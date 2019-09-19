rem Used to process multiple files and folders wherever the bat file is located and run from.
for /d %%X in (*) do tar -cf "%%X.tar" "%%X"
pause