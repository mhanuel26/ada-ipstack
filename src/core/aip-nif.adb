------------------------------------------------------------------------------
--                            IPSTACK COMPONENTS                            --
--          Copyright (C) 2010-2014, Free Software Foundation, Inc.         --
------------------------------------------------------------------------------

package body AIP.NIF with
  SPARK_Mode => Off
is

   type Offload_Checksums_Array is array (Checksum_Type) of Boolean;
   --  pragma Convention (C, Offload_Checksums_Array);

   type Netif is record
      Name              : Netif_Name;
      --  Unique name of interface

      State             : Netif_State;
      --  Interface state

      LL_Address        : LL_Address_Storage;
      --  Link-level address

      LL_Address_Length : U8_T;
      --  Actual length of link level address

      MTU               : U16_T;
      --  Maximum Transmission Unit

      IP                : IPaddrs.IPaddr;
      --  IP address

      Mask              : IPaddrs.IPaddr;
      --  Netmask

      Broadcast         : IPaddrs.IPaddr;
      --  Broadcast address: (IP and mask) or (not mask)

      Remote            : IPaddrs.IPaddr;
      --  Remote address (case of a point-to-point interface)

      Offload_Checksums : Offload_Checksums_Array;
      --  Each component of the array is set True for devices that support
      --  offloading of the corresponding checksum. In that case, checksums
      --  are set to 0 on output and ignored on input.

      Configured_CB     : System.Address;
      --  Low-level configuration callback (called by If_Config)
      --  procedure C (Nid; Err : out Err_T);

      Input_CB          : IP_Input_CB_Procedure;
      --  Packet input callback
      --  procedure I (Nid : Netif_Id; Buf : Buffer_Id);

      Output_CB         : Output_CB_Procedure;
      --  Packet output callback (called by network layer)
      --  procedure O (Nid : Netif_Id; Buf : Buffer_Id; Dst_Address : IPaddr);

      Link_Output_CB    : Link_Output_CB_Procedure;
      --  Link level packet output callback (called by ARP layer)
      --  procedure LO (Nid : Netif_Id; Buf : Buffer_Id; Err : out Err_T);

      Dev               : System.Address;
      --  Driver private information
   end record;
   --  pragma Convention (C, Netif);

   type NIF_Array is array (Netif_Id) of aliased Netif;

   NIFs : NIF_Array;

   --------------------
   -- Allocate_Netif --
   --------------------

   procedure Allocate_Netif (Nid : out EID) is
   begin
      Nid := IF_NOID;
      for J in NIFs'Range loop
         if NIFs (J).State = Invalid then
            Nid := J;

            --  Mark NIF as allocated

            NIFs (J).State := Down;
            exit;
         end if;
      end loop;
   end Allocate_Netif;

   function Get_LL_Address_Length (Nid : Netif_Id) return U8_T is
   begin
      return NIFs (Nid).LL_Address_Length;
   end Get_LL_Address_Length;
   --------------------
   -- Get_LL_Address --
   --------------------

   procedure Get_LL_Address
     (Nid               : Netif_Id;
      LL_Address        : out AIP.LL_Address;
      LL_Address_Length : out AIP.LL_Address_Range)
   is
      pragma Assert (LL_Address'First = 1);
      This_LL_Address_Last : constant LL_Address_Range :=
        NIFs (Nid).LL_Address_Length;
   begin
      LL_Address (1 .. This_LL_Address_Last) :=
        NIFs (Nid).LL_Address (1 .. This_LL_Address_Last);
      LL_Address_Length := NIFs (Nid).LL_Address_Length;
   end Get_LL_Address;

   ---------------
   -- Get_Netif --
   ---------------

   function Get_Netif (Nid : Netif_Id) return System.Address is
   begin
      return NIFs (Nid)'Address;
   end Get_Netif;

   --------------------------
   -- Get_Netif_By_Address --
   --------------------------

   procedure Get_Netif_By_Address
     (Addr : IPaddrs.IPaddr;
      Mask : Boolean;
      Nid  : out EID)
   is
   begin
      Nid := IF_NOID;
      Scan_Netifs : for J in NIFs'Range loop
         if NIFs (J).State = Up
           and then
             (NIFs (J).IP = Addr
              or else NIFs (J).Broadcast = Addr
              or else
                (Mask and then
                        (((NIFs (J).IP xor Addr) and NIFs (J).Mask) = 0)))
         then
            Nid := J;
            exit Scan_Netifs;
         end if;
      end loop Scan_Netifs;
   end Get_Netif_By_Address;

   ---------------
   -- If_Config --
   ---------------

   procedure If_Config
     (Nid       : Netif_Id;
      IP        : IPaddrs.IPaddr;
      Mask      : IPaddrs.IPaddr;
      Broadcast : IPaddrs.IPaddr;
      Remote    : IPaddrs.IPaddr;
      Err       : out Err_T)
   is
      --  type Configured_CB_Ptr is access
      --    procedure (Nid : Netif_Id; Err : out Err_T);
      --  pragma Convention (C, Configured_CB_Ptr);
      --  function To_Ptr is new Ada.Unchecked_Conversion
      --    (System.Address, Configured_CB_Ptr);

   begin
      NIFs (Nid).IP        := IP;
      NIFs (Nid).Mask      := Mask;
      NIFs (Nid).Broadcast := Broadcast;
      NIFs (Nid).Remote    := Remote;
      Err := NOERR;
      --  To_Ptr (NIFs (Nid).Configured_CB) (Nid, Err);

      if No (Err) then
         NIFs (Nid).State := Up;
      end if;
   end If_Config;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin
      NIFs :=
        (others => Netif'(State             => Invalid,
                          Name              => "  ",
                          IP                => IPaddrs.IP_ADDR_ANY,
                          Mask              => IPaddrs.IP_ADDR_ANY,
                          Broadcast         => IPaddrs.IP_ADDR_ANY,
                          Remote            => IPaddrs.IP_ADDR_ANY,
                          Offload_Checksums => (others => False),
                          Configured_CB     => System.Null_Address,
                          Input_CB          => null,
                          Output_CB         => null,
                          Link_Output_CB    => null,
                          LL_Address        => (others => 0),
                          LL_Address_Length => 0,
                          MTU               => 0,
                          Dev               => System.Null_Address));
   end Initialize;

   ----------------------
   -- Is_Local_Address --
   ----------------------

   function Is_Local_Address
     (Nid  : Netif_Id;
      Addr : IPaddrs.IPaddr) return Boolean
   is
   begin
      return Addr = NIF_Addr (Nid);
   end Is_Local_Address;

   --------------------------
   -- Is_Broadcast_Address --
   --------------------------

   function Is_Broadcast_Address
     (Nid  : Netif_Id;
      Addr : IPaddrs.IPaddr) return Boolean
   is
   begin
      return Addr = IPaddrs.IP_ADDR_BCAST
               or else Addr = NIF_Broadcast (Nid);
   end Is_Broadcast_Address;

   -----------------
   -- Link_Output --
   -----------------

   procedure Link_Output
     (Nid : Netif_Id;
      Buf : Buffers.Buffer_Id;
      Err : out Err_T)
   is
   begin
      NIFs (Nid).Link_Output_CB (Nid, Buf, Err);
   end Link_Output;

   -------------------
   -- NIF_Broadcast --
   -------------------

   function NIF_Broadcast (Nid : Netif_Id) return IPaddrs.IPaddr is
   begin
      return NIFs (Nid).Broadcast;
   end NIF_Broadcast;

   --------------
   -- NIF_Addr --
   --------------

   function NIF_Addr (Nid : Netif_Id) return IPaddrs.IPaddr is
   begin
      return NIFs (Nid).IP;
   end NIF_Addr;

   --------------
   -- NIF_Mask --
   --------------

   function NIF_Mask (Nid : Netif_Id) return IPaddrs.IPaddr is
   begin
      return NIFs (Nid).Mask;
   end NIF_Mask;

   -------------
   -- NIF_MTU --
   -------------

   function NIF_MTU (Nid : Netif_Id) return AIP.U16_T is
   begin
      return NIFs (Nid).MTU;
   end NIF_MTU;

   ---------------
   -- NIF_State --
   ---------------

   function NIF_State (Nid : Netif_Id) return Netif_State is
   begin
      return NIFs (Nid).State;
   end NIF_State;

   -------------
   -- Offload --
   -------------

   function Offload
     (Nid      : Netif_Id;
      Checksum : Checksum_Type) return Boolean
   is
   begin
      return NIFs (Nid).Offload_Checksums (Checksum);
   end Offload;

   ---------------
   -- Set Name --
   ---------------

   procedure NIF_Set_Name
     (Nid      : Netif_Id;
      Name : Netif_Name)
   is
   begin
      NIFs (Nid).Name := Name;
   end NIF_Set_Name;

   ---------------
   -- Set MTU   --
   ---------------

   procedure NIF_Set_MTU
     (Nid  : Netif_Id;
      MTU  : U16_T)
   is
   begin
      NIFs (Nid).MTU := MTU;
   end NIF_Set_MTU;

   -------------------
   -- Set MAC Len   --
   -------------------

   procedure NIF_Set_LL_Address_Length
     (Nid               : Netif_Id;
      LL_Address_Length : in AIP.LL_Address_Range)
   is
   begin
      NIFs (Nid).LL_Address_Length := LL_Address_Length;
   end NIF_Set_LL_Address_Length;

   ---------------
   -- Set MAC   --
   ---------------

   procedure NIF_Set_LL_Address
     (Nid      : Netif_Id;
      LL_Address : LL_Address_Storage)
   is
      This_LL_Address_Last : constant LL_Address_Range :=
        NIFs (Nid).LL_Address_Length;
   begin
      NIFs (Nid).LL_Address (1 .. This_LL_Address_Last) :=
        LL_Address (1 .. This_LL_Address_Last);
   end NIF_Set_LL_Address;

   ----------------------------
   -- Set Offload Checksum   --
   ----------------------------

   procedure NIF_Set_Offload_Checksum
     (Nid      : Netif_Id;
      CS       : Checksum_Type;
      Value    : Boolean)
   is
   begin
      NIFs (Nid).Offload_Checksums (CS) := Value;
   end NIF_Set_Offload_Checksum;


   ------------------
   -- Set Input_CB --
   ------------------

   procedure NIF_Set_Input_CB
     (Nid      : Netif_Id;
      CB       : IP_Input_CB_Procedure)
   is
   begin
      NIFs (Nid).Input_CB := CB;
   end NIF_Set_Input_CB;

   -------------------
   -- Set Output_CB --
   -------------------

   procedure NIF_Set_Output_CB
     (Nid      : Netif_Id;
      CB       : Output_CB_Procedure)
   is
   begin
      NIFs (Nid).Output_CB := CB;
   end NIF_Set_Output_CB;

   ------------------------
   -- Set Link_Output_CB --
   ------------------------

   procedure NIF_Set_Link_Output_CB
     (Nid      : Netif_Id;
      CB       : Link_Output_CB_Procedure)
   is
   begin
      NIFs (Nid).Link_Output_CB := CB;
   end NIF_Set_Link_Output_CB;

   ------------
   -- Input --
   ------------

   procedure Input
     (Nid         : Netif_Id;
      Buf         : Buffers.Buffer_Id)
   is
   begin
      NIFs (Nid).Input_CB (Nid, Buf);
   end Input;

   ------------
   -- Output --
   ------------

   procedure Output
     (Nid         : Netif_Id;
      Buf         : Buffers.Buffer_Id;
      Dst_Address : IPaddrs.IPaddr)
   is
   begin
      NIFs (Nid).Output_CB (Nid, Buf, Dst_Address);
   end Output;




end AIP.NIF;
