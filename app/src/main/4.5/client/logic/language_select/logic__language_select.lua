local LanguageSelectSystem = {
  secondDefautLanguageName = "",
  chatLanguageSelected_1 = "",
  chatLanguageSelected_2 = "",
  firstMatchLanguageName = ""
}
function LanguageSelectSystem.Init()
  LanguageSelectSystem.secondDefautLanguageName = LocUtil.GetLocalizeResStr(5201)
  LanguageSelectSystem.team_match_langs = {}
  LanguageSelectSystem.bIsTeamMatchLeader = false
end
function LanguageSelectSystem.PopForbidTipLanguage()
  ShowNotice(5043)
end
function LanguageSelectSystem.topic_fetch_lang_list_rsp(list, timeSpan)
end
function LanguageSelectSystem.ChatLanguageSelectReq(id1, id2)
  if nil ~= id1 then
    local LanguageHandler = require("client.network.Protocol.LanguageHandler")
    LanguageHandler.send_set_player_langs_req(id1, id2)
  end
end
function LanguageSelectSystem.set_player_langs_rsp(err_code, data)
  log_tree("set_player_langs_rsp" .. tostring(err_code), data)
  if err_code == 0 then
    DataMgr.FirstSecondLanguage = data
  end
  EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_LANGUAGE_SELECT_CHANGE)
  local LogicUGCTrans = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCTrans)
  LogicUGCTrans:ClearMap()
end
function LanguageSelectSystem.MatchLanguageSelectReq(id1, id2, onlymatch, lang_timeout)
  log(bWriteLog and "match id1:" .. tostring(id1) .. " id2:" .. tostring(id2))
  if nil ~= id1 then
    local LanguageHandler = require("client.network.Protocol.LanguageHandler")
    LanguageHandler.send_set_player_match_langs_req(id1, id2, onlymatch, lang_timeout)
  end
end
function LanguageSelectSystem.set_player_match_langs_rsp(err_code, data)
  log_tree("set_player_match_langs_rsp:", data)
  if err_code == 0 then
    DataMgr.MatchLanguage = data
    LanguageSelectSystem.OnSyncFirstMatchLanguage()
  end
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_LANGUAGE)
end
function LanguageSelectSystem.set_player_ugc_match_langs_req(only_match, ugc_lang_timeout)
  log(bWriteLog and "[v_yibxu] LanguageSelectSystem.set_player_ugc_match_langs_req  only_match = " .. tostring(only_match))
  local LanguageHandler = require("client.network.Protocol.LanguageHandler")
  LanguageHandler.send_set_player_ugc_match_langs_req(only_match, ugc_lang_timeout)
end
function LanguageSelectSystem.set_player_ugc_match_langs_rsp(data)
  log_tree("[v_yibxu] LanguageSelectSystem.set_player_ugc_match_langs_rsp data = ", data)
  DataMgr.MatchLanguage = data
  LanguageSelectSystem.OnSyncFirstMatchLanguage()
