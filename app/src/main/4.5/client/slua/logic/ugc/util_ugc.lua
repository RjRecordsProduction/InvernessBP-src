local Util_UGC = {
  PbLoaded = {}
}
function Util_UGC.ModIDTransformToShow(id)
  id = tostring(id)
  if not id then
    log_warning(bWriteLog and "[edward] Logic_UGC:ModCodeTransformToShow id is error")
    return ""
  end
  log(bWriteLog and "[edward] Util_UGC.ModIDTransformToShow id =" .. id)
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local idLen = string.len(id)
  local fixStr = ""
  for i = idLen + 1, Config_UGC.ModIDMaxLen do
    fixStr = fixStr .. "0"
  end
  local showID = fixStr .. id
  local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
  if Client.GetCurrentLanguage() == LanguageMacros.AR then
    local sub1 = string.sub(showID, 1, 3)
    local sub2 = string.sub(showID, 4, 6)
    local sub3 = string.sub(showID, 7, 9)
    showID = sub3 .. sub2 .. sub1
  end
  log(bWriteLog and "[edward] Util_UGC.ModIDTransformToShow after id = " .. showID)
  return string.format("%s-%s-%s", string.sub(showID, 1, 3), string.sub(showID, 4, 6), string.sub(showID, 7))
end
function Util_UGC.IsEditorProMap(ModInfo)
  local IsEditorProMap = false
  if ModInfo and ModInfo.setting then
    local TableUtil = require("common.table_util")
    print(bWriteLog and "Util_UGC:IsEditorProMap ModInfo.setting" .. TableUtil.TableToString(ModInfo.setting))
    IsEditorProMap = ModInfo.setting.use_editor_pro and ModInfo.setting.use_editor_pro > 0
  end
  return IsEditorProMap
end
function Util_UGC.GotoEditorPro()
  print(bWriteLog and "Util_UGC:GotoEditorPro")
  local URL
  local GuideAnchorWebConfig = CDataTable.GetTableData("UGCCreationGuideAnchorWebConfig", 13)
  if GuideAnchorWebConfig then
    URL = GuideAnchorWebConfig.WebURL
    local language = "lan_" .. Client.GetCurrentLanguage()
    local WebURLLocalize = GuideAnchorWebConfig[language]
    if WebURLLocalize ~= nil and WebURLLocalize ~= "" and WebURLLocalize ~= "-1" then
      URL = WebURLLocalize
    end
  end
  if URL and 0 < #URL then
    GlobalData.JumpUrl(URL)
  end
end
function Util_UGC.NewModName(templateShowId)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local index = 1
  local name = LocUtil.GetLocalizeResStr(70005) .. index
  while LogicUGC:CheckModNameUsed(name) do
    index = index + 1
    name = LocUtil.GetLocalizeResStr(70005) .. index
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local templateData = Config_UGC.GetTemplateConfigByID(templateShowId)
  if not (templateData and templateData.DefaultCreateName) or templateData.DefaultCreateName == "" then
    templateData = Config_UGC.GetTemplateShowConfigByID(templateShowId)
  end
  if templateData and templateData.DefaultCreateName then
    log(bWriteLog and "Util_UGC.NewModName templateData.DefaultCreateName = " .. templateData.DefaultCreateName)
    if templateData.DefaultCreateName ~= "" then
      name = templateData.DefaultCreateName
    end
  end
  log(bWriteLog and "[edward] Util_UGC.NewModName name = " .. name)
  return name
end
function Util_UGC.CheckModCodeValid(code)
  return true
end
function Util_UGC.CheckNameValid(name)
  if not name or name == "" then
    ShowNotice(70041)
    return false
  end
  local StringUtil = require("common.string_util")
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local Logic_UGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local ModNameMaxLen = Logic_UGC:GetModNameMaxLen()
  local unitLen = Util_UGC.GetTextLengthAndSubStr(name, ModNameMaxLen)
  local ret, _, retStr = StringUtil.CheckName(name, false, nil, true)
  if ret then
    ShowNotice(70044)
    return false
  end
  if ModNameMaxLen < unitLen then
    ShowNotice(106028)
    return false
  end
  if unitLen == ModNameMaxLen and retStr ~= name then
    ShowNotice(70044)
    return false
  end
  local isStartsWithSpace = StringUtil.CheckStringStartsWithSpace(name)
  if isStartsWithSpace then
    ShowNotice(70100)
    return false
  end
  return true
end
function Util_UGC.NormalizeName(name)
  local StringUtil = require("common.string_util")
  name = string.gsub(name, "\n", "")
  name = string.gsub(name, "\r", "")
  local flag, _, newName = StringUtil.CheckName(name, false, nil, true)
  newName = StringUtil.RemoveLeadingSpaces(newName)
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local Logic_UGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local ModNameMaxLen = Logic_UGC:GetModNameMaxLen()
  local nameLen, retStr = Util_UGC.GetTextLengthAndSubStr(newName, ModNameMaxLen)
  log(bWriteLog and "Util_UGC.NormalizeName name:" .. tostring(newName) .. " nameLen:" .. tostring(nameLen) .. " retStr:" .. tostring(retStr))
  if ModNameMaxLen < nameLen then
    return retStr
  end
  return newName
end
function Util_UGC.NormalizeNameByLen(name, MaxLen)
  local StringUtil = require("common.string_util")
  name = string.gsub(name, "\n", "")
  name = string.gsub(name, "\r", "")
  local flag, _, newName = StringUtil.CheckName(name, false, nil, true)
  newName = StringUtil.RemoveLeadingSpaces(newName)
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local nameLen, retStr = Util_UGC.GetTextLengthAndSubStr(newName, MaxLen)
  log(bWriteLog and "Util_UGC.NormalizeNameByLen name:" .. tostring(newName) .. " nameLen:" .. tostring(nameLen) .. " retStr:" .. tostring(retStr))
  if MaxLen < nameLen then
    return retStr
  end
  return newName
