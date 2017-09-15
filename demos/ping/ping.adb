-----------------------------------------------------------------------
--  ping -- Ping hosts application
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

with Ada.Real_Time;        use Ada.Real_Time;

with AIP.IO;
with BMP_Fonts;
with Net.Buffers;
with Receiver;
with Os_Service;
with Demos;
with MQTT;                     use MQTT;
with Test_MQTT_Clients;
with Test_HTTP_Servers;
with AIP.IPaddrs;
with AIP;                      use AIP;
with AIP.Timers;
with AIP.Time_Types;

pragma Unreferenced (Receiver);
pragma Unreferenced (Os_Service, AIP.Time_Types);

pragma Unreferenced (Test_MQTT_Clients);
--  pragma Unreferenced (Test_HTTP_Servers);

--  == Ping Application ==
--  The <b>Ping</b> application listens to the Ethernet network to identify some local
--  hosts and ping them using ICMP echo requests.
--
--  The <b>Ping</b> application uses the static IP address <b>192.168.1.2</b> and an initial
--  default gateway <b>192.168.1.254</b>.  While running, it discovers the gateway by looking
--  at the IGMP query membership packets.
--
--  The <b>Ping</b> application displays the lists of hosts that it currently pings with
--  the number of ICMP requests that are sent and the number of ICMP replies received.
--
--  The application has two tasks.  The main task loops to manage the refresh of the STM32
--  display and send the ICMP echo requests each second.  The second task is responsible for
--  waiting of Ethernet packets, analyzing them to handle ARP and ICMP packets.  The receiver
--  task also looks at IGMP packets to identify the IGMP queries sent by routers.

procedure Ping is

   procedure Header;
   procedure Header is
   begin
      null;
   end Header;

   procedure Initialize is new Demos.Initialize (Header);

   --  Test MQTT
   Client_Ip     : constant AIP.IPaddrs.IPaddr := AIP.IPaddrs.IP4 (192, 168, 2, 5);
   pragma Unreferenced (Client_Ip);
   --  this will need to hold on until DNS
--     Server_Address : constant String := "test.mosquitto.org";

begin

--     pragma Unreferenced (Client_Ip, Client_Err, Reference);
   AIP.IO.Put_Line ("STM32 Starting ... ");
   Initialize ("STM32 IpStack Demo");
   --  Change font to 8x8.
   Demos.Current_Font := BMP_Fonts.Font8x8;
   --  Instantiate an Mqtt Client
   declare
      Deadline     : Time;
      Now          : constant Time := Clock;
      --  To test Timers
      My_Test_Cb_Timer_Id : AIP.Timers.Valid_Tmr_Id;
      My_Test_Interval : AIP.Time_Types.Interval;

   begin
      pragma Unreferenced (My_Test_Cb_Timer_Id, My_Test_Interval);
      --  MQTT Test Starts
--        delay 1.0;
--        Test_MQTT_Clients.Test_1 (Client_Ip);
--        Test_HTTP_Servers.Test_Web (80);   --  used only for tests while not having the dedicated task.
      Test_HTTP_Servers.Start;
      --        My_Test_Interval := AIP.Time_Types.Time (1 * Duration (AIP.Time_Types.Hz));
      --        AIP.Timers.Timer_Alloc (My_Test_Cb_Timer_Id, Os_Service.Dummy'Access);
      --        AIP.Timers.Set_Interval (My_Test_Cb_Timer_Id, My_Test_Interval);
      AIP.IO.Put_Line ("Enter endless loop");
      loop
         Deadline := Now + Milliseconds (50);
         delay until Deadline;
      end loop;
   end;
end Ping;
