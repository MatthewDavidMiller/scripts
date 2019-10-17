rem Used to restart print spooler service.
net stop "Print Spooler"
taskkill /IM "printfilterpipelinesvc.exe" /F
del /S /Q "C:\Windows\System32\spool\PRINTERS\*"
net start "Print Spooler"
pause