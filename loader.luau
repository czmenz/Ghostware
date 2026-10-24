local BASE_URL = "https://raw.githubusercontent.com/czmenz/Ghostware/main/"

local function fetchSource(relPath)
    local url = BASE_URL .. relPath
    if game and type(game.HttpGet) == "function" then
        local ok, src = pcall(function() return game:HttpGet(url) end)
        if ok and type(src) == "string" and #src > 0 then
            return src
        end
    end
    local req = (typeof(request) == "function" and request)
        or (typeof(http_request) == "function" and http_request)
        or (syn and typeof(syn.request) == "function" and syn.request)
        or (getgenv and type(getgenv) == "function" and getgenv().request)
        or (getgenv and type(getgenv) == "function" and getgenv().http_request)
    if req then
        local ok, res = pcall(req, { Url = url, Method = "GET" })
        if ok and res and res.Body and type(res.Body) == "string" and #res.Body > 0 then
            return res.Body
        end
    end
    error(string.format("[Ghostware Loader] Failed to fetch '%s' from: %s", relPath, url), 2)
end

-- Spolehlivé získání globálního prostředí napříč executory
local _genv = (type(getgenv) == "function" and getgenv()) or shared or _G or {}
_genv.GW_BuildMode = "Release"
if shared then shared.GW_BuildMode = "Release" end
pcall(function() _G.GW_BuildMode = "Release" end)

local _loadstring = (type(loadstring) == "function" and loadstring)
    or (_genv and type(_genv.loadstring) == "function" and _genv.loadstring)
    or (type(load) == "function" and load)
    or loadstring

-- 1. Načtení FileDefineru přímo do paměti (žádné ukládání na disk)
local fileDefinerSrc = fetchSource("FileDefiner.luau")
local loadFileDefiner, compileErr = _loadstring(fileDefinerSrc, "@FileDefiner.luau")
if not loadFileDefiner then
    error(string.format("[Ghostware Loader] Failed to compile FileDefiner: %s", tostring(compileErr)), 2)
end

-- Spuštění FileDefineru + fallback na globální tabulku, pokud obfuskátor nevrátí hodnotu
local FileDefiner = loadFileDefiner() 
    or _genv.FileDefiner 
    or (_G and _G.FileDefiner) 
    or (shared and shared.FileDefiner)

if type(FileDefiner) ~= "table" then
    error("[Ghostware Loader] FileDefiner se nenačetl (vráceno nil). Zkontroluj kompatibilitu executoru!", 2)
end

FileDefiner.Mode = "Online"
FileDefiner.BaseUrl = BASE_URL
_genv.FileDefiner = FileDefiner
if shared then shared.FileDefiner = FileDefiner end
pcall(function() _G.FileDefiner = FileDefiner end)

-- 2. Spuštění hlavního balíčku LoadMe přímo v paměti
return FileDefiner.Load("LoadMe")