------------------------------------------------------------------------------
--                            IPSTACK COMPONENTS                            --
--          Copyright (C) 2010-2014, Free Software Foundation, Inc.         --
------------------------------------------------------------------------------

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
   Remote    : aliased AIP.IPaddrs.IPaddr;

   procedure Send (Packet : in out Net.Buffers.Buffer_Type);

   procedure Initialize;
   --  Initialize the IP stack

private

   function If_Init return AIP.Err_T;

   If_Id : EID := NIF.IF_NOID;
   --  The OSAL assumes a single interface exists, whose Id is If_Id

end AIP.OSAL;
