{ config, lib, pkgs, osConfig ? {}, ... }:

let
  # Determine if Nautilus is selected on the host system
  nautilusSelected =
    if osConfig ? mySystem && osConfig.mySystem ? apps && osConfig.mySystem.apps ? fileManagers
    then builtins.elem "nautilus" osConfig.mySystem.apps.fileManagers
    else true;

  cfg = config.orbitos.nautilus;

  # Helper to write executable scripts for Nautilus
  mkNautilusScript = name: text: pkgs.writeShellScript "nautilus-script-${name}" text;

  # --- RIGHT CLICK SCRIPTS DEFINITIONS ---
  scripts = {
    "Compress" = mkNautilusScript "compress" ''
      PATH="${lib.makeBinPath (with pkgs; [ zenity ffmpeg libnotify coreutils gnugrep gawk gnused bc ])}:$PATH"
      set -euo pipefail

      TARGET_SIZE_RAW=$(zenity --entry \
        --title="Compress Video to Target Size" \
        --text="Enter target size (e.g. 15MB, 50MB, 1GB):" \
        --entry-text="25MB" || true)

      [ -z "$TARGET_SIZE_RAW" ] && exit 0

      # Normalize input
      UNIT=$(echo "$TARGET_SIZE_RAW" | tr -d '0-9. ' | tr '[:lower:]' '[:upper:]')
      VAL=$(echo "$TARGET_SIZE_RAW" | tr -cd '0-9.')

      if [ "$UNIT" = "GB" ] || [ "$UNIT" = "G" ]; then
        TARGET_BYTES=$(echo "$VAL * 1024 * 1024 * 1024" | bc)
      else
        TARGET_BYTES=$(echo "$VAL * 1024 * 1024" | bc)
      fi

      TARGET_BITS=$(echo "$TARGET_BYTES * 8" | bc)

      echo -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | while IFS= read -r file; do
        [ -z "$file" ] && continue
        [ ! -f "$file" ] && continue

        notify-send -a "OrbitOS Video Compressor" "Compressing $(basename "$file")..." "Target size: $TARGET_SIZE_RAW"

        DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file" || echo "0")
        DURATION_INT=''${DURATION%.*}

        if [ -z "$DURATION_INT" ] || [ "$DURATION_INT" -le 0 ]; then
          notify-send -u critical -a "OrbitOS Video Compressor" "Error" "Could not determine duration for $(basename "$file")"
          continue
        fi

        # Audio bitrate: 128kbps = 128000 bps
        AUDIO_BITRATE=128000
        TOTAL_BITRATE=$(echo "$TARGET_BITS / $DURATION" | bc)
        VIDEO_BITRATE=$(echo "$TOTAL_BITRATE - $AUDIO_BITRATE" | bc)

        if [ "$VIDEO_BITRATE" -le 50000 ]; then
          VIDEO_BITRATE=50000
        fi

        DIR=$(dirname "$file")
        BASE=$(basename "$file")
        FILENAME="''${BASE%.*}"
        OUTPUT="$DIR/''${FILENAME}_compressed.mp4"

        ffmpeg -y -i "$file" \
          -c:v libx264 -b:v "''${VIDEO_BITRATE}" -preset fast \
          -c:a aac -b:a 128k \
          "$OUTPUT" 2>&1 | zenity --progress \
            --title="Compressing $BASE" \
            --text="Compressing to $TARGET_SIZE_RAW..." \
            --pulsate --auto-close || true

        notify-send -a "OrbitOS Video Compressor" "Compression Finished" "Saved to: $(basename "$OUTPUT")"
      done
    '';

    "Send to device" = mkNautilusScript "send-to-device" ''
      PATH="${lib.makeBinPath (with pkgs; [ libnotify coreutils ])}:$PATH"

      FILE=$(echo -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | head -n 1)
      [ -z "$FILE" ] && exit 0

      if command -v rquickshare >/dev/null 2>&1; then
        rquickshare "$FILE" &
      elif command -v localsend >/dev/null 2>&1; then
        localsend "$FILE" &
      elif flatpak info org.localsend.localsend_app >/dev/null 2>&1; then
        flatpak run org.localsend.localsend_app "$FILE" &
      else
        notify-send -u critical -a "Send to Device" "Sharing client not found" "Neither RQuickShare nor LocalSend is available."
      fi
    '';

    "Share via link" = mkNautilusScript "share-via-link" ''
      PATH="${lib.makeBinPath (with pkgs; [ curl wl-clipboard libnotify coreutils ])}:$PATH"
      set -euo pipefail

      echo -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | while IFS= read -r file; do
        [ -z "$file" ] && continue
        [ ! -f "$file" ] && continue

        notify-send -a "OrbitOS Cloud Share" "Uploading..." "Uploading $(basename "$file") to 0x0.st"

        URL=$(curl -s -F "file=@$file" https://0x0.st || true)

        if [[ "$URL" =~ ^https?:// ]]; then
          echo -n "$URL" | wl-copy
          notify-send -i edit-copy -a "OrbitOS Cloud Share" "Link Copied to Clipboard!" "$URL"
        else
          notify-send -u critical -a "OrbitOS Cloud Share" "Upload Failed" "Server response: $URL"
        fi
      done
    '';

    "Bring live" = mkNautilusScript "bring-live" ''
      PATH="${lib.makeBinPath (with pkgs; [ python3 xdg-utils libnotify coreutils ])}:$PATH"

      FILE=$(echo -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | head -n 1)
      [ -z "$FILE" ] && exit 0

      DIR=$(dirname "$FILE")
      FILENAME=$(basename "$FILE")

      # Pick next available port starting from 9800
      PORT=9800
      while ! python3 -c "import socket; s = socket.socket(); s.bind(('127.0.0.1', $PORT)); s.close()" 2>/dev/null; do
        PORT=$((PORT + 1))
      done

      # Launch lightweight python HTTP server serving that folder
      (
        cd "$DIR"
        nohup python3 -m http.server "$PORT" >/dev/null 2>&1 &
      )

      sleep 0.5
      xdg-open "http://localhost:$PORT/$FILENAME"
      notify-send -a "OrbitOS Dev Server" "Live Server Active" "Serving $FILENAME on http://localhost:$PORT/"
    '';

    "Copy Path" = mkNautilusScript "copy-path" ''
      PATH="${lib.makeBinPath (with pkgs; [ wl-clipboard libnotify coreutils ])}:$PATH"

      if [ -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" ]; then
        echo -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | wl-copy
        notify-send -i edit-copy -a "OrbitOS Nautilus" "Path Copied" "Copied selected file path(s) to clipboard."
      fi
    '';

    "Toggle Hide" = mkNautilusScript "toggle-hide" ''
      PATH="${lib.makeBinPath (with pkgs; [ libnotify coreutils gnugrep gnused ])}:$PATH"

      TARGET_DIR="''${NAUTILUS_SCRIPT_CURRENT_URI#file://}"
      TARGET_DIR="$(printf '%b' "''${TARGET_DIR//%/\\x}")"

      echo -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | while IFS= read -r file; do
        [ -z "$file" ] && continue
        NAME="$(basename "$file")"
        PARENT="$(dirname "$file")"
        HIDDEN_FILE="$PARENT/.hidden"
        touch "$HIDDEN_FILE"

        if grep -Fxq "$NAME" "$HIDDEN_FILE"; then
          sed -i "/^$NAME$/d" "$HIDDEN_FILE"
          notify-send -a "OrbitOS Nautilus" "Unhidden" "Removed $NAME from .hidden"
        else
          echo "$NAME" >> "$HIDDEN_FILE"
          notify-send -a "OrbitOS Nautilus" "Hidden" "Added $NAME to .hidden"
        fi
      done
    '';

    "Image Converter" = mkNautilusScript "image-converter" ''
      PATH="${lib.makeBinPath (with pkgs; [ zenity imagemagick libnotify coreutils ])}:$PATH"

      ACTION=$(zenity --list \
        --title="OrbitOS Image Converter" \
        --column="Format / Action" \
        "Convert to PNG" \
        "Convert to JPG" \
        "Convert to WebP" \
        "Convert to AVIF" \
        "Resize 50%" \
        "Resize 75%" \
        "Resize to 1920x1080" || true)

      [ -z "$ACTION" ] && exit 0

      echo -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | while IFS= read -r file; do
        [ -z "$file" ] && continue
        DIR=$(dirname "$file")
        BASE=$(basename "$file")
        NAME="''${BASE%.*}"

        case "$ACTION" in
          "Convert to PNG")  magick "$file" "$DIR/$NAME.png" ;;
          "Convert to JPG")  magick "$file" "$DIR/$NAME.jpg" ;;
          "Convert to WebP") magick "$file" "$DIR/$NAME.webp" ;;
          "Convert to AVIF") magick "$file" "$DIR/$NAME.avif" ;;
          "Resize 50%")      magick "$file" -resize 50% "$DIR/''${NAME}_50%.$BASE" ;;
          "Resize 75%")      magick "$file" -resize 75% "$DIR/''${NAME}_75%.$BASE" ;;
          "Resize to 1920x1080") magick "$file" -resize 1920x1080\> "$DIR/''${NAME}_1080p.$BASE" ;;
        esac

        notify-send -a "OrbitOS Image Converter" "Conversion Finished" "$ACTION on $BASE"
      done
    '';

    "PDF Tools" = mkNautilusScript "pdf-tools" ''
      PATH="${lib.makeBinPath (with pkgs; [ zenity poppler-utils libnotify coreutils ])}:$PATH"

      ACTION=$(zenity --list \
        --title="OrbitOS PDF Tools" \
        --column="Action" \
        "Extract Images from PDF" \
        "Render PDF Pages to PNG" \
        "Merge Selected PDFs" || true)

      [ -z "$ACTION" ] && exit 0

      case "$ACTION" in
        "Extract Images from PDF")
          echo -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | while IFS= read -r file; do
            [ -z "$file" ] && continue
            DIR=$(dirname "$file")
            NAME=$(basename "$file" .pdf)
            mkdir -p "$DIR/''${NAME}_images"
            pdfimages -png "$file" "$DIR/''${NAME}_images/img"
            notify-send -a "OrbitOS PDF Tools" "Extracted" "Saved images to ''${NAME}_images"
          done
          ;;
        "Render PDF Pages to PNG")
          echo -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | while IFS= read -r file; do
            [ -z "$file" ] && continue
            DIR=$(dirname "$file")
            NAME=$(basename "$file" .pdf)
            pdftoppm -png -r 150 "$file" "$DIR/''${NAME}_page"
            notify-send -a "OrbitOS PDF Tools" "Rendered" "Pages exported as PNGs"
          done
          ;;
        "Merge Selected PDFs")
          FIRST=$(echo -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | head -n 1)
          DIR=$(dirname "$FIRST")
          OUT="$DIR/merged_$(date +%Y%m%d_%H%M%S).pdf"
          readarray -t FILES < <(echo -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS")
          pdfunite "''${FILES[@]}" "$OUT"
          notify-send -a "OrbitOS PDF Tools" "Merged" "Saved as $(basename "$OUT")"
          ;;
      esac
    '';

    # Nested Git Submenu
    "Git/Sync (Pull & Push)" = mkNautilusScript "git-sync" ''
      PATH="${lib.makeBinPath (with pkgs; [ git libnotify coreutils ])}:$PATH"

      DIR=$(echo -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | head -n 1)
      [ -z "$DIR" ] && DIR="."
      [ -f "$DIR" ] && DIR=$(dirname "$DIR")

      GIT_ROOT=$(git -C "$DIR" rev-parse --show-toplevel 2>/dev/null || true)
      if [ -z "$GIT_ROOT" ]; then
        notify-send -u critical -a "OrbitOS Git" "Error" "Not a git repository!"
        exit 1
      fi

      notify-send -a "OrbitOS Git" "Syncing..." "Pulling and pushing $GIT_ROOT"
      if git -C "$GIT_ROOT" pull --rebase && git -C "$GIT_ROOT" push; then
        notify-send -a "OrbitOS Git" "Git Sync Success" "Repository is up to date!"
      else
        notify-send -u critical -a "OrbitOS Git" "Git Sync Failed" "Check git status for conflicts or errors."
      fi
    '';

    "Git/Pull" = mkNautilusScript "git-pull" ''
      PATH="${lib.makeBinPath (with pkgs; [ git libnotify coreutils ])}:$PATH"

      DIR=$(echo -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | head -n 1)
      [ -z "$DIR" ] && DIR="."
      [ -f "$DIR" ] && DIR=$(dirname "$DIR")

      GIT_ROOT=$(git -C "$DIR" rev-parse --show-toplevel 2>/dev/null || true)
      if [ -n "$GIT_ROOT" ]; then
        OUT=$(git -C "$GIT_ROOT" pull 2>&1 || true)
        notify-send -a "OrbitOS Git" "Git Pull" "$OUT"
      fi
    '';

    "Git/Push" = mkNautilusScript "git-push" ''
      PATH="${lib.makeBinPath (with pkgs; [ git libnotify coreutils ])}:$PATH"

      DIR=$(echo -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | head -n 1)
      [ -z "$DIR" ] && DIR="."
      [ -f "$DIR" ] && DIR=$(dirname "$DIR")

      GIT_ROOT=$(git -C "$DIR" rev-parse --show-toplevel 2>/dev/null || true)
      if [ -n "$GIT_ROOT" ]; then
        OUT=$(git -C "$GIT_ROOT" push 2>&1 || true)
        notify-send -a "OrbitOS Git" "Git Push" "$OUT"
      fi
    '';

    "Git/Stage All" = mkNautilusScript "git-stage" ''
      PATH="${lib.makeBinPath (with pkgs; [ git libnotify coreutils ])}:$PATH"

      DIR=$(echo -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | head -n 1)
      [ -z "$DIR" ] && DIR="."
      [ -f "$DIR" ] && DIR=$(dirname "$DIR")

      GIT_ROOT=$(git -C "$DIR" rev-parse --show-toplevel 2>/dev/null || true)
      if [ -n "$GIT_ROOT" ]; then
        git -C "$GIT_ROOT" add -A
        notify-send -a "OrbitOS Git" "Staged" "All changes staged in $(basename "$GIT_ROOT")"
      fi
    '';

    "Git/Commit" = mkNautilusScript "git-commit" ''
      PATH="${lib.makeBinPath (with pkgs; [ git zenity libnotify coreutils ])}:$PATH"

      DIR=$(echo -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | head -n 1)
      [ -z "$DIR" ] && DIR="."
      [ -f "$DIR" ] && DIR=$(dirname "$DIR")

      GIT_ROOT=$(git -C "$DIR" rev-parse --show-toplevel 2>/dev/null || true)
      if [ -z "$GIT_ROOT" ]; then
        notify-send -u critical -a "OrbitOS Git" "Error" "Not a git repository!"
        exit 1
      fi

      MSG=$(zenity --entry --title="Git Commit" --text="Enter commit message:" || true)
      if [ -n "$MSG" ]; then
        OUT=$(git -C "$GIT_ROOT" commit -m "$MSG" 2>&1 || true)
        notify-send -a "OrbitOS Git" "Committed" "$OUT"
      fi
    '';

    "Git/Status" = mkNautilusScript "git-status" ''
      PATH="${lib.makeBinPath (with pkgs; [ git zenity coreutils ])}:$PATH"

      DIR=$(echo -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | head -n 1)
      [ -z "$DIR" ] && DIR="."
      [ -f "$DIR" ] && DIR=$(dirname "$DIR")

      GIT_ROOT=$(git -C "$DIR" rev-parse --show-toplevel 2>/dev/null || true)
      if [ -n "$GIT_ROOT" ]; then
        STATUS=$(git -C "$GIT_ROOT" status --short 2>&1 || echo "Error getting status")
        zenity --info --title="Git Status - $(basename "$GIT_ROOT")" --text="''${STATUS:-Working tree clean}" || true
      fi
    '';
  };

