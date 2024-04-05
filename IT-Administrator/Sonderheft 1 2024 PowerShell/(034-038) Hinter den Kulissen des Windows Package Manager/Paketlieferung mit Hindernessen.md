# IT-Administrator: Sonderheft I/2024 PowerShell



## Paketlieferung mit Hindernissen  (Hinter den Kulissen des Windows Package Manager)



1993 stellte Microsoft mit Windows NT eine neue Betriebssystemfamilie vor, deren Nachfahren sich bis heute großer Popularität erfreuen. Umso überraschender, dass Microsoft es in all den Jahren nicht geschafft hat, ein Werkzeug zu integrieren, das auf einfache Weise Installation, Aktualisierung und Dein-
stallation von Software, Betriebssystem und Treibern ermöglicht – obgleich es durchaus Ansätze in diese Richtung gab. Mit dem Windows Package Manager änderte sich dies endlich im Jahr 2020. Wir werfen einen Blick auf das praktische Tool.



### Link Codes im Artikel

[1] Installation der PowerShell (os11h)

https://learn.microsoft.com/de-de/powershell/scripting/install/installing-powershell

[2] Windows-PowerShell-Kompatibilität (os11i)

https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_windows_powershell_compatibility

[3] Cloud Shell in VSCode einbinden (os11j)
https://www.geeksforgeeks.org/microsoft-azure-add-azure-cloud-shell-to-vs-code/



**Listing Seite 34: Manifest für Notepad++ v8.6** (Auszug) 

Quelle: https://github.com/microsoft/winget-pkgs/tree/master/manifests/n/Notepad%2B%2B/Notepad%2B%2B/8.6

```yaml
PackageIdentifier: Notepad++.Notepad++
PackageVersion: "8.6"
InstallerType: nullsoft
Scope: machine
InstallModes:
- interactive
- silent
UpgradeBehavior: install
ElevationRequirement: elevatesSelf
Installers:
- Architecture: x86
  InstallerUrl: https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.6/npp.8.6.Installer.exe
  InstallerSha256: 40A7F4E73F670B5D620096115886D1931AA36E3DAA70735FC5BAD3041C3730D5
  AppsAndFeaturesEntries:
  - DisplayName: Notepad++ (32-bit x86)
[..]
ManifestType: installer
ManifestVersion: 1.5.0
```



**Seite 34/35: Long vs short options**

```powershell
## Lange Notation (long options)
winget install --id  Notepad++.Notepad++ --exact --source winget
## Kurze Notation (short options)
winget install Notepad++.Notepad++ -e -s winget
```



**Seite 35/36: Store vs Manifest**

```powershell
winget search Brave
winget install --id XP8C9QZMS2PC1T --source msstore
winget install --id Brave.Brave --source winget   ## Alternativ: Brave.Brave.Nightly 
```



**Listing 1, Seite 35: WinGet Argument Completer**

Quelle: https://github.com/microsoft/winget-cli/blob/master/doc/Completion.md

```powershell
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}
```



**Listing 2, Seite 36: Manifest für Brave 120.1.61.114** (Auszug)
Quelle: https://github.com/microsoft/winget-pkgs/blob/master/manifests/b/Brave/Brave/120.1.61.114/Brave.Brave.installer.yaml

```yaml
Installers:
[..]
- Architecture: x64
  Scope: user
  InstallerUrl: https://updates-cdn.bravesoftware.com/build/Brave-Release/x64-rel/win/120.1.61.114/brave_installer-x64.exe
  InstallerSha256: C0233BC92B512126CF985DDA4E7BBC552C87CA80F4FA344E8474A2B8EF3D2DE5
  InstallerSwitches:
    Custom: --do-not-launch-chrome
  ProductCode: BraveSoftware Brave-Browser
- Architecture: x64
  Scope: machine
  InstallerUrl: https://updates-cdn.bravesoftware.com/build/Brave-Release/x64-rel/win/120.1.61.114/brave_installer-x64.exe
  InstallerSha256: C0233BC92B512126CF985DDA4E7BBC552C87CA80F4FA344E8474A2B8EF3D2DE5
  InstallerSwitches:
    Custom: --do-not-launch-chrome --system-level
  ProductCode: BraveSoftware Brave-Browser
```



