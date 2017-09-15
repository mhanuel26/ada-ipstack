-----------------------------------------------------------------------
--  OS periodic task
--  Copyright (C) 2017 Manuel Iglesias
--  Written by Manuel Iglesias (mhanuel.usb@gmail.com)
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
-----------------------------------------------------------------------
with System;
package Os_Service is

--     type Us_Time is new Natural;

   --  Start the Periodic OS loop.
   procedure Start;

   procedure mqtt_connect;

   procedure Dummy (Id : Integer);
   --  The task that waits for packets.
   task Periodic with
     Storage_Size => (4 * 1024),
     Priority => System.Default_Priority;

end Os_Service;
