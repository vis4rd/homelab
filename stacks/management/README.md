# Management stack

'Meta' services which are required for proper working of the home server.

## Services

> [!NOTE]
> Dockhand service is an exception due to being a dependency for all other services. Therefore it is
> stored in the root of this repository.

### Pi-hole

Used as DNS server. Internally uses dnsmasq. It is configured to route all *.local URLs to Caddy.
The rest of URLs route to regular DNS like from Google. It is required to set an IP of the Pi-hole
in router settings so that all devices in local network can use it. Alternatively, each client can
set the DNS IP separately.

### Caddy

Used as reverse proxy. Resolves domain names sent from Pi-hole to individual Docker containers or
other locally deployed services. Therefore all routing rules are actually defined in Caddyfile.

## Local domains

At the moment, there are two local domains used:

1. `*.home.arpa`
2. `*.homelab.local`

The first one is a classic domain, which is then resolved by custom DNS and redirected to a specific
IP address. Any subdomains are handled by a reverse proxy. DNS server usually has to be pointed to
by a router (either from ISP or your own). `.home.arpa` domain is officially reserved for
residential use and defined by [RFC-8375](https://www.rfc-editor.org/rfc/rfc8375). Most devices and
web browsers should automatically recognize it as a local domain.

The second one uses a more modern mechanism called [mDNS](https://en.wikipedia.org/wiki/Multicast_DNS),
which essentially uses device name to match it with its IP address in local network. When any device
sees `*.local` in a request, they broadcast to the entire network the question "whose name is it?".
If such device is present, it responds to the sender. This is why it is crucial to never use
`*.local` domain as a custom local domain in DNS, as it will always clash with
[mDNS](https://en.wikipedia.org/wiki/Multicast_DNS). In this instance, `homelab` is the name of the
home server device hosting all services, that's why it is used.

Sources:

- <https://www.ctrl.blog/entry/homenet-domain-name.html>
- <https://www.stefsmeets.nl/posts/localdomains/>
