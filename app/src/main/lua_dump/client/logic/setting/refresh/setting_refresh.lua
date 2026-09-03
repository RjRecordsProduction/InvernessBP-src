local Refresh = {}
local LogicSettingBasic = require("client.slua.logic.setting.logic_setting_basic")
local SettingCfg = require("client.logic.setting.setting_config")
local SettingMacro = require("client.slua.logic.setting.setting_macro")
local UIUtil = require("client.common.ui_util")
local GetOneSettingValue = LogicSettingBasic.GetOneSettingValue
local SetOneSettingValue = LogicSettingBasic.SetOneSettingValue
local CfgConvertNot = LogicSettingBasic.CfgConvertNot
local CfgConvert1And2 = LogicSettingBasic.CfgConvert1And2
local EItemType = SettingMacro.EItemType
local C_TEXTCOLOR_UNSELECTED = FSlateColor(FLinearColor(1, 1, 1, 0.5))
local C_TEXTCOLOR_SELECTED = FSlateColor(FLinearColor(0.571125, 1, 0.921582, 1))
local Key2Widget = function(key)
  if not SettingCfg[key] then
    return nil
  end
  return SettingCfg[key].widget
end
local RefreshSubKeys = function(key)
  local subItems = SettingCfg[key].subItems
  for _, subKey in pairs(subItems) do
    Refresh.RefreshItem(subKey)
  end
end
local PlaySound = function()
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudio(sound_config.click_v1)
end
local ReportTLog = function(key)
  if SettingCfg[key].enableTLog then
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    local LogStr = string.format("Option=%s,Value=%s", key, tostring(GetOneSettingValue(key)))
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.OptionSwitch, 0, LogStr)
  end
end
local ConvertedOneAndZero = function(switch)
  if switch == 1 then
    switch = 0
  else
    switch = 1
  end
  return switch
end
local GetbONDouble = function(key)
  local KeyConfig = SettingCfg[key]
  if KeyConfig.isNormal or Refresh["GetbON" .. key] == nil then
    local SettingValue = GetOneSettingValue(key)
    if SettingValue == true or SettingValue == false then
      return SettingValue
    elseif SettingValue == 1 or SettingValue == 2 then
      return SettingValue == 2
    end
  elseif Refresh["GetbON" .. key] then
    return Refresh["GetbON" .. key](key)
  end
end
local SetbONDouble = function(key)
  local KeyConfig = SettingCfg[key]
  if KeyConfig.isNormal or Refresh["SetbON" .. key] == nil then
    local SettingValue = GetOneSettingValue(key)
    if SettingValue == true or SettingValue == false then
      CfgConvertNot(key)
    elseif SettingValue == 1 or SettingValue == 2 then
      CfgConvert1And2(key)
    end
  elseif Refresh["SetbON" .. key] then
    Refresh["SetbON" .. key](key)
  end
  ReportTLog(key)
end
local RefreshNormalDoubleV = function(key)
  local root = Key2Widget(key)
  if root then
    local bON = GetbONDouble(key)
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, bON)
  end
end
local OnClickNormalDoubleV = function(key)
  PlaySound()
  SetbONDouble(key)
  RefreshNormalDoubleV(key)
end
local RefreshNormalDoubleVWord = function(key)
  local root = Key2Widget(key)
  local bON = GetbONDouble(key)
  if root then
    UIUtil.SetWidgetVisible(root.Single_Left, not bON)
    UIUtil.SetWidgetVisible(root.Single_Right, bON)
  end
  return bON
end
local OnClickNormalDoubleVWord = function(key)
  PlaySound()
  SetbONDouble(key)
  RefreshNormalDoubleVWord(key)
end
local RefreshDoubleSlim = function(key)
  local root = Key2Widget(key)
  if not root then
    return
  end
  local bON = GetbONDouble(key)
  root.Image_Highlight:SetRenderAngle(bON and 0 or 180)
  root.TextBlock_Left:SetColorAndOpacity(bON and C_TEXTCOLOR_SELECTED or C_TEXTCOLOR_UNSELECTED)
  root.TextBlock_Right:SetColorAndOpacity(not bON and C_TEXTCOLOR_SELECTED or C_TEXTCOLOR_UNSELECTED)
end
local OnClickDoubleSlim = function(key)
  PlaySound()
  SetbONDouble(key)
  RefreshDoubleSlim(key)
end
local RefreshNormalTreble = function(key)
  local root = Key2Widget(key)
  if not root then
    return
  end
  local SettingValue = GetOneSettingValue(key)
  UIUtil.SetWidgetVisible(root.status_off1, SettingValue ~= 1)
  UIUtil.SetWidgetVisible(root.status_on1, SettingValue == 1)
  UIUtil.SetWidgetVisible(root.status_off2, SettingValue ~= 2)
  UIUtil.SetWidgetVisible(root.status_on2, SettingValue == 2)
  UIUtil.SetWidgetVisible(root.status_off3, SettingValue ~= 3)
  UIUtil.SetWidgetVisible(root.status_on3, SettingValue == 3)
end
local OnClickNormalTreble = function(key, index)
  PlaySound()
  SetOneSettingValue(key, index)
  RefreshNormalTreble(key)
  ReportTLog(key)
end
local RefreshNormalTreble120 = function(key)
  local root = Key2Widget(key)
  if not root then
    return
  end
  local SettingValue = GetOneSettingValue(key)
  UIUtil.SetWidgetVisible(root.status_off1, SettingValue ~= 1)
  UIUtil.SetWidgetVisible(root.status_on1, SettingValue == 1)
  UIUtil.SetWidgetVisible(root.status_off2, SettingValue ~= 2)
  UIUtil.SetWidgetVisible(root.status_on2, SettingValue == 2)
  UIUtil.SetWidgetVisible(root.status_off3, SettingValue ~= 0)
  UIUtil.SetWidgetVisible(root.status_on3, SettingValue == 0)
end
local OnClickNormalTreble120 = function(key, index)
  PlaySound()
  local SettingValue = index % 3
  SetOneSettingValue(key, SettingValue)
  RefreshNormalTreble120(key)
  ReportTLog(key)
end
local RefreshNormalDoubleParent = function(key)
  local root = Key2Widget(key)
  local bON = GetbONDouble(key)
  if not root then
    return
  end
  LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, bON)
  local subItems = SettingCfg[key].subItems
  for _, subName in pairs(subItems) do
    UIUtil.SetWidgetVisible(Key2Widget(subName), bON)
  end
  if bON then
    RefreshSubKeys(key)
  end
  Refresh.ToggleRedDisplay(key, SettingCfg[key].RedInSub and not bON)
end
local OnClickNormalDoubleParent = function(key)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  SetbONDouble(key)
  RefreshNormalDoubleParent(key)
  local SettingSystem = require("client.logic.setting.logic_setting")
  SettingSystem.RefreshOneOverLayHeight(key)
end
function Refresh.GetbShowSub(key)
  local KeyConfig = SettingCfg[key]
  if KeyConfig.isNormal or Refresh["GetbShowSub" .. key] == nil then
    if KeyConfig.itemType == EItemType.DoubleParent then
      return GetbONDouble(key)
    end
  elseif Refresh["GetbShowSub" .. key] then
    return Refresh["GetbShowSub" .. key](key)
  end
  return true
end
function Refresh.RefreshItem(key, ...)
  local KeyConfig = SettingCfg[key]
  if KeyConfig.isNormal or Refresh["Refresh" .. key] == nil then
    if KeyConfig.itemType == EItemType.DoubleV then
      return RefreshNormalDoubleV(key)
    elseif KeyConfig.itemType == EItemType.DoubleVWord then
      return RefreshNormalDoubleVWord(key)
    elseif KeyConfig.itemType == EItemType.Treble then
      return RefreshNormalTreble(key)
    elseif KeyConfig.itemType == EItemType.DoubleParent then
      return RefreshNormalDoubleParent(key)
    elseif KeyConfig.itemType == EItemType.DoubleSlim then
      return RefreshDoubleSlim(key)
    end
  elseif Refresh["Refresh" .. key] then
    return Refresh["Refresh" .. key](key, ...)
  end
end
function Refresh.OnClickItem(key, index, ...)
  local KeyConfig = SettingCfg[key]
  if KeyConfig.isNormal or Refresh["OnClick" .. key] == nil then
    if KeyConfig.itemType == EItemType.DoubleV then
      OnClickNormalDoubleV(key)
    elseif KeyConfig.itemType == EItemType.DoubleVWord then
      OnClickNormalDoubleVWord(key)
    elseif KeyConfig.itemType == EItemType.Treble then
      OnClickNormalTreble(key, index)
    elseif KeyConfig.itemType == EItemType.DoubleParent then
      OnClickNormalDoubleParent(key)
    elseif KeyConfig.itemType == EItemType.DoubleSlim then
      OnClickDoubleSlim(key)
    end
  elseif Refresh["OnClick" .. key] then
    Refresh["OnClick" .. key](key, index, ...)
  end
end
function Refresh.OnClickHelpNormal(key)
  PlaySound()
  local cfg = SettingCfg[key]
  if not cfg.widget then
    return
  end
  local tipsId = cfg.needHelp
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_three, LocUtil.GetLocalizeResStr(tipsId), cfg.widget.Button_Help)
end
function Refresh.BShowGromeLinkOpen()
  local logic_grome_link = require("client.slua.logic.gromelink.logic_grome_link")
  return logic_grome_link:ValidateGRomelinkActivation()
end
function Refresh.ToggleRedDisplay(key, isRed)
  if SettingCfg[key] then
    local widget = SettingCfg[key].widget
    if widget and widget.Red then
      UIUtil.SetWidgetVisible(widget.Red, isRed)
      UIUtil.SetWidgetVisible(widget.Red.CanvasPanel_RedAnim, false)
    end
  end
end
function Refresh.OnClickDriftMode(key)
  PlaySound()
  local bTurnOnDrift = true
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if SettingConfig then
    bTurnOnDrift = SettingConfig.DriftMode > 0
  end
  SettingConfig.DriftMode = bTurnOnDrift and 0 or 1
  slua_GameFrontendHUD:FinishModifyUserSettings()
  Refresh.RefreshDriftMode(key)
end
function Refresh.RefreshDriftMode(key)
  local root = Key2Widget(key)
  if root then
    local bTurnOnDrift = true
    local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
    if SettingConfig then
      bTurnOnDrift = SettingConfig.DriftMode > 0
    end
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, bTurnOnDrift)
  end
end
function Refresh.OnClickAutoPickupSwitcher(key)
  OnClickNormalDoubleV(key)
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_AUTOPICKUP_SWITCH)
end
function Refresh.OnClickTeammateTakeOver(key)
  OnClickNormalDoubleV(key)
  local logic_ai_take_over = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ai_take_over)
  logic_ai_take_over:ReportTLog(1)
end
function Refresh.RefreshAutoPickupSwitcher(key)
  RefreshNormalDoubleV(key)
