<#
.SYNOPSIS
  Generates passwords that pass VCF validation on every component.

.DESCRIPTION
  VCF components accept different special characters. Cloud Proxy takes
  @ ! # $ % ? ^, Fleet and VCF Automation take ! @ # $ ^ *, and SDDC Manager
  fails to remediate passwords containing & < > ' ". This script uses only
  @ and ^, the two that pass every list.

  Each password has at least one upper case letter, one lower case letter,
  one digit and one special character. Look-alike characters (l I 1 O 0 o)
  are left out, the first and last characters are never special, and no
  character repeats three times in a row.

.PARAMETER Count
  How many passwords to generate. Default 10.

.PARAMETER Length
  Password length. Minimum 15, which is what VCF requires. Default 16.

.PARAMETER OutFile
  Write the passwords to this file instead of the console.

.EXAMPLE
  .\New-VcfPassword.ps1

.EXAMPLE
  .\New-VcfPassword.ps1 -Count 20 -Length 20 -OutFile .\passwords.txt
#>
[CmdletBinding()]
param(
    [int]$Count = 10,
    [ValidateRange(15, 64)][int]$Length = 16,
    [string]$OutFile
)

$Upper   = 'ABCDEFGHJKLMNPQRSTUVWXYZ'.ToCharArray()
$Lower   = 'abcdefghijkmnpqrstuvwxyz'.ToCharArray()
$Digit   = '23456789'.ToCharArray()
$Special = '@^'.ToCharArray()
$All     = $Upper + $Lower + $Digit + $Special

$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()

function Get-RandInt([int]$Max) {
    # Unbiased random integer in [0, Max)
    $bytes = New-Object byte[] 4
    $limit = [uint32]::MaxValue - ([uint32]::MaxValue % [uint32]$Max)
    do {
        $rng.GetBytes($bytes)
        $v = [BitConverter]::ToUInt32($bytes, 0)
    } while ($v -ge $limit)
    [int]($v % [uint32]$Max)
}

function Select-Random1($Set) { $Set[(Get-RandInt $Set.Length)] }

function New-Pw([int]$Len) {
    while ($true) {
        $c = @((Select-Random1 $Upper), (Select-Random1 $Lower),
               (Select-Random1 $Digit), (Select-Random1 $Special))
        for ($i = 0; $i -lt $Len - 4; $i++) { $c += Select-Random1 $All }

        # Fisher-Yates shuffle
        for ($i = $c.Count - 1; $i -gt 0; $i--) {
            $j = Get-RandInt ($i + 1)
            $t = $c[$i]; $c[$i] = $c[$j]; $c[$j] = $t
        }

        $pw = -join $c
        if ($Special -contains $pw[0] -or $Special -contains $pw[-1]) { continue }
        if ($pw -cmatch '(.)\1\1') { continue }
        return $pw
    }
}

$passwords = 1..$Count | ForEach-Object { New-Pw $Length }

if ($OutFile) {
    $passwords | Set-Content -Path $OutFile
    "Saved $Count passwords to $OutFile"
} else {
    $passwords
}
