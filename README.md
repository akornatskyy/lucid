# Lua web API toolkit

[![Build Status](https://travis-ci.org/akornatskyy/lucid.svg?branch=master)](https://travis-ci.org/akornatskyy/lucid)
[![Coverage Status](https://coveralls.io/repos/akornatskyy/lucid/badge.svg?branch=master&service=github)](https://coveralls.io/github/akornatskyy/lucid?branch=master)
[![Licence](http://img.shields.io/badge/Licence-MIT-brightgreen.svg)](LICENSE)

A playground for lua web API toolkit.

# Setup

Install development dependencies:

    make env nginx
    make test
    eval "$(env/bin/luarocks path --bin)"

# Run

Serve files with web server:

    cd env/nginx
    objs/nginx -c conf/lucid.conf
    curl -i http://localhost:8080

Open your browser at [http://localhost:8080](http://localhost:8080)
