------------------------------------------------------------------------------
--                            IPSTACK MQTT COMPONENT
--         Copyright (C) 2017, Free Software Foundation, Inc.
--  Written by Manuel Iglesias (Mhanuel.Usb@gmail.com)
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

with AIP.TCP;
--  with AIP.Buffers;
with AIP.IPaddrs;
with Net;
--  with AIP.PCBs;
--  with AIP.IO;

pragma Warnings (Off, "* referenced");
with AIP.Timers;
with System, RAW_TCP_Callbacks;
with RAW_MQTT_Dispatcher;

with Ada.Unchecked_Conversion;
with Ada.Exceptions;       use Ada.Exceptions;
with Ada.IO_Exceptions;    use Ada.IO_Exceptions;
pragma Warnings (On, "* referenced");
use type AIP.S8_T, AIP.U8_T, AIP.U16_T, AIP.S32_T;

package body MQTT.Clients with
   Refined_State => (State => (MSP))
is

   use type System.Address;
   ---------------------------
   -- Mqtt State management --
   ---------------------------

   --  We will be using the raw callback API, passing application state
   --  information across calls for each connection.

   pragma Warnings (Off, "procedure * is not referenced");
   procedure Init_MS_Pool;

   procedure MS_Alloc (Sid : out MS_Id);

   procedure MS_Release (PCB : AIP.PCBs.PCB_Id; Ms : in out Mqtt_Conn_State);

   -----------------------
   -- Local Subprograms --
   -----------------------

   procedure Mqtt_Close
     (Pcb : AIP.PCBs.PCB_Id;
      Ms  : in out Mqtt_Conn_State)
   with
     Global => (In_Out => (State));

   procedure Mqtt_Dispatch_Recv
     (Pcb : AIP.PCBs.PCB_Id;
      Ms  : in out Mqtt_Conn_State);

   procedure MQTT_Process_Sent
     (Ev  : AIP.TCP.TCP_Event_T;
      Pcb : AIP.PCBs.PCB_Id;
      Err : out AIP.Err_T);

   procedure MQTT_Process_Abort
     (Ev  : AIP.TCP.TCP_Event_T;
      Pcb : AIP.PCBs.PCB_Id;
      Err : out AIP.Err_T)
   with
     Global => (In_Out => (State));

   procedure MQTT_Process_Poll
     (Ev  : AIP.TCP.TCP_Event_T;
      Pcb : AIP.PCBs.PCB_Id;
      Err : out AIP.Err_T);

   procedure MQTT_Process_Recv
     (Ev  : AIP.TCP.TCP_Event_T;
      Pcb : AIP.PCBs.PCB_Id;
      Err : out AIP.Err_T);

   procedure MQTT_Process_Connect
     (Ev  : AIP.TCP.TCP_Event_T;
      Pcb : AIP.PCBs.PCB_Id;
      Err : out AIP.Err_T);

   pragma Warnings (On, "procedure * is not referenced");

   ----------
   -- Init --
   ----------

   procedure Init with
     Refined_Global => (Output => (State))
   is
   begin
      --  Initialize the application state pool
      Init_MS_Pool;
   end Init;

   ------------------
   -- Init_MS_Pool --
   ------------------

   --  Initialize the Mqtt_Conn_State pool, required before any other op

   procedure Init_MS_Pool is
   begin
      null;
      for Id in Valid_MS_Id loop
         MSP (Id).Kind := MS_FREE;
      end loop;
   end Init_MS_Pool;

   --------------
   -- MS_Alloc --
   --------------

   procedure MS_Alloc (Sid : out MS_Id) is
   begin
      --  Search a free for use entry in the pool. If found, move to MS_NONE,
      --  and return Id. Return NOMS otherwise.

      Sid := NOMS;
      for Id in Valid_MS_Id loop
         if MSP (Id).Kind = MS_FREE then
            MSP (Id).Kind := MS_READY;
            Sid := Id;
            exit;
         end if;
      end loop;
   end MS_Alloc;

   ----------------
   -- MS_Release --
   ----------------

   procedure MS_Release (PCB : AIP.PCBs.PCB_Id; Ms : in out Mqtt_Conn_State) is
   begin
      AIP.TCP.TCP_Set_Udata (PCB, System.Null_Address);

      --  Mark entry as free so that it can be reused

      Ms.Kind := MS_FREE;
      Ms.Pcb := AIP.PCBs.NOPCB;
      if Ms.Tmr_Id /= Timers.No_Timer then
         --  Stop cyclic timer
         Timers.Timer_Stop (Ms.Tmr_Id);
      end if;
   end MS_Release;

   ----------------
   -- Mqtt_Close --
   ----------------

   procedure Mqtt_Close
     (Pcb : AIP.PCBs.PCB_Id;
      Ms  : in out Mqtt_Conn_State)
   is
      Err : AIP.Err_T;
   begin
      if Ms.Kind /= MS_FREE
        and then Ms.Kind /= MS_READY
      then
         MS_Release (Pcb, Ms);
         AIP.TCP.TCP_Close (Pcb, Err);
      end if;
      pragma Assert (AIP.No (Err));
   end Mqtt_Close;

   ---------------
   -- Mqtt_Send --
   ---------------

   procedure Mqtt_Send
     (Pcb : AIP.PCBs.PCB_Id;
      Ms  : in out Mqtt_Conn_State)
   is
      Buf  : AIP.Buffers.Buffer_Id;
      Err  : AIP.Err_T := AIP.NOERR;
   begin

      --  Proceed as long as there's something left to send and there's room
      --  for it in the curent output buffer. Punt if something wrong happens.

      while Err = AIP.NOERR
        and then Ms.Buf /= AIP.Buffers.NOBUF
        and then AIP.Buffers.Buffer_Len (Ms.Buf) <= AIP.TCP.TCP_Sndbuf (Pcb)
      loop
         --  Enqueue the current Buf for transmission

         Buf := Ms.Buf;
         declare
            Fin : Boolean := False;
         begin
            if Ms.Kind = MS_CLOSING then
               Fin := True;
            end if;
            AIP.TCP.TCP_Write
              (PCB  => Pcb,
               Data => AIP.Buffers.Buffer_Payload (Buf),
               Len  => AIP.M32_T (AIP.Buffers.Buffer_Len (Buf)),
               Copy => True,
               Push => True,
               Fin  => Fin,
               Err  => Err);
         end;

         --  If all went well, move to next Buf in chain

         if Err = AIP.NOERR then

            --  Grab reference to the following Buf, if any

            Ms.Buf := AIP.Buffers.Buffer_Next (Buf);
            if Ms.Buf /= AIP.Buffers.NOBUF then
               AIP.Buffers.Buffer_Ref (Ms.Buf);
            end if;

            --  Deallocate the processed buffer

            AIP.Buffers.Buffer_Blind_Free (Buf);


         elsif Err = AIP.ERR_MEM then

            --  We are low on memory, defer polling

            Ms.Buf := Buf;
            --  This is a no-op???

         else
            --  Other problem???
            null;
         end if;

      end loop;
   end Mqtt_Send;


   ------------------------
   -- Mqtt_Dispatch_Recv --
   ------------------------

   procedure Mqtt_Dispatch_Recv
     (Pcb : AIP.PCBs.PCB_Id;
      Ms  : in out Mqtt_Conn_State)
   is
      Buf         : AIP.Buffers.Buffer_Id;
      srcAdd      : System.Address;
      Plen        : AIP.U16_T;
      TPlen       : AIP.U16_T;
