function reload_local -d "Reload ~/.fish_local"
    source ~/.fish_local
    return $status
end
