function %1 --on-event fish_%0exec
    string match -q "*%2*" "$argv"; and executable "%3"; and %3
end
