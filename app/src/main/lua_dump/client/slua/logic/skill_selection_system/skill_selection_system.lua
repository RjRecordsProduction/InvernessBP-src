local skill_selection_system = {}
local SkillModViewIDs = {
  [1112113] = true,
  [1112114] = true,
  [1112115] = true,
  [2113] = true,
  [2114] = true,
  [2115] = true
}
local SkillModSubModeIDs = {
  [60112] = true,
  [60113] = true,
  [60114] = true,
  [60115] = true,
  [60116] = true,
  [60117] = true,
  [90010] = true,
  [90011] = true,
  [90012] = true,
  [90013] = true,
  [90014] = true,
  [90015] = true,
  [90016] = true,
  [90017] = true,
  [90018] = true,
  [90019] = true,
  [90020] = true,
  [90021] = true
}
local FittestSkillsForMaps = {}
local IsInGame = function()
  return GameStatus.IsInFightingStatus()
end
function skill_selection_system:OnInitialize()
  log(bWriteLog and "skill_selection_system:OnInitialize")
  skill_selection_system.__super.OnInitialize(self)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  self.SkillsData = nil
  local skill_task_system = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.skill_task_system)
  skill_task_system:GetActivityData()
  skill_task_system:SendGetTaskDataReq()
end
function skill_selection_system:RegistEvents()
  log(bWriteLog and "skill_selection_system:RegistEvents")
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_NEW_TEAM_MATCH_MODE, self.OnSelectionModeChange, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_SELECT_CHANGE, self.InitLobbyEntrance, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_ON_PRE_MATCH_SUCCESS, self.OnPreMatchSuccess, self)
  self:AddCommonEvent(EVENTTYPE_SKILL_SELECTION, EVENTID_SKILL_SELECTION_ON_MODE_ANIM_SHOW, self.ShowRandomSelectNotice, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_STATUS_MATCHING_OR_NOT, self.OnStartMatch, self)
end
function skill_selection_system:OnPreMatchSuccess(_, __, SubMode)
  log(bWriteLog and "skill_selection_system:OnPreMatchSuccess: Cur Sub Mode" .. tostring(SubMode))
  if not SkillModSubModeIDs[SubMode] then
    log(bWriteLog and "skill_selection_system:OnPreMatchSuccess: Not Skill Mode")
    return
  end
  if self:ShouldShowSkillSelection() and self.CurEquipedSkillID == nil and self.ReceivedSkillData then
    local RandomSkillID = self:RandomSelectSkill()
    self.ShouldShowNotice = true
    self.NoticeContent = LocUtil.LocalizeResFormat(43759, self:GetSkillName(RandomSkillID))
  end
