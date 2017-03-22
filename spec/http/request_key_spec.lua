local request_key = require 'http.request_key'
local describe, it, assert = describe, it, assert
local unpack = unpack or table.unpack

describe('http.request_key', function()
    it('raises an error if a variable is unknown', function()
        assert.error(function()
		    request_key.new('-$z-')
        end, 'unknown variable "z"')
	end)

    it('raises an error if expression is not a string', function()
        assert.error(function()
		    request_key.new()
        end)

        assert.error(function()
		    request_key.new('')
        end)
	end)

    describe('expression', function()
        local cases = {
            ['key'] = {'key', nil},
            ['GET'] = {'$m', {method='GET'}},
            ['P-GET'] = {'P-$m', {method='GET'}},
            ['GET-S'] = {'$m-S', {method='GET'}},
            ['GET/'] = {'$m$p', {method='GET', path='/'}},
            ['GET:/search/posts'] = {
                '$m:$p',
                {
                    method='GET',
                    path='/search/posts'
                }
            },
            ['GET:/search/posts::'] = {
                '$m:$p:$q_q:$q_page',
                {
                    method='GET', path='/search/posts',
                    query={}
                }
            },
            ['GET:/search/posts:vol:'] = {
                '$m:$p:$q_q:$q_page',
                {
                    method='GET', path='/search/posts',
                    query={q='vol'}
                }
            },
            ['GET:/search/posts:vol:10'] = {
                '$m:$p:$q_q:$q_page',
                {
                    method='GET', path='/search/posts',
                    query={q='vol', page='10'}
                }
            },
            ['GET::/'] = {
                '$m:$h_accept_encoding:$p',
                {
                    method='GET', path='/',
                    headers={}
                }
            },
            ['GET:gzip, deflate:/'] = {
                '$m:$h_accept_encoding:$p',
                {
                    method='GET', path='/',
                    headers={['accept-encoding']='gzip, deflate'}
                }
            },
            ['GET:/::'] = {
                '$m:$p:$c__a:$c_b',
                {
                    method='GET', path='/', cookies={}
                }
            },
            ['GET:/:abc'] = {
                '$m:$p:$c__a',
                {
                    method='GET', path='/', cookies={_a='abc', b='xyz'}
                }
            },
            ['GET:/:abc:xyz'] = {
                '$m:$p:$c__a:$c_b',
                {
                    method='GET', path='/', cookies={_a='abc', b='xyz'}
                }
            },
            ['GET:/'] = {
                '$m$gz:$p',
                {
                    method='GET', path='/', headers={}
                }
            },
            ['GETz:/'] = {
                '$m$gz:$p',
                {
                    method='GET', path='/',
                    headers={['accept-encoding']='gzip, deflate'}
                }
            },
        }
        for r, c in next, cases do
            local expression, req = unpack(c)
            it(expression, function()
                local make_key = request_key.new(expression)
                assert.equals(r, make_key(req))
            end)
        end
    end)
end)
