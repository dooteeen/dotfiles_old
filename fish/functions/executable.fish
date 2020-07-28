function executable -d "Chech whether command executable"
    begin
        status --is-interactive
        and type -q $argv
    end
    return $status
end