**Seite 36: fsutil zeigt AppExecAlias**

```
fsutil reparsepoint query "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
```



**Seite 36: Pinning**

```powershell
## Installation einer spezifischen Versioon
winget install --id Microsoft.PowerShell --version 7.1.5

## Blockieren eines möglichen Updates: "Pinning"
winget pin add --id Microsoft.PowerShell --version 7.1.5

## Reguläre Updates bleiben erfolglos für Anwendungen mit einem "Pin"
winget upgrade --id Microsoft.PowerShell
winget upgrade --all

## .. außer, Sie erzwingen das Update
winget upgrade --id Microsoft.PowerShell --force

## WinGet UI nachrüsten
winget install --id SomePythonThings.WingetUIStore
```



**Seite 36, Listing 3: Konfigurationsdatei settings.json**
https://github.com/microsoft/winget-cli/blob/master/doc/Settings.md

```json
{
    "$schema": "https://aka.ms/winget-settings.schema.json",
       "installBehavior": {
        "preferences": {
            "scope": "user"
        }
    }
}
```



**Seite 37: Erste Schritte mit dem WinGet.Client-Modul**

```powershell
## Bereitstellen des Moduls
Find-Module -Name *WinGet*
Install-Module -Name 'Microsoft.WinGet.Client' 
Get-Module -Name  'Microsoft.WinGet.Client' -ListAvailable
Get-Command -Module 'Microsoft.WinGet.Client'

## Erste Schritte: Suchen und finden
Get-WinGetSource # winget source list

## Alle verfügbaren Browser im Store finden
Find-WinGetPackage -Tag browser -Source msstore # winget search --tag browser --source msstore

## Alle installierten Browser aus der Quelle Store finden
Get-WinGetPackage -Tag browser -Source msstore # winget list --tag browser --source msstore
```



**Seite 37, Listing 4: WinGet-Cmdlets**

```powershell
## Installieren
Get-WinGetPackage -Moniker vscode
Find-WinGetPackage -Moniker vscode
Install-WinGetPackage -Id  Microsoft.VisualStudioCode.Insiders -Scope Syst

## Installation mittels Pipelining
Find-WinGetPackage -Name 'Mozilla' -source msstore | Install-WinGetPackage
Find-WinGetPackage -Name 'Mozilla' -source winget | Install-WinGetPackage -Scope System
```



**Seite 37, Listing 5:  Fehlerhafte Cmdlets** 

```powershell
## Cmdlets mit Pluralformen, die Hash-Tabellen ausgeben anstelle von PowerShell-Objekten
Get-WinGetSettings 
Get-WinGetUserSettings

## Eine spezifische Einstellung abfragen
(Get-WinGetSettings).adminSettings.InstallerHashOverride
(Get-WinGetUserSettings).visual.progressBar

## Eine spezifische Einstellung aktivieren/deaktivieren
Enable-WinGetSetting -Name InstallerHashOverride
Disable-WinGetSetting -Name InstallerHashOverride

Set-WinGetUserSettings -UserSettings  @{
    'installBehavior' = @{preferences = @{scope='machine'}}
    'visual'          = @{progressBar = 'rainbow'}
    'telemtry'        = @{disable = 'true'}
}
```



**Seite 38, Listing 6: TaskbarAlignment.dsc.yaml**

```yaml
properties:
  assertions:
    - resource:  Microsoft.Windows.Developer/OSVersion
      directives:
        description: Verifiy minimum OS version
        allowPrerelease: true
      settings:
        MinVersion: '10.0.22000'  ## Windows 11 (21H2)
  resources:
    - resource: Microsoft.Windows.Developer/TaskBarAlignment
      directives:
        description: Set taskbar alignment to left
        allowPrerelease: true
      settings:
        Alignment: Left 
  configurationVersion: 0.1.0
```



**Seite 38: Die Konfiguration anwenden**

```powershell
winget configuration .\TaskbarAlignment.dsc.yaml  --accept-configuration-agreements
```

 