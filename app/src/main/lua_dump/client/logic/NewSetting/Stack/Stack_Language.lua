local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")
local _isNotBluehole = function()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  return Client.GetPublishRegion() ~= PublishRegionMacros.BLUEHOLE
end
local _isNotBlueholeAndNotWoW = function()
  return _isNotBluehole() and not IsWoWEditor
end
local _getLanguageName = function(tableName, index)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  local dataSource = Client.GetPublishRegion() ~= PublishRegionMacros.BLUEHOLE and logic_chat_channel_world.language_data_list or CDataTable.GetTable("BlueHoleMatchLang")
  local dataMap = {}
  for k, v in pairs(dataSource) do
    dataMap[v.id] = v
  end
  local str_empty = LocUtil.GetLocalizeResStr(5201)
  local preLang
  local indexList = {1, 2}
  local dataTable = DataMgr and DataMgr[tableName]
  dataTable = dataTable or {}
  local isFitVersion = PublishRegionMacros.IsFITVersion()
  local isLocResExist = Client.CheckLocalizationExist()
  local LanguageDownload = require("client.slua.logic.download.recommend.logic_language_download")
  local langName = str_empty or ""
  for i, v in ipairs(indexList) do
    local id = dataTable[v]
    local data = dataMap[id]
    langName = str_empty or ""
    if data then
      local lang = data.langName
      if isFitVersion and LanguageDownload.IsNeedDownload(data.name, nil) and not isLocResExist then
        lang = "English"
        dataTable[v] = 104
      end
      if lang ~= preLang then
        langName = lang
      else
        dataTable[v] = nil
      end
    end
    if index == 1 then
      log(bWriteLog and string.format("Stack_Language:_getLanguageName tableName = %s index = %s langName = %s", tableName, index, langName))
      return langName
    end
    preLang = langName
  end
  log(bWriteLog and string.format("Stack_Language:_getLanguageName tableName = %s index = %s langName = %s", tableName, index, langName))
  return langName
end
local _showSelectLanguageUI = function(index)
  if IsWoWEditor then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.ui_select_language, index - 1, false, index == 4 or index == 5)
