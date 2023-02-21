{ config, pkgs, modulesPath, lib, environment, ihp-app-one, ... }:
let
  # TODO: Enable SSL
  # By enabling SSL, you accept the terms and conditions of LetsEncrypt
  isHttpEnabled = false;
  jobsEnabled = false;
in
{
  services.nginx.virtualHosts = {
    "ihp-private-1.com" = {
      serverName = "ihp-private-1.com";
      default = true;
      enableACME = isHttpEnabled;
      serverAliases = [ "www.ihp-private-1.com" ];
      forceSSL = isHttpEnabled;
      locations = {
        "/" = {
          proxyPass = "http://localhost:8000";
          proxyWebsockets = true;
          extraConfig =
            # required when the target is also TLS server with multiple hosts
            "proxy_ssl_server_name on;" +
            # required when the server wants to use HTTP Authentication
            "proxy_pass_header Authorization;";
        };
      };
    };
  };

  systemd.services.ihp_app_one = {
    description = "Project one service";
    enable = true;
    after = [
      "network.target"
      "postgresql.service"
    ];
    wantedBy = [
      "multi-user.target"
    ];
    serviceConfig = {
      Type = "simple";
      User = "ship";
      Restart = "always";
      WorkingDirectory = "${ihp-app-one}/lib";
      EnvironmentFile = /etc/shipnix/multi-env/ihp-private-one;
      ExecStart = '' ${ihp-app-one}/bin/RunProdServer '';
    };
  };

  systemd.services.ihp_app_one_jobs = {
    description = "IHP job watcher";
    enable = jobsEnabled;
    after = [ "ship.service" ];
    wantedBy = [
      "multi-user.target"
    ];
    serviceConfig = {
      Type = "simple";
      User = "ship";
      Restart = "always";
      WorkingDirectory = "${ihp-app-one}/lib";
      EnvironmentFile = /etc/shipnix/multi-env/ihp-private-one;
      ExecStart = '' ${ihp-app-one}/bin/RunJobs '';
    };
  };
}

