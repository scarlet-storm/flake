{
  pkgs,
  ...
}:

{
  users.users.kanata = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    linger = false;
    uid = 1000;
    shell = pkgs.fish;
    createHome = true;
    group = "kanata";
    hashedPassword = "$y$j9T$et55Z2t4KqNaTEX.IlDIB.$Rckgxg5X/o8V1yZ5MlfCJlaJTyetNy8wOpeh3.N6VcA";
  };
  users.groups.kanata = {
    gid = 1000;
  };
}