end
function Util_UGC.NormalizeDesc(desc)
  if not desc or desc == "" then
    return ""
  end
  local StringUtil = require("common.string_util")
  local Logic_UGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local ModDescMaxLen = Logic_UGC:GetModDescMaxLen()
  local len, retStr = Util_UGC.GetTextLengthAndSubStr(desc, ModDescMaxLen)
  if ModDescMaxLen < len then
    ShowNotice(70043)
    desc = retStr
  end
  local _, _, newDesc = StringUtil.CheckName(desc, nil, nil, true)
  return newDesc
end
function Util_UGC.NormalizeBlockyLuaStr(inputS)
  local StringUtil = require("common.string_util")
  inputS = string.gsub(inputS, "\\n", "")
  inputS = string.gsub(inputS, "\\r", "")
  local BlockyLuaStrMaxLen = 512
  local nameLen, retStr = Util_UGC.GetTextLengthAndSubStr(inputS, BlockyLuaStrMaxLen)
  if BlockyLuaStrMaxLen < nameLen then
    return retStr
  end
  return inputS
end
function Util_UGC.GetTextLengthAndSubStr(txt, maxLen)
  if not txt or txt == "" then
    return 0, ""
  end
  local charsize = function(ch)
    if not ch then
      return 0
    elseif 252 <= ch then
      return 6
    elseif 248 <= ch and ch < 252 then
      return 5
    elseif 240 <= ch and ch < 248 then
      return 4
    elseif 224 <= ch and ch < 240 then
      return 3
    elseif 192 <= ch and ch < 224 then
      return 2
    else
      return 1
    end
  end
  maxLen = maxLen or 0
  local curIndex = 1
  local totalLength = 0
  local retStrLen = 0
  while curIndex <= #txt do
    local curChar = string.byte(txt, curIndex)
    local byteCount = charsize(curChar)
    if byteCount == 1 then
      totalLength = totalLength + 1
    elseif 2 <= byteCount then
      totalLength = totalLength + 2
    end
    curIndex = curIndex + byteCount
    if maxLen <= 0 or maxLen >= totalLength then
      retStrLen = curIndex - 1
    end
  end
  return totalLength, string.sub(txt, 1, retStrLen)
end
function Util_UGC.GetUGCThumbUrl(modSetting, isOrigin)
  return Util_UGC.GetUGCAlbumUrl(modSetting.album, modSetting.thumb_index, isOrigin)
end
function Util_UGC.GetUGCAllViewUrls(modSetting, isOrigin)
  local urls = {}
  if not modSetting.view_pic_list then
    return urls
  end
  for _, v in pairs(modSetting.view_pic_list) do
    local url = Util_UGC.GetUGCAlbumUrl(modSetting.album, v, isOrigin)
    if url ~= "" then
      table.insert(urls, url)
    end
  end
  return urls
end
function Util_UGC.GetUGCViewUrl(modSetting, index, isOrigin)
  local url = ""
  if not index then
    return url
  end
  if not modSetting.view_pic_list then
    return url
  end
  if index <= 0 or index > #modSetting.view_pic_list then
    return url
  end
  url = Util_UGC.GetUGCAlbumUrl(modSetting.album, modSetting.view_pic_list[index], isOrigin)
  return url
end
function Util_UGC.GetUGCAlbumUrl(albums, index, isOrigin)
  local url = ""
  if not index then
    return url
  end
  if not albums then
    return url
  end
  if index <= 0 or index > #albums then
    return url
  end
  if isOrigin then
    url = albums[index].origin_url
  else
    url = albums[index].thumb_url
  end
  return url
end
function Util_UGC.IsCustomUGCAlbum(Albums, Url, isOrigin)
  if not Albums then
    return
  end
  for Index = 1, #Albums do
    local AlbumInfo = Albums[Index]
    local TargetUrl = AlbumInfo[isOrigin and "origin_url" or "thumb_url"]
    if TargetUrl == Url then
      return AlbumInfo.custom_photo
    end
  end
end
function Util_UGC.GetAllViewImageUrls(modInfo, isOrigin)
  local urls = Util_UGC.GetUGCAllViewUrls(modInfo.setting, isOrigin)
  if #urls <= 0 then
    local coverImageUrl = Util_UGC.GetUGCThumbUrl(modInfo.setting, isOrigin)
    if coverImageUrl and coverImageUrl ~= "" then
      log(bWriteLog and "Util_UGC.GetAllViewImageUrls use thumbUrl")
      table.insert(urls, coverImageUrl)
    end
  end
  if #urls <= 0 then
    local LogicUGCTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCTemplate)
    local config = LogicUGCTemplate:GetTemplateByIDLocally(modInfo.base.template_id)
    if config then
      table.insert(urls, config.Image)
    end
  end
  return urls
end
function Util_UGC.GetCoverImageUrl(modSetting, templateId, isOrigin)
  local url = Util_UGC.GetUGCThumbUrl(modSetting, isOrigin)
  if url == "" or url == nil then
    local LogicUGCTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCTemplate)
    local config = LogicUGCTemplate:GetTemplateByIDLocally(templateId)
    if config then
      url = config.Image
    end
  end
  return url
end
function Util_UGC.SetCoverImage(uiBase, widget, modInfo, bIsOrigin, bIsMatchSize, onSuccessCallback, onFailedCallback, imageCacheType)
  if modInfo == nil then
    return
  end
  if not imageCacheType then
    local image_download_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.image_download_mgr)
    local DiskCacheTypeEnum = image_download_mgr:GetDiskCacheTypeEnum()
    if bIsOrigin then
      imageCacheType = DiskCacheTypeEnum.VersionUpdate
    else
      imageCacheType = DiskCacheTypeEnum.NeverDelete
    end
  end
  log(bWriteLog and "Util_UGC.SetCoverImage imageCacheType:" .. tostring(imageCacheType))
  local url = Util_UGC.GetCoverImageUrl(modInfo.setting, modInfo.base.template_id, bIsOrigin)
  Util_UGC.SetUGCImage(uiBase, widget, url, bIsMatchSize, onSuccessCallback, onFailedCallback, imageCacheType)
