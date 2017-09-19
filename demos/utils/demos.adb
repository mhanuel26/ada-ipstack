-----------------------------------------------------------------------
--  demos -- Utility package for the demos
--  Copyright (C) 2016, 2017 Stephane Carrez
--  Written by Stephane Carrez (Stephane.Carrez@gmail.com)
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
with Bitmapped_Drawing;
with Bitmap_Color_Conversion;
--  with STM32.SDRAM;
with STM32.RNG.Interrupts;
with Net.Utils;
with Receiver;
with Os_Service;
with AIP.OSAL;
--  with AIP.IO;
with AIP.IP;
with RAW_TCP_Echo;
with RAW_TCP_Dispatcher;
with RAW_UDP_Dispatcher;
with MQTT;


--  This guys here are from other commit of Ada_Drivers_Library
--  that is not on master
--  with File_IO;                    use File_IO;
--  with Filesystem.FAT;             use Filesystem.FAT;

with HAL;                        use HAL;
with HAL.SDMMC;                  use HAL.SDMMC;
with STM32.Board;                use STM32.Board;
with Dns_List;
with DNS;



pragma Warnings (Off, RAW_TCP_Dispatcher);
pragma Warnings (Off, RAW_UDP_Dispatcher);
pragma Warnings (Off, RAW_TCP_Echo);
pragma Warnings (Off, MQTT);

package body Demos is

   function Scale (Point : in HAL.Bitmap.Point) return HAL.Bitmap.Point;

   function Scale (Point : in HAL.Bitmap.Point) return HAL.Bitmap.Point is
      pragma Warnings (Off);
   begin
      if STM32.Board.LCD_Natural_Width > 480 then
         return (Point.X * 800 / 480, Point.Y * 480 / 272);
      else
         return Point;
      end if;
   end Scale;

   --  ------------------------------
   --  Write a message on the display.
   --  ------------------------------
   procedure Put (X   : in Natural;
                  Y   : in Natural;
                  Msg : in String) is
   begin
      Bitmapped_Drawing.Draw_String (Buffer     => STM32.Board.Display.Hidden_Buffer (1).all,
                                     Start      => Scale ((X, Y)),
                                     Msg        => Msg,
                                     Font       => Current_Font,
                                     Foreground => Foreground,
                                     Background => Background);
   end Put;

   --  ------------------------------
   --  Write the 64-bit integer value on the display.
   --  ------------------------------

   procedure Put (X     : in Natural;
                  Y     : in Natural;
                  Value : in Net.Uint64) is
      Buffer : constant HAL.Bitmap.Any_Bitmap_Buffer := STM32.Board.Display.Hidden_Buffer (1);
      FG     : constant HAL.UInt32 := Bitmap_Color_Conversion.Bitmap_Color_To_Word (Buffer.Color_Mode,
                                                                                   Foreground);
      BG     : constant HAL.UInt32 := Bitmap_Color_Conversion.Bitmap_Color_To_Word (Buffer.Color_Mode,
                                                                                   Background);
      V      : constant String := Net.Uint64'Image (Value);
      Pos    : HAL.Bitmap.Point := (X + 100, Y);
      D      : Natural := 1;
   begin
      for I in reverse V'Range loop
         Bitmapped_Drawing.Draw_Char (Buffer     => Buffer.all,
                                      Start      => Scale (Pos),
                                      Char       => V (I),
                                      Font       => Current_Font,
                                      Foreground => FG,
                                      Background => BG);
         Pos.X := Pos.X - 8;
         D := D + 1;
         if D = 4 then
            D := 1;
            Pos.X := Pos.X - 4;
         end if;
      end loop;
   end Put;

   --  ------------------------------
   --  Refresh the ifnet statistics on the display.
   --  ------------------------------
   procedure Refresh_Ifnet_Stats is
      use type Receiver.Us_Time;
