local level_unlock_util = {}
function level_unlock_util:IsFeatureIDValid(featureID)
  log(bWriteLog and "level_unlock_util:IsFeatureIDValid featureID = " .. tostring(featureID))
  if not featureID or featureID <= 0 then
    return false
  end
  return true
end
function level_unlock_util:HaveLockedFeature()
  local level = DataMgr.roleData.level
  log(bWriteLog and "level_unlock_util:HaveLockedFeature level = " .. tostring(level))
  if 20 <= level then
    return false
  end
  return level_unlock_util:IsSwitchOpen()
end
function level_unlock_util:IsSwitchOpen()
  log(bWriteLog and "level_unlock_util:IsSwitchOpen level_unlock_switch = " .. tostring(LobbySystem.roleData.level_unlock_switch))
  return LobbySystem.roleData.level_unlock_switch == 1
end
return level_unlock_util