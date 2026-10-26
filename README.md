# vcf-lab-tools
Small PowerShell helpers for VMware Cloud Foundation lab builds

## Scripts

| Script | What it does |
| --- | --- |
| `dns/Test-VcfDns.ps1` | Checks forward (A) and reverse (PTR) DNS for a list of host names before VCF bring-up. Flags missing records and mismatched PTRs. |
| `passwords/New-VcfPassword.ps1` | Generates passwords that pass VCF validation on every component, using only `@` and `^` as special characters. |

```powershell
.\dns\Test-VcfDns.ps1 -DnsServer dc01.example.internal -Zone vcf.example.internal -Names sddcmanager,vcenter,nsxmgr,esx01
```

```powershell
.\passwords\New-VcfPassword.ps1 -Count 10 -Length 16
```
