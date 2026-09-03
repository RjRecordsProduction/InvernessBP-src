local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")
local FuncLib = require("client.logic.NewSetting.Stack.FuncLib")
local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
local UIUtil = require("client.common.ui_util")
local Spacer = {
  UI = AliasMap.Spacer
}
local Stack_Social = {
  {
    UI = AliasMap.Title,
    Text = 73339,
    VisibilityFunc = main_city_process_util.IsMainCityEntryOpen
  },
  {
    Key = "EnterMainCity",
    UI = AliasMap.Switcher,
    Text = 73328,
    SwitcherText = {73329, 73330},
    EventType = EVENTTYPE_MAIN_CITY_LOBBY,
    EventID = EVENTID_MAIN_CITY_SETTING_MAINPAGE,
    VisibilityFunc = main_city_process_util.IsMainCityEntryOpen,
    GetFunc = function()
      local logic_main_city_privacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_privacy)
      return logic_main_city_privacy:GetUserSwitch(1)
    end,
    SetFunc = function(_, bValue)
      local logic_main_city_privacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_privacy)
      local Main_City_Download_Tool = require("client.slua.logic.lobby.MainCity.Main_City_Download_Tool")
      if bValue and not Main_City_Download_Tool.IsMainCityMapDownloaded(true) then
        return
      end
      local logic_main_city_enter_report = require("GameLua.Mod.MainCity.Client.logic.logic_main_city_enter_report")
      logic_main_city_enter_report.ReportSetDefaultMCEntrance(bValue)
      logic_main_city_privacy:SetUserSwitch(1, bValue)
    end
  },
  {
    Key = "MainCityNoInteract_Stranger",
    UI = AliasMap.Switcher,
    Text = 656072,
    EventType = EVENTTYPE_MAIN_CITY_LOBBY,
    EventID = EVENTID_MAIN_CITY_SETTING_MAINPAGE,
    VisibilityFunc = main_city_process_util.IsMainCityEntryOpen,
    GetFunc = function()
      local logic_main_city_privacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_privacy)
      return logic_main_city_privacy:GetUserSwitch(2)
    end,
    SetFunc = function(key, bValue)
      local logic_main_city_privacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_privacy)
      return logic_main_city_privacy:SetUserSwitch(2, bValue)
    end
  },
  {
    Key = "MainCityNoInteract_Friend",
    UI = AliasMap.Switcher,
    Text = 656073,
    EventType = EVENTTYPE_MAIN_CITY_LOBBY,
    EventID = EVENTID_MAIN_CITY_SETTING_MAINPAGE,
    VisibilityFunc = main_city_process_util.IsMainCityEntryOpen,
    GetFunc = function()
      local logic_main_city_privacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_privacy)
      return logic_main_city_privacy:GetUserSwitch(3)
    end,
    SetFunc = function(key, bValue)
      local logic_main_city_privacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_privacy)
      return logic_main_city_privacy:SetUserSwitch(3, bValue)
    end
  },
  {
    Key = "QuickEnterMainCity",
    UI = AliasMap.Switcher,
    Text = 656183,
    EventType = EVENTTYPE_MAIN_CITY_LOBBY,
    EventID = EVENTID_MAIN_CITY_SETTING_MAINPAGE,
    VisibilityFunc = main_city_process_util.IsMainCityEntryOpen,
    GetFunc = function()
      local logic_main_city_privacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_privacy)
      return logic_main_city_privacy:GetUserSwitch(4)
    end,
    SetFunc = function(key, bValue)
      local logic_main_city_privacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_privacy)
      return logic_main_city_privacy:SetUserSwitch(4, bValue)
    end
  },
  Spacer,
  {
    UI = AliasMap.Title,
    Text = 4309031
  },
  {
    Key = "UseIngameLike",
    UI = AliasMap.Switcher,
    Text = 33130
  },
  {
    Key = "IslandBroadCast",
    UI = AliasMap.Switcher,
    Text = 33132
  },
  {
    Key = "OpenOthersPet",
    UI = AliasMap.Switcher,
    Text = 33133
  },
  {
    Key = "OpenMyPetFPP",
    UI = AliasMap.Switcher,
    Text = 33134
  },
  {
    Key = "OpenMyPet",
    UI = AliasMap.Switcher,
    Text = 33135
  },
  {
    Key = "bSpectatingPetVisible",
    UI = AliasMap.Switcher,
    Text = 49272
  },
  {
    Key = "bOtherPlayingWeapon",
    UI = AliasMap.Switcher,
    Text = 44728
  },
  {
    Key = "ShowMiniTvInFighting",
    UI = AliasMap.Switcher,
    Text = 89947,
    Help = 87375,
    SetFunc = function(key, value)
      local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
      local reportValue = value and 1 or 0
      BasicDataTLogReport:ReportDelay(TLogEventDefine.FightingShowSwitchSetting, reportValue)
      return FuncLib.SetValue(key, value)
    end
  },
  {
    Key = "ShowOtherMiniTvInFighting",
    UI = AliasMap.Switcher,
    Text = 89948,
    SetFunc = function(key, value)
      local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
      local reportValue = value and 1 or 0
      BasicDataTLogReport:ReportDelay(TLogEventDefine.FightingShowOtherSwitchSetting, reportValue)
      return FuncLib.SetValue(key, value)
    end
  },
  {
    Key = "ShowMiniTvInRank",
    UI = AliasMap.Switcher,
    Text = 87373
  },
  {
    Key = "ShowMiniTvInSocial",
    UI = AliasMap.Switcher,
    Text = 87374
  },
  {
    Key = "bEnableSTTS",
    UI = AliasMap.Switcher,
    Text = 817411,
    Help = function()
      UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 0, LocUtil.GetLocalizeResStr(792526), LocUtil.GetLocalizeResStr(817413))
    end,
    SetFunc = function(key, value)
      if value then
        UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 2, LocUtil.GetLocalizeResStr(792526), LocUtil.GetLocalizeResStr(817413), nil, LocUtil.LocalizeResFormat(117035), LocUtil.LocalizeResFormat(4111), function()
          FuncLib.SetValue(key, true)
          EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_OPTION_FORCEUPDATE, key)
        end)
      else
        return FuncLib.SetValue(key, false)
      end
    end,
    VisibilityFunc = function()
      local VoiceChatSubsystemClass = require("GameLua.Mod.BaseMod.Client.Chat.VoiceChatSubsystem")
      return VoiceChatSubsystemClass.IsSTTSRegion() or Client.IsDevelopment()
    end
  },
  Spacer,
  {
    UI = AliasMap.Title,
    Text = 4309032
  },
  {
    Key = "DoubleAllowRecommendedFriend",
    UI = AliasMap.Switcher,
    Text = 8889,
    EventType = EVENTTYPE_SETTING,
    EventID = EVENTID_SETTING_SHOW_RECOMMENDED_UPDATE,
    GetFunc = function()
      local logic_setting_recommended = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_setting_recommended)
      return logic_setting_recommended:GetSwitchByType(2) == 1
    end,
    SetFunc = function(_, bValue)
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
        return
      end
      local logic_setting_recommended = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_setting_recommended)
      logic_setting_recommended:send_set_recommend_open_req(2, bValue and 1 or 0)
    end
  },
  {
    Key = "DoubleTeamRecommend",
    UI = AliasMap.Switcher,
    Text = 39190,
    EventType = EVENTTYPE_SETTING,
    EventID = EVENTID_SETTING_SHOW_RECOMMENDED_UPDATE,
    GetFunc = function()
      local logic_setting_recommended = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_setting_recommended)
      return logic_setting_recommended:GetSwitchByType(3) == 1
    end,
    SetFunc = function(_, bValue)
      if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SpaceSecrecySetting) then
        return
      end
      local logic_setting_recommended = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_setting_recommended)
      logic_setting_recommended:send_set_recommend_open_req(3, bValue and 1 or 0)
    end
  }
}
return Stack_Social