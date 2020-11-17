rem Robocopy backup script

rem Set source, destination, and log file location
SET MainBackupSource=""
SET MainBackupDestination=""
SET log_file="log_file"

rem Run the robocopy commands
robocopy %MainBackupSource% %MainBackupDestination% /s /copy:DAT /np /r:2 /w:5 /tee /MT:40 /mir /log:%log_file%
