rem Used to restart print spooler service.
net stop "Print Spooler"
del /S /Q "C:\Windows\System32\spool\PRINTERS\*"
net start "Print Spooler"
pause