$tempFolder = "C:\Users\user.name\AppData\local\Temp"
Get-ChildItem -Path $tempFolder -Recurse -Force |ForEach-Object{
    $name = $_.Name
    try{
        Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction Stop
    }
    catch{
    
        if($Error[0].Exception.Message.Contains("used by another process")){
            $m = "Failed to delete " + $name + " it is being used by another program"
            Write-Host $m
        }
        else{
            Write-Host $Error[0].Exception.Message
        }
    }
}