end
function Refresh.OnClickAutoPickupSwitcherCombo(key, index)
  PlaySound()
  if index == 1 then
    SetOneSettingValue("AutoPickupSwitcher", true)
    SetOneSettingValue("AutoPickupSwitcherTPlan", true)
  elseif index == 2 then
    SetOneSettingValue("AutoPickupSwitcher", false)
    SetOneSettingValue("AutoPickupSwitcherTPlan", false)
  elseif index == 3 then
    SetOneSettingValue("AutoPickupSwitcher", true)
    SetOneSettingValue("AutoPickupSwitcherTPlan", false)
  end
  Refresh.RefreshAutoPickupSwitcherCombo(key)
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_AUTOPICKUP_SWITCH)
end
function Refresh.RefreshAutoPickupSwitcherCombo(key)
  local root = Key2Widget(key)
  if not root then
    return
  end
  local bON = GetOneSettingValue("AutoPickupSwitcher")
  local bONTPlan = GetOneSettingValue("AutoPickupSwitcherTPlan")
  local CompValue = 1
  if bON and bONTPlan then
    CompValue = 1
  elseif bON and not bONTPlan then
    CompValue = 3
  elseif not bON and bONTPlan then
    SetOneSettingValue("AutoPickupSwitcherTPlan", false)
  elseif not bON and not bONTPlan then
    CompValue = 2
  end
  UIUtil.SetWidgetVisible(root.status_off1, CompValue ~= 1)
  UIUtil.SetWidgetVisible(root.status_on1, CompValue == 1)
  UIUtil.SetWidgetVisible(root.status_off2, CompValue ~= 2)
  UIUtil.SetWidgetVisible(root.status_on2, CompValue == 2)
  UIUtil.SetWidgetVisible(root.status_off3, CompValue ~= 3)
  UIUtil.SetWidgetVisible(root.status_on3, CompValue == 3)
end
function Refresh.RefreshAutoPickClipType(key)
  RefreshNormalTreble120(key)
end
function Refresh.OnClickAutoPickClipType(key, index)
  OnClickNormalTreble120(key, index)
end
local RefreshFriendsOnly = function(key, value)
  local SettingValue = value
  local root = Key2Widget(key)
  if not root then
    return
  end
  UIUtil.SetWidgetVisible(root.status_off1, SettingValue ~= 1)
  UIUtil.SetWidgetVisible(root.status_on1, SettingValue == 1)
  UIUtil.SetWidgetVisible(root.status_off2, SettingValue ~= 2)
  UIUtil.SetWidgetVisible(root.status_on2, SettingValue == 2)
  UIUtil.SetWidgetVisible(root.status_off3, SettingValue ~= 0)
  UIUtil.SetWidgetVisible(root.status_on3, SettingValue == 0)
end
local RefreshFriendsOnlyValue = function(value)
  local SettingValue = 0
  if value == true then
    SettingValue = 1
  elseif value == false then
    SettingValue = 2
  elseif value == nil then
    SettingValue = 2
  elseif value == 0 then
    SettingValue = 2
  elseif value == 1 then
    SettingValue = 1
  elseif value == 2 then
    SettingValue = 0
  end
  return SettingValue
end
function Refresh.RefreshDoubleCanShowHistory(key)
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    local SettingValue = RefreshFriendsOnlyValue(LogicSettingBasic.bCanShowHistory)
    RefreshFriendsOnly(key, SettingValue)
    return SettingValue
  else
    local root = Key2Widget(key)
    if not root then
      return
    end
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, LogicSettingBasic.bCanShowHistory)
    return LogicSettingBasic.bCanShowHistory
  end
end
function Refresh.OnClickDoubleCanShowHistory(key, index)
  PlaySound()
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    if index == 1 then
      index = 1
    elseif index == 2 then
      index = 0
    elseif index == 3 then
      index = 2
    end
    LogicSettingBasic.bCanShowHistory = index
    local RoleInfoHistorySystem = require("client.logic.roleinfo.logic_roleinfo_history")
    RoleInfoHistorySystem.send_show_history(LogicSettingBasic.bCanShowHistory)
  else
    LogicSettingBasic.bCanShowHistory = not LogicSettingBasic.bCanShowHistory
    local RoleInfoHistorySystem = require("client.logic.roleinfo.logic_roleinfo_history")
    RoleInfoHistorySystem.send_show_history(LogicSettingBasic.bCanShowHistory)
  end
  Refresh.RefreshDoubleCanShowHistory(key)
end
function Refresh.RefreshDoubleCanShowRole(key)
  local roleUid = DataMgr.roleData.uid
  local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
  local playerInfo = BasicDataAvatarWearInfo:GetCacheData(roleUid)
  if nil == playerInfo then
    return
  end
  LogicSettingBasic.bCanShowRole = playerInfo.bshow
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    local SettingValue = RefreshFriendsOnlyValue(LogicSettingBasic.bCanShowRole)
    RefreshFriendsOnly(key, SettingValue)
    return SettingValue
  else
    local root = Key2Widget(key)
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, LogicSettingBasic.bCanShowRole)
    return LogicSettingBasic.bCanShowRole
  end
end
function Refresh.OnClickDoubleCanShowRole(key, index)
  PlaySound()
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    if index == 1 then
      index = 1
    elseif index == 2 then
      index = 0
    elseif index == 3 then
      index = 2
    end
    LogicSettingBasic.SendCanShowRole()
    local ProfileHander = require("client.network.Protocol.ProfileHander")
    ProfileHander.send_chg_avatar_show_switch_req(index)
  else
    local bshow = not LogicSettingBasic.bCanShowRole
    log(bWriteLog and "EventSettingSendCanShowRole BP_SettingCanShowRole " .. tostring(bshow))
    LogicSettingBasic.SendCanShowRole()
    local ProfileHander = require("client.network.Protocol.ProfileHander")
    ProfileHander.send_chg_avatar_show_switch_req(bshow)
  end
end
function Refresh.RefreshDoubleCanShowPopularity(key)
  local PopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    local SettingValue = RefreshFriendsOnlyValue(PopularitySystem.IsShowDetail)
    RefreshFriendsOnly(key, SettingValue)
    return SettingValue
  else
    if PopularitySystem.IsShowDetail == 0 then
      PopularitySystem.IsShowDetail = false
    elseif PopularitySystem.IsShowDetail == 1 then
      PopularitySystem.IsShowDetail = true
    elseif PopularitySystem.IsShowDetail == 2 then
      PopularitySystem.IsShowDetail = false
    end
    local root = Key2Widget(key)
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, PopularitySystem.IsShowDetail)
    return PopularitySystem.IsShowDetail
  end
end
function Refresh.OnClickDoubleCanShowPopularity(key, index)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  local PopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    if index == 1 then
      index = 1
    elseif index == 2 then
      index = 0
    elseif index == 3 then
      index = 2
    end
    PopularitySystem.IsShowDetail = index
    PopularitySystem.show_popularity_detail_req(PopularitySystem.IsShowDetail)
  else
    PopularitySystem.show_popularity_detail_req(not PopularitySystem.IsShowDetail)
  end
end
function Refresh.RefreshDoubleHideVisitRecord(key)
  local root = Key2Widget(key)
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  if root then
    return LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, RoleInfoPopularitySystem.bHideVisitRecord)
  end
  return RoleInfoPopularitySystem.bHideVisitRecord
end
function Refresh.OnClickDoubleHideVisitRecord(_)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.send_set_pspace_hidden_visitor_track(not RoleInfoPopularitySystem.bHideVisitRecord)
end
function Refresh.RefreshDoubleCanShowPround(key)
  local bShow = false
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    if DataMgr.roleData.pround_info then
      bShow = DataMgr.roleData.pround_info.is_visable or 0
    end
    local SettingValue = RefreshFriendsOnlyValue(bShow)
    RefreshFriendsOnly(key, SettingValue)
    return SettingValue
  else
    if DataMgr.roleData.pround_info then
      bShow = DataMgr.roleData.pround_info.is_visable or false
    end
    local root = Key2Widget(key)
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, bShow)
    return bShow
  end
end
function Refresh.OnClickDoubleCanShowPround(key, index)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    local PopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
    PopularitySystem.set_popularity_pround_visable_req(index)
  else
    local bShow = false
    if DataMgr.roleData.pround_info then
      bShow = DataMgr.roleData.pround_info.is_visable or false
    end
    local PopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
    PopularitySystem.set_popularity_pround_visable_req(not bShow)
  end
end
function Refresh.RefreshDoubleCanShowPlayDay(key)
  local root = Key2Widget(key)
  local CharacterHandler = require("client.network.Protocol.CharacterHandler")
  if root then
    if CharacterHandler.bShowPlayDays then
      root.Setting_Switch:SetSwitcherEnable2(true)
    else
      root.Setting_Switch:SetSwitcherEnable2(false)
    end
  end
  return CharacterHandler.bShowPlayDays
end
function Refresh.OnClickDoubleCanShowPlayDay(_)
  PlaySound()
  local CharacterHandler = require("client.network.Protocol.CharacterHandler")
  if CharacterHandler.bShowPlayDays == nil then
    return
  end
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  local bShowPlayDays = not CharacterHandler.bShowPlayDays
  CharacterHandler.send_modify_role_privacy(bShowPlayDays, 1)
end
function Refresh.BShowDoubleOfflineInvite()
  local Logic_Offline_Invite = require("client.slua.logic.teamup.logic_offline_invite")
  return Logic_Offline_Invite.GetOfflineInviteIsOpen()
end
function Refresh.BShowDoubleGlobalInvite()
  local Logic_Offline_Invite = require("client.slua.logic.teamup.logic_offline_invite")
  return Logic_Offline_Invite.GetMessengerInviteIsOpen() and Refresh.CheckFacebookUser()
end
function Refresh.RefreshDoubleOfflineInvite(key)
  local root = Key2Widget(key)
  local show = Refresh.BShowDoubleOfflineInvite()
  log(bWriteLog and "[v_zhanggao] RefreshDoubleOfflineInvite" .. " " .. tostring(show))
  UIUtil.SetWidgetVisible(root, show)
  if show then
    local Logic_Offline_Invite = require("client.slua.logic.teamup.logic_offline_invite")
    local settingValue = Logic_Offline_Invite.GetCurFcmSettingState()
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, settingValue == 0)
  end
end
function Refresh.OnClickDoubleOfflineInvite(key)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  DataMgr.SendSettingReq_Bool(false, RoleSettingType.OfflineInvite, DataMgr.GetRoleSetting(RoleSettingType.OfflineInvite) ~= 0)
  local Logic_Offline_Invite = require("client.slua.logic.teamup.logic_offline_invite")
  Logic_Offline_Invite.SetCurFcmSettingState()
  Refresh.RefreshDoubleOfflineInvite(key)
end
function Refresh.RefreshDoubleGlobalInvite(key)
  local root = Key2Widget(key)
  local show = Refresh.BShowDoubleGlobalInvite()
  log(bWriteLog and "[v_zhanggao] RefreshDoubleOfflineInvite" .. " " .. tostring(show))
  UIUtil.SetWidgetVisible(root, show)
  if show then
    local Logic_Offline_Invite = require("client.slua.logic.teamup.logic_offline_invite")
    local settingValue = Logic_Offline_Invite.GetCurMesengerSettingValue()
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, settingValue == 0)
  end
