local PreloadAssetManager = {}
function PreloadAssetManager:DefineAndResetData()
  log(bWriteLog and "PreloadAssetManager:DefineAndResetData")
  self.PreloadAssetHookArray = {}
  self.AsyncHandleIDAMap = {}
end
function PreloadAssetManager:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "PreloadAssetManager:OnPostSwitchGameStatus pre = " .. tostring(preState) .. " nextState = " .. tostring(nextState))
  for i = 1, #self.PreloadAssetHookArray do
    log(bWriteLog and string.format("PreloadAssetManager:OnPostSwitchGameStatus. UISyncPreloadHookTable Asset=%s", tostring(self.PreloadAssetHookArray[i])))
  end
  self.PreloadAssetHookArray = {}
end
function PreloadAssetManager:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and "PreloadAssetManager:OnPostSwitchGameStatus pre = " .. tostring(preState) .. " nextState = " .. tostring(nextState))
  self:_CancelAsyncLoad()
end
function PreloadAssetManager:UISyncPreload(AssetPath)
  local asset_util = require("common.asset_util")
  log(bWriteLog and string.format("PreloadAssetManager:UISyncPreload. AssetPath=%s", tostring(AssetPath)))
  local Asset = asset_util.GetAssetSync(AssetPath)
  table.insert(self.PreloadAssetHookArray, Asset)
end
function PreloadAssetManager:UIAsyncPreload(AssetPath)
  local asset_util = require("common.asset_util")
  local HandleID = asset_util.GetAssetAsyncOneParam(AssetPath, self._OnASyncPreload, self)
  log(bWriteLog and string.format("PreloadAssetManager:UIAsyncPreload. AssetPath=%s", tostring(AssetPath)))
  if HandleID ~= asset_util.loadFromCacheHandleID then
    self.AsyncHandleIDAMap[HandleID] = true
  end
end
function PreloadAssetManager:_OnASyncPreload(Asset)
  table.insert(self.PreloadAssetHookArray, Asset)
end
function PreloadAssetManager:UIAsyncPreloadArray(AssetPathArray)
  log(bWriteLog and "PreloadAssetManager:UIAsyncPreloadArray. ")
  local asset_util = require("common.asset_util")
  local function GetAssetAsync(i)
    local HandleID = asset_util.loadFromCacheHandleID
    HandleID = asset_util.GetAssetAsyncOneParam(AssetPathArray[i], function(Asset)
      self.AsyncHandleIDAMap[HandleID] = nil
      self:_OnASyncPreload(Asset)
      if i >= #AssetPathArray then
        return
      else
        GetAssetAsync(i + 1)
      end
    end)
    if HandleID ~= asset_util.loadFromCacheHandleID then
      self.AsyncHandleIDAMap[HandleID] = true
    end
  end
  GetAssetAsync(1)
end
function PreloadAssetManager:_CancelAsyncLoad()
  local asset_util = require("common.asset_util")
  for HandleID, _ in pairs(self.AsyncHandleIDAMap) do
    log(bWriteLog and string.format("PreloadAssetManager:_CancelAsyncLoad. HandleID:%d", HandleID))
    asset_util.CancelAssetAsync(HandleID)
  end
  self.AsyncHandleIDAMap = {}
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CUIPreload = class(CModuleBase, nil, PreloadAssetManager)
return CUIPreload