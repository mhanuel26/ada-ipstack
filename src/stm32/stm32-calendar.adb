-----------------------------------------------------------------------
--  STM32.Calendar sort of Ada.Calendar replacement for STM32
--  Copyright (C) 2017 Manuel Iglesias
--  Written by Stephane Carrez (mhanuel.26@gmail.com)
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
-----------------------------------------------------------------------

package body STM32.Calendar is

   function Year (Date : Time) return Year_Number is
      Year_Var : Year_Number;
   begin
      pragma Unreferenced (Date);
      Year_Var := 2017;
      return Year_Var;
   end Year;

   function Month (Date : Time) return Month_Number is
      Month_Var : Month_Number;
   begin
      pragma Unreferenced (Date);
      Month_Var := 9;
      return Month_Var;
   end Month;

   function Day (Date : Time) return Day_Number is
      Day_Var : Day_Number;
   begin
      pragma Unreferenced (Date);
      Day_Var := 3;
      return Day_Var;
   end Day;

   function Seconds (Date : Time) return Day_Duration is
      Duration_Var : Day_Duration;
   begin
      pragma Unreferenced (Date);
      Duration_Var := 20000.0;
      return Duration_Var;
   end Seconds;

   procedure Split
     (Date    : Time;
      Year    : out Year_Number;
      Month   : out Month_Number;
      Day     : out Day_Number;
      Seconds : out Day_Duration) is
   begin
      pragma Unreferenced (Date);
      Year := 2017;
      Month := 9;
      Day := 3;
      Seconds := 10000.0;
   end Split;

   function Time_Of
     (Year    : Year_Number;
      Month   : Month_Number;
      Day     : Day_Number;
      Seconds : Day_Duration := 0.0)
      return    Time
   is
      Time_var : constant Time := Clock;
   begin
      pragma Unreferenced (Year, Month, Day, Seconds);
      return Time_var;
   end Time_Of;

end STM32.Calendar;
