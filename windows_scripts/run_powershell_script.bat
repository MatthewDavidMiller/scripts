:: Used to run a powershell script without needing to change the execution policy
:: Credits to Zack Olinske, https://stackoverflow.com/questions/42897554/powershell-executionpolicy-change-bypass
:: Credits to Microsoft, https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/set_1

:: Specify file
SET /p File=Enter full script path:

:: Run powershell script
powershell.exe -executionpolicy bypass -file "%File%"
