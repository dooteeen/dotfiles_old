function ssh_pubkey -d "Generates ssh key by ed25519"
    set -l key "$HOME/.ssh/id_ed25519.pub"
    if not test -f $key
        yes "" | ssh_keygen -t ed25519 -C "do2te3n@gmail.com" >/dev/null ^&1
    end
    cat $key
end
