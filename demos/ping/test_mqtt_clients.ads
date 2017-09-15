--                                                                    --
--  package Test_MQTT_Clients       Copyright (c)  Dmitry A. Kazakov  --
--  Interface                                      Luebeck            --
--                                                 Spring, 2016       --
--                                                                    --
--                                Last revision :  18:59 21 Mar 2016  --
--                                                                    --
--  This  library  is  free software; you can redistribute it and/or  --
--  modify it under the terms of the GNU General Public  License  as  --
--  published by the Free Software Foundation; either version  2  of  --
--  the License, or (at your option) any later version. This library  --
--  is distributed in the hope that it will be useful,  but  WITHOUT  --
--  ANY   WARRANTY;   without   even   the   implied   warranty   of  --
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU  --
--  General  Public  License  for  more  details.  You  should  have  --
--  received  a  copy  of  the GNU General Public License along with  --
--  this library; if not, write to  the  Free  Software  Foundation,  --
--  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.    --
--                                                                    --
--  As a special exception, if other files instantiate generics from  --
--  this unit, or you link this unit with other files to produce  an  --
--  executable, this unit does not by  itself  cause  the  resulting  --
--  executable to be covered by the GNU General Public License. This  --
--  exception  does not however invalidate any other reasons why the  --
--  executable file might be covered by the GNU Public License.       --

with Ada.Streams;        use Ada.Streams;
with MQTT;               use MQTT;
with AIP.PCBs;
with Handles;            use Handles;
with AIP.IPaddrs;

package Test_MQTT_Clients is

   procedure Test_1 (Client_Ip : in AIP.IPaddrs.IPaddr);

   type Handle_Array is array (0 .. 3) of Handle;

   Test_Client_Array : Handle_Array := (others => Null_Handle);

   procedure Test_Receive
     (Pcb : AIP.PCBs.PCB_Id;
      DATA : Stream_Element_Array;
      Err : out AIP.Err_T);

   procedure Test_Connect
     (Pcb : AIP.PCBs.PCB_Id;
      DATA : Stream_Element_Array;
      Err : out AIP.Err_T);

   type Test_Client is new MQTT_Pier with private;
   overriding
   procedure On_Connect_Accepted
             (Pier            : in out Test_Client;
                Session_Present : Boolean
             );
   overriding
   procedure On_Connect_Rejected
             (Pier     : in out Test_Client;
                Response : Connect_Response
             );
   overriding
   procedure On_Ping_Response (Pier : in out Test_Client);
   overriding
   procedure On_Publish
             (Pier      : in out Test_Client;
                Topic     : String;
                Message   : Stream_Element_Array;
                Packet    : Packet_Identification;
                Duplicate : Boolean;
                Retain    : Boolean
             );
   overriding
   procedure On_Subscribe_Acknowledgement
             (Pier   : in out Test_Client;
                Packet : Packet_Identifier;
                Codes  : Return_Code_List
             );
private
   type Test_Client is new MQTT_Pier with null record;
   --  type Test_Client_Ptr is access Test_Client;

end Test_MQTT_Clients;
