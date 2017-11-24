# Lua Web API Toolkit

[![Build Status](https://travis-ci.org/akornatskyy/lucid.svg?branch=master)](https://travis-ci.org/akornatskyy/lucid)
[![Coverage Status](https://coveralls.io/repos/akornatskyy/lucid/badge.svg?branch=master&service=github)](https://coveralls.io/github/akornatskyy/lucid?branch=master)

A web API toolkit playground for the [Lua](http://www.lua.org/) programming
language.

# Installation

```sh
luarocks install --server=http://luarocks.org/dev lucid
```

... or use docker [images](https://github.com/akornatskyy/lucid/tree/master/docker).

# Overview

Using a function:

```lua
local http = require 'http'

local app = http.app.new()
app:use(http.middleware.routing)

app:get('', function(w, req)
    return w:write('Hello World!\n')
end)

return app()
```

... or a metaclass:

```lua
local class = require 'core.class'
local web = require 'web'

local WelcomeHandler = class {
    get = function(self)
        self.w:write('Hello World!\n')
    end
}

local all_urls = {
    {'', WelcomeHandler}
}

local options = {
    urls = all_urls
}

return web.app({web.middleware.routing}, options)
```

see more [here](https://github.com/akornatskyy/lucid/tree/master/demos).

# Setup

Install development dependencies:

```sh
sudo make debian
make env nginx
make test qa
eval "$(env/bin/luarocks path --bin)"
```

alternative environments:

```sh
make env LUA_VERSION=5.2.4
make env LUA_IMPL=luajit LUA_VERSION=2.0.5
make env LUA_IMPL=luajit LUA_VERSION=2.1.0-beta2
```

# Run

Check from the command line:

```sh
lurl -v demos/http/hello.lua /
```

Serve files with a web server:

```sh
export app=demos.http.hello ; make run
curl -v http://localhost:8080
```

Use docker:

```sh
docker run -it --rm -p 8080:8080 -v `pwd`/demos:/app \
    -e app=http.hello akorn/lucid:dev-luajit2.1-alpine
```

Open your browser at [http://localhost:8080](http://localhost:8080)

# HTTP API Reference

## Application

### http.app.new([options])

The `app` object by convention corresponds to HTTP application. Create it by
calling `http.app.new` function exported by the `http` module:

```lua
local http = require 'http'
local app = http.app.new()
```

It also accepts optional table `options` that affects how the application
behaves:

```lua
local app = http.app.new {
    root_path = '/api/v1/'
}
```

Later options can be accessed as `app.options`.

> The same options are shared as a parameter to
> [middleware](#functionfollowing-options) initialization and
> available in HTTP request object as `req.options`.

The `app` object has methods for configuring middleware:

```lua
app:use(http.middleware.routing)
```

and routing HTTP requests:

```lua
app:get('', function(w, req)
    return w:write('Hello World!\n')
end)
```

Here `app:get` function corresponds to HTTP GET verb, `app:post` to HTTP
POST, etc.

Finally you call `app` to build url mapping, chain middlewares and run it
through initialization step.

```lua
return app()
```

This call returns the first middleware registered with `app:use`.

### Properties

#### http.app.http_verbs

The table of adapted HTTP verbs can be  accessed as
`http.app.http_verbs`,
which is an association between a function name and HTTP verb, e.g.
`post = POST`, etc. The association happens during application initialization
only, thus does not affect runtime.

> HTTP verb *OPTIONS* is not in `http.app.http_verbs`.

Use HTTP verb in upper case if is not in `http.app.http_verbs`.

```lua
app:OPTIONS('', function(w, req)
end)
```

#### app.options

The `app.options` table has properties that are specific for the application.

```lua
app.options.root_path
-- '/'
```

These options remain throughout the life of the application. You can access
`options` during middleware initialization and in HTTP request object as
`req.options`.

> The `app` object is not supposed to be shared with request
> [handlers](#functionw-req). Use `req.options` instead.

The following table describes the properties of the `options` object.

| Property | Description                              | Default |
| :------- | ---------------------------------------- | ------- |
| urls     | Keeps url path mapping to request handler | `{}`    |

### Events

#### app.on('mounted', function(parent))

The `mounted` event is fired on a sub-app, when it is mounted on a
parent app. The `parent` app is passed to the function.

> Sub-app will:
> - Not inherit the value of `options` of the parent application.
> - Keep own `options` unchanged.
> - Use any values from the `parent` application as necessary.

The following example shows the use of `mounted` event.

```lua
local http = require 'http'

local greetings = http.app.new()
greetings:on('mounted', function(parent)
    print('mounted')
end)
greetings:get('hi', function(w)
    return w:write('hi')
end)

local app = http.app.new()
app:use(http.middleware.routing)
app:add('greetings/', greetings)
return app()
```
