package = 'lucid'

version = 'scm-0'

description = {
    summary = 'A playground for lua web API toolkit.',
    homepage = 'https://github.com/akornatskyy/lucid',
    maintainer = 'Andriy Kornatskyy <andriy.kornatskyy@live.com>',
    license = 'MIT'
}

dependencies = {
    'lua >= 5.1',
    -- optional:
    -- 'lbase64',
    -- 'struct',
    -- 'luaossl',
    -- 'lua-cjson',
    -- 'luasocket'
    -- 'utf8'
}

source = {
    url = 'git://github.com/akornatskyy/lucid.git'
}

build = {
    type = 'builtin',
    modules = {
        ['caching.cached'] = 'src/caching/cached.lua',
        ['caching.dependency'] = 'src/caching/dependency.lua',
        ['caching.null'] = 'src/caching/null.lua',

        ['core.class'] = 'src/core/class.lua',
        ['core.clockit'] = 'src/core/clockit.lua',
        ['core.encoding'] = 'src/core/encoding.lua',
        ['core.encoding.base64'] = 'src/core/encoding/base64.lua',
        ['core.encoding.json'] = 'src/core/encoding/json.lua',
        ['core.encoding.messagepack'] = 'src/core/encoding/messagepack.lua',
        ['core.encoding.null'] = 'src/core/encoding/null.lua',
        ['core.i18n'] = 'src/core/i18n.lua',
        ['core.i18n.plurals'] = 'src/core/i18n/plurals.lua',
        ['core.mixin'] = 'src/core/mixin.lua',
        ['core.pretty'] = 'src/core/pretty.lua',

        ['http'] = 'src/http.lua',
        ['http.adapters.nginx.base'] = 'src/http/adapters/nginx/base.lua',
        ['http.adapters.nginx.buffered'] = 'src/http/adapters/nginx/buffered.lua',
        ['http.adapters.nginx.helloworld'] = 'src/http/adapters/nginx/helloworld.lua',
        ['http.adapters.nginx.stream'] = 'src/http/adapters/nginx/stream.lua',
        ['http.app'] = 'src/http/app.lua',
        ['http.cookie'] = 'src/http/cookie.lua',
        ['http.cors'] = 'src/http/cors.lua',
        ['http.etag'] = 'src/http/etag.lua',
        ['http.functional.lurl'] = 'src/http/functional/lurl.lua',
        ['http.functional.request'] = 'src/http/functional/request.lua',
        ['http.functional.response'] = 'src/http/functional/response.lua',
        ['http.middleware.authcookie'] = 'src/http/middleware/authcookie.lua',
        ['http.middleware.authorize'] = 'src/http/middleware/authorize.lua',
        ['http.middleware.caching'] = 'src/http/middleware/caching.lua',
        ['http.middleware.cors'] = 'src/http/middleware/cors.lua',
        ['http.middleware.routing'] = 'src/http/middleware/routing.lua',
        ['http.mixins.json'] = 'src/http/mixins/json.lua',
        ['http.mixins.routing'] = 'src/http/mixins/routing.lua',
        ['http.request'] = 'src/http/request.lua',
        ['http.request_key'] = 'src/http/request_key.lua',
        ['http.response'] = 'src/http/response.lua',

        ['routing.builders'] = 'src/routing/builders.lua',
        ['routing.router'] = 'src/routing/router.lua',
        ['routing.routes.choice'] = 'src/routing/routes/choice.lua',
        ['routing.routes.curly'] = 'src/routing/routes/curly.lua',
        ['routing.routes.pattern'] = 'src/routing/routes/pattern.lua',
        ['routing.routes.plain'] = 'src/routing/routes/plain.lua',

        ['security.crypto.cipher'] = 'src/security/crypto/cipher.lua',
        ['security.crypto.digest'] = 'src/security/crypto/digest.lua',
        ['security.crypto.rand'] = 'src/security/crypto/rand.lua',
        ['security.crypto.ticket'] = 'src/security/crypto/ticket.lua',
        ['security.principal'] = 'src/security/principal.lua',

        ['validation'] = 'src/validation.lua',
        ['validation.binder'] = 'src/validation/binder.lua',
        ['validation.mixins.set_error'] = 'src/validation/mixins/set_error.lua',
        ['validation.mixins.validation'] = 'src/validation/mixins/validation.lua',
        ['validation.model'] = 'src/validation/model.lua',
        ['validation.rules.compare'] = 'src/validation/rules/compare.lua',
        ['validation.rules.email'] = 'src/validation/rules/email.lua',
        ['validation.rules.length'] = 'src/validation/rules/length.lua',
        ['validation.rules.messages.en'] = 'src/validation/rules/messages/en.lua',
        ['validation.rules.messages.uk'] = 'src/validation/rules/messages/uk.lua',
        ['validation.rules.pattern'] = 'src/validation/rules/pattern.lua',
        ['validation.rules.range'] = 'src/validation/rules/range.lua',
        ['validation.rules.required'] = 'src/validation/rules/required.lua',
        ['validation.rules.succeed'] = 'src/validation/rules/succeed.lua',
        ['validation.validator'] = 'src/validation/validator.lua',

        ['web'] = 'src/web.lua',
        ['web.app'] = 'src/web/app.lua',
        ['web.middleware.routing'] = 'src/web/middleware/routing.lua',
        ['web.mixins.authcookie'] = 'src/web/mixins/authcookie.lua',
        ['web.mixins.json'] = 'src/web/mixins/json.lua',
        ['web.mixins.locale'] = 'src/web/mixins/locale.lua',
        ['web.mixins.model'] = 'src/web/mixins/model.lua',
        ['web.mixins.principal'] = 'src/web/mixins/principal.lua',
        ['web.mixins.routing'] = 'src/web/mixins/routing.lua'
    },
    install = {
        bin = {
            ['lurl'] = 'bin/lurl'
        }
    }
}
