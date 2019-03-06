# Run the script as admin.

# Applications to remove

# Use this variable with the other variables
$app_to_remove_1="Microsoft."

# Names of applications
$app_to_remove_2="Windows.Photos"
$app_to_remove_3="BingWeather"
$app_to_remove_4="MicrosoftStickyNotes"
$app_to_remove_5="ZuneVideo"
$app_to_remove_6="ZuneMusic"
$app_to_remove_7="XboxSpeechToTextOverlay"
$app_to_remove_8="XboxIdentityProvider"
$app_to_remove_9="XboxGamingOverlay"
$app_to_remove_10="XboxGameOverlay"
$app_to_remove_11="XboxApp"
$app_to_remove_12="Xbox.TCUI"
$app_to_remove_13="WindowsSoundRecorder"
$app_to_remove_14="WindowsMaps"
$app_to_remove_15="WindowsFeedbackHub"
$app_to_remove_16="windowscommunicationsapps"
$app_to_remove_17="WindowsCamera"
$app_to_remove_18="WindowsAlarms"
$app_to_remove_19="SkypeApp"
$app_to_remove_20="Print3D"
$app_to_remove_21="People"
$app_to_remove_22="OneConnect"
$app_to_remove_23="Office.Sway"
$app_to_remove_24="NetworkSpeedTest"
$app_to_remove_25="MicrosoftSolitaireCollection"
$app_to_remove_26="MicrosoftOfficeHub"
$app_to_remove_27="Microsoft3DViewer"
$app_to_remove_28="Messaging"
$app_to_remove_29="Getstarted"
$app_to_remove_30="GetHelp"
$app_to_remove_31="XboxOneSmartGlass"
$app_to_remove_32="BingNews"
$app_to_remove_33="Windows.Photos"
$app_to_remove_34="WindowsCalculator"
$app_to_remove_35="MSPaint"
$app_to_remove_36="YourPhone"
$app_to_remove_37="MixedReality.Portal"
$app_to_remove_38="ScreenSketch"
$app_to_remove_39="Office.OneNote"
$app_to_remove_40="Wallet"


# Removes the applications
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_2)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_3)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_4)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_5)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_6)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_7)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_8)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_9)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_10)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_11)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_12)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_13)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_14)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_15)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_16)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_17)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_18)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_19)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_20)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_21)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_22)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_23)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_24)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_25)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_26)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_27)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_28)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_29)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_30)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_31)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_32)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_33)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_34)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_35)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_36)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_37)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_38)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_39)" | Remove-AppxPackage
Get-AppxPackage -name "$($app_to_remove_1)$($app_to_remove_40)" | Remove-AppxPackage

# MIT License

# Copyright (c) 2019 Matthew David Miller

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
