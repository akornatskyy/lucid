local assert, type, setmetatable = assert, type, setmetatable

local check_rule = {__index = {
    validate = function(self, value, model, translations)
      return self.rule(value, model, translations)
    end
  }
}

return function(rule)
    assert(
        type(rule) == 'function',
        "bad argument 'rule' (function(value, model, translations) expected)")
    return setmetatable({rule = rule}, check_rule)
end
