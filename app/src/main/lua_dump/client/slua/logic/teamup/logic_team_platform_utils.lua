local logic_team_platform_utils = {}
function logic_team_platform_utils.GetSaveFilterLangSwitch()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTeamPlatFormFilterLanguage)
  if saveData and saveData.teamPlatformFilterSwitch then
    return saveData.teamPlatformFilterSwitch == 1
  end
  return false
end
function logic_team_platform_utils.GetSaveFilterLanguageData(sceneType)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTeamPlatFormFilterLanguage)
  if saveData then
    local TeamPlatform_Macro = require("client.slua.logic.teamup.teamplatform_macro")
    if sceneType == TeamPlatform_Macro.Enum_FilterLanguage_Scene.Chat then
      return saveData.chatLanguageList
    else
      return saveData.teamPlatformLanguageList
    end
  end
  return nil
end
function logic_team_platform_utils.UpdateSaveFilterData(sceneType, languageList, isSwitchOpen)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTeamPlatFormFilterLanguage) or {}
  local TeamPlatform_Macro = require("client.slua.logic.teamup.teamplatform_macro")
  if sceneType == TeamPlatform_Macro.Enum_FilterLanguage_Scene.Chat then
    data.chatLanguageList = languageList
  else
    if isSwitchOpen then
      data.teamPlatformLanguageList = languageList
    end
    data.teamPlatformFilterSwitch = isSwitchOpen and 1 or 0
  end
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eTeamPlatFormFilterLanguage)
end
function logic_team_platform_utils.GetLangIdByName(name)
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  if not logic_chat_channel_world.language_data_list then
    log(bWriteLog and "[v_wllwu] logic_team_platform_utils.GetLangIdByName, logic_chat_channel_world.language_data_list is nil")
    return
  end
  local StringUtil = require("common.string_util")
  for _, v in ipairs(logic_chat_channel_world.language_data_list) do
    if string.find(v.name, ",") then
      local list = StringUtil.Split(v.name, ",")
      for i = 1, #list do
        if list[i] == name then
          return v.id
        end
      end
    elseif v.name == name then
      return v.id
    end
  end
  log(bWriteLog and "[v_wllwu] logic_team_platform_utils.GetLangIdByName, cannot find name is:" .. tostring(name))
  return nil
end
function logic_team_platform_utils.GetDefaultSelectData()
  local languageIdList = {}
  if DataMgr.MatchLanguage then
    for i = 1, 2 do
      if DataMgr.MatchLanguage[i] then
        table.insert(languageIdList, DataMgr.MatchLanguage[i])
      end
    end
  end
  log_tree(bWriteLog and "[v_wllwu] logic_team_platform_utils.GetDefaultSelectData, languageIdList is:", languageIdList)
  return languageIdList
end
function logic_team_platform_utils.GetLanguageNameById(langId)
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  if not logic_chat_channel_world.language_data_list then
    log(bWriteLog and "[v_wllwu] logic_team_platform_utils.GetLanguageNameById, logic_chat_channel_world.language_data_list is nil")
    return
  end
  for _, v in ipairs(logic_chat_channel_world.language_data_list) do
    if v.id == langId then
      return v.langName
    end
  end
  return nil
end
function logic_team_platform_utils.GetStrLanguageName(languageList)
  if not languageList or #languageList <= 0 then
    return
  end
  local strName
  for i, v in ipairs(languageList) do
    local singleName = logic_team_platform_utils.GetLanguageNameById(v)
    if i == 1 then
      strName = singleName
    else
      strName = LocUtil.LocalizeResFormat(7255, strName, singleName)
    end
  end
  return strName
end
function logic_team_platform_utils.IsCanFilterLanguage()
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if region == PublishRegionMacros.BLUEHOLE then
    return false
  end
  return true
end
function logic_team_platform_utils.FilterInvalidData(languageList)
  if not languageList or #languageList <= 0 then
    return languageList
  end
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if region == PublishRegionMacros.BLUEHOLE then
    local lang = {}
    local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
    local id = logic_team_platform_utils.GetLangIdByName(LanguageMacros.EN)
    if id then
      log(bWriteLog and "[v_wllwu] logic_team_platform_utils.FilterInvalidData, id is:" .. tostring(id))
      table.insert(lang, id)
    end
    return lang
  end
  local firstMatchLanguageId = DataMgr.MatchLanguage and DataMgr.MatchLanguage[1]
  if firstMatchLanguageId and languageList[1] ~= firstMatchLanguageId then
    local TableUtil = require("common.table_util")
    local index = TableUtil.Find(languageList, firstMatchLanguageId)
    if 0 < index then
      table.remove(languageList, index)
    end
    table.insert(languageList, 1, firstMatchLanguageId)
  end
  local maxCount = logic_team_platform_utils.GetMaxSelectLangCount()
  if maxCount < #languageList then
    for i = #languageList, maxCount, -1 do
      table.remove(languageList, i)
    end
  end
  return languageList
