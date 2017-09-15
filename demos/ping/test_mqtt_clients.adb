--                                                                    --
--  package Test_MQTT_Clients       Copyright (c)  Dmitry A. Kazakov  --
--  Implementation                                 Luebeck            --
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

with AIP;                    use AIP;
with AIP.IO;
with Strings_Edit.Integers;  use Strings_Edit.Integers;

package body Test_MQTT_Clients is

   procedure Test_Receive
     (Pcb  : AIP.PCBs.PCB_Id;
      DATA : Stream_Element_Array;
      Err  : out AIP.Err_T)
   is
   begin
      for Hitem in Test_Client_Array'Range loop
         if Test_Client_Array (Hitem) /= Null_Handle then
            declare
               Client   : Test_Client renames Test_Client (Ptr (Test_Client_Array (Hitem)).all);
               Pointer  : Stream_Element_Offset := DATA'First;
            begin
               if Client.Does_Mqtt_Pier_Match (Pcb) then
                  Client.Received (DATA, Pointer);
               end if;
            end;
         end if;
      end loop;
      Err := AIP.NOERR;
   end Test_Receive;


   procedure Test_Connect
     (Pcb  : AIP.PCBs.PCB_Id;
      DATA : Stream_Element_Array;
      Err  : out AIP.Err_T)
   is
   begin
      pragma Unreferenced (Pcb, DATA);
      Err := AIP.NOERR;
   end Test_Connect;


   overriding
   procedure On_Connect_Accepted
             (Pier            : in out Test_Client;
              Session_Present : Boolean
             )  is
   begin
      pragma Unreferenced (Pier, Session_Present);
--        AIP.IO.Put_Line ("Connect accepted");
   end On_Connect_Accepted;

   overriding
   procedure On_Connect_Rejected
             (Pier     : in out Test_Client;
              Response : Connect_Response
             ) is
   begin
      pragma Unreferenced (Pier);
      AIP.IO.Put_Line ("Connect rejected " & Image (Response));
   end On_Connect_Rejected;

   overriding
   procedure On_Ping_Response (Pier : in out Test_Client) is
   begin
      pragma Unreferenced (Pier);
--        AIP.IO.Put_Line ("Ping response");
   end On_Ping_Response;

   overriding
   procedure On_Publish
             (Pier      : in out Test_Client;
              Topic     : String;
              Message   : Stream_Element_Array;
              Packet    : Packet_Identification;
              Duplicate : Boolean;
              Retain    : Boolean
             ) is
   begin
--        AIP.IO.Put_Line ("Message " & Topic & "=" & Image (Message));
      On_Publish
      (MQTT_Pier (Pier),
       Topic,
       Message,
       Packet,
       Duplicate,
       Retain
      );
   end On_Publish;

   overriding
   procedure On_Subscribe_Acknowledgement
             (Pier   : in out Test_Client;
              Packet : Packet_Identifier;
              Codes  : Return_Code_List
             ) is
   begin
      pragma Unreferenced (Pier);
      AIP.IO.Put ("Subscribed " & Image (Integer (Packet)) & ":");
      for Index in Codes'Range loop
         if Index /= Codes'First then
            AIP.IO.Put (", ");
         end if;
         if Codes (Index).Success then
            AIP.IO.Put (QoS_Level'Image (Codes (Index).QoS));
         else
            AIP.IO.Put ("Failed");
         end if;
      end loop;
      AIP.IO.Put_Line ("");
   end On_Subscribe_Acknowledgement;

   procedure Test_1 (Client_Ip : in AIP.IPaddrs.IPaddr)
   is
      Client_Err    : AIP.Err_T;
   begin
      Set (Test_Client_Array (0), new Test_Client (Max_Subscribe_Topics => 20));
      declare
         Client   : Test_Client renames Test_Client (Ptr (Test_Client_Array (0)).all);
         PId      : Packet_Identification (Qos => At_Most_Once);
      begin
         Client.Set_Client_Ip (Client_Ip);
         Client.Set_Client_Cbs (Test_Connect'Access, Test_Receive'Access);
         Client.Connect (Client_Err);
         if Client_Err = AIP.NOERR then
            while Client.Is_Connected = False loop
               delay 0.01;
            end loop;
            Send_Connect (Client, "TestMQTTclient");
            while Client.Is_Connected = False loop
               delay 0.01;
            end loop;
            Send_Ping (Client);
            delay 1.0;
            Send_Publish (Client,
                          "makewithAda/ipstack/test",
                          "bonjour Ada world!",
                          PId);
            delay 2.0;
            Send_Disconnect (Client);
         else
            AIP.IO.Put_Line ("STM32 Connect Error");
         end if;
      end;
   end Test_1;


end Test_MQTT_Clients;
