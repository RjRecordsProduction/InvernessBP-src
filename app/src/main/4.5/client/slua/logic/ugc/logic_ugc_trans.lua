local LogicUGCTrans = {}
local C_BatchTranslateMaxNum = 10
local C_SerializeCD = 60
function LogicUGCTrans:DefineAndResetData()
  self.TransMap = {}
  self.TransState = {}
  self.AutoTransQueue = {}
  self.bIsTranslate = false
  self.TranslateTimer = nil
  self.bWaitTranslate = false
  self.WaitTranslateTimer = nil
  self.MaxTransCacheCount = 2000
  self.TranCacheReductionFactor = 0.5
  self.TransCacheCount = 0
  self.TranslateLanguage = ""
  self.bTransCacheChanged = false
  self.TranslateSerializeTimer = nil
end
function LogicUGCTrans:OnInitialize()
  log(bWriteLog and "[edward] LogicUGCTrans:OnInitialize")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  self.TransMap = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCTranslate) or {}
  self.TranslateLanguage = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCTranslateLanguage) or ""
  self.bTransCacheChanged = false
end
function LogicUGCTrans:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_CHAT, EVENTID_CHAT_TRANSLATE_CALLBACK, self.OnTransRsp, self)
end
function LogicUGCTrans:OnLogOut()
end
function LogicUGCTrans:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and "[edward] LogicUGCTrans:OnPreSwitchGameStatus, preState, nextState = " .. string.format("%s-%s", preState, nextState))
  if self.TranslateSerializeTimer then
    self:RemoveTimer(self.TranslateSerializeTimer)
    self.TranslateSerializeTimer = nil
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    self:SerializeTranslate()
  end
end
function LogicUGCTrans:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "[edward] LogicUGCTrans:OnPostSwitchGameStatus, preState, nextState = " .. string.format("%s-%s", preState, nextState))
  if nextState == GameStatus.Lobby and self.TranslateSerializeTimer == nil then
    self.TranslateSerializeTimer = self:AddTimerLoop(C_SerializeCD, function()
      if self.bTransCacheChanged then
        self:SerializeTranslate()
      end
    end, TIMER_INFINITE, C_SerializeCD)
  end
end
function LogicUGCTrans:ClearMap()
  self.TransMap = {}
  self.TransState = {}
  self.TransCacheCount = 0
  self.bIsTranslate = false
  if self.TranslateTimer then
    self:RemoveTimer(self.TranslateTimer)
    self.TranslateTimer = nil
  end
  self.bWaitTranslate = false
  if self.WaitTranslateTimer then
    self:RemoveTimer(self.WaitTranslateTimer)
    self.WaitTranslateTimer = nil
  end
  self.FirstTranslateLanguage = nil
  self.TranslateLanguage = ""
  self:SerializeTranslate()
end
function LogicUGCTrans:_SetMaxTransCount(count)
  if not (count and tonumber(count)) or tonumber(count) <= 0 then
    return
  end
  self.MaxTransCacheCount = tonumber(count)
end
function LogicUGCTrans:SetStrTransState(str, bIsForbidden)
  self.TransState[str] = bIsForbidden
  EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_UGC_TRANSLATE_STATE_CHANGE, str, bIsForbidden)
end
function LogicUGCTrans:TransString(str, moduleName)
  if not self:CheckIsOpen() then
    log(bWriteLog and "LogicUGCTrans:TransString SWITCH CLOSE")
    return
  end
  if not str or str == "" or not moduleName then
    log(bWriteLog and "LogicUGCTrans:TransString invalid params")
    return
  end
  if self.TransMap[str] and self.TransMap[str].transOrOrgText then
    self:RefreshTransStrUseTimeStamp(str)
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_UGC_TRANSLATE_CALLBACK, self.TransMap[str])
  else
    local chatMsg = {msg = str, fromModule = moduleName}
    local logic_chat_extra = require("client.slua.logic.lobby_chat.logic_chat_extra")
    logic_chat_extra.Translate(chatMsg)
  end
