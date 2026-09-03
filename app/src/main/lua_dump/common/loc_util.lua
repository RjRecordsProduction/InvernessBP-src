LocUtil = {debugTipsOpen = false, noticePopupDisable = false}
local local string_format = string.format
local string_find = string.find
local string_gsub = string.gsub
local string_match = string.match
local string_StrReplace = string.StrReplace
local local local local local local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local IsDevelopment = USTExtraBlueprintFunctionLibrary.IsDevelopment()
function ShowNotice(noticeId, bImmediately, controlTime, style)
  if LocUtil.noticePopupDisable then
    return
  end
  if not noticeId then
    return
  end
  log(bWriteLog and "ShowNotice noticeId = " .. noticeId)
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    local UIUtil = require("client.common.ui_util")
    if UIUtil.CheckHasIsLand() then
      controlTime = 3
    end
    if not tonumber(noticeId) then
      local tipContent = noticeId
      BattleNormalTips(tipContent, nil, controlTime)
    else
      BattleNormalTipsByTextID(noticeId, nil, nil, controlTime)
    end
    return
  end
  local noticeSystem = require("client.slua.logic.common.logic_notice_mgr")
  local tipContent2 = ""
  if not tonumber(noticeId) then
    tipContent2 = noticeId
  else
    tipContent2 = LocUtil.GetLocalizeResStr(noticeId)
    if tipContent2 == "" then
      tipContent2 = noticeId
    end
  end
  if not IsShipping and LocUtil.debugTipsOpen then
    tipContent2 = string_format("%s (dev\231\137\136\230\156\172\230\143\144\231\164\186\239\188\154id=%s)", tipContent2, tostring(noticeId))
  end
  if bImmediately then
    noticeSystem.RemoveAllNotice()
  end
  noticeSystem.ShowNewNotice(tipContent2, style)
end
LocUtil.
function ShowDevNotice(noticeId, bImmediately, controlTime, style)
  if IsDevelopment then
    ShowNotice(noticeId, bImmediately, controlTime, style)
  end
end
function ShowHelp(content, title, type)
  local info = {}
  local paragraph = {}
  paragraph.type = type or 1
  paragraph.content1 = content
  table.insert(info, paragraph)
  title = title or LocUtil.GetLocalizeResStr(6067)
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_one, title, info)
end
LocUtil.local _GetLocalizeResStrInner = function(id, bIngoreNoConfig)
  if id == nil then
    log_error("GetLocalizeResStr id is nil")
    return ""
  end
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    local localResCfg = CDataTable.GetTableData("Localization_Mod", id)
    if localResCfg ~= nil then
      if not localResCfg.Text then
        if IsDevelopment then
          log_error(debug.traceback())
        end
        log_error("LocUtil.GetLocalizeResStr localResCfg.Text is nil id=" .. tostring(id))
        return ""
      end
      return localResCfg.Text
    end
  end
  local localResCfg = CDataTable.GetTableData("LocalizeRes", id)
  if localResCfg ~= nil then
    if not localResCfg.TextValue then
      if IsDevelopment then
        log_error(debug.traceback())
      end
      log_error("LocUtil.GetLocalizeResStr localResCfg.TextValue is nil id=" .. tostring(id))
      return ""
    end
    return localResCfg.TextValue
  end
  if not bIngoreNoConfig then
    log_error("LocalizeRes not found id=" .. tostring(id))
  end
  return ""
end
function LocUtil.GetLocalizeResStr(id)
  return _GetLocalizeResStrInner(id)
end
function LocUtil.TryGetLocalizeResStr(id)
  return _GetLocalizeResStrInner(id, true)
end
function LocUtil.LocalizeResFormat(id, ...)
  if id == nil then
    if IsDevelopment then
      log_error(bWriteLog and debug.traceback())
    end
    log_error("LocalizeRes format is empty id=nil")
    return ""
  end
  local strFormat = LocUtil.GetLocalizeResStr(id)
  if strFormat == "" then
    log_error("LocalizeRes format is empty id=" .. tostring(id))
  end
  local LocUtil_Internal = require("common.loc_util_internal")
  return LocUtil_Internal.FormatStrByStr(strFormat, ...)