end
function Util_UGC.SetUGCImage(uiBase, widget, url, bIsMatchSize, onSuccessCallback, onFailedCallback, imageCacheType)
  if not url then
    log_warning(bWriteLog and "Util_UGC.SetUGCImage url is nil")
    return
  end
  if not uiBase or not slua.isValid(widget) then
    log_warning(bWriteLog and "Util_UGC.SetUGCImage uiBase is nil")
    return
  end
  url = tostring(url)
  local util = require("client.slua_ui_framework.util")
  local StringUtil = require("common.string_util")
  if not StringUtil.Starts(url, "/Game") and not util.IsOnlineImageUrl(url) then
    local logic_moment_helper = require("client.slua.logic.moment.logic_moment_helper")
    local cdnDomain = logic_moment_helper.GetDomain(1)
    url = cdnDomain .. url
  end
  if not imageCacheType then
    local image_download_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.image_download_mgr)
    local DiskCacheTypeEnum = image_download_mgr:GetDiskCacheTypeEnum()
    imageCacheType = DiskCacheTypeEnum.VersionUpdate
  end
  log(bWriteLog and "Util_UGC.SetUGCImage imageCacheType:" .. tostring(imageCacheType))
  uiBase:SetTexture(widget, url, {
    onDownloadSuccess = onSuccessCallback,
    onDownloadFail = onFailedCallback,
    bMatchSize = bIsMatchSize or false,
    diskCacheType = imageCacheType
  })
end
function Util_UGC.SetUGCCollectionsImage(uiBase, widget, url, onSuccessCallback, templateId)
  if not uiBase or not slua.isValid(widget) then
    log_warning(bWriteLog and "Util_UGC.SetUGCCollectionsImage uiBase is nil")
    return
  end
  if not url or url == "" then
    if templateId and templateId ~= 0 then
      local Config_UGC = require("client.slua.logic.ugc.config_ugc")
      local config = Config_UGC.GetTemplateConfigByID(templateId)
      if config then
        url = config.BgImage
        Util_UGC.SetUGCImage(uiBase, widget, url, true, onSuccessCallback, nil, nil)
        return
      end
    else
      uiBase:SetTexture(widget, "/Game/Mod/Lobby/Base/MatchSelectMap/450/ModeSelection_New/MapEntrance/Small/Lobby_match_MapEntrance_S006_2x2.Lobby_match_MapEntrance_S006_2x2")
    end
    if onSuccessCallback then
      onSuccessCallback()
    end
  else
    Util_UGC.SetUGCImage(uiBase, widget, url, true, onSuccessCallback, nil, nil)
  end
end
function Util_UGC.GetModCollectCount(modInfo)
  return modInfo and modInfo.collect_cnt or 0
end
function Util_UGC.GetModLikeCount(modInfo)
  return modInfo and modInfo.like_cnt or 0
end
function Util_UGC.GetModPlayCount(modInfo)
  return modInfo and modInfo.play_cnt or 0
end
function Util_UGC.GetModPlayCountWeekly(modInfo)
  return modInfo and modInfo.play_cnt_week or 0
end
function Util_UGC.GetModPlayTotalTime(modInfo)
  local StringUtil = require("common.string_util")
  if modInfo.play_total_time then
    return modInfo and StringUtil.FormatNumATWill_KMB(modInfo.play_total_time / 3600, "%.1f") or 0
  else
    return 0
  end
end
function Util_UGC.GetModCompleteTime(modInfo)
  if modInfo then
    local StringUtil = require("common.string_util")
    log(bWriteLog and "Util_UGC.GetModCompleteTime modInfo.finish_play_total_time = " .. modInfo.finish_play_total_time)
    log(bWriteLog and "Util_UGC.GetModCompleteTime modInfo.game_result_finish_cnt = " .. modInfo.game_result_finish_cnt)
    local Time = StringUtil.FormatNumDecimal_KMB(modInfo.finish_play_total_time / modInfo.game_result_finish_cnt / 60) or 0
    log(bWriteLog and "Util_UGC.GetModCompleteTime  Time " .. Time)
    return Time
  end
end
function Util_UGC.GetModCompleteRate(modInfo)
  if modInfo then
    log(bWriteLog and "Util_UGC.GetModCompleteRate modInfo.game_result_cnt = " .. modInfo.game_result_cnt)
    log(bWriteLog and "Util_UGC.GetModCompleteRate modInfo.game_result_finish_cnt = " .. modInfo.game_result_finish_cnt)
    local StringUtil = require("common.string_util")
    local value = StringUtil.FormatNumDecimal_KMB(modInfo.game_result_finish_cnt / modInfo.game_result_cnt * 100, "%.0f") or 0
    log(bWriteLog and "Util_UGC.GetModCompleteRate  value " .. value)
    return value
  end
end
function Util_UGC.GetEditModHasPlayedCompleted(editModInfo)
  if not editModInfo or not editModInfo.setting then
    log(bWriteLog and "Util_UGC.GetEditModHasPlayedCompleted no editModInfo or setting")
    return true
  end
  log(bWriteLog and "Util_UGC.GetEditModHasPlayedCompleted " .. tostring(editModInfo.setting.has_played_completed))
  local hasPlayed = editModInfo.setting.has_played_completed or 0
  return hasPlayed
