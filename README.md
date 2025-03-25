# dohot-service
DNS Over HTTPS Over Tor

Anonymized DNS with (optional) adblocking with [Tor](https://torproject.org/), [DNSCrypt-Proxy](https://github.com/DNSCrypt/dnscrypt-proxy) and [Pi-Hole](https://github.com/pi-hole/pi-hole).

Cribbed from [Alec Muffett's DoHoT](https://github.com/alecmuffett/dohot).

## Update

As part of general improvements, I've consolidated and reformatted the backing containers. `tor-proxy` is now `tor-client` and `dohot-proxy` is now `dnscrypt-proxy`.

The associated [dockerfiles are available here](https://github.com/cyberworm-uk/containers).

I've also replaced podman deployment scripts with `podman kube play ...` compatible kubernete resource definitions and podman quadlet service definitions.

## Overview

`tor` is run as a client, exposing a SOCKS proxy.

`dnscrypt-proxy` is run, configured to use the `tor` clients SOCKS proxy to connect and resolve over a wide selection of DOH servers.

`pihole` is optionally run, configured to use `dnscrypt-proxy` as it's upstream resolver.

End user devices should be resolving via DNS provided by `pihole` to take advantage of the ad-blocking.

`pihole` or `dnscrypt-proxy` should not be exposed to the internet at large, lest it be used as part of a DNS amplification attack. It should be listening on a LAN/VPN IP or a packet filter should restrict incoming DNS queries to only intended client devices.

Replace the existing container definition of the `ghcr.io/cyberworm-uk/tor-client:latest` image with an equivalent `ghcr.io/cyberworm-uk/arti:latest` if you want to use the experimental rust tor client. See more details [here](https://github.com/cyberworm-uk/containers/tree/main/tor#arti)

## Docker Compose

Inside the `/docker` folder, there are two yaml files, one regular and one nopihole. Simply launch the service with `docker compose -f docker-compose.yml up -d` or replace `docker-compose.yml` with `docker-compose-nopihole.yml` to not use pihole.

## Podman

Inside the `/podman` folder, there are two `.kube` and `.yml` files, one regular and one nopihole. You can simply launch them with `podman kube play dohot.yaml` or replace `dohot.yaml` with `dohot-nopihole.yaml` to not use pihole.

You can review logs with `podman pod logs dohot` (or `dohot-nopihole`)

Alternatively if you want to ensure the service is started automatically, place the appropriate `.kube`, `.network` and `.yaml` files in `/etc/containers/systemd/` (or `$XDG_RUNTIME_DIR/containers/systemd/` for rootless).

Then issue `systemctl daemon-reload` (appending `--user` for rootless) to load the `.kube` and `.network` services as systemd units, then `systemctl start dohot` or `dohot-nopihole` (again, appending `--user` for rootless) as appropriate to launch the service.

## PiHole Notes

PiHole will generate a new password when first launched, this will be printed to the logs.

### Podman

`podman logs dohot-pihole` should give you access to the logs.

Alternatively `podman exec -it dohot-pihole pihole setpassword` can be used to set a new password from the command line.

### Docker

`docker compose -f docker-compose.yml logs` should give you access to the logs.

Alternatively `docker compose -f docker-compose.yml exec pihole pihole setpassword` can be used to set a new password from the command line.