local type = type

return function(rules)
    assert(type(rules) == 'table', 'bad argument \'rules\' (table expected)')
    local r = {}
    for i = 1, #rules do
        local rule = rules[i]
        if type(rule) == 'function' then
            rule = rule()
        end
        assert(type(rule.validate) == 'function', 'no validate function')
        r[i] = rule
    end
    return r
end
