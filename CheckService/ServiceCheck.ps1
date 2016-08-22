Function Main
{
## Comment
$folder = Get-Location
$Global:log = "$folder\log.txt"
$count = 0
Get-Date | Out-File $log
    Try {
    $systemarr = Invoke-Sqlcmd -ServerInstance "Karmak_Internal" -Database "QA" -Query "Select SystemID from System Where IsActive = 1"
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
    $server = Invoke-Sqlcmd -ServerInstance "Karmak_Internal" -Database "QA" -Query "Select ServerName from SoftwareServer ss join System sy on sy.SoftwareServerID = ss.SoftwareServerID where sy.SystemID = $system"
    $servername = $server.ServerName
    $configarr = Invoke-Sqlcmd -ServerInstance "Karmak_Internal" -Database "QA" -Query "Select ServiceName from Service Where SystemID = $system"
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
                Log-Line $server 
                Log-Line $a 
                $count = $count + 1
            }
        }
}

$d = Get-Date
IF ($count -eq 0) {
    Log-Line "No services down. :)" 
    Log-Line $d 
} ELSE {
    Log-Line "$count services down. :(" 
    Log-Line $d 
}


}  #  <-----  End of Main

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

Main