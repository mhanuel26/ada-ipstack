# ada-ipstack

Ada ipstack embedded implementation for the STM32 devices with Ethernet peripheral. 
It brings ICMP / UDP / TCP / ARP support for Ada embedded. 

Higher layer protocol supported:

 * MQTT client.
 * HTTP Server.
 * DNS client.

This source is under development so it can change as new features and existing code 
is completed tested. 

# Hardware.

It's has been tested only on STM32F769I-DISCO since It's the only DISCO board I have at the
moment.

# Building.

I have no configure file yet, any help on this will be appreciated!

For now I use the config.status in replacement of configure.

First you need to build the libraries, make sure arm-gnat 2017 is in your path, 
on my hardware is located in /usr/local/gnat so I do

PATH="/usr/local/gnat/bin:$PATH"; export PATH

The project uses ravenscar full. I know there is a way to specify a separate config file
but for now I change manually two files of Ada_Drivers_Library

./Ada_Drivers_Library/boards/config.gpr
./Ada_Drivers_Library/boards/stm32f769_discovery/stm32f769_discovery.gpr

changing 

external ("RTS_Profile", "ravenscar-sfp");

with 

external ("RTS_Profile", "ravenscar-full");

After that library can be build using

arm-eabi-gnatmake -Paipstack_stm32fxxx -p

From then on you can open the ping.gpr project using gps and build. Just remember to select the 
ravenscar-full-stm32f769 under Project -> Properties -> Ada RunTime drop down.

# Debugging. 

I guess ST-Link can be used but I use openocd as follows

openocd -f ./tcl/board/stm32f7discovery.cfg

Under gps project you have to specify the settings for the remote connection go to,

Project -> Properties -> Embedded

Once there make sure to use

Connection Tool : openocd
Configuration File: stm32f7discovery.cfg
Program Host: localhost:3333
Protocol: remote

gps has a bug that make you open again the Debugger tab since it doens't save the Protocol
parameter the first time you save those configs, so double check it.

Then Init the debugger and use the following commands as needed, i.e.

monitor arm semihosting enable
monitor halt reset 
load
monitor halt reset 
continue