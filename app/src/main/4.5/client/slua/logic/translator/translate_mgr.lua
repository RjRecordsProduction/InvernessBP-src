local TranslateMgr = {
  Callback = nil,
  WaitTranslate = nil,
  infoAccumulateID = 0,
  translationInfoMap = {},
  ERR_SUCCESS = 0,
  ERR_CHAT_TRANSLATE_FREQUENT = 101100004,
  RETRY_MAX_TIMES = 3,
  RETRY_SECOND = 3,
  retryTimes = 0,
  TRANSLATE_LIMIT_MILLISECOND = 1500,
  lastTranslateTimestamp = 0,
  lastTransTimeMap = {},
  beginTranslateTimestamp = 0,
  reportPingRate = 1,
  VIA_CLIENT = 0,
  VIA_SERVER = 1
}
local table_pool = require("common.table_pool")
local tablePool = table_pool.Create()
local GetAccessTokenHeaders = {
  ["Ocp-Apim-Subscription-Key"] = "07c1ba6329884d97bd7cb4ca462ed425"
}
local GetAccessToken = {
  URL = FuncUtil.GetDomainByID(3366013) .. "/sts/v1.0/issueToken",
  Verb = "POST",
  Content = ""
}
local DetectHeaders = {
  Authorization = "",
  ["Content-Type"] = "application/json"
}
local Detect = {
  URL = FuncUtil.GetDomainByID(3366092) .. "/detect?api-version=3.0",
  Verb = "POST",
  Content = ""
}
local TranslateHeaders = {
  Authorization = "",
  ["Content-Type"] = "application/json"
}
local Translate = {
  URL = "",
  URLOrigin = FuncUtil.GetDomainByID(3366092) .. "/translate?api-version=3.0",
  Verb = "POST",
  Content = ""
}
local ReportTranslatePing = function(ping, from, to, method)
  log(bWriteLog and "martinhtma ReportTranslatePing")
  if math.random(1, 100) <= TranslateMgr.reportPingRate then
    local ChatHandler = require("client.network.Protocol.ChatHandler")
    ChatHandler.send_report_translate_ping(ping, from, to, method)
  end
end
local TranslateViaServer = function(Content, callback, chatMsg)
  if type(callback) ~= "function" then
    log_error("[MHT]TranslateMgr.OnGetServerTranslate: callback is not a function!")
    return
  end
  local isLatestLimit = false
  local TimeUtil = require("client.common.time_util")
  local curTimestamp = TimeUtil.GetMiliseconds()
  local fromModule = chatMsg and chatMsg.fromModule
  if not fromModule and curTimestamp - TranslateMgr.lastTranslateTimestamp < TranslateMgr.TRANSLATE_LIMIT_MILLISECOND then
    isLatestLimit = true
  elseif fromModule and TranslateMgr.lastTransTimeMap[fromModule] and curTimestamp - TranslateMgr.lastTransTimeMap[fromModule] < TranslateMgr.TRANSLATE_LIMIT_MILLISECOND then
    isLatestLimit = true
  end
  if isLatestLimit then
    ShowNotice(119100008)
    callback(false, nil, nil, chatMsg)
    return
  end
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  if #logic_chat_channel_world.language_data_list == 0 then
    log(bWriteLog and "Translate BP_ChatLanguageDataList == 0")
    logic_chat_channel_world.topic_fetch_lang_list_req()
    TranslateMgr.WaitTranslate = {
      content = Content,
      cb = callback,
      arg = chatMsg
    }
    return
  end
  local FirstLanguage = {}
  FirstLanguage.id = 0
  FirstLanguage.name = ""
  for i, v in ipairs(logic_chat_channel_world.language_data_list) do
    if v.id == DataMgr.FirstSecondLanguage[1] then
      FirstLanguage = v
      if FirstLanguage.id == 103 then
        FirstLanguage.name = "zh-TW"
      end
      break
    end
  end
  local thisInfoID = TranslateMgr.infoAccumulateID
  local info = tablePool:Get()
  info.to = FirstLanguage.name
  local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
  if info.to == "my" then
    info.to = LanguageMacros.MS
  elseif info.to == "my-MM" then
    info.to = LanguageMacros.MY
  end
  info.content = Content
  info.arg = chatMsg
  info.sendTimestamp = TimeUtil.GetMiliseconds()
  function info.callback(IsSuccess, LanguageFrom, Text)
    callback(IsSuccess, LanguageFrom, Text, chatMsg)
  end
  TranslateMgr.translationInfoMap[thisInfoID] = info
  TranslateMgr.infoAccumulateID = TranslateMgr.infoAccumulateID + 1
  if fromModule then
    TranslateMgr.lastTransTimeMap[fromModule] = TimeUtil.GetMiliseconds()
    local UGCHandler = require("client.network.Protocol.UGCHandler")
    UGCHandler.send_ugc_translate_req(info.to, info.content, thisInfoID)
  else
    TranslateMgr.lastTranslateTimestamp = TimeUtil.GetMiliseconds()
    local ChatHandler = require("client.network.Protocol.ChatHandler")
    ChatHandler.send_chat_translate_req(info.to, info.content, thisInfoID)
  end
