param(
    [string]$Hostname = "google.com",
    [string]$WhoAmI = "whoami.ds.akahelp.net",
    [int]$IntervalSeconds = 10,
    [int]$DurationMinutes = 30,
    [array]$NameServers = @("8.8.8.8", "8.8.4.4", "208.67.222.222", "208.67.220.220")
)
$Results = @()
$FutureDate = (Get-Date).AddMinutes($DurationMinutes)
while ((Get-Date) -lt $FutureDate)
{
    foreach($NameServer in $NameServers)
    {        
        $ResultObject = New-Object -TypeName PSObject
        $Result = Resolve-DnsName $Hostname -Server $NameServer
        $WhoAmIResult = Resolve-DnsName $WhoAmI -Type TXT -Server $NameServer
        $NS = ($WhoAmIResult | Where-Object -FilterScript {$_.Strings[0] -eq "ns"}).Strings[-1]
        $ECS = ($WhoAmIResult | Where-Object -FilterScript {$_.Strings[0] -eq "ecs"}).Strings[-1]
        $RepIP = ($WhoAmIResult | Where-Object -FilterScript {$_.Strings[0] -eq "ip"}).Strings[-1]
        Write-Output "Resolved $($Result[1].NameHost) using $NameServer - ECS: $ECS"
        $ResultObject | Add-Member -MemberType NoteProperty -Name Time -Value (Get-Date)
        $ResultObject | Add-Member -MemberType NoteProperty -Name Result -Value ($Result[1].NameHost)
        $ResultObject | Add-Member -MemberType NoteProperty -Name NameServer -Value ($NameServer)
        $ResultObject | Add-Member -MemberType NoteProperty -Name RepIP -Value $RepIP
        $ResultObject | Add-Member -MemberType NoteProperty -Name ECS -Value $ECS
        $ResultObject | Add-Member -MemberType NoteProperty -Name NS -Value $NS
        $Results += $ResultObject
    }
    Start-Sleep -Seconds $IntervalSeconds
}
$TimeStamp = Get-Date -f MM-dd-yyyy_HH_mm_ss
$Results | Export-Csv -NoTypeInformation -Path "$($env:Temp)\$($TimeStamp).csv"
Invoke-Item $env:Temp