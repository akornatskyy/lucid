local type, tostring, tonumber = type, tostring, tonumber

-- http://www.unicode.org/cldr/charts/latest/supplemental/language_plural_rules.html
-- https://developer.mozilla.org/en-US/docs/Mozilla/Localization/Localization_and_Plurals

local cardinals = {
    [1] = function(n)
        assert(type(n) == 'number', 'cardinal: <n> number expected')
        local s = tostring(n)
        local i = s:find('.', 1, true)
        return (n == 1 and not i) and 'one' or 'other'
    end,
    [7] = function(n)
        local s = tostring(n)
        local i = s:find('.', 1, true)
        if i then
            return 'other'
        end
        local i10 = tonumber(s:sub(-1))
        local i100 = tonumber(s:sub(-2))
        return (i10 == 1 and i100 ~= 11) and 'one' or
            (i10 >= 2 and i10 <= 4 and (i100 < 12 or i100 > 14)) and 'few' or
            'many';
    end
}

return {
    rules = {
        en = {
            cardinal = cardinals[1],
            ordinal = function(n)
                assert(type(n) == 'number', 'ordinal: <n> number expected')
                local s = tostring(n)
                local i = s:find('.', 1, true)
                if i then
                    s = s:sub(1, i - 1)
                end
                if tonumber(s) ~= n then
                    return 'other'
                end
                local n10 = s:sub(-1)
                local n100 = s:sub(-2)
                return (n10 == '1' and n100 ~= '11') and 'one' or
                    (n10 == '2' and n100 ~= '12') and 'two' or
                    (n10 == '3' and n100 ~= '13') and 'few' or 'other'
            end
        },
        uk = {
            cardinal = cardinals[7]
        }
    }
}
