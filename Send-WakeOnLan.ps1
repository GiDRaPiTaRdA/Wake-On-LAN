<#PSScriptInfo

.VERSION 1.0.0

.GUID 589da39d-aa3d-469e-b289-9359e9243716

.AUTHOR Sha256Encrypted

.TAGS WakeOnLan WOL Network UDP Windows

#>

<#
.SYNOPSIS
Sends a Wake-on-LAN magic packet.

.DESCRIPTION
Sends a UDP magic packet to the specified MAC address.
Automatically calculates the local IPv4 broadcast address
unless a broadcast address is supplied.

.PARAMETER MacAddress
The MAC address of the target device.

.PARAMETER Broadcast
Optional destination broadcast IPv4 address.

.PARAMETER Port
UDP destination port. Defaults to 9.

.EXAMPLE
.\Send-WakeOnLan.ps1 -MacAddress "AA:BB:CC:DD:EE:FF"

.EXAMPLE
.\Send-WakeOnLan.ps1 -MacAddress "AA-BB-CC-DD-EE-FF" -Broadcast "192.168.1.255" -Port 9
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$MacAddress,

    [Parameter(Mandatory = $false)]
    [string]$Broadcast,

    [Parameter(Mandatory = $true)]
    [int]$Port
)

function Get-LocalBroadcastAddress {
    $config = Get-NetIPConfiguration |
        Where-Object { 
            $_.IPv4Address -and $_.IPv4DefaultGateway -and $_.NetAdapter.Status -eq 'Up' } | Select-Object -First 1

    if (-not $config) {
        throw 'No active IPv4 network adapter was found.'
    }

    $ipv4 = $config.IPv4Address.IPAddress
    $prefixLength = $config.IPv4Address.PrefixLength

    $ipBytes = [System.Net.IPAddress]::Parse($ipv4).GetAddressBytes()
    [Array]::Reverse($ipBytes)
    $ipInt = [BitConverter]::ToUInt32($ipBytes, 0)

    $mask = ([uint32]::MaxValue) -shl (32 - $prefixLength)
    $broadcastInt = $ipInt -bor (-bnot $mask)

    $broadcastBytes = [BitConverter]::GetBytes($broadcastInt)
    [Array]::Reverse($broadcastBytes)

    return ([System.Net.IPAddress]::new($broadcastBytes)).ToString()
}

if (-not $Broadcast) {
    try {
        $Broadcast = Get-LocalBroadcastAddress
    } catch {
        Write-Error "Failed to determine broadcast address: $_"
        exit 1
    }
}

# === Convert MAC to bytes ===
try {
    $macBytes = ($MacAddress -split '[:-]') | ForEach-Object { [byte]("0x$_") }
} catch {
    Write-Error "Invalid MAC address format: ${MacAddress}"
    exit 1
}

# === Construct magic packet ===
$packet = [byte[]]@([byte]0xFF) * 6

# Repeat the MAC address 16 times and add to the packet
$macBytesRepeated = $macBytes * 16
$packet = $packet + $macBytesRepeated

# === Send magic packet ===
try {
    $udpClient = New-Object System.Net.Sockets.UdpClient
    $udpClient.Connect($Broadcast, $Port)
    [void]$udpClient.Send($packet, $packet.Length)
    $udpClient.Close()
    Write-Output "WOL packet sent to ${MacAddress} via ${Broadcast}:${Port}"
} catch {
    Write-Error "Failed to send WOL packet: $_"
    exit 1
}
