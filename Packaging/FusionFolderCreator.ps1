## Fusion Distibution folder Creator

<# 

Adam Griffith

March, 2016

ToDo:

    Add Exclude parameter to Check-Copy so the Reports folder can exclude "Custom Reports"
    Add a Write-Host to acknowledge when steps begin

#>

## =================================================================================================================================================================

Function Main
{

## set log file
$folder = Get-Location
$Global:log = "$folder\log.txt"
$date = Get-Date
"Log started - $date" | Out-File $log

## define the build branch
$count = 0
$choices = "PM_3_Current", "PM_3_ServicePack"

Do{
cls
If ($count -gt 0) {Write-Host "Please select a valid option. Failed attempts:" $count}
$branch = Read-Host -Prompt "
    1- Current
    2- Service Pack
    Which branch are you releasing out of?"
    If ($branch -eq '1') {$branch = $choices[0]}
    If ($branch -eq '2') {$branch = $choices[1]}
Else {$count++}
} Until ($choices -contains $branch)

Log-Line "You have selected branch: $branch" 

## define the build branch folder
$build = "\\pmdevsql\Builds\$branch\Cumulative\*"

## define the distribution folder
$distro = "C:\DistroTest\Fusion\"
## $distro = "\\fp_server\Public\Distribution\ProfitMaster\3_0_0_0_Release\"



## define the previous version folder
Do{
$oldVersion = Read-Host -Prompt "
What is the OLD version number?"
} until ($oldVersion -ne "" )

## define the new version folder
Do{
$newVersion = Read-Host -Prompt "
What is the NEW version number?"
} until ($newVersion -ne "")

## define the copy from and copy to folders
$old = "$distro$oldVersion"
$new = "$distro$newVersion"

## test folders
$check = Test-Path $old
If ($check -ne $true) {
    Log-Line "***ERROR***" 
    Log-Line $_.Exception.Message 
    Log-Line "Cannot find the $old directory" 
    Exit
    }

$check = Test-Path $new
If ($check -ne $true) {
    Log-Line "***ERROR***" 
    Log-Line $_.Exception.Message 
    Log-Line "Cannot find the $new directory" 
    Exit
    }


## copy everything from the old version to the new version folder
Try {
    Log-Line "Creating new folder" 
    Copy-Item $old\ -Destination $new\ -Force -Recurse
    Log-Line "New folder created" 
}
Catch {
    Error-Exit
}

## delete all Service Pack and Database Script files
Try {
    Log-Line "Deleting all Service Pack and Database script files" 
    Remove-Item "$new\Service Pack Files\*" -Recurse
    Remove-Item "$new\Database Scripts\*" -Exclude *Help*
    Log-Line "Service Pack and Database Script files deleted" 
} 
Catch {
    Error-Exit
}

## copy from build drop to the Service Pack folder
Try {
    Log-Line "Copying build files into Distribution" 
    Copy-Item $build\ -Exclude *Analytics*, *ReportsMaster*, *PM_2_0_DB* -Destination "$new\Service Pack Files\" -Force -Recurse
}
Catch {
    Error-Exit
}

## move the Custom Reports folder out of Reports and into Service Pack Files
Try {
    Move-Item -Path "$new\Service Pack Files\Reports\Custom Reports" -Destination "$new\Service Pack Files\"
    Log-Line "Build files copied out to the Service Pack Files folder" 
}
Catch {
    Error-Exit
}


## copy from service pack to complete build

    Check-Copy "Client" "$new\Service Pack Files\Client\" "$new\Complete Build\Client\"

    Check-Copy "CommServer" "$new\Service Pack Files\CommServer\" "$new\Complete Build\CommServer\"

    Check-Copy "KarmakServices" "$new\Service Pack Files\KarmakServices\" "$new\Complete Build\KarmakServices\"

    Check-Copy "PrintServer" "$new\Service Pack Files\PrintServer\" "$new\Complete Build\PrintServer\"

    Check-Copy "Server" "$new\Service Pack Files\Server\" "$new\Complete Build\Server\"

    Check-Copy "TechnicianSuite" "$new\Service Pack Files\TechnicianSuite\" "$new\Complete Build\TechnicianSuite_Server\"

    Check-Copy "Reports" "$new\Service Pack Files\Reports\" "$new\Complete Build\Print Server\Reports\"

    Check-Copy "Custom Reports" "$new\Service Pack Files\Custom Reports\" "$new\Custom Reports\"

    Get-Date | Out-File $log -Append

    Log-Line "=== Fusion Packaging Complete ===" 

}   #  <-----  End of Main


## =================================================================================================================================================================


## FUNCTIONS

## Check for folder and copy
Function Check-Copy ($name, $from, $to)
{
$check = Test-Path "$from"
If ($check -eq "True")  
    {
    Log-Line "Updating $name" 
    Copy-Item "$from" -Destination "$to" -Recurse -Force
    Log-Line "$name has been updated" 
    }
If ($check -notmatch "True") {Write-Host "$name was skipped"}
}


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

## Errors
Function Error-Exit
{
    Log-Line "***ERROR***" 
    Log-Line $_.Exception.Message 
    Exit 
}

Main

