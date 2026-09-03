local logic_mode_selection_for_umg = {}
local isInvitedToTMode = false
function logic_mode_selection_for_umg.SetIsInvitedInToMetroTxMission(isInvited)
  isInvitedToTMode = isInvited
  log(bWriteLog and "logic_mode_selection_for_umg isInvitedToTMode = " .. tostring(isInvitedToTMode))
end
function logic_mode_selection_for_umg.CheckTXMissionIsOpen()
  local TxMissionSeasonTime = CDataTable.GetTable("TxMissionSeasonTime")
  local TimeUtil = require("client.common.time_util")
  local CurTime = TimeUtil.GetServerTimeInSec()
  for _, seasonCfg in ipairs(TxMissionSeasonTime) do
    local EndTime = seasonCfg.EndTime
    local et = TimeUtil.TimeStringToUnixstamp(EndTime)
    log(bWriteLog and "logic_mode_selection_for_umg:CheckTXMissionIsOpen et = " .. tostring(et) .. " CurTime = " .. tostring(CurTime))
    if CurTime < et then
      local StartTime = seasonCfg.StartTime
      local st = TimeUtil.TimeStringToUnixstamp(StartTime)
      if CurTime > st then
        log(bWriteLog and "logic_mode_selection_for_umg:CheckTXMissionIsOpen true")
        return true
      end
    end
  end
  log(bWriteLog and "logic_mode_selection_for_umg:CheckTXMissionIsOpen false")
  return false
end
function logic_mode_selection_for_umg.SetNotMTXMissionIfHasClosed()
  local isOpen = logic_mode_selection_for_umg.CheckTXMissionIsOpen()
  if not isOpen then
    log(bWriteLog and "logic_mode_selection_for_umg:SetNotMTXMissionIfHasClosed")
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    logic_mode_selection:HasSelectMetroTxMission(0)
    EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_SELECT_CHANGE)
  end
end
function logic_mode_selection_for_umg.SetEnterMetroTxMissionDesc(UITable)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  log(bWriteLog and "logic_mode_selection_for_umg:SetEnterMetroTxMissionDesc" .. tostring(logic_mode_selection.hasSelectTxMission))
  local uiRoot = UITable.UIRoot
  if logic_mode_selection.hasSelectTxMission then
    local metroText = LocUtil.LocalizeResFormat(3002001)
    uiRoot.TextBlock_14:SetText(metroText)
    uiRoot.TextBlock_Readying:SetText(metroText)
    uiRoot.Text_State:SetText(metroText)
  else
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local isLeader = TeamUpNewSystem.IsTeamLeader(DataMgr.roleData.uid)
  if logic_mode_selection.hasSelectTxMission then
    if isLeader then
      UITable.UIRoot.Button_Entry:SetIsEnabled(true)
    else
      UITable.UIRoot.Button_Entry:SetIsEnabled(false)
    end
  else
    UITable.UIRoot.Button_Entry:SetIsEnabled(true)
  end
  return logic_mode_selection.hasSelectTxMission
end
function logic_mode_selection_for_umg.CheckIsMetroTxMissionMode(UITable)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local needShow = not logic_mode_selection.hasSelectTxMission
  log(bWriteLog and "logic_mode_selection_for_umg:CheckIsMetroTxMissionMode needShow = " .. tostring(needShow))
  if UITable.UIRoot.HorizontalBox_MapInfo then
    UITable:SetWidgetVisible(UITable.UIRoot.HorizontalBox_MapInfo, needShow, false)
  end
  return not needShow
end
function logic_mode_selection_for_umg.GotoTxMissionLobby()
  log(bWriteLog and "MainCity_Lobby_Main_Match_Entry_UIBP:GotoTxMissionLobby")
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local firstViewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(20000)
  if firstViewInfo and firstViewInfo.url and firstViewInfo.url ~= "" then
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    ActivityNewSystem.JumpUrl(firstViewInfo.url)
  end
end
function logic_mode_selection_for_umg.SaveTxMissionChoiceInLocal(hasSelectTxMission)
  log(bWriteLog and "logic_mode_selection_for_umg:SaveMTChoiceInLocal")
  local TxMissionRecord = logic_mode_selection_for_umg.GetSaveData()
  TxMissionRecord.  logic_mode_selection_for_umg.SaveData(TxMissionRecord)
