# OrbitOS
# Commands to run in interactive sessions can go here
if status is-interactive
    set fish_greeting # No greeting

    # Show fastfetch on login shells
    if status is-login
        fastfetch
    end

    # Use starship
    function starship_transient_prompt_func
        starship module character
    end
    if test "$TERM" != "linux"
        starship init fish | source
        enable_transience
    end

    # Matugen / Quickshell dynamic terminal colors
    if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
        cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end

    # Tools init
    if type -q zoxide
        zoxide init fish --cmd cd | source
    end
    if type -q direnv
        direnv hook fish | source
    end
    if type -q atuin
        atuin init fish --disable-up-arrow | source
    end
    if type -q fzf
        fzf --fish | source
    end

    # Abbreviations
    # kitty doesn't clear properly so we need to do this weird printing
    abbr -a -- clear "printf '\033[2J\033[3J\033[1;1H'"
    abbr -a -- celar "printf '\033[2J\033[3J\033[1;1H'"
    abbr -a -- claer "printf '\033[2J\033[3J\033[1;1H'"
    abbr -a -- nano micro
    abbr -a -- cat bat
    abbr -a -- neofetch fastfetch
    if type -q qs
        abbr -a -- q 'qs -c ii'
    end
    if test "$TERM" != "linux"
        abbr -a -- ls 'eza --icons=auto'
        abbr -a -- ll 'eza -l --icons=auto --git'
        abbr -a -- la 'eza -la --icons=auto --git'
        abbr -a -- tree 'eza --tree --icons=auto'
    end
    if test "$TERM" = "xterm-kitty"
        abbr -a -- ssh 'kitten ssh'
    end
    abbr -a -- gs 'git status -sb'
    abbr -a -- gp 'git pull --rebase'
    abbr -a -- .. 'cd ..'
    abbr -a -- ... 'cd ../..'

    # Vi keybinds with visible cursor feedback
    set -g fish_key_bindings fish_vi_key_bindings
    set -g fish_cursor_default block
    set -g fish_cursor_insert line
    set -g fish_cursor_replace_one underscore
    set -g fish_cursor_visual block
end
