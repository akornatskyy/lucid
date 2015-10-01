local class = require 'core.class'
local assert, next, describe, it = assert, next, describe, it

describe('core.class', function()
    describe('definition', function()
        it('raises an error if base is not a table', function()
            assert.error(class)
            assert.error(function()
                class(1)
            end)
        end)

        it('accepts an empty table', function()
            assert.same({}, class({})())
        end)

        it('has extra meta information', function()
            local keys = {}
            for k in next, class({}) do
                keys[k] = 1
            end
            assert.same({__index=1}, keys)
        end)

        it('is a table type', function()
            assert.equals('table', type(class({})))
        end)
    end)

    describe(':ctor', function()
        it('called', function()
            local C = class({
                ctor = function(self)
                    self.called = true
                end
            })
            assert.same({called = true}, C())
        end)

        it('call with arguments', function()
            local C = class({
                ctor = function(self, a, b)
                    self.a = a
                    self.b = b
                end
            })
            assert.same({a = 1, b = 2}, C(1, 2))
        end)
    end)

    describe('getmetatable', function()
        it('check', function()
            local C = class({})
            local c = C()
            assert.equals(C, getmetatable(c))
        end)
    end)

    describe('setmetatable', function()
        it('init', function()
            local C = class({})
            assert.same({a = 1}, setmetatable({a = 1}, C))
        end)

        it('should call a function', function()
            local C = class({
                f = function(self)
                    return self.a
                end
            })
            local c = setmetatable({a = 1}, C)
            assert.equals(1, c:f())
        end)
    end)

    describe('function', function()
        it('raises an error if function not defined', function()
            local C = class({})
            local c = C()
            assert.error(function()
                c.f()
            end)
        end)

        it('should support static call', function()
            local C = class({
                f = function()
                    return 1
                end
            })
            assert.equals(1, C.f())
        end)

        it('should support class call', function()
            local C = class({
                f = function(cls)
                    assert(cls)
                    return 1
                end
            })
            assert.equals(1, C:f())
        end)

        it('should be available with self', function()
            local C = class({
                f = function(self)
                    return self
                end
            })
            local c = C()
            assert.equals(c, c:f())
        end)
    end)

    describe('inheritance', function()
        it('#1 always calls a base ctor', function()
            local A = class({
                ctor = function(self)
                    self.a = true
                end
            })
            local B = class(A, {})
            local D = class(B, {})
            local d = D()
            assert(d.ctor)
            assert.same({a = true}, d)
        end)

        it('allows to call a base ctor', function()
            local B = class({
                ctor = function(self)
                    self.b = true
                end
            })
            local D = class(B, {
                ctor = function(self)
                    B.ctor(self)
                    self.d = true
                end
            })
            local d = D()
            assert(d.ctor)
            assert.same({b = true, d = true}, d)
        end)

        it('allows to call a base function', function()
            local B = class({
                b = function(self)
                    self.called = true
                end
            })
            local D = class(B, {})
            local d = D()
            d:b()
            assert.same({called=true}, d)
        end)

        it('allows to call a base function from subclass', function()
            local called
            local B = class({
                b = function(self)
                    called = true
                end
            })
            local D = class(B, {
                d = function(self)
                    B:b()
                end
            })
            local d = D()
            d:d()
            assert(called)
        end)

        it('allows to override a base function', function()
            local B = class({
                b = function(self)
                end
            })
            local D = class(B, {
                b = function(self)
                    self.called = true
                end
            })
            local d = D()
            assert.equals(D.b, d.b)
            d:b()
            assert.same({called=true}, d)
        end)

        it('should support static call', function()
            local B = class({
                f = function()
                    return 1
                end
            })
            local D = class(B, {
            })
            assert.equals(1, B.f())
            assert.equals(1, D.f())
        end)

        it('should support class call', function()
            local B = class({
                f = function(cls)
                    return cls
                end
            })
            local D = class(B, {
            })
            assert.equals(B, B:f())
            assert.equals(D, D:f())
        end)
    end)
end)
