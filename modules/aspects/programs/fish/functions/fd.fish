function fd
    set -l dir .
    test (count $argv) -gt 0; and set dir $argv[1]
    set -l d (find "$dir" -type d | fzf --preview 'ls -la --color=always {}')
    and cd "$d"
end
