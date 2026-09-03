local CacheCPPAPI = {}
local CachedState = {}
function CacheCPPAPI.Init()
  local CacheCPPAPIConfig = require("client.slua.config.CacheCPPAPI.CacheCPPAPIConfig")
  for CppLibraryName, CacheContent in pairs(CacheCPPAPIConfig) do
    CachedState[CacheContent.LuaTableName] = {}
    local CppLibrary = import(CppLibraryName)
    for _, StateFunctionName in ipairs(CacheContent.CacheFunctions) do
      _G[CacheContent.LuaTableName][StateFunctionName] = function()
        if CachedState[CacheContent.LuaTableName][StateFunctionName] == nil then
          CachedState[CacheContent.LuaTableName][StateFunctionName] = CppLibrary[StateFunctionName]()
        end
        return CachedState[CacheContent.LuaTableName][StateFunctionName]
      end
    end
  end
end
return CacheCPPAPI