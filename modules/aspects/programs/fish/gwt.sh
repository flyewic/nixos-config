branch="${1:-}"

if [[ -z "$branch" ]]; then
    echo "usage: gwt <branch>" >&2
    exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
repo_name="$(basename "$repo_root")"
base="$HOME/Projects/.worktrees/$repo_name"
target="$base/$branch"

mkdir -p "$(dirname "$target")"

if git rev-parse --verify --quiet "refs/heads/$branch" >/dev/null; then
    git worktree add "$target" "$branch"
else
    git worktree add -b "$branch" "$target"
fi

echo "$target"
