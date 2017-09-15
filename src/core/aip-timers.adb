------------------------------------------------------------------------------
--                            IPSTACK COMPONENTS                            --
--  Adapted by Manuel Iglesias (Mhanuel.Usb@gmail.com)
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

package body AIP.Timers with
  Refined_State => (TimerState => (Timer_Available)),
  SPARK_Mode => Off
is

   Timer_Available : Timer_Reserved_Array;

--     type Timer_Array is array (Timer_Idx) of Timer;
--     My_Timers : Timer_Array;


   function Deadline (T : Timer) return Time_Types.Time;
   --  Return the next deadline for the given timer

   --------------
   -- Deadline --
   --------------

   function Deadline (T : Timer) return Time_Types.Time is
   begin
      if T.Interval = 0 then
         return Time_Types.Time'Last;
      else
         return T.Last_Event + T.Interval;
      end if;
   end Deadline;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize with
     Refined_Global => (Output => (Timer_Available))
   is
   begin
      for J in Timer_Reserved_Array'Range loop
         Timer_Available (J).Id := No_Timer;
         Timer_Available (J).Cb := null;
      end loop;
   end Initialize;

   -----------------
   -- Timer Alloc --
   -----------------

   procedure TID_Alloc (TID : in Timer_Id;
                        Tmr_Cb : in Timer_Cb) with
     Refined_Global => (In_Out => (Timer_Available))
   is
      TIDx     : constant Valid_Reserve_Range := Integer (Timer_Id'Pos (TID) + 1);
   begin
      Timer_Available (TIDx).Id := TIDx;
      Timer_Available (TIDx).Tmr.Interval := 0;
      Timer_Available (TIDx).Cb := Tmr_Cb;
   end TID_Alloc;

   procedure Timer_Alloc (Timer_Idx : out Valid_Tmr_Id;
                          Tmr_Cb : in Timer_Cb) with
     Refined_Global => (In_Out => (Timer_Available))
   is
      Start_Idx : constant Valid_Reserve_Range := Integer ((Timer_Id'Pos (Timer_Id'Last) + 1));
      End_Idx   : constant Valid_Reserve_Range := Timer_Available'Last;
   begin
      Timer_Idx := No_Timer;
      for J in Integer range Start_Idx .. End_Idx loop
         if Timer_Available (J).Id = No_Timer then
            Timer_Available (J).Id := J;
            Timer_Available (J).Tmr.Interval := 0;
            Timer_Available (J).Cb := Tmr_Cb;
            Timer_Idx := J;
            exit;
         end if;
      end loop;
   end Timer_Alloc;

   -------------------
   -- Timer_Stop    --
   -------------------

   procedure Timer_Stop (Timer_Idx : Valid_Reserve_Range) with
     Refined_Global => (In_Out => (Timer_Available))
   is
   begin
      Timer_Available (Timer_Idx).Tmr.Interval := 0;
      Timer_Available (Timer_Idx).Id := No_Timer;
      Timer_Available (Timer_Idx).Cb := null;
   end Timer_Stop;

   -------------------
   -- Next_Deadline --
   -------------------

   function Next_Deadline return Time_Types.Time is
      Result : Time_Types.Time := Time_Types.Time'Last;
      My_Deadline : Time_Types.Time;
   begin
      for J in Timer_Available'Range loop
         My_Deadline := Deadline (Timer_Available (J).Tmr);
         if My_Deadline < Result then
            Result := My_Deadline;
         end if;
      end loop;
      return Result;
   end Next_Deadline;

   ------------------
   -- Set_Interval --
   ------------------

   procedure Set_Interval
     (TID      : Timer_Id;
      Interval : Time_Types.Interval) with
     Refined_Global => (In_Out => (Timer_Available))
   is
      TIDx     : constant Valid_Reserve_Range := Integer (Timer_Id'Pos (TID) + 1);
   begin
      Set_Interval (TIDx, Interval);
   end Set_Interval;

   procedure Set_Interval
     (TIDx     : Timer_Idx;
      Interval : Time_Types.Interval) with
     Refined_Global => (In_Out => (Timer_Available))
   is
   begin
      Timer_Available (TIDx).Tmr.Last_Event := AIP.Time_Types.Now;
      Timer_Available (TIDx).Tmr.Interval := Interval;
   end Set_Interval;

   -----------------
   -- Timer_Fired --
   -----------------

--     function Timer_Fired
--       (Now : Time_Types.Time;
--        TID : Timer_Id) return Boolean
--     is
--        TIDx     : constant Valid_Reserve_Range := Integer (Timer_Id'Pos (TID) + 1);
--        My_Timer : Timer renames My_Timers (TIDx);
--     begin
--        if My_Timer.Interval > 0
--          and then My_Timer.Last_Event + My_Timer.Interval <= Now
--        then
--           My_Timer.Last_Event := Now;
--           return True;
--        else
--           return False;
--        end if;
--
--     end Timer_Fired;

   -----------------
   -- Timer_Fired --
   -----------------

   procedure Timer_Fired_Cb
     (Now : Time_Types.Time) with
     Refined_Global => (In_Out => (Timer_Available))
   is
   begin
      for J in Timer_Available'Range loop
         if Timer_Available (J).Tmr.Interval > 0
           and then Timer_Available (J).Tmr.Last_Event + Timer_Available (J).Tmr.Interval <= Now
         then
            Timer_Available (J).Tmr.Last_Event := Now;
            Timer_Available (J).Cb (J);
         end if;
      end loop;
   end Timer_Fired_Cb;

end AIP.Timers;
