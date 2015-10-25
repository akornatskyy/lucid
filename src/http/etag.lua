local format = string.format

return {
    new = function(hasher)
        return function(s)
            return format('"%x%x%x%x"', hasher(s):byte(1, 4))
        end
    end
}
