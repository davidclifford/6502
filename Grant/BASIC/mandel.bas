10 REM 83 Seconds  1.8432 MHz
11 REM 19 Seconds  8 MHz (stable)
12 REM 15 Seconds  10 MHz (unstable printing)
13 REM 16 Seconds  32-> 16/8 MHz RAM/ROM-IO clock stretching (2 inverters)
14 REM 12 Seconds  25-> 12.5/6.25 MHz RAM-ROM/IO clock stretching (74138+inverter)
15 REM 9.5 Seconds 32-> 16/8 MHz RAM-ROM/IO clock stretching (74138+inverter)
20 PRINTCHR$(27);"[2J";CHR$(27);"[H";
100 FOR PY=0 TO 21
110 FOR PX=0 TO 31
120 XZ = PX*3.5/32-2.5
130 YZ = PY*2/22-1
140 X = 0
150 Y = 0
160 FOR I=0 TO 14
170 IF X*X+Y*Y > 4 THEN GOTO 215
180 XT = X*X - Y*Y + XZ
190 Y = 2*X*Y + YZ
200 X = XT
210 NEXT I
215 I = I-1
220 PRINT(CHR$(I+32)+CHR$(I+32));
240 NEXT PX
250 PRINT
260 NEXT PY
270 FOR I=0 TO 9
280 PRINT CHR$(17)
290 NEXT I
