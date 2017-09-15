------------------------------------------------------------------------------
--                            IPSTACK COMPONENTS                            --
--          Copyright (C) 2012-2017, Free Software Foundation, Inc.         --
------------------------------------------------------------------------------

with Ada.Text_IO;

package body AIP.IO with
  SPARK_Mode => Off
is

   procedure Put (S : String) renames Ada.Text_IO.Put;
   procedure Put_Line (S : String) renames Ada.Text_IO.Put_Line;

end AIP.IO;
