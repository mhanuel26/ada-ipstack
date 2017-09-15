-----------------------------------------------------------------------
--  OS periodic task
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
with AIP.IO;
with Ada.Synchronous_Task_Control;
with Demos;
with HAL.Bitmap;
with STM32.Board;
with Interfaces;
with Ada.Real_Time;
with AIP.Timers;
with AIP.Time_Types;
with AIP.OSAL.Single;
--  with MQTT;                     use MQTT;
with Test_MQTT_Clients;        use Test_MQTT_Clients;
with Handles;                  use Handles;
with AIP.IPaddrs;
with AIP;                      use AIP;

with AIP.ARP;
with AIP.NIF;

package body Os_Service is

   procedure Send_ARP;
--     pragma Unreferenced (mqtt_connect);
   pragma Unreferenced (Send_ARP);

   use type Interfaces.Unsigned_32;
   use type Ada.Real_Time.Time;
   use type Ada.Real_Time.Time_Span;
   use type AIP.Time_Types.Time;

   Ready  : Ada.Synchronous_Task_Control.Suspension_Object;

   TIMER_PERIOD   : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (50);

   procedure Dummy (Id : Integer) is
   begin
--        pragma Unreferenced (Id);
      AIP.IO.Put_Line ("Connect");
      mqtt_connect;
--        AIP.IO.Put_Line ("ARP");
--        Send_ARP;
      --  One Time Timer
      AIP.Timers.Timer_Stop (Id);
   end Dummy;

   procedure Send_ARP is
      Nid         : constant NIF.Netif_Id := 1;
      Dst_Address : constant IPaddrs.IPaddr := AIP.IPaddrs.IP4 (192, 168, 2, 5);
   begin
      AIP.ARP.Send_Request (Nid, Dst_Address);
   end Send_ARP;

   procedure Refresh;
   procedure Refresh is
   begin
      Demos.Refresh_Ifnet_Stats;
      STM32.Board.Display.Update_Layer (1);
   end Refresh;
   pragma Unreferenced (Refresh);
   --     pragma Unreferenced (Refresh);

   pragma Warnings (Off, "procedure * is not referenced");

   procedure mqtt_connect is
      Reference     : Handle;
      Client_Ip     : constant AIP.IPaddrs.IPaddr := AIP.IPaddrs.IP4 (192, 168, 2, 5);
      Client_Err    : AIP.Err_T;
   begin
      Set (Reference, new Test_Client (Max_Subscribe_Topics => 20));
      declare
         Client       : Test_Client renames Test_Client (Ptr (Reference).all);
      begin
         Client.Set_Client_Ip (Client_Ip);
         Connect (Client, Client_Err);
         if Client_Err = AIP.NOERR then
            AIP.IO.Put_Line ("STM32 Connect Command Accepted");
--              Send_Connect (Client, "TestMQTTclient", Client_Err);
--              delay 1.0;
--              Send_Ping (Client);
--              delay 1.0;
--              Send_Publish (Client,
--                            "makewithAda/ipstack/test",
--                            "bonjour Ada world!",
--                            (At_Least_Once, 12));
--              delay 1.0;
--              Send_Disconnect (Client);
            delay 3.0;
--              Disconnect (Client, Client_Err);
         else
            AIP.IO.Put_Line ("STM32 Connect Error");
         end if;
      end;
   end mqtt_connect;
   pragma Warnings (On, "procedure * is not referenced");

   --  ------------------------------
   --  Start the Periodic OS loop.
   --  ------------------------------
   procedure Start is
   begin
      AIP.OSAL.Single.Init_Timers;
      Ada.Synchronous_Task_Control.Set_True (Ready);
   end Start;

   task body Periodic is

      Prev_Clock, Clock  : AIP.Time_Types.Time := AIP.Time_Types.Time'First;
      timer_deadline : Ada.Real_Time.Time;

      Poll_Freq : constant := 50;

   begin
      pragma Unreferenced (Prev_Clock, Poll_Freq);
      Ada.Synchronous_Task_Control.Suspend_Until_True (Ready);
--        AIP.IO.Put_Line ("Periodic Task Starting, TIMER_PERIOD is");
--        AIP.IO.Put_Line (Duration'Image (Ada.Real_Time.To_Duration (TIMER_PERIOD)));
      Clock := AIP.Time_Types.Now;
      timer_deadline := Ada.Real_Time.Clock;
      loop
--           loop
--              Clock := AIP.Time_Types.Now;
--              exit when Clock >= Prev_Clock + Poll_Freq;
--           end loop;
--           Prev_Clock := Clock;
         delay until timer_deadline;
         Clock := AIP.Time_Types.Now;
         AIP.OSAL.Single.Process_Timers (Clock);
         timer_deadline := timer_deadline + TIMER_PERIOD;
--           Refresh;
      end loop;
   end Periodic;

end Os_Service;
