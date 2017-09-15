------------------------------------------------------------------------------
--                            IPSTACK COMPONENTS                            --
--             Copyright (C) 2010, Free Software Foundation, Inc.           --
------------------------------------------------------------------------------

--  IP stack OS adaptation layer, Single task version

--  This unit provides the required facilities to integrate the IP stack
--  within a single task environment.

--  with System;
with AIP.Time_Types;
with AIP.Buffers;
with Net.Buffers;
with AIP.Timers;

package AIP.OSAL.Single is

   procedure Process_Arp (Buf : in AIP.Buffers.Buffer_Id);

   procedure Process_Input (Buf : in AIP.Buffers.Buffer_Id);

   function Process_Interface_Events (Buf : in out Net.Buffers.Buffer_Type) return AIP.Buffers.Buffer_Id;

   procedure Init_Timers renames Timers.Initialize;

   procedure Process_Timers (Now : Time_Types.Time) renames Timers.Timer_Fired_Cb;
   --  Process all timers that have fired since the last check

end AIP.OSAL.Single;
