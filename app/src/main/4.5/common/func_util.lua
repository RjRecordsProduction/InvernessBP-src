FuncUtil = FuncUtil or {
  BitCount = 32,
  BitValues = {
    1,
    2,
    4,
    8,
    16,
    32,
    64,
    128,
    256,
    512,
    1024,
    2048
  },
  dayToMin = 1440,
  hourToMin = 60,
  arrBanIPAreaList = {},
  arrBanStoreList = {},
  arrNotGPUpgradeLink = {},
  defaultJumpLink = "",
  localCountryCode = 0,
  remoteCfgCountryCode = 0,
  turnOnClientSpeLabel = 0,
  remoteCfgBasePreFetch = 0,
  concatDescriptionSwitch = 0
}
local bufstr_table_pool_file = "client.slua.logic.lobby_chat.logic_chat_recruit_bufstr_table_pool"
local local string_format = string.format
local string_gsub = string.gsub
local string_find = string.find
local string_sub = string.sub
local string_len = string.len
local table_move = table.move
local table_sort = table.sort
local math_max = math.max
local math_floor = math.floor
local math_randomseed = math.randomseed
local math_random = math.random
local math_abs = math.abs
local math_type = math.type
local os_time = os.time
local local local local local local local local local local local local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local IsDevelopment = USTExtraBlueprintFunctionLibrary.IsDevelopment()
local slua_Array = slua.Array
local slua_isValid = slua.isValid
local HDmpveRemote = require("client.slua.logic.HDmpveRemote.HDmpveRemote")
local HDmpveRemote_HDmpveRemoteConfigGetString = HDmpveRemote.HDmpveRemoteConfigGetString
local HDmpveRemote_HDmpveRemoteConfigGetInt = HDmpveRemote.HDmpveRemoteConfigGetInt
local HDmpveRemote_HDmpveRemoteConfigGetBool = HDmpveRemote.HDmpveRemoteConfigGetBool
local json = require("common.json_util")
local json_decode = json.decode
function FuncUtil.OnLogin(_)
  local TimeUtil = require("client.common.time_util")
  TimeUtil.SetServerTimeInSec(LobbySystem.roleData.svr_time)
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  Util_UGC.ReloadCreativeExpiredAssetConfig()
  Client.SetTMFPTapWhiteListFlag(LobbySystem.roleData.phone_vibrate_status or 1)
end
function FuncUtil.ShowLoadingToLobby(nMapId)
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  LoadingSystem.ShowLoading(true, nMapId)
end
function OnHyperLinkClicked(MetaData)
  log_tree("FuncUtil OnHyperLinkClicked MetaData:", MetaData)
  if MetaData.id == "GDPRHyperLink" and MetaData.url == "privacy" then
    local long_txt_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.long_txt_manager)
    local LeagalMsgSystem = require("client.slua.logic.common.logic_common_legal_msg")
    LeagalMsgSystem.ShowPrivacyPolicy()
    return
  end
  EventSystem:postEvent(EVENTTYPE_HYPERLINK, EVENTID_HLINK_COMMSGBOXSLUA, MetaData)
