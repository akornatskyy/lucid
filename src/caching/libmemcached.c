#include <assert.h>
#include <errno.h>
#include <string.h>
#include <libmemcached/memcached.h>

#include "lua.h"
#include "lauxlib.h"

#define MC_STATE        "memcached state"

#define FLAG_NONE       0
#define FLAG_BOOLEAN    1
#define FLAG_NUMBER     2
#define FLAG_ENCODED    7


int luaopen_libmemcached(lua_State *L);


typedef memcached_return_t
(memcached_set_pt)(memcached_st *ptr, const char *key, size_t key_length,
                   const char *value, size_t value_length, time_t expiration,
                   uint32_t flags);

typedef memcached_return_t
(memcached_incr_pt)(memcached_st *ptr, const char *key, size_t key_length,
                    uint32_t offset, uint64_t *value);


typedef struct {
    memcached_st    *mc;
    int             key_encode;
    int             encode;
    int             decode;
} mc_data;


static int
l_new(lua_State *L)
{
    int key_encode, encode, decode;
    const char *config_string = luaL_checkstring(L, 1);

    luaL_checktype(L, 2, LUA_TTABLE);

    lua_getfield(L, 2, "encode");
    if (!lua_isfunction(L, -1)) {
        return luaL_error(L, "bad argument #2 ('encode' "
                             "function is missing)");
    }

    lua_getfield(L, 2, "decode");
    if (!lua_isfunction(L, -1)) {
        return luaL_error(L, "bad argument #2 ('decode' "
                             "function is missing)");
    }

    if (lua_isnone(L, 3)) {
        key_encode = 0;
    }
    else if (lua_isfunction(L, 3)) {
        lua_pushvalue(L, 3);
        key_encode = luaL_ref(L, LUA_REGISTRYINDEX);
    }
    else {
        return luaL_error(L, "bad argument #3 ('key_encode' "
                             "must be a function)");
    }

    decode = luaL_ref(L, LUA_REGISTRYINDEX);
    encode = luaL_ref(L, LUA_REGISTRYINDEX);

    mc_data *d = (mc_data *)lua_newuserdata(L, sizeof(mc_data));
    luaL_getmetatable(L, MC_STATE);
    lua_setmetatable(L, -2);

    d->mc = memcached(config_string, strlen(config_string));
    // memcached_behavior_set(d->mc, MEMCACHED_BEHAVIOR_TCP_NODELAY, 1);
    d->encode = encode;
    d->decode = decode;
    d->key_encode = key_encode;

    return 1;
}


static int
l_gc(lua_State *L)
{
    mc_data *d = (mc_data *)luaL_checkudata(L, 1, MC_STATE);

    if (d != NULL && d->mc != NULL) {
        memcached_free(d->mc);
        d->mc = NULL;

        luaL_unref(L, LUA_REGISTRYINDEX, d->decode);
        luaL_unref(L, LUA_REGISTRYINDEX, d->encode);
        if (d->key_encode) {
            luaL_unref(L, LUA_REGISTRYINDEX, d->key_encode);
        }

        d->decode = d->encode = d->key_encode = 0;
    }

    return 0;
}


static int
l_error(lua_State *L, const memcached_return_t rc)
{
    lua_pushnil(L);

    if (rc == MEMCACHED_ERRNO) {
        lua_pushstring(L, strerror(errno));
    }
    else {
        const mc_data *d = (mc_data *)luaL_checkudata(L, 1, MC_STATE);
        lua_pushstring(L, memcached_last_error_message(d->mc));
    }

    return 2;
}


static const char *
l_key_encode(lua_State *L, const mc_data *d, int narg, size_t *key_length)
{
    const char *key = luaL_checklstring(L, narg, key_length);
    if (*key_length >= MEMCACHED_MAX_KEY - 1) {
        if (d->key_encode) {
            lua_rawgeti(L, LUA_REGISTRYINDEX, d->key_encode);
            lua_pushvalue(L, narg);
            lua_call(L, 1, 1);
            key = luaL_checklstring(L, -1, key_length);
            lua_pop(L, 1);
        }
        else {
            lua_pushliteral(L, "key is too long");
            lua_error(L);
            return NULL;
        }
    }

    return key;
}


