BOARD=stm32f769
BOARD_DIR=stm32f769disco
MODE=-XBUILD=Debug -XBUILD_RTS=Debug

all:	ping

ping:
	arm-eabi-gnatmake -vh $(MODE) -Pping -p -cargs -mno-unaligned-access
	arm-eabi-objcopy -O binary obj/${BOARD_DIR}/ping ping.bin

flash-ping:		ping
	st-flash write ping.bin 0x8000000

checkout:
	git submodule update --init --recursive

clean:
	rm -rf obj ping.bin

.PHONY: ping echo time dns

