--                                                                    --
--  package Test_HTTP_Servers       Copyright (c)  Dmitry A. Kazakov  --
--  Test server                                    Luebeck            --
--  Interface                                      Winter, 2012       --
--                                                                    --
--                                Copyright (c) 2017 Manuel Iglesias  --
--   Adapted by Manuel Iglesias for LwIp Socket based implementation  --
--

with Ada.Real_Time;
with Ada.Synchronous_Task_Control;
with AIP.IO;
--  with AIP.Time_Types;

package body Test_HTTP_Servers is

   use type Ada.Real_Time.Time;
   use type Ada.Real_Time.Time_Span;

   HTTP_Ready  : Ada.Synchronous_Task_Control.Suspension_Object;

   HTTP_Polling   : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (20);

   overriding
   procedure Body_Error
     (Client : in out Test_HTTP_Client;
        Stream : in out Root_Stream_Type'Class;
        Error  : Exception_Occurrence
       ) is
   begin
      pragma Unreferenced (Client, Stream, Error);
      null;
--        Save_Occurrence (Client, Error);
--        Client.Content.Failed := True;
   end Body_Error;

   overriding
   procedure Body_Received
     (Client : in out Test_HTTP_Client;
        Stream : in out Root_Stream_Type'Class
       )  is
   begin
      pragma Unreferenced (Client, Stream);
      null;
--        Close (Client.Content.File);
   exception
      when Error : others =>
         pragma Unreferenced (Error);
         null;
--           Save_Occurrence (Client, Error);
--           Client.Content.Failed := True;
   end Body_Received;

   procedure Body_Sent
     (Client : in out Test_HTTP_Client;
        Stream : access Root_Stream_Type'Class;
        Get    : Boolean
       )  is
   begin
      pragma Unreferenced (Client, Stream, Get);
      null;