end
function skill_selection_system:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "skill_selection_system:OnPostSwitchGameStatus")
end
function skill_selection_system:RandomSelectSkill()
  local FittestSkillsData = FittestSkillsForMaps[self.CurViewId]
  local SkillID
  if FittestSkillsData then
    local RandIndex = math.random(1, #FittestSkillsData)
    SkillID = FittestSkillsData[RandIndex]
  else
    local SkillsData = self:GetSkillsData()
    local RandIndex = math.random(1, #SkillsData)
    SkillID = SkillsData[RandIndex].id
  end
  self:EquipSkill(SkillID)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.SkillSelection_RandomSelected, 0, tostring(self.CurSelectSkillID))
  return SkillID
end
function skill_selection_system:ShowRandomSelectNotice()
  if not self:ShouldShowSkillSelection() then
    return
  end
  if self.CurEquipedSkillID == nil and self.ReceivedSkillData and not self.ShouldShowNotice then
    local RandomSkillID = self:RandomSelectSkill()
    self.ShouldShowNotice = true
    self.NoticeContent = LocUtil.LocalizeResFormat(43759, self:GetSkillName(RandomSkillID))
  end
  if self.ShouldShowNotice and self.NoticeContent then
    local ModeAnim = UIManager.GetUI(UIManager.UI_Config.loading_anim_mgr)
    ModeAnim:ShowNotice(self.NoticeContent, false)
  end
  self.ShouldShowNotice = nil
  self.NoticeContent = nil
end
function skill_selection_system:OnStartMatch(_, __, MatchingStatus)
  if not MatchingStatus == ENUM_MatchStatus.Matching then
    return
  end
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if MatchModeMgrSystem.bIsMatchingSocialIsland then
    log(bWriteLog and "skill_selection_system:OnStartMatch: Is Matching SocialIsland Hide")
    self:HideSkillSelectionLobbyEntranceUI()
  end
end
function skill_selection_system:OnSelectionModeChange()
  if IsInGame() then
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  self.LastModeInfo = self.CurModeInfo
  self.CurModeInfo = logic_mode_selection:GetFilterInfo()
  self.LastMatchId, self.LastViewId, self.LastViewIds = self.CurMatchId, self.CurViewId, self.CurViewIds
  self.CurMatchId, self.CurViewId, self.CurViewIds = logic_mode_selection:GetCurSelectInfo()
  log(bWriteLog and string.format("[HZA]skill_selection_system:OnSelectionModeChange Last MatchId: %s Last ViewId: %s ", tostring(self.CurMatchId), tostring(self.CurViewId)))
  log(bWriteLog and string.format("[HZA]skill_selection_system:OnSelectionModeChange Current MatchId: %s Current ViewId: %s ", tostring(self.CurMatchId), tostring(self.CurViewId)))
  self:AddTimerOnce(0.1, function()
    if self:ShouldShowSkillSelection() then
      if not self:HaveFinishedGuideFlow() then
        self:ShowSkillSelectionMainUI()
      end
      self:ShowSkillSelectionLobbyEntranceUI()
    end
    if self:ShouldHideSkillSelection() then
      self:HideSkillSelectionMainUI()
      self:HideSkillSelectionLobbyEntranceUI()
    end
  end)
end
function skill_selection_system:InitLobbyEntrance()
  log(bWriteLog and "skill_selection_system:InitLobbyEntrance")
  if IsInGame() then
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  self.CurMatchId, self.CurViewId, self.CurViewIds = logic_mode_selection:GetCurSelectInfo()
  self.CurModeInfo = logic_mode_selection:GetFilterInfo()
  if self:ShouldShowSkillSelection() then
    log(bWriteLog and "[HZA]skill_selection_system:InitLobbyEntrance Show SkillSelectionLobbyEntrance")
    self:ShowSkillSelectionLobbyEntranceUI()
  end
  if self:ShouldHideSkillSelection() then
    log(bWriteLog and "[HZA]skill_selection_system:InitLobbyEntrance Hide SkillSelectionLobbyEntrance")
    self:HideSkillSelectionLobbyEntranceUI()
  end
end
function skill_selection_system:IsMapDownloaded()
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local logic_mode_map_download = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_map_download)
  local SubViewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(self.CurViewId) or {}
  local MapKeyList, MapKeyDict = logic_mode_map_download:GetMapKeyListByViewData(SubViewInfo)
  MapKeyList = MapKeyList or {
    "map_halloween2"
  }
  local State = logic_mode_map_download:GetMapListState(MapKeyList)
  return State == PufferConst.ENUM_DownloadState.Done
