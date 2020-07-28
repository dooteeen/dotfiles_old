nyagos.setenv("HOME", nyagos.env.USERPROFILE)
nyagos.setenv("DOTFILES",  nyagos.env.USERPROFILE.."\\Dotfiles")

nyagos.completion_slash = true

-- functions {{{1
function result_of(cmd)
    return tostring(nyagos.eval(cmd..' ; status'))
end
function success(cmd)
    return result_of('void '..cmd) == '0'
end
function executable(cmd)
    return success('where '..cmd)
end

local last_fg = 'white'
local last_bg = 'black'
function set_color(fg, bg)
    local template = "$e[;%s;%s;1m"
    local fgcolors = { black='30', red='31', green='32', yellow='33', blue='34', magenta='35', cyan='36', white='37' }
    local bgcolors = { black='40', red='41', green='42', yellow='43', blue='44', magenta='45', cyan='46', white='47' }
    local fgcolor = fgcolors[fg] or last_fg
    local bgcolor = bgcolors[bg] or last_bg
    last_fg = fgcolor
    last_bd = bgcolor
    return (template:format(fgcolor, bgcolor))
end
function with_color(str, fg, bg)
    return string.format('%s%s%s', set_color(fg, bg), str or '', set_color('white', 'black'))
end

function basename(wd)
    return wd:gsub('^.*[/\\]([^/\\]*)$', '%1')
end

function split(s, d)
    local div, fields = d or ",", {}
    local pattern = string.format("([^%s]+)", div)
    s:gsub(pattern, function(c) fields[#fields + 1] = c end)
    return fields
end
-- }}}1

-- fish like aliases
nyagos.alias.cp  = "copy $*"
nyagos.alias.mv  = "move $*"
nyagos.alias.rm  = "trash $*"
nyagos.alias.la  = "ls -al $*"
nyagos.alias.ll  = "ls -l  $*"
nyagos.alias.dirname  = "pwsh -c '((gi $1).Directory).FullName'"
nyagos.alias.realpath = "pwsh -c 'gi $1 | select -ExpandProperty Target'"

-- scoop aliases like chocolatey
nyagos.alias.sup = 'scoop update; scoop update *'
nyagos.alias.sin = 'scoop install $*'
nyagos.alias.sun = 'scoop uninstall $*'
nyagos.alias.sri = 'scoop uninstall $*; scoop install $*'
nyagos.alias.sea = 'scoop search $*'
nyagos.alias.sls = 'scoop list'
nyagos.alias.sst = 'scoop status'
nyagos.alias.sbu = 'scoop bucket $*'

-- schtasks command wrappers
nyagos.alias.at  = "schtasks $*"
nyagos.alias.atc = "schtasks /create /tn $1 /tr $2 /st $3 /sc $4"
nyagos.alias.atd = "schtasks /query /tn $1 /fo list /v && schtasks /delete /tn $1"
nyagos.alias.ate = "schtasks /change $*"
nyagos.alias.atq = "schtasks /query /tn $1 /fo list /v"

-- other aliases (string style)
nyagos.alias.bim    = "bash -c \"vim $*\""
nyagos.alias.fish   = "bash -c fish $*"
nyagos.alias.pwsh   = "powershell $*"
nyagos.alias.run    = "nyagos -f $1"
nyagos.alias.sha256 = "certutil -hashfile $* SHA256"
nyagos.alias.status = "echo %ERRORLEVEL%"
nyagos.alias.sudoc  = "sudo $*"
nyagos.alias.sudon  = "sudo nyagos -c '$*'"
nyagos.alias.sudop  = "sudo powershell -Command '$*'"
nyagos.alias.void   = '$* >nul 2>nul'
if executable('ln.ps1') then
    nyagos.alias.ln  = "ln.ps1 $*"
    nyagos.alias.lns = "ln.ps1 -s $*"
end
if executable('win32yank.exe') then
    nyagos.alias.pbcopy  = 'win32yank -i'
    nyagos.alias.pbpaste = 'win32yank -o'
end

-- other aliases (function style)
nyagos.alias.success = function(args)
    local cmd = args[1] or ''
    return nyagos.eval('void '..cmd..' ; status')
end
nyagos.alias.executable = function(args)
    local cmd = args[1] or ''
    return nyagos.eval('success where '..cmd)
end

-- git related functions
local git = {}
git.is_repository = function()
    return success('git rev-parse')
end
git.has_committed = function()
    return nyagos.eval('git count') > 0
end
git.get_info = function()
    local info = nyagos.eval('git info')
    local remote, r_count = info:gsub('/.*$', "")
    local branch, b_count = info:gsub('^.*/([^ ]+).*$', "%1")
    local aheads, a_count = info:gsub('^.*(ahead )([0-9]+).*$', '%2')
    return git.info,
           r_count == 0 and "" or remote,
           b_count == 0 and "" or branch,
           a_count == 0 and 0  or tonumber(aheads),
           nyagos.eval('git list-alt 2>nul'):gsub('%s', ''):len() > 0
end

-- bd commands {{{1
function bd(args)
    local str = args[1] or ""

    if str == "" then
        nyagos.chdir("..")
        print(nyagos.eval("pwd"))
        return
    end

    local oldpwd = nyagos.eval("pwd")
    local newpwd = oldpwd
    local div = share.completion_slash and "/" or "\\"
    local directories = split(oldpwd, div)
    local stack = {}
    local pattern = function(s) return '.*('..s..').*' end
    local count = 0
    local index = #directories
    for k, v in ipairs(directories) do
        stack[k] = k == 1 and v or stack[k - 1] .. div .. v
        if v:lower():match(pattern(str:lower())) then
            count = count + 1
            index = k
        end
    end
    newpwd = count > 0 and stack[index] or oldpwd

    if newpwd == oldpwd then
        print("No directories that match with " .. str)
        print("pwd: " .. oldpwd)
        return 1, ""
    else
        print(newpwd)
        nyagos.chdir(newpwd)
    end
end
nyagos.alias.bd = function(args) bd(args) end
nyagos.alias.bdg = function()
    if git.is_repository() then
        nyagos.chdir(nyagos.eval('git root'))
        print(nyagos.eval('pwd'))
    else
        bd()
    end
end
-- }}}1

-- to(bookmark directory) functions {{{1
local function to_get_subs()
    return {
        "add",
        "rm",
        "mv",
        "show",
        "ls",
        "help"
    }
end

local function to_get_keys()
    if nyagos.to == nil then
        return {}
    end
    local list = {}
    local i = 0
    for k, _ in pairs(nyagos.to) do
        i = i + 1
        list[i] = k
    end
    return list
end

local function to_validate_with_subs(str)
    local subcommands = to_get_subs()
    for i = 1, #subcommands do
        if str == subcommands[i] then
            return true
        end
    end
    return false
end

local function to_validate_with_keys(key)
    local keys = to_get_keys()
    for i = 1, #keys do
        if key == keys[i] then
            return true
        end
    end
    return false
end

local function to_help()
    print(table.concat({
        "Usage:",
        "  $ to <KEY>                # Go to bookmarked directry.",
        "  $ to add <KEY> [<VALUE>]  # Make a new bookmark(VALUE or current directory).",
        "  $ to rm <KEY>             # Remove bookmark.",
        "  $ to mv <OLD> <NEW>       # Rename bookmark from OLD to NEW.",
        "  $ to ls                   # List all bookmarks.",
        "  $ to show <KEY>           # Show a bookmark registed as KEY.",
        "  $ to help                 # Show this message."
    }, "\n"))
    return 0, ""
end

local function to_cd(key)
    if to_validate_with_subs(key) or not to_validate_with_keys(key) then
        return 2110, "Error: Illigal key."
    end
    nyagos.chdir(nyagos.to[key])
    return 0, ""
end

local function to_add(key, value)
    local path = value or ""
    if path == "" then
        path = nyagos.getwd()
    end

    if key == nil or key == "" then
        return 2120, "Error: Missing key."
    end

    if to_validate_with_subs(key) then
        return 2121, "Error: Illigal key."
    end
    nyagos.to[key] = path
    return 0, ""
end

local function to_rm(key)
    if key == "" then
        return 2130, "Error: Missing key."
    end

    if to_validate_with_subs(key) or not to_validate_with_keys(key) then
        return 2131, "Error: Illigal key."
    end
    nyagos.to[key] = nil
    return 0, ""
end

local function to_mv(old, new)
    if old == "" then
        return 2140, "Error: Missing old key name."
    end
    if to_validate_with_subs(old) then
        return 2141, "Error: Illigal old key name."
    end
    if not to_validate_with_keys(old) then
        return 2142, "Error: Illigal old key name."
    end
    if new == "" then
        return 2143, "Error: Missing new key name."
    end
    if to_validate_with_subs(new) then
        return 2144, "Error: Illigal new key name."
    end
    if to_validate_with_keys(new) then
        return 2145, "Error: Illigal new key name."
    end

    local path = nyagos.to[old]
    local n = 0
    local s = ""
    n, s = to_rm(old)
    if n ~= 0 then
        return n, s
    end
    n, s = to_add(new, path)
    return n, s
end

local function to_show(key)
    if key == "" then
        return 2150, "Error: Missing key."
    end
    if not to_validate_with_keys(key) then
        return 2151, "Error: Illigal key."
    end

    local s = nyagos.to[key]
    nyagos.write(s)
    return 0, ""
end

local function to_list()
    for k, v in pairs(nyagos.to) do
        local s = k..': '..v
        print(s)
    end
    return 0, ""
end

local function to_import()
    nyagos.to = {}
    local csv_path = nyagos.env.DOTFILES.."/.data/nyagos/to.csv"
    nyagos.eval("touch "..csv_path)
    local csv = nyagos.eval("cat "..csv_path)
    for _, i in pairs(split(csv, "\r\n")) do
        local s = split(i, ",")
        nyagos.to[s[1]] = s[2]
    end
end

local function to_export()
    local csv = ""
    if nyagos.to == nil then
        return
    end
    for k, v in pairs(nyagos.to) do
        if csv == "" then
            csv = k..","..v
        else
            csv = csv.."\r\n"..k..","..v
        end
    end
    local csv_path = nyagos.env.DOTFILES.."/.data/nyagos/to.csv"
    nyagos.eval("echo '"..csv.."' > "..csv_path)
end

nyagos.alias.to = function(args)
    local a1 = args[1] or "help"
    local a2 = args[2] or ""
    local a3 = args[3] or ""

    local result_num = 2199
    local result_str = "Error: Unknown or forgotten error."
    local run_export = true

    if a1 ~= "help" then
        to_import()
    end

    if to_validate_with_subs(a1) then
        if a1 == "add" then
            result_num, result_str = to_add(a2, a3)
        elseif a1 == "rm" then
            result_num, result_str = to_rm(a2)
        elseif a1 == "mv" then
            result_num, result_str = to_mv(a2, a3)
        elseif a1 == "show" then
            result_num, result_str = to_show(a2)
        elseif a1 == "ls" then
            result_num, result_str = to_list()
        elseif a1 == "help" then
            result_num, result_str = to_help()
            run_export = false
        end
    elseif to_validate_with_keys(a1) then
        result_num, result_str = to_cd(a1)
    else
        to_help()
        result_num = 2198
        result_str = "Illigal subcommand or key."
        run_export = false
    end

    if result_num == 0 and run_export then
        to_export()
    elseif result_num ~= 0 then
        print(result_str)
    end

    return result_num, result_str
end

nyagos.complete_for["to"] = function(args)
    if #args == 2 then
        to_import()
        local list = to_get_subs()
        for k, v in pairs(to_get_keys()) do
            list[k] = v
        end
        return list
    elseif #args == 3 then
        if args[2] == "help" or args[2] == "ls" then
            return nil
        else
            to_import()
            return to_get_keys()
        end
    end
    return nil
end
-- }}}1

-- nyagos.prompt {{{1
nyagos.prompt = function(_)
    local status = nyagos.eval('status')
    local wd = nyagos.getwd()
    local env = nyagos.env
    local home = env.home or env.userprofile
    local home_len = home:len()
    if wd:sub(1, home_len) == home then
        wd = "~" .. wd:sub(home_len + 1)
    end
    local wd_plain = wd
    local color = status ~= '0' and 'red' or (nyagos.elevated() and 'magenta' or 'cyan')
    if git.is_repository() then
        local root = basename(nyagos.eval('git root'))
        local here = basename(nyagos.getwd())

        local color = 'green'
        local _, _, branch, aheads, has_uncommitted = git.get_info()
        if has_uncommitted then
            color = 'red'
        elseif aheads > 0 then
            color = 'yellow'
        end
        wd = with_color(root, color, 'black')

        if branch ~= '' and branch ~= 'master' then
            wd = wd .. with_color(string.format('(%s)', branch), 'green', 'black')
        end
        if here ~= root then
            wd = wd..with_color(':'..here, color, 'black')
        end
    else
        wd = with_color(wd, color, 'black')
    end
    local head = string.format('\n%s ', with_color('>', color, color))
    local prompt = wd_plain == "~" and head or head .. wd .. head
    return nyagos.default_prompt(prompt, "Nyagos: " .. wd_plain)
end
-- }}}1

-- vim: set ft=lua: --
