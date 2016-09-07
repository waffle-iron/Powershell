<#

    SQL query function

    Use  -  Query-Database "Select Something From Table"

#>

Function Query-Database ($q)
{
    Invoke-Sqlcmd -ServerInstance "Karmak_Internal" -Database "QA" -Query $q
}