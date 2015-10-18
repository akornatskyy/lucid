local principal = require 'security.principal'
local describe, it, assert = describe, it, assert

describe('security.principal', function()
    describe('dump', function()

        it('fails if id is not supplied', function()
            assert.has_error(function()
                principal.dump {}
            end, 'invalid value (nil) at index 1 in table for \'concat\'')
        end)

        it('requires only id', function()
            local s = principal.dump {id='user'}
            assert.same({
                id='user',
                roles={},
                alias='',
                extra=''
            }, principal.parse(s))
        end)

        it('supports alias', function()
            local s = principal.dump {id='user', alias='alias'}
            assert.same({
                id='user',
                roles={},
                alias='alias',
                extra=''
            }, principal.parse(s))
        end)

        it('supports extra', function()
            local s = principal.dump {id='user', extra='extra'}
            assert.same({
                id='user',
                roles={},
                alias='',
                extra='extra'
            }, principal.parse(s))
        end)
    end)

    describe('parse', function()

        it('fails if there is no input', function()
            assert.has_error(principal.parse)
        end)

        it('return nil of input is empty string', function()
            assert.is_nil(principal.parse(''))
        end)

        it('supports a single role', function()
            local p = {
                id='user',
                roles={r1=true},
                alias='',
                extra=''
            }
            assert.same(p, principal.parse(principal.dump(p)))
        end)

        it('supports a multiple roles', function()
            local p = {
                id='user',
                roles={r1=true, r2=true, r3=true},
                alias='',
                extra=''
            }
            assert.same(p, principal.parse(principal.dump(p)))
        end)
    end)
end)
