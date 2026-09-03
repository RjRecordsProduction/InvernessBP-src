local alias_red = {}
function alias_red.HasRedpoint()
  local logic_roleInfo_honor_title_select = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_honor_title_select)
  local count = logic_roleInfo_honor_title_select:GetSaveSelectListCount()
  local isHasShow = alias_red.GetIsHasShowRedPoint()
  log(bWriteLog and "[wzp] count = " .. tostring(count) .. "  isHasShow = " .. tostring(isHasShow))
  return count == 0 and not isHasShow
end
function alias_red.GetIsHasShowRedPoint()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local localData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAliasShowRedPoint) or {}
  local isHasshow = localData.isHasShowRedPoint
  return isHasshow
end
function alias_red.SetIsHasShowRedPoint(isHasShow)
  local saveTab = {isHasShowRedPoint = isHasShow}
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(saveTab, PlayerPrefsSystem.ePlayerPrefsType.eAliasShowRedPoint)
end
return alias_red