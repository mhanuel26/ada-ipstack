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

with Net.Buffers;
with AIP.Buffers;
with AIP.NIF;

package Net.MinIf is

   use type AIP.NIF.Netif_Id;

   function LL_Input (Nid : AIP.NIF.Netif_Id;
                      Buf : in out Net.Buffers.Buffer_Type) return AIP.Buffers.Buffer_Id;

   procedure LL_Output (Nid : AIP.NIF.Netif_Id;
     BufId : AIP.Buffers.Buffer_Id;
     Err : out AIP.Err_T)
   with
     Global => null;

end Net.MinIf;
