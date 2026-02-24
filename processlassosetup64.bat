<# : Source - https://stackoverflow.com/a/78876882
@echo off & set "_F0=%~f0"
powershell -NoProfile -Command "[IO.File]::WriteAllText($Env:Temp+'\_.ps1',([IO.File]::ReadAllText('\\?\'+$Env:_F0) -replace '(?s).*?\r?\n#>\r?\n',''))"
reg query "HKEY_USERS\S-1-5-19" 1>nul 2>nul || powershell -NoProfile -Command "Start-Process powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%Temp%\_.ps1""' -Verb RunAs" & exit /b
#>
$Host.UI.RawUI.WindowTitle = "Process Lasso"
Clear-Host
Write-Host "Installing Process Lasso..."
# download plasso
curl.exe -LSso "$env:TEMP\processlassosetup64.exe" "https://dl.bitsum.com/files/processlassosetup64.exe"
# install plasso
Start "$env:TEMP\processlassosetup64.exe" /S
# clean plasso start menu shortcut
while (-not (Test-Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Process Lasso")) { Sleep 1 }
Move-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Process Lasso\Process Lasso.lnk" "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Process Lasso" -Recurse -Force
# remove plasso setup
Remove-Item "$env:TEMP\processlassosetup64.exe"
# stop plasso running
Stop-Service -Name "ProcessGovernor"
while ((Get-Service -Name "ProcessGovernor").Status -ne 'Stopped') { Sleep 1 }
Stop-Process -Name "bitsumsessionagent","ProcessGovernor","ProcessLasso" -Force -EA 0
# mark greeting and disable automatic updates for plasso
reg add "HKCU\SOFTWARE\ProcessLasso" /v SysTrayGreetingDone /t REG_DWORD /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\ProcessLasso" /v UpdateChecksEnabled /t REG_DWORD /d 0 /f | Out-Null
# create key file for plasso
$Base64String="PABjAHUAcwB0AG8AbQBlAHIAPgBBAGQAbQBpAG4AaQBzAHQAcgBhAHQAbwByADwALwBjAHUAcwB0AG8AbQBlAHIAPgANAAoAPABzAGkAZwBuAGEAdAB1AHIAZQA+AKfb89ul2/Hb99un26Pbptuq2/zb/9uq2/rb+Nv62/zbxNuW25TbwdvA28bbkNuf25Hbm9uc28/bmNvL25nbzds8AC8AcwBpAGcAbgBhAHQAdQByAGUAPgA="
[System.IO.File]::WriteAllBytes("$env:ProgramFiles\Process Lasso\prolasso.key", [Convert]::FromBase64String($Base64String))
# change licence to usarname for plasso
reg add "HKCU\SOFTWARE\ProcessLasso" /v LicensedTo /t REG_SZ /d "$env:USERNAME" /f | Out-Null
reg add "HKLM\SOFTWARE\ProcessLasso" /v LicensedTo /t REG_SZ /d "$env:USERNAME" /f | Out-Null
# disable win game mode
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 0 /f | Out-Null
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d 0 /f | Out-Null
PAUSE