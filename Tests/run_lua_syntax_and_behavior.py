#!/usr/bin/env python3
"""Optional local Lua syntax/behavior smoke checks using an already installed system liblua5.4.
Not a substitute for testing inside World of Warcraft Forever.
"""
import ctypes
from ctypes.util import find_library
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
lib_name = find_library("lua5.4")
if not lib_name:
    raise SystemExit("STOP: System-Lua 5.4 nicht verfuegbar; keine Installation gestartet")
lua = ctypes.CDLL(lib_name)
lua.luaL_newstate.restype = ctypes.c_void_p
lua.luaL_openlibs.argtypes = [ctypes.c_void_p]
lua.luaL_loadfilex.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_char_p]
lua.luaL_loadfilex.restype = ctypes.c_int
lua.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]
lua.lua_tolstring.restype = ctypes.c_char_p
lua.lua_close.argtypes = [ctypes.c_void_p]
lua.luaL_loadstring.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
lua.luaL_loadstring.restype = ctypes.c_int
lua.lua_pcallk.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_longlong, ctypes.c_void_p]
lua.lua_pcallk.restype = ctypes.c_int

state = lua.luaL_newstate()
try:
    lua.luaL_openlibs(state)
    files = sorted((ROOT / "WoWMarket").rglob("*.lua"))
    for path in files:
        result = lua.luaL_loadfilex(state, str(path).encode(), None)
        if result:
            raise AssertionError(f"Lua SYNTAX FAIL {path}: {lua.lua_tolstring(state, -1, None)}")
    print(f"PASS: Syntax {len(files)}/{len(files)} Lua-Dateien")
    # Execute the self-contained synthetic test in the sandbox with mocked game interfaces.
    for test_name in ("synthetic_lua_checks.lua", "synthetic_minimap_lua_checks.lua", "synthetic_ui_v0010.lua", "synthetic_ah_5000.lua", "synthetic_vendor_modern.lua"):
        test_script = ROOT / "Tests" / test_name
        script = ("assert(loadfile(%r))(%r)" % (str(test_script), str(ROOT / "WoWMarket"))).encode()
        result = lua.luaL_loadstring(state, script)
        if not result:
            result = lua.lua_pcallk(state, 0, 0, 0, 0, None)
        if result:
            raise AssertionError(f"Lua BEHAVIOR FAIL {test_name}: {lua.lua_tolstring(state, -1, None)}")
finally:
    lua.lua_close(state)
