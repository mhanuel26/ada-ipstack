------------------------------------------------------------------------------
--                            IPSTACK DNS COMPONENT
--         Copyright (C) 2017.
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

with AIP.UDP;

package DNS.Clients with
Abstract_State => (State with Part_Of => DNS.State)
is

   DNS_PORT : constant AIP.U16_T := 53;

   DSP : Dns_Conn_State_Array;

   procedure Init_DS_Pool;

   procedure Bind
     (Request : access Query)
   with
     Global => (In_Out => (State));

   procedure Send (Request : access Query;
                   Data    : Stream_Element_Array;
                   Last    : Stream_Element_Offset)
   with
     Global => (In_Out => (State));

   procedure Dns_Receive
     (Ev  : AIP.UDP.UDP_Event_T;
      Pcb : AIP.PCBs.PCB_Id)
   with
     Global => (In_Out => (State));

end DNS.Clients;
