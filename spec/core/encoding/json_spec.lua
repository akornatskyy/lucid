local json = require 'core.encoding.json'
local describe, it, assert = describe, it, assert

describe('core.encoding.json', function()
    it('encode decode', function()
        local t = {x = 1}
        assert.same(t, json.decode(json.encode(t)))
    end)

    it('encode empty table as object', function()
        assert.equals('{}', json.encode({}))
    end)

    describe('not implemented', function()
        it('raises an error', function()
            local saved = require
            _G['require'] = function(m)
                if m == 'cjson' then
                    return error()
                end
                return saved(m)
            end
            package.loaded['cjson'] = nil
            package.loaded['core.encoding.json'] = nil
            local j = require 'core.encoding.json'
            assert.error(j.encode, 'json encode is not implemented')
            assert.error(j.decode, 'json decode is not implemented')
            package.loaded['core.encoding.json'] = nil
            _G['require'] = saved
        end)
    end)
end)
