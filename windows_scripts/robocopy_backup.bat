rem Used to backup files
rem Run the script as administrator

rem Set source, destination, and log file location
SET source_directory="source_location"
SET destination_directory="destination_location"
SET log_file="log_file"

robocopy %source_directory% %destination_directory% /s /copyall /np /r:2 /w:5 /tee /log:%log_file%
