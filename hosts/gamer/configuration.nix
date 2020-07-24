# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../soft.nix
    ];
  documentation.dev.enable = true;
  virtualisation.virtualbox.host.enable = true;
  virtualisation.docker.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.pulseaudio.support32Bit = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];

  # Kernel
  boot.blacklistedKernelModules = [ "nvidia" "nouveau" "dvb_usb_rtl28xxu" ];
  # Modified Linux
  #  boot.kernelPatches = [ {
  #    name = "debug-on";
  #    patch = null;
  #    extraConfig = ''
  #      DEBUG_INFO y
  #      KGDB y
  #      GDB_SCRIPTS y
  #    '';
  #  } ];

  # udev
  services.udev.packages = [ pkgs.rtl-sdr ];

  # Networking
  networking = {
    hostName = "gamer"; # Define your hostname.
    hostId = "4e28bfae";
    networkmanager.enable = true;
    extraHosts = builtins.readFile ../../extra_hosts;
    useDHCP = false;
    interfaces.enp3s0.useDHCP = true;
    interfaces.wlp2s0.useDHCP = true;
  };

  # Services
  services.avahi.enable = false;
  services.xserver = {
    enable = true;
    videoDrivers = [ "intel" ];
    libinput.enable = true;
    wacom.enable = true;
    displayManager.startx.enable = true;
  };
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;
  programs.sway.enable = true;
  # workaround to import zpools at boot time
  # ( I don't want to use mountpoint=legacy )
  systemd.services."custom-zfs-import-cache" = {
    enable = true;
    unitConfig = {
      Requires = "systemd-udev-settle.service";
      After = "systemd-udev-settle.service";
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.zfs}/bin/zpool import -aN";
    };
    wantedBy = [  "zfs-import.target" ];
  };

  # Users
  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "systemd-journal" "audio" "libvirtd" "kvm" "vboxusers" "docker" ];
    uid = 1001;
    packages = with pkgs; [
      discord
      nomachine-client
      skypeforlinux
      slack
      steam
      teams
      vscode
      zoom-us
    ];
  };
  # discord, vscode ... requires it
  nixpkgs.config.allowUnfree = true;

  # security
  security.sudo.enable = true;
  security.sudo.configFile = ''
    user ALL=(ALL) NOPASSWD:/run/current-system/sw/bin/mount
    user ALL=(ALL) NOPASSWD:/run/current-system/sw/bin/umount
    user ALL=(ALL) NOPASSWD:/run/current-system/sw/bin/nmtui-connect
  '';
  security.audit = {
    backlogLimit = 8192;
    enable = true;
    failureMode = "printk";
  };
  #security.auditd.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

