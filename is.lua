function isdigit(c)
    return tonumber(c) ~= nil
end

function isspace(c)
    return c == ' '  or
           c == '\r' or
           c == '\t' or
           c == '\v' or
           c == '\f' or
           c == '\n'
end

function isalpha(c)
    return c ~= c:upper() or c ~= c:lower()
end

function isalnum(c)
    return isdigit(c) or isalpha(c)
end
