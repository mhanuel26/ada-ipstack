------------------------------------------------------------------------------
--                            IPSTACK COMPONENTS                            --
--  Written by Manuel Iglesias (Mhanuel.Usb@gmail.com)
--  Copyright (C) 2017.
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

with Ada.Unchecked_Conversion;
with AIP.PCBs;
with AIP.Callbacks;
with Ada.Streams;        use Ada.Streams;

package RAW_MQTT_Callbacks is

   type MQTT_Hook is
     access procedure (Pcb : AIP.PCBs.PCB_Id;
                       DATA : Stream_Element_Array;
                       Err : out AIP.Err_T);

   function To_CBID is new
     Ada.Unchecked_Conversion (MQTT_Hook, AIP.Callbacks.CBK_Id);

   function To_Hook is new
     Ada.Unchecked_Conversion (AIP.Callbacks.CBK_Id, MQTT_Hook);

end RAW_MQTT_Callbacks;
