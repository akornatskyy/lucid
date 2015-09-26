local i18n = require 'core.i18n'

describe('i18n', function()
    local trans = i18n.configure()

    it('domain', function()
        local locales = trans.domains['app']
        local locale = locales['en']
        assert.equals('hello', locale:gettext('hello'))

        locale = locales['de']
        assert.equals('hello', locale:gettext('hello'))

        locale = trans.domains['validation']['en']
        assert.equals('world', locale:gettext('world'))
    end)
end)
