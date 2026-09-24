# usbshare

Share your Mac's Wi-Fi with an iPhone over a USB-C cable. No jailbreak, no
extra hardware, no VPN app. A guided setup that checks each step actually
worked before moving on.

```
curl -fsSL https://raw.githubusercontent.com/xatuke/usbshare/main/install.sh | bash
```

That installs the tool and drops you straight into the guided setup. iPhone
only: Android lets you edit APN proxy settings directly, and
[gnirehtet](https://github.com/Genymobile/gnirehtet) does full reverse
tethering there.

Use it when the phone can't join the Wi-Fi the Mac is on (corporate or
captive networks, MAC filtering, device limits) or when you'd rather not burn
cellular data.

## What you need

- A Mac on Wi-Fi (macOS 13 or newer; tested on macOS 26)
- An iPhone with a SIM that has cellular data and Personal Hotspot
- A USB-C **data** cable (charge-only cables look the same and don't work)
- [Homebrew](https://brew.sh) for the `tinyproxy` dependency

## Commands

| Command | What it does |
|---|---|
| `usbshare setup` | First-time guided setup, about 3 minutes |
| `usbshare start` | After plugging the phone in: bring the link up, start the proxy, confirm traffic |
| `usbshare stop` | Stop the proxy |
| `usbshare status` | Phone on USB? Link up? Proxy running? Traffic flowing? |
| `usbshare profile` | Regenerate the phone profile and walk through reinstalling it |
| `usbshare uninstall` | Remove everything on the Mac and tell you how to remove the profile on the phone |

## How it works

iOS has no "use the computer's internet" mode over USB, and macOS won't share
a Wi-Fi connection back out over Wi-Fi. usbshare uses three things that do
exist:

1. **Personal Hotspot over USB, used backwards.** With the hotspot on and the
   phone plugged in, the phone gives the Mac a private network link (phone
   `172.20.10.1`, Mac `172.20.10.x`). Normally the Mac uses it to reach the
   phone's cellular data. usbshare keeps the Mac's own internet on Wi-Fi and
   uses the link only as a path *from the phone to the Mac*.
2. **A small HTTP proxy on the Mac** (`tinyproxy`) listening on that link, and
   only on that link.
3. **A cellular APN configuration profile on the phone** whose proxy field
   points at the Mac. iOS then sends every HTTP and HTTPS request from every
   app to the proxy. The phone has a direct route to the Mac over the cable,
   so requests go down the USB link, out the Mac's Wi-Fi, and back.

Cellular data stays switched on only because it carries the APN setting. The
web traffic itself never touches the cellular network.

The setup wizard is closed-loop: it waits for the phone to appear on USB, for
the hotspot link to come up, for the phone to fetch the profile from the Mac,
for the cellular restart that applies it, and finally for real requests from
the phone to arrive at the proxy. It only moves on when each has happened, and
prints a specific hint when a step stalls.

## Limits, read these

- **HTTP and HTTPS only.** That covers Safari and nearly all apps. Push
  notifications, iMessage, FaceTime and anything on raw TCP/UDP still use
  cellular data.
- **With the profile installed and the Mac not attached, the phone has no web
  access.** Remove the profile (Settings > General > VPN & Device Management >
  usbshare > Remove Profile) to get normal data back. `usbshare profile`
  reinstalls it later.
- **Carriers that lock APN settings don't work.** Known: Jio (India), Verizon
  and AT&T (US). Airtel (India), T-Mobile (US), EE/O2/Three (UK) and most
  MVNOs accept the profile. The wizard detects it either way at the verify
  step.
- The profile is unsigned (your Mac generates it), so iOS shows a "Not
  Signed" warning on install. Its full contents are at
  `~/.usbshare/usbshare.mobileconfig`.
- Speed is whatever the Mac's Wi-Fi gives, minus a little proxy overhead.

## Troubleshooting

- **"No hotspot link"**: Personal Hotspot is off, or the phone re-enumerated
  on USB without it (happens after Airplane Mode). Unplug, wait 5 s, replug.
  If needed, toggle the hotspot off and on while plugged in.
- **Link present but no address**: macOS sometimes leaves the interface
  switched off. `usbshare start` fixes it (asks for your password once).
- **Phone loads pages but `status` shows 0 connections**: the profile isn't in
  effect. Do the Airplane Mode cycle (on, wait 10 s, off, hotspot back on), or
  the carrier locks APN settings.
- **Phone loads nothing**: the profile is in effect but the proxy is
  unreachable. Run `usbshare status`; if the Mac's link address differs from
  what the profile expects, run `usbshare profile`.
- **Mac lost internet or got slow**: check `usbshare status` says the default
  route is Wi-Fi. The wizard sets Wi-Fi first in the network service order so
  the Mac never uses the phone's cellular data for itself.

## What doesn't work, so you don't retry it

Tested on iOS 26 before settling on the proxy approach:

- **A VPN (WireGuard) to the Mac over the USB link.** iOS pins VPN traffic to
  the primary interface (cellular) regardless of the routing table, so the
  tunnel packets never enter the USB link, even though Safari can reach the
  Mac over it.
- **The developer USB link** (the second network link iPhones expose for
  Xcode). It accepts IPv6 router advertisements and an address, but iOS won't
  treat it as an internet path, so VPNs refuse to start over it.
- **Bluetooth internet sharing.** iOS is only ever the host, never a client.
- **Internet Sharing Wi-Fi to Wi-Fi.** One radio can't be client and access
  point.

If you need every kind of traffic through the Mac, the wired alternative
works: two USB-C Ethernet adapters and an Ethernet cable between Mac and
phone, then Internet Sharing from Wi-Fi to the adapter. The phone treats it as
a normal Ethernet connection.

## Uninstall

```
usbshare uninstall
brew uninstall tinyproxy   # optional
rm "$(command -v usbshare)"
```
and remove the profile on the phone.

## License

MIT
