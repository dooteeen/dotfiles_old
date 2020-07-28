function reload -d "Reload config.fish"
    source $FISH_CONFIG_PATH
    return $status
end
