# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Grow the last (root) partition to fill the whole disk at boot, then
  # resize the root filesystem to match. Lets a VMware disk be enlarged
  # and have the space picked up automatically on next boot.
  boot.growPartition = true;
  fileSystems."/".autoResize = true;

  # Swap file (no dedicated partition needed; coexists with growPartition).
  swapDevices = [{
    device = "/var/swapfile";
    size = 8192;  # MB
  }];

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    # VMware SVGA video driver (modesetting works too, but this matches the guest).
    videoDrivers = [ "vmware" ];
    # Enable the XFCE Desktop Environment.
    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;
    # Configure keymap in X11
    xkb.layout = "de";
    xkb.variant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  security.rtkit.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "kjp"; # Define your hostname.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  virtualisation.docker.enable = true;
  programs.extra-container.enable = true;

  # VMware guest optimizations: installs open-vm-tools and enables the
  # guest daemon (time sync, graceful shutdown, clipboard/drag-and-drop,
  # automatic screen resizing).
  virtualisation.vmware.guest.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups = {
    matthias = { gid = 1000; };
  };

  # Root password. Generate the hash with: mkpasswd -m sha-512
  users.users.root.hashedPassword = "$6$VuKAyTFzw81H8Qhv$CDAkOeusF0L/b7hWW1geYtDTQ1QtdFq9kQLsR1bVc6zd9KnkPHHLBlja9BCNpTBIVKMzq78Rnfn.VpugznNHn.";

  users.users = {
    matthias = {
      uid = 1000;
      isNormalUser = true;
      description = "Matthias Bolz";
      # Generate the hash with: mkpasswd -m sha-512
      hashedPassword = "$6$ReRSGXwBvQZFaUNz$zKze.KugF7L8TSyhP5ZWViARq2w6vf7pm1vclUXQW79uQ1Cho15cgQbiQxBmFGe0Eoj4r7zyr9rfth7RsJ9g3/";
      extraGroups = [ "networkmanager" "wheel" "docker"];
      packages = with pkgs; [
      ];
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLem/1L0O0y+y5H/ka6ewk2weuohwG2JMGbv49xbSHIYulM9hFw3brPD2hTTDqkRHu+mrDwH9oFj6uQBhTlGTJQ1VEdY9wISRG9mGsYjT2q4ijWwwMQrNkyXYEBXZRnNIh7dWElqH8S8shAY8fAebPlFNfruIMA9Q/+aUWWFfVU9lXIKEEe5g/b8vHOv6CivetlkXrjcziFS/JZmYdtANg7hD0otsVZkaKITFivIXleYHOYoXIoaoocj5y8W0l3ewN81Mj73cimqNZBpSRcf0M4X73+R25U9HhEewsXH5ZzyVIQOowhVUwWlNm5VH9V1FUAGQPTAMuVe++gjyO+fTl matthias@lorien" ];
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Allow flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    git
    ncdu
    gdu
    dua
    unison
    tmux
    # herdr  # not in nixpkgs — provide via overlay/flake input before re-enabling
    rclone
    cryptomator
    docker-compose
    httm
  ];

  # Or disable the firewall altogether.
  networking.firewall.enable = false;


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  #networking.firewall = {
  #  enable = true;
  #    # for NFSv3; view with `rpcinfo -p`
  #  allowedTCPPorts = [ 111 2049 4000 4001 4002 20048 3000 9090 ];
  #  allowedUDPPorts = [ 111 2049 4000 4001 4002 20048 3000 9090 ];
  #};

services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "LUKAS";
        "server string" = "kjp";
        "netbios name" = "kjp";
        "security" = "user";
        #"use sendfile" = "yes";
        #"max protocol" = "smb2";
        # note: localhost is the ipv6 localhost ::1
        "hosts allow" = "192.168. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      "private" = {
        "path" = "/mnt/vault";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  # services.postgresql = {
  #   enable = true;
  #   ensureDatabases = [ "private" "ecsplico" "matthias" ];
  #   ensureUsers = [
  #     {
  #       name = "gitea";
  #     }
  #     {
  #       name = "matthias";
  #       ensureDBOwnership = true;
	# ensureClauses.login = true;
  #     }
  #   ];
  #   dataDir = "/srv/postgresql/${config.services.postgresql.package.psqlSchema}";
  #   extensions = with config.services.postgresql.package.pkgs; [
  #     pg_repack
  #     pgvector
  #   ];
  #   enableTCPIP = true;
  #   # port = 5432;
  #   authentication = pkgs.lib.mkOverride 10 ''
  #     #type database  DBuser  auth-method
  #     local all       all     trust
  #     #...
  #     #type database DBuser origin-address auth-method
  #     # ipv4
  #     host  all      all     127.0.0.1/32   trust
  #     # ipv6
  #     host all       all     ::1/128        trust
  #     # Database access to username database only
  #     local sameuser  all     peer        map=superuser_map
  #     host all 	     all  192.168.7.1/24 scram-sha-256
  #   '';
  #   initialScript = pkgs.writeText "backend-initScript" ''
  #     CREATE ROLE nixcloud WITH LOGIN PASSWORD 'nixcloud' CREATEDB;
  #     CREATE DATABASE nixcloud;
  #     GRANT ALL PRIVILEGES ON DATABASE nixcloud TO nixcloud;
  #   '';
  #   identMap = ''
  #     # ArbitraryMapName systemUser DBUser
  #        superuser_map      root      postgres
  #        superuser_map      postgres  postgres
  #        # Let other names login as themselves
  #        superuser_map      /^(.*)$   \1
  #   '';
  # };

  # services.pgadmin = {
  #   enable = true;
  #   initialEmail = "matthias.bolz@gmail.com";
  #   initialPasswordFile = "/etc/nixos/pgpass";

  # };

}
