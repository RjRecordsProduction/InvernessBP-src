local logic_share_replay = {
  savedReplayJsonMap = nil,
  savedDeathReplayJsonMap = nil,
  recordData = nil,
  cdnUrlConfig = nil,
  openShareDetailInfo = nil,
  maxLoadingFileTime = 10
}
local chat_msg_params = {
  "domainID",
  "replayUrl",
  "jsonUrl",
  "uid",
  "rankIntegralLevel",
  "modeID",
  "totalTime",
  "typeInfo",
  "appVersion",
  "srcVersion",
  "decrypt",
  "saveTimeStamp"
}
local bSavedBattleJson = false
local bInitCdnUrlConfig = false
function logic_share_replay.InitBattleSavedMapData()
  log(bWriteLog and "logic_share_replay.InitBattleSavedMapData")
  if bSavedBattleJson then
    log(bWriteLog and "logic_share_replay.InitBattleSavedMapData bSavedBattleJson")
    return
  end
  local logic_replay = require("client.slua.logic.replay.logic_replay")
  local replayDataMap = logic_replay.GetReplayDataMap()
  local uid = tonumber(DataMgr.roleData.uid)
  for filename, data in pairs(replayDataMap) do
    if not logic_share_replay.savedReplayJsonMap then
      logic_share_replay.savedReplayJsonMap = {}
    end
    if not logic_replay.IsOnlineUrl(filename) and data.GameID ~= nil and data.UID ~= nil and uid == data.UID then
      logic_share_replay.savedReplayJsonMap[tostring(data.GameID)] = filename
    else
      log(bWriteLog and "[v_Wllwu] logic_share_replay InitBattleSavedMapData file is no battle_id, name is : " .. tostring(filename))
    end
  end
  logic_replay.InitDeathFileFromLocalFile()
  local deathReplayDataMap = logic_replay.GetDeathReplayDataMap()
  for fileName, data in pairs(deathReplayDataMap) do
    if not logic_share_replay.savedDeathReplayJsonMap then
      logic_share_replay.savedDeathReplayJsonMap = {}
    end
    if data.GameID ~= nil and data.UID ~= nil and uid == data.UID then
      logic_share_replay.savedDeathReplayJsonMap[tostring(data.GameID)] = fileName
    else
      log(bWriteLog and "[v_Wllwu] logic_share_replay InitBattleSavedMapData file is no battle_id, name is : " .. tostring(fileName))
    end
  end
  bSavedBattleJson = true
  log_tree(bWriteLog and "logic_share_replay.InitBattleSavedMapData savedBattleJsonMap:", logic_share_replay.savedReplayJsonMap)
end
function logic_share_replay.CheckHasBattleReplay(battle_id)
  battle_id = tostring(battle_id)
  logic_share_replay.InitBattleSavedMapData()
  if logic_share_replay.savedReplayJsonMap and logic_share_replay.savedReplayJsonMap[battle_id] then
    return true
  end
  return false
end
function logic_share_replay.CheckHasDeathReplay(battle_id)
  log(bWriteLog and string.format("logic_share_replay.CheckHasDeathReplay. battle_id=%s", tostring(battle_id)))
  battle_id = tostring(battle_id)
  if logic_share_replay.savedDeathReplayJsonMap and logic_share_replay.savedDeathReplayJsonMap[battle_id] then
    return true
  end
  return false
end
function logic_share_replay.PlayDeathReplay(battle_id, handler, index)
  log(bWriteLog and string.format("logic_share_replay.PlayDeathReplay. battle_id=%s, index=%s", tostring(battle_id), tostring(index)))
  local fileName, data = logic_share_replay.GetDeathReplayData(battle_id)
  if not data then
    log(bWriteLog and "RoleInfoHistoryDetailUI:OnClickButton_5.data is nil")
    return
  end
  log(bWriteLog and "logic_share_replay.PlayDeathReplay. fileName = " .. tostring(fileName))
  local logic_replay = require("client.slua.logic.replay.logic_replay")
  logic_replay.RealPlayDeathReplayFile(fileName, nil, handler, data.ModeID, index)
end
function logic_share_replay.GetDeathReplayData(battle_id)
  battle_id = tostring(battle_id)
  local fileName
  if logic_share_replay.savedDeathReplayJsonMap and logic_share_replay.savedDeathReplayJsonMap[battle_id] then
    fileName = logic_share_replay.savedDeathReplayJsonMap[battle_id]
  end
  local logic_replay = require("client.slua.logic.replay.logic_replay")
  local deathReplayDataMap = logic_replay.GetDeathReplayDataMap()
  if deathReplayDataMap and fileName then
    local data = deathReplayDataMap[fileName]
    fileName = Client.ProjectSavedDir() .. "/" .. string.sub(fileName, 0, string.len(fileName) - 4)
    return fileName, data
  end
  return nil, nil
