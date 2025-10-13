echo %~n1.bin
vasm6502_oldstyle.exe -L List\%~n1.txt -Fbin -dotdir -wdc02 -o Bin\%~n1.bin %1
vasm6502_oldstyle.exe -Fwoz -dotdir -wdc02 -o Hex\%~n1.hex %1
