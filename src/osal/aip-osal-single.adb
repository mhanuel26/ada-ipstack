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

with AIP.ARP;
--  with AIP.TCP;
--  with AIP.Timers;
with Net.MinIf;
with AIP.NIF;
with AIP.OSAL;
--  with MQTT;

package body AIP.OSAL.Single is


   ------------------------------
   -- Process_Arp_Events --
   ------------------------------

   procedure Process_Arp (Buf : in AIP.Buffers.Buffer_Id) is
   begin
      AIP.ARP.ARP_Input (If_Id, AIP.OSAL.Netif_MAC_Addr, Buf);
   end Process_Arp;

   ------------------------------
   -- Process_Input_Events --
   ------------------------------

   procedure Process_Input (Buf : in AIP.Buffers.Buffer_Id) is
   begin
      AIP.NIF.Input (If_Id, Buf);
   end Process_Input;

   ------------------------------
   -- Process_Interface_Events --
   ------------------------------

   function Process_Interface_Events (Buf : in out Net.Buffers.Buffer_Type) return AIP.Buffers.Buffer_Id is
   begin
      return Net.MinIf.LL_Input (If_Id, Buf);
   end Process_Interface_Events;

end AIP.OSAL.Single;
