__ADM Power - A Collection of Citrix ADM Power Tools__
<br><br><img src=".\images\ADMPower.png"/><br>
## Contents
+ [Introduction](#intro)
+ [Getting Started](#gettingstarted)
    - [Script Startup](#startup)
    - [Main Form](#mainform)
    - [Actions](#actions)
+ [Preferences](#prefs)
+ [Power Tools](#powertools)
    - [Config Viewer](#configviewer)
    - [Checkout ADCs](#checkadcs)
    - [Get ADC Resources](#getadcresources)
    - [Import Devices](#importdevices)
    - [Log Viewer](#logviewer)
<a name="intro"></a>
## Introduction
ADMPower is a Forms-based Windows application that runs as a PowerShell script, and includes a collection of scripts and tools for managing Citrix's Application Delivery Management (ADM) and the Citrix Application Delivery Controllers (ADCs), formerly known as NetScalers, that it manages.
<br><br>
Citrix ADM & ADC appliances include an API SDK called [Nitro](https://www.citrix.com/community/citrix-developer/netscaler/nitro-sdk.html), which is implemented as a RESTful interface.
This script leverages ADM as an API Proxy, giving end users the ability to quickly interact with one to many ADCs via ADM:
<a name="gettingstarted"></a>
## Getting Started
To use this script set your execution policy to allow unrestricted execution mode:
```powershell 
\> Set-ExecutionPolicy -ExecutionPolicy Unrestricted
```
From there simply execute the script to load the startup form:
```powershell
\> .\ADMPower.ps1
```
<a name="startup"></a>
### Startup Parameters
Once the script is executed, specify the ADM hostname and ADM user, and optionally check the 'Save Options' and/or 'Use HTTPS' checkboxes:<br>
<img src=".\images\startup.png"/>
<a name="mainform"></a>
### Main Form
Upon successfully connecting to an ADM host, the main form will load, which is divided into three panels:<br>
<img src=".\images\mainform.png"/>
<br>
The lefthand splitpanel displays a treeview of the various configuration elements in ADM, which is divded into four main sections
#### Applications 
The applications section includes the various stylebooks and related configuration elements:
<img src=".\images\applications.png"/>
#### Configurations
The configurations section contains the configuration jobs, templates, and audit templates that are managed under the 'Networks' section in the ADM GUI:<br>
<img src=".\images\configs.png"/>
#### Inventory
The inventory section enumerates and displays the ADCs that are managed by ADM, as well as device groups, profiles, sites, and SSL certkeys:
<br>
<img src=".\images\inventory.png"/>
#### Settings
The settings section includes the ADM system settings, including users, groups, roles and access policies:
<br>
<img src=".\images\settings.png"/>
<br>
<a name="prefs"></a>
### Preferences
Clicking 'Edit > Preferences' allows you to modify the color settings for the background, foreground, and header of the various elements in ADMPower:
<br>
<img src=".\images\edit_preferences.png"/>
<br>
Color settings can be specified by hex, rgb, or color name, and applied by clicking the 'Apply' button:
<br>
<img src=".\images\colors.png"/>
<a name="powertools"></a>
### Power Tools
The ADMPower-'Tools' can be found by clicking the 'Tools' item in the top menu:
<br>
<img src=".\images\config_viewer.png"/>
<br>
<a name="configviewer"></a>
#### Config Viewer
The config viewer allows an admin to view the merged configuration of a 'root.conf' and 'variables.xml' file, and compare it against the running configuration of a target ADC:
<br>
<img src=".\images\configviewer.png"/>
<br>
Currently, the 'Compare to Running' feature relies on Visual Studio Code being installed (and in the PATH env variable), which will launch a difference of the two:
<br>
<img src=".\images\diff.png"/>
<br>
<a name="checkadcs"></a>
#### Checkout ADCs
This tool can be used to compare an exported configuration (in .json format) with a selection of ADCs and/or groups of ADCs that displays the differences for each in an excel spreadsheet:
<br>
<img src=".\images\checkout_adc.png"/>
<br>
To use this tool, you must first dump the 'known good' nitro configuration object to a .json file in the following format (the name of the .json must match the object, e.g. lbvserver.json for lbvserver objects):
```json
[
    {
        "name": "Args",
        "labelkey": "name",
        "excludes": "ipv46, curaaausers, curtotalusers",
        "bindingkey": ""
    },
    {
        "name": "vserver Name",
        "ipv46": "192.168.0.1",
        "port": 443
    }
]
```
The output is an Excel spreadsheet that highlights the matching and non-matching configuration elements for each object in a separate worksheet.
<br>
<img src=".\images\lbvserver.png"/>
<br>
<a name="getadcresources"></a>
#### Get ADC Resources
This tool allows an admin to view one or many nitro object from one or many ADCs in a spreadsheet
<br>
<img src=".\images\get_adc_resources.png"/>
<br>
To use it, simply select the ADCs to get the object from, and then specify a comma-separated list of objects to dump; for example, to view nsip and lbvserver from all ADCs in the 'ADM' device group:
<br>
<img src=".\images\get-resources.png"/>
<br>
Once complete, an Excel spreadsheet will open with a sheet for each object type, and a row for each ADC:
<br>
<img src=".\images\get-resource-output.png"/>
<br>
<a name="importdevices"></a>
#### Import Devices
<br>
<img src=".\images\import_devices.png"/>
<br>
This tool allows an admin to import a group of ADCs using an XML file in the following format, where the nsip is required, and the datacenter name is optional (and must already exist in ADM):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "inputfile.dtd"[]>
<properties>
    <global>
        <param name="name" value="value" />
    </global>
    <device name="192.168.86.11">
        <param name="hostname" value="adc1"/>
        <param name="nsip" value="192.168.86.11"/>        
        <param name="datacenter" value="dc1"/>
        <param name="group" value="group1"/>
    </device>
    <device name="192.168.86.12">
        <param name="hostname" value="adc2"/>
        <param name="nsip" value="192.168.86.12"/>
        <param name="datacenter" value="dc2"/>
        <param name="group" value="group2"/>
    </device>
</properties>
```
When importing you'll be prompted to select a device profile, and all imported ADCs will be added to a group named after the parent folder of the imported .XML file.
<br>
<img src=".\images\device_profile.png"/>
<br>
<br>
<img src=".\images\added_adcs.png"/>
<br>
<a name="logviewer"></a>
#### Log Viewer
<br>
<img src=".\images\log_viewer.png"/>
<br>
The log viewer gives ADM admins a quick and easy way to view the various logs that exposed in the Nitro APIs, including 
<br>
<img src=".\images\log_types.png"/>
<br>
By default the viewer will only show the last 10 events, which can be adjusted by specifying a count in the 'Max Dislayed' box and clicking 'Refresh'
<br>
<img src=".\images\logs.png"/>
<br>
You can also right-click the log results to copy or save the output for further analysis
<br>
<img src=".\images\log_right-click.png"/>
<br>