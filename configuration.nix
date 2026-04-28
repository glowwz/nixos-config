{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = false;
    };
  };

  networking.hostName = "nix";
  time.timeZone = "America/Santiago";
  i18n.defaultLocale = "es_CL.UTF-8";

  console.keyMap = "us";
  services.xserver.xkb.layout = "us";

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    trusted-users = [ "root" "@wheel" ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nixpkgs.config.allowUnfree = true;

  users.users.glowz = {
    isNormalUser = true;
    description = "glowz";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    fuse3
    icu
    nss
    openssl
    curl
    expat
  ];

  networking.networkmanager.enable = true;
  services.openssh.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  programs.niri.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.niri-caelestia-shell = {
    enable = true;

    systemd = {
      enable = true;
      environment = [
        "QT_QPA_PLATFORM=wayland"
        "PATH=/etc/profiles/per-user/glowz/bin"
      ];
    };

    settings.general.apps.terminal = "kitty";

    features = {
      systemMonitor = true;
      dynamicTheming = true;
      audioVisualizer = true;
      clipboardManager = true;
    };
  };

  home-manager.backupFileExtension = "hm-backup";

  # --- NVIDIA ---------------------------------------------------------------
  # RTX 2070 Super (Turing) desktop — Wayland + niri
  # ---------------------------------------------------------------------------

  hardware.cpu.intel.updateMicrocode = true;
  boot.initrd.kernelModules = [ "nvidia" "nvidia_drm" "nvidia_modeset" "nvidia_uvm" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    powerManagement.enable = true;
    forceFullCompositionPipeline = true;
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME         = "nvidia";
    GBM_BACKEND               = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NIXOS_OZONE_WL            = "1";
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    htop
    firefox
    kitty
    tmux
    neovim
    (inputs._0fetch.packages.${pkgs.stdenv.hostPlatform.system}.default)
  ];

  system.stateVersion = "24.11";
}
