# dohot-service
DNS Over HTTPS over Tor for Anonymized DNS with adblocking, with [Pi-Hole](https://github.com/pi-hole/pi-hole) and [DNSCrypt-Proxy](https://github.com/DNSCrypt/dnscrypt-proxy)

Cribbed from [Alec Muffett's DoHoT](https://github.com/alecmuffett/dohot).


# Overview
`tor` is run as a client, exposing a SOCKS proxy.

`dnscrypt-proxy` is run, configured to use the `tor` clients SOCKS proxy to connect and resolve over a wide selection of DOH servers.

`pihole` is run, configured to use `dnscrypt-proxy` as it's upstream resolver.

End user devices should be resolving via DNS provided by `pihole` to take advantage of the ad-blocking.

`pihole` should not be exposed to the internet at large, lest it be used as part of a DNS amplification attack. It should be listening on a LAN/VPN IP or a packet filter should restrict incoming DNS queries to the `pihole` to only authorized client devices.

Optionally, `doh-front` (container image for [`doh-server`](https://github.com/DNSCrypt/doh-server)) can be used so that the pihole can be configured as a DOH server directly by end user devices (see the [`README`](https://github.com/cyberworm-uk/dohot-service/blob/main/doh-server/README.md)).

Further optionally, as of Arti 1.1.10 it's now capable of listening on arbitrary ports (previously restricted to localhost) which means it's now suitable for deployment in containers.

Replace the existing tor proxy image with an equivalent [`ghcr.io/cyberworm-uk/arti:latest`](https://github.com/cyberworm-uk/tortainer#arti) if you want to use the experimental rust tor client.