end
function Refresh.OnClickDoubleGlobalInvite(key)
  PlaySound()
  log(bWriteLog and "\229\133\168\231\144\131\229\188\128\229\133\179")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  if not GlobalData.IsJapanOrKorea() then
    DataMgr.SendSettingReq_Bool(false, RoleSettingType.GlobalMessagener, DataMgr.GetRoleSetting(RoleSettingType.GlobalMessagener) ~= 0)
  end
  local Logic_Offline_Invite = require("client.slua.logic.teamup.logic_offline_invite")
  Logic_Offline_Invite.SetMessagenerSettingState()
  Refresh.RefreshDoubleGlobalInvite(key)
end
function Refresh.CheckFacebookUser()
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  log(bWriteLog and "[v_zhanggao] IMSDKHelperInstance:GetCurLoginPlatform " .. IMSDKHelperInstance:GetCurLoginPlatform())
  if IMSDKHelperInstance:GetCurLoginPlatform() == ShareSource.Messenger or IMSDKHelperInstance:GetCurLoginPlatform() == ShareSource.Facebook then
    return true
  end
  return false
end
function Refresh.BShowbLbsMain()
  local SettingSystem = require("client.logic.setting.logic_setting")
  if SettingSystem.IsHideLBSPanel() or not GameStatus.IsInLobbyOrMainCity() then
    return false
  end
  return true
end
function Refresh.GetbShowSubbLbsMain(key)
  local show = Refresh.BShowbLbsMain()
  local open = GetOneSettingValue(key)
  return show and open
end
function Refresh.RefreshbLbsMain(key)
  if IsWoWEditor then
    return false
  end
  local root = Key2Widget(key)
  local show = Refresh.BShowbLbsMain()
  if not root then
    return show
  end
  UIUtil.SetWidgetVisible(root, show)
  if show then
    local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
    local name = LbsMgr.GetMySetZoneConcatName("/")
    root.TextBlock_Word:SetText(name)
    root.TextBlock_ButtonWord:SetText(LocUtil.GetLocalizeResStr(24612))
    local open = GetOneSettingValue(key)
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, open)
    local visibility = UIUtil.BoolToVisible(open)
    local subItems = SettingCfg[key].subItems
    for _, subName in pairs(subItems) do
      if Key2Widget(subName) then
        Key2Widget(subName):SetWidgetVisibility(visibility)
      end
    end
    if open then
      for _, subName in pairs(subItems) do
        if Key2Widget(subName) then
          Refresh["Refresh" .. subName](subName)
        end
      end
    end
    return open
  end
  return false
end
function Refresh.OnClickbLbsMain(key)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  CfgConvertNot(key)
  local bLbsMain = GetOneSettingValue(key)
  local LBSHandler = require("client.network.Protocol.LBSHandler")
  local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
  if bLbsMain then
    LBSHandler.send_lbs_set_privacy_req(LbsMgr.SETTING_CFG_MAIN_ID, 1)
  else
    LBSHandler.send_lbs_set_privacy_req(LbsMgr.SETTING_CFG_MAIN_ID, 2)
  end
  Refresh.RefreshbLbsMain(key)
  local SettingSystem = require("client.logic.setting.logic_setting")
  SettingSystem.RefreshOneOverLayHeight(key)
end
function Refresh.OnClickChoosebLbsMain(_)
  PlaySound()
  log(bWriteLog and "Refresh.OnClickChoosebLbsMain lsb")
  local logic_lbs_warzone = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lbs_warzone)
  logic_lbs_warzone:RefreshGPSZone()
end
function Refresh.BShowbLBSNear()
  if IsWoWEditor then
    return false
  end
  local SettingSystem = require("client.logic.setting.logic_setting")
  if SettingSystem.IsHideLBSPanel() or not GameStatus.IsInLobbyOrMainCity() then
    return false
  end
  return Refresh.BShowbLbsMain() and SettingSystem.IsOpenLBSNear()
end
function Refresh.RefreshbLBSNear(key)
  local root = Key2Widget(key)
  if not root then
    return
  end
  local show = Refresh.BShowbLBSNear()
  UIUtil.SetWidgetVisible(root, show)
  if show then
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, GetOneSettingValue(key))
  end
end
function Refresh.OnClickbLBSNear(key)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  CfgConvertNot(key)
  local LBSHandler = require("client.network.Protocol.LBSHandler")
  local nOpen = GetOneSettingValue(key) and 1 or 2
  local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
  LBSHandler.send_lbs_set_privacy_req(LbsMgr.SETTING_CFG_NEAR_ID, nOpen)
  Refresh["Refresh" .. key](key)
end
function Refresh.BShowbLbsChat()
  if IsWoWEditor then
    return false
  end
  local SettingSystem = require("client.logic.setting.logic_setting")
  if SettingSystem.IsHideLBSPanel() or not GameStatus.IsInLobbyOrMainCity() then
    return false
  end
  return Refresh.BShowbLbsMain() and SettingSystem.IsOpenLBSChat()
end
function Refresh.RefreshbLbsChat(key)
  local root = Key2Widget(key)
  if not root then
    return
  end
  local show = Refresh.BShowbLbsChat()
  UIUtil.SetWidgetVisible(root, show)
  if show then
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, GetOneSettingValue(key))
  end
end
function Refresh.OnClickbLbsChat(key)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  CfgConvertNot(key)
  local LBSHandler = require("client.network.Protocol.LBSHandler")
  local nOpen = GetOneSettingValue(key) and 1 or 2
  local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
  LBSHandler.send_lbs_set_privacy_req(LbsMgr.SETTING_CFG_CHAT_ID, nOpen)
  Refresh["Refresh" .. key](key)
end
function Refresh.BShowbLBSWarZone()
  if IsWoWEditor then
    return false
  end
  local SettingSystem = require("client.logic.setting.logic_setting")
  if SettingSystem.IsHideLBSPanel() or not GameStatus.IsInLobbyOrMainCity() then
    return false
  end
  return Refresh.BShowbLbsMain() and SettingSystem.IsOpenLBSWarZone()
end
function Refresh.RefreshbLBSWarZone(key)
  local root = Key2Widget(key)
  if not root then
    return
  end
  local show = Refresh.BShowbLBSWarZone()
  UIUtil.SetWidgetVisible(root, show)
  if show then
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, GetOneSettingValue(key))
  end
end
function Refresh.OnClickbLBSWarZone(key)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  CfgConvertNot(key)
  local LBSHandler = require("client.network.Protocol.LBSHandler")
  local nOpen = GetOneSettingValue(key) and 1 or 2
  local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
  LBSHandler.send_lbs_set_privacy_req(LbsMgr.SETTING_CFG_WARZONE_ID, nOpen)
  Refresh["Refresh" .. key](key)
end
function Refresh.BShowbLBSPlace()
  if IsWoWEditor then
    return false
  end
  local SettingSystem = require("client.logic.setting.logic_setting")
  if SettingSystem.IsHideLBSPanel() or not GameStatus.IsInLobbyOrMainCity() then
    return false
  end
  return Refresh.BShowbLbsMain()
end
function Refresh.RefreshbLBSPlace(key)
  local root = Key2Widget(key)
  local show = Refresh.BShowbLBSPlace()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  if root then
    UIUtil.SetWidgetVisible(root, show)
    if show then
      LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, RoleInfoSystem.bLBSPlace)
    end
  end
  return RoleInfoSystem.bLBSPlace
end
function Refresh.OnClickbLBSPlace()
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local switch = not RoleInfoSystem.bLBSPlace
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_set_lbs_privacy_req(switch)
end
function Refresh.BShowDoubleEvaluation()
  local logic_team_evaluation_view = require("client.slua.logic.team_evaluation.logic_team_evaluation_view")
  return logic_team_evaluation_view.GetEntranceSettingType() ~= 0
end
function Refresh.RefreshDoubleEvaluation(key)
  local logic_team_evaluation_view = require("client.slua.logic.team_evaluation.logic_team_evaluation_view")
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    local SettingValue = 0
    if logic_team_evaluation_view.bShowEvaluation == 1 then
      SettingValue = 2
    elseif logic_team_evaluation_view.bShowEvaluation == 2 then
      SettingValue = 1
    elseif logic_team_evaluation_view.bShowEvaluation == 3 then
      SettingValue = 0
    elseif logic_team_evaluation_view.bShowEvaluation == true then
      SettingValue = 2
    elseif logic_team_evaluation_view.bShowEvaluation == false or not logic_team_evaluation_view.bShowEvaluation then
      SettingValue = 1
    end
    RefreshFriendsOnly(key, SettingValue)
    return SettingValue
  else
    local root = Key2Widget(key)
    UIUtil.SetWidgetVisible(root, Refresh.BShowDoubleEvaluation())
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, logic_team_evaluation_view.bShowEvaluation)
    return logic_team_evaluation_view.bShowEvaluation and 1 or 2
  end
end
function Refresh.OnClickDoubleEvaluation(key, index)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  local logic_team_evaluation_view = require("client.slua.logic.team_evaluation.logic_team_evaluation_view")
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    if index == 1 then
      index = 2
    elseif index == 2 then
      index = 1
    elseif index == 3 then
      index = 3
    end
    logic_team_evaluation_view.bShowEvaluation = index
    logic_team_evaluation_view.send_set_evaluation_privacy(logic_team_evaluation_view.bShowEvaluation)
  else
    local privacy_type = not logic_team_evaluation_view.bShowEvaluation
    local typeNum = 1
    if privacy_type == true then
      typeNum = 2
    end
    logic_team_evaluation_view.send_set_evaluation_privacy(typeNum)
  end
end
function Refresh.BShowDoublePublicCareer()
  local CareerSystem = require("client.slua.logic.career.logic_career")
  return CareerSystem.IsOpen() and GameStatus.IsInLobbyOrMainCity()
end
function Refresh.RefreshDoublePublicCareer(key)
  local root = Key2Widget(key)
  local CareerSystem = require("client.slua.logic.career.logic_career")
  local show = Refresh.BShowDoublePublicCareer()
  UIUtil.SetWidgetVisible(root, show)
  log(bWriteLog and "  :CareerSystem.bPublicShow" .. tostring(CareerSystem.bPublicShow))
  LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, CareerSystem.bPublicShow)
end
function Refresh.OnClickDoublePublicCareer(key)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  local CareerSystem = require("client.slua.logic.career.logic_career")
  CareerSystem.ReqCareerSetPublic()
  Refresh.RefreshDoublePublicCareer(key)
end
function Refresh.RefreshDoubleNotFriendInvite(key)
  local root = Key2Widget(key)
  local nReceiveNonFriend = DataMgr.roleData.receive_nonfriend_team_request
  if root then
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, nReceiveNonFriend == 1)
  end
  return nReceiveNonFriend == 1
end
function Refresh.OnClickDoubleNotFriendInvite(key)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  local nPreValue = DataMgr.roleData.receive_nonfriend_team_request
  log(bWriteLog and "OnClickNotFriendInvite() receive_nonfriend_team_request = ", nPreValue)
  if nPreValue ~= 0 and nPreValue ~= 1 then
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if nPreValue == 1 then
    TeamUpNewSystem.set_receive_nonfriend_team_request(0)
    DataMgr.roleData.receive_nonfriend_team_request = 0
  else
    TeamUpNewSystem.set_receive_nonfriend_team_request(1)
    DataMgr.roleData.receive_nonfriend_team_request = 1
  end
  Refresh.RefreshDoubleNotFriendInvite(key)
