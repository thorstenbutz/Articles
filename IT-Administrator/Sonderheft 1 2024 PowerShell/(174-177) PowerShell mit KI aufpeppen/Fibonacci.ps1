#####################################################
## about_Fibonacci
## https://de.wikipedia.org/wiki/Fibonacci-Folge
## https://en.wikipedia.org/wiki/Fibonacci_sequence
####################################################

## A: Fibonacci-Ausgabe mit ChatGPT4, Prompt:
## Erstelle eine rekursive PowerShell-Funktion, die die Fibonacci-Folge bis zu einem übergebenen Wert ausgibt!

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


## B: Fibonacci Bing Chat
## Erstelle eine rekursive PowerShell-Funktion, die die Fibonacci-Folge bis zu einem übergebenen Wert ausgibt!
function Get-Fibonacci($n) {
    if ($n -lt 2) {
        return $n
    } else {
        return (Get-Fibonacci ($n - 1)) + (Get-Fibonacci ($n - 2))
    }
}
Get-Fibonacci -n 10 ## Ausgabe: 55
