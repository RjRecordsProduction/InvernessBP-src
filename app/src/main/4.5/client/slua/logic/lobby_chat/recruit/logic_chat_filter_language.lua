local logic_chat_filter_language = {}
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
local DefaultSelectLangCfg = {
  [PublishRegionMacros.JAPAN] = {
    LanguageMacros.EN,
    LanguageMacros.JA
  },
  [PublishRegionMacros.KOREA] = {
    LanguageMacros.EN,
    LanguageMacros.KO
  },
  [PublishRegionMacros.VNG] = {
    LanguageMacros.EN,
    LanguageMacros.VI
  },
  [PublishRegionMacros.BLUEHOLE] = {
    LanguageMacros.EN
  }
}
local isCacheDataInit, filterLanguageIdList, isContainEnglish
local isNeedSendLangs = true
local _GetDefaultSelectData = function()
  local region = Client.GetPublishRegion()
  local logic_team_platform_utils = require("client.slua.logic.teamup.logic_team_platform_utils")
  local languageList = {}
  local defaultLangNameList = DefaultSelectLangCfg[region]
  if defaultLangNameList then
    for _, v in ipairs(defaultLangNameList) do
      local id = logic_team_platform_utils.GetLangIdByName(v)
      if id then
        table.insert(languageList, id)
      end
    end
  else
    local englishId = logic_team_platform_utils.GetLangIdByName(LanguageMacros.EN)
    if englishId then
      table.insert(languageList, englishId)
    end
  end
  return languageList
end
local _InitSelectLanguageData = function()
  if isCacheDataInit then
    return
  end
  local logic_team_platform_utils = require("client.slua.logic.teamup.logic_team_platform_utils")
  if logic_team_platform_utils.IsCanFilterLanguage() then
    local TeamPlatform_Macro = require("client.slua.logic.teamup.teamplatform_macro")
    filterLanguageIdList = logic_team_platform_utils.GetSaveFilterLanguageData(TeamPlatform_Macro.Enum_FilterLanguage_Scene.Chat)
    log_tree(bWriteLog and "[v_wllwu] logic_chat_filter_language:_InitSelectLanguageData, saveData: ", filterLanguageIdList)
  end
  if not filterLanguageIdList or #filterLanguageIdList <= 0 then
    filterLanguageIdList = _GetDefaultSelectData()
    log_tree(bWriteLog and "[v_wllwu] logic_team_platform_data:_InitSelectLanguageData, GetDefaultSelectData >>> ", filterLanguageIdList)
  end
  filterLanguageIdList = logic_team_platform_utils.FilterInvalidData(filterLanguageIdList)
  log_tree(bWriteLog and "[v_wllwu] logic_chat_filter_language:_InitSelectLanguageData, selectLanguageList: ", filterLanguageIdList)
  isCacheDataInit = true
end
function logic_chat_filter_language:InitData()
  _InitSelectLanguageData()
  self:UpdateIsSelectEnglish()
end
function logic_chat_filter_language:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_CHAT, EVENTID_CHAT_FETCH_LANGUAGE_LIST, self.OnUpdateChatLanguageList, self)
end
function logic_chat_filter_language:OnUpdateChatLanguageList()
  if not isNeedSendLangs then
    log(bWriteLog and "[v_wllwu] logic_chat_filter_language:OnUpdateChatLanguageList return")
    return
  end
  isNeedSendLangs = nil
  log(bWriteLog and "[v_wllwu] logic_chat_filter_language:OnUpdateChatLanguageList enter")
  self:SyncFilterLanguage()
end
function logic_chat_filter_language:OnLogin(bReLogin)
end
function logic_chat_filter_language:OnLogOut()
  isCacheDataInit = nil
  filterLanguageIdList = nil
  isContainEnglish = nil
  isNeedSendLangs = true
end
function logic_chat_filter_language:GetCurSelectLanguageData()
  _InitSelectLanguageData()
  return filterLanguageIdList
end
function logic_chat_filter_language:SyncFilterLanguage()
  local langIdList = self:GetCurSelectLanguageData()
  log_tree(bWriteLog and "[v_wllwu] logic_chat_filter_language:SyncFilterLanguage, langIdList is:", langIdList)
  self:SendSetRecruitLangsReq(langIdList)
end
function logic_chat_filter_language:IsContainEnglish()
  return isContainEnglish
end
function logic_chat_filter_language:RefreshCurSelectFilterLanguage()
  log(bWriteLog and "[v_wllwu] logic_chat_filter_language:RefreshCurSelectFilterLanguage")
  if not isCacheDataInit then
    return
  end
  log_tree(bWriteLog and "[v_wllwu] logic_chat_filter_language:RefreshCurSelectFilterLanguage before, filterLanguageIdList is:", filterLanguageIdList)
  local logic_team_platform_utils = require("client.slua.logic.teamup.logic_team_platform_utils")
  filterLanguageIdList = logic_team_platform_utils.FilterInvalidData(filterLanguageIdList)
  self:UpdateIsSelectEnglish()
  log_tree(bWriteLog and "[v_wllwu] logic_chat_filter_language:RefreshCurSelectFilterLanguage after, filterLanguageIdList is:", filterLanguageIdList)
end
function logic_chat_filter_language:SendSetRecruitLangsReq(langIdList)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_set_player_recruit_langs_req(langIdList)
end
function logic_chat_filter_language:OnSetRecruitLangsRsp(err_code, langs)
  if err_code ~= 0 then
    log(bWriteLog and "[v_wllwu] logic_chat_filter_language:OnSetRecruitLangsRsp, err_code is:" .. tostring(err_code))
    return
  end
  filterLanguageIdList = langs
  self:UpdateIsSelectEnglish()
  local TeamPlatform_Macro = require("client.slua.logic.teamup.teamplatform_macro")
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_REFRESH_FILTER_LANGUAGE, TeamPlatform_Macro.Enum_FilterLanguage_Scene.Chat)
end
function logic_chat_filter_language:UpdateIsSelectEnglish()
  if not filterLanguageIdList then
    return
  end
  local logic_team_platform_utils = require("client.slua.logic.teamup.logic_team_platform_utils")
  local englishId = logic_team_platform_utils.GetLangIdByName(LanguageMacros.EN)
  if not englishId then
    log_error(bWriteLog and "[v_wllwu] logic_chat_filter_language:UpdateIsSelectEnglish englishId is nil")
    return
  end
  for _, v in pairs(filterLanguageIdList) do
    if v == englishId then
      isContainEnglish = true
      log(bWriteLog and "[v_wllwu] logic_chat_filter_language:UpdateIsSelectEnglish, isContainEnglish is true")
      return
    end
  end
  log(bWriteLog and "[v_wllwu] logic_chat_filter_language:UpdateIsSelectEnglish, isContainEnglish is false")
  isContainEnglish = false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_chat_filter_language = class(CModuleBase, nil, logic_chat_filter_language)
return Clogic_chat_filter_language