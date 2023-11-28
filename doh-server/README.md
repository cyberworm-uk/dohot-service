# doh-front
This is a packaged [doh-server](https://github.com/DNSCrypt/doh-server).

It's not part of the main release, but if you wanted to setup DOH for clients to access this, you could do so.

- Add `-p 127.0.0.1:3000:3000` to the `dohot` pod so that port 3000 is published.
- Add an additional container to the pod, `podman run -d --rm --pod dohot --name dohot-dohfront ghcr.io/cyberworm-uk/doh-front:latest -l 0.0.0.0:3000 -u 127.0.0.1:53`
- Setup your preferred/existing TLS reverse proxy to serve the `/dns-query` path from 127.0.0.1:3000, alternatively specify a custom expected path by passing `-p /your-custom-path` to the container and use that rather than `/dns-query`.

```
# podman run --rm ghcr.io/cyberworm-uk/doh-front:latest --help
A DNS-over-HTTPS (DoH) and ODoH (Oblivious DoH) proxy

Usage: doh-proxy [OPTIONS]

Options:
  -H, --hostname <hostname>
          Host name (not IP address) DoH clients will use to connect
  -g, --public-address <public_address>
          External IP address DoH clients will connect to
  -j, --public-port <public_port>
          External port DoH clients will connect to, if not 443
  -l, --listen-address <listen_address>
          Address to listen to [default: 127.0.0.1:3000]
  -u, --server-address <server_address>
          Address to connect to [default: 9.9.9.9:53]
  -b, --local-bind-address <local_bind_address>
          Address to connect from
  -p, --path <path>
          URI path [default: /dns-query]
  -c, --max-clients <max_clients>
          Maximum number of simultaneous clients [default: 512]
  -C, --max-concurrent <max_concurrent>
          Maximum number of concurrent requests per client [default: 16]
  -t, --timeout <timeout>
          Timeout, in seconds [default: 10]
  -T, --min-ttl <min_ttl>
          Minimum TTL, in seconds [default: 10]
  -X, --max-ttl <max_ttl>
          Maximum TTL, in seconds [default: 604800]
  -E, --err-ttl <err_ttl>
          TTL for errors, in seconds [default: 2]
  -K, --disable-keepalive
          Disable keepalive
  -P, --disable-post
          Disable POST queries
  -O, --allow-odoh-post
          Allow POST queries over ODoH even if they have been disabed for DoH
  -h, --help
          Print help
  -V, --version
          Print version
```