end
local getSplitTable = function(str, split_char)
  local list = {}
  if str == nil or str == "" then
    return list
  end
  while true do
    local pos = string.find(str, split_char)
    if not pos then
      list[#list + 1] = str
      break
    end
    local sub_str = string.sub(str, 1, pos - 1)
    list[#list + 1] = sub_str
    str = string.sub(str, pos + 1, #str)
  end
  return list
end
function LanguageSelectSystem.sync_chat_with_match_langs()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSyncMatchAndChatLanguage)
  local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
  if info and info.languageCode and info.languageCode ~= "" then
    log(bWriteLog and "[v_wllwu] LanguageSelectSystem.sync_chat_with_match_langs" .. tostring(info.languageCode))
    local id
    local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
    for i, v in ipairs(logic_chat_channel_world.language_data_list) do
      if v.name then
        if info.languageCode ~= LanguageMacros.MY then
          if v.name == info.languageCode or v.name == "my" and info.languageCode == LanguageMacros.MS then
            id = v.id
            break
          end
        elseif v.name == "my-MM" and info.languageCode == LanguageMacros.MY then
          id = v.id
          break
        end
      end
      if string.find(v.name, ",") then
        local list = getSplitTable(v.name, ",")
        local isFind = false
        for i = 1, #list do
          if list[i] == info.languageCode then
            id = v.id
            isFind = true
            break
          end
        end
        if isFind then
          break
        end
      end
    end
    if id then
      local second_chat_id = DataMgr.FirstSecondLanguage[2]
      local second_match_id = DataMgr.MatchLanguage[2]
      if type(second_chat_id) == type(id) and second_chat_id == id then
      elseif DataMgr.FirstSecondLanguage[1] ~= id then
        LanguageSelectSystem.ChatLanguageSelectReq(id, second_chat_id)
      end
      if type(second_match_id) == type(id) and second_match_id == id then
      elseif DataMgr.MatchLanguage[1] ~= id then
        LanguageSelectSystem.MatchLanguageSelectReq(id, second_match_id, false)
      end
    end
  end
  PlayerPrefsSystem.SaveTableToFile_N({}, PlayerPrefsSystem.ePlayerPrefsType.eSyncMatchAndChatLanguage)
end
function LanguageSelectSystem.OpenMatchLanguageSelect()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    return
  end
  local sameLanguageType = false
  if DataMgr.MatchLanguage then
    sameLanguageType = DataMgr.MatchLanguage.only_match or false
  end
  UIManager.ShowUI(UIManager.UI_Config.ui_match_language_select, sameLanguageType)
end
function LanguageSelectSystem.GetLanguageStrByName(name)
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  if not name or not logic_chat_channel_world.language_data_list then
    return
  end
  for i, v in ipairs(logic_chat_channel_world.language_data_list) do
    if v.name and v.name == name then
      return v.langName or ""
    end
  end
  return ""
end
function LanguageSelectSystem.OnSyncFirstMatchLanguage()
  LanguageSelectSystem.UpdateFirstMatchLanguageName()
  local logic_team_platform_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_platform_data)
  logic_team_platform_data:RefreshCurSelectFilterLanguage()
  local logic_chat_filter_language = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_filter_language)
  logic_chat_filter_language:RefreshCurSelectFilterLanguage()
end
function LanguageSelectSystem.UpdateFirstMatchLanguageName()
  log(bWriteLog and "[v_wllwu]  LanguageSelectSystem.UpdateFirstMatchLanguageName" .. tostring(DataMgr.MatchLanguage[1]))
  if not DataMgr.MatchLanguage or not DataMgr.MatchLanguage[1] then
    log(bWriteLog and "[v_wllwu] LanguageSelectSystem.UpdateFirstMatchLanguageName DataMgr.MatchLanguage[1] is nil !!!")
    LanguageSelectSystem.firstMatchLanguageName = ""
    return
  end
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  if not logic_chat_channel_world.language_data_list then
    LanguageSelectSystem.firstMatchLanguageName = ""
    log(bWriteLog and "[v_wllwu] LanguageSelectSystem.UpdateFirstMatchLanguageName logic_chat_channel_world.language_data_list is nil !!!")
    return
  end
  for _, v in ipairs(logic_chat_channel_world.language_data_list) do
    if v.id == DataMgr.MatchLanguage[1] then
      LanguageSelectSystem.firstMatchLanguageName = v.name
      break
    end
  end
  log(bWriteLog and "[v_wllwu] LanguageSelectSystem.UpdateFirstMatchLanguageName, firstMatchLanguageName = " .. tostring(LanguageSelectSystem.firstMatchLanguageName))
end
function LanguageSelectSystem.GetFirstMatchLanguageName()
  return LanguageSelectSystem.firstMatchLanguageName
end
function LanguageSelectSystem.on_match_langs_change_notify(match_langs)
  log_tree(bWriteLog and "logic__language_select on_match_langs_change_notify", match_langs)
  LanguageSelectSystem.team_  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_LANGUAGE_TEAM)
end
function LanguageSelectSystem.GetTeamMatchLanguage()
  log_tree(bWriteLog and "logic__language_select GetTeamMatchLanguage", LanguageSelectSystem.team_match_langs)
  return LanguageSelectSystem.team_match_langs
end
function LanguageSelectSystem.send_query_match_langs_req()
  log(bWriteLog and "logic__language_select send_query_match_langs_req")
  local LanguageHandler = require("client.network.Protocol.LanguageHandler")
  LanguageHandler.send_query_match_langs_req()
end
function LanguageSelectSystem.on_query_match_langs_rsp(match_langs, bIsLeader)
  log(bWriteLog and "logic__language_select query_match_langs_rsp bIsLeader =", tostring(bIsLeader))
  log_tree(bWriteLog and "logic__language_select query_match_langs_rsp", match_langs)
  LanguageSelectSystem.bIsTeamMatchLeader = bIsLeader
  LanguageSelectSystem.team_  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_LANGUAGE_TEAM)
end
return LanguageSelectSystem