end
function Refresh.BShowDoubleWatchingOpen()
  local LogicLobbyWatching = require("client.logic.watching.logic_lobby_watching")
  local AccessRestrictionSystem = require("client.logic.common.logic_access_restriction")
  return LogicLobbyWatching.IsWatchingPrivacyOpen() and LogicLobbyWatching.IsWatchingOpen() and AccessRestrictionSystem.CheckAccess(AccessRestrictionSystem.EAccessType.FriendWatch)
end
function Refresh.RefreshDoubleWatchingOpen(key)
  local root = Key2Widget(key)
  LogicSettingBasic.bShowWatching = DataMgr.IsEnableWatch()
  if root then
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, LogicSettingBasic.bShowWatching == 1)
    UIUtil.SetWidgetVisible(root, Refresh.BShowDoubleWatchingOpen(), true)
  end
  return LogicSettingBasic.bShowWatching == 1
end
function Refresh.OnClickDoubleWatchingOpen(key)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  LogicSettingBasic.bShowWatching = (LogicSettingBasic.bShowWatching + 1) % 2
  DataMgr.SetEnableWatch(LogicSettingBasic.bShowWatching)
  local LogicLobbyWatching = require("client.logic.watching.logic_lobby_watching")
  LogicLobbyWatching.send_show_watching(LogicSettingBasic.bShowWatching)
  Refresh.RefreshDoubleWatchingOpen(key)
end
function Refresh.RefreshDoubleReserve(key)
  local root = Key2Widget(key)
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  local isOpen = logic_friend_reserve.nAllowReserveFlag == 1
  if root then
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, isOpen)
  end
  return isOpen
end
function Refresh.OnClickDoubleReserve()
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  local flag = 1
  if logic_friend_reserve.nAllowReserveFlag == 1 then
    flag = 0
  else
    flag = 1
  end
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  FriendHandler.send_modify_friend_appointment_privacy_req(flag)
end
function Refresh.RefreshDoublePopularGiftPK(key)
  local logic_popular_gift_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_gift_pk)
  local resViewPKSwitch = logic_popular_gift_pk.resViewPKSwitch
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    local SettingValue = RefreshFriendsOnlyValue(resViewPKSwitch)
    RefreshFriendsOnly(key, SettingValue)
    return SettingValue
  else
    local root = Key2Widget(key)
    if resViewPKSwitch == nil or resViewPKSwitch == 0 then
      LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, false)
    else
      LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, true)
    end
    return resViewPKSwitch
  end
end
function Refresh.OnClickDoublePopularGiftPK(key, index)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    if index == 1 then
      index = 1
    elseif index == 2 then
      index = 0
    elseif index == 3 then
      index = 2
    end
    local SettingHandler = require("client.network.Protocol.SettingHandler")
    SettingHandler.send_set_psmatch_view_pk_switch(index)
  else
    local logic_popular_gift_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_gift_pk)
    local resViewPKSwitch = logic_popular_gift_pk.resViewPKSwitch
    local SettingHandler = require("client.network.Protocol.SettingHandler")
    if resViewPKSwitch == nil or resViewPKSwitch == 0 then
      SettingHandler.send_set_psmatch_view_pk_switch(1)
    else
      SettingHandler.send_set_psmatch_view_pk_switch(0)
    end
  end
end
function Refresh.RefreshCollectionHallVisit(key)
  log(bWriteLog and string.format("[114514] Refresh.RefreshCollectionHallPrivacy"))
  local CollectionHallVisitPrivacyTool = require("client.slua.logic.CollectionHall.CollectionHallVisitPrivacyTool")
  local collectionHallVisitorPrivacy = CollectionHallVisitPrivacyTool.GetPlayerVisitPrivacy()
  local root = Key2Widget(key)
  if not root then
    return
  end
  UIUtil.SetWidgetVisible(root.status_off1, collectionHallVisitorPrivacy ~= 0)
  UIUtil.SetWidgetVisible(root.status_on1, collectionHallVisitorPrivacy == 0)
  UIUtil.SetWidgetVisible(root.status_off2, collectionHallVisitorPrivacy ~= 1)
  UIUtil.SetWidgetVisible(root.status_on2, collectionHallVisitorPrivacy == 1)
  UIUtil.SetWidgetVisible(root.status_off3, collectionHallVisitorPrivacy ~= 2)
  UIUtil.SetWidgetVisible(root.status_on3, collectionHallVisitorPrivacy == 2)
end
function Refresh.OnClickCollectionHallVisit(key, index)
  log(bWriteLog and string.format("[114514] Refresh.OnClickCollectionHallPrivacy"))
  PlaySound()
  local CollectionHallVisitPrivacyTool = require("client.slua.logic.CollectionHall.CollectionHallVisitPrivacyTool")
  local collectionHallVisitorPrivacy = CollectionHallVisitPrivacyTool.GetPlayerVisitPrivacy()
  if index == collectionHallVisitorPrivacy then
    log(bWriteLog and string.format("[114514] Refresh.OnClickCollectionHallVisit already in target setting, jump out"))
    return
  end
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_set_collect_hall_visit_privacy_req(index)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  local TLogReasonStr = json.encode({
    uid = DataMgr.roleData.uid or 0,
    slotIndex = index or 0
  })
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.PrivacyPolicyForCollectionGallery, 0, TLogReasonStr)
end
function Refresh.BShowDoubleSouvenirs()
  if IsWoWEditor then
    return false
  end
  local logic_xmission_entrance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_entrance)
  if not logic_xmission_entrance:IsTxMissionOpen() then
    return false
  end
  if not LobbySystem.CheckOpen(BP_ENUM_SWITCH_SOUVENIRS) then
    log(bWriteLog and "Refresh.BShowDoubleSouvenirsShow, return false because of switch is closed")
    return false
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if not LogicTxMissionMain.IsInXMission() then
    return false
  end
  return true
end
function Refresh.RefreshDoubleSouvenirs(key)
  local root = Key2Widget(key)
  local logic_xmission_souvenirs = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_souvenirs)
  local state = logic_xmission_souvenirs:GetPrivacySwitchState()
  if root then
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, state)
  end
  return state
end
function Refresh.OnClickDoubleSouvenirs()
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  local logic_xmission_souvenirs = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_souvenirs)
  local TxMissionSouvenirsHandler = require("client.network.Protocol.TxMissionSouvenirsHandler")
  if logic_xmission_souvenirs:GetPrivacySwitchState() then
    TxMissionSouvenirsHandler.send_metro_set_souvenir_invisible_req(true)
  else
    TxMissionSouvenirsHandler.send_metro_set_souvenir_invisible_req(false)
  end
end
local ERelation = {
  Love = 2,
  Gay = 1,
  Buddies = 3,
  Sisters = 4,
  Family = 5
}
local RefreshSecrecySetting = function(Switcher, index)
  local SecrecySystemData = require("client.slua.logic.roleInfo.secrecy_data")
  local bOn = SecrecySystemData.GetOneSwitch(index)
  log(bWriteLog and "  : index" .. tostring(index))
  log(bWriteLog and "  : bOn" .. tostring(bOn))
  LogicSettingBasic.SetSwitcherAnim(Switcher, bOn)
  if index ~= 0 then
    local bTotalOn = SecrecySystemData.GetOneSwitch(0)
    if bTotalOn then
      Switcher:SetSwitcherEnable(true)
    else
      Switcher:SetSwitcherEnable(false)
    end
  end
end
local Relation2RoleInfo = {
  ERelation.Love,
  ERelation.Gay,
  ERelation.Buddies,
  ERelation.Sisters,
  ERelation.Family
}
function Refresh.OnUpdateRelationData()
  Refresh.RefreshRelation("Relation")
end
function Refresh.RefreshRelation(key)
  log(bWriteLog and string.format("  : Refresh.RefreshRelation key:%s", key))
  local SecrecySystemData = require("client.slua.logic.roleInfo.secrecy_data")
  local bTotalOn = SecrecySystemData.GetOneSwitch(0)
  local nReturn = 0
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    local SettingValue = RefreshFriendsOnlyValue(SecrecySystemData.GetOneSwitch(0))
    RefreshFriendsOnly(key, SettingValue)
    nReturn = SettingValue
  else
    nReturn = (bTotalOn == 0 or bTotalOn == false) and 1 or 0
    local root = Key2Widget(key)
    if not root then
      return nReturn
    end
    RefreshSecrecySetting(root.Setting_Switch, 0)
  end
  local subItems = SettingCfg[key].subItems
  for index, subName in pairs(subItems) do
    log(bWriteLog and "  :subName" .. tostring(subName))
    if Key2Widget(subName) then
      RefreshSecrecySetting(Key2Widget(subName).Setting_Switch, Relation2RoleInfo[index])
    end
  end
  if subItems then
    local visibility
    if bTotalOn == 0 or bTotalOn == false then
      visibility = UIUtil.BoolToVisible(false)
    else
      visibility = UIUtil.BoolToVisible(true)
    end
    for _, subName in pairs(subItems) do
      if Key2Widget(subName) then
        Key2Widget(subName):SetWidgetVisibility(visibility)
      end
    end
    log(bWriteLog and "    RefreshRelation SetWidgetVisibility:bTotalOn" .. tostring(bTotalOn))
    log(bWriteLog and "  : RefreshOneOverLayHeight " .. key)
    local SettingSystem = require("client.logic.setting.logic_setting")
    SettingSystem.RefreshOneOverLayHeight(key)
  end
  return nReturn
end
function Refresh.GetbShowSubRelation(key)
  local SecrecySystemData = require("client.slua.logic.roleInfo.secrecy_data")
  return SecrecySystemData.GetOneSwitch(0)
end
local ClickOneRelation = function(_, index)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  local SecrecySystemData = require("client.slua.logic.roleInfo.secrecy_data")
  SecrecySystemData.ChangeSwitch(index)
end
function Refresh.OnClickRelation(key, index)
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    if index == 1 then
      index = 1
    elseif index == 2 then
      index = 0
    elseif index == 3 then
      index = 2
    end
    local SecrecySystemData = require("client.slua.logic.roleInfo.secrecy_data")
    SecrecySystemData.ChangeSwitch(0, index)
  else
    ClickOneRelation(key, 0)
  end
end
function Refresh.OnClickRelationLove(key)
  ClickOneRelation(key, ERelation.Love)
end
function Refresh.OnClickRelationGay(key)
  ClickOneRelation(key, ERelation.Gay)
end
function Refresh.OnClickRelationBuddies(key)
  ClickOneRelation(key, ERelation.Buddies)
end
function Refresh.OnClickRelationSisters(key)
  ClickOneRelation(key, ERelation.Sisters)
end
function Refresh.OnClickRelationFamily(key)
  ClickOneRelation(key, ERelation.Family)
end
function Refresh.RefreshRelationShowOrder(key)
  local setting_refresh_RelationShowOrder = require("client.logic.setting.refresh.setting_refresh_RelationShowOrder")
  return setting_refresh_RelationShowOrder.RefreshRelationShowOrder(key)
end
function Refresh.BShowRelationShowOrder()
  local setting_refresh_RelationShowOrder = require("client.logic.setting.refresh.setting_refresh_RelationShowOrder")
  return setting_refresh_RelationShowOrder.BShowRelationShowOrder()
end
function Refresh.RefreshProfileShowFight()
  local roleData = LobbySystem.roleData.social_private_data
  if not roleData then
    return false
  end
  return roleData[2] == 1 or roleData[2] == 3
