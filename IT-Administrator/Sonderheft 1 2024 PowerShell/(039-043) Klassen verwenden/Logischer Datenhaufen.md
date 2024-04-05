# IT-Administrator: Sonderheft I/2024 PowerShell



## Logischer Datenhaufen (Klassen verwenden)



Bei den ersten Gehversuchen mit der PowerShell stolpern User schnell über den Begriff der Objekt-
orientierung, was wiederum zur Nutzung von Klassen führt. Es braucht in aller Regel ein wenig
Zeit, bis wirklich klar ist, was dieser Ansatz für die Praxis bedeutet. In diesem Beitrag betrachten
wir ein Beispiel hierzu und zeigen so auf, was es mit Klassen in der PowerShell auf sich hat.



**Seite 39: whoami.exe**

```powershell
## Die eigenen Gruppenmitgliedschaften ermitteln
whoami /groups

## Strukturierte Daten erzeugen
whoami /groups /fo csv | ConvertFrom-Csv | where Type -ne 'Well-known group'
whoami /groups /fo csv | ConvertFrom-Csv | where 'Group Name' -like '*Administrators'

```



**Seite 39: Alles ist ein Objekt**

```powershell
$givenName = 'Jen'
$surName = 'Barber'
$userName = $surName.Substring(0,4) + $givenName.Substring(0,1)
$userName  ## Ausgabe: BarbJ
$userName.length  ## Ausgabe: 4
```



**Seite 40: Hash table**

```powershell
$user = @{
    $givenName = 'Jen'
    $surname = 'Barber'
    $city = 'London'
}
$user.givenName ## Ausgabe: Jen
```



**Seite 40: Eigene Objekte erzeugen**

```powershell
## A: New-Object
$user = New-Object -TypeName 'PSObject' ## Seit PS v3 auch: New-Object -TypeName PSCustomObject
$user | Add-Member -Name 'givenName' -MemberType NoteProperty -Value 'Jen'
$user | Add-Member -Name 'surName' -MemberType NoteProperty -Value 'Barber'
$user | Add-Member -Name 'city' -MemberType NoteProperty -Value 'London'
$user | Add-Member -Name 'birthday' -MemberType NoteProperty -Value (Get-Date -Date '1910-06-22')

## B: PSCustomObject, seit PowerShell 3
$user = [PSCustomObject] @{
    'givenName' = 'Jen'
    'surName' = 'Barber'
    'city' = 'London'
    'birthday' = Get-Date -Date '1978-03-09'    
}
```

 

**Seite 40, Listing 1: Get-LocalUser**

```powershell
$localusers = Get-LocalUser  
$localusers | Add-Member -MemberType NoteProperty 'Computername' -Value $env:COMPUTERNAME 
$localusers | Select-Object -Property 'Name','Enabled','Computername'

## Ausgabe:
Name               Enabled Computername
----               ------- ------------
Administrator         True pc1
Jen                   True pc1
DefaultAccount       False pc1
Guest                False pc1
WDAGUtilityAccount   False pc1

$localusers | Get-Member 

## Ausgabe:
   TypeName: Microsoft.PowerShell.Commands.LocalUser
   
Name                   MemberType   Definition
----                   ----------   ----------
Clone                  Method       Microsoft.PowerShell.Commands.LocalUser Clone()
Equals                 Method       bool Equals(System.Object obj)
GetHashCode            Method       int GetHashCode()
GetType                Method       type GetType()
ToString               Method       string ToString()
Computername           NoteProperty string Computername=pc1
AccountExpires         Property     System.Nullable[datetime] AccountExpires {get;set;}
Description            Property     string Description {get;set;}
Enabled                Property     bool Enabled {get;set;}
FullName               Property     string FullName {get;set;}
LastLogon              Property     System.Nullable[datetime] LastLogon {get;set;}
Name                   Property     string Name {get;set;}
ObjectClass            Property     string ObjectClass {get;set;}
PasswordChangeableDate Property     System.Nullable[datetime] PasswordChangeableDate {get;set;}
PasswordExpires        Property     System.Nullable[datetime] PasswordExpires {get;set;}
PasswordLastSet        Property     System.Nullable[datetime] PasswordLastSet {get;set;}
PasswordRequired       Property     bool PasswordRequired {get;set;}
```



**Seite 41, Listing 2: Splatting**

```powershell
$addMemberSplat = @{
    MemberType = 'ScriptProperty'
    Name = 'LastLogonElapsedDays'
    Value = {[int] ((Get-Date) - $this.lastlogon).TotalDays}
}
## Main
$localusers = Get-LocalUser 
$localusers | Add-Member @addMemberSplat
$localusers | Select-Object -Property Name,Enabled,LastLogonElapsedDays

## Ausgabe:
Name               Enabled LastLogonElapsedDays
----               ------- --------------------
Administrator         True                    2
Jen                   True                    7
DefaultAccount       False                     
Guest                False                     
WDAGUtilityAccount   False                     
```



**Seite 41: Eigene Klassen erstellen**

```powershell
## Klassen und Eigenschaften
class employee {
    [string] $givenName
    [string] $surName
    [string] $city
    [datetime] $employedSince
}

$newEmployee = New-Object -TypeName 'employee' ## [employee]::new()
$newEmployee.givenName = 'Jen'
$newEmployee.surName = 'Barber'
$newEmployee.employedSince = Get-Date

## Get-Member
$newEmployee | Get-Member

```



