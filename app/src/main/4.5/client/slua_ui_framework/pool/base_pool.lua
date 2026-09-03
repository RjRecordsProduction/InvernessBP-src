local base_pool = {}
local local local local local local local Client_GetMemorySize = Client.GetMemorySize
local slua_loadUI = slua.loadUI
local slua_loadUISingleton = slua.loadUISingleton
local slua_AsyncLoadUI = slua.AsyncLoadUI
local slua_CancelLoadUI = slua.CancelLoadUI
local slua_isValid = slua.isValid
local utility = require("common.utility")
local xpcallHandle = utility.ErrorMessageHandler
local IntDefalut = -1
function base_pool._LoadUI(path, bSingleton)
  local loadFunc = bSingleton and slua_loadUISingleton or slua_loadUI
  local _, ui = xpcall(loadFunc, function(msg)
    if msg == nil or msg == "" then
      msg = path
    end
    xpcallHandle(msg)
  end, path)
  return ui
end
function base_pool._LoadUIAsy(path, Callback, bSingleton)
  bSingleton = bSingleton or false
  return slua_AsyncLoadUI(path, function(HandleID, obj)
    if Callback then
      Callback(HandleID, obj)
    end
  end, bSingleton)
end
function base_pool._OnRelease(obj)
  obj:RemoveFromParent()
end
function base_pool._DestroyUI(obj)
  obj = nil
end
function base_pool:ctor()
  self.Const = {
    MIN_3GorAbove = 1,
    MIN_2G = 2,
    MIN_1GorBelow = 3,
    MAX_Fighting_1GorBelow = 4,
    MAX_Fighting = 5,
    MAX_Lobby_2G = 6,
    MAX_Lobby_1GorBelow = 7,
    MAX_Lobby_3G = 8,
    MAX_Lobby_4G = 9,
    MAX_Lobby_5GorAbove = 10,
    GMRecordTraceback = 1000
  }
end
function base_pool:DefineAndResetData()
  self.LocalList = nil
  self.poolName = nil
end
function base_pool:OnInitialize()
  local CObjectPool = require("client.slua_ui_framework.pool.object_pool")
  self.pool = CObjectPool(self._LoadUI, self._DestroyUI, self._OnRelease, {
    poolName = self.poolName,
    constructASyFunc = self._LoadUIAsy,
    cancelFunc = slua_CancelLoadUI
  })
  self:_GetRemoteConfigAndApply()
end
function base_pool:OnPostSwitchGameStatus(preState, nextState)
  self:_SetPoolLimit()
end
function base_pool:_SetPoolLimit()
  local min = 0
  local max = 0
  local auto_test = require("client.common.auto_test")
  if auto_test.disable_ui_pool then
    log(bWriteLog and "base_pool: auto test disable ui pool")
    self.pool:SetPoolLimit(0, 0)
    return
  end
  local memorySize = Client_GetMemorySize()
  local so_version = Client.GetAndroidSOVersion()
  local LimitUIPoolNum32 = so_version and so_version == 32 and HDmpveRemote.HDmpveRemoteConfigGetBool("LimitUIPoolNum32", false)
  if LimitUIPoolNum32 or memorySize >= HDmpveRemote.HDmpveRemoteConfigGetInt("LimitUIPoolNum2", 100) then
    memorySize = 1
  end
  if 4 < memorySize then
    min = self:_GetLimit(self.Const.MIN_3GorAbove)
    max = self:_GetLimit(self.Const.MAX_Lobby_5GorAbove)
  elseif 3 < memorySize then
    min = self:_GetLimit(self.Const.MIN_3GorAbove)
    max = self:_GetLimit(self.Const.MAX_Lobby_4G)
  elseif 2 < memorySize then
    min = self:_GetLimit(self.Const.MIN_3GorAbove)
    max = self:_GetLimit(self.Const.MAX_Lobby_3G)
  elseif 1 < memorySize then
    min = self:_GetLimit(self.Const.MIN_2G)
    max = self:_GetLimit(self.Const.MAX_Lobby_2G)
  else
    min = self:_GetLimit(self.Const.MIN_1GorBelow)
    max = self:_GetLimit(self.Const.MAX_Lobby_1GorBelow)
  end
  if GameStatus.IsInFightingNotMainCity() then
    local archBit = Client.GetAndroidSOVersion() or 64
    local lowMemory = memorySize < 2 or memorySize <= 3 and archBit == 32
    if lowMemory then
      max = self:_GetLimit(self.Const.MAX_Fighting_1GorBelow)
    else
      max = self:_GetLimit(self.Const.MAX_Fighting)
    end
  end
  self.pool:SetPoolLimit(min, max)
end
function base_pool:_GetLimit(index)
  return self.LocalList[index]
end
function base_pool:SetGM_RecordTraceback()
  self.pool:SetGMRecordTraceback(true)
end
function base_pool:_GetRemoteConfigAndApply()
  self:_SetPoolLimit()
end
function base_pool:Get(path, callback, bSingleton)
  return self.pool:Get(path, callback, bSingleton)
end
function base_pool:GetAsy(path, callBack, bSingleton)
  return self.pool:GetAsy(path, callBack, bSingleton)
end
function base_pool:Release(obj)
  self.pool:Release(obj)
end
function base_pool:Cancel(HandleID)
  return self.pool:Cancel(HandleID)
end
function base_pool:Clear()
  self.pool:Clear()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CBase_pool = class(CModuleBase, nil, base_pool)
return CBase_pool