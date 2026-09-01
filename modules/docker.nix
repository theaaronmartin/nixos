# Docker engine. Split out of network.nix (2026-09-01) so a host can have
# containers without also inheriting the reverse proxy and its open ports.
{
  virtualisation.docker.enable = true;
}
