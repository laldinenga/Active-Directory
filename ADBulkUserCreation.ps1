#Invoke ADBulkUserCreation.ps1

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateScript({ Test-Path $_ })]
    [string[]]$CSVFilePath
)
try {
    $CSVData = @(Import-CSV -Path $CSVFilePath -EA Stop)
    Write-Host "Successfully imported entries from $CSVFilePath"
    Write-Host "Total no. of entries in CSV are :
$($CSVData.count)"
}
catch {
    Write-Host "Failed to read from the CSV file $CSVFilePath.
Script exiting"
    return
}
foreach ($Entry in $CSVData) {
    #Verify that mandatory properties are defined for each object
    $Name = $Entry.Name
    $SamAccountName = $Entry.SAMAccountName
    $GivenName = $Entry.GivenName
    $SurName = $Entry.LastName
    $Email = $Entry.Email
    $StreetAddress = $Entry.Address
    $City = $Entry.City
    $Country = $Entry.Country
    $State = $Entry.State
    $Company = $Entry.Company
    $EmployeeID = $Entry.EmployeeID
    $Path = $Entry.OUName
    $Password = "Randompwd1$"
    if (!$Name) {
        Write-Warning "$Name is not provided. Continue to the next record"
        Continue
    }
    if (!$SamAccountName) {
        Write-Warning "$SamAccountName is not provided. Continue to the next record"
        Continue
    }
    if ($Country.Length -ne 2) {
        Write-Warning "Country code should be of 2 characters only. Setting it to US for now"
        $Country = "US"
    }
    try {
        New-ADUser -Name $Name `
            -SamAccountName $SamAccountName `
            -GivenName $GivenName `
            -Surname $SurName `
            -EmailAddress $Email `
            -AccountPassword (ConvertTo-SecureString -String $Password -AsPlainText -Force) `
            -StreetAddress $StreetAddress `
            -City $City `
            -State $State `
            -Country $Country `
            -Company $Company `
            -EmployeeID $EmployeeID `
            -Enabled $false `
            -Path $Path
        Write-host "$Name : User Account created successfully"
    } catch {
        Write-Warning "$Name : Error occurred while creating account. $_"
    }
}
