# OrbitOS
# Commands to run in interactive sessions can go here
if status is-interactive
    set fish_greeting # No greeting

    # Show animated orbit fetch (fallback to fastfetch)
    if type -q orbit
        orbit fetch
    else if type -q fastfetch
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
        if type -q fzf_configure_bindings
            fzf_configure_bindings --variables=
        end
    end

    # Aliases
    # kitty doesn't clear properly so we need to do this weird printing
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias celar "printf '\033[2J\033[3J\033[1;1H'"
    alias claer "printf '\033[2J\033[3J\033[1;1H'"
    alias nano micro
    alias cat bat
    alias neofetch "orbit fetch"
    if type -q qs
        alias q 'qs -c ii'
    end
    if test "$TERM" != "linux"
        alias ls 'eza --icons=auto'
        alias ll 'eza -l --icons=auto --git'
        alias la 'eza -la --icons=auto --git'
        alias tree 'eza --tree --icons=auto'
    end
    if test "$TERM" = "xterm-kitty"
        alias ssh 'kitten ssh'
    end
    alias gs 'git status -sb'
    alias gp 'git pull --rebase'
    alias .. 'cd ..'
    alias ... 'cd ../..'

    # Default emacs keybindings
    set -g fish_key_bindings fish_default_key_bindings
end
