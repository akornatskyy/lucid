local i18n = require 'core.i18n'
local json = require 'cjson'
local pretty = require 'core.pretty'

local testcases_path = 'spec/validation/rules/'
local testcases = {
    'bytes.json',
    'compare.json',
    'email.json',
    'empty.json',
    'fields.json',
    'length.json',
    'nilable.json',
    'nonempty.json',
    'pattern.json',
    'range.json',
    'required.json',
    'succeed.json',
    'typeof.json'
}

local function read(path)
    local f = assert(io.open(path))
    local d = json.decode(f:read('*a'))
    f:close()
    return d
end

local function test_suite(suite)
    local rule = require('validation.rules.' .. suite.rule)
    local validator = rule(unpack(suite.args))
    for _, case in next, suite.tests do
        it(case.description, function()
            for _, sample in next, case.samples do
                local model
                if sample == json.null then
                    sample = nil
                elseif type(sample) == 'table' then
                    sample, model = unpack(sample)
                end
                local err = validator:validate(sample, model, i18n.null)
                assert.equals(case.err, err, 'sample: ' .. pretty.dump(sample))
            end
        end)
    end
end

describe('validation rules', function()
    for _, path in next, testcases do
        for _, suite in next, read(testcases_path .. path) do
            describe(suite.description .. ' (' .. path .. ')', function()
              test_suite(suite)
            end)
        end
    end
end)
