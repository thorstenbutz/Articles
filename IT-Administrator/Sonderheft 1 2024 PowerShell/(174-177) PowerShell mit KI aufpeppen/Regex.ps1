##############################################################################
## A glympse of RegEx and artificial intelligence (AI)
## quser.exe und RegEx 
## \s für ein Whitespace-Zeichen (wie Leerzeichen oder Tabulatoren)
## {2,} bedeutet, dass zwei oder mehr dieser Zeichen in Folge gesucht werden
##############################################################################

## Text => Objekt
(quser.exe) -replace '\s{2,}', ',' | ConvertFrom-Csv | Select-Object -Property Username, ID

## Deutsche PLZ bestehen aus 5 Zahlen
80802 -match '^\d{5}$'  ## True

## Niederländische PLZ bestehen aus 4 Zahlen und 2 (Groß-) Buchstaben
'1017CA' -match '^\d{4}[A-Z]{2}$'

## Aufgabe für ChatGPT4, Prompt: 
## Ich benötige für die PowerShell einen regulären Ausdruck, der Postleitzahlen validiert, 
## die aus einer Abfolge von 6 Zeichen besteht, davon sind mindestens zwei Zahlen und mindestens zwei Buchstaben,
## eine abschließenden Prüfzahl repräsentiert die Summe aller Zahlen modulo 10 (Modulo berechnet den ganzzahligen
## Rest einer Divsion, also: 16 mod 10 = 6).
## Anwort: https://chat.openai.com/share/946b6b4f-1777-485c-b6bf-58014802dbbf

## "To hard to handle"
$sum = 0
[int[]] [string[]] [char[]] '123' | ForEach-Object -Process {
    $sum += $_ 
}
$sum 