#attempt to log in to ProjectWise, if it fails exit the program
 if(New-PWLogin -UseGui) {
        $consultantName = Read-Host "Enter the consultants name: "
        Write-Output 'Successfully logged into ProjectWise datasource.'
        $folders = Get-PWRichProjects -FolderPath "_Projects\Bristol"
   
    for($folder -in $folders){
         Write-Host $folder.Name
         Write-Host $folder.FullPath
        $security = Get-PWFolderSecurity -InputFolder $folder
        for($sec -in $security){
            if ($sec.Name.ToUpper().Equals($consultantName.ToUpper())){
                Write-Host $folder.Name
            }
        }


    }
    Undo-PWLogin
 } 
    else {
        Write-Output -Message 'Failed to log into ProjectWise datasource.'
        break
    }