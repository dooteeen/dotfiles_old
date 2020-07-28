function termux -d "Run termux API commands"
    if test (count $argv -lt 1)
        echo "termux: should 1 or more arguments." >&2
        return 1
    end
    set -l sub $argv[1]
    set -l arg $argv[2..-1]
    termux-$sub $arg
end
