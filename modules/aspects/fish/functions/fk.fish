function fk
    set -l p (ps -ef | fzf --preview 'ps -o pid,user,%cpu,%mem,cmd -p $(echo {} | awk "{print \$2}")' | awk '{print $2}')
    and kill $p
end
