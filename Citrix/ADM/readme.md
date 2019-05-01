__Citrix Application Delivery Management Powershell Modu1e__
## Contents
+ [Introduction](#ingro)
+ [External Module Functions](#emf)
    - [Connect-ADM](#connect-adm)
    - [Disconnect-ADM](#disconnect-adm)
    - [Invoke-ADMNitro](#invoke-admnitro)
+ [Utility Scripts](#samples)
    - [Sample.ps1](#sample1)
<a name="intro"></a>
## Module Introduction
Citrix's Application Delivery Management (ADM) product is a linux-based Virtual appliance that serves as a centralized configuration management and analytics system for monitoring, analyzing, and maintaining Citrix Application Delivery Controllers (ADCs), which are formerly known as NetScalers.
<br><br>
![Overview](https://docs.citrix.com/en-us/citrix-application-delivery-management-software/12-1/media/adm-architecture.png)
<br><br>
Citrix ADM & ADC appliances include an API SDK called [Nitro](https://www.citrix.com/community/citrix-developer/netscaler/nitro-sdk.html), which is implemented as a RESTful interface.
This module provides a set of functions that are tailored for the Nitro REST interfaces to facilitate command line interaction with a target ADM host, as well as the ADCs that it manages, through the use of PowerShell cmdlets.
### Getting Started
The easiest way to get started is to copy the '.\Sample.ps1' script (in this path) to the script that you want to create. The only requirement is that ADM.psm1 be in the same directory.

The following steps explain how to start from scratch, and outline the various functions in the ADM Powershell 'Invoke-RestMethod' helper module.

First, import module using the Import-Module command:
```powershell 
Import-Module '\ADM.psm1'
```
From there, a call to [Connect-ADM](#connect-adm) should be stored to a variable to be used for any subsequent calls to [Invoke-ADMNitro].
<a name="emf"></a>
## External Module Functions
The following functions can be used as Powershell cmdlets to interact with a target ADM host.
<a name="connect-adm"></a>
### Connect-ADM
This function builds a websession object to be used by [Invoke-ADMNitro](#invoke-admnitro).
#### Example
The following example will prompt a user for credentials and store an ADMSession object in [PSObject]$ADMSession to be used later on:
```powershell
$ADMSession = Connect-ADM https://adm Get-Credential
```
<a name="disconnect-adm"></a>
### Disconnect-ADM
This function closes a websession object when it is no longer needed.
#### Example
```powershell
Disconnect-ADM $ADMSession
```
<a name="invoke-admnitro"></a>
### Invoke-ADMNitro
This is the primary function in the module, and acts as the interpreter for input parameters to be executed against a target ADM host.
#### Parameters
The following parameters are used by this function:
##### ADMSession
`Mandatory=$true [PSObject]`<br>
This required parameter takes an *ADMSession* web session object to be used for the subsequent Invoke-Restmethod command
##### OperationMethod
`Mandatory=$true [ValidateSet("DELETE","GET","POST","PUT")] [string]$OperationMethod`<br>
The REST method to be used by Invoke-RestMethod command
##### ResourceType
`Mandatory=$true [string]$ResourceType` <br>
The target nitro object class, for example configuration_template  
##### Resource Name
`Mandatory=$false [string]$ResourceName` <br>
Additional name added to the URL string
$uri = "$($ADMSession.Endpoint)/nitro/v1/$ApiType/$ResourceType"
if (-not [string]::IsNullOrEmpty($ResourceName)) { $uri += "/$ResourceName" }
##### Action
`Mandatory=$false [string]$Action` <br>
The target nitro method to execute against the specified nitro class
##### Arguments
`Mandatory=$false [ValidateScript({$OperationMethod -in @("GET", "DELETE")})] [hashtable]$Arguments=@{}` <br>
Additional arguments to be passed in the URL string in a ?key=value
##### Payload
`Mandatory=$false [ValidateScript({$OperationMethod -notin @("GET", "DELETE")})] [hashtable]$Payload=@{}`<br>
Payload data in a hashtable key/value pair to send as JSON payload data to the REST interface.
##### ApiType
`Mandatory=$false [ValidateSet("upload", "config")] [ValidateSet("config","GET","POST","PUT")] [string]$ApiType="config"` <br>
Specify an the root API path to target, defaults to config.
##### ADCProxy
`Mandatory=$false [string]$ADCProxy`<br>
Specify a target ADC to proxy the API calls to
#### Examples
##### Get All ADM Configuration Templates
The following command will **Get** configuration_template objects from an $ADMSession
```powershell
Invoke-ADMNitro -ADMSession $ADMSession -OperationMethod GET -ResourceType configuration_template
```
##### Delete the ADM Configuration Template Named Template
The following command will **Get** configuration_template objects from an $ADMSession
```powershell
$Args = @{
   name = $Template.Name
   id = $Template.id
}
Invoke-ADMNitro -ADMSession $ADMSession -OperationMethod Delete -ResourceType configuration_template -Arguments $Args
```
##### Get the running configuration from every ADC in ADM
The following script will get the running configuration from each ADC in an ADM's inventory:
```powershell
$ADCS = Invoke-ADMNitro -ADMSession $ADMSession -OperationMethod GET -ResourceType ns
$RunningConfigs = @()
foreach ($ADC in $ADCs.ns)
{
	$RunningConfigs += (Invoke-ADMNitro -ADMSession $ADMSession -OperationMethod GET -ResourceType nsrunningconfig -ADCHost $ADC.ip_address).nsrunningconfig
}
```