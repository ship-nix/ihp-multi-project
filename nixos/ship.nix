# Shipnix recommended settings
# IMPORTANT: These settings are here for ship-nix to function properly on your server
# Modify with care

{ config, pkgs, modulesPath, lib, ... }:
{
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes ca-derivations
    '';
    settings = {
      trusted-users = [ "root" "ship" "nix-ssh" ];
    };
  };

  programs.git.enable = true;
  programs.git.config = {
    advice.detachedHead = false;
  };

  services.openssh = {
    enable = true;
    # ship-nix uses SSH keys to gain access to the server
    # Manage permitted public keys in the `authorized_keys` file
    passwordAuthentication = false;
    #  permitRootLogin = "no";
  };


  users.users.ship = {
    isNormalUser = true;
    extraGroups = [ "wheel" "nginx" ];
    # If you don't want public keys to live in the repo, you can remove the line below
    # ~/.ssh will be used instead and will not be checked into version control. 
    # Note that this requires you to manage SSH keys manually via SSH,
    # and your will need to manage authorized keys for root and ship user separately
    openssh.authorizedKeys.keyFiles = [ ./authorized_keys ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDA5Yuc6VjGdziJVza1LX/Fv4YK7TFS1wCgPNkFNJ9ODFO54CILo5fA/Xj2PQLy1IkQ22rn5xt9CfeRsO8iQvpz0PB9T59G95xXC7Z6zCMPlnqxJEoFqJVZ+4Q4It4va6/3jNwqvVgVs3eGfP/5iI+i57ksZrIpnEGL1Xa7oiVzLw1y9Hqk82gxgJwn/n2ISZM1mSQvzx0WyIpkKgrf77FURcXkWEY6X4WO13ZciDhXnivOI/tuvkY/pSMTbw+6QbbTe7BHaB+akGtH9J6RvTt8QE85mQTP+vGH6T9Gj5ovL0foIdSbLctZ75ttGyV0KUya5bGqMjkQ14F8alPGvgV+aTHHRT4xDJ4dK1lKO7NxlcPgOCAFttTxBt1TZfLzHIfXPS4hQVAWhD5laxl+ciOm0Zisl6SCgnH5ZpxRgh88jZBwF9gP7I+8nClM9irjzpvN50eQnuSHXKcTjq+SlzWXkVHebcFkNddYLWjtsnDsMdWTkpid7xjsBaPMNYZcWUM= lillo@kodeFant
"
    ];
  };

  # Can be removed if you want authorized keys to only live on server, not in repository
  # Se note above for users.users.ship.openssh.authorizedKeys.keyFiles
  users.users.root.openssh.authorizedKeys.keyFiles = [ ./authorized_keys ];
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDA5Yuc6VjGdziJVza1LX/Fv4YK7TFS1wCgPNkFNJ9ODFO54CILo5fA/Xj2PQLy1IkQ22rn5xt9CfeRsO8iQvpz0PB9T59G95xXC7Z6zCMPlnqxJEoFqJVZ+4Q4It4va6/3jNwqvVgVs3eGfP/5iI+i57ksZrIpnEGL1Xa7oiVzLw1y9Hqk82gxgJwn/n2ISZM1mSQvzx0WyIpkKgrf77FURcXkWEY6X4WO13ZciDhXnivOI/tuvkY/pSMTbw+6QbbTe7BHaB+akGtH9J6RvTt8QE85mQTP+vGH6T9Gj5ovL0foIdSbLctZ75ttGyV0KUya5bGqMjkQ14F8alPGvgV+aTHHRT4xDJ4dK1lKO7NxlcPgOCAFttTxBt1TZfLzHIfXPS4hQVAWhD5laxl+ciOm0Zisl6SCgnH5ZpxRgh88jZBwF9gP7I+8nClM9irjzpvN50eQnuSHXKcTjq+SlzWXkVHebcFkNddYLWjtsnDsMdWTkpid7xjsBaPMNYZcWUM= lillo@kodeFant
"
  ];

  security.sudo.extraRules = [
    {
      users = [ "ship" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" "SETENV" ];
        }
      ];
    }
  ];
}