end
function Refresh.RefreshProfileShowSocial()
  local roleData = LobbySystem.roleData.social_private_data
  if not roleData then
    return false
  end
  return roleData[2] == 2 or roleData[2] == 3
end
function Refresh.BShowProfileShow()
  if IsWoWEditor then
    return false
  end
  return LobbySystem.CheckOpen(BP_ENUM_SOCIAL_INGAME_SWITCH)
end
function Refresh.RefreshProfileShow(key)
  local roleData = LobbySystem.roleData.social_private_data
  if not roleData then
    return false
  end
  local root = Key2Widget(key)
  if not root then
    return roleData[3] == 1
  end
  local isOn = roleData[3] and roleData[3] == 1 and true or false
  LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, isOn)
  root.Setting_Switch:SetSwitcherEnable(true)
  local isOpen = LobbySystem.CheckOpen(BP_ENUM_SOCIAL_INGAME_SWITCH)
  local visibility = UIUtil.BoolToVisible(isOpen)
  root:SetWidgetVisibility(visibility)
  local subItems = SettingCfg[key].subItems
  for index, subName in pairs(subItems) do
    if Key2Widget(subName) then
      Key2Widget(subName).Setting_Switch:SetSwitcherEnable(true)
      local subIsOn = false
      if index == 1 then
        subIsOn = roleData[2] == 1 or roleData[2] == 3
      else
        subIsOn = roleData[2] == 2 or roleData[2] == 3
      end
      LogicSettingBasic.SetSwitcherAnim(Key2Widget(subName).Setting_Switch, subIsOn)
    end
  end
  if subItems then
    visibility = UIUtil.BoolToVisible(isOn and isOpen)
    for _, subName in pairs(subItems) do
      if Key2Widget(subName) then
        Key2Widget(subName):SetWidgetVisibility(visibility)
      end
    end
    local SettingSystem = require("client.logic.setting.logic_setting")
    SettingSystem.RefreshOneOverLayHeight(key)
  end
  return isOn
end
function Refresh.GetbShowSubProfileShow(key)
  local roleData = LobbySystem.roleData.social_private_data
  if not roleData then
    return false
  end
  return roleData[3] and roleData[3] == 1 and true or false
end
function Refresh.OnClickProfileShow(key)
  local SettingSystem = require("client.logic.setting.logic_setting")
  if not LobbySystem.roleData.social_private_data or not LobbySystem.roleData.social_private_data[1] then
    return
  end
  local isOn = LobbySystem.roleData.social_private_data[3] ~= 1
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_set_social_private_switch_req(3, (LobbySystem.roleData.social_private_data[3] + 1) % 2)
end
function Refresh.OnClickProfileShowFight(key)
  if not LobbySystem.roleData.social_private_data or not LobbySystem.roleData.social_private_data[2] then
    return
  end
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_set_social_private_switch_req(2, LobbySystem.roleData.social_private_data[2] ~ 1)
end
function Refresh.OnClickProfileShowSocial(key)
  if not LobbySystem.roleData.social_private_data or not LobbySystem.roleData.social_private_data[2] then
    return
  end
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_set_social_private_switch_req(2, LobbySystem.roleData.social_private_data[2] ~ 2)
end
function Refresh.OnClickbCanShowUnknownPass(key)
  OnClickNormalDoubleParent(key)
  LogicSettingBasic.bUnknownPassBattleShow = LogicSettingBasic.bCanShowUnknownPass
  LogicSettingBasic.bUnknownPassRecordShow = LogicSettingBasic.bCanShowUnknownPass
  LogicSettingBasic.SendUnknownPassSwitch()
end
function Refresh.RefreshbUnknownPassRecordShow(key)
  local root = Key2Widget(key)
  log(bWriteLog and "  :LogicSettingBasic.bUnknownPassRecordShow" .. tostring(LogicSettingBasic.bUnknownPassRecordShow))
  if not root then
    return
  end
  LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, LogicSettingBasic.bUnknownPassRecordShow)
end
function Refresh.OnClickbUnknownPassRecordShow(key)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  LogicSettingBasic.bUnknownPassRecordShow = not LogicSettingBasic.bUnknownPassRecordShow
  LogicSettingBasic.SendUnknownPassSwitch()
  Refresh.RefreshbUnknownPassRecordShow(key)
end
function Refresh.RefreshbUnknownPassBattleShow(key)
  local root = Key2Widget(key)
  log(bWriteLog and "  :LogicSettingBasic.bUnknownPassBattleShow" .. tostring(LogicSettingBasic.bUnknownPassBattleShow))
  if not root then
    return
  end
  LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, LogicSettingBasic.bUnknownPassBattleShow)
end
function Refresh.OnClickbUnknownPassBattleShow(key)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  LogicSettingBasic.bUnknownPassBattleShow = not LogicSettingBasic.bUnknownPassBattleShow
  LogicSettingBasic.SendUnknownPassSwitch()
  Refresh.RefreshbUnknownPassBattleShow(key)
end
function Refresh.RefreshDoubleShowSubscribeBadge(key)
  local root = Key2Widget(key)
  log(bWriteLog and "  :LogicSettingBasic.RefreshDoubleShowSubscribeBadge" .. tostring(LogicSettingBasic.bShowSubscribeBadge))
  if not root then
    log_error("Refresh.RefreshDoubleShowSubscribeBadge Error Key Not Valid")
    return
  end
  LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, LogicSettingBasic.bShowSubscribeBadge)
end
function Refresh.OnClickDoubleShowSubscribeBadge(key)
  PlaySound()
  LogicSettingBasic.bShowSubscribeBadge = not LogicSettingBasic.bShowSubscribeBadge
  LogicSettingBasic.SendSubscribeSwich()
  Refresh.RefreshDoubleShowSubscribeBadge(key)
end
function Refresh.InitSocialData()
  local SocialIslandHandler = require("client.network.Protocol.SocialIslandHandler")
  LogicSettingBasic.bAllowFriendIsland = SocialIslandHandler.is_apply_on_info[1] == 1
  LogicSettingBasic.bAllowStrangerIsland = SocialIslandHandler.is_apply_on_info[0] == 1
end
function Refresh.RefreshDoubleAllowFriendIsland(key)
  local root = Key2Widget(key)
  Refresh.InitSocialData()
  if root then
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, LogicSettingBasic.bAllowFriendIsland)
  end
  return LogicSettingBasic.bAllowFriendIsland
end
function Refresh.OnClickDoubleAllowFriendIsland(_)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  local SocialIslandHandler = require("client.network.Protocol.SocialIslandHandler")
  if SocialIslandHandler.is_apply_on_info then
    local value = 0
    if SocialIslandHandler.is_apply_on_info[1] == 0 then
      value = 1
    end
    SocialIslandHandler.send_set_apply_onoff_req(1, value)
  end
end
function Refresh.RefreshDoubleAllowStrangerIsland(key)
  local root = Key2Widget(key)
  Refresh.InitSocialData()
  if root then
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, LogicSettingBasic.bAllowStrangerIsland)
  end
  return LogicSettingBasic.bAllowStrangerIsland
end
function Refresh.OnClickDoubleAllowStrangerIsland(_)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  local SocialIslandHandler = require("client.network.Protocol.SocialIslandHandler")
  if SocialIslandHandler.is_apply_on_info then
    local value = 0
    if SocialIslandHandler.is_apply_on_info[0] == 0 then
      value = 1
    end
    SocialIslandHandler.send_set_apply_onoff_req(0, value)
  end
end
function Refresh.RefreshDoubleAllowRecommendedFriend(key)
  local root = Key2Widget(key)
  local logic_setting_recommended = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_setting_recommended)
  if root then
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, logic_setting_recommended:GetSwitchByType(2) == 1)
  end
  return logic_setting_recommended:GetSwitchByType(2) == 1
end
function Refresh.OnClickDoubleAllowRecommendedFriend(_)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  local logic_setting_recommended = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_setting_recommended)
  local switch = ConvertedOneAndZero(logic_setting_recommended:GetSwitchByType(2))
  logic_setting_recommended:send_set_recommend_open_req(2, switch)
end
function Refresh.RefreshDoubleTeamRecommend(key)
  local root = Key2Widget(key)
  local logic_setting_recommended = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_setting_recommended)
  if root then
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, logic_setting_recommended:GetSwitchByType(3) == 1)
  end
  return logic_setting_recommended:GetSwitchByType(3) == 1
end
function Refresh.OnClickDoubleTeamRecommend(_)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  local logic_setting_recommended = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_setting_recommended)
  local switch = ConvertedOneAndZero(logic_setting_recommended:GetSwitchByType(3))
  logic_setting_recommended:send_set_recommend_open_req(3, switch)
end
function Refresh.BShowDoubleAllowChatHorn()
  if IsWoWEditor then
    return false
  end
  return LobbySystem.CheckOpen(BP_ENUM_CHAT_HORN_SWITCH)
end
function Refresh.RefreshDoubleAllowChatHorn(key)
  local root = Key2Widget(key)
  UIUtil.SetWidgetVisible(root, Refresh.BShowDoubleAllowChatHorn())
  local logic_chat_horn = require("client.slua.logic.lobby_chat.logic_chat_horn")
  if root then
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, logic_chat_horn:GetChatHornSwitch())
  end
  return logic_chat_horn:GetChatHornSwitch()
end
function Refresh.OnClickDoubleAllowChatHorn(key)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  local logic_chat_horn = require("client.slua.logic.lobby_chat.logic_chat_horn")
  logic_chat_horn:ChangeChatHornSwitch()
  Refresh.RefreshDoubleAllowChatHorn(key)
end
function Refresh.RefreshDoubleAllowFriendSeason(key)
  local root = Key2Widget(key)
  if root then
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, LogicSettingBasic.bSeasonFriendDataPrivacy)
  end
  return LogicSettingBasic.bSeasonFriendDataPrivacy
end
function Refresh.OnClickDoubleAllowFriendSeason(key)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  LogicSettingBasic.bSeasonFriendDataPrivacy = not LogicSettingBasic.bSeasonFriendDataPrivacy
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  SeasonHandler.send_set_season_reward_head_frame_privacy(LogicSettingBasic.bSeasonFriendDataPrivacy)
  Refresh.RefreshDoubleAllowFriendSeason(key)
end
function Refresh.BShowDoubleAllowPushNight()
  if IsWoWEditor then
    return false
  end
  local IntlHelper = import("IntlHelper")
  return FuncUtil.IsPlayerJPKR() and IntlHelper.IsRemoteNotificationsEnabled()
end
function Refresh.RefreshDoubleAllowPushNight(key)
  local root = Key2Widget(key)
  local IntlHelper = import("IntlHelper")
  local strNightTag = IntlHelper.GetSavedXGPushNightTag()
  local show = Refresh.BShowDoubleAllowPushNight()
  UIUtil.SetWidgetVisible(root, show)
  LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, strNightTag == "night_on")
  local SettingSystem = require("client.logic.setting.logic_setting")
  local overlay = SettingSystem.Key2Overlay(key)
  UIUtil.SetWidgetVisible(overlay, show)
