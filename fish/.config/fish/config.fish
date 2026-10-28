# Run fastfetch on startup
if status is-interactive
    fastfetch
end

# Initialize Starship and Zoxide
starship init fish | source
zoxide init fish | source

# --- MY ALIASES ---
alias ls="eza --icons=always"
alias ll="eza -la --icons --git"
alias tree="eza --tree --icons"
alias update='paru'
alias y='yazi'
alias vi='nvim'
alias q='exit'
alias off='poweroff'
alias cl='clear'
alias ff='fastfetch'
alias dot='cd ~/dotfiles'
alias lg='lazygit'
alias rvk="cd ~/RVK/Pedagogick-portfolium-Bc-Mgr-"
alias zen='cd ~/zen-browser-css'

# Environment variables
set -gx EDITOR nvim

# Use cat as pager <- Paru PKGBUILD 
set -Ux PAGER cat

# Add paths to PATH
fish_add_path $HOME/.spicetify

# Replacement for the sudo plugin (Alt+S adds sudo to the start of the line)
function fish_user_key_bindings
    bind \es sudo_command_toggle
end

function sudo_command_toggle
    set -l cmd (commandline -b)
    if test -z "$cmd"
        # If the line is empty, load the last command from history
        set cmd $history[1]
    end
    if string match -r '^sudo ' $cmd
        commandline -r (string replace -r '^sudo ' '' $cmd)
    else
        commandline -r "sudo $cmd"
    end
end

# Yazi: stay in the directory where I left off
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

function s
    set -l session (sesh list -t -c | fzf --height 40% --reverse --border-label ' Projdi projekty / sezení ' --border)
    if test -n "$session"
        sesh connect $session
    end
end
