Function Log-Line ($message)
{
    <# Make sure you define the log file variable in the Main function
        $folder = Get-Location
        $Global:log = "$folder\log.txt"
        $date = Get-Date
        "Log started - $date" | Out-File $log
    #>
    $message | Out-File $log -Append
}

Function Log-Error ($message)
{
    ## This function is dependent on the Log-Line function
    Log-Line "***ERROR***" 
    Log-Line $message 
    Log-Line "***********" 
}

Function New-Function
{

    ## NEW CODE

}

