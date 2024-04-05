#######################
## Splatting in VSCode
#######################

## Get required module 
Find-Module -Name EditorServicesCommandSuite
Install-Module -Name EditorServicesCommandSuite -AllowPrerelease -RequiredVersion 1.0.0-beta4
Import-CommandSuite ## Command Palette => Show additional commands from PowerShell => Splat Command

## Example command (before splatting)
Test-Connection -TargetName dns.google -TimeoutSeconds 1 -Count 2

## Example command (splatted)
$testConnectionSplat = @{
    TargetName     = 'dns.google'
    TimeoutSeconds = 1
    Count          = 2
}

Test-Connection @testConnectionSplat