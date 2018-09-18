#!/usr/bin/env bash

set -e

if [[ $# -ne 1 ]]; then
    echo 'Usage: release.sh VERSION'
    exit 1
fi

version=${1}
remote_git_repo=${REMOTE_GIT_REPO:-"https://github.com/yuanying/test-release"}
remote=${REMOTE:-"origin"}

if [[ "$(git remote get-url ${remote})" != "${remote_git_repo}" ]]; then
    echo "REMOTE_GIT_REPO isn't match the url of REMOTE: REMOTE: ${remote} REMOTE_GIT_REPO: ${remote_git_repo}"
    exit 1
fi

if [[ ${version} =~ ^v([0-9]+)\.([0-9]+)\.[0-9]+(-rc\.[0-9]+)*$ ]]; then
    major=${BASH_REMATCH[1]}
    minor=${BASH_REMATCH[2]}
    rc=${BASH_REMATCH[3]}
    flag=""
    if [[ ${rc} != "" ]]; then
        flag="-d"
    fi

    release_branch=release-${major}.${minor}
    # Create a release branch if it does not exist
    git remote update ${remote}
    if ! git remote show ${remote} | grep ${release_branch} > /dev/null; then
        if [[ $(git symbolic-ref --short HEAD) != 'master' ]]; then
            echo 'Current branch must be master in order to create release branch from master branch.'
            exit 1
        fi
        echo "Create a remote branch: ${release_branch}"
        git push ${remote} master:${release_branch}
    fi


    echo "Create a release: ${version}"
    hub release create ${flag} -m ${version} -t ${release_branch} ${version}
else
    echo "Invalid version: ${version}"
    exit 1
fi
