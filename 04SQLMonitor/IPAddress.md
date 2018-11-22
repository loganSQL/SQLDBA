# IP Address
## Old way

```
-- looking for DNS suffix
-- IPv4 address
ipconfig
ipconfig | findstr /i "ipv4"
```

## PS
```
-- Looking for Dhcp
Get-NetIPAddress | Format-Table
```

## WMI
```
-- look for DNSDomain
get-WmiObject Win32_NetworkAdapterConfiguration|Where {$_.Ipaddress.length -gt 1} |format-table
```