end
function LogicUGCTrans:PreTransString(Strings)
  if not Strings or not next(Strings) then
    log(bWriteLog and "LogicUGCTrans:PreTransString invalid params")
    return nil
  end
  local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
  local TransList = {}
  for k, v in ipairs(Strings) do
    if self.TransMap[v] and self.TransMap[v].transOrOrgText then
      self:RefreshTransStrUseTimeStamp(v)
      EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_UGC_TRANSLATE_CALLBACK, self.TransMap[v])
    elseif v == "" then
      local SingleMsg = {
        msg = v,
        languageFrom = LanguageMacros.EN,
        transOrOrgText = v
      }
      self:OnTransRsp(nil, nil, SingleMsg)
    else
      table.insert(TransList, v)
    end
  end
  return TransList
end
function LogicUGCTrans:TransStringBatch(Strings, ModuleName, bAutoTrans, TargetLang, bIsUseNewMsg)
  if not self:CheckIsOpen() then
    log(bWriteLog and "LogicUGCTrans:TransStringBatch SWITCH CLOSE")
    return
  end
  self.bWaitTranslate = false
  if self.WaitTranslateTimer then
    self:RemoveTimer(self.WaitTranslateTimer)
    self.WaitTranslateTimer = nil
  end
  local TransList = self:PreTransString(Strings)
  local bIsOnlyAddQueue = false
  if self.bIsTranslate then
    bIsOnlyAddQueue = true
  end
  if not bAutoTrans then
    if not TransList or #TransList == 0 then
      return
    end
    local TimeUtil = require("client.common.time_util")
    local CurTimestamp = TimeUtil.GetMiliseconds()
    local TranslateMgr = require("client.slua.logic.translator.translate_mgr")
    if CurTimestamp - TranslateMgr.lastTranslateTimestamp < TranslateMgr.TRANSLATE_LIMIT_MILLISECOND then
      ShowNotice(TranslateMgr.ERR_CHAT_TRANSLATE_FREQUENT)
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_TRANSLATE_FREQUENT, ModuleName, Strings)
      return
    end
  end
  if TransList and 0 < #TransList then
    table.insert(self.AutoTransQueue, {msg = TransList, fromModule = ModuleName})
  end
  if bIsOnlyAddQueue then
    return
  end
  local FirstLanguage = self:GetFirstTranslateLanguage()
  if not FirstLanguage then
    return
  end
  self:CheckCacheLanguageChanged(FirstLanguage)
  local TransNum = 0
  local FinalTransList = {}
  for i = #self.AutoTransQueue, 1, -1 do
    local Queue = self.AutoTransQueue[i]
    while 0 < #Queue.msg and not (TransNum >= C_BatchTranslateMaxNum) do
      table.insert(FinalTransList, table.remove(Queue.msg))
      TransNum = TransNum + 1
    end
    if #Queue.msg == 0 then
      table.remove(self.AutoTransQueue)
    end
    if TransNum >= C_BatchTranslateMaxNum then
      break
    end
  end
  if self.TranslateTimer then
    self:RemoveTimer(self.TranslateTimer)
    self.TranslateTimer = nil
  end
  if 0 < #FinalTransList then
    self.bIsTranslate = true
    local logic_ugc_comment_macro = require("client.slua.logic.ugc.comment.logic_ugc_comment_macro")
    self.TranslateTimer = self:AddTimerOnce(logic_ugc_comment_macro.TranslateLimitTime, function()
      self.bIsTranslate = false
      self:TransStringBatch(nil, nil, true)
    end)
    local ToLanguage = TargetLang or FirstLanguage.name
    if ToLanguage ~= "" then
      if not bIsUseNewMsg then
        local UGCHandler = require("client.network.Protocol.UGCHandler")
        UGCHandler.send_ugc_translate_batch_req(ToLanguage, FinalTransList, 0)
      else
        local transText = FinalTransList[1]
        if transText and transText ~= "" then
          local PHomeKeeperAIHandler = require("client.network.Protocol.PHomeKeeperAIHandler")
          PHomeKeeperAIHandler.send_manor_aigc_translate_req(ToLanguage, FinalTransList[1], 0)
        end
      end
    else
      log(bWriteLog and "[edward] LogicUGCTrans:TransStringBatch, FirstLanguage = " .. tostring(FirstLanguage.name))
      log(bWriteLog and "[edward] LogicUGCTrans:TransStringBatch, ModuleName = " .. tostring(ModuleName))
      log(bWriteLog and "[edward] LogicUGCTrans:TransStringBatch, " .. debug.traceback())
    end
    log(bWriteLog and string.format("[edward] LogicUGCTrans:TransStringBatch, ToLanguage = %s", ToLanguage))
    log(bWriteLog and "[edward] LogicUGCTrans:TransStringBatch, TransNum = " .. #FinalTransList)
  end
  if 0 < #self.AutoTransQueue then
    self.bWaitTranslate = true
  end
end
function LogicUGCTrans:StopTransStringBatch(ModuleName)
  if not self:CheckIsOpen() then
    return
  end
  self.bWaitTranslate = false
  if self.WaitTranslateTimer then
    self:RemoveTimer(self.WaitTranslateTimer)
    self.WaitTranslateTimer = nil
  end
  local TransListInfo = self.AutoTransQueue[#self.AutoTransQueue]
  if TransListInfo and TransListInfo.fromModule and TransListInfo.fromModule == ModuleName then
    table.remove(self.AutoTransQueue)
  end
end
function LogicUGCTrans:CheckContinueTranslate()
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  if #logic_chat_channel_world.language_data_list > 0 and self.bWaitTranslate then
    self.bWaitTranslate = false
    self:TransStringBatch(nil, nil, true)
  end
end
function LogicUGCTrans:on_ugc_translate_batch_rsp(msg_id, from, to, trans_keys, trans_values)
  local LanguageFrom = from == "" and from or LocUtil.LocalizeResFormatByStr(from)
  LanguageFrom = LocUtil.LocalizeResFormat(1220, LanguageFrom)
  for k, v in pairs(trans_values) do
    local SingleMsg = {
      msg = LogicUGCTrans.ConvertHtmlToPlain(k),
      transOrOrgText = v,
      languageFrom = LanguageFrom
    }
    self:OnTransRsp(nil, nil, SingleMsg)
  end
  if self.bWaitTranslate then
    self.bWaitTranslate = false
    self.WaitTranslateTimer = self:AddTimerOnce(1, function()
      self:TransStringBatch(nil, nil, true)
    end)
  end
end
function LogicUGCTrans:CheckIsOpen()
  if not LobbySystem.CheckOpen(BP_ENUM_TRANSLATE_UGC_SWITCH) then
    return false
  end
  if not LobbySystem.CheckOpen(BP_ENUM_TRANSLATE_UGC_GRAY) then
    return false
  end
  return true
end
function LogicUGCTrans:OnTransRsp(_, _, chatMsg)
  print(bWriteLog and "[edward] LogicUGCTrans:OnTransRsp, ")
  if not chatMsg then
    return
  end
  if not chatMsg.transOrOrgText or not chatMsg.msg then
    log(bWriteLog and "LogicUGCTrans:OnTransRsp translate fail")
    return
  end
  self:CheckAndClearOldCacheTrans()
  self.TransMap[chatMsg.msg] = chatMsg
  print(bWriteLog and "[edward] LogicUGCTrans:OnTransRsp, chatMsg.msg = ", chatMsg.msg)
  self.TransCacheCount = self.TransCacheCount + 1
  self.bTransCacheChanged = true
  self:RefreshTransStrUseTimeStamp(chatMsg.msg)
  EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_UGC_TRANSLATE_CALLBACK, chatMsg)
end
function LogicUGCTrans:GetTransByStr(originStr)
  if not originStr then
    return nil, nil
  end
  if not self.TransMap or not self.TransMap[originStr] then
    return nil, nil
  end
  self:RefreshTransStrUseTimeStamp(originStr)
  return self.TransMap[originStr].transOrOrgText, self.TransMap[originStr].languageFrom
end
function LogicUGCTrans:GetTransByStrWithState(originStr)
  if not originStr then
    return nil, nil, nil
  end
  if self.TransState[originStr] then
    return nil, nil, true
  end
  local str, lang = self:GetTransByStr(originStr)
  return str, lang, false
end
function LogicUGCTrans:RefreshTransStrUseTimeStamp(originStr)
  if not originStr then
    log(bWriteLog and "LogicUGCTrans:RefreshTransStrUseTimeStamp no originStr")
    return
  end
  if not self.TransMap or not self.TransMap[originStr] then
    log(bWriteLog and "LogicUGCTrans:RefreshTransStrUseTimeStamp no transData")
    return
  end
  local transData = self.TransMap[originStr]
  if not transData.transOrOrgText then
    log(bWriteLog and "LogicUGCTrans:RefreshTransStrUseTimeStamp no transOrOrgText")
    return
  end
  log(bWriteLog and "LogicUGCTrans:RefreshTransStrUseTimeStamp")
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  transData.useTimeStamp = curTime
end
function LogicUGCTrans:CheckAndClearOldCacheTrans()
  if not self.TransMap or not next(self.TransMap) then
    log(bWriteLog and "LogicUGCTrans:CheckAndClearOldCacheTrans no transMap")
    return
  end
  local CacheCount = self.TransCacheCount
  if CacheCount < self.MaxTransCacheCount then
    log(bWriteLog and "LogicUGCTrans:CheckAndClearOldCacheTrans no need to clear")
    return
  end
  log(bWriteLog and "LogicUGCTrans:CheckAndClearOldCacheTrans cacheCount before: " .. tostring(CacheCount))
  local SortList = {}
  for key, transData in pairs(self.TransMap) do
    table.insert(SortList, {
      key = key,
      useTimeStamp = transData.useTimeStamp or 0
    })
  end
  table.sort(SortList, function(a, b)
    return a.useTimeStamp < b.useTimeStamp
  end)
  local ClearCnt = math.floor(self.TranCacheReductionFactor * self.MaxTransCacheCount)
  for i, v in ipairs(SortList) do
    if i > ClearCnt then
      break
    end
    self.TransMap[v.key] = nil
    self.TransState[v.key] = nil
    CacheCount = CacheCount - 1
  end
  log(bWriteLog and "LogicUGCTrans:CheckAndClearOldCacheTrans cacheCount: " .. tostring(CacheCount))
  self.Trans  self:SerializeTranslate()
end
function LogicUGCTrans:GetFirstTranslateLanguage()
  if not self.FirstTranslateLanguage or self.FirstTranslateLanguage == "" then
    local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
    if #logic_chat_channel_world.language_data_list == 0 then
      log(bWriteLog and "LogicUGCTrans:GetFirstTranslateLanguage, language_data_list == 0")
      logic_chat_channel_world.topic_fetch_lang_list_req()
      self.bWaitTranslate = true
      return nil
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
    if FirstLanguage.name == "my" then
      local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
      FirstLanguage.name = LanguageMacros.MS
    elseif FirstLanguage.name == "my-MM" then
      local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
      FirstLanguage.name = LanguageMacros.MY
    end
    self.FirstTranslateLanguage = FirstLanguage
  end
  return self.FirstTranslateLanguage
end
function LogicUGCTrans:CheckCacheLanguageChanged(FirstLanguage)
  if not FirstLanguage then
    return
  end
  if self.TranslateLanguage == "" then
    self.TranslateLanguage = FirstLanguage.name
  elseif self.TranslateLanguage ~= FirstLanguage.name then
    log(bWriteLog and "[edward] LogicUGCTrans:CheckCacheLanguageChanged, Language Changed")
    self:ClearMap()
    self.FirstTranslateLanguage = FirstLanguage
    self.TranslateLanguage = FirstLanguage.name
    return
  end
end
function LogicUGCTrans:SerializeTranslate()
  self.bTransCacheChanged = false
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(self.TransMap, PlayerPrefsSystem.ePlayerPrefsType.eUGCTranslate)
  PlayerPrefsSystem.SaveTableToFile_N(self.TranslateLanguage, PlayerPrefsSystem.ePlayerPrefsType.eUGCTranslateLanguage)
  log(bWriteLog and "[edward] LogicUGCTrans:SerializeTranslate, TranslateLanguage = " .. self.TranslateLanguage)
  log(bWriteLog and "[edward] LogicUGCTrans:SerializeTranslate, CacheCount: " .. tostring(self.TransCacheCount))
end
function LogicUGCTrans.ConvertHtmlToPlain(str)
  if not str then
    return ""
  end
  str = string.gsub(str, "&#92;", "\\")
  str = string.gsub(str, "&gt;", ">")
  str = string.gsub(str, "&lt;", "<")
  str = string.gsub(str, "&amp;", "&")
  return str
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicUGCTrans = class(CModuleBase, nil, LogicUGCTrans)
return CLogicUGCTrans