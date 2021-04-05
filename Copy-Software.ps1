
$userName = Read-Host "Enter your username"
$password = Read-Host "Enter your password" -AsSecureString
$dests = Read-Host "Enter the computer(s) to copy files to seperated by a comma (no spaces)."
$soft = Read-Host "Enter software to copy seperated by a comma (PW for ProjectWise, MS for Microstation, CS for ConceptStation, RT for LumenRT, CC for ContextCapture, LS for Leap steal, LC for Leap concrete)."
$software = $soft.Split(',')
$destList = $dests.Split(',')
Write-Host "`n"
[pscredential]$credentials = New-Object System.Management.Automation.PSCredential ($userName, $password)
foreach($d in $destList){
    try{
        $destination = New-PSDrive -Name "Tmp" -PSProvider FileSystem -Root "\\$d\c$\Windows\I386\software" -Credential $credentials -ErrorAction Stop
    }
    catch{
        if($Error[0].Exception.Message.Contains("Access is denied")){
            Write-Host "Access is denied. You don't have sufficient privileges to access this computer."
        }
        else{
            Write-Host "Failed to connect to"$d
            Write-Host $Error
        }
        break
        
    }
    foreach($s in $software){
        if($s.Contains("PW")){
            Write-Host "Copying the ProjectWise folder to "$d
            Copy-Item 'path to files on serverProject Wise'  -Destination $destination.Root -Force -Recurse 
        }
        elseif($s.Contains("MS")){
            Write-Host "Copying the Microstation folder to "$d
            Copy-Item 'path to files on serverCADD SS10 916 GEO 918' -Destination $destination.Root -Force -Recurse
        }
        elseif($s.Contains("CS")){
            Write-Host "Copying the ConceptStation folder to "$d
            Copy-Item 'path to files on server\Concept Station Bentley\OpenRoads Conceptstation CONNECT Edition' -Destination $destination.Root -Force -Recurse
        }
        elseif($s.Contains("RT")){
            Write-Host "Copying the LumenRT folder to "$d
            Copy-Item 'path to files on server\LumenRT\lumrt16146067en_updt14' -Destination $destination.Root -Force -Recurse
        }
        elseif($s.Contains("CC")){
            Write-Host "Copying the ContextCapture folder to "$d
            Copy-Item 'path to files on server\Context Capture Update15' -Destination $destination.Root -Force -Recurse
        }
        elseif($s.Contains("LS")){
            Write-Host "Copying the Leap Steel folder to "$d
            Copy-Item 'path to files on server\Bridge Software\Bentley LEAP Bridge STEEL 18010025' -Destination $destination.Root -Force -Recurse
        }
        elseif($s.Contains("LC")){
            Write-Host "Copying the Leap Concrete folder to "$d
            Copy-Item 'path to files on server\Bridge Software\Bentley LEAP Bridge CONCRETE 18020106 UPT2' -Destination $destination.Root -Force -Recurse
        }
        elseif($s.Contains("PC")){
            Write-Host "Copying the ProConcrete folder to "$d
            Copy-Item 'path to files on server\ProStructures\ProStructures CONNECT Edition' -Destination $destination.Root -Force -Recurse -Verbose
        }
        elseif($s.Contains("ORD")){
            Write-Host "Copying the ORD folder to "$d
            Copy-Item 'path to files on server\ORD-OBD\OpenRoads Designer CONNECT Edition' -Destination $destination.Root -Force -Recurse -Verbose
        }
        else{
            Write-Host $s "isn't a vaild software to copy."
        }
    }#end loop through software
    Remove-PSDrive -Name "Tmp"
}#end loop through computers

Write-Host "Done"