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

Additionally, for any service that requires HTTPs, Caddy is responsible for SSL certificates
management. Currently, a special build of Caddy is created that installs OVH provider, which is then
used for DNS-01 TLS challenge. When using OVH as CA (instead of self-signed certificates),
browsers do not warn about untrusted SSL. Note that this approach requires buying a domain on OVH.

### WireGuard

WireGuard tunnel is a way to connect two (or more) networks, bypassing their firewalls, which allows
direct communication, even though they are on different remote sites.

The idea is to allow external access to certain services without opening any ports and exposing
the local network to the internet.

In this repository, there is only one end of the tunnel configured - the client. The other end, the
server, is configured on a VPS, which is exposed to the internet.

Here, setup is done using Docker containers, meaning that the tunnel actually connects two docker
networks. This ensures that unwanted access is not spilled to the host system. Only services that
are participants in WireGuard's docker network can be accessed by the WG server.

To differentiate between connections to several various services, a reverse proxy is used, because
there is no need for more than one WireGuard client - it means there's only one endpoint, one IP
address. Details of how reverse proxy is set up are in [this section](#caddy-for-wireguard).

### Caddy for WireGuard

Another instance of Caddy was created to route traffic from WireGuard tunnel to corresponding
services in homelab. To achieve that, the docker container is set up to be on the same
[network namespace](https://docs.docker.com/engine/network/#container-networks) as WireGuard
container.

The reverse proxy catches all tunnel traffic on port `8080`. The other end has to comply with that
and remember to route all traffic to the WG client address at this port.

The server appends an additional custom `X-Target-Service` HTTP header to let the reverse proxy know
which service route the traffic to. How the server decides what requests belong to what service is
defined in WG's configuration on VPS, but it's not relevant on this end. The client can only respect
whatever the server sends through the tunnel. If the custom header is not appended or its value is
not recognized, the traffic is dropped.

The consequence of attaching this Caddy's container's network to WireGuard's is that it loses the
ability to address other Docker containers by their service names (Docker domain name resolution is
not allowed). To circumvent this inconvenience, in the WireGuard Docker network all exposed
services are required to have a static IPv4 address assigned, of course in compliance with a defined
subnet. Static assignment is required as otherwise containers restarts/redeployments could change
their IPs.

Any access control and authentication is managed by the WG server end for simplicity - OAuth2 / Zero
Trust access can be performed directly within the internet, instead of through the tunnel as well.

The reverse proxy instance for local network does not participate at all in network traffic going
through the tunnel.

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
