rem Used to view all hard links of files in a folder.
for %%i in (*) do fsutil hardlink list "%%i"
pause