static int
l_get(lua_State *L)
{
    const mc_data *d;
    const char *key;
    size_t key_length;
    char *value;
    size_t value_length;
    uint32_t flags;
    memcached_return_t rc;

    d = (mc_data *)luaL_checkudata(L, 1, MC_STATE);
    key = l_key_encode(L, d, 2, &key_length);

    value = memcached_get(d->mc, key, key_length, &value_length, &flags, &rc);

    if (value != NULL) {
        switch(flags) {
            case FLAG_ENCODED:
                lua_rawgeti(L, LUA_REGISTRYINDEX, d->decode);
                lua_pushlstring(L, value, value_length);
                free(value);
                lua_call(L, 1, 1);
                break;

            case FLAG_NUMBER:
                lua_pushlstring(L, value, value_length);
                free(value);
                lua_Number number = lua_tonumber(L, -1);
                lua_pop(L, 1);
                lua_pushnumber(L, number);
                break;

            case FLAG_BOOLEAN:
                lua_pushboolean(L, *value == '1' ? 1 : 0);
                free(value);
                break;

            default:
                lua_pushlstring(L, value, value_length);
                free(value);
                break;
        }

        return 1;
    }
    else if (rc == MEMCACHED_SUCCESS) {
        lua_pushliteral(L, "");
        return 1;
    }
    else if (rc == MEMCACHED_NOTFOUND) {
        lua_pushnil(L);
        return 1;
    }

    return l_error(L, rc);
}


static int
l_get_multi(lua_State *L)
{
    const mc_data *d;
    memcached_return_t rc;

    d = (mc_data *)luaL_checkudata(L, 1, MC_STATE);

    luaL_checktype(L, 2, LUA_TTABLE);

    int i;
    const int n = lua_objlen(L, 2);
    const char *keys[n];
    size_t keys_size[n];

    for (i = 0; i < n; i++) {
        lua_rawgeti(L, 2, i + 1);
        keys[i] = lua_tolstring(L, -1, &keys_size[i]);
        lua_pop(L, 1);
    }

    assert(2 == lua_gettop(L));

    rc = memcached_mget(d->mc, keys, keys_size, n);

    if (rc != MEMCACHED_SUCCESS) {
        return l_error(L, rc);
    }

    char key[MEMCACHED_MAX_KEY];
    size_t key_length;
    char *value;
    size_t value_length;
    uint32_t flags;

    lua_newtable(L);

    for (;;) {
        value = memcached_fetch(d->mc, key, &key_length,
                                &value_length, &flags, &rc);
        if (rc != MEMCACHED_SUCCESS) {
            return 1;
        }

        lua_pushlstring(L, key, key_length);

        if (value != NULL) {
            switch(flags) {
                case FLAG_ENCODED:
                    lua_rawgeti(L, LUA_REGISTRYINDEX, d->decode);
                    lua_pushlstring(L, value, value_length);
                    free(value);
                    lua_call(L, 1, 1);
                    break;

                case FLAG_NUMBER:
                    lua_pushlstring(L, value, value_length);
                    free(value);
                    lua_Number number = lua_tonumber(L, -1);
                    lua_pop(L, 1);
                    lua_pushnumber(L, number);
                    break;

                case FLAG_BOOLEAN:
                    lua_pushboolean(L, *value == '1' ? 1 : 0);
                    free(value);
                    break;

                default:
                    lua_pushlstring(L, value, value_length);
                    free(value);
                    break;
            }
        }
        else {
            lua_pushliteral(L, "");
        }

        lua_rawset(L, -3);
    }
}


