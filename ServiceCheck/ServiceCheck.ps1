Function Main
{

$folder = Get-Location
$Global:log = "$folder\log.html"
$count = 0
Get-Date | Out-File $log
Log-Break
Log-Line "<a href='\\qaserver5\Scripts\ServiceCheck\Call ServiceCheck.bat'>RUN SERVICECHECK</a>"
    Try {
    $systemarr = Query-Database "Select SystemID from System Where IsActive = 1"
    } 
    Catch {
    Log-Error "Failed to return system data array"
    Exit
    }

    If ($systemarr -eq $null) {
    Log-Error "Failed to return system data array"
    Exit
    }

FOREACH($system in $systemarr.SystemID) {
    
    Try {
    $server = Query-Database "Select ServerName from SoftwareServer ss join System sy on sy.SoftwareServerID = ss.SoftwareServerID where sy.SystemID = $system"
    $servername = $server.ServerName
    $configarr = Query-Database "Select ServiceName from Service Where SystemID = $system"
    }
    Catch {
    Log-Error "Failed to return SQL server data"
    Exit
    }
    
    If (($server -eq $null) -or ($servername -eq $null) -or ($configarr -eq $null)) {
    Log-Error "Failed to return SQL server data"
    Exit
    }

        FOREACH($config in $configarr.ServiceName){
        
            $a = Get-Service -ComputerName "$servername" -Name "$config" | Where-Object {$_.Status -ne 'Running'} | Format-Table -AutoSize
            IF ($a -ne $null) {
                Log-Break
                Log-Line $a 
                Log-Line $server
                Log-Break
                $count = $count + 1
            }
        }
}

$d = Get-Date
IF ($count -eq 0) {
    Log-Break
    Log-Line "No services down. :)" 
    Log-Break
    Log-Line $d 
} ELSE {
    Log-Break
    Log-Line "$count services down. :(" 
    Log-Break
    Log-Line $d 
}


}  #  <-----  End of Main





Function Query-Database ($q)
{
    Invoke-Sqlcmd -ServerInstance "Karmak_Internal" -Database "QA" -Query $q
}

Function Log-Line ($message)
{
    $message | Out-File $log -Append
}

Function Log-Error ($message)
{
    Log-Line "***ERROR***" 
    Log-Line $message 
    Log-Line "***********" 
}

Function Log-Break ()
{
    Log-Line "<br>"
    Log-Line "<br>"
}

Main