local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")
local LogicSettingBasic = require("client.slua.logic.setting.logic_setting_basic")
local PopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
local CharacterHandler = require("client.network.Protocol.CharacterHandler")
local FuncLib = require("client.logic.NewSetting.Stack.FuncLib")
local setting_refresh_RelationShowOrder = require("client.logic.setting.refresh.setting_refresh_RelationShowOrder")
local UIUtil = require("client.common.ui_util")
local SEQ_102 = {
  1,
  0,
  2
}
local Spacer = {
  UI = AliasMap.Spacer
}
local RemapFriendsOnlyValue = function(value)
  local SettingValue = 0
  if value == true then
    SettingValue = 1
  elseif value == false then
    SettingValue = 2
  elseif value == nil then
    SettingValue = 2
  else
    SettingValue = value
  end
  return SettingValue
end
local ERelation = {
  Love = 2,
  Gay = 1,
  Buddies = 3,
  Sisters = 4,
  Family = 5
}
local _clickOneRelation = function(_, index)
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
    return
  end
  local SecrecySystemData = require("client.slua.logic.roleInfo.secrecy_data")
  SecrecySystemData.ChangeSwitch(index)
end
local _getSettingRelationValue = function(key)
  local ERelationKey2Index = {
    RelationLove = 2,
    RelationGay = 1,
    RelationBuddies = 3,
    RelationSisters = 4,
    RelationFamily = 5
  }
  local SecrecySystemData = require("client.slua.logic.roleInfo.secrecy_data")
  local bOn = SecrecySystemData.GetOneSwitch(ERelationKey2Index[key])
  return bOn
end
local _BShowbLbsMain = function()
  return true
end
local _BShowCollect = function()
  if IsWoWEditor then
    return false
  end
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if collect_module and collect_module.CanShowCollect then
    return collect_module:CanShowCollect()
  end
  return false
end
local _GetCollectPrivacy = function(key)
  local collect_privacy_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_privacy_module)
  return collect_privacy_module:GetPrivacyData(key)
end
local _SetCollectPrivacy = function(key)
  local collect_privacy_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_privacy_module)
  collect_privacy_module:ChangePrivacySetting(key)
  return true
end
local UploadUGCPrivacy = function()
  local Privacy = {
    main = not LogicSettingBasic.bWoWShow,
    play = not LogicSettingBasic.bWoWPlayShow,
    collect = not LogicSettingBasic.bWoWCollectModShow,
    follow = not LogicSettingBasic.bWoWLikeAuthorShow,
    rec_display = not LogicSettingBasic.bWoWHeadShwoShow,
    mod_collection = not LogicSettingBasic.bWoWModCollectionShow,
    wow_pass_display = not LogicSettingBasic.bWoWPassDisplay,
    wow_copilot_display = not LogicSettingBasic.bWoWCopilotDisplay
  }
  local UGCHandler = require("client.network.Protocol.UGCHandler")
  UGCHandler.send_ugc_set_privacy_req(Privacy)