--        if Is_Open (Client.Content.File) then
--           Close (Client.Content.File);
--        end if;
   end Body_Sent;

   overriding
   function Create
     (Factory  : access Test_HTTP_Factory;
      Pcb      : AIP.PCBs.PCB_Id;
      Data     : Stream_Element_Array;
      Err      : out AIP.Err_T
     )  return Connection_Ptr is
      Result : Connection_Ptr;
   begin
      pragma Unreferenced (Pcb, Data);
      --        if Get_Clients_Count (Listener.all) < Factory.Max_Connections then
      Result :=
        new Test_HTTP_Client
          (Request_Length   => Factory.Request_Length,
           Input_Size     => Factory.Input_Size,
           Output_Size    => Factory.Output_Size
          );
      --     Receive_Body_Tracing   (Test_Client (Result.all), True);
      --     Receive_Header_Tracing (Test_Client (Result.all), True);
      Err := AIP.NOERR;
      return Result;
   end Create;

   overriding
   procedure Do_Body (Client : in out Test_HTTP_Client) is
      Status : Status_Line renames Get_Status_Line (Client);
   begin
      pragma Unreferenced (Client, Status);
      null;
      --  if Status.Kind = File then
      --     if Status.File = "test_forms.htm" then
      --        Receive_Body (Client, "text,submit,a,b");
      --     elsif Status.File = "test_forms_2.htm" then
      --        Receive_Body (Client, Client.Content.Keys'Access);
      --     elsif Status.File = "test_forms_4.htm" then
      --        Receive_Body (Client);
      --     else
      --        declare
      --           Disposition : String renames
      --                         Get_Multipart_Header
      --                         (  Client,
      --                            Content_Disposition_Header
      --                         );
      --           Pointer : aliased Integer := Disposition'First;
      --        begin
      --           if not Client.Content.Failed then
      --              while Pointer < Disposition'Last loop
      --                 if Is_Prefix
      --                    (  "filename=",
      --                       Disposition,
      --                       Pointer
      --                    )
      --                 then
      --                    Pointer := Pointer + 9;
      --                    declare
      --                       Name : constant String :=
      --                                       Get_Quoted
      --                                       (  Disposition,
      --                                          Pointer'Access
      --                                       );
      --                    begin
      --                       Create
      --                       (  Client.Content.File,
      --                          Out_File,
      --                          Name,
      --                          "Text_Translation=No"
      --                       );
      --                       Receive_Body
      --                       (  Client,
      --                          Stream (Client.Content.File)
      --                       );
      --                       return;
      --                    exception
      --                       when Error : others =>
      --                          Save_Occurrence (Client, Error);
      --                          Client.Content.Failed := True;
      --                    end;
      --                 else
      --                    Pointer := Pointer + 1;
      --                 end if;
      --              end loop;
      --           end if;
      --        exception
      --           when Error : others =>
      --              Save_Occurrence (Client, Error);
      --              Client.Content.Failed := True;
      --        end;
      --     end if;
      --  end if;
   end Do_Body;

   overriding
   procedure Do_Get (Client : in out Test_HTTP_Client)
   is
      Status : Status_Line renames Get_Status_Line (Client);
   begin
      case Status.Kind is
         when None =>
            null;
         when File =>
            if Status.File = "hello.htm" then
               Send_Status_Line (Client, 200, "OK");     -- Response status line
               Send_Date   (Client);                     -- Date header line
               Send_Server (Client);                     -- Server name
               Send_Connection (Client, False);
               Send_Content_Type (Client, "text/html");  -- Content type
               Accumulate_Body (Client, "<html><body>"); -- Begin content construction
               Accumulate_Body (Client, "<p>Hello world!</p>");
               Accumulate_Body (Client, "</body></html>");
               Send_Body (Client);
--                 Send_Body_Now (Client);                  -- Evaluate total length, send length
            end if;
         when URI =>
            null;
      end case;
   end Do_Get;

   overriding
   procedure Initialize (Client : in out Test_HTTP_Client) is
      use CGI_Keys;
   begin
      Initialize (HTTP_Client (Client));
--        Add (Client.Content.Keys, "text",   null);
--        Add (Client.Content.Keys, "submit", null);
--        Add (Client.Content.Keys, "a",      null);
--        Add (Client.Content.Keys, "b",      null);
   end Initialize;

   pragma Warnings (Off, "variable *");
   pragma Warnings (Off, "possibly *");
   procedure Test_Web (Port : in Natural)
   is
      Err     : AIP.Err_T;
      Factory : aliased Test_HTTP_Factory
        (Request_Length  => 200,
           Input_Size      => 1024,
           Output_Size     => 1024,
           Max_Connections => 100
        );
      Server : Connections_Server (Factory'Access, Port_Type (Port));
   begin
      --  Just to test  with
      delay 60.0;
   end Test_Web;
   pragma Warnings (On, "variable *");
   pragma Warnings (On, "possibly *");
   --  ------------------------------
   --  Start the HTTP Server Loop.
   --  ------------------------------
   procedure Start is
   begin
      Ada.Synchronous_Task_Control.Set_True (HTTP_Ready);
   end Start;

   task body Worker is

      timer_deadline : Ada.Real_Time.Time;

   begin
      --  Wait until started
      Ada.Synchronous_Task_Control.Suspend_Until_True (HTTP_Ready);
      AIP.IO.Put_Line ("HTTP Server Task Starting");
      declare
         Factory : aliased Test_HTTP_Factory
           (Request_Length  => 200,
            Input_Size      => 1024,
            Output_Size     => 1024,
            Max_Connections => 100
           );
         Server : Connections_Server (Factory'Access, Port_Type (80));
      begin
         timer_deadline := Ada.Real_Time.Clock;
         loop
            Server.Poll_Connections;
            delay until timer_deadline;
            timer_deadline := timer_deadline + HTTP_Polling;
         end loop;
      end;

   end Worker;


end Test_HTTP_Servers;
