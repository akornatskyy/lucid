local pretty = require 'core.pretty'

describe('pretty', function()
    local dump = pretty.dump

    it('dump nil', function()
        assert.equals('nil', dump())
    end)

    it('dump default', function()
        local cases = {
            ['1'] = 1,
            ['"a"'] = 'a',
            ['true'] = true,
            ['{}'] = {},
            ['{{}}'] = {{}},
            ['{1, 2}'] = {1, 2},
            ['{"a", "b"}'] = {'a', 'b'},
            ['{1, 2, ["a"] = 1, ["b"] = 2}'] = {1, 2, a=1, b=2},
            ['{["a"] = {["x"] = 1, ["y"] = 2}, ["b"] = 2}'] = {a={x=1, y=2}, b=2},
        }
        for expected, obj in next, cases do
            assert.equals(expected, dump(obj))
        end
    end)

    it('dump compact', function()
        local cases = {
            ['{1, 2}'] = {1, 2},
            ['{1, 2, ["a"]=1, ["b"]=2}'] = {1, 2, a=1, b=2}
        }
        for expected, obj in next, cases do
            assert.equals(expected, dump(obj, pretty.spaces.compact))
        end
    end)

    it('dump indented', function()
        local cases = {
            ['{\n    1,\n    2\n}'] = {1, 2},
            ['{\n    1,\n    ["a"] = 1\n}'] = {1, a=1},
            ['{\n    ["a"] = {\n        ["x"] = 1\n    }\n}'] = {a={x=1}}
        }
        for expected, obj in next, cases do
            assert.equals(expected, dump(obj, pretty.spaces.indented))
        end
    end)

    it('dump min', function()
        local cases = {
            ['{1,2}'] = {1, 2},
            ['{1,2,["a"]=1,["b"]=2}'] = {1, 2, a=1, b=2}
        }
        for expected, obj in next, cases do
            assert.equals(expected, dump(obj, pretty.spaces.min))
        end
    end)
end)
