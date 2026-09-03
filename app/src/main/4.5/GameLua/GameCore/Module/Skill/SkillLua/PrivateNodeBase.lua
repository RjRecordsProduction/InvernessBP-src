local TableUtil = require("common.table_util")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local PrivateNodeBase = {
  __PrivateFuncList = {},
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
  local PrivateFuncList = self.__PrivateFuncList
  local private_index = function(t, k, cache)
    local ret
    if PrivateFuncList[k] then
      ret = rawget(t, k)
    end
    if not ret then
      local UniqueKey = rawget(t, "__ScopeUniqueKey")
      if UniqueKey then
        local PlayerPrivateData = rawget(t, UniqueKey)
        if PlayerPrivateData and PlayerPrivateData[k] ~= nil then
          ret = PlayerPrivateData[k]
        else
          ret = self_index(t, k, cache)
        end
      else
        ret = self_index(t, k, cache)
      end
    end
    return ret
  end
  local private__newindex = function(t, k, v)
    t:SetPrivateData(k, v)
  end
  for FuncName, _ in pairs(PrivateFuncList) do
    local OldFunc = self[FuncName]
    if OldFunc then
      rawset(self, FuncName, self:WrapFuncAndReplaceData(OldFunc))
    end
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
  self.ObjectName = UKismetSystemLibrary.GetObjectName(self.Object)
  self_mt.__index = private_index
  self_mt.__newindex = private__newindex
  setmetatable(self, self_mt)
end
function PrivateNodeBase:WrapFuncAndCallback(Func)
  local NewFunc = function(...)
    local Args = table.pack(...)
    for i = 1, #Args do
      local Arg = Args[i]
      if type(Arg) == "function" then
        Args[i] = self:WrapCallback(Arg)
      end
    end
    return Func(table.unpack(Args))
  end
  return NewFunc
end
function PrivateNodeBase:WrapCallback(Func)
  local ScopeUniqueKey = rawget(self, "__ScopeUniqueKey")
  local NewFunc = function(...)
    local OldUniqueKey = rawget(self, "__ScopeUniqueKey")
    rawset(self, "__ScopeUniqueKey", ScopeUniqueKey)
    local ret = Func(...)
    rawset(self, "__ScopeUniqueKey", OldUniqueKey)
    return ret
  end
  return NewFunc
end
function PrivateNodeBase:WrapFuncAndReplaceData(Func)
  local NewFunc = function(...)
    local OldUniqueKey = rawget(self, "__ScopeUniqueKey")
    rawset(self, "__ScopeUniqueKey", self:GetPrivateUniqueKey())
    local bCurAlreadyReplacePrivateData = self:GetPrivateData("__bAlreadyReplacePrivateData")
    if not bCurAlreadyReplacePrivateData then
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
      self:SetPrivateData("__bAlreadyReplacePrivateData", true)
    end
    local ret = Func(...)
    rawset(self, "__ScopeUniqueKey", OldUniqueKey)
    return ret
  end
  return NewFunc
end
function PrivateNodeBase:GetPrivateUniqueKey()
  sandbox.LogError("PrivateNodeBase:GetPrivateUniqueKey Need Override")
end
function PrivateNodeBase:ReplaceWithPrivateData(Key, Value)
  local UniqueKey = rawget(self, "__ScopeUniqueKey")
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
  local UniqueKey = rawget(self, "__ScopeUniqueKey")
  if not UniqueKey then
    sandbox.LogError("PrivateNodeBase:ReplaceWithPrivateData No UniqueKey")
    return
  end
  rawset(self, UniqueKey, nil)
end
function PrivateNodeBase:SetPrivateData(Key, Value)
  local UniqueKey = rawget(self, "__ScopeUniqueKey")
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
  local UniqueKey = rawget(self, "__ScopeUniqueKey")
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
function PrivateNodeBase:AddControlEventWithCondition(control, eventName, condTable, handleFunc, ...)
  handleFunc = self:WrapCallback(handleFunc)
  return PrivateNodeBase.__super.AddControlEventWithCondition(self, control, eventName, condTable, handleFunc, ...)
end
function PrivateNodeBase:BindLuaObjEvent(control, eventName, handleFunc, ...)
  handleFunc = self:WrapCallback(handleFunc)
  return PrivateNodeBase.__super.BindLuaObjEvent(self, control, eventName, handleFunc, ...)
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