# IT-Administrator: Sonderheft I/2024 PowerShell

## Codelistings zum Artikel: Neue Zahl, neues Glück? (Neuerungen in PowerShell 7)

Vor knapp 18 Jahren erblickte die PowerShell das Licht der Welt und ist seither gereift.
Vor sechs Jahren brachte Microsoft dann die erste Fassung einer neu entwickelten, plattform-
übergreifenden PowerShell heraus – irreführenderweise als Version 6, denn im Grunde genommen
war diese erste Version nach dem Neustart mehr eine Technologiedemo. Welche interessanten
Neuerungen im aktuellen 7er-Release auf Admins warten und wo die Unterschiede zum
Vorgänger liegen, beleuchtet dieser Beitrag.

### Link Codes in diesem Artikel

[1] Installation der PowerShell (os11h)

https://learn.microsoft.com/de-de/powershell/scripting/install/installing-powershell

[2] Windows-PowerShell-Kompatibilität (os11i)

https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_windows_powershell_compatibility

[3] Cloud Shell in VSCode einbinden (os11j)

https://www.geeksforgeeks.org/microsoft-azure-add-azure-cloud-shell-to-vs-code/



**Listing Seite 9: Prozesse und Netzwerkadapter**

```powershell
## Beispiel "Prozesse"

[System.Diagnostics.Process]::GetProcessesByName('powershell')  ## Windows PowerShell  
Get-Process -name 'Powershell'

[System.Diagnostics.Process]::GetProcessesByName('pwsh')  ## PowerShell 6 ff
Get-Process -name 'pwsh'

## Beispiel "Netzadapter"
wmic /namespace:\\root\StandardCimv2 path msft_netadapter get /value
Get-CimInstance -Namespace 'root/StandardCimv2' -ClassName 'MSFT_NetAdapter'
Get-NetAdapter
```



**Listing Seite 9: Installation PwSh**

```powershell
## Beispielinstallation via HomeBrew (macOS)
brew install powershell/tap/powershell

## Manuelle Installation (macOS,Apple Silicon)
curl https://github.com/ PowerShell/PowerShell/releases/download/v7.4.0/powershell-7.4.0-osx-arm64.pkg -o powershell-7.4.0-osx-arm64.pkg
sudo installer -pkg ./powershell-7.4.0-osx-arm64.pkg -target /

## Ausgabe der PowerShell-Version (siehe Bild 1)
$PSVersionTable
```



**Listing Seite 9: Local accouns**

```powershell
## Microsoft.PowerShell.LocalAccounts
Get-Command -Name Get-LocalUser
Get-Command -Module Microsoft.PowerShell.LocalAccounts
Get-Module -ListAvailable -Name Microsoft.PowerShell.LocalAccounts | Select-Object -Property ModuleBase
```



**Listing Seite 10: Cmdlets, Module, PSModulePath**

```powershell
## Bild 2: Die Umgebungsvariable PSModulePath
$env:PSModulePath
$env:PSModulePath.Split(';') ## in lesbarer Form als Liste

## "Native" PowerShell 7-Cmdlets ermitteln
$modules = Get-Module -ListAvailable | Where-Object -FilterScript { $_.path -like "$pshome*" } 
Get-Command | Where-Object -FilterScript { $_.Source -in $modules.name } | Sort-Object -Property Name | Get-Unique | Measure-Object

## Ein Modul nachrüsten am Beispiel von ImportExcel (https://www.powershellgallery.com/packages/ImportExcel/)
Find-Module -Name ImportExcel | Install-Module
Get-Module -ListAvailable -Name ImportExcel | Select-Object -Property ModuleBase

## Laden des Benutzerprofils mittels "dot sourcing"
. .\$home\Documents\myprofile.ps

## Eine Verzeichnisverbindung / Junction erstellen
New-Item -ItemType Junction -path "$home\Documents\PowerShell" -Value "$home\Documents\WindowsPowerShell"
```



**Listing Seite 11: Benutzerprofile, Pfade**

```powershell
## Bild 3: Benutzerprofile ermitteln
## Alle Profildateien müssen expliziert erstellt werden

$PROFILE.AllUsersAllHosts | Test-Path
$PROFILE.AllUsersCurrentHost | Test-Path
$PROFILE.CurrentUserAllHosts | Test-Path
$PROFILE.CurrentUserCurrentHost | Test-Path

```



**Listing Seite 11: Interessante Neuerungen**

```powershell
## Verbindungstest mittels ICMP echo request und TCP port scan
## Variante A: Pipeling (nur PowerShell 7)
Get-Content -Path .\computers.txt -Delimiter ',' | Test-Connection -Count 1
Get-Content -Path .\computers.txt -Delimiter ',' | Test-Connection -TcpPort 3389


## Variante B: die kompatbile Variante (Windows PowerShell 7 und PowerShell 7)
Test-Connection -ComputerName (Get-Content -Path 'computers.txt').split(',') -Count 1
(Get-Content -Path 'computers.txt').split(',') | Test-NetConnection -Port 3389

## Nebenläufige Ausführung in PowerShell 7
1..10 | ForEach-Object -Parallel { Start-Sleep -Seconds 1 }

Start-ThreadJob -ScriptBlock {
    Start-Sleep -Seconds 1
    'Finished!'
}
Get-Job | Wait-Job | Receive-Job

Import-Module -Name 'C:\Program Files\PowerShell\7\Modules\ThreadJob'

## Remoting mittels SSH
Invoke-Command -HostName lin-sv1 -UserName Linus
```



**Listing Seite 11: Splatting**

```powershell
## Bild 6: Splatting in VSCode

Find-Module -Name EditorServicesCommandSuite
Install-Module -Name EditorServicesCommandSuite -AllowPrerelease -RequiredVersion 1.0.0-beta4
Import-CommandSuite ## Command Palette => Show additional commands from PowerShell: Splat Command

## Example command (before splatting)
Test-Connection -TargetName dns.google -TimeoutSeconds 1 -Count 2

## Example command (splatted)
$testConnectionSplat = @{
  TargetName     = 'dns.google'
  TimeoutSeconds = 1
  Count          = 2
}
Test-Connection @testConnectionSplat
```



**Listing Seite 11: Remoting**

```powershell
## Remoting
$cred = Get-Credential
Test-WSMan -ComputerName win-dc1 -Authentication Kerberos -Credential $cred
$PSSession = New-PSSession -ComputerName win-dc1 -Credential $cred ## Fan out

Invoke-Command -Session $PSSession -ScriptBlock {
  hostname
  whoami
  $PSVersionTable.PSVersion.ToString()
}

## Implicit remoting
$proxyCmdlets = Import-PSSession -Session $pssession -Module ActiveDirectory 
Get-ADDomain

## Exportieren des Proxy-Moduls zur späteren Verwendung
Export-PSSession -OutputModule ActiveDirectory -Session $PSSession -Module ActiveDirectory -AllowClobber

## Fehler in PowerShell 7.4
New-LocalUser -Name 'Jeffrey' -NoPassword

```



**Listing Seite 11: VSCode installieren**

```powershell
## Eine von vielen möglichen Installationswegen zu VSCode
$uri = 'https://update.code.visualstudio.com/latest/win32-x64/stable'
Invoke-WebRequest -UseBasicParsing -Uri $uri -OutFile 'VSCodeSetup-x64.exe' 
$args = '/verysilent /tasks=addcontextmenufiles,addcontextmenufolders,addtopath'
Start-Process -FilePath 'VSCodeSetup-x64.exe' -Argument-List $args -Wait
```