end
function skill_selection_system:ShowSkillSelectionMainUI()
  if not self:IsMapDownloaded() then
    ShowNotice(505089)
    return
  end
  if not UIManager.IsUIShow(UIManager.UI_Config.Lobby_Main_UIBP) then
    return
  end
  local TopUI = UIManager.GetTopUIName()
  if TopUI ~= UIManager.UI_Config.Lobby_Main_UIBP.keyName and TopUI ~= UIManager.UI_Config.mode_selection_main.keyName then
    log(bWriteLog and "[HZA]skill_selection_system:ShowSkillSelectionMainUI TopUI Is Not Lobby_Main_UIBP or ModeSelection_Main_UIBP, Cur Is :" .. TopUI)
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.SkillSelectionMain)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local SelectionState = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSkillSelectionState)
  if not SelectionState or SelectionState.MainUIShowInLobbyTimes and SelectionState.MainUIShowInLobbyTimes <= 0 then
    SelectionState = SelectionState or {}
    SelectionState.MainUIShowInLobbyTimes = 0
  end
  if not SelectionState.MainUIShowInLobbyTimes then
    SelectionState.MainUIShowInLobbyTimes = 0
  end
  SelectionState.MainUIShowInLobbyTimes = SelectionState.MainUIShowInLobbyTimes + 1
  PlayerPrefsSystem.SaveTableToFile_N(SelectionState, PlayerPrefsSystem.ePlayerPrefsType.eSkillSelectionState)
end
function skill_selection_system:HideSkillSelectionMainUI()
  UIManager.CloseUI(UIManager.UI_Config.SkillSelectionMain)
end
function skill_selection_system:ShowSkillSelectionLobbyEntranceUI()
  EventSystem:postEvent(EVENTTYPE_SKILL_SELECTION, EVENTID_SKILL_SELECTION_LOBBY_ENTRANCE_SHOW)
end
function skill_selection_system:HideSkillSelectionLobbyEntranceUI()
  EventSystem:postEvent(EVENTTYPE_SKILL_SELECTION, EVENTID_SKILL_SELECTION_LOBBY_ENTRANCE_HIDE)
end
function skill_selection_system:GetCurEquipedSkillID()
  if self.CurEquipedSkillID == 0 then
    self.CurEquipedSkillID = nil
  end
  return self.CurEquipedSkillID
end
function skill_selection_system:ShouldShowGuide()
  if IsInGame() then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local SelectionState = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSkillSelectionState)
  if self.CurEquipedSkillID ~= nil and self.CurEquipedSkillID ~= 0 then
    return false
  end
  if not SelectionState or not next(SelectionState) then
    return true
  end
  if SelectionState.MainUIShowInLobbyTimes and SelectionState.MainUIShowInLobbyTimes == 1 then
    return true
  end
  return false
end
function skill_selection_system:ShouldShowLobbyEntryGuide()
  if IsInGame() then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local SelectionState = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSkillSelectionState)
  if self.CurEquipedSkillID ~= nil and self.CurEquipedSkillID ~= 0 then
    return false
  end
  if not SelectionState or not next(SelectionState) then
    return true
  end
  if SelectionState.MainUIShowInLobbyTimes and SelectionState.MainUIShowInLobbyTimes == 1 then
    return true
  end
  return false
end
function skill_selection_system:GetSkillsData()
  local StringUtil = require("common.string_util")
  self.SkillsData = self.SkillsData or {}
  self.SkillIDToIndex = self.SkillIDToIndex or {}
  if not next(self.SkillsData) then
    local CharacterSkillTable = CDataTable.GetTable("CharacterSkillTable")
    for _, v in pairs(CharacterSkillTable) do
      local temp = {
        id = v.id,
        character_id = v.character_id,
        name = v.name,
        level = v.level,
        skill_type = v.skill_type,
        buffer = v.buffer,
        desc = v.desc,
        desc_value1 = v.desc_value1,
        desc_value2 = v.desc_value2,
        desc_value3 = v.desc_value3,
        desc_value4 = v.desc_value4,
        unlock = v.unlock,
        icon_big = v.icon_big,
        icon_small = v.icon_small,
        video_path = v.video_path
      }
      table.insert(self.SkillsData, temp)
      self.SkillIDToIndex[v.id] = #self.SkillsData
    end
  end
  return self.SkillsData
end
function skill_selection_system:GetSkillIndexByID(SkillID)
  if not self.SkillIDToIndex then
    self:GetSkillsData()
  end
  return self.SkillIDToIndex[SkillID]
