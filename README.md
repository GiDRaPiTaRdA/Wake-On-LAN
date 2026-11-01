# Send-WakeOnLan

A simple PowerShell script for remotely waking compatible computers and devices using **Wake-on-LAN (WoL)**.

## Features

- Send Wake-on-LAN magic packets over UDP
- Automatically detect a local IPv4 broadcast address
- Specify a custom broadcast address and UDP port
- Accept MAC addresses separated by `:` or `-`
- No third-party dependencies
- Administrator privileges are not normally required

## Requirements

- Windows PowerShell 5.1 or PowerShell 7+ on Windows
- Network access to the target device
- Wake-on-LAN enabled on the target device

## Installation

Install from PowerShell Gallery (once published):

```powershell
Install-Script -Name Send-WakeOnLan -Scope CurrentUser
```

## Usage

Wake a device using automatic broadcast detection and the default UDP port (9):

```powershell
Send-WakeOnLan.ps1 -MacAddress "AA:BB:CC:DD:EE:FF"
```

Specify the broadcast address:

```powershell
Send-WakeOnLan.ps1 -MacAddress "AA:BB:CC:DD:EE:FF" -Broadcast "192.168.1.255"
```

Use a custom UDP port:

```powershell
Send-WakeOnLan.ps1 -MacAddress "AA:BB:CC:DD:EE:FF" -Port 7
```

Specify all parameters:

```powershell
Send-WakeOnLan.ps1 -MacAddress "AA-BB-CC-DD-EE-FF" -Broadcast "192.168.1.255" -Port 9
```

If running a downloaded script from the current directory instead of an installed command, prefix it with `./` (or `.\` in PowerShell).

## Parameters

| Parameter | Required | Default | Description |
| --- | --- | --- | --- |
| `MacAddress` | Yes | — | MAC address of the target device |
| `Broadcast` | No | Auto-detected | Destination IPv4 broadcast address |
| `Port` | No | `9` | UDP destination port |

## Example output

```text
WOL packet sent to AA:BB:CC:DD:EE:FF via 192.168.1.255:9
```

A successful send does **not** guarantee the device woke up.

## Troubleshooting

**The target device doesn't wake up**

- Enable Wake-on-LAN in the target device's BIOS/UEFI and network adapter settings.
- Check the target MAC address.
- Verify that the network allows UDP broadcast traffic.
- Confirm the device supports waking from its current power state.

**Broadcast detection fails or selects the wrong network**

Specify `-Broadcast` manually, such as `192.168.1.255` for the appropriate subnet.

**PowerShell doesn't recognize the command**

Restart PowerShell after installation and check that the PowerShell scripts directory is included in `PATH`.

## License

See [LICENSE](LICENSE) for license details.