end
function logic_share_replay.GetJsonFileByBattleId(battle_id)
  battle_id = tostring(battle_id)
  logic_share_replay.InitBattleSavedMapData()
  if logic_share_replay.savedReplayJsonMap and logic_share_replay.savedReplayJsonMap[battle_id] then
    return logic_share_replay.savedReplayJsonMap[battle_id]
  end
  return nil
end
function logic_share_replay.GetChatShareReplay(file_name, replay_info_url, replay_url, is_forward)
  local share_data = {}
  local logic_replay = require("client.slua.logic.replay.logic_replay")
  local data = logic_replay.GetJsonTableByFilename(file_name)
  if data then
    share_data.domainID = 1
    share_data.jsonUrl = logic_share_replay.GetShortShareUrl(replay_info_url, share_data.domainID)
    share_data.replayUrl = logic_share_replay.GetShortShareUrl(replay_url, share_data.domainID)
    share_data.uid = data.UID
    share_data.rankIntegralLevel = data.SegmentLevel
    share_data.modeID = data.ModeID
    share_data.totalTime = data.TotalTime
    share_data.typeInfo = data.TypeInfoArray
    share_data.appVersion = data.AppVersion
    share_data.srcVersion = data.SrcVersion
    share_data.decrypt = logic_replay.GetDecryptStrByUrl(file_name, replay_url)
    share_data.saveTimeStamp = data.saveTimestamp
    share_data.isForward = is_forward or false
  end
  return share_data
end
function logic_share_replay.GetChatMsgParamsList()
  return chat_msg_params
end
function logic_share_replay.InitCdnUploadUrlConfig()
  if bInitCdnUrlConfig then
    return
  end
  local cfg = CDataTable.GetTable("FriendMomentDomain")
  if not cfg then
    return
  end
  bInitCdnUrlConfig = true
  logic_share_replay.cdnUrlConfig = {}
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local is_india = Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE
  for _, v in pairs(cfg) do
    if is_india then
      logic_share_replay.cdnUrlConfig[v.ID] = v.IndiaDomain
    else
      logic_share_replay.cdnUrlConfig[v.ID] = v.Domain
    end
  end
  log_tree(bWriteLog and "logic_share_replay.InitCdnUploadUrlConfig = ", logic_share_replay.cdnUrlConfig)
end
function logic_share_replay.GetDomainIdByUrl(url)
  if not url or url == "" then
    return
  end
  logic_share_replay.InitCdnUploadUrlConfig()
  local StringUtil = require("common.string_util")
  for id, domain_url in pairs(logic_share_replay.cdnUrlConfig) do
    if domain_url ~= "" and StringUtil.Starts(url, domain_url) then
      log(bWriteLog and "[v_wllwu] GetDomainIdByUrl : " .. tostring(url) .. " domain_id = " .. tostring(id))
      return id
    end
  end
  return nil
end
function logic_share_replay.GetShortShareUrl(url, domain_id)
  local replay_macro = require("client.slua.logic.replay.replay_macro")
  url = string.gsub(url, "%" .. replay_macro.FileType.REPLAY, "")
  url = string.gsub(url, "%" .. replay_macro.FileType.INFO, "")
  logic_share_replay.InitCdnUploadUrlConfig()
  if not (domain_id ~= nil and logic_share_replay.cdnUrlConfig) or not logic_share_replay.cdnUrlConfig[domain_id] then
    return url
  end
  local domain_url = logic_share_replay.cdnUrlConfig[domain_id]
  local StringUtil = require("common.string_util")
  if domain_url ~= "" and StringUtil.Starts(url, domain_url) then
    return string.sub(url, string.len(domain_url) + 1)
  end
  return url
end
function logic_share_replay.GetFullShareUrl(url, file_type, domain_id)
  logic_share_replay.InitCdnUploadUrlConfig()
  if not string.find(url, file_type, nil, true) then
    url = url .. file_type
  end
  log(bWriteLog and "domain_id ==  " .. tostring(domain_id))
  if not domain_id or not logic_share_replay.cdnUrlConfig then
    return url
  end
  local domain_url = logic_share_replay.cdnUrlConfig[tonumber(domain_id)] or ""
  log(bWriteLog and "logic_share_replay.GetFullShareUrl : " .. domain_url .. url .. "  domain_id = " .. tostring(domain_id))
  return domain_url .. url
