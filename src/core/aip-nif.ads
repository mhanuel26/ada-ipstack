------------------------------------------------------------------------------
--                            IPSTACK COMPONENTS                            --
--          Copyright (C) 2010-2014, Free Software Foundation, Inc.         --
------------------------------------------------------------------------------

--  Network Interface abstraction

with System;

with AIP.Config;
with AIP.Buffers;
with AIP.IPaddrs;


package AIP.NIF is
   pragma Preelaborate;

   procedure Initialize;
   --  Initialize NIF subsystem

   type Netif_State is (Invalid, Down, Up);
   --  pragma Convention (C, Netif_State);
   --  State of a network interface

   subtype Netif_Name_Range is Integer range 1 .. 2;
   type Netif_Name is array (Netif_Name_Range) of Character;

   --  Invalid: no associated link-level driver
   --  Down:    driver present but interface inactive
   --  Up:      active interface

   subtype Netif_Id is AIP.EID range 1 .. Config.MAX_NETIF;
   IF_NOID : constant AIP.EID := 0;

   type Checksum_Type is (IP_CS, ICMP_CS, UDP_CS, TCP_CS);
   --  pragma Convention (C, Checksum_Type);

   function NIF_State     (Nid : Netif_Id) return Netif_State with
     Global => null;
   function NIF_Addr      (Nid : Netif_Id) return IPaddrs.IPaddr with
     Global => null;
   function NIF_Mask      (Nid : Netif_Id) return IPaddrs.IPaddr with
     Global => null;
   function NIF_Broadcast (Nid : Netif_Id) return IPaddrs.IPaddr with
     Global => null;

   function NIF_MTU       (Nid : Netif_Id) return AIP.U16_T
   --  Maximum transmission unit
   with
     Global => null;

   procedure If_Config
     (Nid       : Netif_Id;
      IP        : IPaddrs.IPaddr;
      Mask      : IPaddrs.IPaddr;
      Broadcast : IPaddrs.IPaddr;
      Remote    : IPaddrs.IPaddr;
      Err       : out AIP.Err_T)
   --  Set up IP address, netmask, broadcast address and remote address for
   --  Nid, and mark interface as UP.
   with
     Global => null;

   function Is_Local_Address
     (Nid  : Netif_Id;
      Addr : IPaddrs.IPaddr) return Boolean
   --  True if Addr is a local address for Nid
   with
     Global => null;

   function Is_Broadcast_Address
     (Nid  : Netif_Id;
      Addr : IPaddrs.IPaddr) return Boolean
   --  True if Addr is a broadcast address for Nid
   with
     Global => null;

   function Offload
     (Nid      : Netif_Id;
      Checksum : Checksum_Type) return Boolean
   --  True if the driver for Nid supports checksum offloading for the given
   --  checksum.
   with
     Global => null;

   procedure Get_Netif_By_Address
     (Addr : IPaddrs.IPaddr;
      Mask : Boolean;
      Nid  : out AIP.EID)
   --  Find a netif whose address or broadcast address is Addr. If Mask is
   --  True, only the network part of addresses is considered.
   with
     Global => null;

   procedure Get_LL_Address
     (Nid               : Netif_Id;
      LL_Address        : out AIP.LL_Address;
      LL_Address_Length : out AIP.LL_Address_Range)
   --  Copy Nid's link level address into LL_Address, and set LL_Address_Length
   --  to the amount of data copied.
   --  LL_Address'First is expected to be 1.
   with
     Global => null;

   function Get_LL_Address_Length (Nid : Netif_Id) return U8_T;

   procedure NIF_Set_Name
     (Nid  : Netif_Id;
      Name : Netif_Name)
   --  Set the Interface Name
   with
     Global => null;

   procedure NIF_Set_MTU
     (Nid  : Netif_Id;
      MTU  : U16_T)
   --  Set MTU value

   with
     Global => null;

   procedure NIF_Set_LL_Address_Length
     (Nid               : Netif_Id;
      LL_Address_Length : in AIP.LL_Address_Range)
   --  Set the Mac Addres length
   with
     Global => null;

   procedure NIF_Set_LL_Address
     (Nid      : Netif_Id;
      LL_Address : LL_Address_Storage)
   --  Set the Mac Address
   with
     Global => null;

   procedure Input
     (Nid         : Netif_Id;
      Buf         : Buffers.Buffer_Id)
   with
     Global => null;

   procedure Output
     (Nid         : Netif_Id;
      Buf         : Buffers.Buffer_Id;
      Dst_Address : IPaddrs.IPaddr)
   --  Call Nid's Ouptut_CB callback with Buf
   with
     Global => null,
     Depends => (null => (Nid, Buf, Dst_Address));

   procedure Link_Output
     (Nid : Netif_Id;
      Buf : Buffers.Buffer_Id;
      Err : out AIP.Err_T)
   --  Call Nid's Link_Output_CB callback with Buf
   with
     Global => null;

   procedure Allocate_Netif
     (Nid : out EID)
   with
     Global => null;

   procedure NIF_Set_Offload_Checksum
     (Nid      : Netif_Id;
      CS       : Checksum_Type;
      Value    : Boolean)
   with
     Global => null;

   type Link_Output_CB_Procedure is access procedure (Nid : Netif_Id;
                                                      Buf : Buffers.Buffer_Id;
                                                      Err : out Err_T);

   type Output_CB_Procedure is access procedure (Nid : Netif_Id;
                                                 Buf : Buffers.Buffer_Id;
                                                 Dst_Address : IPaddrs.IPaddr);

   type IP_Input_CB_Procedure is access procedure (Nid   : NIF.Netif_Id;
                                                   Buf   : Buffers.Buffer_Id);

   procedure NIF_Set_Input_CB
     (Nid      : Netif_Id;
      CB       : IP_Input_CB_Procedure)
   with
     Global => null;

   procedure NIF_Set_Link_Output_CB
     (Nid      : Netif_Id;
      CB       : Link_Output_CB_Procedure)
   with
     Global => null;

   procedure NIF_Set_Output_CB
     (Nid      : Netif_Id;
      CB       : Output_CB_Procedure)
   with
     Global => null;

private

   --  subtype Netif_Name_Range is Integer range 1 .. 2;
   --  type Netif_Name is array (Netif_Name_Range) of Character;

   --  procedure Allocate_Netif (Nid : out AIP.EID);

   --  Allocate a new netif Id. Return IF_NOID if none is available

   function Get_Netif (Nid : Netif_Id) return System.Address;
   --  Return pointer to Netif record for the given netif

end AIP.NIF;