--        Min_Time : constant Receiver.Us_Time := Receiver.Min_Receive_Time;
--        Max_Time : constant Receiver.Us_Time := Receiver.Max_Receive_Time;
--        Avg_Time : constant Receiver.Us_Time := Receiver.Avg_Receive_Time;
      NoBufCnt           : Net.Uint64 := Receiver.NoBufCnt;
      ErrCnt             : Net.Uint64 := Receiver.ErrCnt;
      ErrOtherType       : Net.Uint64 := Receiver.ErrOtherType;
      RcvCnt             : Net.Uint64 := Receiver.RcvCnt;
   begin
      Foreground := HAL.Bitmap.Blue;
      Put (80, 30, Net.Utils.To_String (AIP.OSAL.Ifnet.Ip));
      Put (80, 40, Net.Utils.To_String (AIP.OSAL.Ifnet.Gateway));
      Put (80, 50, Net.Utils.To_String (AIP.OSAL.Ifnet.Dns));
      Foreground := HAL.Bitmap.White;
      Put (250, 30, Net.Uint64 (AIP.OSAL.Ifnet.Rx_Stats.Packets));
      Put (350, 30, AIP.OSAL.Ifnet.Rx_Stats.Bytes);
      Put (250, 40, Net.Uint64 (AIP.OSAL.Ifnet.Tx_Stats.Packets));
      Put (350, 40, AIP.OSAL.Ifnet.Tx_Stats.Bytes);
      Put (250, 60, Net.Uint64 (AIP.IP.Icmp_Count));
      Put (350, 60, AIP.IP.Icmp_Tbytes);
      Put (250, 70, NoBufCnt);
      Put (250, 80, ErrCnt);
      Put (250, 90, ErrOtherType);
      Put (250, 100, RcvCnt);

--        if Min_Time < 1_000_000 and Min_Time > 0 then
--           Put (250, 50, Net.Uint64 (Min_Time));
--        end if;
--        if Avg_Time < 1_000_000 and Avg_Time > 0 then
--           Put (300, 50, Net.Uint64 (Avg_Time));
--        end if;
--        if Max_Time < 1_000_000 and Max_Time > 0 then
--           Put (350, 50, Net.Uint64 (Max_Time));
--        end if;
   end Refresh_Ifnet_Stats;

   --  ------------------------------
   --  Initialize the board and the interface.
   --  ------------------------------
   procedure Initialize (Title  : in String) is
      SD_Card_Info  : Card_Information;
      Units         : constant array (Natural range <>) of Character :=
                     (' ', 'k', 'M', 'G', 'T');
      Capacity      : UInt64;
      Error_State   : Boolean := False;

--        Status        : Status_Code;

      Y             : Integer := 90;

--        procedure Display_Current_Dir (Path : String);

      -------------------------
      -- Display_Current_Dir --
      -------------------------

--        procedure Display_Current_Dir (Path : String)
--        is
--           Dir    : Directory_Descriptor;
--           E      : Directory_Entry := Invalid_Dir_Entry;
--           Status : Status_Code;
--        begin
--           if Error_State then
--              return;
--           end if;
--
--           Status := Open (Dir, Path);
--
--           if Status /= OK then
--              AIP.IO.Put_Line ("!!! Error reading the directory " & Path);
--              Error_State := True;
--              Y := Y + 10;
--              return;
--           end if;
--
--           loop
--              E := Read (Dir);
--
--              exit when E = Invalid_Dir_Entry;
--
--              if not E.Hidden
--                and then E.Name /= "."
--                and then E.Name /= ".."
--              then
--                 Put (5, Y, Path & E.Name);
--                 Y := Y + 10;
--
--                 if E.Subdirectory then
--                    Display_Current_Dir (Path & E.Name & "/");
--                 end if;
--              end if;
--           end loop;
--
--           Close (Dir);
--        end Display_Current_Dir;

   begin
      STM32.RNG.Interrupts.Initialize_RNG;
      STM32.Board.Display.Initialize;
      STM32.Board.Display.Initialize_Layer (1, HAL.Bitmap.ARGB_1555);

      --  Initialize Sd Card

      STM32.Board.SDCard_Device.Initialize;

