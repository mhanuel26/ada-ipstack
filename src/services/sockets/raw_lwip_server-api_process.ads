------------------------------------------------------------------------------
--                  IPSTACK RAW_LwIp_Server RAW API COMPONENT
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

--  Socket Server Implementation using the RAW callback API
--  for Lower Level binding of Socket Server from Dmitry A. Kazakov

package RAW_LwIp_Server.API_Process with
  Abstract_State => (State with Part_Of => RAW_LwIp_Server.State)
is

--
--     procedure Init
--     --  Setup server to wait for and process connections
--       with
--         Global => (Output => (State));

   lwIp_Listener   : Connections_Server_Ptr;
   lwIp_Factory    : access Connections_Factory'Class;



   procedure Initialize
     (Listener       : access Connections_Server'Class;
      Factory        : access Connections_Factory'Class;
      Err            : out AIP.Err_T)
     with
       Global => (In_Out => (State));


end RAW_LwIp_Server.API_Process;
