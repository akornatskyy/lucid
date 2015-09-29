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
    -- 'luacrypto',
    -- 'lua-cjson'
}

source = {
    url = 'git://github.com/akornatskyy/lucid.git'
}

build = {
    type = 'builtin',
    modules = {
        ["core.class"] = "src/core/class.lua",
        ["core.clockit"] = "src/core/clockit.lua",
        ["core.collections.defaulttable"] = "src/core/collections/defaulttable.lua",
        ["core.encoding"] = "src/core/encoding.lua",
        ["core.encoding.base64"] = "src/core/encoding/base64.lua",
        ["core.encoding.json"] = "src/core/encoding/json.lua",
        ["core.encoding.messagepack"] = "src/core/encoding/messagepack.lua",
        ["core.encoding.null"] = "src/core/encoding/null.lua",
        ["core.i18n"] = "src/core/i18n.lua",
        ["core.mixin"] = "src/core/mixin.lua",
        ["core.pretty"] = "src/core/pretty.lua",

        ["http"] = "src/http.lua",
        ["http.adapters.nginx.base"] = "src/http/adapters/nginx/base.lua",
        ["http.adapters.nginx.buffered"] = "src/http/adapters/nginx/buffered.lua",
        ["http.adapters.nginx.helloworld"] = "src/http/adapters/nginx/helloworld.lua",
        ["http.adapters.nginx.stream"] = "src/http/adapters/nginx/stream.lua",
        ["http.app"] = "src/http/app.lua",
        ["http.cookie"] = "src/http/cookie.lua",
        ["http.functional.lurl"] = "src/http/functional/lurl.lua",
        ["http.functional.request"] = "src/http/functional/request.lua",
        ["http.functional.response"] = "src/http/functional/response.lua",
        ["http.middleware.routing"] = "src/http/middleware/routing.lua",
        ["http.mixins.json"] = "src/http/mixins/json.lua",
        ["http.mixins.routing"] = "src/http/mixins/routing.lua",
        ["http.request"] = "src/http/request.lua",
        ["http.response"] = "src/http/response.lua",

        ["routing.builders"] = "src/routing/builders.lua",
        ["routing.router"] = "src/routing/router.lua",
        ["routing.routes.choice"] = "src/routing/routes/choice.lua",
        ["routing.routes.curly"] = "src/routing/routes/curly.lua",
        ["routing.routes.pattern"] = "src/routing/routes/pattern.lua",
        ["routing.routes.plain"] = "src/routing/routes/plain.lua",

        ["security.crypto.cipher"] = "src/security/crypto/cipher.lua",
        ["security.crypto.digest"] = "src/security/crypto/digest.lua",
        ["security.crypto.ticket"] = "src/security/crypto/ticket.lua",
        ["security.principal"] = "src/security/principal.lua",

        ["validation.binder"] = "src/validation/binder.lua",
        ["validation.model"] = "src/validation/model.lua",
        ["validation.rules.length"] = "src/validation/rules/length.lua",
        ["validation.rules.required"] = "src/validation/rules/required.lua",
        ["validation.validator"] = "src/validation/validator.lua",

        ["web"] = "src/web.lua",
        ["web.app"] = "src/web/app.lua",
        ["web.middleware.routing"] = "src/web/middleware/routing.lua",
        ["web.mixins.authcookie"] = "src/web/mixins/authcookie.lua",
        ["web.mixins.json"] = "src/web/mixins/json.lua",
        ["web.mixins.model"] = "src/web/mixins/model.lua",
        ["web.mixins.principal"] = "src/web/mixins/principal.lua",
        ["web.mixins.routing"] = "src/web/mixins/routing.lua"
    },
    install = {
        bin = {
            ['lurl'] = 'bin/lurl'
        }
    }
}
