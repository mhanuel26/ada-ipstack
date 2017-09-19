------------------------------------------------------------------------------
--                  IPSTACK RAW_LwIp_Server RAW API COMPONENT
--         Copyright (C) 2017, Free Software Foundation, Inc.
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

with AIP.TCP;
with AIP.Buffers;
with AIP.IPaddrs;
with AIP.PCBs;
--  with AIP.IO;

with System, RAW_TCP_Callbacks;
with RAW_SOCKET_Callbacks;
with RAW_SOCKET_Dispatcher;

with Ada.Unchecked_Conversion;

with Ada.IO_Exceptions;    use Ada.IO_Exceptions;
use type AIP.S8_T, AIP.U8_T, AIP.U16_T, AIP.S32_T;

package body RAW_LwIp_Server.API_Process with
  Refined_State => (State => (SSP))  --  Socket State Pool
is

   use type System.Address;

--     Null_Array : Ada.Streams.Stream_Element_Array (0 .. -1);

   ---------------------------
   -- Echo State management --
   ---------------------------

   procedure Init_SS_Pool with
     Global => (In_Out => SSP);

   procedure SS_Alloc (Sid : out SS_Id) with
     Global => (In_Out => SSP);

   procedure SS_Release (PCB : AIP.PCBs.PCB_Id; Ss : in out Socket_State);

   -----------------------
   -- Local Subprograms --
   -----------------------

   procedure Socket_Close
     (Pcb : AIP.PCBs.PCB_Id;
      Ss  : in out Socket_State)
   with
     Global => (In_Out => State);

   procedure Socket_Dispatch_Recv
     (Pcb : AIP.PCBs.PCB_Id;
      Ss  : in out Socket_State)
   with
     Global => (In_Out => State);

   procedure SOCKET_Process_Sent
     (Ev  : AIP.TCP.TCP_Event_T;
      Pcb : AIP.PCBs.PCB_Id;
      Err : out AIP.Err_T);

   procedure SOCKET_Process_Abort
     (Ev  : AIP.TCP.TCP_Event_T;
      Pcb : AIP.PCBs.PCB_Id;
      Err : out AIP.Err_T)
   with
     Global => (In_Out => State);

   procedure SOCKET_Process_Poll
     (Ev  : AIP.TCP.TCP_Event_T;
      Pcb : AIP.PCBs.PCB_Id;
      Err : out AIP.Err_T);

   procedure SOCKET_Process_Recv
     (Ev  : AIP.TCP.TCP_Event_T;
      Pcb : AIP.PCBs.PCB_Id;
      Err : out AIP.Err_T);

   procedure SOCKET_Process_Accept
     (Ev  : AIP.TCP.TCP_Event_T;
      Pcb : AIP.PCBs.PCB_Id;
      Err : out AIP.Err_T);
--     pragma Unreferenced (SOCKET_Process_Accept);
   ------------------
   -- Init_SS_Pool --
   ------------------

   --  Initialize the Socket_State pool, required before any other op

   procedure Init_SS_Pool is
   begin
      for Id in Valid_SS_Id loop
         SSP (Id).Kind := SS_FREE;
      end loop;
   end Init_SS_Pool;

   ------------------
   ----  Init    ----
   ------------------SOCKET_Event

