--                                                                     --
--   package                         Copyright (c)  Dmitry A. Kazakov  --
--      GNAT.Sockets.Connection_State_Machine.      Luebeck            --
--      Variable_Length_Arrays                      Winter, 2012       --
--   Interface                                                         --
--                                 Last revision :  13:09 10 Mar 2013  --
--                                                                     --
--   This  library  is  free software; you can redistribute it and/or  --
--   modify it under the terms of the GNU General Public  License  as  --
--   published by the Free Software Foundation; either version  2  of  --
--   the License, or (at your option) any later version. This library  --
--   is distributed in the hope that it will be useful,  but  WITHOUT  --
--   ANY   WARRANTY;   without   even   the   implied   warranty   of  --
--   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU  --
--   General  Public  License  for  more  details.  You  should  have  --
--   received  a  copy  of  the GNU General Public License along with  --
--   this library; if not, write to  the  Free  Software  Foundation,  --
--   Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.    --
--                                                                     --
--   As a special exception, if other files instantiate generics from  --
--   this unit, or you link this unit with other files to produce  an  --
--   executable, this unit does not by  itself  cause  the  resulting  --
--   executable to be covered by the GNU General Public License. This  --
--   exception  does not however invalidate any other reasons why the  --
--   executable file might be covered by the GNU Public License.       --


package Connection_State_Machine.Variable_Length_Arrays is
--
--  Array_Data_Item --  Contains an array
--
--     Size - Maximum array length
--
--  The array value is Item.Value (1 .. Item.Last).  The field Last must be
--  set before calling to Feed.
--
   type Array_Data_Item (Size : Stream_Element_Count) is
      new Data_Item with
   record
      Last   : Stream_Element_Offset := 0;
      Value  : Stream_Element_Array (1 .. Size);
   end record;
--
--  Feed --  Implementation of the feed operation
--
   overriding
   procedure Feed
             (Item    : in out Array_Data_Item;
                Data    : Stream_Element_Array;
                Pointer : in out Stream_Element_Offset;
                Client  : in out State_Machine'Class;
                State   : in out Stream_Element_Offset
             );
--
--  Get --  Array from stream element array
--
--     Data    - The stream element array
--     Pointer - The first element to read
--     Value   - The result (boinds are known in advance)
--
--  The parameter Pointer is advanced beyond the value obtained
--
--  Exceptions :
--
--     End_Error    - Not enough data
--     Layout_Error - Pointer is outside bounds
--
   procedure Get
             (Data    : Stream_Element_Array;
                Pointer : in out Stream_Element_Offset;
                Value   : out Stream_Element_Array
             );
--
--  Put --  String into stream element array
--
--     Data    - The stream element array
--     Pointer - The first element to write
--     Value   - The value to encode
--
--  The parameter Pointer is advanced beyond the value output
--
--  Exceptions :
--
--     End_Error    - No room for output
--     Layout_Error - Pointer is outside bounds
--
   procedure Put
             (Data    : in out Stream_Element_Array;
                Pointer : in out Stream_Element_Offset;
                Value   : Stream_Element_Array
             );
end Connection_State_Machine.Variable_Length_Arrays;
