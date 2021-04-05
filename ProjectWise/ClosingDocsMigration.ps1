If(New-PWLogin -UseGui){
    $districts = {'Bristol', 'Culpeper', 'Fredericksburg', 'Hampton Roads', 'Lynchburg', 'Nova', 'Richmond', 'Salem', 'Staunton', 'Statewide'}
    Get-ChildItem 'path to files on server'|ForEach-Object{
        $upc = $_.Name
        Foreach($dist in $districts){
            $pwProjPath = "_Projects\$dist\$upc"
            If(Get-PWRichProjects -FolderPath $pwProjPath  -JustOne){
                $pwClosingPath = ''
                Get-ChildItem $_.FullName | ForEach-Object{
                    
                    New-PWDocument -FolderPath $pwClosingPath -FilePath $_.FullName
                }
            }
        }
        
        
    }
}