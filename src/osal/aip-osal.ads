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

--  IP stack OS adaptation layer

--  This unit and its children provide the required facilities to integrate
--  the IP stack within its operating environment.

with Interfaces;
with Net;
with Net.Buffers;
with Net.Interfaces;
with Net.Interfaces.STM32;
--  with AIP;
with AIP.NIF;
with AIP.IPaddrs;

package AIP.OSAL is

   use type Interfaces.Unsigned_32;

   --  Reserve 256 network buffers.
   NET_BUFFER_SIZE : constant Net.Uint32 := Net.Buffers.NET_ALLOC_SIZE * 256;

   --  The Ethernet interface driver.
   Ifnet     : aliased Net.Interfaces.STM32.STM32_Ifnet;

   Netif_MAC_Addr : AIP.Ethernet_Address;

   IP        : aliased AIP.IPaddrs.IPaddr;
   Mask      : aliased AIP.IPaddrs.IPaddr;
   Broadcast : aliased AIP.IPaddrs.IPaddr;
   Dns       : aliased AIP.IPaddrs.IPaddr;
   Remote    : aliased AIP.IPaddrs.IPaddr;

   procedure Send (Packet : in out Net.Buffers.Buffer_Type);

   procedure Initialize;
   --  Initialize the IP stack

private

   function If_Init return AIP.Err_T;

   If_Id : EID := NIF.IF_NOID;
   --  The OSAL assumes a single interface exists, whose Id is If_Id

end AIP.OSAL;
