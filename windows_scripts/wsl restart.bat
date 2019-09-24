rem Used to restart Windows Subsystem for Linux service.
net stop "LxssManager"
net stop "LxssManagerUser_21fbe"
net start "LxssManager"
net start "LxssManagerUser_21fbe"
pause