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

### Methods

#### app:add(pattern, sub_app)

Mounts specified `sub_app` at the `pattern`: the application handles all
requests that match url path according to pattern.

> This allows you to build modular or composable applications.

**Example: composable application**

Here is *child* application that we could reuse later.

```lua
-- child.lua
local http = require 'http'

local app = http.app.new()
app:get('hi', function(w, req)
    return w:write('Hello World!\n')
end)

return app
```

> The child *app* object is returned without a call for initialization.

The parent app builds url mapping for `sub_app` app.

> The middlewares registered in `sub_app` are ignored.

The route that matches any path that follows its path immediately after
"/greetings/" will be handed to *child* application.

``` lua
-- main.lua
local http = require 'http'

local app = http.app.new()
app:add('greetings/', require 'child')
app:use(http.middleware.routing)

return app()
```

The *child* application handles requests to */greetings/hi*.

The *main* application can extend child application routing as necessary.

```lua
app:get('greetings/hallo', function(w, req)
    return w:write('Hallo Welt!\n')
end)
```

By default the *main* application can not override patterns (the routing
middleware treats this as an  error, unless *allow_path_override* option).

```lua
local app = http.app.new {
    allow_path_override = true
}
app:add('greetings/', require 'child')
app:get('greetings/hi', function(w, req)
    return w:write('hey!\n')
end)
```

#### app:all(pattern \[, route_name] [, function(following, options), ...], function(w, req))

Routes an HTTP request regardless HTTP verb.

```lua
app:all('hi', function(w)
    return w:write('hi')
end)
```

The actual HTTP verb can be obtained from request, e.g.:

```lua
app:all('hi', function(w, req)
    return w:write(req.method)
end)
```

The following table describes the arguments.

| Argument                                 | Description                              |
| :--------------------------------------- | ---------------------------------------- |
| pattern                                  | The path for which the middleware function is invoked, it can be a string representing a path or a regular expression pattern. |
| route_name                               | The name used to address this route in reverse URL lookup. Optional. |
| [function (following, options)](#functionfollowing-options) | Middleware function. See below.          |
| [function (w, req)](#functionw-req)      | Request handler function. See below.     |

##### function(following, options)

Middleware function (interceptor) can be used to impose pre-conditions on a
route handler.

```lua
local function middleware(following, options)
    return function(w, req)
        return following(w, req)
    end
end
```

The `following` object by convention corresponds to the next route handler,
which is a `function(w, req)`; `options` is a table used to initialize
application and holds properties that are specific to application and shared
across.

> The middleware function is called only once during application initialization,
> while returning function for route handling on each request routed.

The middleware function does not influence routing, that means if a call to
`following` has not been made, the processing is still considered successful,
an attempt to find a next matching route is not performed.

A return value of middleware function is ignored, however
`return following(w, req)` enables Lua's tail call, thus generally preferred.
