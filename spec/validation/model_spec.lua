local i18n = require 'core.i18n'
local m = require 'validation.model'
local describe, it, assert = describe, it, assert
local type, next = type, next

describe('update_model', function()
    local translations = i18n.null
    local model, values, errors

    local update_model = function()
        errors = {}
        return m.update_model(model, values, errors, translations)
    end

    it('leaves model attribute unchanged if no value', function()
        model = {count = 1}
        values = {}
        assert(update_model())
        assert.equals(1, model.count)
        assert.same({}, errors)
    end)

    describe('single type adapter', function()
        it('ignores unknown attribute type', function()
            local c = function()end
            model = {count = c}
            values = {count = ''}
            assert(update_model())
            assert.equals(c, model.count)
        end)

        it('updates attribute', function()
            model = {count = 0}
            values = {count = '10'}
            assert(update_model())
            assert.equals(10, model.count)
        end)

        it('supports nil', function()
            model = {count = 0}
            values = {count = ''}
            assert(update_model())
            assert.is_nil(model.count)
        end)

        it('captures an error', function()
            model = {count = 0}
            values = {count = 'x'}
            assert(not update_model())
            assert.equals(0, model.count)
            assert.truthy(errors.count[1])
        end)

        it('should support model custom adapter', function()
            model = {
                count = 0,
                adapters = {
                    count = function(value, t)
                        return tonumber(value) or -1
                    end
                }
            }

            values = {count = '10'}
            assert(update_model())
            assert.equals(10, model.count)

            values = {count = 'x'}
            assert(update_model())
            assert.equals(-1, model.count)
        end)
    end)

    describe('multi default type adapter', function()
        it('updates attribute from a single value', function()
            model = {roles = {}}
            values = {roles = 'a'}
            assert(update_model())
            assert.same({'a'}, model.roles)
        end)

        it('updates attribute from multiple values', function()
            model = {roles = {}}
            values = {roles = {'a', 'b'}}
            assert(update_model())
            assert.same({'a', 'b'}, model.roles)
        end)
    end)

    describe('multi type adapter from first element', function()
        it('updates attribute from a single value', function()
            model = {roles = {0}}
            values = {roles = '1'}
            assert(update_model())
            assert.same({1}, model.roles)
        end)

        it('updates attribute from multiple values', function()
            model = {roles = {0}}
            values = {roles = {'1', '2'}}
            assert(update_model())
            assert.same({1, 2}, model.roles)
        end)

        it('captures an error from a single value', function()
            model = {roles = {0}}
            values = {roles = 'x'}
            assert(not update_model())
            assert.same({0}, model.roles)
            assert.truthy(errors.roles[1])
        end)

        it('captures an error from multiple values', function()
            model = {roles = {0}}
            values = {roles = {'x'}}
            assert(not update_model())
            assert.same({0}, model.roles)
            assert.truthy(errors.roles[1])
        end)
    end)
end)

describe('model adapter', function()
    describe('string', function()
        local a = m.adapters.string

        it('registered', function()
            assert.equals(a, m.adapters[type('')])
        end)

        it('adapts nil', function()
            assert.equals(nil, a(nil))
        end)

        it('adapts number', function()
            assert.equals('100', a(100))
            assert.equals('0.5', a(0.5))
        end)

        it('adapts boolean', function()
            assert.equals('false', a(false))
            assert.equals('true', a(true))
        end)

        it('adapts an empty table to nil', function()
            assert.equals(nil, a({}))
        end)

        it('strips whitespace', function()
            local cases = {
                {'', ''},
                {'', ' '},
                {'x', '  x  '},
                {'x  x', '  x  x '}
            }
            for _, c in next, cases do
                local expected, s = c[1], c[2]
                assert.equals(expected, a(s))
            end
        end)

        it('takes last value of multiple input', function()
            local cases = {
                {'', {' '}},
                {'', {'1', ' '}},
                {'x', {'1', ' x '}},
                {'100', {'1', 100}},
                {'false', {'1', false}}
            }
            for _, c in next, cases do
                local expected, s = c[1], c[2]
                assert.equals(expected, a(s))
            end
        end)
    end)

    describe('number', function()
        local a = m.adapters.number

        it('registered', function()
            assert.equals(a, m.adapters[type(1)])
        end)

        it('adapts nil', function()
            assert.equals(nil, a(nil))
        end)

        it('adapts an empty string to nil', function()
            assert.is_nil(a(''))
        end)

        it('adapts an empty table to nil', function()
            assert.equals(nil, a({}))
        end)

        it('converts string to number', function()
            local cases = {
                {0, ' 0 '},
                {1.5, '1.5 '},
                {-1, ' -1.0'},
                {0.1, ' 1e-1'},
                {100, '1e2 '}
            }
            for _, c in next, cases do
                local expected, s = c[1], c[2]
                assert.equals(expected, a(s))
            end
        end)

        it('takes last value of multiple input', function()
            local cases = {
                {1, {'1'}},
                {2, {'1', '2'}},
                {3, {'1', 3}}
            }
            for _, c in next, cases do
                local expected, s = c[1], c[2]
                assert.equals(expected, a(s))
            end
        end)

        it('reports an error if can not adapt a string to number', function()
            local translations = i18n.null
            local cases = {
                true,
                false,
                'x',
                '1x',
                'x1'
            }
            for _, s in next, cases do
                local value, err = a(s, translations)
                assert.is_nil(value)
                assert.truthy(err)
            end
        end)
    end)

    describe('boolean', function()
        local a = m.adapters.boolean

        it('registered', function()
            assert.equals(a, m.adapters[type(true)])
        end)

        it('adapts nil', function()
            assert.equals(nil, a(nil))
        end)

        it('adapts an empty string to nil', function()
            assert.is_nil(a(''))
        end)

        it('adapts an empty table to nil', function()
            assert.equals(nil, a({}))
        end)

        it('adapts number', function()
            assert.equals(true, a(1))
            assert.equals(false, a(0))
            assert.equals(false, a(2))
        end)

        it('adapts boolean', function()
            assert.equals(true, a(true))
            assert.equals(false, a(false))
        end)

        it('converts string', function()
            local cases = {
                {true, '1'},
                {true, 'true'},
                {false, ' 1'}
            }
            for _, c in next, cases do
                local expected, s = c[1], c[2]
                assert.equals(expected, a(s))
            end
        end)

        it('takes last value of multiple input', function()
            local cases = {
                {true, {0, 1}},
                {true, {'0', '1'}},
                {nil, {1, ''}},
                {true, {'1', 'true'}}
            }
            for _, c in next, cases do
                local expected, s = c[1], c[2]
                assert.equals(expected, a(s))
            end
        end)
    end)
end)