end
function Util_UGC.GetMinPlayerCount(modInfo)
  if not modInfo or not modInfo.setting then
    log(bWriteLog and "Util_UGC.GetMinPlayerCount no modInfo or setting")
    return 0
  end
  local min_size = 0
  if modInfo.setting.team_size == -1 then
    min_size = modInfo.setting.max_num
  else
    local min_team_size = modInfo.setting.team_min_size or modInfo.setting.team_size
    if min_team_size == nil or modInfo.setting.min_start_team_num == nil then
      log_error(bWriteLog and "Util_UGC.GetMinPlayerCount min_team_size = " .. tostring(min_team_size) .. " min_start_team_num = " .. tostring(modInfo.setting.min_start_team_num))
      return 0
    end
    min_size = min_team_size * modInfo.setting.min_start_team_num
  end
  log(bWriteLog and "Util_UGC.GetMinPlayerCount min_size = " .. min_size)
  return min_size
end
function Util_UGC.GetModTeamSize(ModInfo, DefaultTeamSize)
  local ModTeamSize = 0
  if ModInfo and ModInfo.setting and ModInfo.setting.team_size then
    ModTeamSize = ModInfo.setting.team_size
    if ModTeamSize == -1 then
      ModTeamSize = ModInfo.setting.max_num or 0
    end
  end
  if ModTeamSize <= 0 then
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    ModTeamSize = DefaultTeamSize or TeamUpNewSystem.GetDefaultMaxTeamNum()
  end
  log(bWriteLog and "Util_UGC.GetModTeamSize ModTeamSize = " .. ModTeamSize)
  return ModTeamSize
end
function Util_UGC.CheckIsTrailMod(editModInfo)
  if not editModInfo or not editModInfo.setting then
    log(bWriteLog and "Util_UGC.CheckIsTrailMod no editModInfo")
    return false
  end
  return true
end
function Util_UGC.IsModFreeze(reason)
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if type(reason) ~= "number" then
    return false
  end
  local config = Config_UGC.GetModReasonConfigByID(reason)
  if config and config.Type == Config_UGC.FreezeType then
    return true
  end
  return false
end
function Util_UGC.IsUGCPubItemExpired(modInfo)
  local TimeUtil = require("client.common.time_util")
  if gTestItemExpiredUI then
    return true
  end
  if modInfo.theme_obj_close_time and modInfo.theme_obj_close_time ~= 0 then
    local ServerTime = TimeUtil.GetServerTimeInSec()
    if ServerTime > modInfo.theme_obj_close_time then
      return true
    end
  end
  return false
end
function Util_UGC.GetUGCRedDotState(fileType)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(fileType) or {}
  if cfg.red_dot then
    return true
  end
  return false
end
function Util_UGC.GetUGCRedDotLastCheckTime(fileType)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(fileType) or {}
  if cfg and cfg.last_check_time then
    return cfg.last_check_time
  end
  return nil
end
function Util_UGC.SetUGCRedDotState(fileType, checkTick, state)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(fileType) or {}
  if checkTick then
    cfg.last_check_time = checkTick
  end
  cfg.red_dot = state or false
  PlayerPrefsSystem.SaveTableToFile_N(cfg, fileType)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_UGCCOMMUNITY_REDPOINT, fileType)
end
local BinaryBasePb = "gamesrv_ds/ugc_binary_base.pb"
function Util_UGC.GetCurBinaryVersion()
  local pb = require("pb")
  if Util_UGC.PbLoaded[BinaryBasePb] ~= true then
    pb.loadfile(BinaryBasePb)
  end
  local CurBinaryVersion = pb.enum("gamesrv_ds.UGC_GLOBAL_ENUM", "CurBinaryVersion")
  print(bWriteLog and "Util_UGC.IsModVersionValid CurBinaryVersion:" .. tostring(CurBinaryVersion))
  return CurBinaryVersion
end
function Util_UGC.IsModVersionValid(modInfo)
  if not modInfo or not modInfo.base then
    return false
  end
  local modVersion = modInfo.base.version or 10000
  local curVersion = Util_UGC.GetCurBinaryVersion()
  return tonumber(curVersion) >= tonumber(modVersion)
end
function Util_UGC.NeedShowUpdateTips(modInfo)
  if not Util_UGC.IsModVersionValid(modInfo) then
    local title = LocUtil.GetLocalizeResStr(5077)
    local tips = LocUtil.GetLocalizeResStr(48897)
    local okText = LocUtil.GetLocalizeResStr(201003)
    local cancelText = LocUtil.GetLocalizeResStr(110035)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, tips, function()
      FuncUtil.JumpToDownloadApp()
    end, nil, okText, cancelText)
    return true
  end
  return false
end
function Util_UGC.JumpStrategyGuideUrl()
  local url = FuncUtil.GetDomainByID(3366036) .. "/act/operationevent/WOW/index.html?region={country}&sTicket={itop_ticket}&gameid={gameid}&nickname={nickname}&game_area={game_area}&language={language}&game_season={game_season}&head_pic={head_pic}&never_adjust=1"
  local cfg = CDataTable.GetTableData("UGCGuideUrlConfig", "StrategyGuideAddress")
  local accountregion = FuncUtil.GetAccountRegionForBP()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    if accountregion == "JP" then
      cfg = CDataTable.GetTableData("UGCGuideUrlConfig", "StrategyGuideAddress_JP")
    else
      cfg = CDataTable.GetTableData("UGCGuideUrlConfig", "StrategyGuideAddress_KR")
    end
  end
  if cfg then
    url = cfg.Value
  end
  log(bWriteLog and string.format("Util_UGC.GetStrategyGuideUrl, url:%s", url))
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  GlobalData.JumpUrl(webModule:AddParameterByPersonalInfo(url, true, true))
end
function Util_UGC.ShowUGCChatSharePanel(modInfo)
  if modInfo == nil or not next(modInfo) then
    log(bWriteLog and "Util_UGC.ShowUGCChatSharePanel modInfo is invalid")
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local _tag = ""
  if modInfo.setting.tag and type(modInfo.setting.tag) == "table" then
    for _, v in pairs(modInfo.setting.tag) do
      local config = Config_UGC.GetTagConfigByID(v)
      if config then
        _tag = _tag .. " " .. config.Name
      end
    end
  end
  local ugcParam = {
    mod_id = modInfo.mod_id,
    mod_name = modInfo.setting.name,
    tag = _tag,
    mode_desc = modInfo.setting.desc
  }
  UIManager.ShowUI(UIManager.UI_Config.UGCChatShareInvitePanel, ugcParam)
