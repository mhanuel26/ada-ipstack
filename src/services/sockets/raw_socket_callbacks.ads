------------------------------------------------------------------------------
--                            IPSTACK COMPONENTS                            --
--             Copyright (C) 2010, Free Software Foundation, Inc.           --
------------------------------------------------------------------------------

with Ada.Unchecked_Conversion;
with AIP.PCBs;
with AIP.Callbacks;
with Ada.Streams;        use Ada.Streams;
with RAW_LwIp_Server;    use RAW_LwIp_Server;

package RAW_SOCKET_Callbacks is

   type SOCKET_Hook is
     access procedure (Client : in out Connection_Ptr;
                       Pcb    : AIP.PCBs.PCB_Id;
                       DATA   : Stream_Element_Array;
                       Err    : out AIP.Err_T);

   function To_CBID is new
     Ada.Unchecked_Conversion (SOCKET_Hook, AIP.Callbacks.CBK_Id);

   function To_Hook is new
     Ada.Unchecked_Conversion (AIP.Callbacks.CBK_Id, SOCKET_Hook);

end RAW_SOCKET_Callbacks;
