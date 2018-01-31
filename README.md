# Lua Web API Toolkit

[![Build Status](https://travis-ci.org/akornatskyy/lucid.svg?branch=master)](https://travis-ci.org/akornatskyy/lucid)
[![Coverage Status](https://coveralls.io/repos/akornatskyy/lucid/badge.svg?branch=master&service=github)](https://coveralls.io/github/akornatskyy/lucid?branch=master)

A web API toolkit playground for the [Lua](http://www.lua.org/) programming
language.

# Table of Contents

<!-- TOC depthFrom:1 depthTo:2 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Lua Web API Toolkit](#lua-web-api-toolkit)
- [Table of Contents](#table-of-contents)
- [Installation](#installation)
- [Overview](#overview)
- [Setup](#setup)
- [Run](#run)
- [HTTP API Reference](#http-api-reference)
	- [Application](#application)
	- [Request](#request)
	- [Response Writer](#response-writer)
	- [Cookie](#cookie)
	- [Middlewares](#middlewares)
	- [Mixins](#mixins)
	- [Nginx Adapters](#nginx-adapters)
- [Validation API Reference](#validation-api-reference)
	- [Model Binder](#model-binder)
	- [Validator](#validator)
	- [Mixins](#mixins)
	- [Rules](#rules)
- [Web API Reference](#web-api-reference)
	- [Application](#application)
	- [Middlewares](#middlewares)
	- [Mixins](#mixins)
- [Tools](#tools)
	- [lurl](#lurl)

<!-- /TOC -->

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

**Example: middleware function**

Here is an example that shows the use of multiple middleware functions:

```lua
local function interceptor1(following, options)
  return function(w, req)
    print('before1')
    following(w, req)
    print('after1')
  end
end

local function interceptor2(following, options)
  return function(w, req)
    print('before2')
    following(w, req)
    print('after2')
  end
end

app:all('hi', interceptor1, interceptor2, function(w, req)
  print('hi')
  return w:write(req.method)
end)
```

The `interceptor1` and `interceptor2` middleware functions intercept all
calls (one after another) to corresponding route handler function.

You can use multiple middleware functions, the execution order is from left to
right. The above example prints:

```
before1
before2
hi
after2
after1
```

##### function(w, req)

HTTP route / request handler function processes application logic and writes
response if any.

```lua
local function handler(w, req)
    return w:write('hi')
end
```

The [w](#response-writer) object by convention corresponds to HTTP response
writer, [req](#request) to HTTP request. If `req` object is not used it can be
safely omitted.

```lua
local function handler(w)
    return w:write('hi')
end
```

A return value of HTTP route handler function is ignored, however
`return following(w, req)` enables Lua's tail call, thus generally
preferred.

#### app:route(pattern [, route_name])

Returns an instance of a route, which can be used to further handle HTTP verbs.

```lua
app:route('hi')
:get(function(w, req)
    -- respond to HTTP GET request
end)
:post(function(w)
    -- respond to HTTP POST request
end)
```

Use `app:route()` to specify HTTP verb that does not have a valid map in
`http.app.http_verbs`.

```lua
app:route('hi')['OPTIONS'](function(w)
end)
```

Use `app:route()` to avoid duplicate routing patterns and potential typo
errors.

#### app:use(middleware)

Mounts the specified [middleware](#functionfollowing-options) function. The
middleware function is executed for each request served by the application.

```lua
local http = require 'http'

local app = http.app.new()
app:use(http.middleware.routing)
```

## Request

The `req` object represents the HTTP request and has properties for the
request method, path, HTTP headers, and so on. By convention, the object is
always referred to as `req`.

### Properties

#### req.options

This property holds a reference to the instance of the application
[app.options](#appoptions).

#### req.method

Contains a string corresponding to the HTTP method of the request: GET, POST,
PATCH, and so on.

#### req.path

Contains the path part of the request URL.

```lua
-- http://blog.example.com/api/v1/posts?q=lua
req.path
-- "/api/v1/posts"
```

#### req.route_args

This property is a table containing properties mapped to the named route
“arguments” set by [routing](#routing) middleware.

```lua
app:get('{locale}/user/{user_id:i}', function(w, req)
    return w:write(req:route_args.user_id)
end)
-- path: /en/user/123
req.route_args
-- {["locale"] = "en", ["user_id"] = "123"}
```

The `req.route_args` can have a reserved property `route_name`
if there is an associated name with the request handler.

```lua
app:get('{locale}/user/{user_id:i}', 'user', function(w, req)
end)
-- path: /en/user/123
req.route_args.route_name
-- "user"
```

If there is no route arguments, it is the empty table, `{}`.

#### req.query

This property is a table containing a property for each query string parameter
(case-sensitive) in the route.

> The value is a `string` for a single occurrence of query parameter or a
> `table` for multiple values.

```lua
-- http://blog.example.com/api/v1/posts?q=lua&page=2
req.query
-- {["q"] = "lua", ["page" = "2"]}
req.query.q
-- "lua"
req.query.page
-- "2"
```

Use `req.query` or `req:parse_query()`.

```lua
app:get('', function(w, req)
    local qs = req.query or req:parse_query()
    -- ...
end)
```

If there is no query string, it is the empty table, `{}`.

```lua
-- http://blog.example.com/api/v1/posts
req.query
-- {}
```

> The `req.query` table is `nil` unless you call  `req:parse_query()`
> first.

#### req.headers

This property is a table containing a property for each HTTP header name
(lowercase).

> The value is a `string` for a single occurrence of HTTP header or a
> `table` for multiple values.

Use `req.headers` or `req:parse_headers()`.

```lua
app:get('', function(w, req)
    local headers = req.headers or req:parse_headers()
    -- ...
end)
```

> The `req.headers` table is `nil` unless you call
> `req:parse_headers()` first.

Use `req.headers` to determine whenever the request is AJAX.

```lua
local headers = self.headers or self:parse_headers()
local is_ajax = headers['x-requested-with'] == 'XMLHttpRequest'
```

#### req.cookies

This property is a table that contains HTTP cookies (case-sensitive).

Use `req.cookies` or `req:parse_cookie()`.

```lua
app:get('', function(w, req)
    local cookies = req.cookies or req:parse_cookie()
    -- ...
end)
```

The `req:parse_cookie()` uses an empty name if not specified.

```lua
-- Cookie:
req.cookies
-- {['']=''}
-- Cookie: abc
req.cookies
-- {['']='abc'}
```

Returns a table with mapped cookie name to value.

```lua
-- Cookie: a=1
req.cookies
-- {['a']='1'}
-- Cookie: a=1; b=2
req.cookies
-- {a='1', b='2'}
```

Supports cookie value with spaces.

```lua
-- Cookie: c1=a b; c2= ; c3=a ; c4= b
req.cookies
-- {['c1']='a b', ['c2']=' ', ['c3']='a ', ['c4']=' b'}
```

If there is no cookies, it is the empty table, `{}`.

> The `req.cookies` table is `nil` unless you call
> `req:parse_cookies()` first.

#### req.body

This property type depends on *MIME type* of incoming HTTP request.

| MIME Type                         | Value                                    |
| --------------------------------- | ---------------------------------------- |
| application/x-www-form-urlencoded | a table that contains all the current request POST query arguments. |
| application/json                  | a table that corresponds to parsed JSON object, either array or map. |
| multipart/form-data               | a string, in-memory request body data.   |

Use `req.body` or `req:parse_body()`.

```lua
local values = req.body or req:parse_body()
```

> To force in-memory request bodies, set
> [client_body_buffer_size](http://nginx.org/en/docs/http/ngx_http_core_module.html#client_body_buffer_size)
> to the same size value in
> [client_max_body_size](http://nginx.org/en/docs/http/ngx_http_core_module.html#client_max_body_size).

This function returns `nil` if the request body has zero size.

### Methods

#### req:parse_query()

Parses HTTP query string.

See [req.query](#reqquery).

#### req:parse_headers()

Parses HTTP headers.

See [req.headers](#reqheaders).

#### req:parse_cookie()

Parses HTTP cookie header.

See [req.cookies](#reqcookies).

#### req:parse_body()

Parses HTTP body.

See [req.body](#reqbody).

#### req:server_parts()

Returns multiple values representing various server parts.

```lua
-- http://blog.example.com/api/v1/posts?q=lua
local scheme, host, port = req:server_parts()
-- "http", "blog.example.com", "80"
```

Use `req.server_parts()` to build request URL authority part.

```lua
local authority = scheme .. '://' .. host
    .. (port == '80' and '' or ':' .. port)
-- http://blog.example.com
```

## Response Writer

The `w` object represents the HTTP response and has properties for the
response HTTP headers. By convention, the object is always referred to as `w`.

### Properties

#### w.headers

This property is a table that contains HTTP headers. The keys of the returned
table are the header names (case-insensitive) and the values are the respective
header values.

> The value is a `string` for a single occurrence of HTTP header or a
> `table` for multiple values.

```lua
-- w.headers['X-Request-Count'] = '100'
w.headers['X-Request-Count']
-- "100"
w.headers['x-request-count']
-- "100"
```

Use table to set multiple values.

```lua
-- w.headers['Set-Cookie'] = {'a=1', 'b=2'}
w.headers['set-cookie']
-- {"a=1", "b=2"}
```

> Use value `nil` to remove corresponding HTTP response header.

### Methods

#### w:get_status_code()

Returns the status code which was sent to the client.

> `nil` value indicates successful HTTP response.

#### w:set_status_code(code)

Controls the HTTP status code that will be sent to the client when the headers
get flushed.

```lua
w:set_status_code(403)
```

#### w:write(c)

Sends a chunk `c` of the response body. This method may be called multiple
times to provide successive parts of the body.

> The response body is omitted when the request is a HEAD request. The 204
> and 304 responses must not include a body.

The behavior of this method depends on adapter in use.

| Adapter  | Behavior                                 |
| -------- | ---------------------------------------- |
| buffered | The `w:write()` calls are buffered. The headers and body is sent to the client  when application will finish processing request. |
| stream   | The first time `w:write()` is called, it will send the headers and the first chunk of the body to the client. |

> This method sends the raw HTTP body and do not perform any body
> encodings.

#### w:flush()

Flushes response output to the client asynchronously.

> This method returns immediately without waiting for output data to be
> written into the system send buffer.

> This function has no effect in case of buffered adapter in use.

#### w:add_header(name, value)

Adds a single string value for HTTP header.

```lua
w:addHeader('Set-Cookie', 'c=100')
```

> If this header already exists it will add value so multiple headers withthe same
> name will be sent.

#### w:set_cookie(s)

Sets specified cookie string by adding `Set-Cookie` HTTP header.

```lua
w:set_cookie(http.cookie.dump {
    name = 'c', value = '100', http_only = true
})
w.headers['Set-Cookie']
-- c=100; HttpOnly
```

Use this method to delete cookie.

```lua
w:set_cookie(http.cookie.delete {name = 'c'})
w.headers['Set-Cookie']
-- c=; Expires=Thu, 01 Jan 1970 00:00:00 GMT
```

#### w:redirect(absolute_url[, status_code=302])

Redirects to the absolute URL with specified status that corresponds to an HTTP
status code. If not specified, status defaults to “302 “Found”.

```lua
w:redirect('http://example.com')
```

Use this method together with routing mixin to redirect to named routes.

```lua
local mixin = require 'core.mixin'
local http = require 'http'

mixin(http.Request, http.mixins.routing)

app:get('', function(w, req)
    return w:redirect(req:absolute_url_for('welcome'))
end)

app:get('welcome', 'welcome', function(w, req)
    return w:write('Hello World!\n')
end)
```

## Cookie

An HTTP cookie (browser cookie) is a small piece of data that a server sends to
the user's web browser. The browser may store it and send it back with the next
request to the same server.

The `http.cookie` module represents the HTTP cookie.

#### http.cookie.dump(options)

Returns a string that represents the HTTP cookie per `options` provided.

```lua
http.cookie.dump {name='a', value='1'}
-- "a=1"
http.cookie.dump {name='a', value='1', path='/abc/'}
-- "a=1; Path=/abc/"
http.cookie.dump {name='a', value='1', domain='example.com'}
-- "a=1; Domain=example.com"
http.cookie.dump {name='a', value='1', expires=1423473707}
-- "a=1; Expires=Mon, 09 Feb 2015 09:21:47 GMT"
http.cookie.dump {name='a', value='1', max_age=600}
-- "a=1; Max-Age=600"
http.cookie.dump {name='a', value='1', same_site='Strict'}
-- "a=1; SameSite=Strict"
http.cookie.dump {name='a', value='1', http_only=true}
-- "a=1; HttpOnly"
http.cookie.dump {name='a', value='1', secure=true}
-- "a=1; Secure"
```

The following table describes the options.

| Property  | Type    | Description                              |
| --------- | ------- | ---------------------------------------- |
| name      | string  | Name of the cookie.                      |
| value     | string  | Cookie value.                            |
| path      | string  | Path for the cookie.                     |
| domain    | string  | Domain name for the cookie.              |
| expires   | number  | Expiry date of the cookie in GMT. If not specified creates a session cookie. |
| max_age   | number  | The expiry time relative to the current time in milliseconds. |
| same_site | string  | Can be used to disable third-party usage for a specific cookie. Either Lax or Strict. |
| http_only | boolean | Flags the cookie to be accessible only by the web server. |
| secure    | boolean | Marks the cookie to be used with HTTPS only. |

#### http.cookie.delete(options)

Returns a string that corresponds to an empty expired cookie.

```lua
http.cookie.delete {name='a'}
-- a=; Expires=Thu, 01 Jan 1970 00:00:00 GMT
http.cookie.delete {name='a', path='/abc/'}
-- a=; Expires=Thu, 01 Jan 1970 00:00:00 GMT; Path=/abc/
```

See options in [http.cookie.dump](#httpcookiedump).

## Middlewares

[Middleware](#functionfollowing-options) functions are functions that have
access to the
[response writer](#response-writer) object (`w`),
the [request](#request) object (`req`), the
[following](#functionw-req) function, and the application
[options](#appoptions) in the application’s request processing lifecycle.

The `following` function is a function, when invoked, executes the
middleware succeeding the current one.

> If the current middleware function does not end the request processing cycle,
> it must call `following(w, req)` to pass control to the next middleware
> function.

**Configuration**

Middleware function receives application [options](#appoptions) during
initialization. However sometimes it is useful to override some settings per
middleware without affecting application options.

Use `http.middleware.opt` to override any middleware specific options over
those in application options.

```lua
local http = require 'http'
local opt = require 'http.middleware.opt'

local app = http.app.new {
    option1 = 'A'
}

local function my_middleware(following, options)
    local option1 = options.option1
    -- option1 == 'B'
    return function(w, req)
        return following(w, req)
    end
end

app:use(opt(my_middleware, {
    option1 = 'B' -- this will override default in app.options
}))

app:use(http.middleware.routing)
app:get('', function(w, req)
    -- req.options.option1 == 'A'
end)
return app()
```

### authcookie

Authentication cookie middleware implements creation of signed and encrypted
authentication session cookie.

Use  response writer `w.principal` property to set or delete the security
principal associated with request authentication.

```lua
local http = require 'http'
local authcookie = http.middleware.authcookie

app:get('signin', authcookie, function(w, req)
    w.principal = {id = 'john.smith', roles = {admin = true}}
end)

app:get('signout', authcookie, function(w, req)
    w.principal = nil
end)
```

> The authentication cookie is set only on successful status code (2XX).

Use `app.options` to configure middleware.

```lua
local ticket = require 'security.crypto.ticket'
local digest = require 'security.crypto.digest'
local cipher = require 'security.crypto.cipher'
local http = require 'http'

local app = http.app.new {
    ticket = ticket.new {
        -- digest = digest.new('sha256'),
        digest = digest.hmac('ripemd160', 'b`*>Z!P4pf99%p,)'),
        cipher = cipher.new {
            cipher = 'aes128',
            key = 'DK((-x=e[.2cLq]f',
            iv = 'b#KXN>H9"j><f2N`'
        }
    },
    auth_cookie = {
        name = '_a'
    },
    principal = require 'security.principal'
}
```

The following table describes the configuration options.

| Property    | Type  | Description                              |
| ----------- | ----- | ---------------------------------------- |
| ticket      | table | Required. An object that provides secure string encoding, `ticket:encode(s)`. |
| auth_cookie | table | Optional. Defaults to `{name='_a'}`. The `http_only` is always `true`. If `path` is not specified, fallbacks to `options.root_path` or `/`. See more [here](#cookie). |
| principal   | table | Optional. An object that provides function `principal.dump(p)`, where `p` is a  table like: `{id='', roles={role1=true}, alias='', extra=''}`. Defaults to `require 'security.principal'`. |

> Use `auth_cookie.max_age` to control timeout before authentication cookie
> expires.

### authorize

Authorization middleware implements verification of signed and encrypted
authentication session cookie.

Use  request `req.principal` property to get the security principal associated
during request authentication.

```lua
app:get('secure', authorize, function(w, req)
    if not req.principal.roles['admin'] then
        return w:set_status_code(403)
    end
    -- req.principal.id
end)
```

The middleware responds with HTTP status code 401 (Unauthorized) in case the
authentication cookie is not in the request or cannot be decoded.

> The authentication cookie lifetime is automatically extended once cookie time
> left is less than a half of cookie max age.

See configuration options in [authcookie](#authcookie) middleware.

### caching

TODO

### cors

This middleware implements [cross-origin resource sharing](https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS).

```lua
local http = require 'http'

app:use(http.middleware.cors)
```

Use `app.options` to configure middleware.

```lua
local app = http.app.new {
    cors = http.cors.new {
        allow_credentials = true,    
        allowed_origins = {'*'},
        allowed_methods = {'GET', 'HEAD', 'POST', 'PUT', 'DELETE'},
        allowed_headers = {'content-type', 'x-requested-with'},
        exposed_headers = {'content-length', 'etag'},
        max_age = 180
    }
}
```

The following table describes the configuration options.

| Property          | Type    | Description                              |
| ----------------- | ------- | ---------------------------------------- |
| allow_credentials | boolean | Indicates whether the client is allowed to send credentials (cookies, authorization headers, etc) to the server. Defaults to `false`. |
| allowed_origins   | table   | Required. Indicates whether the response can be shared with resources with the given origin. For requests without credentials, specify "\*" as a wildcard, thereby allowing any origin to access the resource. Otherwise, specify a URI that may access the resource. |
| allowed_methods   | table   | Specifies the methods allowed when accessing the resource in response to a preflight request. Defaults to `{'GET', 'HEAD'}`. |
| allowed_headers   | table   | Used in response to a preflight request to indicate which HTTP headers will be available via *Access-Control-Expose-Headers* when making the actual request. |
| exposed_headers   | table   | Indicates which headers can be exposed as part of the response. Only [simple response headers](https://www.w3.org/TR/cors/#simple-response-header) are exposed. Use this property to allow clients to access other headers. |
| max_age           | number  | How long the results of a preflight request (that is the information contained in the *Access-Control-Allow-Methods* and *Access-Control-Allow-Headers* headers) can be cached. |

### routing

Routing refers to the definition of endpoints (URI paths) and how they respond to
client requests.

```lua
local http = require 'http'

app:use(http.middleware.routing)
```

A route method is derived from one of the HTTP methods and is attached to the
`app` object. Routing supports the following methods that correspond to HTTP
verbs: `get`, `head`, `post`, `patch`, `put`, `delete`.

Route path, in combination with a request method, define the endpoint at which
requests can be dispatched. Route path can be string pattern.

```lua
app:post('signin', function(w, req)
end)
```

There is a special routing method, `app:all()`, which is used to respond to all
request methods.

```lua
app:all('', function(w, req)
end)
```

Route arguments are named URL path segments that used to capture the values
specified at their position in the URL path. The captured values are populated in
the `req.route_args` table, with the name of the route arguments specified in
the URL path as the respective keys in the table.

```lua
-- URL: /en/user/123
-- route path: {locale}/user/{user_id:i}
-- req.route_args: {['locale'] = "en", ['user_id'] = "123"}
```

Use route arguments in the path.

```lua
app:get('{locale}/user/{user_id:i}', function(w, req)
end)
```

Because routing supports string patterns, specify type of the matching path
segment.

| Name                           | Pattern | Description                  |
| ------------------------------ | ------- | ---------------------------- |
| `i`, `int`, `number`, `digits` | `%d+`   | One or more digits.          |
| `w`, `word`                    | `%w+`   | One or more word characters. |
| `s`, `segment`, `part`         | `[^/]+` | Everything until `/`.        |
| `*`, `a`, `any`, `rest`        | `.+`    | Any match.                   |

Use named route to build URL from name.

```lua
-- URL: /en/user/123
-- route path: {locale}/user/{user_id:i}
req:path_for('user', {locale='de', user_id='1'})
-- "/de/user/1"
req:path_for('user', {user_id='1'})
-- "/en/user/2"
req:path_for('user')
-- "/en/user/123"
req:absolute_url_for('user')
-- "http://localhost:8080/en/user/123"
```

> If route argument is not specified, it is inherited from `req.route_args`.

Use routing mixin to build URL from name.

```lua
local mixin = require 'core.mixin'
local http = require 'http'

mixin(http.Request, http.mixins.routing)

app:get('{locale}/user/{user_id:i}', 'user', function(w, req)
    -- req:path_for('user', {user_id='1'})
    -- req:absolute_url_for('user')
end)
```

Use `app:route` to chain multiple request handlers to the same URL path.

```lua
app:route('users')
:get(function(w, req)
end)
:post(function(w, req)
end)
```

The following table describes the configuration options.

| Property            | Type    | Description                              |
| ------------------- | ------- | ---------------------------------------- |
| root_path           | string  | The URL path on which a router instance to be mounted. Defaults to `/`. |
| router              | object  | Defaults to `require 'routing.router'`.  |
| urls                | table   | Holds all URL mapping for the application. |
| allow_path_override | boolean | Specifies whenever allowed to override path that is already defined. Defaults to `false`. |

The routing middleware responds with HTTP status 404 (Not Found) in case there
is not match for `req.path`.

## Mixins

A mixin is a special kind of multiple inheritance. Specifically, it is used to provide
optional features or reuse of particular feature in different classes.

The mixins are not made to stand on their own. Usually, mixins assume some
context which they extend.

```lua
local mixin = require 'core.mixin'
```

### json mixin

Extends response writer (`w`) with ability to send JSON.

Use `mixin` to extend response writer:

```lua
local mixin = require 'core.mixin'
local http = require 'http'
mixin(http.ResponseWriter, http.mixins.json)
```

#### w:json(obj)

Sends a JSON response. This method sends a response (with the content-type
*application/json*) that is the `obj` parameter converted to a JSON string
using `core.encoding` module.

```lua
app:get('', function(w, req)
    return w:json({message = 'Hello World!'})
end)
```

The parameter can be any JSON type, including `table`, `string`, `boolean`,
or `number`, and `nil`.

### routing mixin

Extends request (`req`) with ability to resolve named routes.

Use `mixin` to extend request:

```lua
local mixin = require 'core.mixin'
local http = require 'http'
mixin(http.Request, http.mixins.routing)
```

#### req:path_for(name[, args])

Returns URL path part for route `name`, optionally substituting path named
segments with `args` table.

```lua
-- URL: /en/user/123
-- route path: {locale}/user/{user_id:i}
req:path_for('user', {user_id='1'})
-- "/en/user/1"
```

> Any route argument not provided by `args` is taken from `req.route_args`.

#### req:absolute_url_for(name[, args])

Returns URL for route `name`.

```lua
-- URL: http://localhost:8080/en/user/123
-- route path: {locale}/user/{user_id:i}
req:path_for('user', {user_id='1'})
-- "http://localhost:8080/en/user/1"
```

See [req:path_for](#reqpath_forname-args).

## Nginx Adapters

Provides integration with Nginx HTTP service using [lua-nginx-module](https://github.com/openresty/lua-nginx-module).

### buffered

This adapter buffers each chunk of `w:write()`, flushes once application finishes processing HTTP request.

```nginx
http {
    init_by_lua '
        local adapter = require "http.adapters.nginx.buffered"
        main = adapter(require(os.getenv("app") or "demos.http.hello"))
    ';
    server {
        listen       8080;
        server_name  127.0.0.1;
        location / {
            default_type 'text/plain';
            content_by_lua 'main(ngx)';
        }
    }
}
```

### stream

This adapter asynchronously writes data and will return immediately without
waiting for all the data to be written into the system send buffer.

```nginx
http {
    init_by_lua '
        local adapter = require "http.adapters.nginx.stream"
        main = adapter(require(os.getenv("app") or "demos.http.hello"))
    ';
    server {
        listen       8080;
        server_name  127.0.0.1;
        location / {
            default_type 'text/plain';
            content_by_lua 'main(ngx)';
        }
    }
}
```

# Validation API Reference

Data validation ensures data quality, that they are both correct and useful.

## Model Binder

The model binder converts a table of string values to corresponding Lua type
per target model attribute type. For example, if there is a model with an
attribute `message_id` and it defaults to numeric value 0, the model binder
attempts to convert source value to number.

**Example: binding a message model**

```lua
local binder = require 'validation.binder'

app:put('', function(w, req)
    local m = {message_id=0, message=''}
    local b = binder.new()
    local values = req.body or req:parse_body()
    if not b:bind(m, values) then
        w:set_status_code(400)
        return w:json(b.errors)
    end
end)
```

There are several model value adapters accessible in
`validation.model.adapters` table.

The following table describes behavior of corresponding model value adapter.

| Name    | Description                              |
| ------- | ---------------------------------------- |
| boolean | The `nil` and empty string `""` values are converted to `nil`. If source value type is not `boolean` , the adapter converts it to string and checks whenever it equals to `1` or `true`. |
| number  | The `nil` and empty string `""` values are converted to `nil`. Uses lua `tonumber` function for conversion. Adds an error message in case the input is not in numeric format. |
| string  | The `nil` returned as `nil`. If source value type is not `string`, the adapter uses `tostring` function for conversion. Trims returned value. |

> If source value is a table with multiple values, the last one is used.

Model value adapter is a function that satisfies the following contract:

```lua
local function my_adapter(value, translations)
    if value == nil then
        return nil, translations:gettext("My error message.")
    end
    return value
end
```

Where `value` - the original value, can be a table or a string or any JSON
compatible type.

The model can define specific adapters by using `adapters` attribute, which is a table per
attribute to adapt.

> Any attributes that have no corresponding name in the model are ignored.

### binder.new([translations])

### Properties

#### b.errors

### Methods

#### b:bind(model, values)

#### b:validate(model, validator)

## Validator

### validator.new(mapping)

## Mixins

### set_error

### validation

## Rules

### bytes{min, max}

### compare{equal, not_equal}

### email

### length{min, max}

### pattern{pattern, plain, negated}

### range{min, max}

### required

### succeed

# Web API Reference

## Application

## Middlewares

### routing

## Mixins

### authcookie

### json

### locale

### model

### principal

### routing

# Tools

## lurl

lurl is a tool that allows sending a request to an application and display response.

```
Usage: lurl [options...] <app> <path>
Options:
 -X COMMAND     Specify request command to use, e.g. POST
 -I             Fetch the headers only
 -H LINE        Pass custom header LINE, e.g. 'Accept: application/json'
 -d DATA        Request body data, e.g. '{"msg":"hello"}', 'msg=hello'
 -b             Issue a number of requests through iterations
 -v             Make the operation more talkative
```

Basic usage:

```
lurl -v demos/http/hello.lua /
```

Output:

```
req: {
    ["body"] = {},
    ["headers"] = {
        ["accept"] = "*/*",
        ["host"] = "localhost:8080",
        ["user-agent"] = "lurl/scm-0"
    },
    ["method"] = "GET",
    ["path"] = "/",
    ["query"] = {},
    ["route_args"] = {}
}
w: {
    ["buffer"] = {
        "Hello World!\
"
    },
    ["headers"] = {}
}
```
