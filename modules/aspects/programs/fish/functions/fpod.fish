function fpod
    set -l c (podman ps --format '{{.Names}}' | fzf --preview 'podman inspect {} 2>/dev/null | bat --language=json --color=always')
    and podman exec -it "$c" bash
end
