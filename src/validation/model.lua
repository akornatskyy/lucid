local type, next, tonumber = type, next, tonumber


local function string_adapter(value)
    if value == nil then
        return nil
    end
    local t = type(value)
    if t == 'table' then
        value = value[#value]
        if value == nil then
            return nil
        end
        t = type(value)
    end
    if t ~= 'string' then
        return tostring(value)
    end
    return value:match('^%s*(.*%S)') or ''
end

local function number_adapter(value, translations)
    if value == nil then
        return nil
    end
    local t = type(value)
    if t == 'table' then
        value = value[#value]
        if value == nil then
            return nil
        end
        t = type(value)
    end
    if value == '' then
        return nil
    end
    if t ~= 'number' then
       value = tonumber(value)
    end
    if value == nil then
        return nil, translations:gettext('The input is not in numeric format.')
    end
    return value
end

local function boolean_adapter(value)
    if value == nil then
        return nil
    end
    local t = type(value)
    if t == 'table' then
        value = value[#value]
        if value == nil then
            return nil
        end
        t = type(value)
    end
    if value == '' then
        return nil
    end
    if t ~= 'boolean' then
        value = tostring(value)
        return value == '1' or value == 'true'
    end
    return value
end

local function table_adapter(value, adapter, translations)
    if type(value) == 'table' then
        local items = {}
        for i = 1, #value do
            local r, err = adapter(value[i], translations)
            if err then
                return nil, err
            end
            items[i] = r
        end
        return items
    end
    local r, err = adapter(value, translations)
    if err then
        return nil, err
    end
    return {r}
end

local adapters = {
    boolean = boolean_adapter,
    number = number_adapter,
    string = string_adapter
}

local function update_model(model, values, errors, translations)
    local ok = true
    local name_adapters = model.adapters or {}
    local type_adapters = adapters
    for name, attr in next, model do
        local value = values[name]
        if value then
            local t = type(attr)
            if t == 'table' then
                local a = name_adapters[name]
                if not a then
                    if #attr > 0 then
                        a = type_adapters[type(attr[1])]
                    else
                        a = string_adapter
                    end
                end
                if a then
                    local v, err = table_adapter(value, a, translations)
                    if not err then
                        model[name] = v
                    else
                        ok = false
                        errors[name] = {err}
                    end
                end
            else
                local a = name_adapters[name] or type_adapters[t]
                if a then
                    local v, err = a(value, translations)
                    if not err then
                        model[name] = v
                    else
                        ok = false
                        errors[name] = {err}
                    end
                end
            end
        end
    end
    return ok
end

return {
    update_model = update_model,
    adapters = adapters
}
