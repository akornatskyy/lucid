local plain = require 'routing.routes.plain'
local assert, describe, it = assert, describe, it
local new = plain.new
_ENV = nil

describe('plain route', function()
    describe('builder', function()
        it('supports alphanumeric characters', function()
            assert(new('abc123'))
        end)

        it('supports dash, slash and dot characters', function()
            assert(new('/hello/world'))
            assert(new('hello-world'))
            assert(new('hello.world'))
        end)

        it('does not support some characters', function()
            assert.is_nil(new('~hello'))
            assert.is_nil(new('#hello'))
        end)
    end)

    describe('finishing strategy', function()
        local r = new('/', true)

        it('supports empty pattern', function()
            assert.has_nil(new('').match)
        end)

        describe('exact matches', function()
            it('fallback to empty table if args is nil', function()
                assert.same({['/'] = {}}, r.exact_matches)
            end)

            it('supports extra args', function()
                r = new('/', true, {event_type='task'})
                assert.same({['/'] = {event_type='task'}}, r.exact_matches)
            end)
        end)

        describe('match', function()
            it('not supported since replaced by exact matches', function()
                assert.has_nil(r.match)
            end)
        end)
    end)

    describe('starts with strategy', function()
        local r = new('/welcome', false)

        describe('exact matches', function()
            it('fallback to empty table if args is nil', function()
                assert.same({['/welcome'] = {}}, r.exact_matches)
            end)

            it('supports extra args', function()
                r = new('/welcome', false, {event_type='task'})
                assert.same({['/welcome'] = {event_type='task'}},
                            r.exact_matches)
            end)
        end)

        describe('match', function()
            it('returns a number of characters matched and args', function()
                r = new('/hello', false, {lang='en'})
                local matched, args = r:match('/hello/world')
                assert.equals(6, matched)
                assert.same({lang='en'}, args)
            end)

            it('ignores route name', function()
                r = new('/hello', false, nil, 'hello')
                local matched, args = r:match('/hello/world')
                assert(matched)
                assert.same({}, args)
            end)

            it('returns nil if no match found', function()
                local matched = r:match('/')
                assert.is_nil(matched)
            end)
        end)
    end)
end)