end
function logic_share_replay.ConstructInviteLink(owner_uid, replay_info_url, replay_url, decrypt, source)
  local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
  local adjToken = AdjustSystem:GetRegionToken(AdjustSystem.E_TokenType.CallbackPlayer)
  local title = LocUtil.GetLocalizeResStr(24672)
  local desc = ""
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    desc = LocUtil.GetLocalizeResStr(24679)
  else
    desc = LocUtil.GetLocalizeResStr(24675)
  end
  if tostring(owner_uid) ~= DataMgr.roleData.uid then
    desc = LocUtil.GetLocalizeResStr(24690)
  end
  title = Client.UrlEncode(Client.HtmlEncode(title))
  desc = Client.UrlEncode(Client.HtmlEncode(desc))
  local content = "title=%s&descript=%s&"
  content = string.format(content, title, desc)
  local domain_id = logic_share_replay.GetDomainIdByUrl(replay_info_url)
  local short_info_url = logic_share_replay.GetShortShareUrl(replay_info_url, domain_id)
  local short_replay_url = logic_share_replay.GetShortShareUrl(replay_url, domain_id)
  local acceptor = string.format("module=%s&uid=%s&src=%s&owner=%s&info=%s&url=%s&decrypt=%s", BP_ENUM_MODULE_SHARE_WONDERFUL_REPLAY, DataMgr.roleData.uid, source, owner_uid, short_info_url, short_replay_url, decrypt)
  if domain_id ~= nil then
    acceptor = acceptor .. "&domain=" .. domain_id
  end
  local adjust_deeplink = AdjustSystem.GetRegionDeeplinkUrlScheme() .. acceptor
  adjust_deeplink = Client.UrlEncode(adjust_deeplink)
  local cr = AdjustSystem.GetShareLinkCr()
  local tail = "&adjust_campaign=jcsk"
  local logic_deeplink = require("client.slua.logic.deeplink.logic_deeplink")
  local gameId = logic_deeplink:GetDeeplinkUrlSchemeAppId()
  local domain = ShareMgr.GetShareDomain()
  local link = "https://" .. domain .. "/recallfriend.php?cdn=2&gameid=" .. gameId .. "&" .. content .. acceptor .. "&cr=" .. cr .. "&adjust_t=" .. adjToken .. "&adjust_deeplink=" .. adjust_deeplink .. tail
  log(bWriteLog and "logic_replay.ConstructInviteLink, link = " .. link)
  return link
end
function logic_share_replay.ShowReplayShareUI(_, _, vars)
  if not LobbySystem.CheckOpen(BP_ENUM_WONDERFUL_REPLAY_SWITCH) then
    ShowNotice(100220020)
    return
  end
  local owner_uid = vars.owner
  local replay_info_url = vars.info
  local replay_url = vars.url
  local decrypt = vars.decrypt
  local domain_id = vars.domain
  log(bWriteLog and "[v_wllwu] ShowReplayShareUI domain_id = " .. tostring(domain_id) .. " owner_uid = " .. tostring(owner_uid) .. " replay_info_url = " .. tostring(replay_info_url) .. " replay_url = " .. tostring(replay_url) .. " decrypt = " .. tostring(decrypt))
  if replay_info_url ~= nil and replay_url ~= nil and decrypt ~= nil then
    local replay_macro = require("client.slua.logic.replay.replay_macro")
    local full_info_url = logic_share_replay.GetFullShareUrl(replay_info_url, replay_macro.FileType.INFO, domain_id)
    local full_replay_url = logic_share_replay.GetFullShareUrl(replay_url, replay_macro.FileType.REPLAY, domain_id)
    local logic_replay = require("client.slua.logic.replay.logic_replay")
    logic_replay.AddEntryToCache(full_info_url, full_replay_url, decrypt, owner_uid)
    logic_share_replay.ShowPlayReplayPopUI(replay_macro.TLOG.Sub_Scene.LINK, full_info_url, full_replay_url)
    local tlog = replay_macro.TLOG
    local owner = tlog.OWNER.SELF
    if tostring(owner_uid) ~= DataMgr.roleData.uid then
      owner = tlog.OWNER.OTHER
    end
    logic_replay.reportTlog({
      replay_macro.TLOG.Sub_Scene.LINK,
      tlog.Action.CLICKSHOW,
      owner
    })
  end
  local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
  AdjustSystem:ClearAdjustDeepLink()
