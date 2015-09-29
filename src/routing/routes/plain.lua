local assert, format, load = assert, string.format, loadstring


local function plain_finishing(pattern, args)
    return {
        exact_matches = {[pattern] = args},
        fmt = {pattern}
    }
end

local function gen_match(pattern)
    local n = #pattern
    return format([[
        local sub = string.sub
        _ENV = nil
        return function(self, path)
            if #path >= %s and sub(path, 1, %s) == %q then
                return %s, self.args
            end
            return nil
        end
    ]], n, n, pattern, n)
end

local function plain_startswith(pattern, args)
    return {
        exact_matches = {[pattern] = args},
        match = assert(load(gen_match(pattern)))(),
        fmt = {pattern},
        args = args
    }
end

local function new(pattern, finishing, args, name)
    if pattern == '' then
        return plain_finishing(pattern, args or {}, name)
    elseif pattern:find('^[%w./-]+$') then
        args = args or {}
        if finishing then
            return plain_finishing(pattern, args, name)
        else
            return plain_startswith(pattern, args)
        end
    end
    return nil
end

return {
    new = new
}