end
function Util_UGC.Reportprotocolassignment(modInfo)
  if not modInfo then
    return
  end
  local logic_ugc_SendFriends = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_SendFriends)
  logic_ugc_SendFriends:SetUGCModSendFriends(modInfo)
end
function Util_UGC.ShowUGCSharePanel(modInfo)
  if modInfo == nil or not next(modInfo) then
    log(bWriteLog and "Util_UGC.ShowUGCSharePanel modInfo is invalid")
    return
  end
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  local url = Util_UGC.GetCoverImageUrl(modInfo.setting, modInfo.base.template_id, true)
  local Util = require("client.slua_ui_framework.util")
  local StringUtil = require("common.string_util")
  if url and not StringUtil.Starts(tostring(url), "/Game") and not Util.IsOnlineImageUrl(tostring(url)) then
    local logic_moment_helper = require("client.slua.logic.moment.logic_moment_helper")
    local cdnDomain = logic_moment_helper.GetDomain(1)
    url = cdnDomain .. tostring(url)
  end
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  local cfg = {
    capturePath = url or "",
    shareTitle = LocUtil.GetLocalizeResStr(80045),
    shareContent = LocUtil.LocalizeResFormat(80046, DataMgr.roleData.nickName, modInfo.setting.name, modInfo.mod_id),
    otherTLog = TLogEventDefine.UGC_Share,
    campaign = "ugc_mod",
    reasonStr = json.encode({
      uid = DataMgr.roleData.uid,
      modID = modInfo.mod_id
    }),
    nItemId = modInfo.mod_id,
    moduleParams = "module=" .. BP_ENUM_MODULE_MATCH_MODE_SELECTION .. "&menuList=" .. mode_selection_macro.Enum_TabID.UGC .. "&modId=" .. modInfo.mod_id
  }
  Util_UGC.Reportprotocolassignment(modInfo)
  if cfg then
    Util.ShowShare(cfg, UIManager.UI_Config.UGCExtraSharePanel, modInfo)
  end
end
function Util_UGC.ShowUGCShareCollectionListPanel(collectionData)
  if collectionData == nil or not next(collectionData) then
    log(bWriteLog and "Util_UGC.ShowUGCSharePanel modInfo is invalid")
    return
  end
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local cfg = {
    capturePath = "/Game/Mod/Lobby/Base/MatchSelectMap/450/ModeSelection_New/BG/ModeSelection_Image_BG02.ModeSelection_Image_BG02",
    shareTitle = LocUtil.LocalizeResFormat(69416),
    shareContent = LocUtil.LocalizeResFormat(69355, DataMgr.roleData.nickName, collectionData.name, collectionData.mod_collection_id),
    otherTLog = TLogEventDefine.UGC_Share,
    campaign = "ugc_mod",
    reasonStr = json.encode({
      uid = DataMgr.roleData.uid,
      modCollectionId = collectionData.mod_collection_id
    }),
    nItemId = collectionData.mod_collection_id,
    moduleParams = "module=" .. BP_ENUM_MODULE_UGC_COLLECTIONLIST_DETAILS .. "&menuList=" .. mode_selection_macro.Enum_TabID.UGC .. "&mod_collection_id=" .. collectionData.mod_collection_id .. "&source=" .. Config_UGC.Source_Open_Detail.SNS
  }
  Util_UGC.Reportprotocolassignment(collectionData)
  local Util = require("client.slua_ui_framework.util")
  Util.ShowShare(cfg, UIManager.UI_Config.UGCExtraShareCollectionPanel, collectionData)
end
function Util_UGC.SetUGCNewbieGuideFinish(guideKey)
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  if not DataMgr.HaveNewbieGuide(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_UGC, guideKey) then
    log(bWriteLog and "Util_UGC.SetUGCNewbieGuideFinish no need set")
    return
  end
  log(bWriteLog and "Util_UGC.SetUGCNewbieGuideFinish")
  DataMgr.SetNewbieGuide(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_UGC, guideKey)
end
function Util_UGC.ResetUGCNewbieGuideFinish(guideKey)
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  if not DataMgr.HaveNewbieGuide(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_UGC, guideKey) then
    log(bWriteLog and "Util_UGC.SetUGCNewbieGuideFinish no need set")
    return
  end
  log(bWriteLog and "Util_UGC.SetUGCNewbieGuideFinish")
  DataMgr.SetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_UGC, guideKey, 0)
end
function Util_UGC.IsUGCNewbieGuideFinish(guideKey)
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  return not DataMgr.HaveNewbieGuide(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_UGC, guideKey)
end
function Util_UGC.SetUGCNewbieGuideVal(guideKey, val)
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  log(bWriteLog and "Util_UGC.SetUGCNewbieGuideFinish")
  DataMgr.SetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_UGC, guideKey, val)
end
function Util_UGC.GetUGCNewbieGuideVal(guideKey)
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  log(bWriteLog and "Util_UGC.SetUGCNewbieGuideFinish")
  return DataMgr.GetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_UGC, guideKey)
end
function Util_UGC.RefreshLoopAllItemsWithoutTLog(loopscrollbox)
  if not loopscrollbox then
    return
  end
  local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
  Logic_UGC_TLog:SetTLogSwitch(false)
  loopscrollbox:RefreshAllItems()
  Logic_UGC_TLog:SetTLogSwitch(true)
