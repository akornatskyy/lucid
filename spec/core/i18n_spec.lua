local i18n = require 'core.i18n'

describe('i18n', function()
    local t = i18n.new {
        lang = 'en',
        translations = {
            ['hi'] = 'hello',
            ['%s day'] = {
                one = '%s day',
                other = '%s days'
            },
            ['Take the %d right.'] = {
                one = 'Take the %dst right.',
                two = 'Take the %dnd right.',
                few = 'Take the %drd right.',
                other = 'Take the %dth right.'
            }
        }
    }

    it('gettext', function()
        assert.equals('hello', t:gettext('hi'))
    end)

    it('cgettext', function()
        local samples = {
            {'0 days', 0},
            {'1 day', 1},
            {'2 days', 2}
        }
        for _, sample in next, samples do
            local expected, n = unpack(sample)
            assert.equals(expected, t:cgettext('%s day', n):format(n))
        end
    end)

    it('ogettext', function()
        local samples = {
            {'Take the 1st right.', 1},
            {'Take the 2nd right.', 2},
            {'Take the 3rd right.', 3},
            {'Take the 4th right.', 4}
        }
        for _, sample in next, samples do
            local expected, n = unpack(sample)
            local message = t:ogettext('Take the %d right.', n):format(n)
            assert.equals(expected, message)
        end
    end)
end)
