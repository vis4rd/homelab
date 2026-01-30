## Management stack

'Meta' services which are required for proper working of the home server.

> [!NOTE]
> Portainer service is an exception due to being a dependency for all other services. Therefore it is stored in the root of this repository.

# Pi-hole

Used as DNS server. Internally uses dnsmasq. It is configured to route all *.local URLs to Caddy. The rest of URLs route to regular DNS like from Google. It is required to set an IP of the Pi-hole in router settings so that all devices in local network can use it. Alternatively, each client can set the DNS IP separately.

# Caddy

Used as reverse proxy. Resolves domain names sent from Pi-hole to individual Docker containers or other locally deployed services. Therefore all routing rules are actually defined in Caddyfile.