end
function Util_UGC.RefreshModePlayerNum(widget, mod_id)
  if not slua.isValid(widget) then
    return
  end
  if not widget or not widget.HorizontalBox_Time then
    return
  end
  local UIUtil = require("client.common.ui_util")
  UIUtil.SetWidgetVisible(widget.HorizontalBox_Time, true)
  UIUtil.SetWidgetVisible(widget.Online, false)
  if not widget.TextBlock_PlayTime then
    return
  end
  if not slua.isValid(widget.TextBlock_PlayTime) then
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  local num = logic_ugc_mode:GetModePlayerNum(mod_id) or 0
  if num >= Config_UGC.SimultaneousOnlinePopular then
    UIUtil.SetWidgetVisible(widget.TextBlock_PlayTime, true)
  elseif num < Config_UGC.SimultaneousOnlinePopular and num >= Config_UGC.SimultaneousOnlineModerate then
    UIUtil.SetWidgetVisible(widget.TextBlock_PlayTime, false)
  else
    UIUtil.SetWidgetVisible(widget.HorizontalBox_Time, false)
    UIUtil.SetWidgetVisible(widget.TextBlock_PlayTime, false)
  end
  if slua.isValid(widget.TextBlock_PlayTime) then
    local StringUtil = require("common.string_util")
    widget.TextBlock_PlayTime:SetText(StringUtil.FormatNum_KMB(num, "%.1f"))
  end
end
function Util_UGC.ShowAuthorWorkMainUI(uid)
  uid = tonumber(uid)
  if not uid then
    return
  end
  if uid == tonumber(DataMgr.roleData.uid) then
    if IsWoWEditor then
      UIManager.AndroidBackToLobby()
    else
      UIManager.ShowUI(UIManager.UI_Config.ugc_mine_main)
    end
  else
    UIManager.ShowUI(UIManager.UI_Config.ugc_guest_work_panel, uid)
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SHOW_GUEST)
end
function Util_UGC.ModListToArray(modList)
  if not modList then
    return nil
  end
  local array = {}
  for _, v in pairs(modList) do
    table.insert(array, v)
  end
  table.sort(array, function(a, b)
    if a.base.state_release ~= b.base.state_release then
      return a.base.state_release > b.base.state_release
    elseif a.base.modify_time ~= b.base.modify_time then
      return a.base.modify_time > b.base.modify_time
    else
      return a.base.slot < b.base.slot
    end
  end)
  return array
end
function Util_UGC.GetCoverList(modList)
  local CoverList = {}
  if not modList then
    return CoverList
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  for key, value in pairs(modList) do
    local state = value.base.state_release or Config_UGC.E_PublishState.Not
    if state == Config_UGC.E_PublishState.Not then
      table.insert(CoverList, value)
    end
  end
  return CoverList