static memcached_return_t
l_put(lua_State *L, memcached_set_pt f)
{
    const mc_data *d;
    const char *key;
    size_t key_length;
    const char *value;
    size_t value_length;
    time_t expiration;
    uint32_t flags;

    d = (mc_data *)luaL_checkudata(L, 1, MC_STATE);
    key = l_key_encode(L, d, 2, &key_length);
    expiration = luaL_optnumber(L, 4, 0);

    switch(lua_type(L, 3)) {
        case LUA_TTABLE:
            flags = FLAG_ENCODED;
            lua_rawgeti(L, LUA_REGISTRYINDEX, d->encode);
            lua_pushvalue(L, 3);
            lua_call(L, 1, 1);
            value = luaL_checklstring(L, -1, &value_length);
            break;

        case LUA_TNUMBER:
            flags = FLAG_NUMBER;
            value = lua_tolstring(L, -1, &value_length);
            break;

        case LUA_TBOOLEAN:
            flags = FLAG_BOOLEAN;
            value = lua_toboolean(L, -1) ? "1" : "0";
            value_length = 1;
            break;

        case LUA_TSTRING:
            flags = FLAG_NONE;
            value = luaL_checklstring(L, 3, &value_length);
            break;

        default:
            return luaL_error(L, "unsuported value type");
    }

    return f(d->mc, key, key_length, value, value_length,
             expiration, flags);
}


static int
l_set(lua_State *L)
{
    const memcached_return_t rc = l_put(L, memcached_set);

    if (rc == MEMCACHED_SUCCESS) {
        lua_pushboolean(L, 1);
        return 1;
    }

    return l_error(L, rc);
}


static int
l_add(lua_State *L)
{
    const memcached_return_t rc = l_put(L, memcached_add);

    if (rc == MEMCACHED_SUCCESS) {
        lua_pushboolean(L, 1);
        return 1;
    }
    else if (rc == MEMCACHED_DATA_EXISTS) {
        lua_pushnil(L);
        return 1;
    }

    return l_error(L, rc);
}


static int
l_replace(lua_State *L)
{
    const memcached_return_t rc = l_put(L, memcached_replace);

    if (rc == MEMCACHED_SUCCESS) {
        lua_pushboolean(L, 1);
        return 1;
    }
    else if (rc == MEMCACHED_NOTFOUND) {
        lua_pushnil(L);
        return 1;
    }

    return l_error(L, rc);
}


static int
l_append(lua_State *L)
{
    const memcached_return_t rc = l_put(L, memcached_append);

    if (rc == MEMCACHED_SUCCESS) {
        lua_pushboolean(L, 1);
        return 1;
    }
    else if (rc == MEMCACHED_NOTSTORED) {
        lua_pushnil(L);
        return 1;
    }

    return l_error(L, rc);
}


static int
l_prepend(lua_State *L)
{
    const memcached_return_t rc = l_put(L, memcached_prepend);

    if (rc == MEMCACHED_SUCCESS) {
        lua_pushboolean(L, 1);
        return 1;
    }
    else if (rc == MEMCACHED_NOTSTORED) {
        lua_pushnil(L);
        return 1;
    }

    return l_error(L, rc);
}


static int
l_delete(lua_State *L)
{
    const mc_data *d;
    const char *key;
    size_t key_length;
    time_t expiration;
    memcached_return_t rc;

    d = (mc_data *)luaL_checkudata(L, 1, MC_STATE);
    key = l_key_encode(L, d, 2, &key_length);
    expiration = luaL_optnumber(L, 3, 0);

    rc = memcached_delete(d->mc, key, key_length, expiration);

    if (rc == MEMCACHED_SUCCESS) {
        lua_pushboolean(L, 1);
        return 1;
    }
    else if (rc == MEMCACHED_NOTFOUND) {
        lua_pushnil(L);
        return 1;
    }

    return l_error(L, rc);
}


static int
l_touch(lua_State *L)
{
    const mc_data *d;
    const char *key;
    size_t key_length;
    time_t expiration;
    memcached_return_t rc;

    d = (mc_data *)luaL_checkudata(L, 1, MC_STATE);
    key = l_key_encode(L, d, 2, &key_length);
    expiration = luaL_checknumber(L, 3);

    rc = memcached_touch(d->mc, key, key_length, expiration);

    if (rc == MEMCACHED_SUCCESS) {
        lua_pushboolean(L, 1);
        return 1;
    }
    else if (rc == MEMCACHED_NOTFOUND) {
        lua_pushnil(L);
        return 1;
    }

    return l_error(L, rc);
}


