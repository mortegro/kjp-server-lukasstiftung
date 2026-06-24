{ modulesPath, pkgs, lib, self, ... }:
{
  imports = [
    # swap for installation-cd-graphical-xfce.nix if you want a GUI live env
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  # Bake the entire flake into the live ISO at /etc/nixos (read-only copy
  # from the Nix store). This is what makes the config "predefined".
  environment.etc."nixos".source = self.outPath;

  # OPTIONAL — bake the target system's full closure into the ISO so the
  # install works with NO network at all. Makes the ISO much larger.
  # system.extraDependencies = [
  #   self.nixosConfigurations.kjp.config.system.build.toplevel
  # ];

  environment.systemPackages = [
    pkgs.git
    pkgs.vim
    (pkgs.writeShellScriptBin "install-kjp" ''
      set -euo pipefail
      echo ">>> Partitioning with disko (/etc/nixos/disko.nix) ..."
      ${pkgs.disko}/bin/disko --mode disko /etc/nixos/disko.nix
      echo ">>> Installing 'kjp' from the baked-in flake at /etc/nixos ..."
      nixos-install --flake /etc/nixos#kjp "$@"
      echo ">>> Done. Detach the ISO and reboot."
    '')
  ];

  # VMware guest tooling in the live environment too.
  virtualisation.vmware.guest.enable = true;

  # Make the installer pleasant to drive over SSH.
  services.openssh.enable = true;
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
  # Real root password on the live ISO (console + SSH password login).
  # Same hash as the installed system. Overrides the media's empty default.
  users.users.root.hashedPassword = "$6$VuKAyTFzw81H8Qhv$CDAkOeusF0L/b7hWW1geYtDTQ1QtdFq9kQLsR1bVc6zd9KnkPHHLBlja9BCNpTBIVKMzq78Rnfn.VpugznNHn.";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLem/1L0O0y+y5H/ka6ewk2weuohwG2JMGbv49xbSHIYulM9hFw3brPD2hTTDqkRHu+mrDwH9oFj6uQBhTlGTJQ1VEdY9wISRG9mGsYjT2q4ijWwwMQrNkyXYEBXZRnNIh7dWElqH8S8shAY8fAebPlFNfruIMA9Q/+aUWWFfVU9lXIKEEe5g/b8vHOv6CivetlkXrjcziFS/JZmYdtANg7hD0otsVZkaKITFivIXleYHOYoXIoaoocj5y8W0l3ewN81Mj73cimqNZBpSRcf0M4X73+R25U9HhEewsXH5ZzyVIQOowhVUwWlNm5VH9V1FUAGQPTAMuVe++gjyO+fTl matthias@lorien"
  ];
}
