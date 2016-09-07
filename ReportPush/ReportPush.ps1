<#
    Report Push
    This will check a folder to see if any .RPT file exists.  If so it will deploy them to the print server folders.

    TODO: 
        Replace folder paths with variables that pull from the Karmak_Internal.QA database
        Add the needed variables to the Karmak_Internal.QA database

#>

Function Main
{

$folder = Get-Location
$Global:log = "$folder\ReportPush_log.txt"
"Starting log" | Out-File $log
$fPath = "\\qaserver4\D$\Builds\ReportPush\Future\Stop.txt", "\\qaserver2\ReportPush\Future\*.rpt"
$cPath = "\\qaserver4\D$\Builds\ReportPush\Current\Stop.txt", "\\qaserver2\ReportPush\Current\*.rpt"
$spPath = "\\qaserver4\D$\Builds\ReportPush\ServicePack\Stop.txt", "\\qaserver2\ReportPush\ServicePack\*.rpt" 

Report-Copy $fPath[0], $fPath[1]
Report-Copy $cPath[0], $cPath[1]
Report-Copy $spPath[0], $spPath[1]

}  # <-----  End of Main


Function Log-Line ($message)
{
    ## Make sure you define the log file variable in the Main function
    $message | Out-File $log -Append
}

Function Log-Error ($message)
{
    ## This function is dependent on the Log-Line function
    Log-Line "***ERROR***" 
    Log-Line $message 
    Log-Line "***********" 
}

Function Report-Copy($a, $b, $c)
{
    ## Decides if the report needs to be pushed or not
    If (Test-Path $a )
    {
        Log-Line "Stopping"
        EXIT
    }
    ElseIf (Test-Path $b)
    {
        Log-Line "Pushing reports"
        <# 
        TODO add code to stop print services and push the reports 
            
            ForEach branch in branches
            Look for all SystemIDs isActiveBuilds = 1 isActive = 1
            Save ReportPath and PrintServer service name and server

            ForEach ID in SysIDs
                Stop print server service
                ForEach rpt in reports
                    Copy rpt to folderpath
                Start print service service

        #>

        $sysIDs = Query-Database "Select SystemID from System Where IsActive = 1 and IsActiveBuilds = 1"

        ForEach($id in $sysIDs.SystemID)
        {
            $server = Query-Database "Select ServerName from SoftwareServer ss join System sy on sy.SoftwareServerID = ss.SoftwareServerID where sy.SystemID = $id"
            $servername = $server.ServerName
            $configarr = Query-Database "Select ServiceName from Service Where SystemID = $id and ServiceTypeID = 2"
            $servicename = $configarr.ServiceName
            $rptFolder = Query-Database "Select FolderPath from Folder where FolderTypeID = 2 and SystemID = $id"
            $foldername = $rptFolder.FolderPath

            <#
            Write-Host $servername
            Write-Host $servicename
            Write-Host $foldername
            #>

            If (!(Test-Path ($foldername))) {Write-Host "Invalid folder path: *** $foldername ***"}

        }
    }
    Else
    {
        Log-Line "No reports to push"
        EXIT
    }
}

Function Query-Database ($q)
{
    Invoke-Sqlcmd -ServerInstance "Karmak_Internal" -Database "QA" -Query $q
}

Main