#usage:
#PS C:\> ADBulkGroup -GroupName Sales-INDIA,Sales-US,Sales-Singapore -GroupScope Global

#To reads group names from the c:\temp\groups.txt file and creates domainlocal security groups with these names:
#PS C:\> Invoke-ADBulkGroup -GroupName (Get-Content c:\temp\groups.txt) -GroupScope DomainLocal

#It first checks whether the group exists in Active Directory and then proceeds with creating it
Function ADBulkGroup {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)]
        [String[]]$GroupName,
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet("DomainLocal", "Global", "Universal")]
        [string]$GroupScope
    )
    #Change the value of $TargetOU variable to the DN of the path
    #where you want the groups to be created
    #If you leave it, it will create in default users container.

    $TargetOU = (Get-ADDomain).UsersContainer
    #$TargetOU = "OU=Prod1,DC=techibee,DC=ad"
    if (!([ADSI]::Exists("LDAP://$TargetOU"))) {
        Write-Warning "The given OU $TargetOU not found. Exiting"
        return
    }
    Foreach ($Group in $GroupName) {
        try {
            $GroupObj = Get-ADGroup -Identity $Group -EA Stop
            if ($GroupObj) {
                Write-Warning "$Group : Group already exists. Cannot create
    another with same name"
                Continue
            }
        }
        catch {
            try {
                New-ADGroup -Name $Group -GroupScope $GroupScope -EA Stop
                Write-Host "$Group : Successfully Created"
            }
            catch {
                Write-Warning "$Group : An error occurred during creation"
            }
        }
    }
}