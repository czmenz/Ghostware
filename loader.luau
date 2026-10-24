-- loader.luau
-- Ghostware Universal Cloud Loader
-- 100% In-Memory Execution via HttpGet & loadstring. ZERO files saved to local client disk!

local BASE_URL = "https://raw.githubusercontent.com/czmenz/Ghostware/main/"

local function fetchSource(relPath)
    local url = BASE_URL .. relPath
    local ok, src = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and type(src) == "string" and #src > 0 then
        return src
    end
    error(string.format("[Ghostware Loader] Failed to fetch '%s' from: %s", relPath, url), 2)
end

local _genv = (rawget(getfenv(0), "getgenv") and getgenv()) or _G or {}
_genv.GW_BuildMode = "Release"
if shared then shared.GW_BuildMode = "Release" end

-- 1. Načtení FileDefineru přímo do paměti (žádné ukládání na disk)
local fileDefinerSrc = fetchSource("FileDefiner.luau")
local loadFileDefiner, compileErr = loadstring(fileDefinerSrc, "@FileDefiner.luau")
if not loadFileDefiner then
    error(string.format("[Ghostware Loader] Failed to compile FileDefiner: %s", tostring(compileErr)), 2)
end

local FileDefiner = loadFileDefiner()
FileDefiner.Mode = "Online"
FileDefiner.BaseUrl = BASE_URL

-- 2. Spuštění hlavního balíčku LoadMe přímo v paměti
return FileDefiner.Load("LoadMe")
