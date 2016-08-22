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

If (Test-Path \\qaserver4\D$\Builds\ReportPush\Current\Stop.txt -IsValid) 
{
    Log-Line "Stopping"
    EXIT
}

If (Test-Path \\qaserver2\ReportPush\Current\ -Include "*.txt" -IsValid) 
{
    Log-Line "No reports to push"
    EXIT
}

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

Main