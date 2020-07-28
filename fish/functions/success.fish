function success -d "Returns status without output"
    set -l last_status "$status"
    if not set -q argv[1]
        return (test $last_status -eq 0)
    end
    switch "$argv[1]"
        case '-p' '--print'
            echo $last_status
            return $last_status
        case '*'
            eval "$argv" > /dev/null ^/dev/null
    end
end
