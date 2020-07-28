function git_to_ssh
    git_is_repo; or return 1

    set -l remote (git remote show)
    begin
        not is_succeeded
        or  test -z "$remote"
    end
    if is_succeeded
        echo "This repository has not registed remote repository."
        return 0
    end

    set -l url (git remote get-url $remote)
    begin
        not is_succeeded
        or  test -z "$url"
        or  string match -q "git@*" $url
    end
    if is_succeeded
        echo "This repository's url has already set to use ssh."
        return 0
    end

    if string match -q "https://github.com/*" $url
        git remote set-url $remote \
            (string replace 'https://github.com/' 'git@github.com:' $url)
    else if string match -q "https://bitbucket.org/*" $url
        git remote set-url $remote \
            (string replace 'https://bitbucket.org/' 'git@bitbucket.org:' $url)
    end
end
