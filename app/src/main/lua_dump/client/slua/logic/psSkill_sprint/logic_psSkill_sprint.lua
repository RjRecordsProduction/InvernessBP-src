local psSkill_sprint_config = require("client.slua.logic.psSkill_sprint.psSkill_sprint_config")
local logic_psSkill_sprint = {}
function logic_psSkill_sprint:DefineAndResetData()
end
function logic_psSkill_sprint:OnInitialize()
  local psSkill_sprint_util = require("client.slua.logic.psSkill_sprint.psSkill_sprint_util")
  local roleConfig, levelConfig = psSkill_sprint_util.InitConfig()
  self._  self._  self._saveRoleID = nil
  self:_SendGetData()
end
function logic_psSkill_sprint:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_VIEW_SELECT_CHANGE, self.OnAutoOpenPanel, self)
end
function logic_psSkill_sprint:OnLogin(bReLogin)
end
function logic_psSkill_sprint:OnLogOut()
end
function logic_psSkill_sprint:OnPreSwitchGameStatus(preState, nextState)
  if GameStatus.IsPostSwitchEnterLobbyOrMainCityFromFighting(preState, nextState) then
    self:_SendGetData()
  end
end
function logic_psSkill_sprint:OnPostSwitchGameStatus(preState, nextState)
end
function logic_psSkill_sprint:OpenMainUI()
  log(bWriteLog and "logic_psSkill_sprint:OpenMainPanel")
  UIManager.ShowUI(UIManager.UI_Config.PSKillSprint_Popup_UIBP)
end
function logic_psSkill_sprint:OnAutoOpenPanel()
  log(bWriteLog and "logic_psSkill_sprint:OnAutoOpenPanel")
  local psSkill_sprint_util = require("client.slua.logic.psSkill_sprint.psSkill_sprint_util")
  if not psSkill_sprint_util.CheckIsSelectedTargetView() then
    log(bWriteLog and "logic_psSkill_sprint:OnAutoOpenPanel. not select target view")
    return
  end
  if self:GetSaveRoleID() then
    log(bWriteLog and "logic_psSkill_sprint:OnAutoOpenPanel. already have role")
    return
  end
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  local IsSlapEnd = NewFaceSlapSystem:IsSlapEnd()
  local IsNewbie = NewFaceSlapSystem:CheckIsNewBie()
  log_format("logic_psSkill_sprint:OnAutoOpenPanel IsSlapEnd = [%s], IsNewbie = [%s]", IsSlapEnd, IsNewbie)
  if not IsNewbie and not IsSlapEnd then
    log_warning(bWriteLog and "logic_psSkill_sprint:OnAutoOpenPanel return not IsSlapEnd")
    return
  end
  psSkill_sprint_util.OpenMainUI()
end
function logic_psSkill_sprint:GetRoleConfig()
  return self._roleConfig
end
function logic_psSkill_sprint:GetLevelConfigByID(levelID)
  return self._levelConfig and self._levelConfig[levelID]
end
function logic_psSkill_sprint:GetSaveRoleID()
  log_format("logic_psSkill_sprint:GetSaveRoleID. saveRoleID = [%s]", self._saveRoleID)
  return self._saveRoleID
end
function logic_psSkill_sprint:GetCurrentRoleID()
  local saveRoleID = self:GetSaveRoleID()
  if saveRoleID then
    return saveRoleID
  end
  return psSkill_sprint_config.CDefaultRoleID
end
function logic_psSkill_sprint:GetCurrentRoleConfig()
  local roleID = self:GetCurrentRoleID()
  return self._roleConfig and self._roleConfig[roleID]
end
function logic_psSkill_sprint:SetCurrentRoleID(roleID, notReq)
  self._saveRoleID = roleID
  if not notReq then
    self:_SetBattleData()
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_ON_PSSKILL_SPRINT_ROLE_UPDATE)
end
function logic_psSkill_sprint:GMClearLocalData()
  self:SetCurrentRoleID(nil)
end
function logic_psSkill_sprint:ReportClickEnter()
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.PSkillSprint_ClickEnter, 0, "PSKillSprint_ClickEnter_" .. self._saveRoleID)
end
function logic_psSkill_sprint:_SendGetData()
  log(bWriteLog and "logic_psSkill_sprint:_SendGetData")
  local logic_battle_data_transmission = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_battle_data_transmission)
  logic_battle_data_transmission:GetOrReqTransmissionData(psSkill_sprint_config.CTransmissionKey, function(isSuccess, data)
    self:_OnGetBattleData(isSuccess, data)
  end, true)
end
function logic_psSkill_sprint:_SetBattleData()
  local saveRoleID = self:GetSaveRoleID()
  local data = {RoleID = saveRoleID}
  local logic_battle_data_transmission = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_battle_data_transmission)
  logic_battle_data_transmission:SetTransmissionData(psSkill_sprint_config.CTransmissionKey, data)
end
function logic_psSkill_sprint:_OnGetBattleData(success, data)
  log_format("logic_psSkill_sprint:_OnGetBattleData. success = [%s], data = [%s]", success, data)
  if not success then
    log_warning(bWriteLog and "logic_psSkill_sprint:_OnGetBattleData. fail")
    return
  end
  log_tree("logic_psSkill_sprint:_OnGetBattleData. data = ", data)
  local RoleID = data and data.RoleID
  self:SetCurrentRoleID(RoleID, true)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_PSKillSprint = class(CModuleBase, nil, logic_psSkill_sprint)
return Clogic_PSKillSprint