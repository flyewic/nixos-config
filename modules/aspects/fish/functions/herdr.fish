function herdr
    if set -q ZELLIJ_SESSION_NAME
        touch "$HOME/.cache/ghostty-herdr-handoff"
        zellij kill-session "$ZELLIJ_SESSION_NAME"
    else
        command herdr $argv
    end
end
