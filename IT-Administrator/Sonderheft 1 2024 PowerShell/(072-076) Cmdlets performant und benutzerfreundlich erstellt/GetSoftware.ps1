################################################
## Anwendungsbeispiel Software-Inventarisierung
################################################

function Get-Software {     
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [string[]] $Computername = $env:COMPUTERNAME,
        [switch] $Detailled,
        [switch] $IncludeUserHive
    )
    begin {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()  
        $path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
        $props = 'Publisher', 'Displayname', 'Displayversion'

        if ($IncludeUserHive) {
            $path += 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
            'HKCU:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' 
        }    
        if ($Detailled) { $props += 'Uninstallstring' } 
    }
    process { 
        [array] $Computers += $Computername
    }
    end {
        ## Remote execution
        Invoke-Command -ComputerName $Computers -ScriptBlock {
            Get-ItemProperty -Path $using:path -ErrorAction SilentlyContinue | 
            Where-Object -Property DisplayName | Select-Object -Property $using:props
        } | Select-Object -ExcludeProperty 'RunspaceID'
        'Runtime (ms): ' + $stopwatch.ElapsedMilliseconds | Write-Verbose
    }
}
