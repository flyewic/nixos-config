function fg
    set -l b (git branch --all | fzf --preview 'git log --oneline --graph --color=always (echo {} | sed "s/^[* ]*//; s/[+ ]//g; s|remotes/origin/||")' | sed 's/^[* ]*//; s/[+ ]//g; s|remotes/origin/||')
    and git checkout $b
end
