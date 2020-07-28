function cls -w clear -d "Alias of clear"
    set -l last_status $status
    clear
    return $last_status
end
