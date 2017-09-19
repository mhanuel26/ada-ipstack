------------------------------------------------------------------------------
--                            IPSTACK DNS COMPONENT
--         Copyright (C) 2017.
--  Written by Manuel Iglesias (Mhanuel.Usb@gmail.com)
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
-------------------------------------------------------------------------------
pragma Warnings (Off, "* referenced");
with AIP.IPaddrs;
with Net;
with Net.Headers;
with Interfaces;    use Interfaces;

with System;
with RAW_UDP_Callbacks;


pragma Warnings (Off, "* referenced");
with RAW_UDP_Dispatcher;
with Ada.Unchecked_Conversion;
with Ada.Exceptions;       use Ada.Exceptions;
with Ada.IO_Exceptions;    use Ada.IO_Exceptions;
pragma Warnings (On, "* referenced");

use type AIP.S8_T, AIP.U8_T, AIP.U16_T, AIP.S32_T;

with AIP.OSAL;

package body DNS.Clients with
Refined_State => (State => (DSP))
is

   use type System.Address;

   ------------------
   -- Init_MS_Pool --
   ------------------

   --  Initialize the Mqtt_Conn_State pool, required before any other op

   procedure Init_DS_Pool is
   begin
      null;
      for Id in Valid_DS_Id loop
         DSP (Id).Kind := DNS_FREE;
      end loop;
   end Init_DS_Pool;

   --------------
   -- DS_Alloc --
   --------------

   procedure DS_Alloc (Sid : out DS_Id);

   procedure DS_Alloc (Sid : out DS_Id) is
   begin
      --  Search a free for use entry in the pool. If found, move to MS_NONE,
      --  and return Id. Return NOMS otherwise.

      Sid := NODS;
      for Id in Valid_DS_Id loop
         if DSP (Id).Kind = DNS_FREE then
            DSP (Id).Kind := DNS_READY;
            Sid := Id;
            exit;
         end if;
      end loop;
   end DS_Alloc;

   procedure Dns_Dispatch_Recv
     (Pcb : AIP.PCBs.PCB_Id;
      Ds  : in out Dns_Conn_State);

   procedure Dns_Dispatch_Recv
     (Pcb : AIP.PCBs.PCB_Id;
      Ds  : in out Dns_Conn_State)
   is
      Buf         : AIP.Buffers.Buffer_Id;
      srcAdd      : System.Address;
      Plen        : AIP.U16_T;
      TPlen       : AIP.U16_T;
      Item_Size   : Stream_Element_Offset;
   begin
      if Ds.Buf = AIP.Buffers.NOBUF then
         return;
      end if;
      TPlen := AIP.Buffers.Buffer_Tlen (Ds.Buf);
      declare
         Data     : Stream_Element_Array (1 .. Stream_Element_Offset (TPlen));
         Pointer  : Stream_Element_Offset := Data'First;
      begin
         loop
            Buf := Ds.Buf;
            Plen := AIP.Buffers.Buffer_Len (Buf);
            Item_Size := Stream_Element_Offset (Plen);
            declare
               type SEA_Pointer is
                 access all Stream_Element_Array (1 .. Item_Size);
               srcPtr   : SEA_Pointer;
               function As_SEA_Pointer is
                 new Ada.Unchecked_Conversion (System.Address, SEA_Pointer);
               Data_Ptr : SEA_Pointer;
            begin
               srcAdd := AIP.Buffers.Buffer_Payload (Buf);
               srcPtr := As_SEA_Pointer (srcAdd);
               Data_Ptr := As_SEA_Pointer (Data (Pointer)'Address);
               Data_Ptr.all (1 .. Item_Size) := srcPtr.all (1 .. Item_Size);
               --  Grab reference to the following Buf, if any
               Ds.Buf := AIP.Buffers.Buffer_Next (Buf);
               if Ds.Buf /= AIP.Buffers.NOBUF then
                  AIP.Buffers.Buffer_Ref (Ds.Buf);
               end if;
               --  Deallocate the processed buffer
               AIP.Buffers.Buffer_Blind_Free (Buf);
               exit when Ds.Buf = AIP.Buffers.NOBUF;
               --  Pointer "points" to Next element to copy
               Pointer := Pointer + Item_Size;
               if Pointer > Data'Last then
                  Raise_Exception
                    (Layout_Error'Identity,
                     "Invalid pointer"
                    );
               end if;
            end;
         end loop;
         Do_Receive (Ds, Data);
      end;
      --  Disconnect
      AIP.UDP.UDP_Disconnect (Pcb);
   end Dns_Dispatch_Recv;

   procedure Dns_Receive
     (Ev  : AIP.UDP.UDP_Event_T;
      Pcb : AIP.PCBs.PCB_Id)
   is
      Ds : Dns_Conn_State;
      for Ds'Address use AIP.UDP.UDP_Udata (Pcb);
   begin
      if Ev.Buf = AIP.Buffers.NOBUF then
         if Ds.Buf /= AIP.Buffers.NOBUF then
            Dns_Dispatch_Recv (Pcb, Ds);
         else
            AIP.UDP.UDP_Disconnect (PCB => Pcb);
            AIP.UDP.UDP_Release (PCB => Pcb);
         end if;
      else
         if Ds.Buf = AIP.Buffers.NOBUF then
            AIP.Buffers.Buffer_Ref (Ev.Buf);
            Ds.Buf := Ev.Buf;
            Dns_Dispatch_Recv (Pcb, Ds);
         else
            AIP.Buffers.Buffer_Chain (Ds.Buf, Ev.Buf);
         end if;
      end if;
   end Dns_Receive;

   procedure Bind
     (Request : access Query)
   is
      Port   : constant AIP.U16_T := DNS_PORT;
      Addr   : constant AIP.IPaddrs.IPaddr := AIP.OSAL.Dns;
      Pcb    : AIP.PCBs.PCB_Id;
      Sid    : DS_Id;
      Err    : AIP.Err_T;
   begin
      --  check client existence.
      if Request.Udp_State_Pool /= null then
         Request.Err := AIP.ERR_MEM;
         return;
      end if;
      AIP.UDP.UDP_New (Pcb);
      if Pcb = AIP.PCBs.NOPCB then
         Request.Err := AIP.ERR_MEM;
         return;
      end if;
      AIP.UDP.UDP_Bind (PCB        => Pcb,
                        Local_IP   => IPaddrs.IP_ADDR_ANY,
                        Local_Port => PCBs.Port_T
                          (Shift_Right (Unsigned_16 (Request.Xid), 16)),
                        Err        => Err);
      if Err /= AIP.NOERR then
         goto Udp_Error;
      end if;
      AIP.UDP.UDP_Connect (PCB         => Pcb,
                           Remote_IP   => Addr,
                           Remote_Port => Port,
                           Err         => Err);
      if Err /= AIP.NOERR then
         goto Udp_Error;
      end if;
      DS_Alloc (Sid);
      if Sid = NODS then
         Request.Err := AIP.ERR_MEM;
         goto Udp_Error;
      else
         Request.Sid := Sid;
         Request.Udp_State_Pool := DSP (Sid)'Access;
         Request.Udp_State_Pool.Kind := DNS_READY;
         Request.Udp_State_Pool.Pcb := Pcb;
         Request.Udp_State_Pool.Buf := AIP.Buffers.NOBUF;
         Request.Udp_State_Pool.Sid := Sid;
         AIP.UDP.UDP_Set_Udata (Pcb, DSP (Sid)'Address);
         AIP.UDP.On_UDP_Recv (Pcb, RAW_UDP_Callbacks.DNS_RECV);
         return;
      end if;
<<Udp_Error>>
      AIP.UDP.UDP_Release (Pcb);
   end Bind;

   procedure Send (Request : access Query;
                   Data    : Stream_Element_Array;
                   Last    : Stream_Element_Offset)
   is
      Pointer    : Stream_Element_Offset := Data'First;
      size       : AIP.Buffers.Data_Length;
      p, q       : AIP.Buffers.Buffer_Id;
      BufLen     : AIP.Buffers.Buffer_Length;
      Item_Size  : Stream_Element_Offset;
      dstAdd     : System.Address;
   begin
      size := AIP.U16_T (Last - Pointer);
      AIP.Buffers.Buffer_Alloc (0, size, AIP.Buffers.LINK_BUF, p);
      if p /= AIP.Buffers.NOBUF then
         q := p;
         loop
            BufLen := AIP.Buffers.Buffer_Len (q);
            Item_Size := Stream_Element_Offset (BufLen);
            declare
               type SEA_Pointer is
                 access all Stream_Element_Array (1 .. Item_Size);
               dstPtr   : SEA_Pointer;
               function As_SEA_Pointer is
                 new Ada.Unchecked_Conversion (System.Address, SEA_Pointer);
               Data_Ptr : SEA_Pointer;
            begin
               dstAdd := AIP.Buffers.Buffer_Payload (q);
               dstPtr := As_SEA_Pointer (dstAdd);
               Data_Ptr := As_SEA_Pointer (Data (Pointer)'Address);
               --  copy the actual data using the streams access pointers
               dstPtr.all (1 .. Item_Size) := Data_Ptr.all (1 .. Item_Size);
            end;
            q := AIP.Buffers.Buffer_Next (q);
            --  check if there is one more buffer to fill
            exit when q = AIP.Buffers.NOBUF;
            --  Pointer "points" to Next element to copy
            Pointer := Pointer + Item_Size + 1;
            if Pointer > Last then
               Raise_Exception
                 (Layout_Error'Identity,
                  "Invalid pointer"
                 );
            end if;
         end loop;
         declare
            Ds : Dns_Conn_State;
            for Ds'Address use Clients.DSP (Request.Sid)'Address;
         begin
            Ds.Buf := p;
            AIP.UDP.UDP_Send (PCB => Ds.Pcb,
                              Buf => Ds.Buf,
                              Err => Ds.Err);
            AIP.Buffers.Buffer_Blind_Free (Ds.Buf);
            Ds.Buf := AIP.Buffers.NOBUF;
         end;
      else
         Request.Err := ERR_MEM;
      end if;
   end Send;

end DNS.Clients;
