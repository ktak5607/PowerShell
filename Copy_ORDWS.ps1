$userName = Read-Host "Enter your username"
$password = Read-Host "Enter your password" -AsSecureString
$comp = Read-Host "Enter the computer to copy the ws to."
[pscredential]$credentials = New-Object System.Management.Automation.PSCredential ($userName, $password)
$destination = New-PSDrive -Name "Tmp" -PSProvider FileSystem -Root "\\$comp\c$\ProgramData\Bentley" -Credential $credentials -ErrorAction Stop
Copy-Item 'server path to workspace\OpenRoads Designer CE'  -Destination $destination.Root -Recurse -Force -Verbose 
Remove-PSDrive -Name "Tmp"