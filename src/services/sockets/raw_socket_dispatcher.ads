------------------------------------------------------------------------------
--                            IPSTACK COMPONENTS                            --
--  Written by Manuel Iglesias (Mhanuel.Usb@gmail.com)
--  Copyright (C) 2017.
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

with AIP.Callbacks;
with AIP.PCBs;
with Ada.Streams;    use Ada.Streams;
with RAW_LwIp_Server;    use RAW_LwIp_Server;

package RAW_SOCKET_Dispatcher is

   procedure SOCKET_Event
     (Client : in out Connection_Ptr;
      PCB    : AIP.PCBs.PCB_Id;
      DATA   : Stream_Element_Array;
      Cbid   : AIP.Callbacks.CBK_Id;
      Err    : out AIP.Err_T);
   --  Process TCP event EV, aimed at PCB and for which Cbid was
   --  registered.

   --  pragma Export (Ada, TCP_Event, "AIP_tcp_event");

end RAW_SOCKET_Dispatcher;