end
local Stack_Privacy = {
  {
    UI = AliasMap.Title,
    Text = 4309025
  },
  {
    Key = "DoubleCanShowHistory",
    UI = AliasMap.Switcher,
    Text = 33136,
    SwitcherText = {
      773319,
      773318,
      773320
    },
    SwitcherValue = SEQ_102,
    EventType = EVENTTYPE_SETTING,
    EventID = EVENTID_SETTING_CAN_SHOW_HISTORY,
    GetFunc = function()
      if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
        return RemapFriendsOnlyValue(LogicSettingBasic.bCanShowHistory)
      else
        return LogicSettingBasic.bCanShowHistory ~= 1
      end
    end,
    SetFunc = function(_, Value)
      if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
        LogicSettingBasic.bCanShowHistory = Value
      else
        LogicSettingBasic.bCanShowHistory = Value == 1
      end
      local RoleInfoHistorySystem = require("client.logic.roleinfo.logic_roleinfo_history")
      RoleInfoHistorySystem.send_show_history(LogicSettingBasic.bCanShowHistory)
      return true
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "DoubleCanShowPopularity",
    UI = AliasMap.Switcher,
    Text = 33138,
    SwitcherText = {
      773319,
      773318,
      773320
    },
    SwitcherValue = SEQ_102,
    EventType = EVENTTYPE_ROLEINFO,
    EventID = EVENTID_TEAM_EVALUATION_INIT,
    EventType_1 = EVENTTYPE_PERSON_SPACE,
    EventID_1 = EVENTID_POPULARITY_GET_POPULARITY_RSP,
    GetFunc = function()
      if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
        return RemapFriendsOnlyValue(PopularitySystem.IsShowDetail)
      else
        return PopularitySystem.IsShowDetail ~= 1
      end
    end,
    SetFunc = function(_, Value)
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
        return
      end
      if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
        PopularitySystem.IsShowDetail = Value
      else
        PopularitySystem.IsShowDetail = Value == 1
      end
      PopularitySystem.show_popularity_detail_req(Value)
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "DoubleCanShowPlayDay",
    UI = AliasMap.Switcher,
    Text = 33139,
    EventType = EVENTTYPE_SETTING,
    EventID = EVENTID_SETTING_SHOW_PLAY_DAYS_UPDATE,
    GetFunc = function()
      return CharacterHandler.bShowPlayDays
    end,
    SetFunc = function(key, value)
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
        return
      end
      local bShowPlayDays = value
      CharacterHandler.send_modify_role_privacy(bShowPlayDays, 1)
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "DoubleEvaluation",
    UI = AliasMap.Switcher,
    Text = 33140,
    SwitcherText = {
      773319,
      773318,
      773320
    },
    SwitcherValue = {
      2,
      1,
      3
    },
    EventType = EVENTTYPE_ROLEINFO,
    EventID = EVENTID_TEAM_EVALUATION_PRIVACY,
    GetFunc = function()
      local logic_team_evaluation_view = require("client.slua.logic.team_evaluation.logic_team_evaluation_view")
      if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
        return logic_team_evaluation_view.bShowEvaluation
      end
    end,
    SetFunc = function(_, Value)
      local logic_team_evaluation_view = require("client.slua.logic.team_evaluation.logic_team_evaluation_view")
      if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
        logic_team_evaluation_view.bShowEvaluation = Value
      end
      logic_team_evaluation_view.send_set_evaluation_privacy(logic_team_evaluation_view.bShowEvaluation)
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "DoublePopularGiftPK",
    UI = AliasMap.Switcher,
    Text = 45954,
    SwitcherText = {
      773319,
      773318,
      773320
    },
    SwitcherValue = SEQ_102,
    EventType = EVENTTYPE_PERSON_SPACE,
    EventID = EVENTID_POPULAR_GIFT_PK_VIEW_SWITCH,
    GetFunc = function()
      local logic_popular_gift_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_gift_pk)
      local resViewPKSwitch = logic_popular_gift_pk.resViewPKSwitch
      if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
        return RemapFriendsOnlyValue(resViewPKSwitch)
      else
        return resViewPKSwitch
      end
    end,
    SetFunc = function(_, Value)
      if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
        local SettingHandler = require("client.network.Protocol.SettingHandler")
        SettingHandler.send_set_psmatch_view_pk_switch(Value)
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
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "DoubleSeasonLookBackShow",
    UI = AliasMap.Switcher,
    Text = 512144,
    EventType = EVENTTYPE_SEASONLOOKBACK,
    EventID = EVENTID_SEASONLOOKBACK_ENTRANCE_PRIVACY_UPDATE,
    VisibilityFunc = function()
      if IsWoWEditor then
        return false
      end
      local logic_season_lookback = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_lookback)
      if logic_season_lookback and logic_season_lookback.GetEntranceSwitch then
        return logic_season_lookback:GetEntranceSwitch()
      end
      return false
    end,
    GetFunc = function()
      local logic_season_lookback = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_lookback)
      if logic_season_lookback and logic_season_lookback.GetEntrancePrivacy then
        return logic_season_lookback:GetEntrancePrivacy()
      end
      return false
    end,
    SetFunc = function()
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
        return
      end
      local logic_season_lookback = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_lookback)
      local privacy = logic_season_lookback:GetEntrancePrivacy()
      local SeasonLookBackHandler = require("client.network.Protocol.SeasonLookBackHandler")
      SeasonLookBackHandler.send_set_season_lookback_privacy_req(not privacy)
    end
  },
  {
    Key = "ProfileShow",
    UI = AliasMap.Switcher,
    Text = 47373,
    VisibilityFunc = function()
      if IsWoWEditor then
        return false
      end
      return LobbySystem.CheckOpen(BP_ENUM_SOCIAL_INGAME_SWITCH)
    end,
    GetFunc = function()
      local roleData = LobbySystem.roleData.social_private_data
      if not roleData then
        return false
      end
      return roleData[3] == 1
    end,
    SetFunc = function()
      if not LobbySystem.roleData.social_private_data or not LobbySystem.roleData.social_private_data[1] then
        return
      end
      local SettingHandler = require("client.network.Protocol.SettingHandler")
      SettingHandler.send_set_social_private_switch_req(3, (LobbySystem.roleData.social_private_data[3] + 1) % 2)
    end,
    EventID = EVENTID_SETTING_PROFILE_SHOW,
    EventType = EVENTTYPE_SETTING,
    ExpandIndex = 0
  },
  {
    Key = "ProfileShowFight",
    UI = AliasMap.Switcher,
    Text = 47374,
    ExpandHandle = "ProfileShow",
    EventID = EVENTID_SETTING_PROFILE_SHOW,
    EventType = EVENTTYPE_SETTING,
    GetFunc = function()
      local roleData = LobbySystem.roleData.social_private_data
      if not roleData then
        return false
      end
      return roleData[2] == 1 or roleData[2] == 3
    end,
    SetFunc = function()
      if not LobbySystem.roleData.social_private_data or not LobbySystem.roleData.social_private_data[2] then
        return
      end
      local SettingHandler = require("client.network.Protocol.SettingHandler")
      SettingHandler.send_set_social_private_switch_req(2, LobbySystem.roleData.social_private_data[2] ~ 1)
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "ProfileShowSocial",
    UI = AliasMap.Switcher,
    Text = 47375,
    ExpandHandle = "ProfileShow",
    EventID = EVENTID_SETTING_PROFILE_SHOW,
    EventType = EVENTTYPE_SETTING,
    GetFunc = function()
      local roleData = LobbySystem.roleData.social_private_data
      if not roleData then
        return false
      end
      return roleData[2] == 2 or roleData[2] == 3
    end,
    SetFunc = function()
      if not LobbySystem.roleData.social_private_data or not LobbySystem.roleData.social_private_data[2] then
        return
      end
      local SettingHandler = require("client.network.Protocol.SettingHandler")
      SettingHandler.send_set_social_private_switch_req(2, LobbySystem.roleData.social_private_data[2] ~ 2)
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "WoWShow",
    UI = AliasMap.Switcher,
    Text = 67750,
    EventType = EVENTTYPE_UGC,
    EventID = EVENTID_UGC_FATHER_PRIVACY_SETTING_STATUS_NOTIFY,
    GetFunc = function()
      return LogicSettingBasic.bWoWShow
    end,
    SetFunc = function()
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SettingPrivacySwitchButton) then
        return
      end
      local bShow = not LogicSettingBasic.bWoWShow
      LogicSettingBasic.bWoWShow = bShow
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_FATHER_PRIVACY_SETTING_STATUS_NOTIFY)
      UploadUGCPrivacy()
    end,
    ExpandIndex = 0
  },
  {
    Key = "WoWPlay",
    UI = AliasMap.Switcher,
    Text = 67751,
    ExpandHandle = "WoWShow",
    EventType = EVENTTYPE_UGC,
    EventID = EVENTID_UGC_PRIVACY_SETTING_STATUS_NOTIFY,
    GetFunc = function()
      return LogicSettingBasic.bWoWPlayShow
    end,
    SetFunc = function()
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SettingPrivacySwitchButton) then
        return
      end
      LogicSettingBasic.bWoWPlayShow = not LogicSettingBasic.bWoWPlayShow
      UploadUGCPrivacy()
    end
  },
  {
    Key = "WoWCollectMod",
    UI = AliasMap.Switcher,
    Text = 67752,
    ExpandHandle = "WoWShow",
    EventType = EVENTTYPE_UGC,
    EventID = EVENTID_UGC_PRIVACY_SETTING_STATUS_NOTIFY,
    GetFunc = function()
      return LogicSettingBasic.bWoWCollectModShow
    end,
    SetFunc = function()
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SettingPrivacySwitchButton) then
        return
      end
      LogicSettingBasic.bWoWCollectModShow = not LogicSettingBasic.bWoWCollectModShow
      UploadUGCPrivacy()
    end
  },
  {
    Key = "WoWLikeAuthor",
    UI = AliasMap.Switcher,
    Text = 67753,
    ExpandHandle = "WoWShow",
    EventType = EVENTTYPE_UGC,
    EventID = EVENTID_UGC_PRIVACY_SETTING_STATUS_NOTIFY,
    GetFunc = function()
      return LogicSettingBasic.bWoWLikeAuthorShow
    end,
    SetFunc = function()
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SettingPrivacySwitchButton) then
        return
      end
      LogicSettingBasic.bWoWLikeAuthorShow = not LogicSettingBasic.bWoWLikeAuthorShow
      UploadUGCPrivacy()
    end
  },
  {
    Key = "WoWHeadShwo",
    UI = AliasMap.Switcher,
    Text = 69350,
    ExpandHandle = "WoWShow",
    EventType = EVENTTYPE_UGC,
    EventID = EVENTID_UGC_PRIVACY_SETTING_STATUS_NOTIFY,
    GetFunc = function()
      return LogicSettingBasic.bWoWHeadShwoShow
    end,
    SetFunc = function()
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SettingPrivacySwitchButton) then
        return
      end
      LogicSettingBasic.bWoWHeadShwoShow = not LogicSettingBasic.bWoWHeadShwoShow
      UploadUGCPrivacy()
    end
  },
  {
    Key = "WoWModCollectionShow",
    UI = AliasMap.Switcher,
    Text = 77910,
    ExpandHandle = "WoWShow",
    EventType = EVENTTYPE_UGC,
    EventID = EVENTID_UGC_PRIVACY_SETTING_STATUS_NOTIFY,
    GetFunc = function()
      return LogicSettingBasic.bWoWModCollectionShow
    end,
    SetFunc = function()
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SettingPrivacySwitchButton) then
        return
      end
      LogicSettingBasic.bWoWModCollectionShow = not LogicSettingBasic.bWoWModCollectionShow
      UploadUGCPrivacy()
    end
  },
  {
    Key = "WoWPassDisplay",
    UI = AliasMap.Switcher,
    Text = 1050125,
    ExpandHandle = "WoWShow",
    EventType = EVENTTYPE_UGC,
    EventID = EVENTID_UGC_PRIVACY_SETTING_STATUS_NOTIFY,
    GetFunc = function()
      return LogicSettingBasic.bWoWPassDisplay
    end,
    SetFunc = function()
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SettingPrivacySwitchButton) then
        return
      end
      LogicSettingBasic.bWoWPassDisplay = not LogicSettingBasic.bWoWPassDisplay
      UploadUGCPrivacy()
    end
  },
  {
    Key = "WoWCopilotDisplay",
    UI = AliasMap.Switcher,
    Text = 97000020,
    EventType = EVENTTYPE_UGC_COPILOT,
    EventID = EVENTID_UGC_COPILOT_SETTING_STATUS_NOTIFY,
    GetFunc = function()
      return LogicSettingBasic.bWoWCopilotDisplay
    end,
    SetFunc = function()
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SettingPrivacySwitchButton) then
        return
      end
      local bShow = not LogicSettingBasic.bWoWCopilotDisplay
      LogicSettingBasic.bWoWCopilotDisplay = bShow
      EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_SETTING_STATUS_NOTIFY, bShow)
      UploadUGCPrivacy()
    end
  },
  Spacer,
  {
    UI = AliasMap.Title,
    Text = 4309026,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "DoubleCanShowRole",
    UI = AliasMap.Switcher,
    Text = 33137,
    SwitcherText = {
      773319,
      773318,
      773320
    },
    SwitcherValue = SEQ_102,
    EventType = BP_ENUM_MODULE_SETTING,
    EventID = EVENTID_NET_ROLE_INFO_RSP,
    GetFunc = function()
      local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
      local playerInfo = BasicDataAvatarWearInfo:GetCacheData(DataMgr.roleData.uid)
      if nil == playerInfo then
        return
      end
      LogicSettingBasic.bCanShowRole = playerInfo.bshow
      if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
        return RemapFriendsOnlyValue(LogicSettingBasic.bCanShowRole)
      else
        return LogicSettingBasic.bCanShowRole ~= 1
      end
    end,
    SetFunc = function(_, Value)
      if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
        LogicSettingBasic.bCanShowRole = Value
      else
        LogicSettingBasic.bCanShowRole = Value == 1
      end
      LogicSettingBasic.SendCanShowRole()
      local ProfileHander = require("client.network.Protocol.ProfileHander")
      ProfileHander.send_chg_avatar_show_switch_req(Value)
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "DoubleShowCollectLevel",
    UI = AliasMap.Switcher,
    Text = 48248,
    EventType = EVENTTYPE_COLLECT,
    EventID = EVENTID_COLLECT_PRIVACY_DATA,
    GetFunc = _GetCollectPrivacy,
    SetFunc = _SetCollectPrivacy,
    VisibilityFunc = _BShowCollect
  },
  {
    Key = "DoubleStrangerCDetail",
    UI = AliasMap.Switcher,
    Text = 48249,
    EventType = EVENTTYPE_COLLECT,
    EventID = EVENTID_COLLECT_PRIVACY_DATA,
    GetFunc = _GetCollectPrivacy,
    SetFunc = _SetCollectPrivacy,
    VisibilityFunc = _BShowCollect
  },
  {
    Key = "DoubleFriendCDetail",
    UI = AliasMap.Switcher,
    Text = 48250,
    EventType = EVENTTYPE_COLLECT,
    EventID = EVENTID_COLLECT_PRIVACY_DATA,
    GetFunc = _GetCollectPrivacy,
    SetFunc = _SetCollectPrivacy,
    VisibilityFunc = _BShowCollect
  },
  {
    Key = "DoubleSouvenirs",
    UI = AliasMap.Switcher,
    Text = 49146,
    EventType = EVENTTYPE_SOUVENIRS,
    EventID = EVENTID_SOUVENIRS_INVISIBLE_UPDATE,
    GetFunc = function()
      local logic_xmission_souvenirs = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_souvenirs)
      if logic_xmission_souvenirs and logic_xmission_souvenirs.GetPrivacySwitchState then
        return logic_xmission_souvenirs:GetPrivacySwitchState()
      end
      return false
    end,
    SetFunc = function()
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
      return true
    end,
    VisibilityFunc = function()
      if IsWoWEditor then
        return false
      end
      local logic_xmission_entrance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_entrance)
      if not logic_xmission_entrance or not logic_xmission_entrance:IsTxMissionOpen() then
        return false
      end
      if not LobbySystem.CheckOpen(BP_ENUM_SWITCH_SOUVENIRS) then
        return false
      end
      local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
      if not LogicTxMissionMain.IsInXMission() then
        return false
      end
      return true
    end
  },
  {
    Key = "CollectionHallVisit",
    UI = AliasMap.Switcher,
    Text = 880060080,
    SwitcherText = {
      773319,
      773318,
      773320
    },
    SwitcherValue = {
      0,
      1,
      2
    },
    EventType = EVENTTYPE_PERSON_SPACE,
    EventID = EVENTID_COLLECTIONHALL_VISIT_PRIVACY_CHANGE,
    GetFunc = function()
      local CollectionHallVisitPrivacyTool = require("client.slua.logic.CollectionHall.CollectionHallVisitPrivacyTool")
      return CollectionHallVisitPrivacyTool.GetPlayerVisitPrivacy()
    end,
    SetFunc = function(key, index)
      local CollectionHallVisitPrivacyTool = require("client.slua.logic.CollectionHall.CollectionHallVisitPrivacyTool")
      local currentPrivacy = CollectionHallVisitPrivacyTool.GetPlayerVisitPrivacy()
      if index == currentPrivacy then
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
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  Spacer,
  {
    UI = AliasMap.Title,
    Text = 4309027,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "DoubleCanShowPround",
    UI = AliasMap.Switcher,
    Text = 43257,
    SwitcherText = {
      773319,
      773318,
      773320
    },
    SwitcherValue = SEQ_102,
    EventType = EVENTTYPE_PERSON_SPACE,
    EventID = EVENTID_POPULARITY_SET_PROUND_SWITCH_RSP,
    GetFunc = function()
      if DataMgr.roleData.pround_info then
        if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
          return RemapFriendsOnlyValue(DataMgr.roleData.pround_info.is_visable)
        else
          return DataMgr.roleData.pround_info.is_visable or false
        end
      end
    end,
    SetFunc = function(key, index)
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
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "bCanShowUnknownPass",
    UI = AliasMap.Switcher,
    Text = 33149,
    GetFunc = function()
      return LogicSettingBasic.bCanShowUnknownPass
    end,
    SetFunc = function(key)
      LogicSettingBasic[key] = not LogicSettingBasic[key]
      LogicSettingBasic.bUnknownPassBattleShow = LogicSettingBasic[key]
      LogicSettingBasic.bUnknownPassRecordShow = LogicSettingBasic[key]
      LogicSettingBasic.SendUnknownPassSwitch()
      return true
    end,
    ExpandIndex = 0,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "bUnknownPassRecordShow",
    UI = AliasMap.Switcher,
    Text = 33150,
    GetFunc = function()
      return LogicSettingBasic.bUnknownPassRecordShow
    end,
    SetFunc = function(key)
      LogicSettingBasic[key] = not LogicSettingBasic[key]
      LogicSettingBasic.SendUnknownPassSwitch()
      return true
    end,
    ExpandHandle = "bCanShowUnknownPass",
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "bUnknownPassBattleShow",
    UI = AliasMap.Switcher,
    Text = 33151,
    GetFunc = function()
      return LogicSettingBasic.bUnknownPassBattleShow
    end,
    SetFunc = function(key)
      LogicSettingBasic[key] = not LogicSettingBasic[key]
      LogicSettingBasic.SendUnknownPassSwitch()
      return true
    end,
    ExpandHandle = "bCanShowUnknownPass",
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "DoubleShowSubscribeBadge",
    UI = AliasMap.Switcher,
    Text = 62900,
    GetFunc = function()
      return LogicSettingBasic.bShowSubscribeBadge
    end,
    SetFunc = function()
      LogicSettingBasic.bShowSubscribeBadge = not LogicSettingBasic.bShowSubscribeBadge
      LogicSettingBasic.SendSubscribeSwich()
      return true
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  Spacer,
  {
    UI = AliasMap.Title,
    Text = 4309028,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "ShowBirthdaySwitch",
    UI = AliasMap.Switcher,
    Text = 38673,
    SwitcherText = {
      773319,
      773318,
      773320
    },
    SwitcherValue = SEQ_102,
    EventType = EVENTTYPE_SETTING,
    EventID = EVENTID_SETTING_BIRTHDAY,
    VisibilityFunc = function()
      return not IsWoWEditor and not GameStatus.IsInFightingNotSocialNotMainCityNotHome()
    end,
    GetFunc = function()
      local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
      if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
        return RemapFriendsOnlyValue(RoleInfoSystem.ShowBirthdaySwitch)
      else
        return RoleInfoSystem.ShowBirthdaySwitch
      end
    end,
    SetFunc = function(_, Value)
      local SettingHandler = require("client.network.Protocol.SettingHandler")
      if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
        SettingHandler.send_set_birthday_privacy_req(Value)
      else
        SettingHandler.send_set_birthday_privacy_req(Value == 1)
      end
    end
  },
  Spacer,
  {
    UI = AliasMap.Title,
    Text = 4309029,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "DoubleNotFriendInvite",
    UI = AliasMap.Switcher,
    Text = 31057,
    GetFunc = function()
      return DataMgr.roleData.receive_nonfriend_team_request == 1
    end,
    SetFunc = function()
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
        return
      end
      local nPreValue = DataMgr.roleData.receive_nonfriend_team_request
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
      return true
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "DoubleWatchingOpen",
    UI = AliasMap.Switcher,
    Text = 33292,
    GetFunc = function()
      LogicSettingBasic.bShowWatching = DataMgr.IsEnableWatch()
      return LogicSettingBasic.bShowWatching == 1
    end,
    SetFunc = function()
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
        return
      end
      LogicSettingBasic.bShowWatching = (LogicSettingBasic.bShowWatching + 1) % 2
      DataMgr.SetEnableWatch(LogicSettingBasic.bShowWatching)
      local LogicLobbyWatching = require("client.logic.watching.logic_lobby_watching")
      LogicLobbyWatching.send_show_watching(LogicSettingBasic.bShowWatching)
      return true
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "DoubleReserve",
    UI = AliasMap.Switcher,
    Text = 44046,
    EventType = EVENTTYPE_FRIEND,
    EventID = EVENTID_FRIEND_RESERVE_SWITCH_SYNC,
    GetFunc = function()
      local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
      return logic_friend_reserve and logic_friend_reserve.nAllowReserveFlag == 1
    end,
    SetFunc = function()
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
        return
      end
      local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
      local flag = 1
      if logic_friend_reserve.nAllowReserveFlag == 1 then
        flag = 0
      end
      local FriendHandler = require("client.network.Protocol.FriendHandler")
      FriendHandler.send_modify_friend_appointment_privacy_req(flag)
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "DoubleAllowFriendIsland",
    UI = AliasMap.Switcher,
    Text = 33152,
    GetFunc = function()
      local SocialIslandHandler = require("client.network.Protocol.SocialIslandHandler")
      if SocialIslandHandler.is_apply_on_info then
        return SocialIslandHandler.is_apply_on_info[1] == 1
      end
      return false
    end,
    SetFunc = function()
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
    end,
    EventType = EVENTID_SOCIAL_EVENT,
    EventID = EVENTID_SOCIAL_EVENT_SET_APPLY_ONOFF,
    EventType_1 = EVENTID_SOCIAL_EVENT,
    EventID_1 = EVENTID_SOCIAL_EVENT_GET_APPLY_ONOFF,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "DoubleAllowStrangerIsland",
    UI = AliasMap.Switcher,
    Text = 33153,
    GetFunc = function()
      local SocialIslandHandler = require("client.network.Protocol.SocialIslandHandler")
      if SocialIslandHandler.is_apply_on_info then
        return SocialIslandHandler.is_apply_on_info[0] == 1
      end
      return false
    end,
    SetFunc = function()
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
    end,
    EventType = EVENTID_SOCIAL_EVENT,
    EventID = EVENTID_SOCIAL_EVENT_SET_APPLY_ONOFF,
    EventType_1 = EVENTID_SOCIAL_EVENT,
    EventID_1 = EVENTID_SOCIAL_EVENT_GET_APPLY_ONOFF,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "SocialIslandCanAcceptDuel",
    UI = AliasMap.Switcher,
    Text = 33154,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "DoubleAllowChatHorn",
    UI = AliasMap.Switcher,
    Text = 33155,
    VisibilityFunc = function()
      if IsWoWEditor then
        return false
      end
      return LobbySystem.CheckOpen(BP_ENUM_CHAT_HORN_SWITCH)
    end,
    GetFunc = function()
      local logic_chat_horn = require("client.slua.logic.lobby_chat.logic_chat_horn")
      return logic_chat_horn:GetChatHornSwitch()
    end,
    SetFunc = function()
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
        return
      end
      local logic_chat_horn = require("client.slua.logic.lobby_chat.logic_chat_horn")
      logic_chat_horn:ChangeChatHornSwitch()
      return true
    end
  },
  {
    Key = "TeammateTakeOver",
    UI = AliasMap.Switcher,
    Text = 86035,
    Help = 86036,
    VisibilityFunc = function()
      if IsWoWEditor then
        return false
      end
      local logic_ai_take_over = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ai_take_over)
      if logic_ai_take_over and logic_ai_take_over.BShowButton then
        return logic_ai_take_over:BShowButton()
      end
      return false
    end,
    SetFunc = function(key, value)
      FuncLib.SetValue(key, not FuncLib.GetValue(key))
      local logic_ai_take_over = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ai_take_over)
      logic_ai_take_over:ReportTLog(1)
      return true
    end
  },
  {
    Key = "bLbsMain",
    UI = AliasMap.Switcher,
    Text = 24568,
    ExpandIndex = 0,
    EventType = EVENTTYPE_LBS,
    EventID = EVENTID_LBS_UPDATE_JOIN_MAIN,
    VisibilityFunc = _BShowbLbsMain,
    GetFunc = FuncLib.GetValue,
    SetFunc = function(key, bValue)
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
        return
      end
      FuncLib.SetValue(key, bValue)
      local LBSHandler = require("client.network.Protocol.LBSHandler")
      local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
      if bValue then
        LBSHandler.send_lbs_set_privacy_req(LbsMgr.SETTING_CFG_MAIN_ID, 1)
      else
        LBSHandler.send_lbs_set_privacy_req(LbsMgr.SETTING_CFG_MAIN_ID, 2)
      end
    end
  },
  {
    Key = "bLbsChaneZone",
    UI = AliasMap.OpenWindow,
    Text = 24612,
    EventType = EVENTTYPE_LBS,
    EventID = EVENTID_LBS_UPDATE_MY_ZONE,
    ExpandHandle = "bLbsMain",
    VisibilityFunc = _BShowbLbsMain,
    GetFunc = function()
      local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
      return LbsMgr.GetMySetZoneConcatName("/")
    end,
    SetFunc = function()
      local logic_lbs_warzone = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lbs_warzone)
      logic_lbs_warzone:RefreshGPSZone()
    end,
    bReplaceTitleAndContent = true
  },
  {
    Key = "bLBSNear",
    UI = AliasMap.Switcher,
    Text = 24565,
    ExpandHandle = "bLbsMain",
    VisibilityFunc = function()
      if IsWoWEditor then
        return false
      end
      local SettingSystem = require("client.logic.setting.logic_setting")
      if SettingSystem.IsHideLBSPanel() or not GameStatus.IsInLobbyOrMainCity() then
        return false
      end
      return _BShowbLbsMain() and SettingSystem.IsOpenLBSNear()
    end,
    SetFunc = function(key, bValue)
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
        return
      end
      local LBSHandler = require("client.network.Protocol.LBSHandler")
      local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
      local nOpen = bValue and 1 or 2
      LBSHandler.send_lbs_set_privacy_req(LbsMgr.SETTING_CFG_NEAR_ID, nOpen)
      return FuncLib.SetValue(key, bValue)
    end
  },
  {
    Key = "bLbsChat",
    UI = AliasMap.Switcher,
    Text = 24566,
    ExpandHandle = "bLbsMain",
    VisibilityFunc = function()
      if IsWoWEditor then
        return false
      end
      local SettingSystem = require("client.logic.setting.logic_setting")
      if SettingSystem.IsHideLBSPanel() or not GameStatus.IsInLobbyOrMainCity() then
        return false
      end
      return _BShowbLbsMain() and SettingSystem.IsOpenLBSChat()
    end,
    SetFunc = function(key, bValue)
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
        return
      end
      local LBSHandler = require("client.network.Protocol.LBSHandler")
      local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
      local nOpen = bValue and 1 or 2
      LBSHandler.send_lbs_set_privacy_req(LbsMgr.SETTING_CFG_CHAT_ID, nOpen)
      return FuncLib.SetValue(key, bValue)
    end
  },
  {
    Key = "bLBSWarZone",
    UI = AliasMap.Switcher,
    Text = 24567,
    ExpandHandle = "bLbsMain",
    VisibilityFunc = function()
      if IsWoWEditor then
        return false
      end
      local SettingSystem = require("client.logic.setting.logic_setting")
      if SettingSystem.IsHideLBSPanel() or not GameStatus.IsInLobbyOrMainCity() then
        return false
      end
      return _BShowbLbsMain() and SettingSystem.IsOpenLBSWarZone()
    end,
    SetFunc = function(key, bValue)
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
        return
      end
      local LBSHandler = require("client.network.Protocol.LBSHandler")
      local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
      local nOpen = bValue and 1 or 2
      LBSHandler.send_lbs_set_privacy_req(LbsMgr.SETTING_CFG_WARZONE_ID, nOpen)
      return FuncLib.SetValue(key, bValue)
    end
  },
  {
    Key = "bLBSPlace",
    UI = AliasMap.Switcher,
    Text = 39033,
    EventType = EVENTTYPE_SETTING,
    EventID = EVENTID_SETTING_BLBSPLACE,
    ExpandHandle = "bLbsMain",
    VisibilityFunc = _BShowbLbsMain,
    GetFunc = function()
      local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
      return RoleInfoSystem.bLBSPlace
    end,
    SetFunc = function(key, bValue)
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
        return
      end
      local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
      local switch = not RoleInfoSystem.bLBSPlace
      local SettingHandler = require("client.network.Protocol.SettingHandler")
      SettingHandler.send_set_lbs_privacy_req(switch)
    end
  },
  Spacer,
  {
    UI = AliasMap.Title,
    Text = 4309030,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "Guardian",
    UI = AliasMap.Switcher,
    Text = 18010379,
    Help = 18010380,
    SwitcherText = {
      773319,
      773318,
      773320
    },
    SwitcherValue = SEQ_102,
    EventType = EVENTTYPE_PERSON_SPACE,
    EventID = EVENTID_GUARDIAN_RANK_SWITCH_UPDATE,
    GetFunc = function()
      if DataMgr.roleData then
        if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
          local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
          local myProfile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
          if myProfile then
            local switch = myProfile.guardian_visable
            return RemapFriendsOnlyValue(switch)
          end
        else
          return DataMgr.roleData.guardian_visable or false
        end
      end
    end,
    SetFunc = function(_, Value)
      if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
        local logic_roleinfo_popularity = require("client.slua.logic.person_space.logic_roleinfo_popularity")
        logic_roleinfo_popularity.changeGuardianSwitch(Value)
      else
        local logic_roleinfo_popularity = require("client.slua.logic.person_space.logic_roleinfo_popularity")
        logic_roleinfo_popularity.changeGuardianSwitch(Value == 1)
      end
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "DoubleIntimacyHint",
    UI = AliasMap.Switcher,
    Text = 44137,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "Relation",
    UI = AliasMap.Switcher,
    Text = 33144,
    Help = 77122,
    SwitcherText = {
      773319,
      773318,
      773320
    },
    SwitcherValue = SEQ_102,
    ExpandIndex = {0, 2},
    EventType = EVENTTYPE_PERSON_SPACE,
    EventID = EVENTID_PERSONSPACE_SWITCH_UPDATE_TOTAL,
    GetFunc = function()
      local SecrecySystemData = require("client.slua.logic.roleInfo.secrecy_data")
      local bTotalOn = SecrecySystemData.GetOneSwitch(0)
      if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
        return RemapFriendsOnlyValue(SecrecySystemData.GetOneSwitch(0))
      else
        return bTotalOn == 0 or bTotalOn == false
      end
    end,
    SetFunc = function(_, Value)
      if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
        local SecrecySystemData = require("client.slua.logic.roleInfo.secrecy_data")
        SecrecySystemData.ChangeSwitch(0, Value)
      end
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "RelationLove",
    UI = AliasMap.Switcher,
    Text = 8075914,
    ExpandHandle = "Relation",
    EventType = EVENTTYPE_PERSON_SPACE,
    EventID = EVENTID_PERSONSPACE_SWITCH_UPDATE,
    GetFunc = _getSettingRelationValue,
    SetFunc = function()
      _clickOneRelation(nil, ERelation.Love)
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "RelationGay",
    UI = AliasMap.Switcher,
    Text = 33146,
    ExpandHandle = "Relation",
    EventType = EVENTTYPE_PERSON_SPACE,
    EventID = EVENTID_PERSONSPACE_SWITCH_UPDATE,
    GetFunc = _getSettingRelationValue,
    SetFunc = function()
      _clickOneRelation(nil, ERelation.Gay)
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "RelationBuddies",
    UI = AliasMap.Switcher,
    Text = 33147,
    ExpandHandle = "Relation",
    EventType = EVENTTYPE_PERSON_SPACE,
    EventID = EVENTID_PERSONSPACE_SWITCH_UPDATE,
    GetFunc = _getSettingRelationValue,
    SetFunc = function()
      _clickOneRelation(nil, ERelation.Buddies)
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "RelationSisters",
    UI = AliasMap.Switcher,
    Text = 33148,
    ExpandHandle = "Relation",
    EventType = EVENTTYPE_PERSON_SPACE,
    EventID = EVENTID_PERSONSPACE_SWITCH_UPDATE,
    GetFunc = _getSettingRelationValue,
    SetFunc = function()
      _clickOneRelation(nil, ERelation.Sisters)
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "RelationFamily",
    UI = AliasMap.Switcher,
    Text = 73243,
    ExpandHandle = "Relation",
    EventType = EVENTTYPE_PERSON_SPACE,
    EventID = EVENTID_PERSONSPACE_SWITCH_UPDATE,
    GetFunc = _getSettingRelationValue,
    SetFunc = function()
      _clickOneRelation(nil, ERelation.Family)
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "RelationShowOrder",
    UI = AliasMap.Switcher,
    Text = 8205113,
    SwitcherText = {
      8075914,
      33146,
      33147,
      33148,
      73243
    },
    EventType = EVENTTYPE_PERSON_SPACE,
    EventID = EVENTID_PERSONSPACE_PRIOR_RELATION,
    VisibilityFunc = setting_refresh_RelationShowOrder.BShowRelationShowOrder,
    GetFunc = function()
      local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
      local curSelect = 0
      if PersonSpaceSystem.relationPrior == nil then
        curSelect = 0
      else
        curSelect = setting_refresh_RelationShowOrder.saveIndexToShowIndexMap[PersonSpaceSystem.relationPrior.prior_type]
      end
      return curSelect or 0
    end,
    SetFunc = function(_, Value)
      setting_refresh_RelationShowOrder.OnClickItem("RelationShowOrder", Value)
    end
  },
  {
    Key = "DoubleShowChatRoom",
    UI = AliasMap.Switcher,
    Text = 62376,
    EventType = EVENTTYPE_CHAT_ROOM,
    EventID = EVENTID_CHAT_ROOM_SET_SHOW_CHAT_ROOM,
    GetFunc = function()
      return LogicSettingBasic.bShowChatRoom
    end,
    SetFunc = function(_, value)
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
        return
      end
      local ChatRoomHandler = require("client.network.Protocol.ChatRoomHandler")
      ChatRoomHandler.send_set_chat_channel_status_switch_req(value)
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "DoubleHideVisitRecord",
    UI = AliasMap.Switcher,
    Text = 43197,
    GetFunc = function()
      local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
      return RoleInfoPopularitySystem.bHideVisitRecord
    end,
    SetFunc = function(_, value)
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
        return
      end
      local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
      RoleInfoPopularitySystem.send_set_pspace_hidden_visitor_track(value)
      return true
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "DoubleAllowFriendSeason",
    UI = AliasMap.Switcher,
    Text = 33156,
    GetFunc = function()
      return LogicSettingBasic.bSeasonFriendDataPrivacy
    end,
    SetFunc = function()
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
        return
      end
      LogicSettingBasic.bSeasonFriendDataPrivacy = not LogicSettingBasic.bSeasonFriendDataPrivacy
      local SeasonHandler = require("client.network.Protocol.SeasonHandler")
      SeasonHandler.send_set_season_reward_head_frame_privacy(LogicSettingBasic.bSeasonFriendDataPrivacy)
      return true
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "DoublePeakGameHideId",
    UI = AliasMap.Switcher,
    Text = 68649,
    Help = 68650,
    VisibilityFunc = function()
      if IsWoWEditor then
        return false
      end
      local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
      return LogicPeakGame.isShowPeakGameHideNameSelection and FuncLib.BShow_InLobby()
    end,
    GetFunc = function()
      local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
      return LogicPeakGame.peakgameHideName ~= 0
    end,
    SetFunc = function(_, bValue)
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
        return
      end
      local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
      local SettingHandler = require("client.network.Protocol.SettingHandler")
      SettingHandler.send_set_peakgame_anchor_setting_req(bValue and 1 or 0)
      LogicPeakGame.peakgameHideName = bValue and 1 or 0
      return true
    end
  },
  {
    Key = "DoubleAllowPush",
    UI = AliasMap.Switcher,
    Text = 33291,
    VisibilityFunc = function()
      return not IsWoWEditor and FuncUtil.IsPlayerJPKR()
    end,
    GetFunc = function()
      local IntlHelper = import("IntlHelper")
      return IntlHelper.IsRemoteNotificationsEnabled()
    end,
    SetFunc = function(_, bValue)
      LogicSettingBasic.bIsClickPushButton = true
      local IntlHelper = import("IntlHelper")
      IntlHelper.DirectToNotificationSetup()
      return true
    end
  },
  {
    Key = "DoubleAllowPushNight",
    UI = AliasMap.Switcher,
    Text = 33288,
    VisibilityFunc = function()
      local IntlHelper = import("IntlHelper")
      return not IsWoWEditor and FuncUtil.IsPlayerJPKR() and IntlHelper.IsRemoteNotificationsEnabled()
    end,
    GetFunc = function()
      local IntlHelper = import("IntlHelper")
      local strNightTag = IntlHelper.GetSavedXGPushNightTag()
      return strNightTag == "night_on"
    end,
    SetFunc = function(_, bValue)
      local IntlHelper = import("IntlHelper")
      local strNightTag = IntlHelper.GetSavedXGPushNightTag()
      local SettingSystem = require("client.logic.setting.logic_setting")
      if strNightTag == "night_on" then
        SettingSystem.nPushResId = 4982
      elseif strNightTag == "night_off" then
        SettingSystem.nPushResId = 4981
      end
      IntlHelper.UpdateXGPushNightTag(false)
      SettingSystem.ShowXGPushOpenTip()
      return true
    end
  },
  {
    UI = AliasMap.Title,
    Text = 817003,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "DoubleFlashMatchTeamRecommend",
    UI = AliasMap.Switcher,
    Text = 817034,
    EventType = EVENTTYPE_FLASH_TEAM,
    EventID = EVENTID_FLASH_TEAM_SETTING_UI_UPDATE,
    GetFunc = function()
      local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
      local teamInfo = logic_flash_match_team:getOwnFlashTeamInfo()
      if teamInfo and teamInfo.setting and teamInfo.setting.guide_muted then
        return teamInfo.setting.guide_muted
      else
        return false
      end
    end,
    SetFunc = function()
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
        return
      end
      local flash_team_setting_tools = require("client.slua.logic.friend.flash_team.flash_team_setting_tools")
      flash_team_setting_tools.reverse_one_setting("guide_muted")
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "DoubleFlashMatchTeamInsidePreTeamInvite",
    UI = AliasMap.Switcher,
    Text = 817035,
    EventType = EVENTTYPE_FLASH_TEAM,
    EventID = EVENTID_FLASH_TEAM_SETTING_UI_UPDATE,
    GetFunc = function()
      local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
      local teamInfo = logic_flash_match_team:getOwnFlashTeamInfo()
      if teamInfo and teamInfo.setting and teamInfo.setting.block_team_invite then
        return teamInfo.setting.block_team_invite
      else
        return false
      end
    end,
    SetFunc = function()
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
        return
      end
      local flash_team_setting_tools = require("client.slua.logic.friend.flash_team.flash_team_setting_tools")
      flash_team_setting_tools.reverse_one_setting("block_team_invite")
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "DoubleFriendInviteJoinFlashMatchTeam",
    UI = AliasMap.Switcher,
    Text = 817036,
    EventType = EVENTTYPE_FLASH_TEAM,
    EventID = EVENTID_FLASH_TEAM_SETTING_UI_UPDATE,
    GetFunc = function()
      local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
      local teamInfo = logic_flash_match_team:getOwnFlashTeamInfo()
      if teamInfo and teamInfo.setting and teamInfo.setting.block_flash_squad_invite then
        return teamInfo.setting.block_flash_squad_invite
      else
        return false
      end
    end,
    SetFunc = function()
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
        return
      end
      local flash_team_setting_tools = require("client.slua.logic.friend.flash_team.flash_team_setting_tools")
      flash_team_setting_tools.reverse_one_setting("block_flash_squad_invite")
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "DoubleOpenPreTeamIsLeader",
    UI = AliasMap.Switcher,
    Text = 817037,
    EventType = EVENTTYPE_FLASH_TEAM,
    EventID = EVENTID_FLASH_TEAM_SETTING_UI_UPDATE,
    GetFunc = function()
      local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
      local teamInfo = logic_flash_match_team:getOwnFlashTeamInfo()
      if teamInfo and teamInfo.setting and teamInfo.setting.disable_flash_squad_pre_team_sync then
        return teamInfo.setting.disable_flash_squad_pre_team_sync
      else
        return false
      end
    end,
    SetFunc = function()
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
        return
      end
      local flash_team_setting_tools = require("client.slua.logic.friend.flash_team.flash_team_setting_tools")
      flash_team_setting_tools.reverse_one_setting("disable_flash_squad_pre_team_sync")
    end,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  }
}
return Stack_Privacy