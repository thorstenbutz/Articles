# IT-Administrator: Sonderheft I/2024 PowerShell



## Handgemacht (Cmdlets performant und benutzerfreundlich erstellt)



Insbesondere beim Verarbeiten von Mengen in Arrays oder Listen zeigt sich, wie unzulänglich viele Cmdlets entwickelt wurden. Sie
erlauben oft keine direkte Übergabe von Arrays oder verarbeiten keinen Pipeline-Input. In diesem Workshop erläutern wir detailliert
den Umgang mit den begin-, process- und end-Blöcken. Wir zeigen die benutzerfreundliche Übergabe von Arrays und achten dabei
auch auf die Performance. So gelingt das Do-it-yourself-Cmdlet. 

 

### Link Codes im Artikel

 

**Link-Codes**: Link Code 124 fehlt noch

[1] PowerShell-Komitee (os121)

https://github.com/PowerShell/PowerShell/blob/master/docs/community/governance.md#powershell-committee

 

[2] Offizielle Cmdlet-Definition (os122)

https://github.com/MicrosoftDocs/PowerShell-Docs/issues/6105

 

[3] OpenWeather (os123)

https://openweathermap.org/

 

[4] Beispielskript 1 (os124)

https://github.com/thorstenbutz/Articles/tree/4ddc1529e62e4b8fbcddf01d037ed0f6c33fde12/IT-Administrator/Sonderheft%201%202024%20PowerShell/(072-076)%20Cmdlets%20performant%20und%20benutzerfreundlich%20erstellt

 

[5] Beispielskript 2 (os120)

https://github.com/thorstenbutz/conferences/tree/master/2022.PSConf.eu/Chasing%20the%20seconds



**Seite 72: Was ist ein Cmdlet?** 

    Get-Command -Verb * | Group-Object -Property CommandType



**Seite 72: New-HelloWorld** (v1,v2)

```powershell
## v1
function New-HelloWorld {
    [CmdletBinding()]
    param ( 
        [string] $Name = $env:USERNAME
    )
    ## Main
    process {
        "Hello $name!"
        Write-Verbose -Message $env:COMPUTERNAME
    }
}

## v2
function New-HelloWorld {
    [CmdletBinding()]
    param ( 
        [Parameter(ValueFromPipeline)]
        [string] $Name = $env:USERNAME
    )
    ## Main
    process {
        "Hello $name!"
        Write-Verbose -Message $env:COMPUTERNAME
    }
}
'Eva','Adam' | New-HelloWorld 
```



**Seite 73: New-HelloWorld** (v3)

    ## v3
    function New-HelloWorld {
        [CmdletBinding()]
        param (         
            [string[]] $Name = $env:USERNAME
        )
        ## Main
        foreach ($item in $Name) {
            "Hello $item!"        
        }
        Write-Verbose -Message $env:COMPUTERNAME
    }
    New-HelloWorld -name 'Eva','Adam' ## Listing 3 unterstützt diese Eingabe,



**Seite 73: Array als Argument vs Pipelining**

    Test-Connection -ComputerName 'one.one.one.one','dns.google'
    'one.one.one.one','dns.google' | Test-Connection



**Seite 73: Wetterbericht**

    ## Einen Wetterbericht abrufen
    $Apikey = 'YOUR_API_KEY'
    $City = 'Munic'
    $Units = 'metric'
    $Uri = "http://api.openweathermap.org/data/2.5/weather?units=$Units&q=$City&appid=$Apikey"
    Invoke-RestMethod -Uri $Uri



**Seite 73, Listing 1: Get-WeatherReport-Cmdlet**

```powershell
function Get-WeatherReport {
    [CmdletBinding()]
    param (
        [string] $Apikey = 'YOUR_API_KEY',
        [Parameter(Mandatory,ValueFromPipeline)]
        [string[]] $City,
        [string] $Units = 'metric'
    )
    ## Main
    process {
        foreach ($item in $City) {
            $Uri = "http://api.openweathermap.org/data/2.5/weather?units=$Units&q=$Item&appid=$Apikey"
            Invoke-RestMethod -Uri $Uri | Select-Object -ExpandProperty Main 
        }
    }
}

Get-WeatherReport -City 'Munic','Berlin','Hamburg' | Format-Table
'Köln','Frankfurt','Stuttgart' | Get-WeatherReport | Format-Table
```



**Seite 74: Wetterbericht, try/catch**

