$aadTenantId="<YOUR_AAD_TENANT_ID>"
$workspaceId = "<YOUR_LOGA_WORKSPACE_ID>"
$workspaceKey = "<YOUR_LOGA_WORKSPACE_KEY>"
$fslogixProfilePath = "<YOUR_FILE_SHARE_PATH>"

#########################################################################################
# Create a temp working directory
#########################################################################################
New-Item -Path 'C:\temp' -ItemType Directory -Force | Out-Null

#########################################################################################
# Download, install, and configure FSLogix
#########################################################################################
Write-Host "Downloading FSLogix"
Invoke-WebRequest -Uri 'https://aka.ms/fslogix_download' -OutFile 'c:\temp\fslogix.zip'
Write-Host "Start 10 second sleep"
Start-Sleep -Seconds 10

Write-Host "Installing FSLogix"
Expand-Archive -Path 'C:\temp\fslogix.zip' -DestinationPath 'C:\temp\fslogix\'  -Force
Invoke-Expression -Command 'C:\temp\fslogix\x64\Release\FSLogixAppsSetup.exe /install /quiet /norestart'
Write-Host "Start 10 second sleep"
Start-Sleep -Seconds 10

Write-Host "Configuring FSLogix"
New-Item -Path HKLM:\Software\FSLogix\ -Name Profiles -Force
New-Item -Path HKLM:\Software\FSLogix\Profiles\ -Name Apps -Force
Set-ItemProperty -Path HKLM:\Software\FSLogix\Profiles -Name "Enabled" -Type "Dword" -Value "1"
Set-ItemProperty -Path HKLM:\Software\FSLogix\Profiles -Name "DeleteLocalProfileWhenVHDShouldApply" -Type "Dword" -Value "1"
New-ItemProperty -Path HKLM:\Software\FSLogix\Profiles -Name "VHDLocations" -Value $fslogixProfilePath -PropertyType MultiString -Force
Set-ItemProperty -Path HKLM:\Software\FSLogix\Profiles -Name "SizeInMBs" -Type "Dword" -Value "15360"
Set-ItemProperty -Path HKLM:\Software\FSLogix\Profiles -Name "IsDynamic" -Type "Dword" -Value "1"
Set-ItemProperty -Path HKLM:\Software\FSLogix\Profiles -Name "VolumeType" -Type String -Value "vhd"
Set-ItemProperty -Path HKLM:\Software\FSLogix\Profiles -Name "LockedRetryCount" -Type "Dword" -Value "12"
Set-ItemProperty -Path HKLM:\Software\FSLogix\Profiles -Name "LockedRetryInterval" -Type "Dword" -Value "5"
Set-ItemProperty -Path HKLM:\Software\FSLogix\Profiles -Name "ProfileType" -Type "Dword" -Value "3"
Set-ItemProperty -Path HKLM:\Software\FSLogix\Profiles -Name "ConcurrentUserSessions" -Type "Dword" -Value "1"
Set-ItemProperty -Path HKLM:\Software\FSLogix\Profiles -Name "RoamSearch" -Type "Dword" -Value "2" 
New-ItemProperty -Path HKLM:\Software\FSLogix\Profiles\Apps -Name "RoamSearch" -Type "Dword" -Value "2"
Set-ItemProperty -Path HKLM:\Software\FSLogix\Profiles -Name "RoamSearch" -Type "Dword" -Value "2"
Set-ItemProperty -Path HKLM:\Software\FSLogix\Profiles -Name "VolumeType" -Type String -Value "vhd"
Set-ItemProperty -Path HKLM:\Software\FSLogix\Profiles -Name "FlipFlopProfileDirectoryName" -Type "Dword" -Value "1" 
Set-ItemProperty -Path HKLM:\Software\FSLogix\Profiles -Name "SIDDirNamePattern" -Type String -Value "%username%%sid%"
Set-ItemProperty -Path HKLM:\Software\FSLogix\Profiles -Name "SIDDirNameMatch" -Type String -Value "%username%%sid%"
Write-Host "Start 10 second sleep"
Start-Sleep -Seconds 10

#########################################################################################
# Download and install Teams
#########################################################################################
Write-Host "Downloaing Teams"
New-Item -Path 'HKLM:\SOFTWARE\Citrix\PortICA' -Force | Out-Null
Invoke-WebRequest -Uri 'https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&download=true&managedInstaller=true&arch=x64' -OutFile 'c:\temp\Teams.msi'
Write-Host "Start 10 second sleep"
Start-Sleep -Seconds 10

