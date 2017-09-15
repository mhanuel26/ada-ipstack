------------------------------------------------------------------------------
--                            IPSTACK COMPONENTS                            --
--             Copyright (C) 2010, Free Software Foundation, Inc.           --
------------------------------------------------------------------------------

with RAW_MQTT_Callbacks;

package body RAW_MQTT_Dispatcher is

   use type AIP.Callbacks.CBK_Id;

   procedure MQTT_Event
     (PCB  : AIP.PCBs.PCB_Id;
      DATA : Stream_Element_Array;
      Cbid : AIP.Callbacks.CBK_Id;
      Err  : out AIP.Err_T)
   is
   begin
      if Cbid /= AIP.Callbacks.NOCB then
         RAW_MQTT_Callbacks.To_Hook (Cbid).all (PCB, DATA, Err);
      end if;
   end MQTT_Event;

end RAW_MQTT_Dispatcher;
