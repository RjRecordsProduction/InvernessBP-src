local logic_chat_extra = {}
local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
local PlanZModeID = 26001
function logic_chat_extra.CheckAndTLogMicVoice()
  local TimeUtil = require("client.common.time_util")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTeamVoiceTLog)
  if not saveData then
    return
  end
  local now = TimeUtil.GetServerTimeInSec()
  if TimeUtil.IsSameDay(saveData.lastTLogTime or 0, now) then
    return
  end
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_report_player_voice_status_in_team(saveData.lastTLogTime or 0, saveData.openVoiceDt or 0, saveData.openMicDt or 0, saveData.isVoiceOpen or 1, saveData.isMicOpen or 0)
  saveData = {}
  saveData.lastTLogTime = now
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eTeamVoiceTLog)
end
function logic_chat_extra.RecordVoiceTLog(enterBattle)
  if DataMgr.roleData.openID == nil or DataMgr.roleData.openID == 0 then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTeamVoiceTLog)
  saveData = saveData or {}
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  if not saveData.isVoiceOpen or saveData.isVoiceOpen == 0 then
    if logic_chat_voice:GetSpeakerState() then
      local TimeUtil = require("client.common.time_util")
      local now = TimeUtil.GetServerTimeInSec()
      if not saveData.openVoiceDt then
        saveData.openVoiceDt = 0
      end
      saveData.lastOpenVoiceTime = now
      saveData.isVoiceOpen = 1
      PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eTeamVoiceTLog)
    end
  else
    local TimeUtil = require("client.common.time_util")
    local now = TimeUtil.GetServerTimeInSec()
    if not saveData.openVoiceDt then
      saveData.openVoiceDt = 0
    end
    if saveData.lastOpenVoiceTime then
      saveData.openVoiceDt = saveData.openVoiceDt + (now - saveData.lastOpenVoiceTime)
    end
    if logic_chat_voice:GetSpeakerState() then
      saveData.isVoiceOpen = 1
    else
      saveData.isVoiceOpen = 0
    end
    if enterBattle then
      saveData.lastOpenVoiceTime = nil
    else
      saveData.lastOpenVoiceTime = now
    end
    PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eTeamVoiceTLog)
  end
end
function logic_chat_extra.RecordMicTLog(enterBattle)
  if DataMgr.roleData.openID == nil or DataMgr.roleData.openID == 0 then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTeamVoiceTLog)
  saveData = saveData or {}
  if not saveData.isMicOpen or saveData.isMicOpen == 0 then
    local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
    local openMicState = logic_chat_voice:GetMicState()
    if openMicState then
      local TimeUtil = require("client.common.time_util")
      local now = TimeUtil.GetServerTimeInSec()
      if not saveData.openMicDt then
        saveData.openMicDt = 0
      end
      saveData.lastOpenMicTime = now
      saveData.isMicOpen = 1
      PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eTeamVoiceTLog)
    end
  else
    local TimeUtil = require("client.common.time_util")
    local now = TimeUtil.GetServerTimeInSec()
    if not saveData.openMicDt then
      saveData.openMicDt = 0
    end
    if saveData.lastOpenMicTime then
      saveData.openMicDt = saveData.openMicDt + (now - saveData.lastOpenMicTime)
    end
    local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
    local openMicState = logic_chat_voice:GetMicState()
    if openMicState then
      saveData.isMicOpen = 1
    else
      saveData.isMicOpen = 0
    end
    if enterBattle then
      saveData.lastOpenMicTime = nil
    else
      saveData.lastOpenMicTime = now
    end
    PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eTeamVoiceTLog)
  end
end
function logic_chat_extra.RecordVoiceMicTLog(enterBattle)
  if enterBattle then
    logic_chat_extra.RecordVoiceTLog(true)
    logic_chat_extra.RecordMicTLog(true)
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() > 1 then
    logic_chat_extra.RecordVoiceTLog()
    logic_chat_extra.RecordMicTLog()
  else
    logic_chat_extra.RecordVoiceTLog(true)
    logic_chat_extra.RecordMicTLog(true)
  end
