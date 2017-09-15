------------------------------------------------------------------------------
--                            IPSTACK COMPONENTS                            --
--             Copyright (C) 2010, Free Software Foundation, Inc.           --
------------------------------------------------------------------------------

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