end
function logic_team_platform_utils.GetCurTeamPlatFormType()
  local TeamPlatform_Macro = require("client.slua.logic.teamup.teamplatform_macro")
  local logic_xmission_main = require("client.slua.logic.TxMission.logic_xmission_main")
  if logic_xmission_main.IsInXMission() then
    return TeamPlatform_Macro.Enum_PlatformType.TPlan
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  if LogicUGCMatch:GetMatchModID() > 0 or LogicUGCMulti.bIsBundleMatch then
    return TeamPlatform_Macro.Enum_PlatformType.WoW
  else
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    local isPakegame = logic_mode_selection:IsPeakGameView()
    if isPakegame then
      return TeamPlatform_Macro.Enum_PlatformType.Peak
    end
  end
  return TeamPlatform_Macro.Enum_PlatformType.Normal
end
function logic_team_platform_utils.UpdateLabelItem(Label_Item, itemData)
  log_tree(bWriteLog and "[v_wllwu] UpdateLabelItem", itemData)
  local UIUtil = require("client.common.ui_util")
  if not itemData then
    UIUtil.SetWidgetVisible(Label_Item, false)
    return
  end
  local evaluation = logic_team_platform_utils.GetEvaluation(itemData)
  if logic_team_platform_utils.CanShowEvaluationScore(evaluation) then
    Label_Item.WidgetSwitcher_Style:SetActiveWidgetIndex(1)
    Label_Item.TextBlock_Score:SetText(string.format("%.1f", evaluation.score))
    UIUtil.SetWidgetVisible(Label_Item, true)
    return
  end
  local recent_upvote = itemData.recent_upvote or 0
  if 0 < recent_upvote then
    Label_Item.WidgetSwitcher_Style:SetActiveWidgetIndex(0)
    Label_Item.TextBlock_Like:SetText(recent_upvote)
    UIUtil.SetWidgetVisible(Label_Item, true)
  else
    UIUtil.SetWidgetVisible(Label_Item, false)
  end
end
function logic_team_platform_utils.CanShowEvaluationScore(evaluation)
  if not evaluation or evaluation.score then
    return
  end
  local logic_team_evaluation_view = require("client.slua.logic.team_evaluation.logic_team_evaluation_view")
  local settingType = logic_team_evaluation_view.GetEntranceSettingType()
  if settingType == 0 then
    log(bWriteLog and "[v_wllwu] logic_team_platform_utils.CanShowEvaluationScore false")
    return
  end
  return true
end
function logic_team_platform_utils.GetZoneList()
  local logic_zone_delay = require("client.slua.logic.match.logic_zone_delay")
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local zoneID = ZoneSystem.GetChooseZone()
  local serverDelay = 0
  local fakeShowDelay = 360
  if zoneID then
    log(bWriteLog and "[v_wllwu] logic_team_platform_utils.GetZoneList, zoneID is:" .. tostring(zoneID))
    serverDelay = logic_zone_delay.GetZoneDelay(zoneID, fakeShowDelay, 10000)
    local logic_team_platform_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_platform_data)
    local maxDelayLimit = logic_team_platform_data:GetSelfZonePingCfgValue()
    if maxDelayLimit ~= 0 and serverDelay < maxDelayLimit then
      return
    end
  end
  local zoneList = {}
  local zoneToPingInfo = {}
  if zoneID then
    table.insert(zoneList, zoneID)
    zoneToPingInfo[zoneID] = serverDelay
  end
  local allZoneList = ZoneSystem.chooseZoneList
  if allZoneList and 0 < #allZoneList then
    for _, v in pairs(allZoneList) do
      if v.zone_id ~= zoneID then
        table.insert(zoneList, v.zone_id)
        zoneToPingInfo[v.zone_id] = logic_zone_delay.GetZoneDelay(v.zone_id, fakeShowDelay, 10000)
      end
    end
  end
  if 0 < #zoneList then
    table.sort(zoneList, function(a, b)
      local aDelay = zoneToPingInfo[a]
      local bDelay = zoneToPingInfo[b]
      return aDelay < bDelay
    end)
  end
  return zoneList
end
function logic_team_platform_utils.IsCurSelectMode(viewID, matchID)
  if not viewID or not matchID then
    return false
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local selectMatchId, selectViewId, viewIds = logic_mode_selection:GetCurSelectInfo()
  if selectMatchId ~= matchID then
    return false
  end
  if selectViewId and selectViewId == viewID then
    return true
  end
  if viewIds then
    for _, v in ipairs(viewIds) do
      if v == viewID then
        return true
      end
    end
  end
  return false
end
function logic_team_platform_utils.GetCurSelectModeList()
  local curSelectModeList = {}
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local selectMatchId, _, viewIds = logic_mode_selection:GetCurSelectInfo()
  if viewIds then
    for _, v in ipairs(viewIds) do
      local modeInfo = {
        [1] = selectMatchId,
        [2] = v
      }
      table.insert(curSelectModeList, modeInfo)
    end
  end
  return curSelectModeList
end
function logic_team_platform_utils.GetMaxSelectLangCount()
  return 3
end
function logic_team_platform_utils.GetEvaluation(data)
  if not data or not data.evaluation_base64bin then
    return
  end
  local base64 = require("client.slua.logic.lobby_watermark.base64")
  local evaluation = base64.decode(data.evaluation_base64bin)
  evaluation = evaluation and slua.LuaArchiverDecode(LuaStateWrapper, evaluation)
end
return logic_team_platform_utils