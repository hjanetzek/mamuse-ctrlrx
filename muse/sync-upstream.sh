#!/bin/sh
# Merges upstream CtrlrX into the current branch and keeps the paths in muse/removed-paths removed.
#
#   muse/sync-upstream.sh [ref]       fetch the remote "upstream" and merge ref (upstream/master)
#   muse/sync-upstream.sh --continue  after resolving the remaining conflicts by hand
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

finish() {
	unmerged=$(git diff --name-only --diff-filter=U)
	if [ -n "$unmerged" ]; then
		echo "resolve these conflicts, then run $0 --continue:"
		echo "$unmerged"
		exit 1
	fi
	if git rev-parse -q --verify MERGE_HEAD >/dev/null; then
		git commit -q --no-edit
		echo "merged: $(git log -1 --format='%h %s')"
	fi
}

if [ "$1" = "--continue" ]; then
	prune
	finish
	exit 0
fi

ref=${1:-upstream/master}
git fetch -q upstream
git merge -q --no-ff --no-commit "$ref" || true
prune
finish
