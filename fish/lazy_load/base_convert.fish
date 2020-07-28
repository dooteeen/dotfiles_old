function base_convert -d "Convert number base"
    if not executable bc
        echo "base_convert: Install bc." >&2
        return 1
    end

    argparse -n=base_convert 'v/invert' -- $argv
        or return 1

    if test (count $argv) -ne 3
        echo "base_convert: Require 3 numeric args, got "(count $argv) >&2
        return 1
    end

    set -l i (set -lq _flag_invert; and printf $argv[2]; or printf $argv[1])
    set -l o (set -lq _flag_invert; and printf $argv[1]; or printf $argv[2])
    set -l n $argv[3]

    echo "ibase=$i; obase=$o; $n" | bc
end
