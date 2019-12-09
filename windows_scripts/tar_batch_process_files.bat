rem Used to process multiple files and folders wherever the bat file is located and run from.
for /d %%X in (*) do tar -cf "%%X.tar" "%%X"

CHOICE /M "Compress tar archives? "
IF %errorlevel% equ 1 (
    for %%i in (*.tar) do "c:\Program Files\7-Zip\7z.exe" a "%%i.7z" "%%i" -mx=9
)
pause
