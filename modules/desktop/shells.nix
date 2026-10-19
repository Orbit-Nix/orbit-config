{ config, lib, ... }:

{
  options.mySystem.desktop = {
    shell = lib.mkOption {
      type = lib.types.enum [
        "illogical-impulse"
        "end4-pC"
        "ii-vynx"
        "caelestia"
        "midnight"
        "dms"
        "noctalia"
        "none"
      ];
      default = "illogical-impulse";
      example = "caelestia";
      description = ''
        The active desktop shell suite for this host (Tree view):
        
        ├── Illogical Impulse (selectable parent or specific child)
        │   ├── "illogical-impulse" : Default Illogical Impulse suite
        │   ├── "end4-pC"         : Material 3 Quickshell desktop
        │   └── "ii-vynx"         : vaguesyntax ii-vynx scrolling-dots fork
        ├── Caelestia (selectable parent or specific child)
        │   ├── "caelestia"       : Default Caelestia shell
        │   └── "midnight"        : Midnight Shell (dim-ghub/midnight-shell)
        ├── DMS (selectable, no childs)
        │   └── "dms"             : DankMaterialShell
        └── Noctalia (selectable, no childs)
            └── "noctalia"        : Noctalia Shell
      '';
    };
  };
}
