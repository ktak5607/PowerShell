$folders = Get-ChildItem C:\Temp
foreach($f in $folders){
   $size = (Get-ChildItem -Path $f.FullName -Recurse | Measure-Object -Property Length -Sum).Sum/1MB
   if($size -ge 300){
        Write-Host $f.FullName $size
   }
    
    
}