class employee {
    [string] $givenName
    [string] $surName
    
    ## Used for samAccountName, mailNickName et cetera
    [string] $userName 
    [string] $city
    [datetime] $employedSince
    [string] $displayName

    ## AzureAD/EntraID domain name (typically the email suffix)
    [string] $entraIDDomain 

    ## Hidden properties will not be displayed in default output
    [securestring]hidden $password  
        
    ## Method A: create local user account
    [void] createLocalUser() {
        if ($this.username -and $this.password) {
            $newLocalUserSplat = @{
                Name     = $this.userName
                FullName = "$($this.givenName) $($this.surname)"
                Password = $this.password
            }
            New-LocalUser @newLocalUserSplat 
        }   
    }

    ## Method B: create AD user account
    [void] createADUser() {
        if ($this.username -and $this.password ) {
            $newADUserSplat = @{
                Name                  = "$($this.givenName) $($this.surname)"
                GivenName             = $this.givenName
                Surname               = $this.surName
                SamAccountName        = $this.userName
                AccountPassword       = $this.password
                ChangePasswordAtLogon = $true
                Enabled               = $false
            }
            New-ADUser @newADUserSplat 
        }
    }   
    
    ## Method C: create AzureAD user account (legacy!)
    [void] createAzuerADUser() {
        if ($this.username -and $this.password ) {
            $pwProfile = ' ' # [Microsoft.Open.AzureAD.Model.PasswordProfile]::new()
            $pwProfile.Password = $this.showPlainTextPassword()
            $pwProfile.ForceChangePasswordNextLogin = $true
            if ($pwProfile) {
                $newAzureADUserSplat = @{
                    DisplayName       = "$($this.givenName) $($this.surname)"
                    UserPrincipalName = $this.userName + '@' + $this.entraIDDomain
                    MailNickName      = $this.userName
                    PasswordProfile   = $pwProfile
                    AccountEnabled    = $true
                    GivenName         = $this.givenName
                    Surname           = $this.surname
                }
                New-AzureADUser @newAzureADUserSplat
            }
        }
    }
        
    ## Method D: create EntraID user account (Microsoft.Graph)
    [void] createEntraIDUser() {
        if ($this.username -and $this.password ) {
            $pwProfile = @{
                'Password'                      = $this.showPlainTextPassword()
                'ForceChangePasswordNextSignIn' = $true 
            }
            if ($pwProfile) {
                $newMGUserSplat = @{
                    DisplayName       = "$($this.givenName) $($this.surname)"
                    UserPrincipalName = $this.userName + '@' + $this.entraIDDomain
                    MailNickName      = $this.userName
                    PasswordProfile   = $pwProfile
                    AccountEnabled    = $true
                    GivenName         = $this.givenName
                    Surname           = $this.surname
                }
                New-MGUser @newMGUserSplat
            }
        }
    }

    ## Method E: convert PW to plain text
    [string] showPlainTextPassword() {        
        if ($this.password) {
            $netCredential = [System.Net.NetworkCredential]::new($null, $this.password)                        
            return $netCredential.Password        
        }
        else { 
            return $null
        }        
    }

    ## Constructor 1 (testing)
    employee() {            
    }

    ## Constructor 2 (provide mandatory properties)
    employee([string] $givenName, [string] $surname, [string] $entraIDDomain, [securestring] $password) {        
        $this.givenName = $givenName
        $this.surName = $surname
        $this.password = $password
        $this.entraIDDomain = $entraIDDomain
        $this.userName = $this.surName.Substring(0, 4) + $this.givenName.Substring(0, 1)   
        $this.displayName = "$($this.givenName) $($this.surname)" 
    }
}

class apprentice:employee {
    [string] $mentor
    [string] $college
    [DateTime] $educationStart
    [DateTime] $educationEnd

    ## Constructor 1
    apprentice() {                
    }

    ## Constructor 2
    apprentice([string] $givenName, [string] $surname, [string] $entraIDDomain, [securestring] $password, [string] $mentor) {        
        $this.givenName = $givenName
        $this.surName = $surname
        $this.password = $password
        $this.entraIDDomain = $entraIDDomain
        $this.mentor = $mentor   
        $this.username = $this.surName.Substring(0, 4) + $this.givenName.Substring(0, 1)    
        $this.displayName = "$($this.givenName) $($this.surname)"         
    }
} 

## Testing
[employee]::new()

## Create new employee object
$password = ConvertTo-SecureString -AsPlainText -Force -String 'Pa$$w0rd'
$newEmployee = [employee]::new('Jen', 'Barber', 'butz.io', $password)
$newEmployee.showPlainTextPassword()

## Create new apprentice object
$newApprentice = [apprentice]::new('Maurice', 'Moss', 'butz.io', $password, 'BarbJ')
$newApprentice.showPlainTextPassword()

## A local users
$newEmployee.createLocalUser()
Get-LocalUser -Name 'BarbJ' | Remove-LocalUser

## B
Get-ADUser -Identity BarbJ | Remove-ADUser 
$newEmployee.createADUser()

## C
$newEmployee.createAzuerADUser()
Get-AzureADUser -SearchString 'jen' | Remove-AzureADUser

## D
$newEmployee.createEntraIDUser()
$searchResult = Get-MgUser -ConsistencyLevel eventual -Search '"DisplayName:Jen Barber"' 
Remove-MgUser -UserId $searchResult.id

$newApprentice.createEntraIDUser()
$newApprentice.city = 'London'
$newApprentice.employedSince = $newApprentice.educationStart = Get-Date -Date '2006-02-03'
$newApprentice.educationEnd = $newApprentice.educationStart.AddYears(3)
$newApprentice.college = "St Catharine's College"

$searchResult = Get-MgUser -ConsistencyLevel eventual -Search '"DisplayName:Maurice Moss"' 
Remove-MgUser -UserId $searchResult.id