end
local Stack_Language = {
  {
    UI = AliasMap.Title,
    Text = 34637,
    Help = 87474,
    VisibilityFunc = _isNotBluehole
  },
  {
    Key = "OpenWindowInterfaceLanguage",
    UI = AliasMap.OpenWindow,
    Text = 34637,
    GetFunc = function()
      local UELanguageUtilityMethods = import("UELanguageUtilityMethods")
      local cur_language = UELanguageUtilityMethods.GetCurrentLanguageName()
      local tab_name = FuncUtil.GetLanguageTableName()
      local languageList = CDataTable.GetTable(tab_name)
      for k, v in pairs(languageList) do
        if cur_language and v.languageCode and cur_language == v.languageCode then
          local disPlayName = v.disPlayName
          local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
          local isFitVersion = PublishRegionMacros.IsFITVersion()
          local isLocResExist = Client.CheckLocalizationExist()
          if isFitVersion and not isLocResExist and disPlayName ~= "English" then
            disPlayName = "English"
          end
          return disPlayName or ""
        end
      end
      return ""
    end,
    SetFunc = function()
      _showSelectLanguageUI(1)
    end,
    VisibilityFunc = _isNotBluehole
  },
  {
    Key = "OpenWindowTimeFormat",
    UI = AliasMap.OpenWindow,
    Text = 29762,
    EventType = EVENTTYPE_SETTING,
    EventID = EVENTID_SETTING_CHANGE_TIME_DISPLAY,
    GetFunc = function()
      local SettingTimeDisplay = require("client.logic.setting.logic_setting_time_display")
      return LocUtil.LocalizeResFormat("25262", SettingTimeDisplay.dateFormat)
    end,
    SetFunc = function()
      UIManager.ShowUI(UIManager.UI_Config.setting_change_timedisplay)
    end
  },
  {
    UI = AliasMap.Spacer
  },
  {
    UI = AliasMap.Title,
    Text = 34638,
    Help = 87475,
    VisibilityFunc = _isNotBlueholeAndNotWoW
  },
  {
    Key = "OpenWindowChatLanguage",
    UI = AliasMap.OpenWindow,
    Text = 87478,
    EventType = EVENTTYPE_CHAT,
    EventID = EVENTID_CHAT_LANGUAGE_SELECT_CHANGE,
    GetFunc = function()
      return _getLanguageName("FirstSecondLanguage", 1)
    end,
    SetFunc = function()
      _showSelectLanguageUI(2)
    end,
    VisibilityFunc = _isNotBlueholeAndNotWoW
  },
  {
    Key = "OpenWindowChatLanguageSecond",
    UI = AliasMap.OpenWindow,
    Text = 87479,
    EventType = EVENTTYPE_CHAT,
    EventID = EVENTID_CHAT_LANGUAGE_SELECT_CHANGE,
    GetFunc = function()
      return _getLanguageName("FirstSecondLanguage", 2)
    end,
    SetFunc = function()
      _showSelectLanguageUI(3)
    end,
    VisibilityFunc = _isNotBlueholeAndNotWoW
  },
  {
    UI = AliasMap.Spacer,
    VisibilityFunc = function()
      return not IsWoWEditor
    end
  },
  {
    Key = "TitleMatchLanguage",
    UI = AliasMap.TitleSwitcher,
    Text = 34639,
    Help = 87476,
    EventType = EVENTTYPE_MATCH,
    EventID = EVENTID_MATCH_UPDATE_LANGUAGE,
    GetFunc = function()
      return DataMgr.MatchLanguage.only_match
    end,
    SetFunc = function(key, bValue)
      local LanguageSelectSystem = require("client.logic.language_select.logic__language_select")
      LanguageSelectSystem.MatchLanguageSelectReq(DataMgr.MatchLanguage[1], DataMgr.MatchLanguage[2], bValue, DataMgr.MatchLanguage and DataMgr.MatchLanguage.lang_timeout or false)
    end,
    ExpandIndex = 0,
    VisibilityFunc = function()
      return not IsWoWEditor
    end
  },
  {
    Key = "OpenWindowMatchLanguageFirst",
    UI = AliasMap.OpenWindow,
    Text = 87478,
    EventType = EVENTTYPE_MATCH,
    EventID = EVENTID_MATCH_UPDATE_LANGUAGE,
    GetFunc = function()
      return _getLanguageName("MatchLanguage", 1)
    end,
    SetFunc = function()
      _showSelectLanguageUI(4)
    end,
    ExpandHandle = "TitleMatchLanguage",
    VisibilityFunc = function()
      return not IsWoWEditor
    end
  },
  {
    Key = "OpenWindowMatchLanguageSecond",
    UI = AliasMap.OpenWindow,
    Text = 87479,
    EventType = EVENTTYPE_MATCH,
    EventID = EVENTID_MATCH_UPDATE_LANGUAGE,
    GetFunc = function()
      return _getLanguageName("MatchLanguage", 2)
    end,
    SetFunc = function()
      _showSelectLanguageUI(5)
    end,
    ExpandHandle = "TitleMatchLanguage",
    VisibilityFunc = function()
      return not IsWoWEditor
    end
  },
  {
    UI = AliasMap.Spacer,
    VisibilityFunc = function()
      return not IsWoWEditor
    end
  },
  {
    UI = AliasMap.Title,
    Text = 8600145,
    Help = 87477,
    VisibilityFunc = _isNotBluehole
  },
  {
    Key = "WoWOutsideAutoTranslate",
    UI = AliasMap.Switcher,
    Text = 67953,
    GetFunc = function()
      local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
      if not LogicUGC then
        return false
      end
      return LogicUGC:GetClientOutsideAutoTransEnabled()
    end,
    SetFunc = function(key, bValue)
      local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
      LogicUGC:SetOutsideNewPoint()
      LogicUGC:SetClientOutsideAutoTransEnabled(bValue)
      local reason = bValue
      local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.UGC_Click_OutsideTranslate, reason, "Setting_OutsideAutoTranslate")
      return true
    end,
    VisibilityFunc = _isNotBluehole
  }
}
return Stack_Language