end
function FuncUtil.UnionList(list1, list2)
  local list = {}
  table_move(list1, 1, #list1, 1, list)
  local list1Flag = {}
  for _, uid in pairs(list1) do
    list1Flag[uid] = true
  end
  for _, uid in pairs(list2) do
    if not list1Flag[uid] then
      list[#list + 1] = uid
    end
  end
  return list
end
function FuncUtil.GetHDmpveErrorMsg(errorId)
  local msg = LocUtil.GetLocalizeResStr("301234") .. tostring(errorId)
  local gclould_error_define = require("client.common.gclould_error_define")
  if errorId == gclould_error_define.GCLOULD_ErrorNetworkException then
    msg = LocUtil.GetLocalizeResStr("103015")
  elseif errorId == gclould_error_define.GCLOULD_ErrorTimeout then
    msg = LocUtil.GetLocalizeResStr("301235")
  elseif errorId == gclould_error_define.GCLOULD_ErrorInvalidArgument then
    msg = LocUtil.GetLocalizeResStr("301236")
  elseif errorId == gclould_error_define.GCLOULD_ErrorLengthError then
    msg = LocUtil.GetLocalizeResStr("301237")
  elseif errorId == gclould_error_define.GCLOULD_ErrorEmpty then
    msg = LocUtil.GetLocalizeResStr("301238")
  elseif errorId == gclould_error_define.GCLOULD_ErrorNotInitialized then
    msg = LocUtil.GetLocalizeResStr("301239")
  elseif errorId == gclould_error_define.GCLOULD_ErrorNotSupported then
    msg = LocUtil.GetLocalizeResStr("301240")
  elseif errorId == gclould_error_define.GCLOULD_ErrorNotInstalled then
    msg = LocUtil.GetLocalizeResStr("301241")
  elseif errorId == gclould_error_define.GCLOULD_ErrorSystemError then
    msg = LocUtil.GetLocalizeResStr("301242")
  elseif errorId == gclould_error_define.GCLOULD_ErrorNoPermission then
    msg = LocUtil.GetLocalizeResStr("301243")
  elseif errorId == gclould_error_define.GCLOULD_ErrorInvalidGameId then
    msg = LocUtil.GetLocalizeResStr("301244")
  elseif errorId == gclould_error_define.GCLOULD_ErrorChecking then
    msg = LocUtil.GetLocalizeResStr("301245")
  elseif errorId == gclould_error_define.GCLOULD_ErrorConnectFailed then
    msg = LocUtil.GetLocalizeResStr("301246")
  elseif errorId == gclould_error_define.GCLOULD_ErrorPeerCloseConnection then
    msg = LocUtil.GetLocalizeResStr("301247")
  elseif errorId == gclould_error_define.GCLOULD_ErrorPeerStopSession then
    msg = LocUtil.GetLocalizeResStr("301248")
  elseif errorId == gclould_error_define.GCLOULD_ErrorStayInQueue then
    msg = LocUtil.GetLocalizeResStr("301249")
  elseif errorId == gclould_error_define.GCLOULD_ErrorSvrIsFull then
    msg = LocUtil.GetLocalizeResStr("301250")
  elseif errorId == gclould_error_define.GCLOULD_ErrorTokenSvrError then
    msg = LocUtil.GetLocalizeResStr("301251")
  elseif errorId == gclould_error_define.GCLOULD_ErrorAuthFailed then
    msg = LocUtil.GetLocalizeResStr("301252")
  elseif errorId == gclould_error_define.GCLOULD_ErrorOverflow then
    msg = LocUtil.GetLocalizeResStr("301253")
  elseif errorId == gclould_error_define.GCLOULD_ErrorInvalidToken then
    msg = LocUtil.GetLocalizeResStr("4007")
  end
  return msg
end
function FuncUtil.GetActivityIdByURL(s)
  local StringUtil = require("common.string_util")
  local TableUtil = require("common.table_util")
  local activityId = TableUtil.GetTableValue(StringUtil.ParseURLParams(s), "activityid") or 0
  return tonumber(activityId)
end
function FuncUtil.IsActivityUrlValid(url)
  local activityId = FuncUtil.GetActivityIdByURL(url)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityData = ActivityNewSystem.GetActivityByID(activityId)
  if FuncUtil.IsDuringActTime(activityData) then
    return true
  end
  local activityType = FuncUtil.GetActivityTypeByURL(url)
  if 0 < activityType then
    activityData = ActivityNewSystem.GetActivityByType(activityType)
    log(bWriteLog and "[YY]IsActivityUrlValid=====" .. tostring(activityType))
    if FuncUtil.IsDuringActTime(activityData) then
      return true
    end
  end
  return false
end
function FuncUtil.IsDuringActTime(activityData)
  if not activityData then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  if activityData then
    local activityStartTime = activityData.StartTime or 0
    local activityEndTime = activityData.EndTime or 0
    if currentTime >= activityStartTime and currentTime <= activityEndTime then
      return true
    end
  end
  return false
end
function FuncUtil.GetActivityTypeByURL(s)
  local StringUtil = require("common.string_util")
  local TableUtil = require("common.table_util")
  local activityType = TableUtil.GetTableValue(StringUtil.ParseURLParams(s), "activityType") or 0
  local moduleId = TableUtil.GetTableValue(StringUtil.ParseURLParams(s), "module") or 0
  if tonumber(moduleId) ~= BP_ENUM_MODULE_SUPPLY then
    return 0
  end
  return tonumber(activityType)
end
function FuncUtil.GetServerTimeInSec()
  local TimeUtil = require("client.common.time_util")
  return TimeUtil.GetServerTimeInSec()
end
function GetSafeNumber(value)
  if value == nil then
    return 0
  end
  return value
end
function FuncUtil.FormatLog(sFormat, ...)
  if not bWriteLog then
    return
  end
  if not IsDevelopment then
    return
  end
  local bIsFormatValid = true
  if type(sFormat) ~= "string" then
    bIsFormatValid = false
  end
  local tDebugInfo = debug.getinfo(2)
  if not tDebugInfo then
    return
  end
  local sFileBasename = ""
  local sMethodName = ""
  if type(tDebugInfo.name) == "string" then
    sMethodName = tDebugInfo.name
  end
  if type(tDebugInfo.short_src) == "string" then
    sFileBasename = tDebugInfo.short_src
    local sReveredFileBasename = sFileBasename:reverse()
    local nSlashIndex = sReveredFileBasename:find("/") or 0
    local nBackSlashIndex = sReveredFileBasename:find("\\") or 0
    local nTheLastSlashIndex = math_max(nSlashIndex, nBackSlashIndex)
    if 0 < nTheLastSlashIndex then
      sFileBasename = string_sub(sFileBasename, #sFileBasename - nTheLastSlashIndex + 2)
    end
    if sFileBasename:find(".lua", -4) == #sFileBasename - 3 then
      sFileBasename = string_sub(sFileBasename, 1, -5)
    end
  end
  local sLogPrefix = string_format("%s:%s, ", sFileBasename, sMethodName)
  if not bIsFormatValid then
    print(bWriteLog and sLogPrefix)
    return
  end
  sFormat = sLogPrefix .. sFormat
  if 0 < select("#", ...) then
    sFormat = string_format(sFormat, ...)
  end
  print(bWriteLog and sFormat)
end
function FuncUtil.GetFormatText(formatStr, ...)
  local bNewStyle = string_find(formatStr, "{0}")
  local res = ""
  if bNewStyle then
    res = formatStr
    for i, v in pairs({
      ...
    }) do
      local pattern = "{" .. i - 1 .. "}"
      res = string_gsub(res, pattern, tostring(v))
    end
  else
    res = string_format(formatStr, ...)
  end
  return res
end
function FuncUtil.SafeCallFun(tb, funName, ...)
  local TableUtil = require("common.table_util")
  local fun = TableUtil.GetTableValue(tb, funName)
  if type(fun) == "function" then
    return fun(...)
  end
end
function FuncUtil.MarkBit(maskTable, index)
  if index <= 0 or index > FuncUtil.BitCount then
    log_error("FuncUtil.MarkBit index invalid " .. index)
    return
  end
  maskTable[index] = true
end
function FuncUtil.UnmarkBit(maskTable, index)
  if index <= 0 or index > FuncUtil.BitCount then
    log_error("FuncUtil.UnmarkBit index invalid " .. index)
    return
  end
  maskTable[index] = false
end
function FuncUtil.GetBitMaskValue(maskTable)
  local result = 0
  local value = 0
  for i = 1, FuncUtil.BitCount do
    if maskTable[i] then
      value = FuncUtil.BitValues[i]
      if value == nil then
        value = 2 ^ (i - 1)
        FuncUtil.BitValues[i] = value
      end
      result = result + value
    end
  end
  return result
end
function FuncUtil.GetMaxSegement(allSegmentInfo)
  local maxSegment_Solo = -1
  local maxSegment_duo = -1
  local maxSegment_squad = -1
  for k, v in pairs(allSegmentInfo) do
    maxSegment_Solo = math_max(maxSegment_Solo, allSegmentInfo[k][1] or 0, allSegmentInfo[k][4] or 0)
    maxSegment_duo = math_max(maxSegment_duo, allSegmentInfo[k][2] or 0, allSegmentInfo[k][5] or 0)
    maxSegment_squad = math_max(maxSegment_squad, allSegmentInfo[k][3] or 0, allSegmentInfo[k][6] or 0)
  end
  return maxSegment_Solo, maxSegment_duo, maxSegment_squad
end
function FuncUtil.GetCurMaxSegementLevel(allSegmentInfo)
  local maxSegment_Solo = -1
  local maxSegment_duo = -1
  local maxSegment_squad = -1
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client and Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    allSegmentInfo = {
      [3] = allSegmentInfo[3]
    }
  else
    local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
    if logic_multiple_area:IsConnectToRussiaArea() then
      allSegmentInfo = {
        [2] = allSegmentInfo[2]
      }
    end
  end
  if allSegmentInfo then
    maxSegment_Solo, maxSegment_duo, maxSegment_squad = FuncUtil.GetMaxSegement(allSegmentInfo)
  end
  return math_max(maxSegment_Solo, maxSegment_duo, maxSegment_squad)
end
function FuncUtil.Gen_title(res_id, rank, ext_info, rank_id, zone_name)
  if res_id == 0 then
    return ""
  end
  local alias_info = CDataTable.GetTableData("AliasCfg", res_id)
  if not alias_info then
    log(bWriteLog and "alias not found, id:%s uid:%s", res_id)
    return ""
  end
  local title = alias_info.AliasName
  rank = rank or 0
  rank_id = rank_id or 0
  local aliasParam = alias_info.AliasParam
  log(bWriteLog and "FuncUtil.Gen_title aliasParam = " .. tostring(aliasParam))
  if aliasParam and aliasParam == 1 or rank <= 100 and 0 < rank then
    if 0 < rank_id then
      local zoneName = zone_name
      if not zoneName or zoneName == "" then
        local logic_lbs = require("client.slua.logic.lbs.logic_lbs")
        zoneName = logic_lbs.GetZoneName(rank_id)
      end
      title = LocUtil.LocalizeResFormatByStr(title, rank, zoneName)
    else
      title = LocUtil.LocalizeResFormatByStr(title, rank)
    end
  end
  if ext_info and alias_info.AliasType == 5 then
    local UIUtil = require("client.common.ui_util")
    title = LocUtil.LocalizeResFormatByStr(title, ext_info.partner_name or "", UIUtil.GetIntimacyRelationName(ext_info.partner_relation or 1))
  end
  if ext_info and alias_info.AliasType == 6 then
    title = LocUtil.LocalizeResFormatByStr(title, ext_info.psmatch_team_name or "")
  end
  if alias_info.AliasType == 7 then
    local zoneName = ""
    if ext_info and ext_info.weapon_power_zone_id then
      local logic_weaponstrength_tool = require("client.slua.umg.Season_WeaponStrength.logic_weaponstrength_tool")
      zoneName = logic_weaponstrength_tool.GetWeaponStrengthZoneTitle(ext_info.weapon_power_zone_id)
    elseif rank_id then
      local logic_weaponstrength_tool = require("client.slua.umg.Season_WeaponStrength.logic_weaponstrength_tool")
      zoneName = logic_weaponstrength_tool.GetWeaponStrengthZoneTitle(rank_id)
    end
    title = LocUtil.LocalizeResFormatByStr(alias_info.AliasName, rank, zoneName or "")
  end
  if alias_info.AliasType == 8 then
    local year = FuncUtil.GetRegisterYear(ext_info and ext_info.registertime)
    year = math.max(year, 1)
    title = LocUtil.LocalizeResFormatByStr(alias_info.AliasName, year)
  end
  return title
end
function FuncUtil.GenEnterBroadcastMsg(AliasID, PlayerName, value)
  local Msg = ""
  local AliasCfg = CDataTable.GetTableData("AliasCfg", AliasID)
  if PlayerName == nil then
    PlayerName = DataMgr.roleData.nickName
  end
  if AliasCfg and AliasCfg.AliasType == 7 then
    if not value then
      local RoleInfoSystem = require("client.slua.logic.roleInfo.logic_roleinfo_title")
      local aliasInfo = RoleInfoSystem.alias_list_info[AliasID]
      if aliasInfo then
        value = aliasInfo.title
      else
        local alias = DataMgr.roleData.alias
        value = FuncUtil.Gen_title(AliasID, alias.rank, alias.ext_info, alias.rank_id)
      end
    elseif type(value) == "number" then
      value = FuncUtil.Gen_title(AliasID, value)
    end
    Msg = LocUtil.LocalizeResFormat(85064, value, PlayerName)
  else
    if not value then
      local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
      value = collect_module:GetSelfCollectScoreByBriefData() or 0
    end
    local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
    local CollectLevel, _ = collect_module:GetLevelDataByScore(value)
    Msg = LocUtil.LocalizeResFormat(77678, CollectLevel, PlayerName)
  end
  log_format("FuncUtil.GenEnterBroadcastMsg. Msg=%s", Msg)
  return Msg
end
function FuncUtil.GetTopResult(weapon_power_add_result)
  local top_result = {}
  local use_time = 0
  for id, v in pairs(weapon_power_add_result) do
    if use_time <= v.totalusetime then
      top_result.total_score = v.fin_power_count
      top_result.delta_score = v.weapon_power_add_count
      top_result.weapon_      use_time = v.totalusetime
    end
  end
  log_tree("FuncUtil.GetTopResult. top_result = ", top_result)
  return top_result
end
function bufToInt32(num1, num2, num3, num4)
  local num = 0
  num1 = num1 << 24
  num2 = num2 << 16
  num3 = num3 << 8
  num = num1 + num2 + num3 + num4
  return num
end
function int32ToBufStr(num)
  local tablepool = require(bufstr_table_pool_file)
  local strList = tablepool.Get()
  strList[#strList + 1] = (num & 4278190080) >> 24
  strList[#strList + 1] = (num & 16711680) >> 16
  strList[#strList + 1] = (num & 65280) >> 8
  strList[#strList + 1] = num & 255
  return strList
end
local UID_TPPE_GLOBAL = 5
local UID_TYPE_JPKR = 6
function FuncUtil.IsUidGlobal(uid)
  return tonumber(string_sub(uid, 1, 1)) == UID_TPPE_GLOBAL
end
function FuncUtil.IsUidJPKR(uid)
  return tonumber(string_sub(uid, 1, 1)) == UID_TYPE_JPKR
end
function FuncUtil.IsPlayerJP()
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if strRegion == PublishRegionMacros.JAPAN then
    return true
  end
  return false
end
function FuncUtil.IsPlayerJPKR()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    return true
  end
  return false
end
function FuncUtil.GetWithRegion(globalData, japanData, koreaData)
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if strRegion == PublishRegionMacros.KOREA then
    return koreaData
  elseif strRegion == PublishRegionMacros.JAPAN then
    return japanData
  end
  return globalData
end
function FuncUtil.InitRemoteCfg()
  log(bWriteLog and "FuncUtil.InitRemoteCfg")
  local rcStr = HDmpveRemote_HDmpveRemoteConfigGetString("BanAreaCodeConfig", "")
  log(bWriteLog and "FuncUtil.InitRemoteCfg  BanAreaCodeConfig:" .. tostring(rcStr))
  if rcStr ~= nil and type(rcStr) == "string" and 2 < #rcStr then
    local rcDict = json_decode(rcStr)
    for index = 1, #rcDict do
      local banCountryCode = tonumber(rcDict[index])
      if banCountryCode then
        FuncUtil.arrBanIPAreaList[#FuncUtil.arrBanIPAreaList + 1] = banCountryCode
      end
    end
  else
  end
  log(bWriteLog and "FuncUtil.InitRemoteCfg  arrBanIPAreaList:" .. tostring(#FuncUtil.arrBanIPAreaList))
  rcStr = HDmpveRemote_HDmpveRemoteConfigGetString("BanStoreListConfig", "")
  log(bWriteLog and "FuncUtil.InitRemoteCfg  BanStoreListConfig:" .. tostring(rcStr))
  if rcStr ~= nil and type(rcStr) == "string" and 2 < #rcStr then
    local rcDict = json_decode(rcStr)
    for index = 1, #rcDict do
      FuncUtil.arrBanStoreList[#FuncUtil.arrBanStoreList + 1] = rcDict[index]
    end
  else
  end
  log(bWriteLog and "FuncUtil.InitRemoteCfg  arrBanStoreList:" .. tostring(#FuncUtil.arrBanIPAreaList))
  rcStr = HDmpveRemote_HDmpveRemoteConfigGetString("ClientUpgradeLinkConfig", "")
  log(bWriteLog and "FuncUtil.InitRemoteCfg  ClientUpgradeLinkConfig:" .. tostring(rcStr))
  if rcStr ~= nil and type(rcStr) == "string" and 2 < #rcStr then
    local rcDict = json_decode(rcStr)
    for index = 1, #rcDict do
      FuncUtil.arrNotGPUpgradeLink[#FuncUtil.arrNotGPUpgradeLink + 1] = rcDict[index]
    end
  else
  end
  log(bWriteLog and "FuncUtil.InitRemoteCfg  arrNotGPUpgradeLink:" .. tostring(#FuncUtil.arrNotGPUpgradeLink))
  FuncUtil.remoteCfgCountryCode = HDmpveRemote_HDmpveRemoteConfigGetInt("RemoteCfgCountryCode", 0)
  FuncUtil.turnOnClientSpeLabel = HDmpveRemote_HDmpveRemoteConfigGetInt("TurnOnClientSpeLabel", 0)
  FuncUtil.remoteCfgBasePreFetch = HDmpveRemote_HDmpveRemoteConfigGetInt("RemoteCfgBasePreFetch", 0)
  PufferDownloader.SetEnableBackpackCache(0)
  if not FuncUtil.defaultJumpLink or FuncUtil.defaultJumpLink == "" then
    FuncUtil.defaultJumpLink = FuncUtil.GetDomainByID(3366055) or ""
  end
  local JumpLink = HDmpveRemote_HDmpveRemoteConfigGetString("DefaultJumpLink", "")
  if "" ~= JumpLink then
    FuncUtil.default  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local actJson = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLoginBackUpLastCountryNo)
  if actJson ~= nil and tonumber(actJson.LastCountryNo) ~= nil then
    FuncUtil.localCountryCode = tonumber(actJson.LastCountryNo)
  end
  local iTOP_country_no = Client.GetIPRegion()
  if 0 < iTOP_country_no and 0 >= FuncUtil.localCountryCode then
    local actJson = {}
    actJson.LastCountryNo = iTOP_country_no
    PlayerPrefsSystem.SaveTableToFile_N(actJson, PlayerPrefsSystem.ePlayerPrefsType.eLoginBackUpLastCountryNo)
    log(bWriteLog and "FuncUtil.InitRemoteCfg Saved LastCountryNo:" .. tostring(actJson.LastCountryNo))
  end
  log(bWriteLog and "FuncUtil.InitRemoteCfg  remoteCfgCountryCode:" .. tostring(FuncUtil.remoteCfgCountryCode))
  log(bWriteLog and "FuncUtil.InitRemoteCfg  turnOnClientSpeLabel:" .. tostring(FuncUtil.turnOnClientSpeLabel))
  log(bWriteLog and "FuncUtil.InitRemoteCfg  LastCountryNo:" .. tostring(FuncUtil.localCountryCode))
end
function FuncUtil.GetCountryIPCode()
  local iTOP_country_no = 0
  if 0 < FuncUtil.turnOnClientSpeLabel then
    iTOP_country_no = tonumber(Client.GetAreaIPNo())
    log(bWriteLog and "FuncUtil.GetCountryIPCode  Use Label: " .. tostring(iTOP_country_no))
  end
  if 0 == iTOP_country_no then
    iTOP_country_no = Client.GetIPRegion()
    log(bWriteLog and "FuncUtil.GetCountryIPCode  Use iTop: " .. tostring(iTOP_country_no))
  end
  if 0 == iTOP_country_no then
    iTOP_country_no = FuncUtil.remoteCfgCountryCode
    log(bWriteLog and "FuncUtil.GetCountryIPCode  Use Remote: " .. tostring(iTOP_country_no))
  end
  if 0 == iTOP_country_no then
    iTOP_country_no = FuncUtil.localCountryCode
    log(bWriteLog and "FuncUtil.GetCountryIPCode  Use Local: " .. tostring(iTOP_country_no))
  end
  log(bWriteLog and "FuncUtil.GetCountryIPCode  songGT return: " .. tostring(iTOP_country_no))
  return iTOP_country_no
end
function FuncUtil.IsSpecialBanArea()
  local InBanArea = false
  CountryIPCode = FuncUtil.GetCountryIPCode()
  for _, v in ipairs(FuncUtil.arrBanIPAreaList) do
    if v == CountryIPCode then
      log(bWriteLog and "FuncUtil.IsSpecialBanArea songGT true")
      InBanArea = true
      break
    end
  end
  return InBanArea
end
function FuncUtil.IsSpecialBanStore()
  local InBanStore = false
  for _, v in ipairs(FuncUtil.arrBanStoreList) do
    if v == Client.GetAOSSHOP() then
      log(bWriteLog and "FuncUtil.IsSpecialBanStore songGT true")
      InBanStore = true
      break
    end
  end
  return InBanStore
end
function FuncUtil.IsSpecialBanClient()
  return FuncUtil.IsSpecialBanArea() and FuncUtil.IsSpecialBanStore()
end
function FuncUtil.GotoNotGPUpgrade()
  local LinkNum = #FuncUtil.arrNotGPUpgradeLink
  if LinkNum <= 0 then
    if not FuncUtil.defaultJumpLink or FuncUtil.defaultJumpLink == "" then
      FuncUtil.defaultJumpLink = FuncUtil.GetDomainByID(3366055) or ""
    end
    Client.LaunchUrl(FuncUtil.defaultJumpLink)
  else
    math_randomseed(os_time())
    local RandPos = math_random(0, 1000) % LinkNum
    log(bWriteLog and "FuncUtil.GotoNotGPUpgrade songGT RandPos: " .. tostring(RandPos))
    log(bWriteLog and "FuncUtil.GotoNotGPUpgrade songGT LinkNum: " .. tostring(LinkNum))
    if LinkNum > RandPos then
      local link = FuncUtil.arrNotGPUpgradeLink[RandPos + 1]
      log(bWriteLog and "FuncUtil.GotoNotGPUpgrade songGT RandPos: true" .. link)
      Client.LaunchUrl(link)
    else
      log(bWriteLog and "FuncUtil.GotoNotGPUpgrade songGT RandPos: false")
    end
  end
end
function FuncUtil.GetIPRegionForBluePrint()
  return Client.GetIPRegion()
end
function FuncUtil.GetAccountRegionForBP()
  if not DataMgr.RegionData.region then
  end
  local result = DataMgr.RegionData.region or "KR"
  return result
end
FuncUtil.RegisterCountry = nil
function FuncUtil.GetRegisterCountry()
  if FuncUtil.RegisterCountry and FuncUtil.RegisterCountry ~= "" then
    return FuncUtil.RegisterCountry
  end
  return FuncUtil.GetAccountRegionForBP()
end
local _WindowOB
function GetWindowOBState()
  if _WindowOB == nil then
    _WindowOB = Client.IsWindowOB()
  end
  return _WindowOB
end
local _CEHideLobbyUI
function GetCEHideLobbyUI()
  if _CEHideLobbyUI == nil then
    _CEHideLobbyUI = Client.IsCEHideLobbyUI(GameFrontendHUD)
  end
  return _CEHideLobbyUI
end
local formatStr
function FuncUtil.GetItemName(itemName, colorID, patternID, rankNo)
  if formatStr == nil then
    formatStr = LocUtil.GetLocalizeResStr(6227)
  end
  if rankNo ~= nil and rankNo <= 100 and 0 < rankNo then
    itemName = LocUtil.LocalizeResFormatByStr(itemName, rankNo)
  end
  if colorID ~= nil and colorID ~= 0 then
    local colorCfg = CDataTable.GetTableData("DiySuitColorConfig", colorID)
    if colorCfg then
      return string_format(formatStr, itemName, colorCfg.ColorName)
    end
  end
  return itemName
end
function FuncUtil.GetLanguageTable()
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    return CDataTable.GetTable("TransSupportConfig_JK")
  elseif strRegion == PublishRegionMacros.VNG then
    return CDataTable.GetTable("TransSupportConfig_VNG")
  elseif strRegion == PublishRegionMacros.TW then
    return CDataTable.GetTable("TransSupportConfig_TW")
  elseif strRegion == PublishRegionMacros.BLUEHOLE then
    return CDataTable.GetTable("TransSupportConfig_BLUEHOLE")
  else
    return CDataTable.GetTable("TransSupportConfig_GLOBAL")
  end
end
function FuncUtil.GetLanguageTableName()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsCEVersion() then
    return "TransSupportConfig_CE"
  else
    local strRegion = Client.GetPublishRegion()
    if PublishRegionMacros.IsJapanOrKorea() then
      return "TransSupportConfig_JK"
    elseif strRegion == PublishRegionMacros.VNG then
      return "TransSupportConfig_VNG"
    elseif strRegion == PublishRegionMacros.TW then
      return "TransSupportConfig_TW"
    elseif strRegion == PublishRegionMacros.BLUEHOLE then
      return "TransSupportConfig_BLUEHOLE"
    end
  end
  return "TransSupportConfig_GLOBAL"
end
function FuncUtil.GetRechargeLevelTable(bUGC)
  local tabledata
  local strRegion = Client.GetPublishRegion()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    if bUGC then
      if PublishRegionMacros.IsJapanOrKorea() then
        tabledata = CDataTable.GetTable("UGCRechargeLevel_IOS_JK")
      elseif strRegion == PublishRegionMacros.VNG then
        tabledata = CDataTable.GetTable("UGCRechargeLevel_IOS_VNG")
      elseif strRegion == PublishRegionMacros.TW then
        tabledata = CDataTable.GetTable("UGCRechargeLevel_IOS_TW")
      elseif strRegion == PublishRegionMacros.BLUEHOLE then
        tabledata = CDataTable.GetTable("UGCRechargeLevel_IOS_BLUEHOLE")
      elseif strRegion == PublishRegionMacros.FIT then
        tabledata = CDataTable.GetTable("UGCRechargeLevel_IOS_FIT")
      else
        tabledata = CDataTable.GetTable("UGCRechargeLevel_IOS_GLOBAL")
      end
    elseif PublishRegionMacros.IsJapanOrKorea() then
      tabledata = CDataTable.GetTable("RechargeLevel_IOS_JK")
    elseif strRegion == PublishRegionMacros.VNG then
      tabledata = CDataTable.GetTable("RechargeLevel_IOS_VNG")
    elseif strRegion == PublishRegionMacros.TW then
      tabledata = CDataTable.GetTable("RechargeLevel_IOS_TW")
    elseif strRegion == PublishRegionMacros.BLUEHOLE then
      tabledata = CDataTable.GetTable("RechargeLevel_IOS_BLUEHOLE")
    elseif strRegion == PublishRegionMacros.FIT then
      tabledata = CDataTable.GetTable("RechargeLevel_IOS_FIT")
    else
      tabledata = CDataTable.GetTable("RechargeLevel_IOS_GLOBAL")
    end
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android then
    if bUGC then
      if PublishRegionMacros.IsJapanOrKorea() then
        tabledata = CDataTable.GetTable("UGCRechargeLevel_Android_JK")
      elseif strRegion == PublishRegionMacros.VNG then
        tabledata = CDataTable.GetTable("UGCRechargeLevel_Android_VNG")
      elseif strRegion == PublishRegionMacros.TW then
        tabledata = CDataTable.GetTable("UGCRechargeLevel_Android_TW")
      elseif strRegion == PublishRegionMacros.BLUEHOLE then
        tabledata = CDataTable.GetTable("UGCRechargeLevel_Android_BLUEHOLE")
      elseif strRegion == PublishRegionMacros.FIT then
        tabledata = CDataTable.GetTable("UGCRechargeLevel_Android_FIT")
      else
        tabledata = CDataTable.GetTable("UGCRechargeLevel_Android_GLOBAL")
      end
    elseif PublishRegionMacros.IsJapanOrKorea() then
      tabledata = CDataTable.GetTable("RechargeLevel_Android_JK")
    elseif strRegion == PublishRegionMacros.VNG then
      tabledata = CDataTable.GetTable("RechargeLevel_Android_VNG")
    elseif strRegion == PublishRegionMacros.TW then
      tabledata = CDataTable.GetTable("RechargeLevel_Android_TW")
    elseif strRegion == PublishRegionMacros.BLUEHOLE then
      tabledata = CDataTable.GetTable("RechargeLevel_Android_BLUEHOLE")
    elseif strRegion == PublishRegionMacros.FIT then
      tabledata = CDataTable.GetTable("RechargeLevel_Android_FIT")
    else
      tabledata = CDataTable.GetTable("RechargeLevel_Android_GLOBAL")
    end
  elseif bUGC then
    tabledata = CDataTable.GetTable("UGCRechargeLevel_IOS_GLOBAL")
  else
    tabledata = CDataTable.GetTable("RechargeLevel_IOS_GLOBAL")
  end
  return tabledata
end
function FuncUtil.GetLoginTypeTable(Region)
  local table = CDataTable.GetTable("LoginTypeListCfg")
  local default
  local language = Client.GetCurrentLanguage()
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  local bCloudVersion = logic_cloud_game:IsCloudVersion()
  local FacadeRegion = bCloudVersion and "CLOUD" or Region
  for i, v in pairs(table) do
    if v.ID == FacadeRegion then
      if v.language == language then
        return v
      elseif v.language == "default" then
        default = v
      end
    end
  end
  return default
end
function FuncUtil.GetRegionConfigTable()
  return CDataTable.GetTable("RegionConfig")
end
function pairsByKeys(t)
  local a = {}
  for i, v in pairs(t) do
    a[#a + 1] = i
  end
  table_sort(a)
  local i = 0
  return function()
    i = i + 1
    return a[i], t[a[i]]
  end
end
function pairsReversedByKeys(t)
  local a = {}
  for i, v in pairs(t) do
    a[#a + 1] = i
  end
  table_sort(a)
  local i = #a + 1
  return function()
    i = i - 1
    return a[i], t[a[i]]
  end
end
function FuncUtil.short_code_to_uid(short_code)
  return tonumber(short_code, 36)
end
function FuncUtil.Clamp(t, min, max)
  if t < min then
    return min
  elseif max < t then
    return max
  else
    return t
  end
end
function FuncUtil.FormatNum_Simple(num)
  if 1000.0 <= num then
    num = math_floor(num / 100.0)
    return string_format("%.1f", num / 10) .. "K"
  else
    return tostring(num)
  end
end
function FuncUtil.CondOp(cond, v1, v2)
  if cond then
    return v1
  else
    return v2
  end
end
function FuncUtil.JudgeIsSameClient(other_uid)
  other_uid = tostring(other_uid)
  if not FuncUtil.IsPlayerJPKR() then
    if FuncUtil.IsUidGlobal(other_uid) then
      return true
    end
  elseif FuncUtil.IsUidJPKR(other_uid) then
    return true
  end
  return false
end
function FuncUtil.CheckNumber(value, base)
  return tonumber(value, base) or 0
end
function FuncUtil.FormatNumberThousands(num)
  local formatted = tostring(FuncUtil.CheckNumber(num))
  local k
  while true do
    formatted, k = string_gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
    if k == 0 then
      break
    end
  end
  return formatted
end
function FuncUtil.GetItemNameWithLimitTime(name, limitTime)
  local timeStr
  if limitTime and 0 < limitTime then
    timeStr = FuncUtil.TimeNumToTimeS(limitTime)
  end
  local ret = name
  if timeStr then
    ret = LocUtil.LocalizeResFormatByStr("{0} [{1}]", name, timeStr)
  end
  return ret
end
function FuncUtil.TimeNumToTimeS(timeNum)
  local result = ""
  if timeNum ~= nil and type(timeNum) == "number" and 0 < timeNum then
    if timeNum < 24 then
      result = LocUtil.LocalizeResFormat(4795, tostring(timeNum))
    else
      result = LocUtil.LocalizeResFormat(4409, tostring(math.modf(timeNum / 24)))
    end
  end
  log(bWriteLog and "FuncUtil.TimeNumToTimeS, timeNum = " .. tostring(timeNum) .. ", result = " .. tostring(result))
  return result
end
function FuncUtil.GetNetworkTypeAsNum()
  local networkType_str = Client.GetNetWorkType()
  local networkTypeTable = {
    Wifi = 1,
    ["2G"] = 4,
    ["3G"] = 5,
    ["4G"] = 6,
    ["5G"] = 8,
    ETHERNET = 9,
    VPN = 17,
    BLUETOOTH = 7,
    Other = 0,
    error = -1,
    NULL = -2
  }
  local networkType = networkTypeTable[networkType_str]
  if not networkType then
    log_warning("Can't get network type from C++")
    networkType = -2
  end
  return networkType
end
function FuncUtil.AddToDelegate(delegate, fun)
  if delegate and delegate.Add and fun then
    return delegate:Add(fun)
  end
end
function FuncUtil.RemoveFromDelegate(delegate, handle)
  if delegate and delegate.Remove and handle then
    return delegate:Remove(handle)
  end
end
function Reload(module_name)
  if module_name == "" then
    ShowDevNotice("###\232\175\183\232\190\147\229\133\165\230\168\161\229\157\151\229\144\141,\230\148\175\230\140\129\230\168\161\231\179\138\229\140\185\233\133\141")
    return
  end
  local lower_module_name = string.lower(module_name)
  local search_results = {}
  if package and package.loaded then
    for moduleName, _ in pairs(package.loaded) do
      if type(moduleName) == "string" and string.lower(moduleName).find(moduleName, lower_module_name) then
        table.insert(search_results, moduleName)
      end
    end
  end
  if 10 < #search_results then
    ShowDevNotice("###reload\232\182\133\232\191\135\228\186\13410\228\184\170\230\150\135\228\187\182\228\186\134,\232\175\183\232\190\147\229\133\165\230\155\180\229\164\154\231\154\132\229\140\185\233\133\141\232\175\141")
    return
  end
  local notify = function(tips)
    ShowNotice(tips)
  end
  local reloadModule = RequireBlackList("blacklist.reload.reload")
  if reloadModule then
    reloadModule.Reload(search_results, notify, notify)
  end
end
function FuncUtil.GetPriceIconPath(currency)
  local currencyIcon = ""
  if currency == StoreConst.label_price_type_bp then
    currencyIcon = CDataTable.GetTableData("Item", 1000).ItemSmallIcon
  elseif currency == StoreConst.label_price_type_chip then
    currencyIcon = CDataTable.GetTableData("Item", 1001).ItemSmallIcon
  elseif currency == StoreConst.label_price_type_uc then
    currencyIcon = CDataTable.GetTableData("Item", 1006).ItemSmallIcon
  elseif currency == StoreConst.label_price_type_fp then
    currencyIcon = CDataTable.GetTableData("Item", 1101).ItemSmallIcon
  elseif currency == StoreConst.label_price_type_gold_chip then
    currencyIcon = CDataTable.GetTableData("Item", 1104).ItemSmallIcon
  elseif currency == StoreConst.label_price_type_battle then
    currencyIcon = CDataTable.GetTableData("Item", 1103).ItemSmallIcon
  elseif currency == StoreConst.label_price_type_iap then
    currencyIcon = SInAppPurchase
  end
  return currencyIcon
end
function FuncUtil.IsTeamMode(battle_type)
  return battle_type == 703 or battle_type == 713 or battle_type == 723 or battle_type == 733 or battle_type == 13703 or battle_type == 1703 or battle_type == 1713 or battle_type == 2703 or battle_type == 2713
end
function FuncUtil.IsXmissionTeamMode(battle_type)
  return battle_type and battle_type == 23713
end
function FuncUtil.IsEscapeMode(battle_type)
  return battle_type and battle_type == 64814
end
function FuncUtil.IsRankTeamMode(battle_type)
  return battle_type == 723 or battle_type == 733
end
function FuncUtil.IsTeam8v8(battle_type)
  return battle_type == 1703 or battle_type == 1713
end
function FuncUtil.GetPreciseDecimal(nNum, n)
  if type(nNum) ~= "number" then
    return nNum
  end
  n = n or 0
  n = math_floor(n)
  if n < 0 then
    n = 0
  end
  local nDecimal = 10 ^ n
  local nTemp = math_floor(nNum * nDecimal)
  local nRet = nTemp / nDecimal
  return nRet
end
function FuncUtil.GetLuaGlobalUI()
  local ui = UIManager.GetUI(UIManager.UI_Config.lua_global_ui)
  ui = ui or UIManager.ShowUI(UIManager.UI_Config.lua_global_ui)
  return ui.UIRoot
end
function FuncUtil.TransformNumToFormatStr(num)
  if not num or type(num) ~= "number" then
    log_error("TransformNumToFormatStr invalid input!!!")
    return ""
  end
  if num < 0 then
    return "-" .. FuncUtil.TransformNumToFormatStr(-num)
  elseif num < 1000 then
    return tostring(num)
  elseif num < 1000000 then
    local append = math_floor(num % 1000)
    local append_str = "000"
    if 100 <= append then
      append_str = tostring(append)
    elseif 10 <= append then
      append_str = string_format("0%d", append)
    else
      append_str = string_format("00%d", append)
    end
    return string_format("%d,%s", math_floor(num / 1000), append_str)
  else
    local temp1 = math_floor(num / 100)
    local temp2 = math_floor(num / 1000)
    local decimal = temp1 % temp2
    local len = string_len(temp2)
    local str = ""
    local idx = 0
    for i = len, 0, -1 do
      idx = idx + 1
      str = string_sub(temp2, i, i) .. str
      if idx % 3 == 0 and 1 < i then
        str = "," .. str
      end
    end
    if decimal == 0 then
      return string_format("%s%s", str, "K")
    else
      return string_format("%s.%d%s", str, decimal, "K")
    end
  end
end
local function _SerializeTable(table)
  local strResult = ""
  for i, v in pairs(table) do
    strResult = strResult .. tostring(i)
    if type(v) == "table" then
      strResult = strResult .. _SerializeTable(v)
    else
      strResult = strResult .. tostring(v)
    end
  end
  return strResult
end
function FuncUtil.SerializeOneTable(table)
  return _SerializeTable(table)
end
function FuncUtil.CheckAreaCodeLegal(code)
  local ecTable = CDataTable.GetTable("EuropeanCountries")
  for _, v in pairs(ecTable) do
    if v.AreaCode == code and v.IsEEU == true then
      return false
    end
  end
  return true
end
function FuncUtil.TransLanguageToImsdkLanguage()
  local lang = Client.GetCurrentLanguage()
  local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
  log(bWriteLog and "TransLanguageToImsdkLanguage lang = " .. tostring(lang))
  if lang == LanguageMacros.AR then
    return "ar_AE"
  elseif lang == LanguageMacros.JA then
    return "ja_JP"
  elseif lang == LanguageMacros.KO then
    return "ko_KR"
  elseif lang == LanguageMacros.RU then
    return "ru_RU"
  elseif lang == LanguageMacros.PT then
    return "pt_PT"
  elseif lang == LanguageMacros.TH then
    return "en_TH"
  elseif lang == LanguageMacros.ZH then
    return "zh_CN"
  elseif lang == LanguageMacros.HK then
    return "zh-HK"
  elseif lang == LanguageMacros.TW then
    return "zh_TW"
  elseif lang == LanguageMacros.DE then
    return "de_DE"
  elseif lang == LanguageMacros.ID then
    return "en_ID"
  elseif lang == LanguageMacros.FR then
    return "fr_FR"
  elseif lang == LanguageMacros.ES then
    return "es_LA"
  elseif lang == LanguageMacros.TR then
    return "tr_TR"
  elseif lang == LanguageMacros.HI then
    return "hi-IN"
  elseif lang == LanguageMacros.MS then
    return "ms_MY"
  elseif lang == LanguageMacros.UZ then
    return "uz-UZ"
  elseif lang == LanguageMacros.UR then
    return "ur-PK"
  elseif lang == LanguageMacros.MY then
    return "my-MM"
  end
  return "en_US"
end
function FuncUtil.UE4ExecuteConsoleCommand(command)
  local KismetSystemLibraryCls = import("KismetSystemLibrary")
  local UIUtil = require("client.common.ui_util")
  KismetSystemLibraryCls.ExecuteConsoleCommand(UIUtil.GetGameInstance(), command, nil)
end
function FuncUtil.UE4GetConsoleVariableIntValue(command)
  local KismetSystemLibraryCls = import("KismetSystemLibrary")
  return KismetSystemLibraryCls.GetConsoleVariableIntValue(command)
end
function FuncUtil.GetMaxKD(rankdata)
  local kd = 0
  for _, zonedata in pairs(rankdata) do
    for _, segmenttype in pairs(struct_SegmentType) do
      local segmentdata = zonedata[segmenttype]
      local kd_v2 = segmentdata.kd_v2 or segmentdata.kd
      if kd < kd_v2 then
        kd = kd_v2
      end
    end
  end
  return kd
end
function FuncUtil.GetLanguageDisplayName(language)
  local languageCode = ""
  local displayName = ""
  local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
  if language == LanguageMacros.HK then
    languageCode = "zh-HK"
  elseif language == LanguageMacros.TW then
    languageCode = "zh-TW"
  else
    languageCode = language
  end
  for _, v in pairs(FuncUtil.GetLanguageTable()) do
    if v.languageCode == languageCode then
      displayName = v.displayName
      break
    end
  end
  return displayName
end
function FuncUtil.AddCrashContextMainFlow(stage, errno)
  local msg = ""
  if errno == nil then
    msg = tostring(stage)
  else
    msg = string_format("%s[%s]", stage, errno)
  end
  log(bWriteLog and "CrashCntxtReport MainFlow: " .. msg)
  Client.AddCrashContextData(2003, msg, false, 100)
end
function FuncUtil.GetDVID()
  local dvidRet = ""
  local PlayerPrefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  local localStoreDic = PlayerPrefs.LoadFileToTable_N(PlayerPrefs.ePlayerPrefsType.eDefault)
  if localStoreDic == nil then
    localStoreDic = {}
  end
  if localStoreDic.dvid == nil then
    local timestamp = os_time()
    math_randomseed(timestamp)
    local randomId = math_random(10000, 99999)
    local vid = tostring(randomId) .. tostring(timestamp)
    localStoreDic.d    PlayerPrefs.SaveTableToFile_N(localStoreDic, PlayerPrefs.ePlayerPrefsType.eDefault)
    log(bWriteLog and "Create dvid: " .. tostring(vid))
  end
  dvidRet = localStoreDic.dvid
  log(bWriteLog and "FuncUtil.GetDVID() return: " .. tostring(dvidRet))
  return dvidRet
end
function FuncUtil.GetAllActorsByTag(sActorBPPath, sTag)
  local GameplayStatics = import("GameplayStatics")
  local uActorClass = import("/Script/Engine.Actor")
  local uWorldActorClass = import(sActorBPPath)
  local UIUtil = require("client.common.ui_util")
  local uWorldActorArray = GameplayStatics.GetAllActorsOfClass(UIUtil.GetGameInstance(), uWorldActorClass, slua_Array(UEnums.EPropertyClass.Object, uActorClass))
  local uOutActorArray = slua_Array(UEnums.EPropertyClass.Object, uActorClass)
  for _, uActor in pairs(uWorldActorArray) do
    if uActor and slua_isValid(uActor) and uActor:ActorHasTag(sTag) then
      uOutActorArray:Add(uActor)
    end
  end
  return uOutActorArray
end
function ShowHide(config)
  local ui = UIManager.GetUI(UIManager.UI_Config[config])
  if ui then
    UIManager.CloseUI(UIManager.UI_Config[config])
  else
    UIManager.ShowUI(UIManager.UI_Config[config])
  end
end
function FuncUtil.IsInXMission()
  local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
  return XMissionSystem.IsInXMission()
end
function FuncUtil.IsLoginSameDay()
  local TimeUtil = require("client.common.time_util")
  local TableUtil = require("common.table_util")
  local last = TableUtil.GetTableValue(DataMgr, "roleData", "old_last_login_time")
  if last == nil then
    last = 0
  end
  local nNow = TimeUtil.GetServerTimeInSec()
  return TimeUtil.IsSameDay(last, nNow)
end
function FuncUtil.GetJsonFileToTable(fileName)
  local filePath = string_format("Paks/SaveGames/%s.json", fileName)
  local str = Client.LoadFileToString(filePath)
  if str == nil or str == "" then
    return nil
  end
  return json_decode(str)
end
function FuncUtil.TestAssetLoad(ListFileName)
  local FileList = FuncUtil.GetJsonFileToTable(ListFileName)
  if not FileList then
    log(bWriteLog and "Load cfg failed: " .. ListFileName)
    return
  end
  Client.TPerforPlatMarkTime(50001)
  local asset_util = require("common.asset_util")
  local pak_util = require("client.common.pak_util")
  for k, v in pairs(FileList) do
    if pak_util.IsFileExist(v) then
      asset_util.GetAssetSync(v)
    end
  end
  Client.TPerforPlatReport(50001, ListFileName .. "Asset Load test end...")
end
function FuncUtil.FloatToShow(val, n)
  local val_int = math_floor(val)
  if n <= 0 then
    return val_int
  end
  if math_abs(val - val_int) < 0.1 ^ n then
    return val_int
  else
    local fmt = "%." .. n .. "f"
    return string_format(fmt, val)
  end
end
function FuncUtil.GetRankTableData(segment, seasonId, ifSecondGet)
  if not segment then
    return nil
  end
  local seasonIndex = seasonId or 0
  local rankTableName = FuncUtil.GetRankTableName(seasonIndex)
  if not rankTableName then
    log(bWriteLog and "FuncUtil.GetRankTableData rankTableName is nil!")
    return nil
  end
  local rankCfg = CDataTable.GetTableData(rankTableName, segment)
  if rankCfg and rankCfg.IsRankInvalid then
    log(bWriteLog and "FuncUtil.GetRankTableData Try to get invalid segment id, segment id is: " .. tostring(segment))
    rankCfg = nil
  end
  if rankCfg == nil and 0 <= seasonIndex and not ifSecondGet then
    log(bWriteLog and "FuncUtil.GetRankTableData Try to get last season rank table")
    return FuncUtil.GetRankTableData(segment, seasonIndex - 1, true)
  end
  return rankCfg
end
function FuncUtil.GetWOWRankTableData(segment)
  if not segment then
    return
  end
  local rankCfg = CDataTable.GetTableData("UGCSegmentData", segment)
  return rankCfg
end
function FuncUtil.GetWowRankTable()
  local rankTable = CDataTable.GetTable("UGCSegmentData")
  return rankTable
end
function FuncUtil.GetOnWowRankTable(index)
  local rankTable = CDataTable.GetTable("UGCSegmentData")
  if 6 < index then
    index = 6
  end
  return rankTable[index].next_segment_score
end
function FuncUtil.GetRankTable(seasonId)
  local rankTableName = FuncUtil.GetRankTableName(seasonId)
  if not rankTableName then
    log(bWriteLog and "FuncUtil.GetRankTable rankTableName is nil!")
    return {}
  end
  return CDataTable.GetTableByFilter(rankTableName, "IsRankInvalid", false)
end
function FuncUtil.GetRankTableName(seasonId)
  local seasonIndex = seasonId or 0
  if seasonIndex == 0 then
    seasonIndex = DataMgr.season_id
  elseif seasonIndex == -1 then
    seasonIndex = DataMgr.season_id - 1
  end
  local seasonCfg = CDataTable.GetTableData("SeasonInfo", seasonIndex)
  if not seasonCfg then
    log(bWriteLog and "FuncUtil.GetRankTableName SesaonConfig is nil!")
    return
  end
  return seasonCfg.RankTableName
end
local JumpAppStore = function(url)
  log(bWriteLog and "  : JumpAppStore url " .. tostring(url))
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    Client.OpenURLInSDK(url, false, true, false, "{}")
  else
    Client.LaunchUrl(url)
  end
end
function FuncUtil.JumpToDownloadApp()
  LobbySystem.CloseOtherMenu()
  local platformName = Client.GetDevicePlatformName()
  local strRegion = Client.GetPublishRegion()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    if platformName == DevicePlatformNameMacros.IOS then
      JumpAppStore(FuncUtil.GetDomainByID(3366100) .. "/app/id1366526331")
    elseif platformName == DevicePlatformNameMacros.Android then
      if Client.GetAOSSHOP() == AOSSHOPMacros.Samsung then
        local DolphinConfig = require("client.slua.umg.NewUpdate.dolphin_updater_config")
        local url = DolphinConfig:GetAppStoreUrl()
        JumpAppStore(url)
      else
        JumpAppStore(FuncUtil.GetDomainByID(3366102) .. "/store/apps/details?id=com.pubg.krmobile")
      end
    else
      log(bWriteLog and "[TAL]===Client.GetDevicePlatformName() is " .. platformName)
    end
  elseif strRegion == PublishRegionMacros.VNG then
    if platformName == DevicePlatformNameMacros.IOS then
      JumpAppStore(FuncUtil.GetDomainByID(3366100) .. "/app/id1438396625")
    else
      JumpAppStore(FuncUtil.GetDomainByID(3366102) .. "/store/apps/details?id=" .. FuncUtil.GetDomainByID(3366175))
    end
  elseif strRegion == PublishRegionMacros.TW then
    if platformName == DevicePlatformNameMacros.IOS then
      JumpAppStore(FuncUtil.GetDomainByID(3366100) .. "/app/id1453363650")
    else
      JumpAppStore(FuncUtil.GetDomainByID(3366102) .. "/store/apps/details?id=" .. FuncUtil.GetDomainByID(3366210))
    end
  else
    local id = 1330123889
    local fixWord = FuncUtil.GetKeywordByID(3377004)
    local bundleId = "com." .. fixWord .. ".ig"
    if strRegion == PublishRegionMacros.BLUEHOLE then
      id = 1526436837
      bundleId = "com.pubg.imobile"
    end
    if platformName == DevicePlatformNameMacros.IOS then
      JumpAppStore(FuncUtil.GetDomainByID(3366100) .. "/ca/app/id" .. id)
    elseif platformName == DevicePlatformNameMacros.Android then
      if Client.GetAOSSHOP() == AOSSHOPMacros.Samsung then
        local DolphinConfig = require("client.slua.umg.NewUpdate.dolphin_updater_config")
        local url = DolphinConfig:GetAppStoreUrl()
        JumpAppStore(url)
      elseif Client.GetAOSSHOP() == AOSSHOPMacros.Amazon then
        JumpAppStore(FuncUtil.GetDomainByID(3366103) .. "/gp/mas/dl/android?p=" .. bundleId)
      elseif Client.GetAOSSHOP() == AOSSHOPMacros.HMS then
        JumpAppStore("market://details?id=" .. bundleId)
      else
        JumpAppStore(FuncUtil.GetDomainByID(3366102) .. "/store/apps/details?id=" .. bundleId)
      end
    else
      log(bWriteLog and "[TAL]===Client.GetDevicePlatformName() is " .. platformName)
    end
  end
end
function FuncUtil.GetLbsAreaName(rank_id)
  log(bWriteLog and "FuncUtil.GetLbsAreaName rankd_id:" .. tostring(rank_id))
  local logic_lbs = require("client.slua.logic.lbs.logic_lbs")
  return logic_lbs.GetZoneName(rank_id)
end
function FuncUtil.IsFloatEqual(n, f)
  local eps = 1.0E-7
  return eps > math_abs(n - f)
end
local JumpUrl = function(url, isBlueHole)
  if isBlueHole then
    local JumpUtils = require("client.logic.store.jump_utils")
    if JumpUtils.IsPanDoraJumpUrl(url) then
      return false
    end
  end
  GlobalData.JumpUrl(url)
  return true
end
local JumpWardrobe = function(itemId)
  local params = {itemId = itemId}
  local jump_utils = require("client.logic.store.jump_utils")
  jump_utils.OpenJumpModule(BP_ENUM_MODULE_WARDROBE, params)
end
function FuncUtil.ItemJump(itemId)
  local jumpConfig = CDataTable.GetTableData("JumpExchangeUrlConfig", itemId)
  if not jumpConfig then
    JumpWardrobe(itemId)
    return
  end
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not JumpUrl(jumpConfig.JumpExchangeUrl, strRegion == PublishRegionMacros.BLUEHOLE) then
    JumpWardrobe(itemId)
  end
end
function FuncUtil.GetGamePublishID()
  local gamePublishID
  local regionStr = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    gamePublishID = 1321
  elseif regionStr == PublishRegionMacros.VNG then
    gamePublishID = 1380
  elseif regionStr == PublishRegionMacros.TW then
    gamePublishID = 1390
  elseif regionStr == PublishRegionMacros.BLUEHOLE then
    gamePublishID = 1450
  elseif regionStr == PublishRegionMacros.FIT then
    gamePublishID = 1440
  else
    gamePublishID = 1320
  end
  return gamePublishID
end
function FuncUtil.ReplaceIllegalChar(str, replaceChar)
  if not str or type(str) ~= "string" or str == "" then
    return str
  end
  replaceChar = replaceChar or ";"
  str = string_gsub(str, "\r\n", replaceChar)
  str = string_gsub(str, "|", replaceChar)
  return str
end
function FuncUtil.ReplaceEnterChar(str, replaceChar)
  log(bWriteLog and "ReplaceEnterChar")
  if not str or type(str) ~= "string" or str == "" then
    return str
  end
  replaceChar = replaceChar or ""
  str = string_gsub(str, "\r", replaceChar)
  str = string_gsub(str, "\n", replaceChar)
  return str
end
function FuncUtil.LuaArrayToTable(luaArray)
  local result = {}
  for i = 0, luaArray:Num() - 1 do
    result[#result + 1] = luaArray:Get(i)
  end
  return result
end
function FuncUtil.GetDomainByID(id)
  local data = CDataTable.GetTableData("DomainCfg", id)
  return data and data.Domain or ""
end
function FuncUtil.GetKeywordByID(id)
  if not id then
    log(bWriteLog and "FuncUtil.GetKeywordByID no id")
    return ""
  end
  local data = CDataTable.GetTableData("KeywordConfig", id)
  return data and data.Keyword or ""
end
function FuncUtil.ByteList2Int(tList)
  log_tree(bWriteLog and "[edward] FuncUtil.List2Bitmap, before = ", tList)
  local bitmap = 0
  for _, bit in ipairs(tList) do
    local tempBit = bit % 32
    if tempBit == 0 then
      tempBit = 32
    end
    bitmap = bitmap + (1 << tempBit - 1)
  end
  log(bWriteLog and "[edward] FuncUtil.List2Bitmap, after = " .. bitmap)
  return bitmap
end
function FuncUtil.Int2ByteList(val, size)
  log(bWriteLog and "[edward] FuncUtil.Bitmap2List, before, size = ", val, size)
  if not val then
    log_error(bWriteLog and "[edward] FuncUtil.Bitmap2List param is error 1")
    return
  end
  if val <= 0 then
    log_error(bWriteLog and "[edward] FuncUtil.Bitmap2List param is error 2")
    return
  end
  size = size or 32
  local list = {}
  for i = 1, size do
    if 0 < 1 << i - 1 & val then
      list[#list + 1] = i
    end
  end
  log_tree(bWriteLog and "[edward] FuncUtil.Bitmap2List, after = ", list)
  return list
end
function FuncUtil.Conv_Int64ToText(iNum)
  if math_type(iNum) ~= "integer" then
    log_error("FuncUtil.Conv_Int64ToText iNum:" .. tostring(iNum))
    return iNum
  end
  local KismetTextLibrary = import("KismetTextLibrary")
  return KismetTextLibrary.Conv_Int64ToText(iNum, true, 1, 324)
end
function FuncUtil.Conv_FloatToText(fNum, decimalPrecision)
  if math_type(fNum) ~= "float" then
    log_error("FuncUtil.Conv_FloatToText fNum:" .. tostring(fNum))
    if math_type(fNum) == "integer" then
      local KismetTextLibrary = import("KismetTextLibrary")
      return KismetTextLibrary.Conv_Int64ToText(fNum, true, 1, 324)
    else
      return fNum
    end
  end
  local KismetTextLibrary = import("KismetTextLibrary")
  local ERoundingMode = import("ERoundingMode")
  return KismetTextLibrary.Conv_FloatToText(fNum, ERoundingMode.HalfToEven, true, 1, 324, decimalPrecision, decimalPrecision)
end
function FuncUtil.GetHDmpveInstanceId()
  local HDmpveInstanceIdSwitch = HDmpveRemote_HDmpveRemoteConfigGetBool("HDmpveInstanceIdSwitch", false)
  log(bWriteLog and "FuncUtil.GetHDmpveInstanceId, HDmpveInstanceIdSwitch: " .. tostring(HDmpveInstanceIdSwitch))
  if HDmpveInstanceIdSwitch and Client.GetHDmpveInstanceId then
    local HDmpveInstanceId = Client.GetHDmpveInstanceId()
    log(bWriteLog and "FuncUtil.GetHDmpveInstanceId, HDmpveInstanceId: " .. HDmpveInstanceId)
    return HDmpveInstanceId
  end
  return "NoId"
end
function FuncUtil.GetHDmpveRemoteConfig(key, defaultVal)
  if defaultVal == nil then
    defaultVal = false
  end
  log(bWriteLog and string.format("FuncUtil.GetHDmpveRemoteConfig. key=%s, defaultVal=%s", tostring(key), tostring(defaultVal)))
  if key == nil then
    return defaultVal
  end
  return HDmpveRemote_HDmpveRemoteConfigGetBool(key, defaultVal)
end
function FuncUtil.CompareVersion(version1, version2)
  if not version1 or version1 == "" then
    return false
  end
  if not version2 or version2 == "" then
    return true
  end
  local SplitVersion = function(version)
    local parts = {}
    for part in version:gmatch("(%d+)") do
      table.insert(parts, tonumber(part))
    end
    return parts
  end
  local versionParts1 = SplitVersion(version1)
  local versionParts2 = SplitVersion(version2)
  for i = 1, math.max(#versionParts1, #versionParts2) do
    local versionPart1 = versionParts1[i] or 0
    local versionPart2 = versionParts2[i] or 0
    if versionPart1 ~= versionPart2 then
      return versionPart1 >= versionPart2
    end
  end
  return false
end
function FuncUtil.IsNewVersion(version1)
  if not version1 or version1 == "" then
    return false
  end
  local SplitVersion = function(version)
    local parts = {}
    for part in version:gmatch("(%d+)") do
      table.insert(parts, tonumber(part))
    end
    return parts
  end
  local version2 = Client.GetApplicationVersion()
  local versionParts1 = SplitVersion(version1)
  local versionParts2 = SplitVersion(version2)
  for i = 1, math.max(#versionParts1, #versionParts2) do
    local versionPart1 = versionParts1[i] or 0
    local versionPart2 = versionParts2[i] or 0
    if versionPart1 ~= versionPart2 then
      return versionPart1 > versionPart2
    end
  end
  return false
end
function FuncUtil.IsInVersionRange(lowerVersion, upperVersion)
  if not FuncUtil.CompareVersion(upperVersion, lowerVersion) then
    return false
  end
  local curVersion = Client.GetApplicationVersion()
  local flag1 = FuncUtil.CompareVersion(curVersion, lowerVersion)
  local flag2 = FuncUtil.CompareVersion(upperVersion, curVersion)
  return flag1 and flag2
end
function FuncUtil.OpenFlushAsyncLoading(bOpen, TickFrame)
  local EnableFlushAsyncLoading = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableFlushAsyncLoading", false)
  local FlushAsyncLoadingLogLevel = HDmpveRemote.HDmpveRemoteConfigGetInt("FlushAsyncLoadingLogLevel", 0)
  TickFrame = TickFrame or 0
  log(bWriteLog and "FuncUtil.OpenFlushAsyncLoading EnableFlushAsyncLoading:" .. tostring(EnableFlushAsyncLoading) .. " FlushAsyncLoadingLogLevel:" .. tostring(FlushAsyncLoadingLogLevel) .. " TickFrame:" .. tostring(TickFrame) .. " bOpen:" .. tostring(bOpen))
  if not EnableFlushAsyncLoading then
    return
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local gameInstance = STExtraGameInstance.GetInstance()
  if bOpen then
    gameInstance:ExecuteCMD("s.AsyncLoadingPriority", 1)
    gameInstance:ExecuteCMD("s.AsyncLoadingPriorityLog", FlushAsyncLoadingLogLevel)
    gameInstance:ExecuteCMD("s.AsyncLoadingPriorityMaxTick", TickFrame)
  else
    gameInstance:ExecuteCMD("s.AsyncLoadingPriority", 0)
    gameInstance:ExecuteCMD("s.AsyncLoadingPriorityLog", 0)
    gameInstance:ExecuteCMD("s.AsyncLoadingPriorityMaxTick", 0)
  end
end
function FuncUtil.CheckBackpackBlueprintDelegateDelayEnable()
  local bBackpackBlueprintDelegateDelayEnable = HDmpveRemote.HDmpveRemoteConfigGetBool("BackpackBlueprintDelegateDelayEnable", false)
  local BackpackBlueprintDelegateClearMinFrameCnt = HDmpveRemote.HDmpveRemoteConfigGetInt("BackpackBlueprintDelegateClearMinFrameCnt", 20)
  local BackpackBlueprintDelegateSafeFPS = HDmpveRemote.HDmpveRemoteConfigGetInt("BackpackBlueprintDelegateSafeFPS", 30)
  local BackpackBlueprintDelegateScaleRatio = HDmpveRemote.HDmpveRemoteConfigGetInt("BackpackBlueprintDelegateScaleRatio", 20)
  log(bWriteLog and "FuncUtil.CheckBackpackBlueprintDelegateDelayEnable BackpackBlueprintDelegateDelayEnable:" .. tostring(bBackpackBlueprintDelegateDelayEnable) .. " BackpackBlueprintDelegateClearMinFrameCnt:" .. tostring(BackpackBlueprintDelegateClearMinFrameCnt) .. " BackpackBlueprintDelegateSafeFPS:" .. tostring(BackpackBlueprintDelegateSafeFPS) .. " BackpackBlueprintDelegateScaleRatio:" .. tostring(BackpackBlueprintDelegateScaleRatio))
  local STExtraGameInstance = import("STExtraGameInstance")
  local gameInstance = STExtraGameInstance.GetInstance()
  if bBackpackBlueprintDelegateDelayEnable then
    gameInstance:ExecuteCMD("s.EnableBackpackBlueprintDelegateDelay", 1)
    gameInstance:ExecuteCMD("s.BackpackBlueprintDelegateClearMinFrameCnt", BackpackBlueprintDelegateClearMinFrameCnt)
    gameInstance:ExecuteCMD("s.BackpackBlueprintDelegateSafeFPS", BackpackBlueprintDelegateSafeFPS)
    gameInstance:ExecuteCMD("s.BackpackBlueprintDelegateScaleRatio", BackpackBlueprintDelegateScaleRatio)
  else
    gameInstance:ExecuteCMD("s.EnableBackpackBlueprintDelegateDelay", 0)
  end
end
function FuncUtil.GetRegisterDay(checkReturn)
  local dayFromRegister = 0
  local tNow = FuncUtil.GetServerTimeInSec()
  if DataMgr.registertime ~= nil and 0 < DataMgr.registertime then
    dayFromRegister = (tNow - DataMgr.registertime) / 86400
  end
  if checkReturn and DataMgr.roleData and DataMgr.roleData.back_user_data and DataMgr.roleData.back_user_data.rejoin_start_time then
    dayFromRegister = (tNow - DataMgr.roleData.back_user_data.rejoin_start_time) / 86400
  end
  return dayFromRegister
end
function FuncUtil.GetRegisterYear(registerTime)
  registerTime = registerTime or DataMgr.registertime or 0
  local TimeUtil = require("client.common.time_util")
  local currTime = TimeUtil.GetServerTimeInSec()
  local day = math.floor((currTime - registerTime) / 86400 + 1)
  return math.floor(day / 365 + 0.5)
end
local PetUtil = require("GameLua.Mod.BaseMod.Actor.Pet.PetUtil")
function FuncUtil.GetPetPosZ(key)
  log(bWriteLog and "FuncUtil.GetPetPosZ. key: " .. tostring(key))
  local player = Game:GetPlayerByPlayerKey(tonumber(key))
  if not player then
    return 0
  end
  local ownerController = player:GetController()
  local z = 0
  if PetUtil.IsSpecialBird(ownerController) then
    z = PetUtil.FlyStartPosZ
  end
  log(bWriteLog and "FuncUtil.GetPetPosZ. z: " .. tostring(z))
  return z
end
function FuncUtil.ConcatDescriptionInDev(desc, taskID, targetRegion)
  if FuncUtil.concatDescriptionSwitch == 0 then
    return desc
  end
  if GlobalData.IsIOSCheck() then
    return desc
  end
  local region = Client.GetPublishRegion()
  if targetRegion and region ~= targetRegion then
    return desc
  end
  local format = "%s TaskID = %d"
  return string.format(format, desc, taskID)
end
function FuncUtil.SetConcatDescriptionSwitch(isOpen)
  log(bWriteLog and "FuncUtil.SetConcatDescriptionSwitch. isOpen: " .. tostring(isOpen))
  FuncUtil.concatDescriptionSwitch = isOpen and 1 or 0
end
return FuncUtil