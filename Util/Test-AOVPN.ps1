function Get-RandomHexNumber{
    param( 
        [int] $length = 20,
        [string] $chars = "0123456789ABCDEF"
    )
    $bytes = new-object "System.Byte[]" $length
    $rnd = new-object System.Security.Cryptography.RNGCryptoServiceProvider
    $rnd.GetBytes($bytes)
    $result = ""
    1..$length | ForEach-Object{
        $result += $chars[ $bytes[$_] % $chars.Length ]    
    }
    $result
}
function Test-AOVPN {      
    [cmdletbinding(  
        DefaultParameterSetName = '',  
        ConfirmImpact = 'low'
    )]  
    Param(  
        [Parameter(  
            Mandatory = $True,  
            Position = 0,  
            ParameterSetName = '',  
            ValueFromPipeline = $True)]  
        [array]$TargetHosts,
        [Parameter(  
            Mandatory = $False,  
            ParameterSetName = '')]
        [int]$UDPtimeout = 10000
    )
    $Results = @()
    foreach ($TargetHost in $TargetHosts) {
        # ISAKMP Datagram
        $InitiatorSPI = Get-RandomHexNumber -Length 16 #Random 16 length hex
        $ResponderSPI = '0000000000000000' #Zero'd out
        $NextPayload = '21' #Security Association (33)
        $Version = '20' #Version 2.0
        $ExchangeType = '22' #IKE_SA_INIT (34)
        $Flags = '08' #Initiator, No higher version, Request
        $MessageID = '00000000' #Start at 0
        $Length = '00000220' #544 Bytes
        $Payload = "$InitiatorSPI$ResponderSPI$NextPayload$Version$ExchangeType$Flags$MessageID$Length"

        ## Payload: Security Association
        $NextPayload = '22' #Key Exchange (34)
        $CriticalBit = '00' #Not critical
        $PayloadSALength = '0030' #48 Bytes
        $Payload += "$NextPayload$CriticalBit$PayloadSALength"

        ### Payload: Proposal (2) # 1
        $NextPayload = '00' #None / No next payload
        $Reserved = '00' #None
        $PayloadLength = '002c' #44 Bytes
        $ProposalNumber = '01' #Phase 1 proposal
        $ProtocolID = '01' #IKE
        $SPISize = '00' #Zero bytes
        $ProposalTransforms = '04' #Four proposal transforms to be sent
        $Payload += "$NextPayload$Reserved$PayloadLength$ProposalNumber$ProtocolID$SPISize$ProposalTransforms"

        #### Payload: Transform (3) Encryption Algorithm
        $NextPayload = '03' # Transform (3)
        $PayloadTransformLength = '000c' #12 Bytes
        $TransformType = '01' #Encryption Algorithm
        $TransformID = '000c' #ENCR_AES_CBC (12)
        $TransformAttribute = '800e0080' #Key Length 128
        $Payload += "$NextPayload$Reserved$PayloadTransformLength$TransformType$Reserved$TransformID$TransformAttribute"

        #### Payload: Transform (3) Integrity Algorithm
        $NextPayload = '03' #Transform (3)
        $PayloadLength = '0008' #8 Bytes
        $TransformType = '03' #Integrity (3)
        $TransformID = '000c' #AUTH_HMAC_SHA2_256_128 (12)
        $Payload += "$NextPayload$Reserved$PayloadLength$TransformType$Reserved$TransformID"

        #### Payload: Transform (3) Psuedo-random function
        $NextPayload = '03' #Transform (3)
        $PayloadLength = '0008' #8 Bytes
        $TransformType = '02' #Psuedo-random Function (2)
        $TransformID = '0005' #PRF_HMAC_SHA2_256 (5)
        $Payload += "$NextPayload$Reserved$PayloadLength$TransformType$Reserved$TransformID"

        #### Payload: Transform (3) Diffie-Hellman Group (D-H)
        $NextPayload = '00' #None / No next payload
        $PayloadLength = '0008' #8 Bytes
        $TransformType = '04' #Diffie-Hellman Group (D-H) (4)
        $TransformID = '000e' #2048 bit MODP group (14)
        $Payload += "$NextPayload$Reserved$PayloadLength$TransformType$Reserved$TransformID"

        ## Key Exchange (34)
        $NextPayload = '28' #Nonce (40)
        $CriticalBit = '00' #Not critical
        $PayloadLength = '0108' #264 Bytes
        $DHGroup = '000e' #2048 bit MODP group (14)
        $KeyExchange = Get-RandomHexNumber -Length 512
        $Payload += "$NextPayload$CriticalBit$PayloadLength$DHGroup$Reserved$Reserved$KeyExchange"

        ## Nonce (40)
        $NextPayload = '29' #Notify (41)
        $CriticalBit = '00' #Not critical
        $PayloadLength = '0034' #52 Bytes
        $NonceData = Get-RandomHexNumber -Length 96
        $Payload += "$NextPayload$CriticalBit$PayloadLength$NonceData"

        ## Notify (41) IKEv2 Fragmentation Supported
        $NextPayload = '29' #Notify (41)
        $CriticalBit = '00' #Not critical
        $PayloadLength = '0008' #8 Bytes
        $SPISize = '00' #0 bytes
        $NotifyType = '402e' #IKEV2_FRAGMENTATION_SUPPORTED (16430)
        $Payload += "$NextPayload$CriticalBit$PayloadLength$Reserved$SPISize$NotifyType"

        ## Notify (41) IKEv2 NAT Detection Source IP
        $NextPayload = '29' #Notify (41)
        $CriticalBit = '00' #Not critical
        $PayloadLength = '001c' #28 Bytes
        $SPISize = '00' #0 bytes
        $NotifyType = '402e' #NAT_DETECTION_SOURCE_IP (16388)
        $NotifyData = Get-RandomHexNumber -Length 40
        $Payload += "$NextPayload$CriticalBit$PayloadLength$Reserved$SPISize$NotifyType$NotifyData"

        ## Notify (41) IKEv2 NAT Detection Destination IP
        $NextPayload = '29' #Notify (41)
        $CriticalBit = '00' #Not critical
        $PayloadLength = '001c' #28 Bytes
        $SPISize = '00' #0 bytes
        $NotifyType = '4005' #NAT_DETECTION_DESTINATION_IP (16389)
        $NotifyData = Get-RandomHexNumber -Length 40
        $Payload += "$NextPayload$CriticalBit$PayloadLength$Reserved$SPISize$NotifyType$NotifyData"

        ## Vendor data for Microsoft Always-On VPN
        $Vendor1 = '2b0000181e2b515905991c7d7c96fcbfb587e46100000009' #Unknown Vendor ID
        $Vendor2 = '2b000014fb1de3cdf341b7ea16b7e5be0855f120' #MS-Negotiation Discovery Capable
        $Vendor3 = '2b00001426244d38eddb61b3172a36e3d0cfb819' #Microsoft Vid-Initital-Contact
        $Vendor4 = '0000001801528bbbc00696121849ab9a1c5b2a5100000002' #Unknown Vendor ID
        $Payload += "$Vendor1$Vendor2$Vendor3$Vendor4"                
        
        # Convert the hex payload to bytes
        $Bytes = [byte[]] ($Payload -replace '..', '0x$&,' -split ',' -ne '')
        $Output = "" | Select-Object Server, Open, Response
        #Create object for connecting to port on computer  
        $UDPObject = new-Object System.Net.Sockets.Udpclient
        #Set a timeout on receiving message 
        $UDPObject.client.ReceiveTimeout = $UDPTimeout                     
        #IPEndPoint object will allow us to read datagrams sent from any source.  
        Write-Output "Creating remote IKEv2 500 endpoint" 
        $IPEndpoint = New-Object System.Net.IPEndpoint([System.Net.IPAddress]::Any, '500') 
        #Connect to remote VPN Server on IKEv2 port 500
        Write-Output "Establishing an IKEv2 SA Init with remote server $TargetHost on UDP 500.." 
        try{
            $UDPObject.Connect("$TargetHost", '500')
            #Sends an IKE SA Init to the target host
            Write-Output "Sending IKE SA Init to $TargetHost"
            [void]$UDPObject.Send($Bytes, $Bytes.length)
            try { 
                #Blocks until a message returns on this socket from a remote host. 
                Write-Output "Waiting for message return" 
                $ReceiveBytes = $UDPObject.Receive([ref]$IPEndpoint) 
                $ReturnData = [System.Text.Encoding]::ASCII.GetString($ReceiveBytes)
                #[string]$returndata = $ASCII.GetString($receivebytes)
                if ($ReturnData) {
                    Write-Output "IKEv2 connection to $TargetHost was successful"
                    $Output.Server = $TargetHost
                    $Output.Open = "True"
                    $Output.Response = $ReturnData
                    $UDPObject.close()   
                }                       
            }
            catch { 
                if ($Error[0].ToString() -match "\bRespond after a period of time\b") { 
                    #Close connection  
                    $UDPObject.Close()  
                    #Make sure that the host is online and not a false positive that it is open 
                    if (Test-Connection -comp $TargetHost -count 1 -quiet) { 
                        Write-Output "Connection Open"
                        $Output.Server = $TargetHost
                        $Output.Open = "True"  
                        $Output.Response = "" 
                    }
                    else { 
                        Write-Output "Host Unreachable"
                        $Output.Server = $TargetHost
                        $Output.Open = "False"
                        $Output.Response = "No response was received from $TargetHost."
                    }
                }
                Elseif ($Error[0].ToString() -match "forcibly closed by the remote host" ) { 
                    #Close connection  
                    $IKEv2Object.Close()  
                    Write-Output "Connection Timeout"
                    $Output.Server = $TargetHost
                    $Output.Open = "False"  
                    $Output.Response = "Connection to Port Timed Out"                         
                }
                Else {                      
                    $UDPObject.close() 
                } 
            }
            $Results += $Output
        }
        catch{
            $Output.Server = $TargetHost
            $Output.Open = "False"  
            $Output.Response = "$($_.Exception.Message)"  
            $Results += $Output
        }
    }     
    return $Results
}
Test-AOVPN -TargetHosts @("server1.domain.com","server2.domain.com")