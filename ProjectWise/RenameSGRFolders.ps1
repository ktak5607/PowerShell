if(New-PWLogin -UseGui){
    $districts = "Bristol", "Culpeper", "Fredericksburg", "Hampton Roads", "Lynchburg", "Nova", "Richmond", "Salem", "Staunton"
    [string]$name = ""
    Foreach($dist in $districts){
        $path = "Central Office\SGR Bridge Projects\$dist"
        $projs = Get-PWFoldersImmediateChildren -FolderPath $path
        Foreach($proj in $projs){

            if($proj.Name.Contains("Fed Id")){
                $name = $proj.Name.Replace("Fed Id", "Federal ID")
                Update-PWFolderNameProps -FolderPath $proj.FullPath -NewName $name
                
            }
            elseif($proj.Name.Contains("FED ID")){
                $name = $proj.Name.Replace("FED ID", "Federal ID")
                Update-PWFolderNameProps -FolderPath $proj.FullPath -NewName $name
            }

            elseif($proj.Name.Contains("Fed ID")){
                $name = $proj.Name.Replace("Fed ID", "Federal ID")
                Update-PWFolderNameProps -FolderPath $proj.FullPath -NewName $name
            }

            elseif($proj.Name.Contains("Fed-ID")){
                $name = $proj.Name.Replace("Fed-ID", "Federal ID")
                Update-PWFolderNameProps -FolderPath $proj.FullPath -NewName $name
            }

            
            
            
        }
    }
    
}