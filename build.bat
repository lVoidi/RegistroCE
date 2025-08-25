@echo off
echo === Compilando main.asm ===
ml /c main.asm
if errorlevel 1 (
    echo Error al compilar main.asm
    pause
    exit /b
)
echo === Compilando menu.asm ===
ml /c menu.asm
if errorlevel 1 (
    echo Error al compilar menu.asm
    pause
    exit /b
)
echo === Enlazando objetos ===
link main.obj menu.obj, programa.exe,,;
if errorlevel 1 (
    echo Error al enlazar
    pause
    exit /b
)
echo === Ejecutando programa ===
programa.exe
pause