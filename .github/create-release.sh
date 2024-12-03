#! /usr/bin/env bash

set -euo pipefail

_get_release_branch()
{
    local release_branch="${1:-}"

    if [ -z "${release_branch}" ]; then
        local raw_branch=$(git branch -r --sort=-committerdate --list "*/v*" | head -n 1)
        local trimmed_branch="${raw_branch#${raw_branch%%[![:space:]]*}}"
        release_branch="${trimmed_branch#origin/}"
    fi

    printf "%s" "${release_branch}"
}

_get_latest_release_tag()
{
    gh release list \
        --repo "$GITHUB_REPOSITORY" \
        --exclude-drafts \
        --exclude-pre-releases \
        --json tagName,publishedAt \
        --jq 'sort_by(.publishedAt) | reverse | .[0].tagName'
}

_same_branch_as_prior_release()
{
    local release_branch_prefix="${1:-}"
    local latest_release_tag="${2:-}"

    case "${latest_release_tag}" in 
        "${release_branch_prefix}"*) 
            true
            ;; 
        *) 
            false
            ;; 
    esac
}

_get_target_release_json()
{
    local release_branch="${1:-}"
    local release_name="${2:-}"

    local latest_release_tag=$(_get_latest_release_tag) 
    local notes_start_tag="${latest_release_tag}"
    if [ -z "${release_name}" ]; then
        local release_base="${release_branch%-branch}"
        if ! _same_branch_as_prior_release "${release_base}" "${latest_release_tag}"; then
            latest_release_tag="${release_base}.0-0"

            if [ -z "${latest_release_tag}" ]; then
                notes_start_tag=
            fi
        fi

        tag_parts=($(printf "%s" "${latest_release_tag}" | tr '-' ' '))
        release_prefix="${tag_parts[0]}"
        release_id="$(( ${tag_parts[1]} + 1 ))"
        release_name="${release_prefix}-${release_id}"
    fi

    jq -n --arg notes_start_tag "${notes_start_tag}" --arg release_name "${release_name}" '{notes_start_tag: $notes_start_tag, release_name: $release_name}'
}

_create_release()
{
    local release_branch="${1:-}"
    local release_name="${2:-}"
    local notes_start_tag="${3:-}"

    gh release create "${release_name}" \
        --repo "$GITHUB_REPOSITORY" \
        --title "${release_name}" \
        --target "${release_branch}" \
        --generate-notes \
        ${notes_start_tag:+ --notes-start-tag ${notes_start_tag}}
}

release_branch=$( _get_release_branch "${TARGET_BRANCH}" )

echo "Using branch '${release_branch}'"

target_release_json=$( _get_target_release_json "${release_branch}" "${RELEASE_TAG}" )
release_name=$( jq -r '.release_name' <<< "${target_release_json}" )
notes_start_tag=$( jq -r '.notes_start_tag' <<< "${target_release_json}" )

echo "Using release name '${release_name}' ${notes_start_tag:+with a start tag of '${notes_start_tag}' for notes generation}"

_create_release "${release_branch}" "${release_name}" "${notes_start_tag}"