end
function TranslateMgr.OnGetTranslateViaServer(ret_code, msg_id, from, to, trans_key, trans_value)
  log(bWriteLog and string.format("[MHT]TranslateMgr.OnGetServerTranslate: ret_code = %s, trans_key = %s", ret_code, tostring(trans_key)))
  local info = TranslateMgr.translationInfoMap[msg_id]
  if not info then
    log_error(string.format("[MHT]TranslateMgr.OnGetServerTranslate: info doesn't exist! msg_id = %s", msg_id))
    return
  end
  local TimeUtil = require("client.common.time_util")
  local translatePing = TimeUtil.GetMiliseconds() - info.sendTimestamp
  if ret_code == TranslateMgr.ERR_SUCCESS then
    TranslateMgr.retryTimes = 0
    local LanguageFrom = from == "" and from or LocUtil.LocalizeResFormatByStr(from)
    LanguageFrom = LocUtil.LocalizeResFormat(1220, LanguageFrom)
    info.callback(true, LanguageFrom, trans_value)
    ReportTranslatePing(translatePing, from, to, TranslateMgr.VIA_SERVER)
  elseif ret_code == TranslateMgr.ERR_CHAT_TRANSLATE_FREQUENT and TranslateMgr.retryTimes < TranslateMgr.RETRY_MAX_TIMES then
    local time_ticker = require("common.time_ticker")
    local content = info.content
    local callback = info.callback
    local arg = info.arg
    time_ticker.AddTimerOnce(TranslateMgr.RETRY_SECOND, function()
      TranslateMgr.retryTimes = TranslateMgr.retryTimes + 1
      TranslateMgr.Translate(content, callback, arg)
    end)
  else
    TranslateMgr.retryTimes = 0
    ShowNotice(ret_code)
    info.callback(false, nil, nil, info.arg)
  end
  tablePool:Recycle(TranslateMgr.translationInfoMap[msg_id])
  TranslateMgr.translationInfoMap[msg_id] = nil
end
local GetTranslator = function()
  local UIUtil = require("client.common.ui_util")
  local _GameFrontendHUD = UIUtil.GetGameInstance():GetAssociatedFrontendHUD()
  if _GameFrontendHUD then
    return _GameFrontendHUD:GetTranslator()
  end
  return nil
end
function TranslateMgr.CheckContinueTranslate()
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  if #logic_chat_channel_world.language_data_list > 0 then
    if TranslateMgr.WaitTranslate ~= nil then
      TranslateMgr.Translate(TranslateMgr.WaitTranslate.content, TranslateMgr.WaitTranslate.cb, TranslateMgr.WaitTranslate.arg)
      TranslateMgr.WaitTranslate = nil
    end
    return
  end
end
function TranslateMgr.Translate(Content, callback, chatMsg)
  local switch = LobbySystem.CheckOpen(BP_ENUM_TRANSLATE_VIA_SERVER_SWITCH)
  if switch then
    TranslateViaServer(Content, callback, chatMsg)
    return
  end
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  if #logic_chat_channel_world.language_data_list == 0 then
    log(bWriteLog and "Translate BP_ChatLanguageDataList == 0")
    logic_chat_channel_world.topic_fetch_lang_list_req()
    TranslateMgr.WaitTranslate = {
      content = Content,
      cb = callback,
      arg = chatMsg
    }
    return
  end
  Content = "[{\"Text\":\"" .. Content .. "\"}]"
  local Translator = GetTranslator()
  if Translator then
    if Translator:HasTranslating() then
      log(bWriteLog and "Translate HasTranslating")
      if callback ~= nil then
        callback(false, "", "", chatMsg)
      end
      return
    end
    function TranslateMgr.Callback(IsSuccess, LanguageFrom, Text)
      callback(IsSuccess, LanguageFrom, Text, chatMsg)
    end
    Detect.    Translate.    log(bWriteLog and "Translate:" .. tostring(Translator.SubscriptionKey))
    GetAccessTokenHeaders["Ocp-Apim-Subscription-Key"] = Translator.SubscriptionKey
    local TimeUtil = require("client.common.time_util")
    TranslateMgr.beginTranslateTimestamp = TimeUtil.GetMiliseconds()
    Translator.OnGetAccessTokenDelegate:Bind(TranslateMgr._OnGetAccessToken)
    Translator:GetAccessToken(false, GetAccessToken.URL, GetAccessToken.Verb, GetAccessTokenHeaders, GetAccessToken.Content)
  end
