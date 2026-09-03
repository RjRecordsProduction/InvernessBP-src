local Lobby_TeamPlatform_Entry = {}
function Lobby_TeamPlatform_Entry:ctor()
end
function Lobby_TeamPlatform_Entry:OnInitialize()
  Lobby_TeamPlatform_Entry.__super.OnInitialize(self)
  self.Border_2 = self.UIRoot.Border_2
  self.Image_Bg = self.UIRoot.Image_Bg
  self.Image_Effect = self.UIRoot.Image_Effect
  self.Image_Effect2 = self.UIRoot.Image_Effect2
  self.WidgetSwitcher_ImageTeamUp = self.UIRoot.WidgetSwitcher_ImageTeamUp
  self.TextBlock_Team = self.UIRoot.TextBlock_Team
  self.Reddot_Anchor = self.UIRoot.Reddot_Anchor
end
function Lobby_TeamPlatform_Entry:RegistEvents()
  Lobby_TeamPlatform_Entry.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_TeamUp, self.OnClickButton_TeamUp, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_RECRUIT_UPDATE, self.UpdateEntryView, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_RECRUIT_PUBLISH, self.UpdateEntryView, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_RECRUIT_CANCEL, self.UpdateEntryView, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_RECRUIT_TIMEOUT, self.UpdateEntryView, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, self.UpdateEntryView, self)
  self:AddCommonEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_REDDOT_NOTIFY, self.BindMentorReddot, self)
end
function Lobby_TeamPlatform_Entry:OnPostInitialize()
  Lobby_TeamPlatform_Entry.__super.OnPostInitialize(self)
  self:UpdateEntryView()
  self:AddTimerOnce(0.1, function()
    self:BindMentorReddot()
  end)
end
function Lobby_TeamPlatform_Entry:OnClickButton_TeamUp()
  log(bWriteLog and "Lobby_TeamPlatform_Entry:OnClickButton_TeamUp")
  self:PlayAudio(sound_config.click_v1)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if logic_mode_selection.hasSelectTxMission then
    log(bWriteLog and "Lobby_TeamPlatform_Entry:OnClickButton_TeamUp early return, hasSelectTxMission")
    ShowNotice(87013)
    return
  end
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  local bResReady = LogicPufferBundle.IsFitLobbyResDownloaded()
  if not bResReady then
    LogicPufferBundle.ShowFitLobbyResDownloadPopup()
    return
  end
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  growthprojectMgrB.HideWeakGuide(4, 1)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  local TeamPlatform_Macro = require("client.slua.logic.teamup.teamplatform_macro")
  local isSendRecruitDirectly = false
  local tlogReason = TeamPlatform_Macro.Enum_ButtonEntranceState.FindTeam
  if TeamPlatformSystem.IsInRecruit() then
    tlogReason = TeamPlatform_Macro.Enum_ButtonEntranceState.InRecruit
  elseif 1 < TeamUpNewSystem.GetTeamNum() and TeamUpNewSystem.IsTeamLeader() then
    isSendRecruitDirectly = true
    tlogReason = TeamPlatform_Macro.Enum_ButtonEntranceState.SendRecruit
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  local Opentype
  if LogicUGCMatch:GetMatchModID() > 0 or LogicUGCMulti.bIsBundleMatch then
    Opentype = 3
  else
    Opentype = 1
  end
  printf(bWriteLog and "Lobby_TeamPlatform_Entry:OnClickButton_TeamUp Opentype=%s isSendRecruitDirectly=%s tlogReason=%s", Opentype, isSendRecruitDirectly, tlogReason)
  TeamPlatformSystem.ShowUI(Opentype, isSendRecruitDirectly)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.TeamPlatFormEntranceClick, nil, tlogReason)
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:OnClickFeature(level_unlock_manager.featureDef.teamLobby)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_MID_TEAM_PLATFORM_ENTRY_CLICKED)
end
function Lobby_TeamPlatform_Entry:UpdateEntryView()
  log(bWriteLog and "Lobby_TeamPlatform_Entry:UpdateEntryView")
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  self:SetWidgetVisible(self.Border_2, false)
  self:SetWidgetVisible(self.Image_Bg, true)
  self:SetWidgetVisible(self.Image_Effect, false)
  self:SetWidgetVisible(self.Image_Effect2, false)
  if self.TextBlock_Team then
    self.TextBlock_Team:SetText("")
  end
  if not TeamPlatformSystem.IsOpen() then
    log(bWriteLog and "Lobby_TeamPlatform_Entry:UpdateEntryView TeamPlatformSystem.IsOpen() false")
    return
  end
  local nTeamNum = TeamUpNewSystem.GetTeamNum()
  local bIsLeader = TeamUpNewSystem.IsTeamLeader()
  local bMultiTeam = 1 < nTeamNum
  self.WidgetSwitcher_ImageTeamUp:SetActiveWidgetIndex(bMultiTeam and 1 or 0)
  if TeamPlatformSystem.IsInRecruit() then
    if not TeamPlatformSystem.IsFull() then
      self:SetWidgetVisible(self.Image_Bg, false)
      self:SetWidgetVisible(self.Image_Effect, true)
      self:SetWidgetVisible(self.Image_Effect2, true)
      self:SetWidgetVisible(self.Border_2, true)
      local teamPublishOption = TeamPlatformSystem.GetTeamPublishOption()
      local teamMaxNum = teamPublishOption and teamPublishOption.nPlayerNum or 4
      self.TextBlock_Team:SetText(LocUtil.LocalizeResFormat(6830, tostring(nTeamNum), tostring(teamMaxNum)))
      self.WidgetSwitcher_ImageTeamUp:SetActiveWidgetIndex(1)
    end
  elseif bMultiTeam and bIsLeader then
    self:SetWidgetVisible(self.Border_2, true)
    self.TextBlock_Team:SetText(LocUtil.LocalizeResFormat(43786))
  end
end
function Lobby_TeamPlatform_Entry:BindMentorReddot()
  local MentorRedPointData = require("client.slua.logic.mentor.mentor_reddot_data")
  local rData = MentorRedPointData.GetData()
  if not rData then
    log(bWriteLog and "Lobby_TeamPlatform_Entry:BindMentorReddot early return, rData is nil")
    return
  end
  log(bWriteLog and "Lobby_TeamPlatform_Entry:BindMentorReddot bind reddot data")
  self.Reddot_Anchor:UnBind()
  self:RegistReddotWidget(self.Reddot_Anchor)
  self.Reddot_Anchor:Bind(rData)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, Lobby_TeamPlatform_Entry)