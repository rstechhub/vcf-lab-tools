<#
.SYNOPSIS
  Checks forward (A) and reverse (PTR) DNS for a list of VCF host names.

.DESCRIPTION
  VCF bring-up validation fails when a name has no A record, no PTR record,
  or a PTR that points at a different name. Run this before you start.

.EXAMPLE
  .\Test-VcfDns.ps1 -DnsServer dc01.example.internal -Zone vcf.example.internal `
      -Names sddcmanager,vcenter,nsxmgr,esx01,esx02
#>
param(
    [Parameter(Mandatory)][string]  $DnsServer,
    [Parameter(Mandatory)][string]  $Zone,
    [Parameter(Mandatory)][string[]]$Names
)

$results = foreach ($n in $Names) {
    $fqdn = "$n.$Zone"
    # Take the first A record only. Some resolvers return the answer twice.
    $a = Resolve-DnsName $fqdn -Type A -Server $DnsServer -ErrorAction SilentlyContinue |
         Select-Object -First 1
    $p = if ($a) {
        Resolve-DnsName $a.IPAddress -Type PTR -Server $DnsServer -ErrorAction SilentlyContinue |
        Select-Object -First 1
    }
    $ptrHost = if ($p) { $p.NameHost.TrimEnd('.') } else { $null }
    [pscustomobject]@{
        Name   = $fqdn
        IP     = $a.IPAddress
        PTR    = $ptrHost
        Status = if (-not $a) { 'NO A RECORD' }
                 elseif (-not $ptrHost) { 'NO PTR' }
                 elseif ($ptrHost -ne $fqdn) { 'PTR MISMATCH' }
                 else { 'OK' }
    }
}

$results | Format-Table -AutoSize
$bad = @($results | Where-Object Status -ne 'OK').Count
if ($bad) { Write-Warning "$bad name(s) need fixing before bring-up." }
else      { Write-Host 'All names resolve forward and reverse.' -ForegroundColor Green }
