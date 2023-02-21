{ config, pkgs, modulesPath, lib, environment, ... }:
{
  imports = lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
    ./ship.nix
    ./sites/ihp-app-one.nix
    ./sites/ihp-app-two.nix
  ];

  services.cron = {
    enable = false;
    systemCronJobs = [
      # "*/30 * * * *      root    ${ihpApp}/bin/SomeScript"
    ];
  };

  nix.settings.substituters = [ "https://digitallyinduced.cachix.org" ];
  nix.settings.trusted-public-keys = [ "digitallyinduced.cachix.org-1:y+wQvrnxQ+PdEsCt91rmvv39qRCYzEgGQaldK26hCKE=" ];

  security.acme.defaults.email = "youremail@email.com";
  security.acme.acceptTerms = true;

  # Common nginx settings
  services.nginx = {
    enable = true;
    enableReload = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
  };


  # Databases
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql;
    ensureDatabases = [ "ihp_app_one" "ihp_app_two" ];
    ensureUsers = [
      {
        name = "shipadmin";
        ensurePermissions = {
          "DATABASE ihp_app_one" = "ALL PRIVILEGES";
          "DATABASE ihp_app_two" = "ALL PRIVILEGES";
        };
      }
    ];
    # Set to true if you want to access your database from an external database manager like Beekeeper Studio
    enableTCPIP = false;
    authentication = ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
      host all all 0.0.0.0/0 md5
    '';
  };

  swapDevices = [{ device = "/swapfile"; size = 2048; }];

  # Add system-level packages for your server here
  environment.systemPackages = with pkgs; [
    bash
    jc
  ];

  # Loads global environment variables into shell. Remove this if you don't want this enabled
  environment.shellInit = "set -o allexport; source /etc/shipnix/.env; set +o allexport";

  nix.settings.sandbox = false;

  # Automatic garbage collection. Enabling this frees up space by removing unused builds periodically
  nix.gc = {
    automatic = false;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  programs.vim.defaultEditor = true;

  services.fail2ban.enable = true;
  system.stateVersion = "22.11";
}

