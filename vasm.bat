echo %~n1.bin
vasm6502_oldstyle.exe -Fbin -dotdir -wdc02 -o bin\%~n1.bin %1
