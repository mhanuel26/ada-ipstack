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

--  IP stack OS adaptation layer, Single task version

--  This unit provides the required facilities to integrate the IP stack
--  within a single task environment.

--  with System;
with AIP.Time_Types;
with AIP.Buffers;
with Net.Buffers;
with AIP.Timers;

package AIP.OSAL.Single is

   procedure Process_Arp (Buf : in AIP.Buffers.Buffer_Id);

   procedure Process_Input (Buf : in AIP.Buffers.Buffer_Id);

   function Process_Interface_Events (Buf : in out Net.Buffers.Buffer_Type) return AIP.Buffers.Buffer_Id;

   procedure Init_Timers renames Timers.Initialize;

   procedure Process_Timers (Now : Time_Types.Time) renames Timers.Timer_Fired_Cb;
   --  Process all timers that have fired since the last check

end AIP.OSAL.Single;
