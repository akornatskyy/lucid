# Supported tags and respective Dockerfile links

- dev-luajit2.1-alpine ([Dockerfile](https://github.com/akornatskyy/lucid/blob/master/docker/dev/luajit2.1/alpine/Dockerfile))

# How to use this image

This image is based on the [Alpine Linux](https://alpinelinux.org). For more information about this image and its history, please see [github](https://github.com/akornatskyy/lucid/tree/master/docker).

```
docker run -it --rm -p 8080:8080 akorn/lucid:dev-luajit2.1-alpine
```

# How to run demos

By setting environment variable `app` you can control which demo app is
running.

```
docker run -it --rm -p 8080:8080 -v `pwd`/demos:/app \
    -e app=http.hello akorn/lucid:dev-luajit2.1-alpine
```

---

# What is Lucid?

[Lucid](https://github.com/akornatskyy/lucid) is a web API toolkit for the Lua programming language.