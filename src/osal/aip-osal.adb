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
with AIP.IP;
with AIP.ARP;
with AIP.Buffers;
with AIP.TCP;
with AIP.UDP;
with HAL.Bitmap;
with STM32.SDRAM;
with Net.MinIf;

package body AIP.OSAL is

   Err : Err_T;
   Name : NIF.Netif_Name;

   function If_Init return Err_T is
      Mac : LL_Address_Storage;
   begin
      Err := NOERR;
      Name := "st";
      NIF.Allocate_Netif (If_Id);
      if If_Id = NIF.IF_NOID then
         Err := ERR_MEM;
      end if;
      NIF.NIF_Set_Name (If_Id, Name);
      --  Mac (1) := Ifnet.Mac (1);
      for I in Integer range 1 .. 6 loop
         Mac (Net.Uint8 (I)) := Ifnet.Mac (I);
         Netif_MAC_Addr (Net.Uint8 (I)) := Ifnet.Mac (I);
      end loop;
      NIF.NIF_Set_Offload_Checksum (If_Id, NIF.IP_CS, True);
      NIF.NIF_Set_Offload_Checksum (If_Id, NIF.ICMP_CS, True);
      NIF.NIF_Set_Offload_Checksum (If_Id, NIF.UDP_CS, True);
      NIF.NIF_Set_Offload_Checksum (If_Id, NIF.TCP_CS, True);
      NIF.NIF_Set_LL_Address_Length (If_Id, LL_Address_Range'Last);
      NIF.NIF_Set_LL_Address (If_Id, Mac);
      NIF.NIF_Set_MTU (If_Id, Net.Uint16 (1500));
      IP := IPaddrs.IP4 (Ifnet.Ip (1), Ifnet.Ip (2), Ifnet.Ip (3), Ifnet.Ip (4));
      Mask := IPaddrs.IP4 (Ifnet.Netmask (1), Ifnet.Netmask (2), Ifnet.Netmask (3), Ifnet.Netmask (4));
      Broadcast := IPaddrs.IP4 (192, 168, 2, 255);
      Remote := IPaddrs.IP_ADDR_ANY;
      Dns := IPaddrs.IP4 (Ifnet.Dns (1), Ifnet.Dns (2), Ifnet.Dns (3), Ifnet.Dns (4));
      --  make static ARP for tests to isolate the issue with ARP append buffer
      declare
         remote_mac : aliased AIP.Ethernet_Address;
         remote_ip  : aliased AIP.IPaddrs.IPaddr;
         arp_err    : AIP.Err_T;
      begin
         remote_mac := (16#f8#, 16#32#, 16#e4#, 16#88#, 16#57#, 16#0c#);
         remote_ip := IPaddrs.IP4 (192, 168, 2, 5);
         ARP.ARP_Update
           (Nid             => If_Id,
            Eth_Address  => remote_mac,
            IP_Address      => remote_ip,
            Allocate        => True,
            Err             => arp_err);
         pragma Unreferenced (arp_err);
      end;
      --  define the callbacks
      NIF.NIF_Set_Input_CB (If_Id, AIP.IP.IP_Input'Access);
      NIF.NIF_Set_Output_CB (If_Id, AIP.ARP.ARP_Output'Access);
      NIF.NIF_Set_Link_Output_CB (If_Id, Net.MinIf.LL_Output'Access);
      NIF.If_Config (If_Id, IP, Mask, Broadcast, Remote, Err);
      return Err;
   end If_Init;
   --  Initialize network interface.
   --  The interface's initialization routine is responsible for requesting
   --  allocation of a Netif_Id from the NIF subsystem.

   procedure Send (Packet : in out Net.Buffers.Buffer_Type) is
   begin
      Ifnet.Send (Packet);
   end Send;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin
      --  Initialize subsystems

      Buffers.Buffer_Init;
      UDP.UDP_Init;
      TCP.TCP_Init;
      ARP.Initialize;
      NIF.Initialize;

      --  Static IP interface, default netmask and no gateway.
      Ifnet.Ip := (192, 168, 2, 50);
      Ifnet.Gateway := (192, 168, 2, 1);
      Ifnet.Dns := (192, 168, 2, 5);

      --  STMicroelectronics OUI = 00 81 E1
      Ifnet.Mac := (0, 16#81#, 16#E1#, 5, 5, 1);


      --  Setup some receive buffers and initialize the Ethernet driver.
      Net.Buffers.Add_Region (STM32.SDRAM.Reserve (Amount => HAL.UInt32 (NET_BUFFER_SIZE)),
                              NET_BUFFER_SIZE);

      --  Set up interfaces

      Err := If_Init;

      if Any (Err) then
         raise Constraint_Error;
      end if;

      Ifnet.Initialize;

      --  To test the ARP issue and packet loss
--        declare
--           Dst_Ip       : constant AIP.IPaddrs.IPaddr := AIP.IPaddrs.IP4 (192, 168, 2, 5);
--           Ether_Add    : constant AIP.Ethernet_Address := (16#F8#, 16#32#, 16#E4#, 16#88#, 16#57#, 16#0C#);
--           Err          : AIP.Err_T;
--        begin
--           AIP.ARP.ARP_Update (If_Id, Ether_Add, Dst_Ip, True, Err);
--           pragma Unreferenced (Err);
--        end;
   end Initialize;

end AIP.OSAL;
