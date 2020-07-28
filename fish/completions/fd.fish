complete -c fd -s H -l hidden -d "Include hidden files and directories"
complete -c fd -s I -l no-ignore
complete -c fd -s u -l unrestricted -d "Same as -I"
complete -c fd -l no-ignore-vsc
complete -c fd -s s -l case-sensitive -d "Perform a case sensitive"
complete -c fd -s i -l ignore-case -d "Perform a case insensitive"
complete -c fd -s g -l glob -d "Perform a glob-based match"
complete -c fd -l regex -d "Perform a regex search"
complete -c fd -s F -l fixed-strings
complete -c fd -s a -l absolute-path -d "Shows the full path"
complete -c fd -s l -l list-details
complete -c fd -s L -l follow
complete -c fd -s p -l full-path -d "Search pattern is matched against the full path"
complete -c fd -s 0 -l print0
complete -c fd -l max-result
complete -c fd -s 1 -d "Same as '--max-limit 1'"
complete -c fd -l show-errors
complete -c fd -l one-file-system -l mount -l xdev
complete -c fd -s h -l help
complete -c fd -s v -l version
complete -c fd -x -s d -l max-depth -a (echo (seq 1 9))
complete -c fd -x -l min-depth -a (echo (seq 1 9))
complete -c fd -x -s t -l type -a "f file d directory l symlink x executable e empty s socket p pipe"
complete -c fd -s e -l extension -d "Filter result by file extension"
complete -c fd -s E -l exclude -d "Exclude result by pattern"
complete -c fd -l ignore-file -d "Ignore file by file path"
complete -c fd -s c -l color -a "auto never always"
complete -c fd -s j -l threads
complete -c fd -s S -l size -d "Limit by size: <+-><Numeric><Unit>"
complete -c fd -l changed-within -d "Filter by modification time"
complete -c fd -l changed-before -d "Filter by modification time"
complete -c fd -s x -l exec -d "Filter by command: {}"
complete -c fd -s X -l exec-batch

