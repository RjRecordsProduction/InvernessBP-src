local TableUtil = require("common.table_util")
local PrivateNodeBase = {
  __NeedReplaceData = {
    _controlEvents = {},
    _commonEvents = {},
    _conditionEvents = {},
    _times = {},
    _gameTimers = {},
    _asyncLoadHandles = {}
  }
}
function PrivateNodeBase:PostHook()
  local self_mt = getmetatable(self)
  local self_index = self_mt.__index
  local private_index = function(t, k, cache)
    local ret
    local PlayerPrivateData = rawget(t, t:GetPrivateUniqueKey())
    if PlayerPrivateData and PlayerPrivateData[k] ~= nil then
      ret = PlayerPrivateData[k]
    else
      ret = self_index(t, k, cache)
    end
    return ret
  end
  local private__newindex = function(t, k, v)
    t:SetPrivateData(k, v)
  end
  local self_newindex = self_mt.__newindex
  rawset(self, "GetPrivateUniqueKey", self.GetPrivateUniqueKey)
  rawset(self, "SetPrivateUniqueKey", self.SetPrivateUniqueKey)
  rawset(self, "GetPrivateData", self.GetPrivateData)
  rawset(self, "SetPrivateData", self.SetPrivateData)
  rawset(self, "GetStaticData", function(t, k, cache)
    return self_index(t, k, cache)
  end)
  rawset(self, "SetStaticData", function(t, k, v)
    self_newindex(t, k, v)
  end)
  self_mt.__index = private_index
  self_mt.__newindex = private__newindex
  setmetatable(self, self_mt)
end
function PrivateNodeBase:PrivateNodeInit()
  for ReplaceKey, ReplaceValue in pairs(PrivateNodeBase.__NeedReplaceData) do
    self:ReplaceWithPrivateData(ReplaceKey, ReplaceValue)
  end
  local ctor_list = {}
  local impl = self
  while impl and impl ~= PrivateNodeBase do
    if impl.ctor then
      table.insert(ctor_list, 1, impl.ctor)
    end
    impl = impl.__super_impl
  end
  for _, ctor in ipairs(ctor_list) do
    ctor(self)
  end
end
function PrivateNodeBase:WrapCallback(Func)
  local ScopeUniqueKey = self:GetPrivateUniqueKey()
  local NewFunc = function(...)
    local OldUniqueKey = self:GetPrivateUniqueKey()
    self:SetPrivateUniqueKey(ScopeUniqueKey)
    local ret = Func(...)
    self:SetPrivateUniqueKey(OldUniqueKey)
    return ret
  end
  return NewFunc
end
function PrivateNodeBase:ReplaceWithPrivateData(Key, Value)
  local UniqueKey = self:GetPrivateUniqueKey()
  if not UniqueKey then
    sandbox.LogError("PrivateNodeBase:ReplaceWithPrivateData No UniqueKey")
    return
  end
  if rawget(self, Key) ~= nil then
    rawset(self, Key, nil)
  end
  local PlayerPrivateData = rawget(self, UniqueKey)
  if PlayerPrivateData == nil then
    rawset(self, UniqueKey, {})
  end
  PlayerPrivateData = self[UniqueKey]
  if PlayerPrivateData[Key] == nil then
    PlayerPrivateData[Key] = type(Value) == "table" and TableUtil.CopyTable(Value) or Value
  end
end
function PrivateNodeBase:ClearPrivateData()
  local UniqueKey = self:GetPrivateUniqueKey()
  if not UniqueKey then
    sandbox.LogError("PrivateNodeBase:ReplaceWithPrivateData No UniqueKey")
    return
  end
  rawset(self, UniqueKey, nil)
end
function PrivateNodeBase:SetPrivateData(Key, Value)
  local UniqueKey = self:GetPrivateUniqueKey()
  if not UniqueKey then
    sandbox.LogError("PrivateNodeBase:SetPrivateData No UniqueKey")
    return
  end
  local PlayerPrivateData = rawget(self, UniqueKey)
  if PlayerPrivateData == nil then
    rawset(self, UniqueKey, {})
  end
  self[UniqueKey][Key] = Value
end
function PrivateNodeBase:GetPrivateData(DataKey)
  local UniqueKey = self:GetPrivateUniqueKey()
  if not UniqueKey then
    sandbox.LogError("PrivateNodeBase:GetPrivateData No UniqueKey")
    return
  end
  local PlayerPrivateData = rawget(self, UniqueKey)
  return PlayerPrivateData and PlayerPrivateData[DataKey] or nil
end
function PrivateNodeBase:GetAssetAsync(AssetPath, CallBackFunc)
  local Util = require("client.slua_ui_framework.util")
  return Util.GetAssetAsync(AssetPath, self:WrapCallback(CallBackFunc))
end
function PrivateNodeBase:ClearAssetAsync(Handle)
  local Util = require("client.slua_ui_framework.util")
  Util.ClearAssetAsync(Handle)
end
function PrivateNodeBase:AddControlEvent(control, eventName, handleFunc, ...)
  handleFunc = self:WrapCallback(handleFunc)
  return PrivateNodeBase.__super.AddControlEvent(self, control, eventName, handleFunc, ...)
end
function PrivateNodeBase:AddCommonEvent(eventType, eventID, handleFunc, ...)
  handleFunc = self:WrapCallback(handleFunc)
  return PrivateNodeBase.__super.AddCommonEvent(self, eventType, eventID, handleFunc, ...)
end
function PrivateNodeBase:AddCommonEventWithConditions(eventType, eventID, conditions, handleFunc, ...)
  handleFunc = self:WrapCallback(handleFunc)
  return PrivateNodeBase.__super.AddCommonEventWithConditions(self, eventType, eventID, conditions, handleFunc, ...)
end
function PrivateNodeBase:AddTimer(delay, func)
  func = self:WrapCallback(func)
  return PrivateNodeBase.__super.AddTimer(self, delay, func)
end
function PrivateNodeBase:AddTimerLoop(delay, func, count, timeInterval)
  func = self:WrapCallback(func)
  return PrivateNodeBase.__super.AddTimerLoop(self, delay, func, count, timeInterval)
end
function PrivateNodeBase:AddTimerOnce(delay, func)
  func = self:WrapCallback(func)
  return PrivateNodeBase.__super.AddTimerOnce(self, delay, func)
end
function PrivateNodeBase:AddGameTimer(nTime, bLoop, fCallback)
  fCallback = self:WrapCallback(fCallback)
  return PrivateNodeBase.__super.AddGameTimer(self, nTime, bLoop, fCallback)
end
function PrivateNodeBase:AsyncLoadAsset(assetPath, handleFunc, ...)
  handleFunc = self:WrapCallback(handleFunc)
  return PrivateNodeBase.__super.AsyncLoadAsset(self, assetPath, handleFunc, ...)
end
local class = require("GameLua.GameCore.Module.Skill.SkillLua.noctor_class")
local CDelegateContainer = require("common.delegate_container")
local CPrivateNodeBase = class(CDelegateContainer, nil, PrivateNodeBase)
return CPrivateNodeBase