Write-Host "Installing Teams"
Start-Process msiexec.exe -Wait -ArgumentList '/I c:\temp\Teams.msi /quiet /l*v c:\temp\teamsinstall.log ALLUSER=1'
Write-Host "Start 10 second sleep"
Start-Sleep -Seconds 30
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run -Name Teams -PropertyType Binary -Value ([byte[]](0x01,0x00,0x00,0x00,0x1a,0x19,0xc3,0xb9,0x62,0x69,0xd5,0x01)) -Force
Write-Host "Start 10 second sleep"
Start-Sleep -Seconds 10

#########################################################################################
# Download and install Edge Chromium
#########################################################################################
Write-Host "Install Microsoft Edge Enterprise"
Invoke-WebRequest -Uri 'http://dl.delivery.mp.microsoft.com/filestreamingservice/files/9dd4c786-d34b-4bdf-90f7-dae7618ba8b4/MicrosoftEdgeEnterpriseX64.msi' -UseBasicParsing -OutFile 'c:\temp\MicrosoftEdgeEnterpriseX64.msi'
Start-Process msiexec.exe -Wait -ArgumentList '/I c:\temp\MicrosoftEdgeEnterpriseX64.msi /quiet'
Write-Host "Start 10 second sleep"
Start-Sleep -Seconds 30

#########################################################################################
# Download and install Sepago
#########################################################################################
#Write-Host "Install Sepago"
#Invoke-WebRequest -Uri 'http://loganalytics.sepago.com/downloads/ITPC-LogAnalyticsAgent.zip' -OutFile 'c:\temp\ITPC-LogAnalyticsAgent.zip'
#Expand-Archive -Path 'c:\temp\ITPC-LogAnalyticsAgent.zip' -DestinationPath 'C:\temp\ITPC-LogAnalyticsAgent'  -Force
#Copy-Item -Path "c:\temp\ITPC-LogAnalyticsAgent\Azure Monitor for WVD" -Destination "C:\Program Files\ITPC-LogAnalyticsAgent" -Recurse -Force
#(Get-Content "C:\Program Files\ITPC-LogAnalyticsAgent\ITPC-LogAnalyticsAgent.exe.config").replace('!!! WORKSPACE ID from Advanced Settings !!!', $workspaceId) | Set-Content "C:\Program Files\ITPC-LogAnalyticsAgent\ITPC-LogAnalyticsAgent.exe.config"
#(Get-Content "C:\Program Files\ITPC-LogAnalyticsAgent\ITPC-LogAnalyticsAgent.exe.config").replace('!!! PRIMARY or SECONDARY KEY from Advanced Settings !!!', $workspaceKey) | Set-Content "C:\Program Files\ITPC-LogAnalyticsAgent\ITPC-LogAnalyticsAgent.exe.config"
#Start-Process "C:\Program Files\ITPC-LogAnalyticsAgent\ITPC-LogAnalyticsAgent.exe" -Wait -ArgumentList '-install'

#########################################################################################
# Download and install VSCode
#########################################################################################
#Write-Host "Install VSCode"
#Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/?Linkid=852157' -OutFile 'c:\temp\VScode.exe'
#Invoke-Expression -Command 'c:\temp\VScode.exe /verysilent'
#Write-Host "Start 10 second sleep"
#Start-Sleep -Seconds 10

#########################################################################################
# Registry settings
#########################################################################################
# Disable storage sense
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v 01 /t REG_DWORD /d 0 /f

# Enable TZ redirection
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v fEnableTimeZoneRedirection /t REG_DWORD /d 1 /f

# Session timeout policies
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v RemoteAppLogoffTimeLimit /t REG_DWORD /d 0 /f
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v fResetBroken /t REG_DWORD /d 1 /f
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v MaxConnectionTime /t REG_DWORD /d 28800000 /f
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v RemoteAppLogoffTimeLimit /t REG_DWORD /d 0 /f
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v MaxDisconnectionTime /t REG_DWORD /d 14400000 /f
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v MaxIdleTime /t REG_DWORD /d 7600000 /f

#Enter the following commands into the registry editor to fix 5k resolution support
REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v MaxMonitors /t REG_DWORD /d 4 /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v MaxXResolution /t REG_DWORD /d 5120 /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v MaxYResolution /t REG_DWORD /d 2880 /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\rdp-sxs" /v MaxMonitors /t REG_DWORD /d 4 /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\rdp-sxs" /v MaxXResolution /t REG_DWORD /d 5120 /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\rdp-sxs" /v MaxYResolution /t REG_DWORD /d 2880 /f

Set-Service -Name w32time -StartupType Automatic

# Set the power profile to the High Performance
powercfg /setactive SCHEME_MIN