--        if STM32.Board.SDCard_Device.Card_Present then
--           AIP.IO.Put_Line ("SD card is present");
--
--           SD_Card_Info := STM32.Board.SDCard_Device.Get_Card_Information;
--
--           --  Dump general info about the SD-card
--           Capacity := SD_Card_Info.Card_Capacity;
--
--           for Unit of Units loop
--              if Capacity < 1000 or else Unit = 'T' then
--                 Put (5, 70, "SDcard size:" & Capacity'Img & " " & Unit & "B");
--                 exit;
--              end if;
--
--              if Capacity mod 1000 >= 500 then
--                 Capacity := Capacity / 1000 + 1;
--              else
--                 Capacity := Capacity / 1000;
--              end if;
--           end loop;

--           --  Test read speed of the card (ideal case: contiguous blocks)
--           declare
--              Block : UInt64 := 0;
--              Start : constant Time := Clock;
--              Fail  : Boolean := False;
--           begin
--
--              for J in 1 .. 100 loop
--                 if not STM32.Board.SDCard_Device.Read
--                   (Block_Number => Block,
--                    Data         => Test_Block)
--                 then
--                    Fail := True;
--                    exit;
--                 end if;
--
--                 Block := Block + Test_Block'Length / 512;
--              end loop;
--
--              declare
--                 Elapsed    : constant Time_Span := Clock - Start;
--                 --  Time needed to read data
--
--                 Norm       : constant Time_Span :=
--                                (Elapsed * 10000) / Test_Block'Length;
--                 --  Extrapolate to 1 MB read
--
--                 Rate_MB_ds : constant Integer := Seconds (10) / Norm;
--                 --  Bandwidth in MByte / 1/10s second
--                 Img        : String := Rate_MB_ds'Img;
--
--              begin
--                 if not Fail then
--                    Img (Img'First .. Img'Last - 2) := Img (Img'First + 1 .. Img'Last - 1);
--                    Img (Img'Last - 1) := '.';
--                    Put (5, Y, "Read (in MB/s): " & Img);
--                 else
--                    Put (5, Y, "*** test failure ***");
--                 end if;
--
--              end;
--
--              Display.Update_Layer (1, True);
--              Y := Y + 10;
--           end;

         --  Just having problem to make this work see github issue
         --  https://github.com/AdaCore/Ada_Drivers_Library/issues/220

--           Status := Mount_Drive ("sdcard", STM32.Board.SDCard_Device'Access);
--
--           if Status = No_Filesystem then
--              Error_State := True;
--              AIP.IO.Put_Line ("No valid partition found");
--  --              Put (5, 80, "No valid partition found");
--           elsif Status /= OK then
--              Error_State := True;
--  --              Put (5, 80, "Error when mounting the sdcard:" & Status'Img);
--              AIP.IO.Put_Line ("Error when mounting the sdcard:" & Status'Img);
--           else
--              Display_Current_Dir ("/");
--              Status := Unmount ("sdcard");
--           end if;
--        end if;

      Os_Service.Start;

      --  Initialize IP stack

      AIP.OSAL.Initialize;

      --  Initialize application services

--        RAW_TCP_Echo.Init;

      --  MQTT Service
      MQTT.Init;  --  This only init the Pool, it's not harms to leave it here enable

      DNS.Init (Dns_List.Queries'Access);

      Receiver.Start;

      for I in 1 .. 2 loop
         Current_Font := BMP_Fonts.Font16x24;
         Put (0, 0, Title);
         Current_Font := Default_Font;
         Put (5, 30, "IP");
         Put (4, 40, "Gateway");
         Put (4, 50, "DNS");
         Put (250, 30, "Rx");
         Put (250, 40, "Tx");
         Put (250, 50, "Rec time");
         Put (250, 60, "ICMP Rx");
         Put (250, 70, "Rec_NOBUF");
         Put (250, 80, "ErrCnt");
         Put (250, 90, "ErrOtherType");
         Put (250, 100, "Recv_Cnt");
         Put (302, 14, "Packets");
         Put (418, 14, "Bytes");
--           Put (0, 70, "Host");
--           Put (326, 70, "Send");
--           Put (402, 70, "Receive");
         Header;
         STM32.Board.Display.Hidden_Buffer (1).Set_Source (HAL.Bitmap.Blue);
         STM32.Board.Display.Hidden_Buffer (1).Draw_Horizontal_Line
           (Pt    => (X => 0, Y => 84),
            Width => STM32.Board.LCD_Natural_Width);
         STM32.Board.Display.Update_Layer (1);
      end loop;

   end Initialize;

end Demos;
