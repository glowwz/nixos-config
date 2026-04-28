{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.ncs.homeModules.default
  ];

  home.username = "glowz";
  home.homeDirectory = "/home/glowz";

  programs.niri-caelestia-shell = {
    enable = true;
    systemd.enable = false;
    niri.installConfig = true;
  };

  home.packages = with pkgs; [
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
    neovim
    tmux
    ripgrep
    fd
    bat
    eza
    fzf
    fastfetch
    lazygit
    wl-clipboard
    unzip
    curl
    jq
    stylua
    chafa
    gcc
    nodejs
    python3
    gdb
    delve
    rustup
  ];

  programs.git = {
    enable = true;
    settings.user.name = "glowwz";
    settings.user.email = "aaron0xc1@gmail.com";
    signing.format = null;
  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    initContent = builtins.readFile ./dotfiles/.zshrc;
  };

  xdg.configFile."zsh/plugins/fzf-tab".source = inputs.zsh-fzf-tab;
  xdg.configFile."zsh/plugins/zsh-autosuggestions".source = inputs.zsh-autosuggestions;
  xdg.configFile."zsh/plugins/zsh-syntax-highlighting".source = inputs.zsh-syntax-highlighting;
  xdg.configFile."zsh/plugins/zsh-history-substring-search".source = inputs.zsh-history-substring-search;

  xdg.configFile."kitty/kitty.conf".source = ./dotfiles/kitty/kitty.conf;
  xdg.configFile."kitty/scroll_mark.py".source = ./dotfiles/kitty/scroll_mark.py;
  xdg.configFile."kitty/search.py".source = ./dotfiles/kitty/search.py;

  home.activation.seedKittyTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
    conf="$HOME/.config/kitty/current-theme.conf"
    if [ ! -f "$conf" ]; then
      cp ${./dotfiles/kitty/current-theme.conf} "$conf"
      chmod 644 "$conf"
    fi
  '';

  xdg.configFile."fastfetch/config.jsonc".source = ./dotfiles/fastfetch/config.jsonc;

  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    mouse = true;
    baseIndex = 1;
    prefix = "C-a";
    extraConfig = builtins.readFile ./dotfiles/.tmux.conf;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      resurrect
      continuum
      catppuccin
      copycat
      open
    ];
  };

  xdg.configFile."nvim" = {
    source = ./dotfiles/nvim;
    recursive = true;
  };

  xdg.desktopEntries = {
    btop = {
      name = "btop";
      exec = "kitty btop";
      icon = "utilities-terminal";
      type = "Application";
      terminal = false;
      categories = ["System" "Monitor"];
    };
  };

  xdg.configFile."niri/config/99-user-extra.kdl".text = ''
    // Output --- NCS/KDL equivalent of the old dms-style output block.
    // Adjust mode / scale / position to your actual hardware.
    output "eDP-1" {
        mode "1920x1080@120.030"
        scale 2
        transform "normal"
        position x=0 y=0
    }

    // Keyboard layout override
    input {
        keyboard {
            xkb {
                layout "us"
            }
        }
    }
  '';

  home.pointerCursor = {
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 13;
    gtk.enable = true;
  };

  home.stateVersion = "24.11";
}
