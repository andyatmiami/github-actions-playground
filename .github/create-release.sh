#! /usr/bin/env bash

# _get_target_branch()
# {
#     local tag="${1:-}"

#     local tag_parts=($(printf "%s" "${tag}" | tr "." " "))
#     local target_branch="${tag_parts[0]}.${tag_parts[1]}-branch"

#     printf "%s" "${target_branch}"
# }

# target_branch=$(_get_target_branch "$GITHUB_REF_NAME")

# gh release create "${GITHUB_REF_NAME}" \
#     --repo="$GITHUB_REPOSITORY" \
#     --title="${GITHUB_REF_NAME}" \
#     --target "${target_branch}" \
#     --generate-notes

echo "HERE"

git branch -r

echo "NOW HERE"

git branch -r --sort=-committerdate --list "*/v*"