end
function logic_chat_extra.AddFriend(uid, clickSource)
  if "" == uid then
    return
  end
  local msgId = 2
  local fromType = BP_ENUM_ADD_FRIEND_FROM_CHAT
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if MatchModeMgrSystem.IsSocialIslandMode() then
    fromType = BP_ENUM_ADD_FRIEND_FROM_SOCIALISLAND
    msgId = 43
  elseif chat_macro.Channel.channelCorps == logic_chat_main.currentChannel then
    fromType = BP_ENUM_ADD_FRIEND_FROM_CORPS
    msgId = 20
  elseif chat_macro.Channel.channelChatRoom == logic_chat_main.currentChannel then
    msgId = 4
  elseif chat_macro.Channel.channelTeamRecruit == logic_chat_main.currentChannel then
    fromType = BP_ENUM_ADD_FRIEND_FROM_TEAMRECRUIT
    msgId = 36
  elseif chat_macro.Channel.channelClub == logic_chat_main.currentChannel then
    fromType = BP_ENUM_ADD_FRIEND_FROM_CLUB_CHAT
    msgId = 49
  else
    local modeID = MatchModeMgrSystem.nInGameModeID or 0
    if modeID == PlanZModeID then
      fromType = BP_ENUM_ADD_FRIEND_FROM_PLANZ
      msgId = 51
    end
  end
  local logic_lbs_friend = require("client.slua.logic.lbs.logic_lbs_friend")
  local bNearFriend = logic_lbs_friend:IsNearsFriend(uid)
  if bNearFriend then
    fromType = BP_ENUM_ADD_FRIEND_FROM_LBS
    msgId = 47
  end
  if clickSource and clickSource == chat_macro.CliSourceId.SocialCard then
    if DataMgr.roleData.gender == 1 then
      msgId = 59
    else
      msgId = 60
    end
    fromType = BP_ENUM_ADD_FRIEND_FROM_Chat_CARD_HEAD
  end
  local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
  logic_friend_apply:add_inner_friend_req(uid, "", fromType, msgId)
end
function logic_chat_extra.Translate(chatMsg)
  print(bWriteLog and "logic_chat_extra.Translate")
  chatMsg.translatting = true
  chatMsg.translateFirstLangauge = DataMgr.FirstSecondLanguage[1]
  local Text = logic_chat_extra.ProcTranslateText(chatMsg.msg)
  if Text == "" then
    local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
    logic_chat_extra.OnTranslate(true, LanguageMacros.EN, "", chatMsg)
    return
  end
  local TranslateMgr = require("client.slua.logic.translator.translate_mgr")
  TranslateMgr.Translate(Text, logic_chat_extra.OnTranslate, chatMsg)
end
function logic_chat_extra.ProcTranslateText(text)
  print(bWriteLog and "logic_chat_extra.ProcTranslateText text = " .. tostring(text))
  text = logic_chat_extra.ConvertPlainToHtml(text)
  print(bWriteLog and "logic_chat_extra.ProcTranslateText text 2 = " .. tostring(text))
  text = logic_chat_extra.RemoveHashTag(text)
  print(bWriteLog and "logic_chat_extra.ProcTranslateText text 3 = " .. tostring(text))
  text = logic_chat_extra.ConvertTextWithEmoji(text)
  print(bWriteLog and "logic_chat_extra.ProcTranslateText Text 4 = " .. tostring(text))
  text = logic_chat_extra.ConvertTextWithHorn(text)
  print(bWriteLog and "logic_chat_extra.ProcTranslateText text 5 = " .. tostring(text))
  return text
end
function logic_chat_extra.OnTranslate(IsSuccess, LanguageFrom, Text, chatMsg)
  log(bWriteLog and "OnTranslate:" .. tostring(chatMsg.msgChannel) .. ",level:" .. tostring(chatMsg.level))
  chatMsg.translatting = false
  if not IsSuccess then
  else
    local translate    translateText = logic_chat_extra.RevertTextWithEmoji(translateText)
    translateText = logic_chat_extra.ConvertHtmlToPlain(translateText)
    chatMsg.transOrOrgText = translateText
    chatMsg.languageFrom = LanguageFrom
  end
  EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_TRANSLATE_CALLBACK, chatMsg)