end
function skill_selection_system:GetSkillDataByID(SkillID)
  local SkillIndex = self:GetSkillIndexByID(SkillID)
  if SkillIndex then
    return self.SkillsData[SkillIndex]
  end
  return nil
end
function skill_selection_system:GetSkillName(SkillID)
  local SkillConfig = CDataTable.GetTableData("CharacterSkillTable", SkillID)
  return SkillConfig and SkillConfig.name or ""
end
function skill_selection_system:GetSkillCD(SkillID)
  local SkillConfig = CDataTable.GetTableData("CharacterSkillTable", SkillID)
  return SkillConfig and SkillConfig.cd or 0
end
function skill_selection_system:GetSkillDesc(SkillID)
  local SkillConfig = CDataTable.GetTableData("CharacterSkillTable", SkillID)
  return SkillConfig and SkillConfig.desc or 0
end
function skill_selection_system:GetSkillVideoPath(SkillID)
  local SkillConfig = CDataTable.GetTableData("CharacterSkillTable", SkillID)
  return SkillConfig and SkillConfig.video_path or ""
end
function skill_selection_system:GetSkillSmallIcon(SkillID)
  local SkillConfig = CDataTable.GetTableData("CharacterSkillTable", SkillID)
  return SkillConfig and SkillConfig.icon_small or ""
end
function skill_selection_system:GetSkillBigIcon(SkillID)
  local SkillConfig = CDataTable.GetTableData("CharacterSkillTable", SkillID)
  return SkillConfig and SkillConfig.icon_big or ""
end
function skill_selection_system:EquipSkill(SkillID)
  self:SendEquipSkillReq(SkillID)
end
function skill_selection_system:ShouldHideSkillSelection()
  return not SkillModViewIDs[self.CurViewId]
end
function skill_selection_system:ShouldShowSkillSelection()
  return SkillModViewIDs[self.CurViewId]
end
function skill_selection_system:HaveFinishedGuideFlow()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local SelectionState = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSkillSelectionState)
  if self.CurEquipedSkillID ~= nil and self.CurEquipedSkillID ~= 0 then
    return true
  end
  if SelectionState and SelectionState.MainUIShowInLobbyTimes and 0 < SelectionState.MainUIShowInLobbyTimes and SelectionState.ClickedUse then
    return true
  end
  if SelectionState and SelectionState.MainUIShowInLobbyTimes and SelectionState.MainUIShowInLobbyTimes >= 3 then
    return true
  end
  return false
end
function skill_selection_system:SendEquipSkillReq(SkillID)
  local SkillSystemHandler = require("client.network.Protocol.SkillSystemHandler")
  SkillSystemHandler.send_skill_trial_select_skill_req(SkillID)
end
function skill_selection_system:OnEquipSkillRsp(ErrCode, SkillID)
  if tonumber(ErrCode) == 0 then
    self.CurEquiped    EventSystem:postEvent(EVENTTYPE_SKILL_SELECTION, EVENTID_SKILL_SELECTION_EQUIPED_SKILL)
  else
    ShowNotice(ErrCode)
  end
  if SkillID == 0 then
    SkillID = nil
  end
end
function skill_selection_system:SendGetSkillReq()
  local SkillSystemHandler = require("client.network.Protocol.SkillSystemHandler")
  SkillSystemHandler.send_skill_trial_get_skill_req()
end
function skill_selection_system:OnGetSkillRsp(ErrCode, SkillID)
  if tonumber(ErrCode) == 0 then
    self.CurEquiped    self.ReceivedSkillData = true
    EventSystem:postEvent(EVENTTYPE_SKILL_SELECTION, EVENTID_SKILL_DATA_RECEIVED)
  else
    ShowNotice(ErrCode)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CSkillSelectionSystem = class(CModuleBase, nil, skill_selection_system)
return CSkillSelectionSystem