end
function logic_mode_selection_for_umg.GetTxMissionChoiceInLocal()
  log(bWriteLog and "logic_mode_selection_for_umg:GetTxMissionChoiceInLocal")
  local TxMissionRecord = logic_mode_selection_for_umg.GetSaveData()
  log(bWriteLog and "logic_mode_selection_for_umg:GetTxMissionChoiceInLocal MTRecord = " .. tostring(TxMissionRecord.hasSelectTxMission))
  local isOpen = logic_mode_selection_for_umg.CheckTXMissionIsOpen()
  if isOpen then
    return TxMissionRecord.hasSelectTxMission
  end
  return false
end
function logic_mode_selection_for_umg.UpdateTxMissionChoiceBeforeJoinTeam(viewID)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local isLeader = TeamUpNewSystem.IsTeamLeader(DataMgr.roleData.uid)
  if isLeader then
    log(bWriteLog and "logic_mode_selection_for_umg.UpdateTxMissionChoiceBeforeJoinTeam isLeader")
    return
  end
  local TxMissionRecord = logic_mode_selection_for_umg.GetSaveData()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  log(bWriteLog and "logic_mode_selection_for_umg:SaveTxMissionChoiceBeforeJoinTeam hasJoinTeam = " .. tostring(TxMissionRecord.hasJoinTeam))
  if not TxMissionRecord.hasJoinTeam then
    TxMissionRecord.SelectedTxMissionBeforeJoinTeam = logic_mode_selection.hasSelectTxMission
    log(bWriteLog and "logic_mode_selection_for_umg:SaveTxMissionChoiceBeforeJoinTeam SelectedTxMissionBeforeJoinTeam = " .. tostring(TxMissionRecord.SelectedTxMissionBeforeJoinTeam))
    if isInvitedToTMode then
      logic_mode_selection:HasSelectMetroTxMission(20000)
    else
      logic_mode_selection:HasSelectMetroTxMission(viewID)
    end
    TxMissionRecord.hasJoinTeam = true
    logic_mode_selection_for_umg.SaveData(TxMissionRecord)
  end
end
function logic_mode_selection_for_umg.UpdateTxMissionChoiceAfterQuitTeam(viewID)
  local TxMissionRecord = logic_mode_selection_for_umg.GetSaveData()
  log(bWriteLog and "logic_mode_selection_for_umg:SaveTxMissionChoiceBeforeJoinTeam" .. tostring(TxMissionRecord.hasJoinTeam))
  if TxMissionRecord.hasJoinTeam then
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    if TxMissionRecord.SelectedTxMissionBeforeJoinTeam then
      log(bWriteLog and "logic_mode_selection_for_umg:SaveTxMissionChoiceBeforeJoinTeam SelectedTxMissionBeforeJoinTeam")
      logic_mode_selection:HasSelectMetroTxMission(20000)
    else
      logic_mode_selection:HasSelectMetroTxMission(viewID)
    end
    TxMissionRecord.hasJoinTeam = false
    logic_mode_selection_for_umg.SaveData(TxMissionRecord)
    logic_mode_selection_for_umg.SetIsInvitedInToMetroTxMission(false)
  end
end
function logic_mode_selection_for_umg.SaveData(TxMissionRecord)
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  playerPrefsSystem.SaveTableToFile_N(TxMissionRecord, playerPrefsSystem.ePlayerPrefsType.eModeSelectionMetroMission)
end
function logic_mode_selection_for_umg.GetSaveData()
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local TxMissionRecord = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eModeSelectionMetroMission)
  TxMissionRecord = TxMissionRecord or {}
  return TxMissionRecord
end
function logic_mode_selection_for_umg.GetTxMissionChoiceBeforeJoinTeam()
  log(bWriteLog and "logic_mode_selection_for_umg:GetTxMissionChoiceInLocal")
  local TxMissionRecord = logic_mode_selection_for_umg.GetSaveData()
  log(bWriteLog and "logic_mode_selection_for_umg:GetTxMissionChoiceInLocal MTRecord = " .. tostring(TxMissionRecord.SelectedTxMissionBeforeJoinTeam))
  return TxMissionRecord.SelectedTxMissionBeforeJoinTeam
end
return logic_mode_selection_for_umg