--        Err         : AIP.Err_T := AIP.NOERR;
      Item_Size   : Stream_Element_Offset;
      Err         : AIP.Err_T;
   begin
      if Ms.Buf = AIP.Buffers.NOBUF then
         return;
      end if;
      TPlen := AIP.Buffers.Buffer_Tlen (Ms.Buf);
      declare
         Data     : Stream_Element_Array (1 .. Stream_Element_Offset (TPlen));
         Pointer  : Stream_Element_Offset := Data'First;
      begin
         loop
            Buf := Ms.Buf;
            Plen := AIP.Buffers.Buffer_Len (Buf);
            Item_Size := Stream_Element_Offset (Plen);
            declare
               type SEA_Pointer is
                 access all Stream_Element_Array (1 .. Item_Size);
               srcPtr   : SEA_Pointer;
               function As_SEA_Pointer is
                 new Ada.Unchecked_Conversion (System.Address, SEA_Pointer);
               Data_Ptr : SEA_Pointer;
            begin
               srcAdd := AIP.Buffers.Buffer_Payload (Buf);
               srcPtr := As_SEA_Pointer (srcAdd);
               Data_Ptr := As_SEA_Pointer (Data (Pointer)'Address);
               Data_Ptr.all (1 .. Item_Size) := srcPtr.all (1 .. Item_Size);
               --  Grab reference to the following Buf, if any
               Ms.Buf := AIP.Buffers.Buffer_Next (Buf);
               if Ms.Buf /= AIP.Buffers.NOBUF then
                  AIP.Buffers.Buffer_Ref (Ms.Buf);
               end if;
               --  Deallocate the processed buffer
               AIP.Buffers.Buffer_Blind_Free (Buf);

               exit when Ms.Buf = AIP.Buffers.NOBUF;
               --  Pointer "points" to Next element to copy
               Pointer := Pointer + Item_Size + 1;
               if Pointer > Data'Last then
                  Raise_Exception
                    (Layout_Error'Identity,
                     "Invalid pointer"
                    );
               end if;
            end;
         end loop;
         --  Signal TCP layer that we can accept more data
         AIP.TCP.TCP_Recved (Pcb, TPlen);
         pragma Warnings (Off, """Err"" modified by call, *");
         RAW_MQTT_Dispatcher.MQTT_Event
           (PCB    =>    Pcb,
            DATA   =>    Data,
            Cbid   =>    Ms.App_Client_Cbs.App_Receive_Cb,
            Err    =>    Err);
         pragma Warnings (On, """Err"" modified by call, *");
      end;
   end Mqtt_Dispatch_Recv;


   -----------------------
   -- MQTT_Process_Sent --
   -----------------------

   procedure MQTT_Process_Sent
     (Ev  : AIP.TCP.TCP_Event_T;
      Pcb : AIP.PCBs.PCB_Id;
      Err : out AIP.Err_T)
   is
      pragma Unreferenced (Ev);
      Ms    :  Mqtt_Conn_State;
      for Ms'Address use AIP.TCP.TCP_Udata (Pcb);
   begin
      if Ms.Buf /= AIP.Buffers.NOBUF then
         --  Reset keep-alive send timer and server watchdog

         Ms.Cyclic_Tick := 0;
         Ms.Server_Watchdog := 0;

         --  More data to send, do it now

         Mqtt_Send (Pcb, Ms);

      elsif Ms.Kind = MS_CLOSING then
         Mqtt_Close (Pcb, Ms);
      end if;

      Err := AIP.NOERR;
   end MQTT_Process_Sent;

   ------------------------
   -- MQTT_Process_Abort --
   ------------------------

   procedure MQTT_Process_Abort
     (Ev  : AIP.TCP.TCP_Event_T;
      Pcb : AIP.PCBs.PCB_Id;
      Err : out AIP.Err_T)
   is
      pragma Unreferenced (Ev);
      Ms    :  Mqtt_Conn_State;
      for Ms'Address use AIP.TCP.TCP_Udata (Pcb);
   begin
      Mqtt_Close (Pcb, Ms);  --  Free the PCB using Close
      Err := AIP.NOERR;
   end MQTT_Process_Abort;

   -----------------------
   -- MQTT_Process_Poll --
   -----------------------

   procedure MQTT_Process_Poll
     (Ev  : AIP.TCP.TCP_Event_T;
      Pcb : AIP.PCBs.PCB_Id;
      Err : out AIP.Err_T)
   is
      pragma Unreferenced (Ev);
      Ms    :  Mqtt_Conn_State;
      for Ms'Address use AIP.TCP.TCP_Udata (Pcb);
   begin
      if Ms'Address = System.Null_Address then
         AIP.TCP.TCP_Drop (Pcb);
         Err := AIP.ERR_ABRT;

      elsif Ms.Buf /= AIP.Buffers.NOBUF then
         Mqtt_Send (Pcb, Ms);
         Err := AIP.NOERR;

      elsif Ms.Kind = MS_CLOSING then
         Mqtt_Close (Pcb, Ms);
         Err := AIP.NOERR;
      end if;
   end MQTT_Process_Poll;

   -----------------------
   -- MQTT_Process_Recv --
   -----------------------

   procedure MQTT_Process_Recv
     (Ev  : AIP.TCP.TCP_Event_T;
      Pcb : AIP.PCBs.PCB_Id;
      Err : out AIP.Err_T)
   is
      Ms    :  Mqtt_Conn_State;
      for Ms'Address use AIP.TCP.TCP_Udata (Pcb);
   begin
      if Ev.Buf = AIP.Buffers.NOBUF then

         --  Remote host closed connection. Process what is left to be
         --  sent or close on our side.

         Ms.Kind := MS_CLOSING;

         if Ms.Buf /= AIP.Buffers.NOBUF then
            Mqtt_Dispatch_Recv (Pcb, Ms);
         else
            Mqtt_Close (Pcb, Ms);
         end if;

      else
         case Ms.Kind is
            when MS_CONNECTING =>
               --  Upper MQTT Stack layer will set the status
               Ms.Buf  := Ev.Buf;
               AIP.Buffers.Buffer_Ref (Ev.Buf);
               Mqtt_Dispatch_Recv (Pcb, Ms);

            when MS_CONNECTED =>

               --  Read some more data

               if Ms.Buf = AIP.Buffers.NOBUF then
                  AIP.Buffers.Buffer_Ref (Ev.Buf);
                  Ms.Buf := Ev.Buf;
                  Mqtt_Dispatch_Recv (Pcb, Ms);
               else
                  --  Not very sure of this since dispatch use a loop
                  --  to process all pending Buffers
                  AIP.Buffers.Buffer_Chain (Ms.Buf, Ev.Buf);
               end if;

            when others =>

               --  Remote side closing twice (MS_CLOSING), or inconsistent
               --  state. Trash.

               AIP.TCP.TCP_Recved (Pcb, AIP.Buffers.Buffer_Tlen (Ev.Buf));
               Ms.Buf := AIP.Buffers.NOBUF;

         end case;

      end if;

      Err := AIP.NOERR;
   end MQTT_Process_Recv;

   --------------------------
   -- MQTT_Process_Connect --
   --------------------------

   procedure MQTT_Process_Connect
     (Ev  : AIP.TCP.TCP_Event_T;
      Pcb : AIP.PCBs.PCB_Id;
      Err : out AIP.Err_T)
   is
      Ms    :  Mqtt_Conn_State;
      for Ms'Address use AIP.TCP.TCP_Udata (Pcb);
      Data  : Stream_Element_Array (0 .. -1);
   begin
      pragma Unreferenced (Ev);
      --  AIP.IO.Put_Line ("New PCB Accept: Sid");
      AIP.TCP.On_TCP_Sent
        (Pcb, RAW_TCP_Callbacks.To_CBID (MQTT_Process_Sent'Access));
      AIP.TCP.On_TCP_Recv
        (Pcb, RAW_TCP_Callbacks.To_CBID (MQTT_Process_Recv'Access));
      AIP.TCP.On_TCP_Poll
        (Pcb, RAW_TCP_Callbacks.To_CBID (MQTT_Process_Poll'Access), 2 * 500);

      --  Enter MQTT connect state
      Ms.Kind := TCP_CONNECTED;
      --  Reset the Timer Tick for client
      Ms.Cyclic_Tick := 0;
      --  Call the User Procedure if available
      RAW_MQTT_Dispatcher.MQTT_Event
        (PCB    =>    Pcb,
         DATA   =>    Data,
         Cbid   =>    Ms.App_Client_Cbs.App_Connect_Cb,
         Err    =>    Err);

   end MQTT_Process_Connect;

   -----------------------------------------------
   --  MQTT_Timer --  CycleTick Timer Callback  --
   -----------------------------------------------

   procedure MQTT_Timer (Id : Integer) with
     Refined_Global => (In_Out => (MSP))
   is
      Sid   :  MS_Id := NOMS;
   begin
      null;
      for J in MSP'Range loop
         if MSP (J).Tmr_Id = Id then
            Sid := J;
            exit;
         end if;
      end loop;
      if Sid = NOMS then
         return;     --  this should not happen
      end if;
      --  Sid Points to the Client Connection State Data that MQTT_Timer belongs
      case MSP (Sid).Kind is
         when MS_CONNECTING =>
            MSP (Sid).Cyclic_Tick := MSP (Sid).Cyclic_Tick + 1;
            if MSP (Sid).Cyclic_Tick * MQTT_CYCLIC_TIMER_INTERVAL >= MQTT_CONNECT_TIMOUT then
               --  Disconnect TCP
               Mqtt_Close (MSP (Sid).Pcb, MSP (Sid));
               Timers.Timer_Stop (Id);
            end if;
         when MS_CONNECTED =>
            --  keep_alive > 0 means keep alive functionality shall be used
            if MSP (Sid).Keep_Alive > 0 then
               MSP (Sid).Server_Watchdog := MSP (Sid).Server_Watchdog + 1;
               --  If reception from server has been idle for 1.5*keep_alive time,
               --  server is considered unresponsive
               if MSP (Sid).Server_Watchdog * MQTT_CYCLIC_TIMER_INTERVAL >=
                 MSP (Sid).Keep_Alive + MSP (Sid).Keep_Alive / 2
               then
                  Mqtt_Close (MSP (Sid).Pcb, MSP (Sid));
                  Timers.Timer_Stop (Id);
               end if;
               if MSP (Sid).Cyclic_Tick * MQTT_CYCLIC_TIMER_INTERVAL >=
                 MSP (Sid).Keep_Alive
               then
                  --  Sending keep-alive message to server
                  declare
                     Ps : MQTT_Pier_Ptr;
                     for Ps'Address use AIP.TCP.TCP_Udata (MSP (Sid).Pcb);
                  begin
                     Send_Ping (Ps.all);
                     MSP (Sid).Cyclic_Tick := 0;
                  end;
               else
                  MSP (Sid).Cyclic_Tick := MSP (Sid).Cyclic_Tick + 1;
               end if;
            end if;
         when TCP_CONNECTING =>
            MSP (Sid).Cyclic_Tick := MSP (Sid).Cyclic_Tick + 1;
            if MSP (Sid).Cyclic_Tick * MQTT_CYCLIC_TIMER_INTERVAL >= TCP_CONNECT_TIMOUT then
               --  Disconnect TCP
               Mqtt_Close (MSP (Sid).Pcb, MSP (Sid));
               Timers.Timer_Stop (Id);
            end if;
         when others =>
            --  Timer should not be running in this state - perhaps TCP_ABORT
            Timers.Timer_Stop (Id);
      end case;
   end MQTT_Timer;

   --------------------------
   -- Mqtt_Client_Connect ---
   --------------------------

   procedure Mqtt_Client_Connect
     (Pier           : in out MQTT_Pier;
      Port           : Natural := MQTT_Port;
      Err            : out AIP.Err_T)
   is
      Pcb    : AIP.PCBs.PCB_Id;
      Sid    : MS_Id;
   begin
      --  check if client already is allocated or sort of
      if Pier.State_Pool /= null then
         Err := AIP.ERR_MEM;
         return;
      end if;

      AIP.TCP.TCP_New (Pcb);
      if Pcb = AIP.PCBs.NOPCB then
         Err := AIP.ERR_MEM;
         return;
      end if;
      AIP.TCP.TCP_Bind
        (PCB        => Pcb,
         Local_IP   => AIP.IPaddrs.IP_ADDR_ANY,
         Local_Port => 0,
         Err        => Err);
      if Err /= AIP.NOERR then
         goto Tcp_Error;
      end if;
      AIP.TCP.TCP_Connect
        (PCB        => Pcb,
         Addr       => Pier.Client_Address,
         Port       => Net.Uint16 (Port),
         Cb         => RAW_TCP_Callbacks.To_CBID (MQTT_Process_Connect'Access),
         Err        => Err);
      if Err /= AIP.NOERR then
         goto Tcp_Error;
      end if;
      MS_Alloc (Sid);
      if Sid = NOMS then
         --  AIP.TCP.TCP_Free (Pcb); --  I think original stack miss this need
         Err := AIP.ERR_MEM;
         goto Tcp_Error;
      else
         Pier.Sid := Sid;
         Pier.State_Pool := MSP (Sid)'Access;
         Pier.State_Pool.Kind := TCP_CONNECTING;
         Pier.State_Pool.Pcb := Pcb;
         Pier.State_Pool.Buf := AIP.Buffers.NOBUF;
         MSP (Sid).App_Client_Cbs := Pier.App_Cbs;
         AIP.TCP.TCP_Set_Udata (Pcb, MSP (Sid)'Address);
         --  Start cyclic timer for the corresponding client
         Timers.Timer_Alloc (Pier.State_Pool.Tmr_Id, MQTT_Timer'Access);
         Timers.Set_Interval (Pier.State_Pool.Tmr_Id, MQTT_CYCLIC_TIMER_INTERVAL * MQTT_Tick_Interval);
         Pier.State_Pool.Cyclic_Tick := 0;
      end if;
      --  set error callback
      AIP.TCP.On_TCP_Abort
        (Pcb, RAW_TCP_Callbacks.To_CBID (MQTT_Process_Abort'Access));
      return;
<<Tcp_Error>>
      declare
         tcpErr  : AIP.Err_T;
      begin
         pragma Unreferenced (tcpErr);
         AIP.TCP.TCP_Close (Pcb, tcpErr);
      end;
   end Mqtt_Client_Connect;

   ------------------------------
   -- Mqtt_Client_Disconnect ----
   ------------------------------

   procedure Mqtt_Client_Disconnect
     (Pier           : in out MQTT_Pier;
      Err            : out AIP.Err_T)
   is
      Ms : Mqtt_Conn_State;
      for Ms'Address use MSP (Pier.Sid)'Address;
   begin
         Mqtt_Close (Ms.Pcb, Ms);
         Err := AIP.NOERR;
   end Mqtt_Client_Disconnect;

end MQTT.Clients;



