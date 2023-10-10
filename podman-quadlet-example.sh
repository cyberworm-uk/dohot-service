#!/usr/bin/env bash
# https://www.redhat.com/sysadmin/quadlet-podman
# https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html

# the PublishPort= entries in dohot-pihole.container are intentionally commented out
# you should ensure that the DNS ports are not exposed to the general internet
# you can either specify a local IP address to bind them to, e.g. PublishPort=192.168.0.2:53:53/tcp
# or ensure a packetfilter/firewall blocks external access

# create the dnscrypt container
echo '[Unit]
Description=DOHOT DNSCrypt container

[Container]
Image=ghcr.io/guest42069/dohproxy:latest
AutoUpdate=registry

Volume=dohot-dnscrypt.volume:/etc/dnscrypt-proxy
Network=dohot.network

[Service]
Restart=always
TimeoutStartSec=900

[Install]
WantedBy=default.target' > dohot-dnscrypt.container

# create the tor proxy container
echo '[Unit]
Description=DOHOT Tor container

[Container]
Image=ghcr.io/guest42069/torproxy:latest
AutoUpdate=registry

Volume=dohot-tor.volume:/var/lib/tor
Network=dohot.network

[Service]
Restart=always
TimeoutStartSec=900

[Install]
WantedBy=default.target' > dohot-tor.container

# create the pihole container
echo '[Unit]
Description=DOHOT Pi-Hole container

[Container]
Image=docker.io/pihole/pihole:latest
AutoUpdate=registry

Volume=dohot-dnsmasq.volume:/etc/dnsmasq.d
Volume=dohot-pihole.volume:/etc/pihole
Volume=dohot-log.volume:/var/log/pihole
Network=dohot.network

PublishPort=53:53/tcp
PublishPort=53:53/udp
PublishPort=3000:80/tcp

Environment=TZ=Europe/London
Environment=DNSSEC=true
Environment=PIHOLE_DNS_=systemd-dohot-dnscrypt#5054
Environment=DNSMASQ_LISTENING=all

[Service]
Restart=always
TimeoutStartSec=900

[Install]
WantedBy=default.target' > dohot-pihole.container

# create the various volumes to store state
echo '[Volume]' | tee dohot-dnsmasq.volume | tee dohot-pihole.volume | tee dohot-log.volume | tee dohot-tor.volume | tee dohot-dnscrypt.volume

# create the shared network for the containers
echo '[Network]
IPv6=true' > dohot.network

# we create this volume manually, it would otherwise be created automatically
# but we wish to pre-populate it with a config file using the tor container.
podman volume create systemd-dohot-dnscrypt

# pre-populate the configuration file for dnscrypt.
echo "listen_addresses = [ '0.0.0.0:5054' ]
disabled_server_names = []
cert_refresh_delay = 60
doh_servers = true
ipv4_servers = false
ipv6_servers = false
dnscrypt_servers = false
block_ipv6 = false
block_unqualified = true
block_undelegated = true
require_nolog = false
require_dnssec = true
require_nofilter = true
force_tcp = true
proxy = 'socks5://systemd-dohot-tor:9050'
timeout = 10000
lb_strategy = 'p2'
log_level = 2
use_syslog = true
log_files_max_size = 64
log_files_max_age = 7
log_files_max_backups = 4
tls_disable_session_tickets = true
tls_cipher_suite = [52392, 49199]
fallback_resolvers = ['1.1.1.1:53', '8.8.8.8:53']
netprobe_address = '8.8.8.8:53'
netprobe_timeout = 60
ignore_system_dns = true
cache = true
cache_size = 4096
cache_min_ttl = 2400
cache_max_ttl = 86400
cache_neg_min_ttl = 60
cache_neg_max_ttl = 600
[query_log]
file = '/var/log/dnscrypt-proxy/query.log'
[nx_log]
file = '/var/log/dnscrypt-proxy/nx.log'
[sources]
[sources.'public-resolvers']
urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md', 'https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md']
minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
cache_file = 'public-resolvers.md'
[sources.'onion-services']
urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/onion-services.md', 'https://download.dnscrypt.info/resolvers-list/v3/onion-services.md']
minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
cache_file = 'onion-services.md'" > $(podman volume inspect -f '{{ .Mountpoint }}' "systemd-dohot-dnscrypt")/dnscrypt-proxy.toml
