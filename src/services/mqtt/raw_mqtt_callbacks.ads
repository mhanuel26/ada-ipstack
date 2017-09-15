------------------------------------------------------------------------------
--                            IPSTACK COMPONENTS                            --
--             Copyright (C) 2010, Free Software Foundation, Inc.           --
------------------------------------------------------------------------------

with Ada.Unchecked_Conversion;
with AIP.PCBs;
with AIP.Callbacks;
with Ada.Streams;        use Ada.Streams;

package RAW_MQTT_Callbacks is

   type MQTT_Hook is
     access procedure (Pcb : AIP.PCBs.PCB_Id;
                       DATA : Stream_Element_Array;
                       Err : out AIP.Err_T);

   function To_CBID is new
     Ada.Unchecked_Conversion (MQTT_Hook, AIP.Callbacks.CBK_Id);

   function To_Hook is new
     Ada.Unchecked_Conversion (AIP.Callbacks.CBK_Id, MQTT_Hook);

end RAW_MQTT_Callbacks;