```powershell
$Apikey = 'YOUR_API_KEY'
$Units = 'metric'
$City = 'Hobbiton'
$Uri = "http://api.openweathermap.org/data/2.5/weather?units=$Units&q=$City&appid=$Apikey"

try {
    Invoke-RestMethod -Uri $Uri -ErrorAction Stop  ## Terminating error
}
catch {
    Write-Warning -Message "Webrequest failed! City: $City, API-Key: $Apikey, Units: $Units "    
}
```



**Seite 74: Terminating vs non-terminating errors**

    ## Beispiel für einen "Non-terminating error" ('c:\foo' existiert NICHT.)
    Get-ChildItem -Path 'c:\foo','c:\windows'
    
    ## Beispiel für einen "Terminating error" ('c:\foo' existiert NICHT.)
    Get-ChildItem -Path 'c:\foo','c:\windows' -errorAction Stop



**Seite 75: Hashtabelle vs PSCustomObject**

```powershell
## Hash table
@{
    'city' = 'Munich'
    'postalCode' = 80802
    'state' = 'Bavaria'
}

## PSCustomObject
[PSCustomObject] @{
    'city' = 'Munich'
    'postalCode' = 80802
    'state' = 'Bavaria'
}
```



**Seite 75, Listing 2: Eine verbesserte Version des Get-WeatherReport-Cmdlet**

```powershell
function Get-WeatherReport {
    [CmdletBinding()]
    [Alias('gwr')]
    param (
        [string] $Apikey = 'YOUR_API_KEY',
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $City,
        [string] $Units = 'metric'
    )
    begin {
        switch ($Units) {
            'metric' { $unit = 'Celsius' }
            'imperial' { $unit = 'Fahrenheit' }    
            'standard' { $unit = 'Kelvin' }
        }
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()                        
    }
    process {                
        foreach ($item in $City) {
            $uri = "http://api.openweathermap.org/data/2.5/weather?units=$Units&q=$item&appid=$Apikey"
            try {
                $request = Invoke-RestMethod -UseBasicParsing -Uri $uri -Verbose:$false -ErrorAction Stop
                                
                [pscustomobject]  @{
                    'City'        = $request.name
                    'Description' = $request.weather.DESCRIPTION                    
                    'AirPressure' = $request.main.pressure
                    'AirHumidity' = $request.main.humidity
                    'Temperature' = $request.main.temp 
                    'Unit'        = $unit                        
                }
            } 
            catch {
                Write-Warning -Message "Webrequest failed! City: $City, API-Key: $Apikey, Units: $Units "                
            }
        }
    }
    end {
        'Runtime(ms): ' + $stopwatch.Elapsed.TotalMilliseconds | Write-Verbose        
    }
}

Get-WeatherReport -City 'Munic', 'Berlin', 'Hamburg' -Units imperial -Verbose | Format-Table
'Cologne', 'Frankfurt', 'Stuttgart' | Get-WeatherReport -Verbose | Format-Table
```



**Seite 75/76: Laufzeiten messen** 

```powershell
begin {
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()                        
}
process {..}
end {
    'Runtime(ms): ' + $stopwatch.Elapsed.TotalMilliseconds | Write-Verbose        
}
```



**Seite 76: Get hardware information**

```powershell
# A
Get-ADComputer -Filter {name -like 'muc-sv*'} | Select-Object -ExpandProperty DNSHostname | Get-HardwareInformation

# B
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
'muc-sv1','muc-sv2','muc-sv3'| Invoke-Command -ScriptBlock { 
    $env:computername
    Start-Sleep -Seconds 10
}
$stopwatch.Elapsed.TotalMilliseconds
```



**Seite 76, Listing 3:  Invoke-Command geschickt einsetzen**

```powershell
function Get-HardwareInformation {
    [CmdletBinding()]
    [Alias('ghwi')]    
    Param (                
        [Parameter(Mandatory,ValueFromPipeline)]
        [string[]] $Computername
    )
    Begin {                
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()                               
        $code = { } ## Ihr Code zur Hardwareinventarisierung
    }
    Process {
        ## Wir sammeln die übergebenen Computernamen in einem neuen Array
        [string[]] $Computernames += $Computername           
    }
    End {   
        ## MAIN                        
        $psSessions = New-PSSession -ComputerName $Computernames -ErrorAction SilentlyContinue
        Invoke-Command -Session $psSessions -ScriptBlock $code              
        $psSessions | Remove-PSSession
        ## Laufzeit ermitteln
        Write-Verbose -message "Runtime(ms): $($stopwatch.ElapsedMilliseconds)"        
    }
}
```

