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

release_branch="${TARGET_BRANCH}"
if [ -z "${release_branch}" ]; then
    raw_branch=$(git branch -r --sort=-committerdate --list "*/v*" | head -n 1)
    trimmed_branch="${raw_branch#${raw_branch%%[![:space:]]*}}"
    release_branch="${trimmed_branch#origin/}"
fi

echo "Using branch ${release_branch}"

echo "HERE"

resolved_tag="${RELEASE_TAG}"
if [ -z "${resolved_tag}" ]; then
    tag_prefix="${release_branch%-branch}"
    last_tag=$(git tag --sort=-creatordate -l "${tag_prefix}*" | head -n 1)
    tag_parts=($(printf "%s" "${last_tag}" | tr '.' ' '))
    release_prefix="${tag_parts[0]}"
    release_id="$(( ${tag_parts[1]} + 1 ))"
    resolved_tag="${release_prefix}-${release_id}"
fi

echo "Using tag ${resolved_tag}"
