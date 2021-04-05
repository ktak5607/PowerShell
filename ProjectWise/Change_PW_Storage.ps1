$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
Import-Module pwps_dab -RequiredVersion 1.21.4.0
if(New-PWLogin -UseGui){
Update-PWStorageAreaForProjectTree -FolderPath "_Projects\Lynchburg\115493" -NewStorageArea "PW_Storage_Lynchburg_003" -UseAdminPaths -DeleteFromSourceStorage -Verbose -ErrorAction Stop -WarningAction Stop
Undo-PWLogin
}
$stopwatch.Stop()
$stopwatch.Elapsed