end
function Refresh.OnClickDoubleAllowPushNight(key)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  local root = Key2Widget(key)
  Refresh.RefreshDoubleAllowPushNight(key)
  local IntlHelper = import("IntlHelper")
  local strNightTag = IntlHelper.GetSavedXGPushNightTag()
  log(bWriteLog and "  :strNightTag" .. tostring(strNightTag))
  local SettingSystem = require("client.logic.setting.logic_setting")
  if strNightTag == "night_on" then
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, false)
    SettingSystem.nPushResId = 4982
  elseif strNightTag == "night_off" then
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, true)
    SettingSystem.nPushResId = 4981
  end
  IntlHelper.UpdateXGPushNightTag(false)
  SettingSystem.ShowXGPushOpenTip()
end
function Refresh.BShowDoubleAllowPush()
  if IsWoWEditor then
    return false
  end
  return FuncUtil.IsPlayerJPKR()
end
function Refresh.RefreshDoubleAllowPush(key)
  local root = Key2Widget(key)
  local IntlHelper = import("IntlHelper")
  local enabled = IntlHelper.IsRemoteNotificationsEnabled()
  log(bWriteLog and "[SY]Refresh.RefreshDoubleAllowPush." .. tostring(key) .. "Enable" .. tostring(enabled))
  LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, enabled)
  UIUtil.SetWidgetVisible(root, Refresh.BShowDoubleAllowPush())
end
function Refresh.OnClickDoubleAllowPush(_)
  log(bWriteLog and "[SY]Refresh.OnClickDoubleAllowPush.")
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  LogicSettingBasic.bIsClickPushButton = true
  local IntlHelper = import("IntlHelper")
  IntlHelper.DirectToNotificationSetup()
end
function Refresh.BShowDoubleTimeDisplay()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  return Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE
end
function Refresh.RefreshDoubleTimeDisplay(key)
  local root = Key2Widget(key)
  local SettingTimeDisplay = require("client.logic.setting.logic_setting_time_display")
  local showText = LocUtil.LocalizeResFormat("25262", SettingTimeDisplay.dateFormat)
  root.TextBlock_Title:SetText(showText)
  local show = Refresh.BShowDoubleTimeDisplay()
  UIUtil.SetWidgetVisible(root, show)
  return show
end
function Refresh.OnClickDoubleTimeDisplay(_)
  PlaySound()
  UIManager.ShowUI(UIManager.UI_Config.setting_change_timedisplay)
end
function Refresh.BShowDoubleMatchServer()
  return false
end
local SetMatchServer = function(widget, value, isClick)
  local show = value or false
  local endTime = widget.NewAnimation_Switch:GetEndTime()
  if show then
    if isClick then
      widget:PlayUserWidgetAnimation(widget.NewAnimation_Switch, 0, 1, 1, 1)
    else
      widget:PlayUserWidgetAnimation(widget.NewAnimation_Switch, endTime, 1, 1, 1)
    end
  elseif isClick then
    widget:PlayUserWidgetAnimation(widget.NewAnimation_Switch, 0, 1, 0, 1)
  else
    widget:PlayUserWidgetAnimation(widget.NewAnimation_Switch, endTime, 1, 0, 1)
  end
end
function Refresh.RefreshDoubleMatchServer(key)
  local root = Key2Widget(key)
  UIUtil.SetWidgetVisible(root, Refresh.BShowDoubleMatchServer())
  SetMatchServer(root.Setting_Switch, DataMgr.JPKRMatchServerOn or false)
end
function Refresh.OnClickDoubleMatchServer(key)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  local MatchServer = not DataMgr.JPKRMatchServerOn or false
  local root = Key2Widget(key)
  SetMatchServer(root.Setting_Switch, MatchServer, true)
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_switch_krjp_match_cross(MatchServer)
end
function Refresh.RefreshLeftHandFire(key)
  RefreshNormalTreble120(key)
end
function Refresh.OnClickLeftHandFire(key, index)
  OnClickNormalTreble120(key, index)
end
function Refresh.OnClickFocalLengthModifySwitch(key)
  PlaySound()
  CfgConvertNot(key)
  RefreshNormalDoubleVWord(key)
end
function Refresh.RefreshbCloseHitHeadAudio(key)
  local root = Key2Widget(key)
  local bCloseHitHeadAudio = GetOneSettingValue(key)
  LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, not bCloseHitHeadAudio)
end
function Refresh.OnClickbCloseHitHeadAudio(key)
  PlaySound()
  CfgConvertNot(key)
  Refresh["Refresh" .. key](key)
end
function Refresh.OnClickHelpbConsumeThrow()
  PlaySound()
  LogicSettingBasic.ShowThrowTips(4)
end
function Refresh.RefreshAutoFollowJump(key)
  local root = Key2Widget(key)
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  SettingAccount.ForbidFollowJump = true
  if DataMgr.GetRoleSetting(RoleSettingType.ForbidParachuteFollow) == 0 then
    SettingAccount.ForbidFollowJump = false
  end
  LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, not SettingAccount.ForbidFollowJump)
end
function Refresh.OnClickAutoFollowJump(key)
  PlaySound()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  RoleInfoSystem.SetRoleInfoSettingSwitch(RoleSettingType.ForbidParachuteFollow)
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  SettingAccount.ForbidFollowJump = not SettingAccount.ForbidFollowJump
  local root = Key2Widget(key)
  LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, not SettingAccount.ForbidFollowJump)
end
function Refresh.RefreshJoystickSprintSensitity(key)
  local root = Key2Widget(key)
  local value = GetOneSettingValue(key)
  local cfg = SettingCfg[key]
  value = FuncUtil.Clamp(value, cfg.min, cfg.max)
  local sliderValue = (value - cfg.min) / (cfg.max - cfg.min)
  root.CommonSlider:SetValue(sliderValue)
  root.NumDelta:SetValue(value, true)
  root.TextBlock_Value:SetText(value .. "%")
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.JoystickSprintSensitity then
    uPlayerController.JoystickSprintSensitity = value
  end
end
function Refresh.OnValueChangedSliderJoystickSprintSensitity(key, nValue)
  SetOneSettingValue(key, math.floor(nValue * 100))
  Refresh.RefreshJoystickSprintSensitity(key)
end
local RefreshSlider = function(key)
  local root = Key2Widget(key)
  local cfg = SettingCfg[key]
  local value = GetOneSettingValue(key)
  log(bWriteLog and "  :value" .. tostring(value))
  log(bWriteLog and "  :cfg.min" .. tostring(cfg.min))
  log(bWriteLog and "  :cfg.max" .. tostring(cfg.max))
  value = FuncUtil.Clamp(value, cfg.min, cfg.max)
  local sliderValue = (value - cfg.min) / (cfg.max - cfg.min)
  log(bWriteLog and "  :sliderValue" .. tostring(sliderValue))
  root.CommonSlider:SetValue(sliderValue)
  local bIsPercent = true
  if cfg.bIsPercent ~= nil then
    bIsPercent = cfg.bIsPercent
  end
  root.NumDelta:SetValue(value, bIsPercent)
  root.TextBlock_Value:SetText(value)
end
function Refresh.RefreshTpViewValue(key)
  RefreshSlider(key)
end
function Refresh.RefreshFpViewValue(key)
  RefreshSlider(key)
end
local SwitcherColor = {
  Normal = FLinearColor(1, 1, 1, 1),
  Disable = FLinearColor(0.2, 0.2, 0.2, 1)
}
function Refresh.GetnShowSubGyroscope(key)
  local SettingValue = GetOneSettingValue(key)
  local canShowSub = Client.IsDeviceSupportGyrSensor() and SettingValue ~= 0
  return canShowSub
end
function Refresh.RefreshGyroscope(key)
  local root = Key2Widget(key)
  local SettingValue = GetOneSettingValue(key)
  local canShowSub = Client.IsDeviceSupportGyrSensor() and SettingValue ~= 0
  if not root then
    return
  end
  if Client.IsDeviceSupportGyrSensor() then
    UIUtil.SetWidgetVisible(root.status_off3, SettingValue ~= 0)
    UIUtil.SetWidgetVisible(root.status_on3, SettingValue == 0)
    UIUtil.SetWidgetVisible(root.status_off1, SettingValue ~= 1)
    UIUtil.SetWidgetVisible(root.status_on1, SettingValue == 1)
    UIUtil.SetWidgetVisible(root.status_off2, SettingValue ~= 2)
    UIUtil.SetWidgetVisible(root.status_on2, SettingValue == 2)
    root.Border_Switcher:SetContentColorAndOpacity(SwitcherColor.Normal)
  else
    UIUtil.SetWidgetVisible(root.status_off3, false)
    UIUtil.SetWidgetVisible(root.status_on3, true)
    UIUtil.SetWidgetVisible(root.status_off1, true)
    UIUtil.SetWidgetVisible(root.status_on1, false)
    UIUtil.SetWidgetVisible(root.status_off2, true)
    UIUtil.SetWidgetVisible(root.status_on2, false)
    root.Border_Switcher:SetContentColorAndOpacity(SwitcherColor.Disable)
  end
  if canShowSub then
    RefreshSubKeys(key)
  end
  local subItems = SettingCfg[key].subItems
  for _, subName in pairs(subItems) do
    if SettingCfg[subName] and SettingCfg[subName].RefreshFunc and Refresh[SettingCfg[subName].RefreshFunc] then
      Refresh[SettingCfg[subName].RefreshFunc](key)
    else
      UIUtil.SetWidgetVisible(Key2Widget(subName), canShowSub)
    end
  end
  Refresh.ToggleRedDisplay(key, SettingCfg[key].RedInSub and not canShowSub)
end
function Refresh.RefreshHoldGrenadeStateEnableGyro(key)
  local SettingValue = GetOneSettingValue(key)
  local canShowSub = Client.IsDeviceSupportGyrSensor() and SettingValue == 2
  UIUtil.SetWidgetVisible(Key2Widget("HoldGrenadeStateEnableGyro"), canShowSub)
end
function Refresh.OnClickGyroscope(Key, Index, TargetItem, LogicUIBase)
  PlaySound()
  if not Client.IsDeviceSupportGyrSensor() then
    ShowNotice(9891)
  else
    local SettingValue = Index % 3
    EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_GYROSCOPE_CHANGE, SettingValue)
    SetOneSettingValue(Key, SettingValue)
    Refresh.RefreshGyroscope(Key)
    local SettingSystem = require("client.logic.setting.logic_setting")
    SettingSystem.RefreshOneOverLayHeight(Key)
    SettingSystem._ShowItemTreble(TargetItem, Key, LogicUIBase)
  end
end
function Refresh.OnClickbSeperateShootMBtn(key)
  OnClickNormalDoubleVWord(key)
end
function Refresh.RefreshbSeperateShootMBtn(key)
  RefreshNormalDoubleVWord(key)
end
function Refresh.BShowTitleRecording()
  return Refresh.BShowbRecordWonderfulReplayOpen() and Refresh.BShowDeathPlaybackSwitch() and Refresh.BShowbUserSaveWonderfulReplaySwitch()
end
function Refresh.BShowbRecordWonderfulReplayOpen()
  return GameStatus.IsInLobbyOrMainCity() and LobbySystem.CheckOpen(BP_ENUM_WONDERFUL_REPLAY_SWITCH)
