# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install browsers
choco install googlechrome firefox -fy

# Install editors
choco install notepadplusplus atom vscode sublimetext3 -fy

# Install code stuff
choco install python3 -fy
choco install golang -fy
choco install arduino -fy

# Msoft Visual C++ Redis
choco install vcredist140 -fy

# VMware
choco install vmware-workstation-player -fy

# Install Utils
choco install winscp -fy
choco install git -fy
choco install 7zip -fy
choco install sysinternals -fy
choco install vlc -fy
choco install filezilla -fy
choco install putty -fy
choco install wireshark -fy
choco install iperf3 -fy
choco install frhed -fy

# Verify fails
# choco install ida-free -fy

# Install flash for Ialab ??
choco install flashplayerplugin -fy