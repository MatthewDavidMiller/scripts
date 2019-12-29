rem Script to batch compress files with 7zip.

CHOICE /C AB /M "Compress files?A Compress folders?B "
IF %errorlevel% equ 1 (
    CHOICE /C ABC /M "Use ultra compression?A No solid compression?B No compression?C "
    IF %errorlevel% equ 1 (
        for %%i in (*) do "c:\Program Files\7-Zip\7z.exe" a "%%i.7z" "%%i" -mx=9
        del %0.7z
    )
    IF %errorlevel% equ 2 (
        for %%i in (*) do "c:\Program Files\7-Zip\7z.exe" a "%%i.7z" "%%i" -mx=9 -ms=off
        del %0.7z
    )
    IF %errorlevel% equ 3 (
        for %%i in (*) do "c:\Program Files\7-Zip\7z.exe" a "%%i.7z" "%%i" -mx=0
        del %0.7z
    )
)

IF %errorlevel% equ 2 (
    CHOICE /C ABC /M "Use ultra compression?A No solid compression?B No compression?C "
    IF %errorlevel% equ 1 (
        for /d %%X in (*) do "c:\Program Files\7-Zip\7z.exe" a "%%X.7z" "%%X\" -mx=9
    )
    IF %errorlevel% equ 2 (
        for /d %%X in (*) do "c:\Program Files\7-Zip\7z.exe" a "%%X.7z" "%%X\" -mx=9 -ms=off
    )
    IF %errorlevel% equ 3 (
        for /d %%X in (*) do "c:\Program Files\7-Zip\7z.exe" a "%%X.7z" "%%X\" -mx=0
    )
)

pause
