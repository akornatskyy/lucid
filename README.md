# Lua Web API Toolkit

[![Build Status](https://travis-ci.org/akornatskyy/lucid.svg?branch=master)](https://travis-ci.org/akornatskyy/lucid)
[![Coverage Status](https://coveralls.io/repos/akornatskyy/lucid/badge.svg?branch=master&service=github)](https://coveralls.io/github/akornatskyy/lucid?branch=master)

A web API toolkit playground for the [Lua](http://www.lua.org/) programming language.

# Installation

```sh
luarocks install --server=http://luarocks.org/dev lucid
```

# Overview

Using function:

```lua
local http = require 'http'
local app = http.app.new()

app:get('', function(w, req)
    return w:write('Hello World!\n')
end)

return app()
```

... or metaclass:

```lua
local class = require 'core.class'
local web = require 'web'

local WelcomeHandler = class({
    get = function(self)
        self.w:write('Hello World!\n')
    end
})

local options = {
    urls = {
        {'', WelcomeHandler}
    }
}

return web.app({web.middleware.routing}, options)
```

# Setup

Install development dependencies:

```sh
make env nginx
make test
eval "$(env/bin/luarocks path --bin)"
```

# Run

Check from command line:

```sh
lurl -v demos/hello.lua /
```

Serve files with web server:

```sh
export app=demos.hello ; make run
curl -v http://localhost:8080
```

Open your browser at [http://localhost:8080](http://localhost:8080)
