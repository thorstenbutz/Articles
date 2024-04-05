# IT-Administrator: Sonderheft I/2024 PowerShell



## sKIripting mit Köpfchen (PowerShell mit KI aufpeppen)



2023 wird als das Jahr in die Geschichte eingehen, in der jahrzehntelange Fortschritte in der Forschung zur künstlichen Intelligenz mit einem Quantensprung sichtbar wurden. Doch was bedeutet das für dir IT? Werden Programmier- und Scripting-Kenntnisse nun
zweitrangig? Wir werfen in diesem Beitrag einen Blick auf KI-gestützte Ansätze im Kontext der PowerShell und zeigen dabei die Grenzen der heute  möglichen Verfahren auf.

 

### Link Codes im Artikel

 [1] Microsoft Copilot (os14a)

https://copilot.microsoft.com

 

[2] ChatGPT: RegEx für Postleitzahlen (os14b)

https://chat.openai.com/share/946b6b4f-1777-485c-b6bf-58014802dbbf

ð Könnt Ihr bitte den Titel für den Link Code ändern in: „RegEx für Postleitzahlen“
 Ich schicke Euch asap einen anderen Link, solange könnt Ihr den oben behalten. Das muss ich aber noch vorbereiten, da bin ich leider noch nicht zu gekommen., 

 

[3] GitHub Copilot (napc)

https://github.com/features/copilot



**Seite 174, Listing 1: Fibonacci-Ausgabe mit ChatGPT4 **

```powershell
function Get-Fibonacci {
    param (
        [int]$n,
        [int]$first = 0,
        [int]$second = 1
    )
    
    if ($n -le 0) {
        return
    }
    
    Write-Host $first
    Get-Fibonacci -n ($n - 1) -first $second -second ($first + $second)
}
    
Get-Fibonacci -n 10  ## Ausgabe: 0 1 1 2 3 5 8 13 21 34
```



**Seite 175, Listing 2: Fibonacci-Ausgabe mit Bing Chat**

```powershell
function Get-Fibonacci($n) {
    if ($n -lt 2) {
        return $n
    }
    else {
        return (Get-Fibonacci ($n - 1)) + (Get-Fibonacci ($n - 2))
    }
}
Get-Fibonacci -n 10 ## Ausgabe: 55

```



**Seite 175: Antwort von ChatGPT auf Aufgabe 3 (RegEx)**

	^(?=(?:[^0-9]*[0-9]){2})(?=(?:[^A-Za-z]*[A-Za-z]){2}).{6}$
	
	Dieser Ausdruck bedeutet:
	
	^ und $: Anfang und Ende der Zeichenkette.
	
	(?=(?:[^0-9]*[0-9]){2}): Ein Lookahead, der sicherstellt, dass mindestens zwei Zahlen vorhanden sind.
	
	(?=(?:[^A-Za-z]*[A-Za-z]){2}): Ein Lookahead, der sicherstellt, dass mindestens zwei Buchstaben vorhanden sind.
	
	.{6}: Genau sechs beliebige Zeichen.

 


**Seite 157: Postleitzahlen und reguläre Ausdrücke**

```
## Deutsche PLZ bestehen aus 5 Zahlen
^\d{5}$

## Niederländische PLZ bestehen aus 4 Zahlen und 2 (Groß-) Buchstaben
^\d{4}[A-Z]{2}$
```

 

**Seite 176: Summe aus einer Zeichenfolge berechnen**

```powershell
$sum = 0
[int[]] [string[]] [char[]] '123' | ForEach-Object -Process {
    $sum += $_ 
}
$sum 
```



**Seite 176, Listing 4: Übersetzen mit DeepL**

```powershell
## Deepl-Free API
## https://www.deepl.com/docs-api/documents/translate-document

$API_KEY = 'YOUR-API-KEY'
$uri = 'https://api-free.deepl.com/v2/translate'
$text = @'
Space, the final frontier
These are the voyages of the Starship Enterprise
Its five year mission
To explore strange new worlds
To seek out new life
And new civilizations
To boldly go where no man has gone before
'@

$headers = @{    
    'Authorization' = "DeepL-Auth-Key $API_KEY"       
} 

$body = @{
    'text'        = $text
    'target_lang' = 'DE'
}

$request = Invoke-RestMethod -Method 'Post' -Headers $headers -Uri $uri -Body $body 
$request.translations.text

<# 
AUSGABE
Der Weltraum, die letzte Grenze
Dies sind die Reisen des Raumschiffs Enterprise
Seine fünfjährige Mission
Um fremde neue Welten zu erforschen
Auf der Suche nach neuem Leben
Und neue Zivilisationen
Um kühn dorthin zu gehen, wo noch kein Mensch zuvor war
#>
```



**Seite 176/177: PSReadline**

```powershell
## Update PSReadline
Install-Module -Name PSReadline # -Scope AllUsers -force

## PSReadLine configuration
Get-PSReadLineOption | Select-Object -Property Prediction*
Set-PSReadLineOption -PredictionViewStyle ListView -PredictionSource Plugin # HistoryAndPlugin
    
## Az.Tools.Predictor
Install-module -name Az.Accounts
Install-Module -Name Az.Tools.Predictor 
Enable-AzPredictor # -AllSession

```



**Seite 177: International Space Station (IIS)**

```
function Get-ISSPosition {
    $url = "http://api.open-notify.org/iss-now.json"
    $response = Invoke-RestMethod -Uri $url
    $response.iss_position
}
```



**Seite 177: Get-WinEvent**

```powershell
## A: Get-WinEvent via Github Copilot
## Finde Fehler und Warnungen im WindowsPowerShell-Log der letzten 4 Stunden.

Get-WinEvent -FilterHashtable @{
    Logname   = 'Windows PowerShell'; 
    Level     = 2, 3; 
    StartTime = (Get-Date).AddHours(-4)
} | Select-Object -Property TimeCreated, Id, LevelDisplayName, Message | Format-List

## B: Die bestmögliche Lösung mit "-FilterXML"
Get-WinEvent -FilterXml @'
<QueryList>
  <Query Id="0" Path="Windows PowerShell">
    <Select Path="Windows PowerShell">*[System[(Level=2 or Level=3) and TimeCreated[timediff(@SystemTime) &lt;= 914400000]]]</Select>
  </Query>
</QueryList>
'@
```

