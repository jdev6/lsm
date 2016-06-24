function isdigit(c)
    return tonumber(c) ~= nil
end

function isalpha(c)
    return c:upper() ~= c:lower()
end

function isalnum(c)
    return isalpha(c) or isdigit(c)
end

function isspace(c)
    return c == ' '  or
           c == '\t' or
           c == '\r' or
           c == '\v' or
           c == '\n' or
           c == '\f'
end

function exit(errno)
    collectgarbage("collect")
    os.exit(errno)
end

function eprintf(_,...) io.stderr:write(_:format(...)) end

function get_os()
    local raw_os_name, raw_arch_name = '', ''

    -- LuaJIT shortcut
    if jit and jit.os and jit.arch then
        raw_os_name = jit.os
        raw_arch_name = jit.arch
    else
        -- is popen supported?
        local popen_status, popen_result = pcall(io.popen, "")
        if popen_status then
            popen_result:close()
            -- Unix-based OS
            raw_os_name = io.popen('uname -s','r'):read('*l')
            raw_arch_name = io.popen('uname -m','r'):read('*l')
        else
            -- Windows
            local env_OS = os.getenv('OS')
            local env_ARCH = os.getenv('PROCESSOR_ARCHITECTURE')
            if env_OS and env_ARCH then
                raw_os_name, raw_arch_name = env_OS, env_ARCH
            end
        end
    end

    raw_os_name = (raw_os_name):lower()
    raw_arch_name = (raw_arch_name):lower()

    local os_patterns = {
        ['windows'] = 'Windows',
        ['linux'] = 'Linux',
        ['mac'] = 'Mac',
        ['darwin'] = 'Mac',
        ['^mingw'] = 'Windows',
        ['^cygwin'] = 'Windows',
        ['bsd$'] = 'BSD',
        ['SunOS'] = 'Solaris',
    }
    
    local arch_patterns = {
        ['^x86$'] = 'x86',
        ['i[%d]86'] = 'x86',
        ['amd64'] = 'x86_64',
        ['x86_64'] = 'x86_64',
        ['Power Macintosh'] = 'powerpc',
        ['^arm'] = 'arm',
        ['^mips'] = 'mips',
    }

    local os_name, arch_name = 'unknown', 'unknown'

    for pattern, name in pairs(os_patterns) do
        if raw_os_name:match(pattern) then
            os_name = name
            break
        end
    end
    for pattern, name in pairs(arch_patterns) do
        if raw_arch_name:match(pattern) then
            arch_name = name
            break
        end
    end
    return os_name, arch_name
end

--inspect.lua by kikito
inspect = require "lsm.inspect"