# Copyright (c) 2019-2020 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Run the script as admin.

# Remove applications

# Applications base name
$AppBase = "Microsoft."
# Applications to remove
$AppBingWeather = "BingWeather"
$AppStickyNotes = "MicrosoftStickyNotes"
$AppZuneVideo = "ZuneVideo"
$AppZuneMusic = "ZuneMusic"
$AppMaps = "WindowsMaps"
$AppFeedbackHub = "WindowsFeedbackHub"
$AppCommunications = "windowscommunicationsapps"
$AppCamera = "WindowsCamera"
$AppAlarms = "WindowsAlarms"
$AppSkype = "SkypeApp"
$AppPrint3D = "Print3D"
$AppPeople = "People"
$AppOneConnect = "OneConnect"
$AppOfficeSway = "Office.Sway"
$AppNetworkSpeedTest = "NetworkSpeedTest"
$AppSolitaire = "MicrosoftSolitaireCollection"
$AppOfficeHub = "MicrosoftOfficeHub"
$App3DViewer = "Microsoft3DViewer"
$AppMessaging = "Messaging"
$AppGetStarted = "Getstarted"
$AppGetHelp = "GetHelp"
$AppXboxOneSmartGlass = "XboxOneSmartGlass"
$AppNews = "BingNews"
$AppYourPhone = "YourPhone"
$AppMixedReality = "MixedReality.Portal"
$AppScreenSketch = "ScreenSketch"
$AppOfficeOnenote = "Office.OneNote"
$AppWallet = "Wallet"

# Removes the applications
Get-AppxPackage -name "$($AppBase)$($AppBingWeather)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppStickyNotes)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppZuneVideo)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppZuneMusic)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppMaps)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppFeedbackHub)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppCommunications)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppCamera)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppAlarms)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppSkype)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppPrint3D)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppPeople)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppOneConnect)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppOfficeSway)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppNetworkSpeedTest)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppSolitaire)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppOfficeHub)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($App3DViewer)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppMessaging)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppGetStarted)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppGetHelp)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppXboxOneSmartGlass)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppNews)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppYourPhone)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppMixedReality)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppScreenSketch)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppOfficeOnenote)" | Remove-AppxPackage
Get-AppxPackage -name "$($AppBase)$($AppWallet)" | Remove-AppxPackage
