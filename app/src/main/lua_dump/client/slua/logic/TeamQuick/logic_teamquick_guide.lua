local ELobbyGuideID = require("GameLua.Mod.MainCity.Client.logic.NewbieGuide.Config.newbie_guide_config").ELobbyGuideID
local level_unlock_config = require("client.logic.level_unlock.config.level_unlock_config")
local ETipDir = level_unlock_config.ETipDir
local ETipStyle = level_unlock_config.ETipStyle
local logic_teamquick_guide = {}
function logic_teamquick_guide:DefineAndResetData()
  self.isLobbyFadeinAnimFinish = false
  self.hasShownLobbyGuide = false
end
function logic_teamquick_guide:OnInitialize()
end
function logic_teamquick_guide:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_TEAMQUICK_GUIDE, self.OnShowGuide, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_FADE_IN_ANIM_FINISH, self.OnLobbyFadeinAnimFinish, self)
end
function logic_teamquick_guide:OnShowGuide()
  log(bWriteLog and "logic_teamquick_guide:OnShowGuide")
  if not self:CheckCanShowLobbyGuide() then
    log_warning(bWriteLog and "logic_teamquick_guide:OnShowGuide - Check failed")
    return
  end
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  local IsSlapEnd = NewFaceSlapSystem:IsSlapEnd()
  if not IsSlapEnd then
    log_warning(bWriteLog and "logic_teamquick_guide:OnShowGuide - Slap not end")
    return false
  end
  self:ShowLobbyEntryGuide()
end
function logic_teamquick_guide:OnLobbyFadeinAnimFinish()
  log(bWriteLog and "logic_teamquick_guide:OnLobbyFadeinAnimFinish")
  self.isLobbyFadeinAnimFinish = true
  self:ShowEntryGuide()
end
function logic_teamquick_guide:ShowEntryGuide()
  log(bWriteLog and "logic_teamquick_guide:ShowEntryGuide")
  if not self:CheckCanShowLobbyGuide() then
    log_warning(bWriteLog and "logic_teamquick_guide:ShowEntryGuide - Check failed")
    return
  end
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  local IsSlapStart = NewFaceSlapSystem:IsSlapStart()
  local IsSlapEnd = NewFaceSlapSystem:IsSlapEnd()
  if IsSlapStart and not IsSlapEnd then
    log_warning(bWriteLog and "logic_teamquick_guide:ShowEntryGuide - Slap in progress")
    return false
  end
  self:ShowLobbyEntryGuide()
end
function logic_teamquick_guide:ShowLobbyEntryGuide()
  log(bWriteLog and "logic_teamquick_guide:ShowLobbyEntryGuide")
  if not self:_CheckNeedShowGuide(ELobbyGuideID.LOBBY_TEAMQUICK_GUIDE_ID) then
    log_warning(bWriteLog and "logic_teamquick_guide:ShowLobbyEntryGuide - Has show lobby guide")
    return
  end
  local widget
  local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if lobbyMain then
    local Lobby_Mid_Friend_UIBP = lobbyMain:GetChildUI(UIManager.UI_Config.Lobby_Mid_Friend_UIBP)
    widget = Lobby_Mid_Friend_UIBP.UIRoot.CanvasPanel_TeamQuick
  end
  if not widget then
    log_warning(bWriteLog and "logic_teamquick_guide:ShowLobbyEntryGuide - Widget not found")
    return
  end
  local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
  local ParamTable = ui_show_queue_config.GetParamTable(nil, "IsLobbyLevelUnLock")
  local text = LocUtil.GetLocalizeResStr(817140)
  local cb = function()
    local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
    UIManager.ShowUI(UIManager.UI_Config.Lobby_InviteFriend_BP, FLMacros.ENUM_OPEN_FROM.LOBBY, FLMacros.ENUM_TAB.ENUM_TEAM_TAG)
    self:_RecordShowGuide(ELobbyGuideID.LOBBY_TEAMQUICK_GUIDE_ID)
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.FlashSquad_Onboarding_Step, 0)
  end
  UIManager.ShowUI(UIManager.UI_Config.level_unlock_bubble, ETipDir.right, text, widget, cb, true, false, nil, nil, ParamTable)
  self.hasShownLobbyGuide = true
end
function logic_teamquick_guide:ShowFriendGuide(widget, callback)
  log(bWriteLog and "logic_teamquick_guide:ShowFriendGuide")
  if not widget or not slua.isValid(widget) then
    log_warning(bWriteLog and "logic_teamquick_guide:ShowFriendGuide - Widget not found")
    return
  end
  if not self:_CheckNeedShowGuide(ELobbyGuideID.LOBBY_TEAMQUICK_FRIEND_GUIDE_ID) then
    log_warning(bWriteLog and "logic_teamquick_guide:ShowFriendGuide - Check failed")
    return
  end
  if not UIManager.IsUIShow(UIManager.UI_Config.Lobby_InviteFriend_BP) then
    log_warning(bWriteLog and "logic_teamquick_guide:ShowFriendGuide - Lobby_InviteFriend_BP not show")
    return
  end
  local topUIName = UIManager.GetTopUIName()
  if topUIName ~= UIManager.UI_Config.Lobby_InviteFriend_BP.keyName then
    log_warning(bWriteLog and "logic_teamquick_guide:ShowFriendGuide - Top UI is not Lobby_InviteFriend_BP")
    return
  end
  local cb = function()
    if callback then
      callback()
    end
    self:_RecordShowGuide(ELobbyGuideID.LOBBY_TEAMQUICK_FRIEND_GUIDE_ID)
  end
  local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
  local ParamTable = ui_show_queue_config.GetParamTable(nil, "NotUseQueue")
  local uiInfo = UIManager.ShowUI(UIManager.UI_Config.level_unlock_bubble, -1, nil, widget, cb, true, nil, nil, nil, ParamTable)
  return uiInfo
