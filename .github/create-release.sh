#! /usr/bin/env bash

release_branch="${TARGET_BRANCH}"
if [ -z "${release_branch}" ]; then
    raw_branch=$(git branch -r --sort=-committerdate --list "*/v*" | head -n 1)
    trimmed_branch="${raw_branch#${raw_branch%%[![:space:]]*}}"
    release_branch="${trimmed_branch#origin/}"
fi

echo "Using branch ${release_branch}"

resolved_tag="${RELEASE_TAG}"
if [ -z "${resolved_tag}" ]; then
    tag_prefix="${release_branch%-branch}"
    last_tag=$(git tag --sort=-creatordate -l "${tag_prefix}*" | head -n 1)
    notes_start_tag="${last_tag}"
    if [ -z "${last_tag}" ]; then
        last_tag="${tag_prefix}.0-0"
        notes_start_tag=$(git tag --sort=-creatordate -l "v*" | head -n 1)
    fi
    tag_parts=($(printf "%s" "${last_tag}" | tr '-' ' '))
    release_prefix="${tag_parts[0]}"
    release_id="$(( ${tag_parts[1]} + 1 ))"
    resolved_tag="${release_prefix}-${release_id}"
fi

echo "Using tag ${resolved_tag}"

gh release create "${resolved_tag}" \
    --repo "$GITHUB_REPOSITORY" \
    --title "${resolved_tag}" \
    --target "${release_branch}" \
    --generate-notes \
    --notes-start-tag "${notes_start_tag}"