end
local addition_str_table = {
  "owner",
  "info",
  "url",
  "decrypt",
  "domain"
}
function logic_share_replay.GetAdditionalStrByUrl(url)
  local strPlatform = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if strPlatform ~= DevicePlatformNameMacros.IOS then
    return url
  end
  if not url or type(url) ~= "string" or url == "" then
    return
  end
  log(bWriteLog and "[v_wllwu] logic_share_replay.GetStrByLinkUrl, url = " .. tostring(url))
  local str = ""
  local add_str = ""
  local StringUtil = require("common.string_util")
  local params = StringUtil.ParseURLParams(url)
  for _, v in pairs(addition_str_table) do
    if params[v] then
      add_str = string.format("&%s=%s", v, params[v])
      str = str .. add_str
    end
  end
  log(bWriteLog and "[v_wllwu] logic_share_replay.GetStrByLinkUrl, output str = " .. tostring(str))
  return str
end
function logic_share_replay.RecordDataFromChat()
  logic_share_replay.ClearRecordData()
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local replay_macro = require("client.slua.logic.replay.replay_macro")
  local data = {}
  data.source = replay_macro.TLOG.Sub_Scene.CHAT
  data.channel = logic_chat_main.currentChannel
  data.topic_id = logic_chat_channel_world.current_topicId
  data.uid = logic_chat_channel_friend.CurrentGid
  logic_share_replay.recordData = data
end
function logic_share_replay.RecordDataFromHistoryRecord(battle_id)
  logic_share_replay.ClearRecordData()
  local replay_macro = require("client.slua.logic.replay.replay_macro")
  local data = {}
  data.source = replay_macro.TLOG.Sub_Scene.HISTORY
  data.  logic_share_replay.recordData = data
end
function logic_share_replay.RecordDataFromDeepLink(replay_info_url, replay_url)
  logic_share_replay.ClearRecordData()
  local replay_macro = require("client.slua.logic.replay.replay_macro")
  local data = {}
  data.source = replay_macro.TLOG.Sub_Scene.LINK
  data.  data.  logic_share_replay.recordData = data
end
function logic_share_replay.RecordDataFromXMissionHistoryRecord(battle_id)
  logic_share_replay.ClearRecordData()
  local replay_macro = require("client.slua.logic.replay.replay_macro")
  local data = {}
  data.source = replay_macro.TLOG.Sub_Scene.XMISSION_HISTORY
  data.  logic_share_replay.recordData = data
end
function logic_share_replay.RecoverUIData()
  if not logic_share_replay.recordData then
    return
  end
  log(bWriteLog and "[v_Wllwu] logic_share_replay.RecoverUIData ")
  local source = logic_share_replay.recordData.source
  local replay_macro = require("client.slua.logic.replay.replay_macro")
  if source == replay_macro.TLOG.Sub_Scene.CHAT then
    logic_share_replay.EnterChatMain()
  elseif source == replay_macro.TLOG.Sub_Scene.HISTORY then
    logic_share_replay.EnterHistoryUI()
  elseif source == replay_macro.TLOG.Sub_Scene.LINK then
    logic_share_replay.ShowPlayReplayPopUI(source, logic_share_replay.recordData.replay_info_url, logic_share_replay.recordData.replay_url)
  elseif source == replay_macro.TLOG.Sub_Scene.XMISSION_HISTORY then
    return
  end
  logic_share_replay.ClearRecordData()
end
function logic_share_replay.EnterChatMain()
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local channel = logic_share_replay.recordData.channel
  if channel == chat_macro.Channel.channelPrivate then
    logic_chat_main.OpenChatMainByFriendId(logic_share_replay.recordData.uid)
  elseif channel == chat_macro.Channel.channelWorld and logic_share_replay.recordData.topic_id ~= "" then
    logic_chat_main.OpenChatMainByTopic(logic_share_replay.recordData.topic_id)
  else
    logic_chat_main.OpenChatMain(channel)
  end
end
function logic_share_replay.EnterHistoryUI()
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  RoleInfoMainSystem.Show(RoleInfoMainSystem.HistoryCombat, RoleInfoMainSystem.RoleInfoOpenFromType.Lobby, DataMgr.roleData.uid)
end
function logic_share_replay.RecoverXmissionUI()
  log(bWriteLog and "logic_share_replay.RecoverXmissionUI")
  if not logic_share_replay.recordData then
    log(bWriteLog and "logic_share_replay.RecoverXmissionUI no recordData")
    return
  end
  local source = logic_share_replay.recordData.source
  local replay_macro = require("client.slua.logic.replay.replay_macro")
  if source == replay_macro.TLOG.Sub_Scene.XMISSION_HISTORY then
    log(bWriteLog and "logic_share_replay.RecoverXmissionUI XMISSION_HISTORY")
    logic_share_replay.EnterXmissionHistoryUI()
  end
  logic_share_replay.ClearRecordData()