end
function logic_chat_extra.ConvertTextWithHorn(src)
  if not src then
    return ""
  end
  local dst = src
  local hornMsgPrefix = "<img src=\"Horn_Chat_Msg_Icon\"/> "
  if string.find(dst, hornMsgPrefix) then
    dst = string.gsub(dst, hornMsgPrefix, "", 1)
  end
  return dst
end
function logic_chat_extra.ConvertPlainToHtml(str)
  if not str then
    return ""
  end
  str = string.gsub(str, "&", "&amp;")
  str = string.gsub(str, "<", "&lt;")
  str = string.gsub(str, ">", "&gt;")
  str = string.gsub(str, "\\", "&#92;")
  return str
end
function logic_chat_extra.ConvertHtmlToPlain(str)
  if not str then
    return ""
  end
  str = string.gsub(str, "&#92;", "\\")
  str = string.gsub(str, "&gt;", ">")
  str = string.gsub(str, "&lt;", "<")
  str = string.gsub(str, "&amp;", "&")
  return str
end
function logic_chat_extra.ConvertTextWithEmoji(src)
  if not src then
    return ""
  end
  local dst = src
  for emoji in string.gmatch(src, "&lt;img src=\"Emoji1_22_%d+\"/&gt;") do
    dst = string.gsub(dst, emoji, "", 1)
  end
  return dst
end
function logic_chat_extra.RevertTextWithEmoji(src)
  if not src then
    return ""
  end
  local dst = src
  return dst
end
function logic_chat_extra.RemoveHashTag(src)
  if not src then
    return ""
  end
  local dst = src
  for hashTag in string.gmatch(src, "&lt;Topic_Name&gt;.-&lt;/&gt;") do
    local bgStr = "&lt;Topic_Name&gt;#"
    local edStr = "&lt;/&gt;"
    local i = string.find(hashTag, bgStr)
    i = i + #bgStr
    local j = string.find(hashTag, edStr)
    local tag = string.sub(hashTag, i, j - 1)
    dst = string.gsub(dst, hashTag, string.format("%s", tag), 1)
  end
  return dst
end
function logic_chat_extra.ConvertTextWithHashTag(src)
  if not src then
    return ""
  end
  local dst = src
  for hashTag in string.gmatch(src, "&lt;Topic_Name&gt;.-&lt;/&gt;") do
    local bgStr = "&lt;Topic_Name&gt;"
    local edStr = "&lt;/&gt;"
    local i = string.find(hashTag, bgStr)
    i = i + #bgStr
    local j = string.find(hashTag, edStr)
    local tag = string.sub(hashTag, i, j - 1)
    dst = string.gsub(dst, hashTag, string.format("<div class=\\\"notranslate\\\">%s</div>", tag), 1)
  end
  return dst
end
function logic_chat_extra.RevertTextWithHashTag(src)
  if not src then
    return ""
  end
  local dst = src
  for hashTag in string.gmatch(src, "<div class=\"notranslate\">.-</div>") do
    local tag = string.match(hashTag, "<div class=\"notranslate\">(.-)</div>")
    dst = string.gsub(dst, string.format("<div class=\"notranslate\">%s</div>", tag), string.format("&lt;Topic_Name&gt;%s&lt;/&gt;", tag), 1)
  end
  return dst
end
function logic_chat_extra.ParseUpassInfo(upassInfo)
  local is_buy = 0
  local is_uishow = false
  if upassInfo ~= nil then
    if upassInfo.switch_ui == nil then
      is_uishow = true
    else
      is_uishow = upassInfo.switch_ui or is_uishow
    end
    is_buy = upassInfo.is_buy or is_buy
    return is_buy, is_uishow and 1 or 0, upassInfo.keep_buy or 0, upassInfo.cur_value or 0, upassInfo.pass_type or 0
  end
  return 0, 0, 0, 0
end
return logic_chat_extra