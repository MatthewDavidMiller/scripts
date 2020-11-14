rem Robocopy backup script

rem Set source, destination, and log file location
SET MainBackupSource=""
SET MainBackupDestination=""
SET log_file="log_file"

rem Set two more backup source and destinations
SET Backup2Source=""
SET Backup2Destination=""
SET Backup3Source=""
SET Backup3Destination=""

rem Run the robocopy commands
robocopy %Backup3Source% %Backup3Destination% /s /copy:DAT /np /r:2 /w:5 /tee /MT:40 /log:%log_file%
robocopy %Backup2Source% %Backup2Destination% /s /copy:DAT /np /r:2 /w:5 /tee /MT:40 /log:%log_file%
robocopy %MainBackupSource% %MainBackupDestination% /s /copy:DAT /np /r:2 /w:5 /tee /MT:40 /mir /log:%log_file%
