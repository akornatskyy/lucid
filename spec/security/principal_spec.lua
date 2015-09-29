local principal = require 'security.principal'
local describe, it, assert = describe, it, assert

describe('principal', function()
    describe('parse', function()

        it('returns a table', function()
            local p = {
                id='user',
                --roles={r1=true, r2=true},
                roles={},
                alias='alias',
                extra='extra'
            }
            local s = principal.dump(p)
            assert.same(p, principal.parse(s))
        end)
    end)
end)
