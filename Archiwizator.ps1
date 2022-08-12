$path =                                                             <#Ścieżka do katalogu nadrzędnego#>
$delTxt = 0                                                         <#1 - Usuwaj .txt po archiwizacji 0 - Nie usuwaj#>
$compressDays = 1                                                   <#Po ilu dniach ma kompresować logi#>
$delTxt = 5                                                         <#Po ilu dniach ma usuwać .txt#>
$delZip = 9                                                         <#Po ilu dniach ma usuwać .zip#>
​
$countTxt = (Get-ChildItem -Path $path -Filter "*.txt" -Recurse -ErrorAction SilentlyContinue -Force).count
$countZip = (Get-ChildItem -Path $path -Filter "*.zip" -Recurse -ErrorAction SilentlyContinue -Force).count
$tabTxt = 0..$countTxt
$tabZip = 0..$countZip
​
$date = Get-Date
$compressDate = $date.AddDays(-$compressDays)
$delTxtRes = $date.AddDays(-$delTxt)
$delZipRes = $date.AddDays(-$delZip)
​
function Archiwizator {
    for ($i = 0; $i -lt $countTxt; $i++) {
        $tabTxt[$i] = Get-ChildItem -Path $path -Filter "*.txt" -Recurse -ErrorAction SilentlyContinue -Force | Select-Object -First 1 -skip $i {
            if ($_.CreationTime -le $compressDate) {
                $compress = @{
                    Path = $_.FullName
                    CompressionLevel = "Fastest"
                    DestinationPath = $_.FullName + ".zip"
                }
                Write-Host $i".Archiwizuje: "$_
                Compress-Archive @compress
            }
        }
    }
    for ($y = 0; $y -lt $countTxt; $y++) {
        $tabTxt[$y] = Get-ChildItem -Path $path -Filter "*.txt" -Recurse -ErrorAction SilentlyContinue -Force | Select-Object -First 1 {
            if ($_.CreationTime -le $delTxtRes) {
                Write-Host $y".Usuwam: "$_
                $_ | Remove-Item
            }
            if ($delTxt -eq 1) {
                if ($_.CreationTime -le $compressDate) {
                    Write-Host $y".Usuwam: "$_
                    $_ | Remove-Item
                }
            }
        }
    }
    for ($x = 0; $x -lt $countZip; $x++) {
        $tabZip[$x] = Get-ChildItem -Path $path -Filter "*.zip" -Recurse -ErrorAction SilentlyContinue -Force | Select-Object -First 1 {
            if ($_.CreationTime -le $delZipRes) {
                Write-Host $x".Usuwam: "$_
                $_ | Remove-Item
            }
        }
    }
}
Archiwizator