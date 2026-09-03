local NewSkillLobbyEntrance = {}
function NewSkillLobbyEntrance:ctor(SelfType)
end
function NewSkillLobbyEntrance:OnInitialize()
  NewSkillLobbyEntrance.__super.OnInitialize(self)
  local skill_selection_system = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.skill_selection_system)
  skill_selection_system:SendGetSkillReq()
end
function NewSkillLobbyEntrance:RegistEvents()
  NewSkillLobbyEntrance.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_SkillSelection, self.OnButtonClicked, self)
  self:AddCommonEvent(EVENTTYPE_SKILL_SELECTION, EVENTID_SKILL_SELECTION_CLOSE, self.OnSkillSelectionMainClosed, self)
  self:AddCommonEvent(EVENTTYPE_SKILL_SELECTION, EVENTID_SKILL_SELECTION_LOBBY_ENTRANCE_SHOW, self.OnEntranceShow, self)
  self:AddCommonEvent(EVENTTYPE_SKILL_SELECTION, EVENTID_SKILL_SELECTION_LOBBY_ENTRANCE_HIDE, self.OnEntranceHide, self)
  self:AddCommonEvent(EVENTTYPE_SKILL_SELECTION, EVENTID_SKILL_DATA_RECEIVED, self.OnSkillChanged, self)
  self:AddCommonEvent(EVENTTYPE_SKILL_SELECTION, EVENTID_SKILL_SELECTION_EQUIPED_SKILL, self.OnSkillChanged, self)
  self:AddCommonEvent(EVENTTYPE_SKILL_SELECTION, EVENTID_SKILL_SELECTION_MODE_OTHER_TIPS_SHOW, self.OnOtherModeTipsBarShow, self)
  self:AddCommonEvent(EVENTTYPE_SKILL_SELECTION, EVENTID_SKILL_SELECTION_MODE_OTHER_TIPS_HIDE, self.OnOtherModeTipsBarHide, self)
end
function NewSkillLobbyEntrance:OnOtherModeTipsBarShow()
  if not self.UIRoot or not slua.isValid(self.UIRoot) then
    return
  end
  self.UIRoot.CanvasPanel_SkillSelection:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function NewSkillLobbyEntrance:OnOtherModeTipsBarHide()
  if not self.UIRoot or not slua.isValid(self.UIRoot) then
    return
  end
  local skill_selection_system = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.skill_selection_system)
  if skill_selection_system:ShouldShowSkillSelection() then
    if not self:IsOtherTipsShow() then
      self.UIRoot.CanvasPanel_SkillSelection:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    self.UIRoot.CanvasPanel_SkillSelection:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function NewSkillLobbyEntrance:OnShow()
  if not self.UIRoot or not slua.isValid(self.UIRoot) then
    return
  end
  self.UIRoot.CanvasPanel_GuideTips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:RefreshSkillEntrance()
end
function NewSkillLobbyEntrance:IsOtherTipsShow()
  local ActVisibility = self.UIRoot.CanvasPanel_Activity:GetVisibility()
  local RankVisibility = self.UIRoot.CanvasPanel_RankLimit:GetVisibility()
  if (ActVisibility == UEnums.ESlateVisibility.Collapsed or ActVisibility == UEnums.ESlateVisibility.Hidden) and (RankVisibility == UEnums.ESlateVisibility.Collapsed or RankVisibility == UEnums.ESlateVisibility.Hidden) then
    return false
  end
  return true
end
function NewSkillLobbyEntrance:OnEntranceShow()
  if not self.UIRoot or not slua.isValid(self.UIRoot) then
    return
  end
  if not self:IsOtherTipsShow() then
    self.UIRoot.CanvasPanel_SkillSelection:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  self:RefreshSkillEntrance()
  self:ShowEntranceAnim()
end
function NewSkillLobbyEntrance:OnEntranceHide()
  if not self.UIRoot or not slua.isValid(self.UIRoot) then
    return
  end
  self.UIRoot.CanvasPanel_SkillSelection:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:RefreshSkillEntrance()
end
function NewSkillLobbyEntrance:RefreshSkillEntrance()
  if not self.UIRoot or not slua.isValid(self.UIRoot) then
    return
  end
  log(bWriteLog and "[HZA]Skill_Lobby_Entrance_UIBP:SetSkillIcon")
  local UIUtil = require("client.slua_ui_framework.util")
  local skill_selection_system = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.skill_selection_system)
  local SkillID = skill_selection_system:GetCurEquipedSkillID()
  if SkillID and SkillID ~= 0 and skill_selection_system:IsMapDownloaded() then
    UIUtil.SetTexture(self.UIRoot.Image_SkillIcon, skill_selection_system:GetSkillSmallIcon(SkillID))
    log(bWriteLog and "[HZA]Skill_Lobby_Entrance_UIBP:SetSkillIcon Success")
  else
    UIUtil.SetTexture(self.UIRoot.Image_SkillIcon, "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Lobby_Icon_Skills_Toggle_png.Lobby_Icon_Skills_Toggle_png")
  end
  if SkillID and SkillID ~= 0 then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
  else
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  end
end
function NewSkillLobbyEntrance:ShowEntranceAnim()
  if not self.UIRoot or not slua.isValid(self.UIRoot) then
    return
  end
  self:AddTimer(0.1, function()
    self:PlayUserWidgetAnimation(self.UIRoot.Anim_loop, 0, 1, 0, 1)
  end)
end
function NewSkillLobbyEntrance:OnSkillChanged()
  self:RefreshSkillEntrance()
end
function NewSkillLobbyEntrance:OnButtonClicked()
  if not self.UIRoot or not slua.isValid(self.UIRoot) then
    return
  end
  self:PlayAudio("/Game/WwiseEvent/UI_hall/Play_UI_hall_Teaching.Play_UI_hall_Teaching")
  local skill_selection_system = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.skill_selection_system)
  skill_selection_system:ShowSkillSelectionMainUI()
  self.UIRoot.CanvasPanel_GuideTips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.SkillSelection_LobbyEntranceClick, 0)
end
function NewSkillLobbyEntrance:OnSkillSelectionMainClosed()
  if not self.UIRoot or not slua.isValid(self.UIRoot) then
    return
  end
  local skill_selection_system = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.skill_selection_system)
  if skill_selection_system:ShouldShowLobbyEntryGuide() then
    self.UIRoot.CanvasPanel_GuideTips:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:AddTimerOnce(6, function()
      self.UIRoot.CanvasPanel_GuideTips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end)
  end
  self:ShowEntranceAnim()
end
function NewSkillLobbyEntrance:OnClose()
  NewSkillLobbyEntrance.__super.OnClose(self)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, NewSkillLobbyEntrance)