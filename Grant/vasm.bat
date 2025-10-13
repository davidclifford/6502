echo %~n1.bin
vasm6502_oldstyle.exe -L list\%~n1.txt -Fbin -dotdir -wdc02 -o bin\%~n1.bin %1
vasm6502_oldstyle.exe -Fwoz -dotdir -wdc02 -o hex\%~n1.hex %1