end
function Util_UGC.DuplicateMod(name, mod_id, slot)
  name = name or ""
  local LogicUGCCRUD = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCRUD)
  local showEditWorksList = Util_UGC.ModListToArray(LogicUGCCRUD:GetModeList()) or {}
  local LastName = LocUtil.LocalizeResFormat(8600051, "", #showEditWorksList + 1)
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local Logic_UGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local ModNameMaxLen = Logic_UGC:GetModNameMaxLen()
  local LastNameLen = Util_UGC.GetTextLengthAndSubStr(LastName, ModNameMaxLen)
  local FirstNameLen, FirstName = Util_UGC.GetTextLengthAndSubStr(name, ModNameMaxLen - LastNameLen)
  local FullName = LocUtil.LocalizeResFormat(8600051, FirstName, #showEditWorksList + 1)
  if mod_id ~= nil then
    LogicUGCCRUD:ReqDuplicatePubMod(mod_id, FullName, 2)
  else
    LogicUGCCRUD:ReqDuplicateMod(slot, FullName, 1)
  end
end
function Util_UGC.StartEditGame(slot, template_id, bUpdate)
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  if LogicUGCAuthor:IsBanned(true) then
    return
  end
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  if LoadingSystem.IsShowing() then
    return
  end
  local func = function(bOk)
    if not bOk then
      return
    end
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    if LogicUGCMatch.bUseDirectEdit then
      local LogicUGCCRUD = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCRUD)
      local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
      if TeamUpNewSystem.IsInTeam() then
        LogicUGCCRUD:EnterTeamCreate(slot, template_id)
      else
        LogicUGCCRUD:ReqStartEditGame(slot, true, true, nil, bUpdate)
      end
    else
      LogicUGCMatch:ReqEditModMatch(slot)
    end
  end
  if not PufferDownloader.CheckAllMapPak(nil, func) then
    return
  end
  func(true)
end
function Util_UGC.RefreshLeaderboardItemByProfile(widget, profile, uid)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  uid = uid or 0
  if profile == nil then
    return
  end
  if not slua.isValid(widget) then
    return
  end
  if widget.Common_Avatar_BP_C_0 then
    widget.Common_Avatar_BP_C_0:InitView(1, uid, profile.picUrl, 0, profile.cur_avatar_box_id, profile.level, false, "")
    if tonumber(uid) == tonumber(DataMgr.roleData.uid) then
      widget.Common_Avatar_BP_C_0:SetButtonEnabled(false)
    else
      widget.Common_Avatar_BP_C_0:SetButtonEnabled(true)
    end
  end
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  if widget.UnknowPass_ContinuousBuy_BP then
    widget.UnknowPass_ContinuousBuy_BP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if widget.PlayerName and profile.nickName then
    widget.PlayerName:SetText(profile.nickName)
  end
  if PublishRegionMacros.IsBLUEHOLE() then
    widget.Image_Nation:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    local UIUtil = require("client.common.ui_util")
    UIUtil.UpdateNationImage(widget.Image_Nation, profile.nation)
  end
  if widget.SizeBox_WoWPass and widget.Image_WowPass then
    local util = require("client.slua_ui_framework.util")
    local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
    local Util_UGC = require("client.slua.logic.ugc.util_ugc")
    local UIUtil = require("client.common.ui_util")
    if Util_UGC.WoWPassActive(profile) then
      UIUtil.SetWidgetVisible(widget.SizeBox_WoWPass, true, false)
      local IconPath = Util_UGC.GetWoWPassIconPath(profile)
      local params = {sync = false, bMatchSize = true}
      util.SetTexture(widget.Image_WowPass, IconPath, params)
      if not logic_ugc_WOWPass:CheckWoWPassDisplay(tonumber(uid)) then
        log_format(bWriteLog and "Util_UGC.RefreshLeaderboardItemByProfile in Util_UGC.WoWPassActive(profile), but not logic_ugc_WOWPass:CheckWoWPassDisplay(tonumber(uid)), uid=%s", uid)
        UIUtil.SetWidgetVisible(widget.SizeBox_WoWPass, false, false)
      end
    elseif tonumber(uid) == tonumber(DataMgr.roleData.uid) then
      local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
      local IconPath = logic_ugc_WOWPass:GetWOWpassIcon()
      if IconPath then
        UIUtil.SetWidgetVisible(widget.SizeBox_WoWPass, true, false)
        local params = {sync = false, bMatchSize = true}
        util.SetTexture(widget.Image_WoWPass, IconPath, params)
      end
      if not logic_ugc_WOWPass:CheckWoWPassDisplay(tonumber(uid)) then
        log_format(bWriteLog and "Util_UGC.RefreshLeaderboardItemByProfile in tonumber(uid) == tonumber(DataMgr.roleData.uid), but not logic_ugc_WOWPass:CheckWoWPassDisplay(tonumber(uid)), uid=%s", uid)
        UIUtil.SetWidgetVisible(widget.SizeBox_WoWPass, false, false)
      end
    else
      UIUtil.SetWidgetVisible(widget.SizeBox_WoWPass, false, false)
    end
  end
end
function Util_UGC.IsStandalone()
  local _bIsStandalone
  if slua.isValid(CGameMode) then
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    _bIsStandalone = UKismetSystemLibrary.IsStandalone(CGameMode)
  end
  return _bIsStandalone == true
end
function Util_UGC.IsCreativeWow()
  if not GameStatus.IsInFightingStatus() then
    return false
  end
  if IsEditor then
    return slua.isValid(CGameState) and CGameState.bIsCreativeWoW
  end
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  local SubMode = tonumber(logic_enter_game:GetSubModeId()) or 0
  return SubMode == 600091 or SubMode == 600092 or SubMode == 600093
end
local AutoFormat = function(Str, ...)
  if select("#", ...) <= 0 then
    return Str
  end
  return LocUtil.GeneralFormat(Str, ...)
end
function Util_UGC.GetLocalizeResStr(IdORStr, ...)
  local IdNumber
  if type(IdORStr) == "string" then
    IdNumber = tonumber(IdORStr)
  else
    IdNumber = IdORStr
  end
  if IdNumber ~= nil then
    local Str = ""
    if LocUtil then
      Str = LocUtil.GetLocalizeResStr(IdNumber)
    end
    if Str ~= nil and Str ~= "" then
      return AutoFormat(Str, ...)
    end
  end
  return AutoFormat(tostring(IdORStr), ...)
end
function Util_UGC.BufferCompressData(Buffer)
  if Buffer ~= nil and Buffer ~= "" then
    local UScriptGameplayStatics = import("ScriptGameplayStatics")
    local CompressSuc = false
    local CompressedData = ""
    CompressSuc, CompressedData = UScriptGameplayStatics.ZSTDCompressData(Buffer, CompressedData, 19)
    if CompressSuc then
      Buffer = CompressedData
    end
  end
  return Buffer
end
function Util_UGC.DecompressData(Buffer)
  if Buffer ~= nil and Buffer ~= "" then
    local UScriptGameplayStatics = import("ScriptGameplayStatics")
    local DecompressSuc = false
    local DecompressData = ""
    DecompressSuc, DecompressData = UScriptGameplayStatics.ZSTDDecompressData(Buffer, DecompressData)
    if DecompressSuc then
      Buffer = DecompressData
    end
  end
  return Buffer
end
function Util_UGC.GetPartOfModInfo()
  local ModInfo = {
    setting = {},
    base = {}
  }
  local GameParameterMgr = _G.GetGameParameterManager ~= nil and _G.GetGameParameterManager() or nil
  if GameParameterMgr == nil then
    return ModInfo
  end
  ModInfo.mod_id = GameParameterMgr:GetGameParameter("ModId").Value
  ModInfo.base.mod_id = ModInfo.mod_id
  ModInfo.base.template_id = GameParameterMgr:GetGameParameter("ModTemplateId").Value
  ModInfo.base.uid = GameParameterMgr:GetGameParameter("AuthorID").Value
  ModInfo.base.wow_pass_season_id = GameParameterMgr:GetGameParameter("WowPassSeasonID").Value
  ModInfo.setting.name = GameParameterMgr:GetGameParameter("ModName").Value
  ModInfo.setting.album = GameParameterMgr:GetGameParameter("albumList").Value
  ModInfo.setting.thumb_index = math.ceil(GameParameterMgr:GetGameParameter("thumbIndex").Value)
  ModInfo.setting.tag_v2 = GameParameterMgr:GetGameParameter("ModTagV2").Value
  ModInfo.setting.subfeature_tag = GameParameterMgr:GetGameParameter("ModSubfeatureTag").Value
  return ModInfo
end
function Util_UGC.LoadFileBinaryData(FilePath)
  print(bWriteLog and "[Util_UGC]LoadFileBinaryData FilePath:" .. tostring(FilePath))
  local BinaryData
  local File = io.open(FilePath, "rb")
  local bReadOk = false
  if File then
    local Len = File:seek("end")
    File:seek("set", 0)
    BinaryData = File:read(Len)
    File:close()
    bReadOk = 0 < Len
    if not bReadOk then
      log_warning(bWriteLog and "Util_UGC:LoadFileBinaryData path read failed. " .. tostring(FilePath) .. ", Len=" .. tostring(Len))
    else
      return BinaryData
    end
  end
  log(bWriteLog and "Util_UGC:LoadFileBinaryData read failed. try abs path")
  local BusinessHelper = import("BusinessHelper")
  local AbsPath = BusinessHelper.GetMobileBasePath(FilePath)
  File = io.open(AbsPath, "rb")
  if File then
    local Len = File:seek("end")
    File:seek("set", 0)
    BinaryData = File:read(Len)
    File:close()
    bReadOk = 0 < Len
    if not bReadOk then
      log(bWriteLog and "Util_UGC:LoadFileBinaryData abs path read failed. " .. tostring(AbsPath) .. ", Len=" .. tostring(Len))
    else
      return BinaryData
    end
  else
    log_warning(bWriteLog and "Util_UGC:LoadFileBinaryData abs path read failed! " .. tostring(AbsPath))
  end
  log(bWriteLog and "Util_UGC:LoadFileBinaryData lua io failed, fallback to UE FileHelper. FilePath=" .. tostring(AbsPath))
  local UCreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
  if UCreativeModeBlueprintLibrary then
    BinaryData = UCreativeModeBlueprintLibrary.LoadFileToArrayByFullPath(AbsPath)
    if BinaryData and 0 < #BinaryData then
      bReadOk = true
    else
      log_warning(bWriteLog and "Util_UGC:LoadFileBinaryData UE LoadFileToArrayByFullPath also failed! " .. tostring(AbsPath))
    end
  end
  return BinaryData
end
function Util_UGC.ShowFilterTextTips()
  print(bWriteLog and "Util_UGC.ShowErrorCodeTips")
  if Client then
    local errStr = LocUtil.GetLocalizeResStr(71008)
    BattleNormalTips(errStr)
  end
end
function Util_UGC.WoWPassActive(Profile)
  print(bWriteLog and "Util_UGC.WoWPassActive Profile:" .. tostring(Profile))
  if Profile == nil then
    return false
  end
  if Profile.wow_pass == nil then
    return false
  end
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  if not logic_ugc_WOWPass:CheckWoWPassDisplay(tonumber(Profile.uid)) then
    log(bWriteLog and "Util_UGC.WoWPassActive logic_ugc_WOWPass:CheckWoWPassDisplay return false")
    return false
  end
  if Profile.wow_pass.is_buy == 1 then
    return true
  end
  return false
end
function Util_UGC.GetWoWPassIconPath(Profile)
  print(bWriteLog and "Util_UGC.GetWoWPassIconPath Profile:" .. tostring(Profile))
  if Profile == nil then
    return ""
  end
  if Profile.wow_pass == nil then
    return ""
  end
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  if not logic_ugc_WOWPass:CheckWoWPassDisplay(tonumber(Profile.uid)) then
    return ""
  end
  if Profile.wow_pass.is_buy == 1 then
    local BuyTimes = Profile.wow_pass.accumulate_buy_times or 1
    local WowPassSignCfgs = CDataTable.GetTable("WowPassSign")
    local CurSignCfg
    for ID, SignCfg in pairs(WowPassSignCfgs) do
      if BuyTimes >= SignCfg.AccBuyCount then
        if CurSignCfg == nil then
          Cur        elseif CurSignCfg.AccBuyCount < SignCfg.AccBuyCount then
          Cur        end
      end
    end
    if CurSignCfg ~= nil then
      return CurSignCfg.SignIconPath
    end
  end
  return ""
end
function Util_UGC.IsModWithEvent(ModInfo, EventElementIDs)
  if not ModInfo or not next(ModInfo) then
    log(bWriteLog and "Util_UGC.IsModWithEvent, ModInfo is invalid")
    return false
  end
  if not EventElementIDs then
    log(bWriteLog and "Util_UGC.IsModWithEvent, EventElementIDs is invalid")
    return false
  end
  local IDMap
  if type(EventElementIDs) ~= "table" then
    IDMap = {
      [EventElementIDs] = true
    }
  else
    IDMap = EventElementIDs
  end
  if ModInfo.setting.ds_expired_resource then
    for i, v in ipairs(ModInfo.setting.ds_expired_resource) do
      if IDMap[v] then
        return true
      end
    end
  end
  return false
end
function Util_UGC.IsSubModeGameMod(ModInfo)
  if ModInfo == nil then
    return false
  end
  local TemplateID = 0
  if ModInfo.base ~= nil and ModInfo.base.template_id ~= nil then
    TemplateID = ModInfo.base.template_id
  end
  local TemplateConfig = CDataTable.GetTableData("UGCTemplateConfig", TemplateID)
  if TemplateConfig ~= nil and TemplateConfig.SubModeID ~= 0 then
    return true
  end
  return false
end
function Util_UGC.ReloadCreativeExpiredAssetConfig()
  local ConfigPath = "GameLua.Mod.BaseMod.GamePlay.Config.CreativeExpiredAssetConfig"
  local LastConfig = package.loaded[ConfigPath]
  local bReloadSuccess, ReloadError = xpcall(function()
    package.loaded[ConfigPath] = nil
    require(ConfigPath)
  end, debug.traceback)
  if not bReloadSuccess then
    package.loaded[ConfigPath] = LastConfig
    log_error(bWriteLog and "Util_UGC.ReloadCreativeExpiredAssetConfig failed: " .. tostring(ReloadError))
  end
  return bReloadSuccess
end
return Util_UGC