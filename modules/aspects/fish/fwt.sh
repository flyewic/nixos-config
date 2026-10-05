if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
    echo "fwt: not in a git repository" >&2
    exit 1
fi

# Build tab-separated raw list: NAME<TAB>PATH<TAB>BRANCH<TAB>COMMIT
tmp_raw=$(mktemp)
tmp_display=$(mktemp)
trap 'rm -f "$tmp_raw" "$tmp_display"' EXIT

path=""
branch=""
head=""

while IFS= read -r line || [[ -n "$line" ]]; do
    case "$line" in
        worktree\ *) path="${line#worktree }" ;;
        HEAD\ *)     head="${line#HEAD }" ;;
        branch\ *)   branch="${line#branch }"; branch="${branch#refs/heads/}" ;;
        "")
            if [[ -n "$path" ]]; then
                name="$(basename "$path")"
                short_head="${head:0:7}"
                b="${branch:-detached HEAD}"
                printf "%s\t%s\t%s\t%s\n" "$name" "$path" "$b" "$short_head" >> "$tmp_raw"
                path=""; branch=""; head=""
            fi
            ;;
    esac
done < <(git worktree list --porcelain; echo)

# Flush last entry if porcelain didn't end with blank line
if [[ -n "$path" ]]; then
    name="$(basename "$path")"
    short_head="${head:0:7}"
    b="${branch:-detached HEAD}"
    printf "%s\t%s\t%s\t%s\n" "$name" "$path" "$b" "$short_head" >> "$tmp_raw"
fi

if [[ ! -s "$tmp_raw" ]]; then
    echo "fwt: no worktrees found" >&2
    exit 1
fi

# Create colored display version with padded worktree name (always visible)
# Field 1 (name) is padded to 25 chars and colored yellow/bold so it stays on the left.
# Field 2 (path) left uncolored so {2} can be used safely for preview/cd.
# --freeze-left keeps the name column pinned while horizontally scrolling long paths.
awk -F'\t' '{
    name=$1; path=$2; branch=$3; commit=$4;
    # % -25s pads name to 25 chars for alignment; ANSI codes outside %s so width is correct
    printf "\033[1;33m%-25s\033[0m\t%s\t\033[32m[%s]\033[0m\t\033[90m%s\033[0m\n", name, path, branch, commit
}' "$tmp_raw" > "$tmp_display"

worktree="$(fzf --ansi \
    --delimiter=$'\t' \
    --with-nth=1,2,3,4 \
    --preview 'git -C {2} log --color=always --oneline --decorate -20' \
    --preview-window=right:60% \
    --header 'worktree                 | path | branch | commit' \
    --freeze-left=1 \
    < "$tmp_display" | cut -f2)"

if [[ -n "${worktree:-}" ]]; then
    cd "$worktree" && exec "$SHELL"
fi
