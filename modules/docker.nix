# Docker engine. Split out of network.nix (2026-09-01) so a host can have
# containers without also inheriting the reverse proxy and its open ports.
{
  virtualisation.docker.enable = true;

  # Containers inherit dockerd's open-files limit unless daemon.json sets a default. That was
  # 1024 soft (systemd's default), and LocalStack's runtime ran out of file descriptors under
  # web-automation-v2's acceptance suite: `[Errno 24] Too many open files`, bare 401s on valid
  # tokens (2026-09-22, twice on 2026-09-24). 65536 soft is ample headroom without the very large
  # soft limit some programs mishandle (fd-closing loops scale with it); the hard limit stays at
  # the 524288 containers already get. Applies to containers created after the daemon restarts,
  # so re-create the LocalStack stack after switching.
  virtualisation.docker.daemon.settings.default-ulimits.nofile = {
    Name = "nofile";
    Soft = 65536;
    Hard = 524288;
  };
}
