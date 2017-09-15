-----------------------------------------------------------------------
--  receiver -- Ethernet Packet Receiver
--  Copyright (C) 2016, 2017 Stephane Carrez
--  Written by Stephane Carrez (Stephane.Carrez@gmail.com)
--
--  Modified by Manuel Iglesias (mhanuel.usb@gmail.com)
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
with Ada.Real_Time;
with Ada.Synchronous_Task_Control;
with Net.Buffers;
with AIP.OSAL;
with AIP.OSAL.Single;
with AIP.Buffers;
with AIP.EtherH;
with AIP;
with AIP.IO;

package body Receiver is

   use type Net.Ip_Addr;
   use type Net.Uint8;
   use type Net.Uint16;

   Ready  : Ada.Synchronous_Task_Control.Suspension_Object;
--     ONE_US : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Microseconds (1);

   --  ------------------------------
   --  Start the receiver loop.
   --  ------------------------------
   procedure Start is
   begin
      Ada.Synchronous_Task_Control.Set_True (Ready);
   end Start;

   task body Controller is
      use type Ada.Real_Time.Time;
      use type Ada.Real_Time.Time_Span;
      use type Net.Uint64;
      use type Net.Ether_Addr;

      Buf     : AIP.Buffers.Buffer_Id;
      Ethhr   : System.Address;
      Ftype   : Net.Uint16;
      Packet  : Net.Buffers.Buffer_Type;
--        Now     : Ada.Real_Time.Time;
--        Dt      : Us_Time;
--        Total   : Net.Uint64 := 0;
--        Count   : Net.Uint64 := 0;
      Err     : AIP.Err_T;
   begin
      --  Wait until the Ethernet driver is ready.
      Ada.Synchronous_Task_Control.Suspend_Until_True (Ready);
      AIP.IO.Put_Line ("Receiver Task Starts");
      --  Loop receiving packets and dispatching them.
--        Min_Receive_Time := Us_Time'Last;
--        Max_Receive_Time := Us_Time'First;
      loop
         if Packet.Is_Null then
            Net.Buffers.Allocate (Packet);
            exit when Packet.Is_Null;
         end if;
         if not Packet.Is_Null then
            --  Block until there is a packet to process
            AIP.OSAL.Ifnet.Receive (Packet);
--              Now := Ada.Real_Time.Clock;
            Buf := AIP.OSAL.Single.Process_Interface_Events (Packet);
            if Buf /= AIP.Buffers.NOBUF then
               RcvCnt := RcvCnt + 1;
               Ethhr := AIP.Buffers.Buffer_Payload (Buf);
               Ftype := AIP.EtherH.EtherH_Frame_Type (Ethhr);
               case Ftype is
                  when AIP.EtherH.Ether_Type_IP =>
                     AIP.Buffers.Buffer_Header (Buf, AIP.S16_T (-14), Err);
                     if AIP.Any (Err) then
                        ErrCnt := ErrCnt + 1;
                        AIP.Buffers.Buffer_Blind_Free (Buf);
                     else
                        AIP.OSAL.Single.Process_Input (Buf);
                     end if;
                  when AIP.EtherH.Ether_Type_ARP =>
                     AIP.OSAL.Single.Process_Arp (Buf);
                  when others =>
                     AIP.Buffers.Buffer_Blind_Free (Buf);
                     ErrOtherType := ErrOtherType + 1;
               end case;
            else
               NoBufCnt := NoBufCnt + 1;
            end if;
            --  Compute the time taken to process the packet in microseconds.
--              Dt := Us_Time ((Ada.Real_Time.Clock - Now) / ONE_US);
--              --  Compute average, min and max values.
--              Count := Count + 1;
--              Total := Total + Net.Uint64 (Dt);
--              Avg_Receive_Time := Us_Time (Total / Count);
--              if Dt < Min_Receive_Time then
--                 Min_Receive_Time := Dt;
--              end if;
--              if Dt > Max_Receive_Time then
--                 Max_Receive_Time := Dt;
--              end if;
         end if;
      end loop;
      AIP.IO.Put_Line ("Problem with Net Stack Packet allocation");
   end Controller;

end Receiver;
