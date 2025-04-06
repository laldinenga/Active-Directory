#Usage
# Nested level:
# PS C:\> Find-EmptyADGroups -Nested

#Without any direct members:
# PS C:\> Find-EmptyADGroups

Function Find-EmptyADGroups {
    [CmdletBinding()]
    Param(
    [switch]$Nested
    )
    $Groups = Get-ADGroup -Filter *
    Write-Host "`nBelow is the list of empty groups in Active
    Directory`n`n"
    $Count = 0
    foreach($Group in $Groups) {
    $Members = Get-ADGroupMember -Identity $Group -Recursive:$Nested
    if(!$Members) {
    $Group | Select-Object Name, DistinguishedName
    $Count++
    }
    }
    Write-Host "`n`n`nTotal no. of empty groups are : $Count`n`n`n"
    }