end
function logic_share_replay.EnterXmissionHistoryUI()
  UIManager.ShowUI(UIManager.UI_Config.Xmission_RoleInfo_History_UIBP)
end
function logic_share_replay.ClearRecordData()
  if logic_share_replay.recordData then
    logic_share_replay.recordData = nil
  end
end
function logic_share_replay.ShowPlayReplayPopUI(from, replay_info_url, replay_url, show_info, battle_id)
  logic_share_replay.SetOpenReplayInfo(from, replay_info_url, replay_url)
  UIManager.ShowUI(UIManager.UI_Config.share_replay_pop, show_info, battle_id)
end
function logic_share_replay.OpenSendChatUI(from, replay_info_url, replay_url)
  logic_share_replay.SetOpenReplayInfo(from, replay_info_url, replay_url)
  UIManager.ShowUI(UIManager.UI_Config.forward_wonderful_replay_pop)
end
function logic_share_replay.OpenShareLinkUI(from, replay_info_url, replay_url)
  logic_share_replay.SetOpenReplayInfo(from, replay_info_url, replay_url)
  UIManager.ShowUI(UIManager.UI_Config.choose_share_channel)
end
function logic_share_replay.CheckFilePath(replay_info_url, replay_url, dont_show_tips)
  local logic_replay = require("client.slua.logic.replay.logic_replay")
  if not logic_replay.CheckFileIsInfo(replay_info_url) then
    log(bWriteLog and "[v_wllwu] replayinfo_url is not info file")
    if not dont_show_tips then
      ShowNotice(25719)
    end
    return false
  end
  if not logic_replay.CheckFileIsReplay(replay_url) then
    log(bWriteLog and "[v_wllwu] replay_url is not replay file")
    if not dont_show_tips then
      ShowNotice(25719)
    end
    return false
  end
  return true
end
function logic_share_replay.OnModePostSwitch(preState, nextState)
  if GameStatus.IsInLobbyOrMainCity() then
    return
  end
  local logic_replay = require("client.slua.logic.replay.logic_replay")
  if logic_replay.IsPlayingReplay() then
    return
  end
  logic_share_replay.ResetData()
end
function logic_share_replay.CheckCanPlay()
  local logic_replay = require("client.slua.logic.replay.logic_replay")
  if logic_replay.IsPlayingReplay() then
    ShowNotice(25719)
    return false
  end
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if MatchModeMgrSystem.IsSocialIslandMode() then
    ShowNotice(24685)
    return false
  end
  if GameStatus.IsInFightingNotMainCity() then
    return false
  end
  return true
end
function logic_share_replay.GetChatChannelTlogStr()
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local replay_macro = require("client.slua.logic.replay.replay_macro")
  local tlog = replay_macro.TLOG
  local channel = logic_chat_main.currentChannel
  if channel == chat_macro.Channel.channelPrivate then
    return tlog.Chat_Channel.PRIVATECHANNEL
  elseif channel == chat_macro.Channel.channelWorld then
    return tlog.Chat_Channel.WORLDCHANNEL
  elseif channel == chat_macro.Channel.channelCorps then
    return tlog.Chat_Channel.CROPCHANNEL
  elseif channel == chat_macro.Channel.channelChatRoom then
    return tlog.Chat_Channel.channelChatRoom
  end
end
function logic_share_replay.SetOpenReplayInfo(from, replay_info_url, replay_url)
  if from == nil and replay_info_url == nil and replay_url == nil then
    return
  end
  if not logic_share_replay.openShareDetailInfo then
    logic_share_replay.openShareDetailInfo = {}
  end
  if from ~= nil then
    logic_share_replay.openShareDetailInfo.str_from_ui = from
  end
  if replay_info_url ~= nil then
    logic_share_replay.openShareDetailInfo.  end
  if replay_url ~= nil then
    logic_share_replay.openShareDetailInfo.  end
end
function logic_share_replay.GetOpenReplayInfo()
  return logic_share_replay.openShareDetailInfo or {}
end
function logic_share_replay.ResetData()
  bSavedBattleJson = false
  bInitCdnUrlConfig = false
  logic_share_replay.cdnUrlConfig = nil
  logic_share_replay.savedReplayJsonMap = nil
  logic_share_replay.savedDeathReplayJsonMap = nil
  logic_share_replay.openShareDetailInfo = nil
  logic_share_replay.ClearRecordData()
end
return logic_share_replay