static int
l_incr_decr(lua_State *L, memcached_incr_pt f)
{
    const mc_data *d;
    const char *key;
    size_t key_length;
    uint32_t offset;
    uint64_t value;
    memcached_return_t rc;

    d = (mc_data *)luaL_checkudata(L, 1, MC_STATE);
    key = l_key_encode(L, d, 2, &key_length);
    offset = luaL_optnumber(L, 3, 1);

    rc = f(d->mc, key, key_length, offset, &value);

    if (rc == MEMCACHED_SUCCESS) {
        lua_pushnumber(L, value);
        return 1;
    }
    else if (rc == MEMCACHED_NOTFOUND) {
        lua_pushnil(L);
        return 1;
    }

    return l_error(L, rc);
}


static int
l_incr(lua_State *L)
{
    return l_incr_decr(L, memcached_increment);
}


static int
l_decr(lua_State *L)
{
    return l_incr_decr(L, memcached_decrement);
}


static int
l_exist(lua_State *L)
{
    mc_data *d;
    const char *key;
    size_t key_length;
    memcached_return_t rc;

    d = (mc_data *)luaL_checkudata(L, 1, MC_STATE);
    key = l_key_encode(L, d, 2, &key_length);

    rc = memcached_exist(d->mc, key, key_length);

    if (rc == MEMCACHED_SUCCESS) {
        lua_pushboolean(L, 1);
        return 1;
    }
    else if (rc == MEMCACHED_NOTFOUND) {
        lua_pushnil(L);
        return 1;
    }

    return l_error(L, rc);
}


static int
l_flush(lua_State *L)
{
    mc_data *d;
    time_t expiration;
    memcached_return_t rc;

    d = (mc_data *)luaL_checkudata(L, 1, MC_STATE);
    expiration = luaL_optnumber(L, 2, 0);

    rc = memcached_flush(d->mc, expiration);

    if (rc == MEMCACHED_SUCCESS) {
        lua_pushboolean(L, 1);
        return 1;
    }

    return l_error(L, rc);
}


#if !defined LUA_VERSION_NUM || LUA_VERSION_NUM==501

static void
l_setfuncs(lua_State *L, const luaL_Reg *l)
{
    for (; l->name != NULL; l++) {
        lua_pushstring(L, l->name);
        lua_pushcclosure(L, l->func, 0);
        lua_settable(L, -3);
    }
}

#endif


static int
l_createmeta(lua_State *L, const char *name, const luaL_Reg *methods)
{
    if (!luaL_newmetatable(L, name)) {
        return 0;
    }

    l_setfuncs(L, methods);

    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index");

    lua_pushliteral(L, "it is not allowed to get metatable.");
    lua_setfield(L, -2, "__metatable");

    return 1;
}


int
luaopen_libmemcached(lua_State *L)
{
    luaL_Reg methods[] = {
        { "new", l_new },
        { }
    };
    luaL_Reg state_methods[] = {
        { "__gc", l_gc },
        { "close", l_gc },
        { "get", l_get },
        { "get_multi", l_get_multi },
        { "set", l_set },
        { "add", l_add },
        { "replace", l_replace },
        { "append", l_append },
        { "prepend", l_prepend },
        { "delete", l_delete },
        { "touch", l_touch },
        { "incr", l_incr },
        { "decr", l_decr },
        { "exist", l_exist },
        { "flush", l_flush },
        { }
    };

    if (!l_createmeta(L, MC_STATE, state_methods)) {
        return 0;
    }

    // TODO: check
    lua_pop(L, 1);

    // module
    lua_newtable(L);

    // status
    /*lua_newtable(L);

    lua_pushinteger(L, MEMCACHED_SUCCESS);
    lua_setfield(L, -2, "OK");

    lua_pushinteger(L, MEMCACHED_NOTSTORED);
    lua_setfield(L, -2, "NOTSTORED");

    lua_setfield(L, -2, "status");*/

    l_setfuncs(L, methods);

    return 1;
}
