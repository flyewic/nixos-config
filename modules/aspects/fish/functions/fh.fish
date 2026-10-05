function fh
    set -l cmd (history | fzf | sed 's/^[ ]*[0-9]*[ ]*//')
    and eval $cmd
end
