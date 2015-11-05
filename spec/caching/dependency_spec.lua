local dependency = require 'caching.dependency'
local describe, it, assert = describe, it, assert

describe('caching.dependency', function()
    describe('add', function()
        it('initial key', function()
            local calls = {}
            local cache = {
                incr = function(self, key)
                    calls[#calls+1] = {'incr', key}
                    return self.c
                end,

                add = function(self, key, value, time)
                    calls[#calls+1] = {'add', key, value, time}
                    if key == 'master' then
                        self.c = 1
                    end
                    return true
                end
            }
            local d = dependency.new(cache, 60)

            assert.is_true(d:add('master', 'key'))

            assert.same({
                {'incr', 'master'},
                {'add', 'master', 0},
                {'incr', 'master'},
                {'add', 'master1', 'key', 60}
            }, calls)
        end)

        it('next key', function()
            local calls = {}
            local cache = {
                incr = function(self, key)
                    calls[#calls+1] = {'incr', key}
                    return 5
                end,

                add = function(self, key, value, time)
                    calls[#calls+1] = {'add', key, value, time}
                    return true
                end
            }
            local d = dependency.new(cache, 60)

            assert.is_true(d:add('master', 'key'))

            assert.same({
                {'incr', 'master'},
                {'add', 'master5', 'key', 60}
            }, calls)
        end)
    end)

    describe('delete', function()
        it('noop if master key does not exist', function()
            local calls = {}
            local cache = {
                get = function(self, key)
                    calls[#calls+1] = {'get', key}
                    return nil
                end
            }
            local d = dependency.new(cache, 60)

            d:delete('master')

            assert.same({
                {'get', 'master'}
            }, calls)
        end)

        it('cleans all dependent keys', function()
            local calls = {}
            local cache = {
                get = function(self, key)
                    calls[#calls+1] = {'get', key}
                    return 4
                end,

                get_multi = function(self, keys)
                    local t = {}
                    for i=1, #keys do
                        t[#t+1] = keys[i]
                    end
                    calls[#calls+1] = {'get_multi', t}
                    return {
                        master1 = 'key1',
                        master2 = 'key2',
                        master3 = 'key3',
                        master4 = 'key4'
                    }
                end,

                delete = function(self, key)
                    calls[#calls+1] = {'delete', key}
                end
            }
            local d = dependency.new(cache, 60)

            d:delete('master')

            assert.same({
                {'get', 'master'},
                {'get_multi', {'master1', 'master2', 'master3', 'master4'}},
                {'delete', 'master1'},
                {'delete', 'master2'},
                {'delete', 'master3'},
                {'delete', 'master4'},
                {'delete', 'key1'},
                {'delete', 'key2'},
                {'delete', 'key3'},
                {'delete', 'key4'},
                {'delete', 'master'}
            }, calls)
        end)
	end)
end)
