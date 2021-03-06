# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../base.nix
    ../../desktop.nix
    ../../electronics.nix
    ../../music.nix
    ../../security.nix
    ../../virt.nix
  ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback exclusive_caps=1 video_nr=10 card_label="OBS Video Source"
  '';
  nixpkgs.config.allowBroken = true;

  # Use the systemd-boot EFI boot loader.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip pkgs.brlaser pkgs.brgenml1lpr ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel
  boot.blacklistedKernelModules = [ "nvidia" "nouveau" "dvb_usb_rtl28xxu" ];

  # Services
  systemd.services.systemd-udev-settle.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';
  services.xserver.videoDrivers = [ "amdgpu" ];
  # Networking
  networking = {
    hostName = "gamer"; # Define your hostname.
    hostId = "4e28bfae";
    networkmanager.enable = true;
    extraHosts = builtins.readFile ../../extra_hosts;
    useDHCP = false;
    firewall.allowedTCPPorts = [ 1234 5064 6064 5065 6065 5075 6075 7011 7012 ];
    firewall.allowedUDPPorts = [ 5064 6064 5065 6065 5076 ];
  };

  # gnupg agent
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "gnome3";
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  # User
  users.users.user = {
    uid = 1001;
    isNormalUser = true;
    extraGroups = [
      "audio"
      "dialout"
      "networkmanager"
      "plugdev"
      "systemd-journal"
      "video"
    ];
    packages = with pkgs; [
      discord
      nomachine-client
      openscad
      skypeforlinux
      slack
      steam
      teams
      vscode-with-extensions
      zoom-us
    ];
  };
  # discord, vscode ... require it
  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

