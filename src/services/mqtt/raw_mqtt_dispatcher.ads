------------------------------------------------------------------------------
--                            IPSTACK COMPONENTS                            --
--             Copyright (C) 2010, Free Software Foundation, Inc.           --
------------------------------------------------------------------------------

with AIP.Callbacks;
with AIP.PCBs;
with Ada.Streams;    use Ada.Streams;

package RAW_MQTT_Dispatcher is

   procedure MQTT_Event
     (PCB  : AIP.PCBs.PCB_Id;
      DATA : Stream_Element_Array;
      Cbid : AIP.Callbacks.CBK_Id;
      Err  : out AIP.Err_T);
   --  Process TCP event EV, aimed at PCB and for which Cbid was
   --  registered.

   --  pragma Export (Ada, TCP_Event, "AIP_tcp_event");

end RAW_MQTT_Dispatcher;
