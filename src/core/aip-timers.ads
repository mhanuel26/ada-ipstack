------------------------------------------------------------------------------
--                            IPSTACK COMPONENTS                            --
--          Copyright (C) 2010-2014, Free Software Foundation, Inc.         --
------------------------------------------------------------------------------

with AIP.Time_Types;

package AIP.Timers with
  Abstract_State => (TimerState)
is
   use type Time_Types.Time;

   type Timer is record
      Interval   : Time_Types.Interval := 0;
      Last_Event : Time_Types.Time     := Time_Types.Time'First;
   end record;

   type Timer_Cb is access procedure (Id : Integer);

   type Timer_Id is (TIMER_EVT_ETHARPTMR,
                     TIMER_EVT_TCPFASTTMR,
                     TIMER_EVT_TCPSLOWTMR,
                     TIMER_EVT_IPREASSTMR,
                     TIMER_EVT_MQTTTICKTMR);

   subtype Timer_Idx is Integer range Integer (Timer_Id'Pos (Timer_Id'First)) ..
          Integer (Timer_Id'Pos (Timer_Id'Last)) + 10;

   --  subtype Valid_Reserve_Range is Integer range 1 .. 10 - Integer (Timer_Id'Pos (Timer_Id'Last));
   subtype Valid_Reserve_Range is Integer range 1 .. Integer (Timer_Id'Pos (Timer_Id'Last)) + 10;
   subtype Valid_Tmr_Id is Integer range 0 .. Valid_Reserve_Range'Last;
   type Timer_Reserved_Rec is record
      Id  : Valid_Tmr_Id := 0;
      Tmr : Timer        := (Interval => 0, Last_Event => 0);
      Cb  : Timer_Cb     := null;
   end record;

   No_Timer : constant Valid_Tmr_Id := 0;

   type Timer_Reserved_Array is array (Valid_Reserve_Range) of Timer_Reserved_Rec;

   procedure Initialize
     with Global => (Output => (TimerState));

   procedure TID_Alloc (TID : in Timer_Id;
                        Tmr_Cb : in Timer_Cb)
     with Global => (In_Out => (TimerState));

   procedure Timer_Alloc (Timer_Idx : out Valid_Tmr_Id;
                          Tmr_Cb : in Timer_Cb)
     with Global => (In_Out => (TimerState));

   procedure Timer_Stop (Timer_Idx : Valid_Reserve_Range)
     with Global => (In_Out => (TimerState));

   procedure Set_Interval (TID : Timer_Id; Interval : Time_Types.Interval) with
     Global  => (In_Out => (TimerState));
--       Depends => (null => (TID, Interval));

   procedure Set_Interval (TIDx : Timer_Idx; Interval : Time_Types.Interval) with
     Global  => (In_Out => (TimerState));
--       Depends => (null => (TIDx, Interval));

--     function Timer_Fired
--       (Now : Time_Types.Time;
--        TID : Timer_Id) return Boolean;

   procedure Timer_Fired_Cb
     (Now : Time_Types.Time)
     with Global => (In_Out => (TimerState));

   function Next_Deadline return Time_Types.Time;

end AIP.Timers;
