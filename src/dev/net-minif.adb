-----------------------------------------------------------------------
--  net-minif -- Ethernet Helper Functions for STM32F74x
--  Copyright (C) 2017 Manuel Iglesias
--  Written by Manuel Iglesias (mhanuel.usb@gmail.com)
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
-----------------------------------------------------------------------

with System;
with Net;
with Net.Headers;
with AIP.Conversions;
with AIP.OSAL;
with Net.Protos;
--  with AIP.IO;

package body Net.MinIf is

   Bcast : constant Net.Ether_Addr := (255, 255, 255, 255, 255, 255);

   function LL_Input (Nid : AIP.NIF.Netif_Id;
                      Buf : in out Net.Buffers.Buffer_Type) return AIP.Buffers.Buffer_Id is
      p            : AIP.Buffers.Buffer_Id;
      q            : AIP.Buffers.Buffer_Id;
      size         : AIP.Buffers.Data_Length;
      Ether        : Net.Headers.Ether_Header_Access;
      DstMac       : Net.Ether_Addr;
      LL_Add       : AIP.LL_Address (1 .. 6);
      LL_Add_Len   : AIP.LL_Address_Range;
      Bail_Out     : Boolean := False;
      bufLen       : Standard.Integer;
      srcAdd       : System.Address;
      dstAdd       : System.Address;
   begin
--        pragma Unreferenced (Nid);
      Ether := Buf.Ethernet;
      if Net.Headers.To_Host (Ether.Ether_Type) = Net.Protos.ETHERTYPE_IP then
         --  If we got an IP packet verify the padding to alloc the correct size
         --  since Ada LwIp implementation uses Buffers.Tlen for some calcs
         declare
            IpHdr : Net.Headers.IP_Header_Access;
         begin
            IpHdr := Buf.IP;
            if Net.Headers.To_Host (IpHdr.Ip_Len) <= 46 then
               --  We set the size to alloc according to packet size
               size := Net.Headers.To_Host (IpHdr.Ip_Len) + 14;
            else
               size := Net.Buffers.Get_Data_Size (Buf, Net.Buffers.RAW_PACKET);
            end if;
         end;
      else
         size := Net.Buffers.Get_Data_Size (Buf, Net.Buffers.RAW_PACKET);
      end if;

      DstMac := Ether.Ether_Dhost;
      AIP.NIF.Get_LL_Address (Nid, LL_Add, LL_Add_Len);
      if (Uint_16 (size) < Uint_16 (LL_Add_Len)) then
         return AIP.Buffers.NOBUF;
      end if;
      --  Compare is packet is for us
      --  I know I can do this with Filter options of STM32 ...
      --  but I couldn't make it work, see line 370 of net-interfaces-stm32.adb
      for I in LL_Add'Range loop
         if LL_Add (I) /= DstMac (Standard.Integer (I)) then
            Bail_Out := True;
            exit;
         end if;
      end loop;
      --  Compare Broadcast if Packet Destination Addr match
      if Bail_Out then
         for I in 1 .. Standard.Integer (LL_Add_Len) loop
            if DstMac (I) /= Bcast (I) then
               return AIP.Buffers.NOBUF;
            end if;
         end loop;
      end if;
      AIP.Buffers.Buffer_Alloc (0, size, AIP.Buffers.LINK_BUF, p);
      if p /= AIP.Buffers.NOBUF then
         q := p;
         srcAdd := Net.Buffers.Get_Data_Address (Buf);
         loop
            bufLen := Standard.Integer (AIP.Buffers.Buffer_Len (q));
            dstAdd := AIP.Buffers.Buffer_Payload (q);
            AIP.Conversions.Memcpy (dstAdd, srcAdd, bufLen);
            q := AIP.Buffers.Buffer_Next (q);
            exit when q = AIP.Buffers.NOBUF;
            srcAdd := Net.Buffers.Get_Data_Address_Pos (Buf, Uint16 (bufLen));
         end loop;
      end if;
      Net.Buffers.Release (Buf);
      return p;
   end LL_Input;

   procedure LL_Output (Nid : AIP.NIF.Netif_Id;
                        BufId : AIP.Buffers.Buffer_Id;
                        Err : out AIP.Err_T)
   is
      Packet       : Net.Buffers.Buffer_Type;
      q            : AIP.Buffers.Buffer_Id;
      srcAdd       : System.Address;
      dstAdd       : System.Address;
      Tlen         : Standard.Integer;
      Written      : Standard.Integer := 0;
      bufLen       : Standard.Integer;
   begin
      pragma Unreferenced (Nid);
      Net.Buffers.Allocate (Packet);
      if Packet.Is_Null then
         Err := AIP.ERR_IF;
         return;
      end if;
      q := BufId;
      dstAdd := Net.Buffers.Get_Data_Address (Packet);
      Tlen := Standard.Integer (AIP.Buffers.Buffer_Tlen (BufId));
      loop
         bufLen := Standard.Integer (AIP.Buffers.Buffer_Len (q));
         srcAdd := AIP.Buffers.Buffer_Payload (q);
         AIP.Conversions.Memcpy (dstAdd, srcAdd, bufLen);
         Written := Written + bufLen;
         exit when Written >= Tlen;
         q := AIP.Buffers.Buffer_Next (q);
         dstAdd := Net.Buffers.Get_Data_Address_Pos (Packet, Uint16 (bufLen));
      end loop;
      Packet.Set_Length (Uint16 (Written));
      AIP.OSAL.Send (Packet);
   end LL_Output;

end Net.MinIf;