end
function Refresh.BShowDeathPlaybackSwitch()
  local isLobby = GameStatus.IsInLobbyOrMainCity()
  local show = false
  local GameInstance = UIUtil.GetGameInstance()
  if slua.isValid(GameInstance) and GameInstance.GetDeathPlayback ~= nil then
    local playBack = GameInstance:GetDeathPlayback()
    if slua.isValid(playBack) then
      show = not playBack:IsSwitchedOffByDevice()
    end
  end
  return isLobby and show
end
function Refresh.BShowbUserSaveWonderfulReplaySwitch()
  return GameStatus.IsInLobbyOrMainCity()
end
function Refresh.BShowLowTickRateInSpectating()
  return GameStatus.IsInLobbyOrMainCity()
end
function Refresh.RefreshbRecordWonderfulReplayOpen(key)
  local root = Key2Widget(key)
  local show = Refresh["BShow" .. key]()
  UIUtil.SetWidgetVisible(root, show)
  if show then
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, GetOneSettingValue(key))
  end
end
function Refresh.OnClickbRecordWonderfulReplayOpen(key)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  local version_util = require("client.common.version_util")
  local ClientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  log(bWriteLog and "OnClickbRecordWonderfulReplayOpen " .. ClientVersion)
  local SettingSystem = require("client.logic.setting.logic_setting")
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_save_custom_settings_new_req(SettingSystem.SettingSwitchOpVersion, ClientVersion)
  CfgConvertNot(key)
  Refresh.RefreshbRecordWonderfulReplayOpen(key)
end
function Refresh.BShowTitleMetroFashionShow()
  if IsWoWEditor then
    return false
  end
  return GameStatus.IsInLobbyOrMainCity()
end
function Refresh.BShowMetroFashionLobbySwitcher()
  if IsWoWEditor then
    return false
  end
  return GameStatus.IsInLobbyOrMainCity()
end
function Refresh.RefreshMetroFashionLobbySwitcher(key)
  local root = Key2Widget(key)
  local show = GameStatus.IsInLobbyOrMainCity()
  UIUtil.SetWidgetVisible(root, show)
  if show then
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, GetOneSettingValue(key))
  end
end
function Refresh.OnClickMetroFashionLobbySwitcher(key)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  local value = CfgConvertNot(key)
  SetOneSettingValue(key, value)
  Refresh.RefreshMetroFashionLobbySwitcher(key)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbyMetroFashionSettingClick, nil, tostring(value))
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if not LogicTxMissionMain.IsInXMission(true) then
    return
  end
  local LogicTxMissionTeam = require("client.slua.logic.TxMission.logic_xmission_team")
  local avatarInfo = LogicTxMissionTeam.GetAvatarInfo()
  for uid, info in pairs(avatarInfo) do
    LogicTxMissionTeam.UpdateAvatar(uid)
  end
end
function Refresh.BShowMetroFashionGameSwitcher()
  return not IsWoWEditor
end
function Refresh.RefreshMetroFashionGameSwitcher(key)
  local root = Key2Widget(key)
  local show = GameStatus.IsInLobbyOrMainCity()
  UIUtil.SetWidgetVisible(root, show)
  if show then
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, GetOneSettingValue(key))
  end
end
function Refresh.OnClickMetroFashionGameSwitcher(key)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  local value = CfgConvertNot(key)
  SetOneSettingValue(key, value)
  Refresh.RefreshMetroFashionGameSwitcher(key)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.GameMetroFashionSettingClick, nil, tostring(value))
end
function Refresh.BShowShowBirthdaySwitch()
  if IsWoWEditor then
    return false
  end
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    return false
  else
    return true
  end
end
function Refresh.RefreshShowBirthdaySwitch(key)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    local SettingValue = RefreshFriendsOnlyValue(RoleInfoSystem.ShowBirthdaySwitch)
    RefreshFriendsOnly(key, SettingValue)
    return SettingValue
  else
    local root = Key2Widget(key)
    Refresh.InitSocialData()
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, RoleInfoSystem.ShowBirthdaySwitch)
    return RoleInfoSystem.ShowBirthdaySwitch
  end
end
function Refresh.OnClickShowBirthdaySwitch(key, index)
  PlaySound()
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    if index == 1 then
      index = 1
    elseif index == 2 then
      index = 0
    elseif index == 3 then
      index = 2
    end
    local switch = index
    local SettingHandler = require("client.network.Protocol.SettingHandler")
    SettingHandler.send_set_birthday_privacy_req(switch)
  else
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    local switch = not RoleInfoSystem.ShowBirthdaySwitch
    local SettingHandler = require("client.network.Protocol.SettingHandler")
    SettingHandler.send_set_birthday_privacy_req(switch)
  end
end
function Refresh.BShowBattleNewSwitch()
  local logic_newbie_assist = require("client.slua.logic.activity.newbie.logic_newbie_assist")
  return logic_newbie_assist.CheckIsNewBie() and logic_newbie_assist.IsBattleSwtichMenuOpen()
end
function Refresh.RefreshBattleNewSwitch(key)
  local root = Key2Widget(key)
  local show = Refresh["BShow" .. key]()
  UIUtil.SetWidgetVisible(root, show)
  if show then
    local logic_newbie_assist = require("client.slua.logic.activity.newbie.logic_newbie_assist")
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, logic_newbie_assist.GetBattleSwitchState())
  end
end
function Refresh.OnClickBattleNewSwitch(key)
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  local logic_newbie_assist = require("client.slua.logic.activity.newbie.logic_newbie_assist")
  local isOpen = logic_newbie_assist.GetBattleSwitchState()
  logic_newbie_assist.SetBattleSwitch(not isOpen)
  Refresh.RefreshBattleNewSwitch(key)
end
function Refresh.OnClickHelpRingThrowSwitch()
  PlaySound()
  UIManager.ShowUI(UIManager.UI_Config.Throw_Tips_UIBP, 1)
end
function Refresh.OnClickHelpRingThrowPressSwitch()
  PlaySound()
  UIManager.ShowUI(UIManager.UI_Config.Throw_Tips_UIBP, 2)
end
function Refresh.OnClickHelpbHideIngameUIAvailable()
  PlaySound()
  LogicSettingBasic.ShowThrowTips(3)
end
function Refresh.OnClickHelpOldMarkStyle()
  PlaySound()
  UIManager.ShowUI(UIManager.UI_Config.Seeting_TwoPicturesPopup_UIBP, 1)
end
function Refresh.OnClickHelpSoundVisualizationType()
  PlaySound()
  UIManager.ShowUI(UIManager.UI_Config.Seeting_TwoPicturesPopup_UIBP, 2)
end
function Refresh.BShowDoubleSeasonLookBackShow()
  if IsWoWEditor then
    return false
  end
  local logic_season_lookback = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_lookback)
  if logic_season_lookback:GetEntranceSwitch() then
    return true
  else
    return false
  end
end
function Refresh.RefreshDoubleSeasonLookBackShow(key)
  local root = Key2Widget(key)
  if not root then
    local logic_season_lookback = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_lookback)
    local privacy = logic_season_lookback:GetEntrancePrivacy()
    return privacy
  end
  local show = Refresh.BShowDoubleSeasonLookBackShow()
  UIUtil.SetWidgetVisible(root, show)
  if show then
    local logic_season_lookback = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_lookback)
    local privacy = logic_season_lookback:GetEntrancePrivacy()
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, privacy)
    return privacy
  else
    return false
  end
end
function Refresh.OnClickDoubleSeasonLookBackShow()
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  local logic_season_lookback = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_lookback)
  local privacy = logic_season_lookback:GetEntrancePrivacy()
  local SeasonLookBackHandler = require("client.network.Protocol.SeasonLookBackHandler")
  SeasonLookBackHandler.send_set_season_lookback_privacy_req(not privacy)
end
function Refresh.BShowTeammateTakeOver()
  if IsWoWEditor then
    return false
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() or PublishRegionMacros.IsJapanOrKorea() then
    print(bWriteLog and "Refresh.ShowTeammateTakeOve BLUEHOLE or JapanOrKorea version")
    return false
  end
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  if SettingHandler.ally_ai_takeover_zones then
    local TableUtil = require("common.table_util")
    local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
    log(bWriteLog and "Refresh.BShowTeammateTakeOver nChooseZoneID = " .. tostring(ZoneSystem.nChooseZoneID))
    if TableUtil.Find(SettingHandler.ally_ai_takeover_zones, ZoneSystem.nChooseZoneID) ~= -1 then
      return true
    end
  end
  return false
end
function Refresh.RefreshInterruptReloadType(key)
  local root = Key2Widget(key)
  local InterruptReloadType = GetOneSettingValue(key)
  if not root then
    return
  end
  UIUtil.SetWidgetVisible(root.status_off3, InterruptReloadType ~= 2)
  UIUtil.SetWidgetVisible(root.status_on3, InterruptReloadType == 2)
  UIUtil.SetWidgetVisible(root.status_off1, InterruptReloadType ~= 0)
  UIUtil.SetWidgetVisible(root.status_on1, InterruptReloadType == 0)
  UIUtil.SetWidgetVisible(root.status_off2, InterruptReloadType ~= 1)
  UIUtil.SetWidgetVisible(root.status_on2, InterruptReloadType == 1)
end
function Refresh.OnClickInterruptReloadType(key, index)
  print(bWriteLog and "OnClickInterruptReloadType", index)
  PlaySound()
  SetOneSettingValue(key, index - 1)
  Refresh.RefreshInterruptReloadType(key)
end
function Refresh.OnClickDefaultMeleeWeaponType(key)
  CfgConvert1And2(key)
  local DefaultMeleeValue = GetOneSettingValue(key)
  local WeaponID = 108005
  if DefaultMeleeValue == 1 then
    WeaponID = 108001
  elseif DefaultMeleeValue == 2 then
    WeaponID = 108005
  end
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_save_player_custom_data_to_battle_req({BirthIslandMeleeItem = WeaponID})
  PlaySound()
  RefreshNormalDoubleVWord(key)
end
local RefreshCollectSettingValue = function(key)
  local root = Key2Widget(key)
  local collect_privacy_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_privacy_module)
  local privacy = collect_privacy_module:GetPrivacyData(key)
  if root then
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, privacy)
  end
  return privacy
end
local BShowCollect = function()
  if IsWoWEditor then
    return false
  end
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  return collect_module:CanShowCollect()
end
local ClickCollectSetting = function(key)
  local collect_privacy_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_privacy_module)
  collect_privacy_module:ChangePrivacySetting(key)
  PlaySound()
  Refresh.RefreshItem(key)
end
function Refresh.BShowDoubleShowCollectLevel()
  return BShowCollect()
end
function Refresh.RefreshDoubleShowCollectLevel(key)
  return RefreshCollectSettingValue(key)
end
function Refresh.OnClickDoubleShowCollectLevel(key)
  ClickCollectSetting(key)
end
function Refresh.BShowDoubleStrangerCDetail()
  return BShowCollect()
end
function Refresh.RefreshDoubleStrangerCDetail(key)
  return RefreshCollectSettingValue(key)
end
function Refresh.OnClickDoubleStrangerCDetail(key)
  ClickCollectSetting(key)
end
function Refresh.BShowDoubleFriendCDetail()
  return BShowCollect()
end
function Refresh.RefreshDoubleFriendCDetail(key)
  return RefreshCollectSettingValue(key)
end
function Refresh.OnClickDoubleFriendCDetail(key)
  ClickCollectSetting(key)