end
function LocUtil.GeneralFormat(strFormat, ...)
  if strFormat == nil then
    if IsDevelopment then
      log_error(bWriteLog and debug.traceback())
    end
    log(bWriteLog and "LocUtil.GeneralFormat strFormat is nil")
    return ""
  end
  local LocUtil_Internal = require("common.loc_util_internal")
  return LocUtil_Internal.FormatStrByStr(strFormat, ...)
end
function LocUtil.LocalizeResFormatByStr(strFormat, ...)
  if strFormat == nil then
    log_error("LocalizeRes format is empty strFormat=nil")
    return ""
  end
  if strFormat == "" then
    if IsDevelopment then
      log_error(bWriteLog and debug.traceback())
    end
    log_error(bWriteLog and "LocalizeRes format is empty strFormat=" .. strFormat)
    return ""
  end
  local IntlHelper = import("IntlHelper")
  strFormat = IntlHelper.GetLocalizationString(strFormat)
  local LocUtil_Internal = require("common.loc_util_internal")
  return LocUtil_Internal.FormatStrByStr(strFormat, ...)
end
function LocUtil.GetLocalizeStrConcatenation(id)
  local res = LocUtil.GetLocalizeResStr(id)
  if res == "" then
    log_error("LocUtil.GetLocalizeStrConcatenation id=" .. tostring(id))
    return ""
  end
  local isContainID = string_find(res, "{#")
  if isContainID then
    return string_gsub(res, "{#%d+}", function(arg)
      local id = string_match(arg, "%d+")
      return LocUtil.GetLocalizeResStr(id)
    end)
  end
  return res
end
function LocUtil.LocalizeFormatConcatenation(id, ...)
  local res = LocUtil.GetLocalizeStrConcatenation(id)
  if res == "" then
    log_error("LocUtil.LocalizeFormatConcatenation id=" .. id)
    return ""
  end
  local isContainID = string_find(res, "{0}")
  if isContainID then
    local LocUtil_Internal = require("common.loc_util_internal")
    res = LocUtil_Internal.ReformatIndex(res)
    res = LocUtil_Internal.FormatStrByStr(res, ...)
  end
  return res
end
function LocUtil.FormatStringIndexOne(strFormat, ...)
  local LocUtil_Internal = require("common.loc_util_internal")
  strFormat = LocUtil_Internal.ReformatIndex(strFormat)
  return LocUtil_Internal.FormatStrByStr(strFormat, ...)
end
function LocUtil.LocalizeServerText(str)
  if str == nil then
    return ""
  end
  local strClient = string_StrReplace(str, ",", ";")
  local IntlHelper = import("IntlHelper")
  local transStrClient = IntlHelper.GetLocalizationString(strClient)
  if transStrClient == strClient then
    return str
  end
  return transStrClient
end
function LocUtil.IsLeftToRightLanguage()
  local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
  local language = Client.GetCurrentLanguage()
  if language == LanguageMacros.AR or language == LanguageMacros.UR then
    return false
  end
  return true
end
function LocUtil.GetTestLocalizeRes(testStr, ...)
  if not IsDevelopment then
    log_error("GetTestLocalizeRes not in development!!! Check your code!!!")
    return ""
  end
  if not testStr or type(testStr) ~= "string" or not string_find(testStr, "##") then
    log_error("GetTestLocalizeRes test string must contain ## !!! Check your code!!!")
    return ""
  end
  local LocUtil_Internal = require("common.loc_util_internal")
  return LocUtil_Internal.FormatStrByStr(testStr, ...)
end
function LocUtil.IsClientTextMirror()
  local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
  local MirrorLanguage = {
    [LanguageMacros.AR] = true,
    [LanguageMacros.UR] = true
  }
  local language = Client.GetCurrentLanguage()
  return MirrorLanguage[language]
end
return LocUtil