--     procedure Init with
--       Refined_Global => (Output => SSP)
--     is
--     begin
--        Init_SS_Pool;
--     end Init;

   --------------
   -- SS_Alloc --
   --------------

   procedure SS_Alloc (Sid : out SS_Id) is
   begin
      --  Search a free for use entry in the pool. If found, move to SS_NONE,
      --  and return Id. Return NOSS otherwise.

      Sid := NOSS;
      for Id in Valid_SS_Id loop
         if SSP (Id).Kind = SS_FREE then
            SSP (Id).Kind := SS_READY;
            Sid := Id;
            exit;
         end if;
      end loop;
   end SS_Alloc;

   ----------------
   -- SS_Release --
   ----------------

   procedure SS_Release (PCB : AIP.PCBs.PCB_Id; Ss : in out Socket_State) is
   begin
      --  This is not really neccessary since we are
      --  initializing the IPCBs entry when Last Ack received
      AIP.TCP.TCP_Set_Udata (PCB, System.Null_Address);

      --  Mark entry as free so that it can be reused

      Ss.Kind := SS_FREE;
   end SS_Release;

   ----------------
   -- Socket_Close --
   ----------------

   procedure Socket_Close
     (Pcb : AIP.PCBs.PCB_Id;
      Ss  : in out Socket_State)
   is
      Err : AIP.Err_T;
   begin
      SS_Release (Pcb, Ss);
      AIP.TCP.TCP_Close (Pcb, Err);
      pragma Assert (AIP.No (Err));
   end Socket_Close;



   -----------------------
   -- SOCKET_Process_Sent --
   -----------------------

   procedure SOCKET_Process_Sent
     (Ev  : AIP.TCP.TCP_Event_T;
      Pcb : AIP.PCBs.PCB_Id;
      Err : out AIP.Err_T)
   is
      pragma Unreferenced (Ev);

      Ss : Socket_State;
      for Ss'Address use AIP.TCP.TCP_Udata (Pcb);
   begin
      if Ss.Buf /= AIP.Buffers.NOBUF then
         --  More data to send, do it now

         Socket_Send (Pcb, Ss);
      end if;

