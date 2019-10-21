rem Used to batch process all files in a folder to hard links.
mkdir "hardlinks"
for %%i in (*) do mklink /h "hardlinks/%%i" "%%i"
del /q "hardlinks\batch_process_hard_links.bat"
pause