Write-Host "Login to the datasource to export the files from."
if(New-PWLogin -UseGui){
    Write-Host "Exporting project"
    Export-PWDocumentsToArchive -OutputFolder "C:\temp" -OutputFileName "115480.sqlite" -ProjectWiseFolder "_Projects\Bristol\115480"
    Write-Host "Export complete"
    Undo-PWLogin
}

Write-Host "Login to the datasource to move the files to."
if(New-PWLogin -UseGui){
    Write-Host "Importing project"
    Import-PWDocumentsFromArchive -InputFile "C:\temp\115480.sqlite" -DefaultStorage "Bristol"
    Write-Host "Import complete"
    Undo-PWLogin
}
