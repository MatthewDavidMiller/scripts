rem Used to process multiple files and folders wherever the bat file is located and run from.

CHOICE /M "Compress folders with 7zip? "
IF %errorlevel% equ 1 (
    for /d %%X in (*) do "c:\Program Files\7-Zip\7z.exe" a "%%X.7z" "%%X" -mx=9
    for %%i in (*.7z) do tar -cf "%%i.tar" "%%i"
    del *.7z
)

IF %errorlevel% equ 2 (
    for /d %%X in (*) do tar -cf "%%X.tar" "%%X"
)
pause
