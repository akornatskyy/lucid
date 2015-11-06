local cached = require 'caching.cached'
local describe, it, assert = describe, it, assert

describe('caching.cached', function()
    describe('get_or_set', function()
        it('returns cached item', function()
            local c = cached.new {
                cache = {
                    get = function(self, key)
                        assert.equals('ab:4:6', key)
                        return 10
                    end
                }
            }
            local key = function(a, b)
                return 'ab:' .. a .. ':' .. b
            end
            local t = {
                f = c:get_or_set(key, function(self, a, b)
                    assert(false)
                end)
            }

            assert.equals(10, t:f(4, 6))
        end)

        it('does not cache nil', function()
            local c = cached.new {
                cache = {
                    get = function(self, key)
                        assert.equals('ab:4:6', key)
                        return nil
                    end
                }
            }
            local key = function(a, b)
                return 'ab:' .. a .. ':' .. b
            end
            local t = {
                f = c:get_or_set(key, function(self, a, b)
                    return nil
                end)
            }

            assert.is_nil(t:f(4, 6))
        end)

        it('sets item in cache', function()
            local called = false
            local c = cached.new {
                cache = {
                    get = function(self, key)
                        assert.equals('ab:4:6', key)
                        return nil
                    end,

                    set = function(self, key, value, time)
                        called = true
                        assert.equals('ab:4:6', key)
                        assert.equals(10, value)
                        assert.equals(60, time)
                    end
                },
                time = 60
            }
            local key = function(a, b)
                return 'ab:' .. a .. ':' .. b
            end
            local t = {
                f = c:get_or_set(key, function(self, a, b)
                    return a + b
                end)
            }

            assert.equals(10, t:f(4, 6))
            assert(called)
        end)
    end)
end)
