function fl
    set -l c (git log --oneline | fzf --preview 'git show --color=always $(echo {} | cut -d" " -f1)' | awk '{print $1}')
    test -n "$c"; and git show "$c"
end