--        elsif Ss.Kind = SS_CLOSING then
--           Socket_Close (Pcb, Ss);
--        end if;

      Err := AIP.NOERR;
   end SOCKET_Process_Sent;

   ------------------------
   -- SOCKET_Process_Abort --
   ------------------------

   procedure SOCKET_Process_Abort
     (Ev  : AIP.TCP.TCP_Event_T;
      Pcb : AIP.PCBs.PCB_Id;
      Err : out AIP.Err_T)
   is
      pragma Unreferenced (Ev);

      Ss : Socket_State;
      for Ss'Address use AIP.TCP.TCP_Udata (Pcb);

   begin
      SS_Release (Pcb, Ss);
      Err := AIP.NOERR;
   end SOCKET_Process_Abort;

   -----------------------
   -- SOCKET_Process_Poll --
   -----------------------

   procedure SOCKET_Process_Poll
     (Ev  : AIP.TCP.TCP_Event_T;
      Pcb : AIP.PCBs.PCB_Id;
      Err : out AIP.Err_T)
   is
      pragma Unreferenced (Ev);

      Ss : Socket_State;
      for Ss'Address use AIP.TCP.TCP_Udata (Pcb);

   begin
      if Ss'Address = System.Null_Address then
         AIP.TCP.TCP_Drop (Pcb);
         Err := AIP.ERR_ABRT;

      elsif Ss.Buf /= AIP.Buffers.NOBUF then
         Socket_Send (Pcb, Ss);
         Err := AIP.NOERR;

      elsif Ss.Kind = SS_CLOSING then
         Socket_Close (Pcb, Ss);
         Err := AIP.NOERR;
      end if;
   end SOCKET_Process_Poll;


   ------------------------
   -- Mqtt_Dispatch_Recv --
   ------------------------

   procedure Socket_Dispatch_Recv
     (Pcb : AIP.PCBs.PCB_Id;
      Ss  : in out Socket_State)
   is
      Buf         : AIP.Buffers.Buffer_Id;
      srcAdd      : System.Address;
      Plen        : AIP.U16_T;
      TPlen       : AIP.U16_T;
      Item_Size   : Stream_Element_Offset;
      Err         : AIP.Err_T;
   begin
      if Ss.Buf = AIP.Buffers.NOBUF then
         return;
      end if;
      TPlen := AIP.Buffers.Buffer_Tlen (Ss.Buf);
      --  Signal TCP layer that we can accept more data
      AIP.TCP.TCP_Recved (Pcb, TPlen);
      declare
         Data     : Stream_Element_Array (1 .. Stream_Element_Offset (TPlen));
         Pointer  : Stream_Element_Offset := Data'First;
      begin
         loop
            Buf := Ss.Buf;
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
               Ss.Buf := AIP.Buffers.Buffer_Next (Buf);
               if Ss.Buf /= AIP.Buffers.NOBUF then
                  AIP.Buffers.Buffer_Ref (Ss.Buf);
               end if;
               --  Deallocate the processed buffer
               AIP.Buffers.Buffer_Blind_Free (Buf);
               exit when Ss.Buf = AIP.Buffers.NOBUF;
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
         pragma Warnings (Off, """Err"" modified by call, *");
         RAW_SOCKET_Dispatcher.SOCKET_Event
           (Client =>    Ss.Client,
            PCB    =>    Pcb,
            DATA   =>    Data,
            Cbid   =>    RAW_SOCKET_Callbacks.To_CBID (Do_Receive'Access),
            Err    =>    Err);
         pragma Warnings (On, """Err"" modified by call, *");
      end;
   end Socket_Dispatch_Recv;

   -----------------------
   -- SOCKET_Process_Recv --
   -----------------------

   procedure SOCKET_Process_Recv
     (Ev  : AIP.TCP.TCP_Event_T;
      Pcb : AIP.PCBs.PCB_Id;
      Err : out AIP.Err_T)
   is
      Ss : Socket_State;
      for Ss'Address use AIP.TCP.TCP_Udata (Pcb);

   begin
      if Ev.Buf = AIP.Buffers.NOBUF then

         --  Remote host closed connection. Process what is left to be
         --  sent or close on our side.

         Ss.Kind := SS_CLOSING;

         if Ss.Buf /= AIP.Buffers.NOBUF then
            Socket_Dispatch_Recv (Pcb, Ss);
         else
            Socket_Close (Pcb, Ss);
         end if;

      else
         case Ss.Kind is
            when SS_ACCEPTED =>

               Ss.Kind := SS_RECEIVED;
               Ss.Buf  := Ev.Buf;
               AIP.Buffers.Buffer_Ref (Ev.Buf);
               Socket_Dispatch_Recv (Pcb, Ss);

            when SS_RECEIVED =>

               --  Read some more data

               if Ss.Buf = AIP.Buffers.NOBUF then
                  AIP.Buffers.Buffer_Ref (Ev.Buf);
                  Ss.Buf := Ev.Buf;
                  Socket_Dispatch_Recv (Pcb, Ss);

               else
                  AIP.Buffers.Buffer_Chain (Ss.Buf, Ev.Buf);
               end if;

            when others =>

               --  Remote side closing twice (SS_CLOSING), or inconsistent
               --  state. Trash.

--                 AIP.TCP.TCP_Recved (Pcb, AIP.Buffers.Buffer_Tlen (Ev.Buf));
               Ss.Buf := AIP.Buffers.NOBUF;

         end case;

      end if;

      Err := AIP.NOERR;
   end SOCKET_Process_Recv;

   -------------------------
   -- SOCKET_Process_Accept --
   -------------------------

   procedure SOCKET_Process_Accept
     (Ev  : AIP.TCP.TCP_Event_T;
      Pcb : AIP.PCBs.PCB_Id;
      Err : out AIP.Err_T)
   is
      Sid      : SS_Id;
      Factory : access Connections_Factory'Class renames lwIp_Factory;
   begin
      Err := AIP.NOERR;
      SS_Alloc (Sid);

      if Sid = NOSS then
         Err := AIP.ERR_MEM;
      else
         Factory.Socket_SP (Sid).Kind := SS_ACCEPTED;
         Factory.Socket_SP (Sid).Pcb := Pcb;
         Factory.Socket_SP (Sid).Buf := AIP.Buffers.NOBUF;

         AIP.TCP.TCP_Set_Udata (Pcb, SSP (Sid)'Address);

         AIP.TCP.On_TCP_Sent
           (Pcb, RAW_TCP_Callbacks.To_CBID (SOCKET_Process_Sent'Access));
         AIP.TCP.On_TCP_Recv
           (Pcb, RAW_TCP_Callbacks.To_CBID (SOCKET_Process_Recv'Access));
         AIP.TCP.On_TCP_Abort
           (Pcb, RAW_TCP_Callbacks.To_CBID (SOCKET_Process_Abort'Access));
         AIP.TCP.On_TCP_Poll
           (Pcb, RAW_TCP_Callbacks.To_CBID (SOCKET_Process_Poll'Access), 500);

         AIP.TCP.TCP_Accepted (Pcb);

         declare
            Data : Ada.Streams.Stream_Element_Array (1 .. 1);
         begin
            --  This is our way around to associate the Server Connection
            --  Pool to a given Pcb and thou fill specific client callbacks
            --  at the upper layer.
            Data (Data'First) := Ada.Streams.Stream_Element (Sid);
            RAW_SOCKET_Dispatcher.SOCKET_Event
              (Client  =>    Factory.Socket_SP (Sid).Client,
               PCB     =>    Pcb,
               DATA    =>    Data,  --  Not really used in upper layer let's see...
               Cbid    =>    RAW_SOCKET_Callbacks.To_CBID (Do_Create'Access),
               Err     =>    Err);
            if Factory.Socket_SP (Sid).Client = null then
               Err := AIP.ERR_MEM;
               Socket_Close (Pcb, SSP (Sid));
            else
               declare
                  This : Connection'Class renames Factory.Socket_SP (Sid).Client.all;
               begin
                  This.Sid            := Sid;
                  This.Client         := False;
                  This.Connect_No     := 0;
                  This.Client_Address := Ev.Addr;
                  This.Client_Port    := Ev.Port;
                  This.Err            := AIP.NOERR;
                  Clear (This);
                  This.Listener := lwIp_Listener.all'Unchecked_Access;
                  if This.Transport = null then -- Ready
                     This.Session := Session_Connected;
                     Connected (This);
                  else
                     This.Session := Session_Handshaking;
                  end if;
                  Err := This.Err;
               end;
            end if;
         end;
      end if;
   end SOCKET_Process_Accept;

   ----------
   -- Init --
   ----------

   procedure Initialize
     (Listener       : access Connections_Server'Class;
      Factory        : access Connections_Factory'Class;
      Err            : out AIP.Err_T)
   is
      Pcb            : AIP.PCBs.PCB_Id;
      Port           : Integer;
   begin
--        pragma Unreferenced (Pcb, Port, Err);
--        pragma Unreferenced (Listener);

      Init_SS_Pool;
      lwIp_Listener := Listener.all'Unchecked_Access;
      lwIp_Factory := Factory.all'Unchecked_Access;

      Port := Integer (lwIp_Factory.Port);

      AIP.TCP.TCP_New (Pcb);
      if Pcb = AIP.PCBs.NOPCB then
         Err := AIP.ERR_MEM;
      else
         AIP.TCP.TCP_Bind
           (PCB        => Pcb,
            Local_IP   => AIP.IPaddrs.IP_ADDR_ANY,
            Local_Port => AIP.U16_T (Port),
            Err        => Err);
      end if;

      if Err = AIP.NOERR then
         AIP.TCP.TCP_Listen (Pcb, Err);
         pragma Assert (AIP.No (Err));
         --  Factory Socket State Pool is linked
         for Sid in lwIp_Factory.Socket_SP'Range loop
            lwIp_Factory.Socket_SP (Sid) := SSP (Sid)'Access;
         end loop;
         AIP.TCP.On_TCP_Accept
           (Pcb, RAW_TCP_Callbacks.To_CBID (SOCKET_Process_Accept'Access));
      end if;

   end Initialize;



end RAW_LwIp_Server.API_Process;
