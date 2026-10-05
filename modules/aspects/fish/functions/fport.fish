function fport
    set -l p (ss -tlnp | fzf --preview 'pid=$(echo {} | grep -oP "pid=\K[0-9]+"); [[ -n $pid ]] && ps -p "$pid" -o pid,user,%cpu,%mem,cmd --no-headers' | grep -oP 'pid=\K[0-9]+')
    and kill $p
end
