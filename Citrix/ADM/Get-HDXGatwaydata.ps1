#This script pull HDX Insight metrics, it is the same value than the one showing up in the ADM website.

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

[string]$ADMHost = "https://adm.domain.local"
Import-Module ADM.psm1

#Connect to ADM and do the RESTAPI call
$ADMSession = Connect-ADM $ADMHost $Cred
$ICAStats = Invoke-ADMNitro -ADMSession $ADMSession -OperationMethod GET -ResourceType "ica_user?asc=no&order_by=ica_rtt&pagesize=250&type=geo&cr_enabled=0&sla_enabled=1&duration=last_1_hour&pageno=1"
$ICAData = $ICAStats.ica_user


#General
[int]$ActiveSessions =  $ICAData.active_desktop_count
[int]$Bandwidth = ($ICAData.bandwidth/1000000) #in Bit to MegaBit
[int]$Bandwidth = [math]::round($Bandwidth)
[int]$AvgSession = ($ICAData.bandwidth / 1000) / $ActiveSessions #In Kbps
[int]$AvgSession = [math]::round($AvgSession) 
[int]$ICARTT = $ICAData.ica_rtt #average ica

#Client
[int]$WANLatency = $ICAData.client_latency
[int]$ClientSidePacketRetransmits = $ICAData.clientside_packet_retransmits
[int]$ClientSideRTO = $ICAData.clientside_rto
[int]$L7ClientSideLatency = $ICAData.l7_clientside_latency
#Server
[int]$DCLatency = $ICAData.server_latency
[int]$ServerSidePacketRetransmits = $ICAData.serverside_packet_retransmits
[int]$ServerSideRTO = $ICAData.serverside_rto
[int]$L7ServerSideLatency = $ICAData.l7_serverside_latency
