# Spuštění fastfetch při startu
if status is-interactive
    fastfetch
end

# Inicializace Starship a Zoxide
starship init fish | source
zoxide init fish | source

# --- MOJE ALIASY ---
alias ll='ls -l'
alias la='ls -la'
alias update='paru'
alias y='yazi'
alias vi='nvim'
alias q='exit'
alias off='poweroff'
alias cl='clear'
alias ff='fastfetch'
alias dot='cd ~/dotfiles'
alias lg='lazygit'
alias rvk="cd /home/libor/RVK/Pedagogick-portfolium-Bc-Mgr-"
alias zen='cd ~/zen-browser-css'

# Proměnné prostředí
set -gx EDITOR nvim

# Přidání cest do PATH
fish_add_path $HOME/.spicetify

# Náhrada za sudo plugin (stisknutím Alt+S přidá sudo na začátek řádku)
function fish_user_key_bindings
    bind \es 'sudo_command_toggle'
end

function sudo_command_toggle
    set -l cmd (commandline -b)
    if test -z "$cmd"
        # Pokud je řádek prázdný, načteme poslední příkaz z historie
        set cmd $history[1]
    end
    if string match -r '^sudo ' $cmd
        commandline -r (string replace -r '^sudo ' '' $cmd)
    else
        commandline -r "sudo $cmd"
    end
end
