#!/bin/sh
# Merges upstream CtrlrX into the current branch and keeps the paths in muse/removed-paths removed.
#
#   muse/sync-upstream.sh [ref]       fetch the remote "upstream" and merge ref (upstream/master)
#   muse/sync-upstream.sh --continue  after resolving the remaining conflicts by hand
#
# The branch doesn't contain upstream's history. muse/upstream-commit names the upstream commit it is synced to:
# for the merge, that commit becomes a second parent of HEAD through a temporary graft, so the merge finds the right
# base. The merge is a squash merge, so the new commit has HEAD as its only parent.
#
# Conflicts in the removed paths, and files upstream adds there, are resolved by removing them again. Other
# conflicts are left for resolving by hand.

set -e
cd "$(git rev-parse --show-toplevel)"

prune() {
	# git rm refuses unmerged submodules and .gitmodules, so the index entries are removed directly
	grep -v -e '^#' -e '^$' muse/removed-paths | while read -r path; do
		git ls-files -z -- "$path" | xargs -0 -r sh -c 'git update-index --force-remove -- "$@" && rm -rf -- "$@"' sh
	done
}

ungraft() {
	git replace -d "$(git rev-parse HEAD)" >/dev/null 2>&1 || true
}

finish() {
	ungraft
	unmerged=$(git diff --name-only --diff-filter=U)
	if [ -n "$unmerged" ]; then
		echo "resolve these conflicts, then run $0 --continue:"
		echo "$unmerged"
		exit 1
	fi
	new=$(cat "$(git rev-parse --git-dir)/muse-sync-upstream")
	echo "$new" > muse/upstream-commit
	git add muse/upstream-commit
	git commit -q -m "Merge upstream $(git log -1 --format='%h (%s)' "$new")

Upstream: https://github.com/damiensellier/CtrlrX/commit/$new"
	rm -f "$(git rev-parse --git-dir)/muse-sync-upstream"
	echo "merged: $(git log -1 --format='%h %s')"
}

if [ "$1" = "--continue" ]; then
	prune
	finish
	exit 0
fi

if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
	echo "commit or stash the changes first"
	exit 1
fi

ref=${1:-upstream/master}
git fetch -q upstream
new=$(git rev-parse "$ref^{commit}")
old=$(cat muse/upstream-commit)

if [ "$new" = "$old" ] || git merge-base --is-ancestor "$new" "$old"; then
	echo "already synced to $(git log -1 --format='%h %s' "$new")"
	exit 0
fi

echo "$new" > "$(git rev-parse --git-dir)/muse-sync-upstream"
# HEAD keeps its own parents, if any
git replace -f --graft HEAD $(git rev-list --parents -n 1 HEAD | cut -s -d' ' -f2-) "$old"
trap ungraft EXIT

# -X renormalize: muse has LF line endings, upstream also CRLF. Conflicts leave the merge to finish, those in the
# removed paths aren't worth showing
git merge -q --squash -X renormalize "$new" 2>&1 | grep -v -e '^Auto-merging' -e 'deleted in HEAD and modified in' || true
prune
finish
