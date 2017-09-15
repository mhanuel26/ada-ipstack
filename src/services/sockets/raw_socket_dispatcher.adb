------------------------------------------------------------------------------
--                            IPSTACK COMPONENTS                            --
--             Copyright (C) 2010, Free Software Foundation, Inc.           --
------------------------------------------------------------------------------

with RAW_SOCKET_Callbacks;

package body RAW_SOCKET_Dispatcher is

   use type AIP.Callbacks.CBK_Id;

   procedure SOCKET_Event
     (Client : in out Connection_Ptr;
      PCB    : AIP.PCBs.PCB_Id;
      DATA   : Stream_Element_Array;
      Cbid   : AIP.Callbacks.CBK_Id;
      Err    : out AIP.Err_T)
   is
   begin
      if Cbid /= AIP.Callbacks.NOCB then
         RAW_SOCKET_Callbacks.To_Hook (Cbid).all (Client, PCB, DATA, Err);
      end if;
   end SOCKET_Event;

end RAW_SOCKET_Dispatcher;
