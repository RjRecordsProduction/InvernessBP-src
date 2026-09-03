local BTFunctionLibrary = import("BTFunctionLibrary")
local BTTools = {}
function BTTools.GetLuaNodeParams(Object, key)
  return Object[key]
end
function BTTools.GetBlackboardParams(Object, key, eType)
  if slua.isValid(Object) and Object.LuaBlackboardParams then
    local BBKey = Object.LuaBlackboardParams:Get(key)
    if BBKey then
      local uBlackboard = Object.ActorOwner.Blackboard
      local sKey = BBKey.SelectedKeyName
      if Game:IsValid(uBlackboard) and Game:IsValid(uBlackboard.BlackboardAsset) then
        if eType == UEnums.EBlackBoardKeyType.Object then
          return uBlackboard:GetValueAsObject(sKey)
        elseif eType == UEnums.EBlackBoardKeyType.Class then
          return uBlackboard:GetValueAsClass(sKey)
        elseif eType == UEnums.EBlackBoardKeyType.Enum then
          return uBlackboard:GetValueAsEnum(sKey)
        elseif eType == UEnums.EBlackBoardKeyType.Int then
          return uBlackboard:GetValueAsInt(sKey)
        elseif eType == UEnums.EBlackBoardKeyType.Float then
          return uBlackboard:GetValueAsFloat(sKey)
        elseif eType == UEnums.EBlackBoardKeyType.Bool then
          return uBlackboard:GetValueAsBool(sKey)
        elseif eType == UEnums.EBlackBoardKeyType.String then
          return uBlackboard:GetValueAsString(sKey)
        elseif eType == UEnums.EBlackBoardKeyType.Name then
          return uBlackboard:GetValueAsName(sKey)
        elseif eType == UEnums.EBlackBoardKeyType.Vector then
          return uBlackboard:GetValueAsVector(sKey)
        elseif eType == UEnums.EBlackBoardKeyType.Rotator then
          return uBlackboard:GetValueAsRotator(sKey)
        end
      end
    end
  end
  return nil
end
function BTTools.SetBlackboardParams(Object, key, eType, aValue)
  if slua.isValid(Object) and Object.LuaBlackboardParams then
    local BBKey = Object.LuaBlackboardParams:Get(key)
    if BBKey then
      local uBlackboard = Object.ActorOwner.Blackboard
      local sKey = BBKey.SelectedKeyName
      if Game:IsValid(uBlackboard) and Game:IsValid(uBlackboard.BlackboardAsset) then
        if eType == UEnums.EBlackBoardKeyType.Object then
          if slua.isValid(aValue) then
            uBlackboard:SetValueAsObject(sKey, aValue)
          end
        elseif eType == UEnums.EBlackBoardKeyType.Class then
          uBlackboard:SetValueAsClass(sKey, aValue)
        elseif eType == UEnums.EBlackBoardKeyType.Enum then
          uBlackboard:SetValueAsEnum(sKey, aValue)
        elseif eType == UEnums.EBlackBoardKeyType.Int then
          uBlackboard:SetValueAsInt(sKey, aValue)
        elseif eType == UEnums.EBlackBoardKeyType.Float then
          uBlackboard:SetValueAsFloat(sKey, aValue)
        elseif eType == UEnums.EBlackBoardKeyType.Bool then
          uBlackboard:SetValueAsBool(sKey, aValue)
        elseif eType == UEnums.EBlackBoardKeyType.String then
          uBlackboard:SetValueAsString(sKey, aValue)
        elseif eType == UEnums.EBlackBoardKeyType.Name then
          uBlackboard:SetValueAsName(sKey, aValue)
        elseif eType == UEnums.EBlackBoardKeyType.Vector then
          uBlackboard:SetValueAsVector(sKey, aValue)
        elseif eType == UEnums.EBlackBoardKeyType.Rotator then
          uBlackboard:SetValueAsRotator(sKey, aValue)
        end
      end
    end
  end
  return nil
end
function BTTools.ClearBlackboardValue(Object, key)
  if slua.isValid(Object) and Object.LuaBlackboardParams then
    local BBKey = Object.LuaBlackboardParams:Get(key)
    if BBKey then
      BTFunctionLibrary.ClearBlackboardValue(Object, BBKey)
    end
  end
end
return BTTools