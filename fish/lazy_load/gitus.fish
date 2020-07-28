function gitus -d "Shows current git information"
    if git_is_repo
        git status --short
        is_succeeded; and echo
        echo "[Root] "(git_root_path)
        test (builtin pwd) != (git_root_path)
            and echo "[now] :/"(git rev-parse --show-prefix)
        echo "[Branch] "(git_branch_name)
        success git log -1
            and echo "[Commit] "(git log -1 --pretty="%h(%cr)" ^/dev/null; or printf '(No commits)')
            and test -n (git log -1 --pretty="%s" | sed 's/\s//g')
            and echo "  >> "(git log -1 --pretty="%s")
        test -n (echo (git_remote_name))
            and echo "[Remote] "(printf (git_remote_name)) (git remote get-url --push (git_remote_name))
        return 0
    else
        echo "[Notice] Here is not Git repository."
        return 0
    end
end
