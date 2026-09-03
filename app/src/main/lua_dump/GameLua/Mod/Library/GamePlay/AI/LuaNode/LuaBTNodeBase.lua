local BTTools = require("GameLua.Mod.Library.GamePlay.AI.LuaNode.BTTools")
local LuaBTNodeBase = {}
function LuaBTNodeBase:ctor()
end
function LuaBTNodeBase:GetLuaNodeParams(key)
  return BTTools.GetLuaNodeParams(self.Object, key)
end
function LuaBTNodeBase:GetBlackboardParams(Key, eType)
  if eType == UEnums.EBlackBoardKeyType.Object then
    return self:GetValueAsObject(Key)
  elseif eType == UEnums.EBlackBoardKeyType.Class then
    return self:GetValueAsClass(Key)
  elseif eType == UEnums.EBlackBoardKeyType.Enum then
    return self:GetValueAsEnum(Key)
  elseif eType == UEnums.EBlackBoardKeyType.Int then
    return self:GetValueAsInt(Key)
  elseif eType == UEnums.EBlackBoardKeyType.Float then
    return self:GetValueAsFloat(Key)
  elseif eType == UEnums.EBlackBoardKeyType.Bool then
    return self:GetValueAsBool(Key)
  elseif eType == UEnums.EBlackBoardKeyType.String then
    return self:GetValueAsString(Key)
  elseif eType == UEnums.EBlackBoardKeyType.Name then
    return self:GetValueAsName(Key)
  elseif eType == UEnums.EBlackBoardKeyType.Vector then
    return self:GetValueAsVector(Key)
  elseif eType == UEnums.EBlackBoardKeyType.Rotator then
    return self:GetValueAsRotator(Key)
  end
  return nil
end
function LuaBTNodeBase:SetBlackboardParams(Key, eType, aValue)
  if eType == UEnums.EBlackBoardKeyType.Object then
    self:SetValueAsObject(Key, aValue)
  elseif eType == UEnums.EBlackBoardKeyType.Class then
    self:SetValueAsClass(Key, aValue)
  elseif eType == UEnums.EBlackBoardKeyType.Enum then
    self:SetValueAsEnum(Key, aValue)
  elseif eType == UEnums.EBlackBoardKeyType.Int then
    self:SetValueAsInt(Key, aValue)
  elseif eType == UEnums.EBlackBoardKeyType.Float then
    self:SetValueAsFloat(Key, aValue)
  elseif eType == UEnums.EBlackBoardKeyType.Bool then
    self:SetValueAsBool(Key, aValue)
  elseif eType == UEnums.EBlackBoardKeyType.String then
    self:SetValueAsString(Key, aValue)
  elseif eType == UEnums.EBlackBoardKeyType.Name then
    self:SetValueAsName(Key, aValue)
  elseif eType == UEnums.EBlackBoardKeyType.Vector then
    self:SetValueAsVector(Key, aValue)
  elseif eType == UEnums.EBlackBoardKeyType.Rotator then
    self:SetValueAsRotator(Key, aValue)
  end
  return false
end
function LuaBTNodeBase:ClearBlackboardValue(key)
  return BTTools.ClearBlackboardValue(self.Object, key)
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CLuaBTNodeBase = class(CDelegateContainer, nil, LuaBTNodeBase)
return CLuaBTNodeBase