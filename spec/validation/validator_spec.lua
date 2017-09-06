local i18n = require 'core.i18n'
local validator = require 'validation.validator'
local describe, it, assert = describe, it, assert

describe('validator', function()
    local translations = i18n.null
    local model, model_validator, errors

    local validate = function()
        errors = {}
        return model_validator:validate(model, errors, translations)
    end

    it('supports function rule factory', function()
        local not_nil = function()
            return {
                validate = function(self, value, m, t)
                    assert.equals(model, m)
                    assert.equals(translations, t)
                    return value == nil and 'error' or nil
                end
            }
        end
        model_validator = validator.new {
            name = {not_nil}
        }
        model = {name = ''}
        assert(validate())
        assert(not errors.name)
        model = {}
        assert(not validate())
        assert(errors.name)
    end)

    it('supports table rule', function()
        local not_nil = {
            validate = function(self, value, m, t)
                assert.equals(model, m)
                assert.equals(translations, t)
                return value == nil and 'error' or nil
            end
        }
        model_validator = validator.new {
            name = {not_nil}
        }
        model = {name = ''}
        assert(validate())
        assert(not errors.name)
        model = {}
        assert(not validate())
        assert(errors.name)
    end)

    it('supports composite rule', function()
        local not_nil = {
            validate = function(self, value, m, t)
                return value == nil and 'error' or nil
            end
        }
        model_validator = validator.new {
            details = validator.new {
                name = {not_nil}
            }
        }
        model = {details = {name = ''}}
        assert(validate())
        assert(not errors.name)
        model = {details={}}
        assert(not validate())
        assert(errors.name)
    end)
end)
