# vcf-lab-tools
Small PowerShell helpers for VMware Cloud Foundation lab builds

## Scripts

| Script | What it does |
| --- | --- |
| `dns/Test-VcfDns.ps1` | Checks forward (A) and reverse (PTR) DNS for a list of host names before VCF bring-up. Flags missing records and mismatched PTRs. |

```powershell
.\dns\Test-VcfDns.ps1 -DnsServer dc01.example.internal -Zone vcf.example.internal -Names sddcmanager,vcenter,nsxmgr,esx01
```