in {
  options.orbitos.nautilus = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = nautilusSelected;
      description = "Enable OrbitOS supercharged Nautilus configuration with templates, scripts, and dconf tweaks.";
    };
  };

  config = lib.mkIf cfg.enable {
    # --- 1. ESSENTIAL PACKAGES, EXTENSIONS & THUMBNAILERS ---
    home.packages = with pkgs; [
      sushi                       # Spacebar preview for images, PDFs, videos, markdown
      gtkhash                     # Checksum verification tool
      ffmpegthumbnailer           # Video thumbnails
      webp-pixbuf-loader          # WebP thumbnailer
      poppler-utils               # PDF thumbnailer and command tools
      libheif                     # HEIC/HEIF image preview support
      file-roller                 # Archive manager integration
      nautilus-open-any-terminal  # Open terminal here extension
      zenity                      # GUI dialogs for Nautilus right-click scripts
      ffmpeg                      # Video compression
      curl                        # 0x0.st upload
      wl-clipboard                # Clipboard utilities
      libnotify                   # Desktop notifications
      imagemagick                 # Image conversion
    ];

    # --- 2. FILE TEMPLATES ---
    # Automatically activates "New Document" menu in Nautilus
    home.file."Templates/plain".text = "";
    home.file."Templates/text-doc.txt".text = "";
    home.file."Templates/markdown-doc.md".text = ''
      # Document Title

      Start writing here...
    '';
    home.file."Templates/bash-script.sh" = {
      text = ''
        #!/usr/bin/env bash

        set -euo pipefail

      '';
      executable = true;
    };
    home.file."Templates/python-script.py" = {
      text = ''
        #!/usr/bin/env python3

        def main():
            pass

        if __name__ == "__main__":
            main()
      '';
      executable = true;
    };
    home.file."Templates/nix-file.nix".text = ''
      { config, lib, pkgs, ... }:

      {

      }
    '';
    home.file."Templates/json-file.json".text = ''
      {

      }
    '';

    # --- 3. DCONF PREFERENCES ---
    dconf.settings = {
      "org/gnome/nautilus/preferences" = {
        show-delete-permanently = true;      # Adds permanent delete to menu / Shift+Delete
        show-create-link = true;             # Adds create symlink option
        default-sort-order = "mtime";        # Sort by last modified
        date-time-format = "detailed";       # Detailed dates
        search-filter-time-type = "last_modified";
        recursive-search = "always";         # Recursive search enabled
      };
      "org/gnome/nautilus/list-view" = {
        use-tree-view = true;                # Expandable folder tree in list view
        default-zoom-level = "small";
      };
      "org/gnome/nautilus/compression" = {
        default-compression-format = "zip";
      };
      "org/gtk/gtk4/settings/file-chooser" = {
        sort-directories-first = true;       # Keep folders on top
      };
      "org/gtk/settings/file-chooser" = {
        sort-directories-first = true;
      };
      "com/github/stunkymonkey/nautilus-open-any-terminal" = {
        terminal = "kitty";
        flatpak = "system";
      };
    };

    # --- 4. DECLARATIVE RIGHT-CLICK SCRIPTS ---
    xdg.dataFile = lib.mapAttrs' (name: script:
      lib.nameValuePair "nautilus/scripts/${name}" {
        source = script;
        executable = true;
      }
    ) scripts;
  };
}
