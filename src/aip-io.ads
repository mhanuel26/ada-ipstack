------------------------------------------------------------------------------
--                            IPSTACK COMPONENTS                            --
--          Copyright (C) 2012-2017, Free Software Foundation, Inc.         --
------------------------------------------------------------------------------

--  Low-level console IO for testing/debugging purposes

package AIP.IO is

   procedure Put (S : String);
   procedure Put_Line (S : String);
   --  Output a line of text to the console (without/with appended newline)

end AIP.IO;
