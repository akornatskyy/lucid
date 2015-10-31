local digest = require 'security.crypto.digest'
local etag = require 'http.etag'
local request_key = require 'http.request_key'
local concat, next = table.concat, next


local function pack(w)
    local status_code = w:get_status_code()
    local headers = w.headers
    local r = {b = w.buffer}
    if status_code ~= 0 and status_code ~= 200 then
        r.s = status_code
    end
    if next(headers) ~= nil then
        r.h = headers
    end
    return r
end

local function unpack(w, r)
    local status_code = r.s
    local headers = r.h
    local body = r.b
    if status_code then
        w:set_status_code(status_code)
    end
    if headers then
        w.headers = headers
    end
    w.buffer = body
end

return function(options, following)
    local cache = options.cache
    assert(cache, 'cache')
    local make_key = request_key.new '$m:$p'
    local make_etag = etag.new(digest.new 'md5')
    local profiles = {}
    return function(w, req)
        local key
        local mkey = make_key(req)
        local mprofile = profiles[mkey]
        if mprofile then
            key = mprofile.key(req)
            local r = cache:get(key)
            if r then
                return unpack(w, r)
            end
        end
        following(w, req)
        local profile = w.cache_profile
        if profile then
            if profile ~= mprofile then
                profiles[mkey] = profile
                key = profile.key(req)
            end
            local b = concat(w.buffer)
            w.buffer = b
            w.headers['ETag'] = make_etag(b)
            cache:set(key, pack(w), profile.time)
        end
    end
end
