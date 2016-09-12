## Fusion Report Writer Distirbution folder creator

<#

Adam Griffith

March, 2016

ToDo:
        

#>

## =================================================================================================================================================================

## FUNCTIONS

## Logging function
function Log-Line ($message, $logfile)
{
    Write-Host $message
    $message | Out-File $logfile
}

fuction Error-Exit
{
    Log-Line "***ERROR***" $log
    Log-Line $_.Exception.Message $log
    Error-Exit 
}


## =================================================================================================================================================================

## set log file
$log = Get-Location
$log = "$log\log.txt"

## define the build branch
$count = 0
$choices = "PM_3_Current", "PM_3_ServicePack"
Do {
cls
If ($count -gt 0) {Write-Host "Please select a valid option. Failed attempts:" $count}
$branch = Read-Host -Prompt "
    1- Current
    2- Service Pack
    Which branch are you releasing out of?"
    IF ($branch -eq '1') {$branch = $choices[0]}
    IF ($branch -eq '2') {$branch = $choices[1]}
    IF ($branch -eq 'exit') {Exit}
Else {$count++}
} until ($choices -contains $branch)

Write-Host "You have selected branch: "$branch

## define the build branch folder
$build = "\\pmdevsql\Builds\$branch\Cumulative\Analytics\FusionSelfService\"

## define the distribution folder
$distro = "C:\DistroTest\FRW\"
## $distro = "\\fp_server\Public\Distribution\FusionReportWriter\"

## =================================================================================================================================================================

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

Try {

    ## create the new version folder
    new-item $distro -name "$newVersion" -type directory

    ## define the copy from and copy to folders
    $old = "$distro$oldVersion\"
    $new = "$distro$newVersion\"
    
    ## create the new folder structure
    Write-Host "Creating folders"
    new-item -path $new -name "Complete Build" -type directory
    new-item -path $new -name "Cumulative" -type directory
    new-item -path $new -name "Service Pack" -type directory
    Write-Host "Folders created"

    ## copy the complete build folder to the new version folder
    Write-Host "Copying Complete Build"
    Copy-Item "$old\Complete Build" -Destination "$new" -Force -Recurse -ErrorVariable e
    Write-Host $e
    $e | Out-File $log
    Write-Host "Finished copying Complete Build"

    Write-Host "Copying Cumulative"
    Copy-Item "$old\Cumulative" -Destination "$new" -Force -Recurse -ErrorVariable e
    Write-Host $e
    $e | Out-File $log
    Write-Host "Finished copying Cumulative"

    Write-Host "Copying Service Pack"
    Copy-Item "$build\*" -Destination "$new\Service Pack" -Force -Recurse -ErrorVariable e
    Write-Host $e
    $e | Out-File $log
    Write-Host "Finished copying Service Pack"

}
Catch {

    Error-Exit
}

## =================================================================================================================================================================