# Install SSH


function _uncomment($string) {
$strings = 'PubkeyAuthentication'

$file = (Get-Content $filename)
$replaced = $file -replace '#$param', $param
$export = Out-File -encoding ASCII $sshd_config

}

Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# OPTIONAL but recommended:
Set-Service -Name sshd -StartupType 'Automatic'

# Start the sshd service
Start-Service sshd

# Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
}

# Set default shell for OpenSSH
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force;

# Get the public key 
$authorizedKey = Get-Content -Path "<path to your public key>"
New-Item -Force -ItemType Directory -Path $env:USERPROFILE\.ssh; Add-Content -Force -Path $env:USERPROFILE\.ssh\authorized_keys -Value $authorizedKey

# Set the config to allow the pubkey auth
$sshd_config="C:\ProgramData\ssh\sshd_config" 
(Get-Content $sshd_config) -replace '#PubkeyAuthentication', 'PubkeyAuthentication' | Out-File -encoding ASCII $sshd_config
(Get-Content $sshd_config) -replace 'AuthorizedKeysFile __PROGRAMDATA__', '#AuthorizedKeysFile __PROGRAMDATA__' | Out-File -encoding ASCII $sshd_config
(Get-Content $sshd_config) -replace 'Match Group administrators', '#Match Group administrators' | Out-File -encoding ASCII $sshd_config
Get-Content C:\ProgramData\ssh\sshd_config

# Reload the config
Restart-Service sshd
