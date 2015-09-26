# Lua web API toolkit

A playground for lua web API toolkit.

# Setup

Install development dependencies:

    make env nginx

# Run

Serve files with web server:

    cd env/nginx
    objs/nginx -c conf/lucid.conf
    curl -i http://localhost:8080

Open your browser at [http://localhost:8080](http://localhost:8080)