end
function TranslateMgr._OnGetAccessToken(IsSuccess, Token)
  local Translator = GetTranslator()
  if Translator then
    Translator.OnGetAccessTokenDelegate:Clear()
  end
  if not IsSuccess then
    if TranslateMgr.Callback ~= nil then
      TranslateMgr.Callback(false, "", "")
      TranslateMgr.Callback = nil
    end
    log(bWriteLog and "Translate OnGetAccessToken not IsSuccess")
    return
  end
  DetectHeaders.Authorization = Token
  TranslateHeaders.Authorization = Token
  if Translator then
    Translator.OnDetectDelegate:Bind(TranslateMgr._OnDetect)
    log(bWriteLog and "Translate OnGetAccessToken IsSuccess to Detect:" .. tostring(Detect.Content))
    Translator:Detect(Detect.URL, Detect.Verb, DetectHeaders, Detect.Content)
  end
end
function TranslateMgr._OnDetect(IsSuccess, From, To)
  local Translator = GetTranslator()
  if Translator then
    Translator.OnDetectDelegate:Clear()
  end
  if not IsSuccess then
    if TranslateMgr.Callback ~= nil then
      TranslateMgr.Callback(IsSuccess, "", "")
      TranslateMgr.Callback = nil
    end
    log(bWriteLog and "Translate OnDetect not IsSuccess")
    return
  end
  local FirstLanguage = {}
  FirstLanguage.id = 0
  FirstLanguage.name = ""
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  for i, v in ipairs(logic_chat_channel_world.language_data_list) do
    if v.id == DataMgr.FirstSecondLanguage[1] then
      FirstLanguage = v
      if FirstLanguage.id == 103 then
        FirstLanguage.name = "zh-TW"
      end
      break
    end
  end
  Translate.URL = Translate.URLOrigin .. "&from=" .. From .. "&to=" .. FirstLanguage.name .. "&textType=html"
  if Translator then
    Translator.OnTranslateDelegate:Bind(TranslateMgr._OnTranslate)
    log(bWriteLog and "Translate OnDetect IsSuccess to Translate:" .. tostring(Translate.Content))
    Translator:Translate(Translate.URL, Translate.Verb, TranslateHeaders, Translate.Content)
  end
end
function TranslateMgr._OnTranslate(IsSuccess, from, Text)
  log(bWriteLog and "martinhtma LanguageFrom: " .. from)
  local TimeUtil = require("client.common.time_util")
  local translatePing = TimeUtil.GetMiliseconds() - TranslateMgr.beginTranslateTimestamp
  local FirstLanguage = {}
  FirstLanguage.id = 0
  FirstLanguage.name = ""
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  for i, v in ipairs(logic_chat_channel_world.language_data_list) do
    if v.id == DataMgr.FirstSecondLanguage[1] then
      FirstLanguage = v
      if FirstLanguage.id == 103 then
        FirstLanguage.name = "zh-TW"
      end
      break
    end
  end
  local LanguageFrom = LocUtil.LocalizeResFormatByStr(from)
  LanguageFrom = LocUtil.LocalizeResFormat(1220, LanguageFrom)
  local Translator = GetTranslator()
  if Translator then
    Translator.OnTranslateDelegate:Clear()
  end
  log(bWriteLog and "Translate OnTranslate IsSuccess:" .. tostring(IsSuccess) .. ",LanguageFrom:" .. tostring(from) .. ",Text:" .. tostring(Text))
  if TranslateMgr.Callback ~= nil then
    TranslateMgr.Callback(IsSuccess, LanguageFrom, Text)
    TranslateMgr.Callback = nil
  end
  ReportTranslatePing(translatePing, from, FirstLanguage.name, TranslateMgr.VIA_CLIENT)
end
return TranslateMgr