end
function logic_teamquick_guide:CheckCanShowLobbyGuide()
  local logic_newbie = require("client.logic.newbie.logic_newbie")
  local flag = logic_newbie.NeedShowNewbieGuide(ELobbyGuideID.LOBBY_TEAMQUICK_GUIDE_ID)
  if not flag then
    log_warning(bWriteLog and "logic_teamquick_guide:CheckCanShowLobbyGuide - Already shown guide")
    return false
  end
  local logic_teamquick_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_teamquick_entry)
  if not logic_teamquick_entry:CheckCanShow() then
    log_warning(bWriteLog and "logic_teamquick_guide:CheckCanShowLobbyGuide - Entry not open")
    return false
  end
  if not self.isLobbyFadeinAnimFinish then
    log_warning(bWriteLog and "logic_teamquick_guide:CheckCanShowLobbyGuide - Lobby FadeIn Anim not finish")
    return false
  end
  if self.hasShownLobbyGuide then
    log_warning(bWriteLog and "logic_teamquick_guide:CheckCanShowLobbyGuide - isShownLobbyGuide")
    return false
  end
  return true
end
function logic_teamquick_guide:TryShowPageGuide()
  local needShowGuide = self:_CheckNeedShowGuide(ELobbyGuideID.LOBBY_TEAMQUICK_PAGE_GUIDE_ID)
  if not needShowGuide then
    log_warning(bWriteLog and "logic_teamquick_guide:TryShowPageGuide - Already shown guide")
    return false
  end
  self:ShowPageGuide()
end
function logic_teamquick_guide:ShowPageGuide()
  local guideData = {
    list = {
      {
        contentType = ENUM_PAGE_GUIDE_CONTENT_TYPE.BluePrint,
        bpPath = "/Game/UMG/UI_BP/TeamQuick/TeamQuick_Guide_Page1_UIBP.TeamQuick_Guide_Page1_UIBP",
        title = LocUtil.GetLocalizeResStr(817151),
        desc = LocUtil.GetLocalizeResStr(817152)
      },
      {
        contentType = ENUM_PAGE_GUIDE_CONTENT_TYPE.BluePrint,
        bpPath = "/Game/UMG/UI_BP/TeamQuick/TeamQuick_Guide_Page2_UIBP.TeamQuick_Guide_Page2_UIBP",
        title = LocUtil.GetLocalizeResStr(817159),
        desc = LocUtil.GetLocalizeResStr(817160)
      },
      {
        contentType = ENUM_PAGE_GUIDE_CONTENT_TYPE.BluePrint,
        bpPath = "/Game/UMG/UI_BP/TeamQuick/TeamQuick_Guide_Page3_UIBP.TeamQuick_Guide_Page3_UIBP",
        title = LocUtil.GetLocalizeResStr(817163),
        desc = LocUtil.GetLocalizeResStr(817164)
      },
      {
        contentType = ENUM_PAGE_GUIDE_CONTENT_TYPE.BluePrint,
        bpPath = "/Game/UMG/UI_BP/TeamQuick/TeamQuick_Guide_Page4_UIBP.TeamQuick_Guide_Page4_UIBP",
        title = LocUtil.GetLocalizeResStr(817166),
        desc = LocUtil.GetLocalizeResStr(817167)
      }
    },
    closeFunc = function()
      self:_RecordShowGuide(ELobbyGuideID.LOBBY_TEAMQUICK_PAGE_GUIDE_ID)
    end,
    skipToNext = true
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_PageGuide_UIBP, guideData)
end
function logic_teamquick_guide:CheckHasShowLobbyGuide()
  local needShowGuide = self:_CheckNeedShowGuide(ELobbyGuideID.LOBBY_TEAMQUICK_GUIDE_ID)
  return not needShowGuide
end
function logic_teamquick_guide:GMCompleteLobbyGuide()
  self:_RecordShowGuide(ELobbyGuideID.LOBBY_TEAMQUICK_GUIDE_ID)
end
function logic_teamquick_guide:GMCompleteFriendGuide()
  self:_RecordShowGuide(ELobbyGuideID.LOBBY_TEAMQUICK_FRIEND_GUIDE_ID)
end
function logic_teamquick_guide:GMCompletePageGuide()
  self:_RecordShowGuide(ELobbyGuideID.LOBBY_TEAMQUICK_PAGE_GUIDE_ID)
end
function logic_teamquick_guide:_RecordShowGuide(guideID)
  log(bWriteLog and "logic_teamquick_guide:_RecordShowGuide - guideID: " .. guideID)
  local logic_newbie = require("client.logic.newbie.logic_newbie")
  DataMgr.SetNewbieGuideValue(logic_newbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, guideID, 1)
end
function logic_teamquick_guide:_CheckNeedShowGuide(guideID)
  local logic_newbie = require("client.logic.newbie.logic_newbie")
  local needShowGuide = DataMgr.HaveNewbieGuide(logic_newbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, guideID)
  log_format("logic_teamquick_guide:CheckHasShowLobbyGuide. guideID: %s, needShowGuide: %s", guideID, needShowGuide)
  return needShowGuide
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_teamquick_guide = class(CModuleBase, nil, logic_teamquick_guide)
return Clogic_teamquick_guide