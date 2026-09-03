local logic_unknowpass_full_level_slap = {}
local slapCDTime = 432000
function logic_unknowpass_full_level_slap:DefineAndResetData()
  self.nLastUcNum = nil
  self.bIsSpendUc = false
  self.bIsBattleEnd = false
end
function logic_unknowpass_full_level_slap:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SHOW_LOBBY, self.ShowFullLevelSlap, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, self.OnUpdateUCInfo, self)
end
function logic_unknowpass_full_level_slap:OnPostSwitchGameStatus(preState, nextState)
  if GameStatus.IsPostSwitchEnterLobbyOrMainCityFromFighting(preState, nextState) then
    self.bIsBattleEnd = true
    self:ShowFullLevelSlap()
  end
end
function logic_unknowpass_full_level_slap:CheckIsShowSlap()
  if UnknowPassSystem.IsBuyElite then
    return false
  end
  if UnknowPassSystem.Level < 100 then
    return false
  end
  if not self.bIsSpendUc and not self.bIsBattleEnd then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local TimeUtil = require("client.common.time_util")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassFullLevelSlap) or {}
  if not saveData.nTimeRecord then
    return true
  end
  local lastTime = saveData.nTimeRecord
  local bIsOutCDTime = TimeUtil.GetServerTimeInSec() - lastTime >= slapCDTime
  return bIsOutCDTime
end
function logic_unknowpass_full_level_slap:ShowFullLevelSlap()
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  if PassDataSystem.GetRpResourceDownloadState() ~= PufferConst.ENUM_DownloadState.Done then
    return
  end
  local bIsShow = self:CheckIsShowSlap()
  if bIsShow then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local TimeUtil = require("client.common.time_util")
    local saveData = {
      nTimeRecord = TimeUtil.GetServerTimeInSec()
    }
    PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassFullLevelSlap)
    UIManager.ShowUI(UIManager.UI_Config.UnknowPass_Popup_Theme_PushBuy_UIBP, true)
    self.bIsSpendUc = false
    self.bIsBattleEnd = false
  end
end
function logic_unknowpass_full_level_slap:OnUpdateUCInfo()
  local ticket = tonumber(DataMgr.ticket)
  if not self.nLastUcNum then
    self.nLastUcNum = ticket
    return
  end
  if ticket >= self.nLastUcNum then
    self.nLastUcNum = ticket
  else
    self.bIsSpendUc = true
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CUnknowpassFullLevelSlap = class(CModuleBase, nil, logic_unknowpass_full_level_slap)
return CUnknowpassFullLevelSlap