:: Used to run a powershell script without needing to change the execution policy
:: Credits to Zack Olinske, https://stackoverflow.com/questions/42897554/powershell-executionpolicy-change-bypass
:: Credits to Microsoft, https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/set_1
:: Credits to rojo, https://stackoverflow.com/questions/15885132/file-folder-chooser-dialog-from-a-windows-batch-script

:: powershell.exe -executionpolicy bypass -file %%~I

<# : "RunPowerShell.bat"
@echo off
setlocal

for /f "delims=" %%I in ('powershell -noprofile "iex (${%~f0} | out-string)"') do (
    powershell.exe -executionpolicy bypass -file %%~I
)
goto :EOF
#>

Add-Type -AssemblyName System.Windows.Forms
$filebrowser = new-object Windows.Forms.OpenFileDialog
$filebrowser.InitialDirectory = pwd
$filebrowser.Filter = "Powershell Scripts (*.ps1)|*.ps1|All Files (*.*)|*.*"
$filebrowser.ShowHelp = $true
$filebrowser.Multiselect = $false
[void]$filebrowser.ShowDialog()
if ($filebrowser.Multiselect) { $filebrowser.FileNames } else { $filebrowser.FileName }