**Seite 41: Klassen, Eigenschaften und Methoden**

```powershell
class employee {
	## Eigenschaften
    [string] $givenName
    [string] $surName
    [string] $city
    [datetime] $employedSince

	## Methode
	[string] showFullName() {
	    return "$($this.givenName) $($this.surName)"
	}    

}
$newEmployee = [employee]::new()
$newEmployee.givenName = 'Jen'
$newEmployee.surName = 'Barber'
$newEmployee.showFullName() ## Ausgabe: Jen Barber
```



**Seite 41: Methode(n) ohne Rückgabewert**

```powershell
class employee {
    ## Eigenschaften
    [string] $givenName
    [string] $surName
    [string] $city
    [datetime] $employedSince
    
    ## Methode ohne Rückgabewert
    [void] createLocalUser() {        
        $newLocalUserSplat = @{
            Name     = $this.surname.Substring(0,4) + $this.givenName.Substring(0,1)            
            FullName = "$($this.givenName) $($this.surname)"
            NoPassword = $true
        }
        New-LocalUser @newLocalUserSplat
    }    
}
$newEmployee = [employee]::new()
$newEmployee.givenName = 'Jen'
$newEmployee.surName = 'Barber'
$newEmployee.createLocalUser()
```



**Seite 42: Konstruktor(en)**

```powershell
class employee {
    ## Eigenschaften
    [string] $givenName
    [string] $surName
    [string] $userName  ## Neu
    [string] $city
    [datetime] $employedSince
    
    ## Methode
    [void] createLocalUser() {        
        $newLocalUserSplat = @{
            Name     = $this.surname.Substring(0,4) + $this.givenName.Substring(0,1)            
            FullName = "$($this.givenName) $($this.surname)"
            NoPassword = $true
        }
        New-LocalUser @newLocalUserSplat
    }    

    ## Konstruktor
    employee($givenName,$surname) {        
        $this.givenName = $givenName
        $this.surName = $surname
        $this.userName = $this.surName.Substring(0,4) + $this.givenName.Substring(0,1) 
    }
}

## new Employee
[employee]::new('Jen','Barber')

## Alternative Schreibweise
New-Object -TypeName employee -ArgumentList 'Jen','Barber'
```



**Seite 42: Overloading**

```powershell
class employee {
    [..] 
    
    ## Konstruktor 1
    employee() {                
    }
    ## Konstruktor 2 
    employee([string] $givenName, [string] $surname) {        
        $this.givenName = $givenName
        $this.surName = $surname
        $this.userName = $this.surName.Substring(0,4) + $this.givenName.Substring(0,1) 
    }
}
## Ermitteln der OverloadDefinitions
[employee]::new

## Ausgabe:
OverloadDefinitions
-------------------
employee new()
employee new(string givenName, string surname)
```



**Seite 42: Vererbung**

```powershell
class apprentice:employee {
    [string] $mentor
    [string] $college
    [DateTime] $educationStart
    [DateTime] $educationEnd

    ## Constructor 1
    apprentice() {                
    }

    ## Constructor 2
    apprentice([string] $givenName, [string] $surname, [string] $mentor) {        
        $this.givenName = $givenName
        $this.surName = $surname
        $this.mentor = $mentor   
		$this.username = $this.surName.Substring(0, 4) + $this.givenName.Substring(0, 1)     
    }
} 
## Neues Objekt der untergeordneten Klasse erzeugen
[apprentice]::new('Maurice','Moss','BarbJ')
## Methoden der übergeordneten Klasse werden vererbt
$newApprentice.createLocalUser()
```



**Seite 43, Listing 2: Mitarbeiterkonten**

```powershell
#Requires -Modules 'Microsoft.PowerShell.LocalAccounts','ActiveDirectory','Microsoft.Graph'
#Requires -Version 5.1

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
        
    ## Method C: create EntraID user account (Microsoft.Graph)
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

    ## Method D: convert PW to plain text
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

## Testing: stripped-down object
[employee]::new()

## Create new employee object
$password = ConvertTo-SecureString -AsPlainText -Force -String 'Pa$$w0rd'
$newEmployee = [employee]::new('Jen', 'Barber', 'reynholm.co.uk', $password)
$newEmployee.showPlainTextPassword()

## Create new apprentice object
$newApprentice = [apprentice]::new('Maurice', 'Moss', 'reynholm.co.uk', $password, 'BarbJ') 
$newApprentice.showPlainTextPassword()

## Create new accounts (employee)
$newEmployee.createLocalUser()   ## New local user
$newEmployee.createADUser()      ## New AD user
$newEmployee.createEntraIDUser() ## New EntraID user

## Create a new apprentice object with optional properties
$newApprentice.city = 'London'
$newApprentice.employedSince = $newApprentice.educationStart = Get-Date -Date '2006-02-03'
$newApprentice.educationEnd = $newApprentice.educationStart.AddYears(3)
$newApprentice.college = "St Catharine's College"

## Create new accounts (Apprentice)
$newApprentice.createLocalUser()
$newApprentice.createADUser()
$newApprentice.createEntraIDUser()
```

