--                                                                    --
--  package Test_HTTP_Servers       Copyright (c)  Dmitry A. Kazakov  --
--  Test server                                    Luebeck            --
--  Interface                                      Winter, 2012       --
--                                                                    --
--                                Copyright (c) 2017 Manuel Iglesias  --
--   Adapted by Manuel Iglesias for LwIp Socket based implementation  --
--                                                                    --


with Ada.Exceptions;             use Ada.Exceptions;
with Ada.Streams;                use Ada.Streams;
--  with Ada.Streams.Stream_IO;      use Ada.Streams.Stream_IO;
with RAW_LwIp_Server;            use RAW_LwIp_Server;
--  with GNAT.Sockets.Server;        use GNAT.Sockets.Server;

with AIP.PCBs;

with Connection_State_Machine.HTTP_Server;
use  Connection_State_Machine.HTTP_Server;

with System;

package Test_HTTP_Servers is

   procedure Start;

   type Test_HTTP_Factory
     (Request_Length  : Positive;
      Input_Size      : Buffer_Length;
      Output_Size     : Buffer_Length;
      Max_Connections : Positive
     )  is new Connections_Factory with private;

   type Test_HTTP_Client
     (Request_Length : Positive;
      Input_Size     : Buffer_Length;
      Output_Size    : Buffer_Length
     )  is new HTTP_Client with private;

   overriding
   function Create
     (Factory  : access Test_HTTP_Factory;
      Pcb  : AIP.PCBs.PCB_Id;
      Data : Stream_Element_Array;
      Err  : out AIP.Err_T
     )  return Connection_Ptr;

   overriding
   procedure Body_Error
             (Client : in out Test_HTTP_Client;
                Stream : in out Root_Stream_Type'Class;
                Error  : Exception_Occurrence
             );
   overriding
   procedure Body_Received
             (Client : in out Test_HTTP_Client;
                Stream : in out Root_Stream_Type'Class
             );
   overriding
   procedure Do_Body (Client : in out Test_HTTP_Client);
   overriding
   procedure Do_Get  (Client : in out Test_HTTP_Client);
   --  procedure Do_Head (Client : in out Test_Client);
   --  procedure Do_Post (Client : in out Test_Client);
   overriding
   procedure Initialize (Client : in out Test_HTTP_Client);

   procedure Test_Web (Port : in Natural);

   --  The task that waits for packets.
   task Worker with
     Storage_Size => (20 * 1024),
     Priority => System.Default_Priority;

private
   type Test_HTTP_Factory
        (Request_Length  : Positive;
           Input_Size      : Buffer_Length;
           Output_Size     : Buffer_Length;
           Max_Connections : Positive
        )  is new Connections_Factory with null record;

   procedure Body_Sent
     (Client : in out Test_HTTP_Client;
        Stream : access Root_Stream_Type'Class;
        Get    : Boolean
       );

   type Test_HTTP_Client
     (Request_Length  : Positive;
      Input_Size      : Buffer_Length;
      Output_Size     : Buffer_Length
     ) is new HTTP_Client
       (Request_Length => Request_Length,
        Input_Size     => Input_Size,
        Output_Size    => Output_Size
       )  with null record;

end Test_HTTP_Servers;