end
function Refresh.RefreshDoubleShowChatRoom(key)
  local root = Key2Widget(key)
  if root then
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, LogicSettingBasic.bShowChatRoom)
  end
  return LogicSettingBasic.bShowChatRoom
end
function Refresh.OnClickDoubleShowChatRoom(_)
  PlaySound()
  local bshow = not LogicSettingBasic.bShowChatRoom
  log(bWriteLog and "Refresh.OnClickDoubleShowChatRoom " .. tostring(bshow))
  local ChatRoomHandler = require("client.network.Protocol.ChatRoomHandler")
  ChatRoomHandler.send_set_chat_channel_status_switch_req(bshow)
end
function Refresh.RefreshWoWShow(Key)
  local bWoWShow = LogicSettingBasic.GetPrivacyWoWShow(Key)
  local Root = Key2Widget(Key)
  if not Root then
    log(bWriteLog and "[v_yibxu] Refresh.RefreshWoWShow Key = " .. Key .. " widget = nil")
    return bWoWShow
  end
  LogicSettingBasic.SetSwitcherAnim(Root.Setting_Switch, bWoWShow)
  local SubItems = SettingCfg[Key].subItems
  if bWoWShow then
    for _, SubKey in pairs(SubItems) do
      if Key2Widget(SubKey) then
        local SubShow = LogicSettingBasic.GetPrivacyWoWShow(SubKey)
        LogicSettingBasic.SetSwitcherAnim(Key2Widget(SubKey).Setting_Switch, SubShow)
      end
    end
  end
  if SubItems then
    local Visibility = UIUtil.BoolToVisible(bWoWShow)
    for _, SubKey in pairs(SubItems) do
      if Key2Widget(SubKey) then
        Key2Widget(SubKey):SetWidgetVisibility(Visibility)
      end
    end
    local SettingSystem = require("client.logic.setting.logic_setting")
    SettingSystem.RefreshOneOverLayHeight(Key)
  end
  return bWoWShow
end
function Refresh.GetbShowSubWoWShow(key)
  return LogicSettingBasic.GetPrivacyWoWShow(key)
end
local RefreshWoWSubSwitch = function(Key)
  local bShow = LogicSettingBasic.GetPrivacyWoWShow(Key)
  local Root = Key2Widget(Key)
  if Root then
    LogicSettingBasic.SetSwitcherAnim(Root.Setting_Switch, bShow)
  end
  print("RefreshWoWSubSwitch Key", Key, "bShow", bShow)
  return bShow
end
local RefreshWoWCopilotDisplay = function(Key)
  local bShow = LogicSettingBasic.GetPrivacyWoWShow(Key)
  local Root = Key2Widget(Key)
  LogicSettingBasic.SetSwitcherAnim(Root.Setting_Switch, bShow)
end
local OnClickWowSwitch = function(Key)
  PlaySound()
  print("OnClickWowSwitch Key1 ", Key)
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SettingPrivacySwitchButton) then
    return
  end
  print("OnClickWowSwitch Key", Key)
  local bShow = LogicSettingBasic.GetPrivacyWoWShow(Key)
  LogicSettingBasic.SetPrivacyWoWShow(Key, not bShow)
  LogicSettingBasic.ReqUGCSetPrivacy()
  if not Key or Key == "WoWShow" then
    Refresh.RefreshWoWShow(Key)
  else
    RefreshWoWSubSwitch(Key)
  end
end
Refresh.OnClickWoWShow = OnClickWowSwitch
Refresh.OnClickWoWPlay = OnClickWowSwitch
Refresh.OnClickWoWCollectMod = OnClickWowSwitch
Refresh.OnClickWoWHeadShwo = OnClickWowSwitch
Refresh.OnClickWoWLikeAuthor = OnClickWowSwitch
Refresh.OnClickWoWModCollectionShow = OnClickWowSwitch
Refresh.OnClickWoWPassDisplay = OnClickWowSwitch
Refresh.OnClickWoWCopilotDisplay = OnClickWowSwitch
Refresh.RefreshWoWPlay = RefreshWoWSubSwitch
Refresh.RefreshWoWCollectMod = RefreshWoWSubSwitch
Refresh.RefreshWoWHeadShwo = RefreshWoWSubSwitch
Refresh.RefreshWoWLikeAuthor = RefreshWoWSubSwitch
Refresh.RefreshWoWModCollectionShow = RefreshWoWSubSwitch
Refresh.RefreshWoWPassDisplay = RefreshWoWSubSwitch
Refresh.
function Refresh.BShowDoublePeakGameHideId()
  log(bWriteLog and "Refresh.BShowDoublePeakGameHideId")
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  if not LogicPeakGame.isShowPeakGameHideNameSelection then
    return false
  end
  log(bWriteLog and "Refresh.BShowDoublePeakGameHideId isShowPeakGameHideNameSelection = " .. tostring(LogicPeakGame.isShowPeakGameHideNameSelection))
  return true
end
function Refresh.RefreshDoublePeakGameHideId(key)
  log(bWriteLog and "Refresh.RefreshDoublePeakGameHideId key" .. tostring(key))
  local root = Key2Widget(key)
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  if LogicPeakGame.peakgameHideName ~= 0 then
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, true)
  else
    LogicSettingBasic.SetSwitcherAnim(root.Setting_Switch, false)
  end
end
function Refresh.OnClickDoublePeakGameHideId()
  log(bWriteLog and "Refresh.OnClickDoublePeakGameHideId")
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  log(bWriteLog and "Refresh.OnClickDoublePeakGameHideId LogicPeakGame.peakgameHideName = " .. tostring(LogicPeakGame.peakgameHideName))
  if LogicPeakGame.peakgameHideName ~= 0 then
    SettingHandler.send_set_peakgame_anchor_setting_req(0)
  else
    SettingHandler.send_set_peakgame_anchor_setting_req(1)
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    if LogicPeakGame.peakgameHideName ~= 0 then
      LogicPeakGame.peakgameHideName = 0
    else
      LogicPeakGame.peakgameHideName = 1
    end
    EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_PEAKGAME_HIDE_NAME)
  end
end
function Refresh.BShowMainCity()
  if IsWoWEditor then
    return false
  end
  local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
  return main_city_process_util.IsMainCityEntryOpen()
end
function Refresh.BShowMainCitySocial()
  log(bWriteLog and "Refresh.BShowMainCitySocial")
  return Refresh.BShowMainCity()
end
function Refresh.BShowEnterMainCity()
  log(bWriteLog and "Refresh.BShowEnterMainCity")
  local bShow = Refresh.BShowMainCity()
  local SettingSystem = require("client.logic.setting.logic_setting")
  local overlay = SettingSystem.Key2Overlay("EnterMainCity")
  UIUtil.SetWidgetVisible(overlay, bShow)
  return bShow
end
function Refresh.BShowMainCityNoInteract_Stranger()
  log(bWriteLog and "Refresh.BShowMainCityNoInteract_Stranger")
  return Refresh.BShowMainCity()
end
function Refresh.BShowMainCityNoInteract_Friend()
  log(bWriteLog and "Refresh.BShowMainCityNoInteract_Friend")
  return Refresh.BShowMainCity()
end
function Refresh.BShowQuickEnterMainCity()
  log(bWriteLog and "Refresh.BShowQuickEnterMainCity")
  return Refresh.BShowMainCity()
end
function Refresh.RefreshMainCityPrivacy(key)
  log(bWriteLog and "Refresh.RefreshMainCityPrivacy key = " .. tostring(key))
  return RefreshNormalDoubleVWord(key)
end
function Refresh.GetbONEnterMainCity(key)
  log(bWriteLog and "Refresh.GetbONEnterMainCity key = " .. tostring(key))
  local logic_main_city_privacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_privacy)
  local switch = logic_main_city_privacy:GetUserSwitch(1)
  return not switch
end
function Refresh.SetbONEnterMainCity(key)
  log(bWriteLog and "Refresh.SetbONEnterMainCity key = " .. tostring(key))
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.MainCityPrivacySetting) then
    return
  end
  local logic_main_city_privacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_privacy)
  local switch = logic_main_city_privacy:GetUserSwitch(1)
  switch = not switch
  local Main_City_Download_Tool = require("client.slua.logic.lobby.MainCity.Main_City_Download_Tool")
  if switch and not Main_City_Download_Tool.IsMainCityMapDownloaded(true) then
    return
  end
  local logic_main_city_enter_report = require("GameLua.Mod.MainCity.Client.logic.logic_main_city_enter_report")
  logic_main_city_enter_report.ReportSetDefaultMCEntrance(switch)
  logic_main_city_privacy:SetUserSwitch(1, switch):Then(function()
    Refresh.RefreshMainCityPrivacy(key)
  end)
end
local GetbONMainCityNoInteract = function(switch_idx)
  local logic_main_city_privacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_privacy)
  local switch = logic_main_city_privacy:GetUserSwitch(switch_idx)
  log(bWriteLog and "GetbONMainCityNoInteract switch_idx = " .. tostring(switch_idx) .. " switch = " .. tostring(switch))
  return switch
end
local SetbONMainCityNoInteract = function(switch_idx, key)
  local logic_main_city_privacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_privacy)
  local switch = logic_main_city_privacy:GetUserSwitch(switch_idx)
  switch = not switch
  logic_main_city_privacy:SetUserSwitch(switch_idx, switch):Then(function()
    Refresh.RefreshMainCityPrivacy(key)
  end)
end
function Refresh.GetbONMainCityNoInteract_Stranger(key)
  log(bWriteLog and "Refresh.GetbONMainCityNoInteract_Stranger key = " .. tostring(key))
  return GetbONMainCityNoInteract(2)
end
function Refresh.SetbONMainCityNoInteract_Stranger(key)
  log(bWriteLog and "Refresh.SetbONMainCityNoInteract_Stranger key = " .. tostring(key))
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.MainCityPrivacySetting) then
    return
  end
  SetbONMainCityNoInteract(2, key)
end
function Refresh.GetbONMainCityNoInteract_Friend(key)
  log(bWriteLog and "Refresh.GetbONMainCityNoInteract_Friend key = " .. tostring(key))
  return GetbONMainCityNoInteract(3)
end
function Refresh.SetbONMainCityNoInteract_Friend(key)
  log(bWriteLog and "Refresh.SetbONMainCityNoInteract_Friend key = " .. tostring(key))
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.MainCityPrivacySetting) then
    return
  end
  SetbONMainCityNoInteract(3, key)
end
function Refresh.GetbONQuickEnterMainCity(key)
  log(bWriteLog and "Refresh.GetbONQuickEnterMainCity key = " .. tostring(key))
  return GetbONMainCityNoInteract(4)
end
function Refresh.SetbONQuickEnterMainCity(key)
  log(bWriteLog and "Refresh.SetbONQuickEnterMainCity key = " .. tostring(key))
  PlaySound()
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.MainCityPrivacySetting) then
    return
  end
  SetbONMainCityNoInteract(4, key)
end
function Refresh.BShowTitleGyroscope()
  return not IsWoWEditor
end
function Refresh.BShowGyroscope()
  return not IsWoWEditor
end
function Refresh.BShowGyroReverse()
  return not IsWoWEditor
end
function Refresh.BShowHoldGrenadeStateEnableGyro()
  return not IsWoWEditor
end
return Refresh