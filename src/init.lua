require "lsm.util"

lsm_version = "0.4-13"
lsm_host_os, lsm_host_arch = get_os()
lsm_host_isposix = ({
    Linux = true,
    Mac   = true,
    BSD   = true
})[lsm_host_os] or false

lsm_inf  = io.stdin
lsm_outf = io.stdout


function lsm_error(str, err,f,ln)
    err = err and (": [%s]"):format(err) or ""

    eprintf(
        "lsm: Error: \n    %s%s\n    in %s:%i\n    at %s\n", str, err, f, ln, lsm_stage
    )
    exit(1)
end

return {
    require "lsm.lex",
    require "lsm.parse",
    require "lsm.exec"
}