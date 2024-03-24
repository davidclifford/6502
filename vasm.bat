echo %~n1.bin
vasm6502_oldstyle.exe -Fbin -dotdir -wdc02 -o bin\%~n1.bin %1
vasm6502_oldstyle.exe -Fihex -dotdir -wdc02 -o hex\%~n1.hex %1