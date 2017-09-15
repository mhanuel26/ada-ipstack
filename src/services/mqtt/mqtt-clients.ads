------------------------------------------------------------------------------
--                            IPSTACK MQTT COMPONENT
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

--  TCP mqtt client implementation using the RAW callback API

package MQTT.Clients with
  Abstract_State => (State with Part_Of => MQTT.State)
is

   MSP : Mqtt_Conn_State_Array; -- Mqtt_Conn_State Pool

   procedure Init
   --  Setup MQTT Client Stack
   with
     Global => (Output => (State));

   -----------------------------------------------
   --  MQTT_Timer --  CycleTick Timer Callback  --
   -----------------------------------------------

   procedure MQTT_Timer (Id : Integer)
   --  Called every MQTT_CYCLIC_TIMER_INTERVAL * 1000 ms and implements the MQTT Cycle Tick Timer
   with
     Global => (In_Out => (State));

   procedure Mqtt_Client_Connect
     (Pier           : in out MQTT_Pier;
      Port           : Natural := MQTT_Port;
      Err            : out AIP.Err_T)
   with
     Global => (In_Out => (State));

   procedure Mqtt_Client_Disconnect
     (Pier           : in out MQTT_Pier;
      Err            : out AIP.Err_T);

   procedure Mqtt_Send
     (Pcb : AIP.PCBs.PCB_Id;
      Ms  : in out Mqtt_Conn_State)
   with
     Global => (In_Out => (State));

end MQTT.Clients;
