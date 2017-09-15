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

with RAW_MQTT_Callbacks;

package body RAW_MQTT_Dispatcher is

   use type AIP.Callbacks.CBK_Id;

   procedure MQTT_Event
     (PCB  : AIP.PCBs.PCB_Id;
      DATA : Stream_Element_Array;
      Cbid : AIP.Callbacks.CBK_Id;
      Err  : out AIP.Err_T)
   is
   begin
      if Cbid /= AIP.Callbacks.NOCB then
         RAW_MQTT_Callbacks.To_Hook (Cbid).all (PCB, DATA, Err);
      end if;
   end MQTT_Event;

end RAW_MQTT_Dispatcher;
