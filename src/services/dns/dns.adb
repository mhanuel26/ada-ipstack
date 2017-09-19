-----------------------------------------------------------------------
--  net-dns -- DNS Network utilities
--  Copyright (C) 2016, 2017 Stephane Carrez
--  Written by Stephane Carrez (Stephane.Carrez@gmail.com)
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
with Interfaces; use Interfaces;
--  with Net.Headers;

with Net.Utils;
with DNS.Clients;

package body DNS with
   Refined_State => (State => (DNS.Clients.State))
is

   --  The IN class for the DNS response (RFC 1035, 3.2.4. CLASS values).
   --  Other classes are not meaningly to us.
   IN_CLASS : constant Net.Uint16 := 16#0001#;

--     procedure Skip_Query (Packet : in out Net.Buffers.Buffer_Type);



   --  ------------------------------
   --  Add a byte to the buffer data, moving the buffer write position.
   --  ------------------------------
   procedure Put_Uint8 (Data    : in out Stream_Element_Array;
                         Pointer : in out Stream_Element_Offset;
                         Value   : in Net.Uint8);

   procedure Put_Uint8 (Data    : in out Stream_Element_Array;
                         Pointer : in out Stream_Element_Offset;
                         Value   : in Net.Uint8) is
   begin
      Data (Pointer) := Stream_Element (Unsigned_8 (Value));
      Pointer := Pointer + 1;
   end Put_Uint8;
   --  ------------------------------
   --  Add a 16-bit value in network byte order to the buffer data,
   --  moving the buffer write position.
   --  ------------------------------
   procedure Put_Uint16 (Data    : in out Stream_Element_Array;
                         Pointer : in out Stream_Element_Offset;
                         Value   : in Net.Uint16);

   procedure Put_Uint16 (Data    : in out Stream_Element_Array;
                         Pointer : in out Stream_Element_Offset;
                         Value   : in Net.Uint16) is
   begin
      Data (Pointer) := Stream_Element (Interfaces.Shift_Right (Unsigned_16 (Value), 8));
      Data (Pointer + 1) := Stream_Element (Unsigned_16 (Value) and 16#0ff#);
      Pointer := Pointer + 2;
   end Put_Uint16;


   --  ------------------------------
   --  Skip a number of bytes in the buffer, moving the buffer position <tt>Size<tt> bytes ahead.
   --  ------------------------------
   procedure Skip (Pointer : in out Stream_Element_Offset;
                     Size : in Net.Uint16);
   procedure Skip (Pointer : in out Stream_Element_Offset;
                   Size : in Net.Uint16) is
   begin
      Pointer := Pointer + Stream_Element_Count (Size);
   end Skip;

   --  ------------------------------
   --  Get a byte from the buffer, moving the buffer read position.
   --  ------------------------------

   function Get_Uint8 (Data    : in Stream_Element_Array;
                       Pointer : in out Stream_Element_Offset) return Net.Uint8;

   function Get_Uint8 (Data    : in Stream_Element_Array;
                       Pointer : in out Stream_Element_Offset) return Net.Uint8 is
      Pos : constant Stream_Element_Offset := Pointer;
   begin
      Pointer := Pointer + 1;
      return Net.Uint8 (Data (Pos));
   end Get_Uint8;

   --  ------------------------------
   --  Get a 16-bit value in network byte order from the buffer, moving the buffer read position.
   --  ------------------------------
   function Get_Uint16 (Data    : in Stream_Element_Array;
                        Pointer : in out Stream_Element_Offset) return Net.Uint16;

   function Get_Uint16 (Data    : in Stream_Element_Array;
                        Pointer : in out Stream_Element_Offset) return Net.Uint16 is
      Pos : constant Stream_Element_Offset := Pointer;
   begin
      Pointer := Pointer + 2;
      return Net.Uint16 (Interfaces.Shift_Left (Unsigned_16 (Data (Pos)), 8)
        or Interfaces.Unsigned_16 (Data (Pos + 1)));
   end Get_Uint16;

   --  ------------------------------
   --  Get a 32-bit value in network byte order from the buffer, moving the buffer read position.
   --  ------------------------------
   function Get_Uint32 (Data    : in Stream_Element_Array;
                        Pointer : in out Stream_Element_Offset) return Net.Uint32;
   function Get_Uint32 (Data    : in Stream_Element_Array;
                        Pointer : in out Stream_Element_Offset) return Net.Uint32 is
      Pos : constant Stream_Element_Offset := Pointer;
   begin
      Pointer := Pointer + 4;
      return Net.Uint32 (Interfaces.Shift_Left (Unsigned_32 (Data (Pos)), 24)
        or Interfaces.Shift_Left (Unsigned_32 (Data (Pos + 1)), 16)
        or Interfaces.Shift_Left (Unsigned_32 (Data (Pos + 2)), 8)
        or Unsigned_32 (Data (Pos + 3)));
   end Get_Uint32;

   --  ------------------------------
   --  Get an IPv4 value from the buffer, moving the buffer read position.
   --  ------------------------------
   function Get_Ip (Data    : in Stream_Element_Array;
                    Pointer : in out Stream_Element_Offset) return AIP.IPaddrs.IPaddr;

   function Get_Ip (Data    : in Stream_Element_Array;
                    Pointer : in out Stream_Element_Offset) return AIP.IPaddrs.IPaddr is
      Pos : constant Stream_Element_Offset := Pointer;
      Result : AIP.IPaddrs.IPaddr;
   begin
      Pointer := Pointer + 4;
      Result := AIP.IPaddrs.IP4 (AIP.U8_T (Data (Pos)),
                                 AIP.U8_T (Data (Pos + 1)),
                                 AIP.U8_T (Data (Pos + 2)),
                                 AIP.U8_T (Data (Pos + 3)));
      return Result;
   end Get_Ip;


   function Image (Value : in Net.Uint8) return String;

   function Image (Value : in Net.Uint8) return String is
      Result : constant String := Value'Image;
   begin
      return Result (Result'First + 1 .. Result'Last);
   end Image;
   --  ------------------------------
   --  Convert the IPv4 address to a dot string representation.
   --  ------------------------------
   function To_String (Ip : in AIP.IPaddrs.IPaddr) return String is
   begin
      return Image (Net.Uint8 (Interfaces.Shift_Right (Unsigned_32 (Ip), 24) and 16#00FF#)) & "."
        & Image (Net.Uint8 (Interfaces.Shift_Right (Unsigned_32 (Ip), 16) and 16#00FF#)) & "."
        & Image (Net.Uint8 (Interfaces.Shift_Right (Unsigned_32 (Ip), 8) and 16#00FF#)) & "."
        & Image (Net.Uint8 (Unsigned_32 (Ip) and 16#00FF#));
   end To_String;


   protected body Request is
      procedure Set_Result (Addr : in AIP.IPaddrs.IPaddr;
                            Time : in Net.Uint32) is
      begin
         Ip  := Addr;
         Ttl := Time;
         Status := NOERROR;
      end Set_Result;

      procedure Set_Status (State : in Status_Type) is
      begin
         Status := State;
      end Set_Status;

      function Get_IP return AIP.IPaddrs.IPaddr is
      begin
         return Ip;
      end Get_IP;

      function Get_Status return Status_Type is
      begin
         return Status;
      end Get_Status;

      function Get_TTL return Net.Uint32 is
      begin
         return Ttl;
      end Get_TTL;

   end Request;

   function Get_Status (Request : in Query) return Status_Type is
   begin
      return Request.Result.Get_Status;
   end Get_Status;

   --  ------------------------------
   --  Get the name defined for the DNS query.
   --  ------------------------------
   function Get_Name (Request : in Query) return String is
   begin
      return Request.Name (1 .. Request.Name_Len);
   end Get_Name;

   --  ------------------------------
   --  Get the IP address that was resolved by the DNS query.
   --  ------------------------------
   function Get_Ip (Request : in Query) return AIP.IPaddrs.IPaddr is
   begin
      return Request.Result.Get_IP;
   end Get_Ip;

   --  ------------------------------
   --  Get the TTL associated with the response.
   --  ------------------------------
   function Get_Ttl (Request : in Query) return Net.Uint32 is
   begin
      return Request.Result.Get_TTL;
   end Get_Ttl;


   procedure Init (Query_Array : access Dns_Query_Array)
   is
   begin
      for item in Dns_Queries'Range loop
         Dns_Queries (item) := Query_Array (item)'Access;
      end loop;
      Init_Done := True;
   end Init;

   --  ------------------------------
   --  Start a DNS resolution for the given hostname.
   --  ------------------------------
   procedure Resolve (Request : access Query;
                      Name    : in String;
                      Timeout : in Duration := 10.0) is
      use type Ada.Real_Time.Time;

      Xid      : constant Unsigned_32 := Unsigned_32 (Net.Utils.Random);
      Data     : Stream_Element_Array (1 .. 512);  --  512 is the maximun DNS payload
      Pointer  : Stream_Element_Offset := Data'First;
      C        : Character;
      Cnt      : Net.Uint8;
   begin
      if not Init_Done then
         Request.Err := AIP.ERR_MEM;
         return;
      end if;
      Request.Name_Len := Name'Length;
      Request.Name (1 .. Name'Length) := Name;
      Request.Result.Set_Status (PENDING);
      Request.Xid := Net.Uint16 (Xid and 16#0ffff#);
      Request.Deadline := Ada.Real_Time.Clock + Ada.Real_Time.To_Time_Span (Timeout);
      Put_Uint16 (Data, Pointer, Request.Xid);
      Put_Uint16 (Data, Pointer, 16#0100#);
      Put_Uint16 (Data, Pointer, 1);
      Put_Uint16 (Data, Pointer, 0);
      Put_Uint16 (Data, Pointer, 0);
      Put_Uint16 (Data, Pointer, 0);
      for I in 1 .. Request.Name_Len loop
         C := Request.Name (I);
         if C = '.' or I = 1 then
            Cnt := (if I = 1 then 1 else 0);
            for J in I + 1 .. Request.Name_Len loop
               C := Request.Name (J);
               exit when C = '.';
               Cnt := Cnt + 1;
            end loop;
            Put_Uint8 (Data, Pointer, Cnt);
            if I = 1 then
               Put_Uint8 (Data, Pointer, Character'Pos (Request.Name (1)));
            end if;
         else
            Put_Uint8 (Data, Pointer, Character'Pos (C));
         end if;
      end loop;
      Put_Uint8 (Data, Pointer, 0);
      Put_Uint16 (Data, Pointer, Net.Uint16 (A_RR));
      Put_Uint16 (Data, Pointer, IN_CLASS);
      Clients.Bind (Request);
      Clients.Send (Request, Data, Pointer);
   end Resolve;

   procedure Do_Receive
     (Conn_State : Dns_Conn_State;
      Data       : Stream_Element_Array)
   is
      Request : access Query;
   begin
      for item in Dns_Queries'Range loop
         if Dns_Queries (item).Sid = Conn_State.Sid then
            Request := Dns_Queries (item).all'Access;
            exit;
         end if;
      end loop;
      Receive (Request => Request.all,
               Data    => Data);
   end Do_Receive;

   --  ------------------------------
   --  Save the answer received from the DNS server.  This operation is called for each answer
   --  found in the DNS response packet.  The Index is incremented at each answer.  For example
   --  a DNS server can return a CNAME_RR answer followed by an A_RR: the operation is called
   --  two times.
   --
   --  This operation can be overriden to implement specific actions when an answer is received.
   --  ------------------------------
   procedure Answer (Request  : in out Query;
                     Status   : in Status_Type;
                     Response : in Response_Type;
                     Index    : in Natural) is
      pragma Unreferenced (Index);
   begin
      if Status /= NOERROR then
         Request.Result.Set_Status (Status);
      elsif Response.Of_Type = A_RR then
         Request.Result.Set_Result (Response.Ip, Response.Ttl);
      end if;
   end Answer;

   procedure Skip_Query (Data    : in Stream_Element_Array;
                         Pointer : in out Stream_Element_Offset);
   procedure Skip_Query (Data    : in Stream_Element_Array;
                         Pointer : in out Stream_Element_Offset) is
      Cnt : Net.Uint8;
   begin
      loop
         Cnt := Get_Uint8 (Data, Pointer);
         exit when Cnt = 0;
         Skip (Pointer, Net.Uint16 (Cnt));
      end loop;
      --  Skip QTYPE and QCLASS in query.
      Skip (Pointer, 2);
      Skip (Pointer, 2);
   end Skip_Query;

   procedure Receive (Request  : in out Query;
                      Data     : Stream_Element_Array) is

      Val     : Net.Uint16;
      Answers : Net.Uint16;
      Ttl     : Net.Uint32;
      Len     : Net.Uint16;
      Cls     : Net.Uint16;
      Status  : Status_Type;
      Pointer : Stream_Element_Offset := Data'First;
   begin
--        pragma Unreferenced (Answers, Ttl, Len, Cls, Status);

      Val := Get_Uint16 (Data, Pointer);
      if Val /= Request.Xid then
         return;
      end if;
      Val := Get_Uint16 (Data, Pointer);
      if (M32_T (Val) and 16#ff00#) /= 16#8100# then
         return;
      end if;
      if (M32_T (Val) and 16#0F#) /= 0 then
         case M32_T (Val) and 16#0F# is
            when 1 =>
               Status := FORMERR;

            when 2 =>
               Status := SERVFAIL;

            when 3 =>
               Status := NXDOMAIN;

            when 4 =>
               Status := NOTIMP;

            when  5 =>
               Status := REFUSED;

            when others =>
               Status := OTHERERROR;

         end case;
         Query'Class (Request).Answer (Status, Response_Type '(Kind => V_NONE, Len => 0,
                                                               Class => 0,
                                                               Of_Type => 0, Ttl => 0), 0);
         return;
      end if;
      Val := Get_Uint16 (Data, Pointer);
      Answers := Get_Uint16 (Data, Pointer);
      if Val /= 1 or else Answers = 0 then
         Query'Class (Request).Answer (SERVFAIL, Response_Type '(Kind => V_NONE, Len => 0,
                                                                 Class => 0,
                                                                 Of_Type => 0, Ttl => 0), 0);
         return;
      end if;
      Skip (Pointer, 4);
      Skip_Query (Data, Pointer);
      for I in 1 .. Answers loop
         Skip (Pointer, 2);
         Val := Get_Uint16 (Data, Pointer);
         Cls := Get_Uint16 (Data, Pointer);
         Ttl := Get_Uint32 (Data, Pointer);
         Len := Get_Uint16 (Data, Pointer);
         if Cls = IN_CLASS and Len < Net.Uint16 (DNS_VALUE_MAX_LENGTH) then
            case RR_Type (Val) is
               when A_RR =>
                  declare
                     Response : constant Response_Type
                       := Response_Type '(Kind    => V_IPV4, Len => Natural (Len),
                                          Of_Type => RR_Type (Val), Ttl => Ttl,
                                          Class   => Cls, Ip => Get_Ip (Data, Pointer));
                  begin
                     Query'Class (Request).Answer (NOERROR, Response, Natural (I));
                  end;

               when CNAME_RR | TXT_RR | MX_RR | NS_RR | PTR_RR =>
                  declare
                     Response : Response_Type
                       := Response_Type '(Kind    => V_TEXT, Len => Natural (Len),
                                          Of_Type => RR_Type (Val), Ttl => Ttl,
                                          Class   => Cls, others => <>);
                  begin
                     for J in Response.Text'Range loop
                        Response.Text (J) := Character'Val (Get_Uint8 (Data, Pointer));
                     end loop;
                     Query'Class (Request).Answer (NOERROR, Response, Natural (I));
                  end;

               when others =>
                  --  Ignore this answer: we don't know its type.
                  Skip (Pointer, Len);

            end case;
         else
            --  Ignore this anwser.
            Skip (Pointer, Len);
         end if;
      end loop;
   end Receive;

end DNS;
