function ff
    set -l dir .
    test (count $argv) -gt 0; and set dir $argv[1]
    set -l f (find "$dir" -type f | fzf --preview 'bat --color=always {}')
    and flow "$f"
end
