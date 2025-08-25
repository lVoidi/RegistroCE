@echo off
echo === Compilando main.asm ===
ml /c main.asm
echo === Compilando menu.asm ===
ml /c menu.asm
echo === Enlazando objetos ===
link main.obj+menu.obj;
echo === Ejecutando programa ===
main.exe
pause
