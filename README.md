# Homelab

Configuration files used to self-host my own homelab.

Any encountered documentation in this repository is mainly for me as I can quickly forget things :)
and it might be out of date.

## Structure

`stacks/` directory stores configuration of all other services, split into categories.

## Network diagram

> [!WARNING]
> The diagram shows a high level overview of interaction between services and other network
> devices. Some services are encapsulated further in private docker networks.

<!-- TODO: create readme.md in streaming stack -->
<!-- TODO: Tailscale setup -->
<!-- TODO: split the diagram into several ones across stacks with different level of details -->
```mermaid
graph TB
    FreeLabel["Internet"]:::invisible

    ExtPC["🖥️ External PCs"]
    Strava_API["🚴 Strava API"]
    Tailscale_Server["🌐 Tailscale Control Server<br/>(orchestration)"]
    ISP["📡 ISP"]
    DNSSP["🗺️ DNS provider<br/>Registrar"]
    Spotify_API["🎶 Spotify API"]

    subgraph LAN["🏠 Local Network"]
        Router["🔌 Router"]
        Modem["📡 Modem"]
        LAN_Devices["📱 LAN Devices"]

        subgraph Host["🖥️ Homelab Server"]
            Caddy["🔒 Caddy<br/>(reverse proxy)<br/>:80 / :443"]
            Homepage["📋 Homepage<br/>:3000"]
            PiHole["🛡️ Pi-Hole<br/>(DNS + adblock)<br/>:53 / :82"]
            Dockhand["🐳 Dockhand<br/>:9443"]
            Filebrowser["📁 File Browser<br/>:8080"]
            SFS["🚴 Statistics for Strava<br/>:8082"]
            Jellyfin["🎬 Jellyfin<br/>:8096 / (tailnet)"]
            Yourspotify["🎵 Yourspotify<br/>:3000, :8080"]
            Streaming["📺 Streaming stack<br/>(reference)"]

            Tailscale["🌐 Tailscale Machine<br/>(tailnet)"]
        end
    end

    %% LAN device access
    LAN_Devices -->|"HTTP"| Caddy

    %% Caddy reverse proxies
    Caddy -->|"home.*"| Homepage
    Caddy -->|"dns.*"| PiHole
    Caddy -->|"docker.*"| Dockhand
    Caddy -->|"files.*"| Filebrowser
    Caddy -->|"tv.*"| Jellyfin
    Caddy -->|"strava.*"| SFS
    Caddy -->|"router.*"| Router
    Caddy -->|"modem.*"| Modem
    Caddy -->|"spotify.*"| Yourspotify
    Caddy -->|"_various_.*"| Streaming

    %% Caddy uses DNS service provider for DNS-01 TLS challenge
    Caddy -->|"TLS challenge"| DNSSP

    %% Tailscale proxies Jellyfin externally
    Tailscale -->|"svc:tv"| Jellyfin

    %% DNS resolution
    LAN_Devices -->|"DNS :53"| Router
    Router -->|"DNS :53"| PiHole
    PiHole -->|"DNS :53 (fallback)"| Modem
    Modem -->|"DNS :53"| ISP
    PiHole -->|"*.home.arpa"| Caddy

    %% External access
    Tailscale_Server ---|"Tailscale tunnel"| ExtPC
    Tailscale_Server -->|"Tailscale tunnel"| Tailscale
    SFS -->|"OAuth"| Strava_API
    Yourspotify -->|"OAuth2"| Spotify_API

    %% Styling
    classDef invisible fill:none,stroke:none,color:#dd0000,font-size:20pt
    classDef localdevice stroke:#00dd00,stroke-dasharray: 5 5,stroke-width:2px
    classDef externaldevice stroke:#dd0000,stroke-dasharray: 5 5,stroke-width:2px
    classDef localnet fill:#00ff0022
    classDef dockernet fill:#0000ff22
    classDef reference stroke-dasharray: 5 5,stroke-width:2px

    class Router,Modem,LAN_Devices,Host localdevice
    class ExtPC,Tailscale_Server,Strava_API,ISP,DNSSP,Spotify_API externaldevice
    class LAN localnet
    class Host dockernet
    class Streaming reference
```
