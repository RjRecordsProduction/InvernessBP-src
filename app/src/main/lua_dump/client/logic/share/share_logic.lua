ShareType = {Friend = 0, Moment = 1}
ShareParam = {
  bShareBigPhoto = false,
  iShareType = 0,
  strMediaTag = "",
  strTitle = "",
  strDesc = "",
  strImgPath = "",
  strMessageExt = "",
  strMessageAction = ""
}
GameCenterADTAG = {
  invite = "gameobj.msg_invite",
  exceed = "gameobj.msg_exceed",
  heart = "gameobj.msg_heart",
  pvp = "gameobj.msg_pvp",
  show = "gameobj.msg_show"
}
ShareSource = {
  SMS = "sms",
  Messenger = "messenger",
  Whatsapp = "whatsapp",
  System = "system",
  Line = "line",
  Facebook = "facebook",
  Twitter = "twitter",
  VK = "vk",
  Hms = "hms",
  GooglePlay = "googleplay",
  Google = "google",
  GameCenter = "gamecenter",
  unifiedaccount = "unifiedaccount",
  Guest = "guest",
  BgBg = FuncUtil.GetKeywordByID(3377006),
  Discord = "discord",
  Noschat = FuncUtil.GetKeywordByID(3377005),
  More = "more",
  Apple = "apple",
  Scan = "scan",
  Web = "web",
  QR = "qr",
  Club = "Club",
  GameChat = "gameChat",
  TikTok = "tiktok"
}
local IMSDKSystem = require("client.logic.login.logic_imsdk")
ShareMgr = {
  bEnableShare = true,
  ShareInfo = {},
  shareDiffTime = 0,
  CurShareType = 0,
  CurShareItemResid = 0,
  CurPoseId = 0,
  ShareImageURL = "",
  ShareH5Title = "",
  LastHDmpveUploadTime = 0,
  LastHDmpveTimerHandle = nil,
  LastUrl = "",
  GetShortUrlHandle = nil,
  GetShortUrlTimer = nil,
  GetUrlOKFunc = nil,
  resultUrl = "",
  ShareFileType = {
    Share = 1,
    MomentPic = 2,
    Replay = 3,
    Voice = 4,
    Intimacy = 5,
    DIYPlan = 6,
    UGC = 7,
    HomeLocal = 8,
    HomeCapture = 9,
    VersionAlbum = 10,
    Heirloom = 11
  },
  SponsorAward = {reward_cnt = 0, refresh_time = 0},
  status = {medal = false, segment = false},
  DefaultImagePath = "/Game/UMG/Texture_200/Lobby_NoAtlas/Common/Common_Image_Loading_BG.Common_Image_Loading_BG"
}
ShortMarkDev = "C"
ShortMarkShipping = "D"
function ShareMgr.isShareEnable()
  if Client.IsMatchNoAuthMode and Client.IsMatchNoAuthMode() then
    ShowNotice("Not supported")
    return false
  end
  return ShareMgr.bEnableShare
end
function ShareMgr.GetShortUrlMask()
  local BusinessHelper = import("BusinessHelper")
  if BusinessHelper.GetIMSDKEnv() == 1 then
    return ShortMarkShipping
  else
    return ShortMarkDev
  end
end
function ShareMgr.InviteJoinTeamBgBg(teamid)
  local ShareDataList = require("client.logic.share.share_data")
  if not ShareMgr.isShareEnable() then
    log(bWriteLog and "the share system is not open!")
    return
  end
  local shareData = ShareDataList[ShareDataList.MEDIA_TAG_SHARE_INVITE_JOINTEAM]
  if nil == shareData then
    log(bWriteLog and string.format("share: not exist share type(%s)", ShareDataList.MEDIA_TAG_SHARE_INVITE_JOINTEAM))
    return
  end
  local gamedata = {
    team_roleid = DataMgr.roleData.uid,
    team_  }
  local str = json.encode(gamedata)
  local StringUtil = require("common.string_util")
  local encodedstr = StringUtil.EncodeURI(str)
  local strUrl = ShareMgr.constructBgBgGameCenterURL(encodedstr, GameCenterADTAG.invite)
  log(bWriteLog and strUrl)
  log(bWriteLog and "InviteJoinTeamBgBg!")
  log(bWriteLog and shareData.strDesc)
  log(bWriteLog and shareData.strImgLocalPath)
  Client.BqBqShare(NetInterface, LocUtil.GetLocalizeResStr(110105), LocUtil.GetLocalizeResStr(110104), shareData.strImgLocalPath, shareData.strImgUrl, strUrl, shareData.iShareType)
end
function ShareMgr.InviteJoinTeamWX(teamid, _)
  local ShareDataList = require("client.logic.share.share_data")
  if not ShareMgr.isShareEnable() then
    log(bWriteLog and "the share system is not open!")
    return
  end
  local shareData = ShareDataList[ShareDataList.MEDIA_TAG_SHARE_INVITE_JOINTEAM]
  if nil == shareData then
    log(bWriteLog and string.format("share: not exist share type(%s)", ShareDataList.MEDIA_TAG_SHARE_INVITE_JOINTEAM))
    return
  end
  local gamedata = {
    team_roleid = DataMgr.roleData.uid,
    team_  }
  local str = json.encode(gamedata)
  local StringUtil = require("common.string_util")
  local encodedstr = StringUtil.EncodeURI(str)
  log(bWriteLog and "InviteJoinTeamWX!")
  log(bWriteLog and shareData.strDesc)
  log(bWriteLog and shareData.strImgLocalPath)
  Client.NoschatShare(NetInterface, LocUtil.GetLocalizeResStr(110105), LocUtil.GetLocalizeResStr(110104), shareData.strImgLocalPath, ShareDataList.MEDIA_TAG_SHARE_INVITE_JOINTEAM, encodedstr)
end
function ShareMgr.GetOldShareUrl()
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local cr = ShareMgr.GetCr(region)
  local domain = ShareMgr.GetShareDomain(true)
  local logic_deeplink = require("client.slua.logic.deeplink.logic_deeplink")
  local gameId = logic_deeplink:GetDeeplinkUrlSchemeAppId()
  if region == PublishRegionMacros.VNG then
    domain = ShareMgr.GetShareDomain()
  end
  local sLink = "https://%s/showimage.php?cdn=2&gameid=%s"
  local link = string.format(sLink, domain, gameId)
  if FuncUtil.IsPlayerJPKR() then
    cr = "kr"
    if region == PublishRegionMacros.JAPAN then
      cr = "jp"
    end
    sLink = "https://%s/showimage.php?cdn=2&gameid=%s&cr=%s"
    link = string.format(sLink, domain, gameId, cr)
  end
  log(bWriteLog and "  : old link" .. tostring(link))
  return link
end
function ShareMgr.shareBgBgWithPhoto(strMediaTag, _, strImgPath, iShareType)
  local ShareDataList = require("client.logic.share.share_data")
  if not ShareMgr.isShareEnable() then
    log(bWriteLog and "the share system is not open!")
    return
  end
  local param = ShareParam
  param.bShareBigPhoto = true
  param.  param.  param.strTitle = LocUtil.GetLocalizeResStr("4053")
  param.strDesc = LocUtil.GetLocalizeResStr("4054")
  param.  local shareData = ShareDataList[param.strMediaTag]
  if nil == shareData then
    log(bWriteLog and string.format("share: not exist share type(%s)", strMediaTag))
    return
  end
  if nil == param.strDesc or "" == param.strDesc then
    param.strDesc = shareData.strDesc
  end
  log(bWriteLog and "share photo to bgbg!")
  local ShareHandle = function()
    local HDmpveSDKObj = ShareMgr.GetHDmpveSDKObj()
    if HDmpveSDKObj then
      IMSDKSystem.StartIMSDKTimer(4)
      log(bWriteLog and "  : param.strImgPath" .. tostring(param.strImgPath))
      local destFileKey = ShareMgr.GenerateFileKeyInS3(param.strImgPath, 1)
      local url = ShareMgr.GetOldShareUrl()
      log(bWriteLog and "  ShareHandle. destFileKey: " .. tostring(destFileKey))
      log(bWriteLog and "  ShareHandle. url: " .. tostring(url))
      HDmpveSDKObj:ShareWithUploadPhotoByChannel(param.strImgPath, BP_ENUM_PLAYFORM_BGBG, ShareMgr.GetOldShareUrl(), destFileKey)
    end
  end
  local EUGDPRSystem = require("client.logic.countryarea.logic_eugdpr")
  if EUGDPRSystem.GetIsGDPRUser() then
    ShareMgr.ShowGDPRHint(ShareHandle)
    return
  end
  ShareHandle()
end
function ShareMgr.shareToBgBgFriend(params)
  if not ShareMgr.isShareEnable() then
    log(bWriteLog and "the share system is not open!")
    return
  end
  if params == nil then
    return
  end
  local gameName = LocUtil.GetLocalizeResStr(200021)
  local inviteString = LocUtil.GetLocalizeResStr(301283)
  params.act = params.act or 1
  params.title = params.title or gameName
  params.desc = params.desc or inviteString
  local adtag = params.adtag or GameCenterADTAG.invite
  local gamedata = params.extendInfo or ""
  local targetUrl = ShareMgr.constructBgBgGameCenterURL(gamedata, adtag)
  params.targetUrl = params.targetUrl or targetUrl
  params.imgUrl = params.imgUrl or ""
  params.previewText = params.previewText or inviteString
  params.gameTag = params.gameTag or "MSG_INVITE"
  params.msdkExtInfo = params.msdkExtInfo or ""
  log(bWriteLog and "share to bgbg friend!")
  local EUGDPRSystem = require("client.logic.countryarea.logic_eugdpr")
  if EUGDPRSystem.GetIsGDPRUser() then
    local OKHandle = function()
      Client.BqBqShareToFriend(NetInterface, params.act, params.openid, params.title, params.desc, params.targetUrl, params.imgUrl, params.previewText, params.gameTag, params.msdkExtInfo)
    end
    ShareMgr.ShowGDPRHint(OKHandle)
    return
  end
  Client.BqBqShareToFriend(NetInterface, params.act, params.openid, params.title, params.desc, params.targetUrl, params.imgUrl, params.previewText, params.gameTag, params.msdkExtInfo)
end
function ShareMgr.constructBgBgGameCenterURL(_, _)
  return ""
end
function ShareMgr.shareWithPhotoByChannel(strMediaTag, imgPath, messageExt, messageAction, iChannel)
  ShareMgr.shareWithPhotoByChannelWithSceneID(strMediaTag, imgPath, messageExt, messageAction, iChannel, 1)
end
function ShareMgr.shareWithPhotoByChannelWithSceneID(strMediaTag, imgPath, messageExt, messageAction, iChannel, sceneID)
  local ShareDataList = require("client.logic.share.share_data")
  if not ShareMgr.isShareEnable() then
    log(bWriteLog and "the share system is not open!")
    return
  end
  local param = ShareParam
  param.bShareBigPhoto = false
  param.  param.  param.strTitle = LocUtil.GetLocalizeResStr(200021)
  param.strImgPath = imgPath
  param.strMessageExt = messageExt
  param.strMessageAction = messageAction
  log(bWriteLog and "ShareMgr.shareWithPhotoByChannel2:" .. tostring(iChannel))
  if iChannel == BP_ENUM_PLAYFORM_WX then
    param.strMessageExt = "{\"mediaTagName\":\"MSG_INVITE\",\"messageExt\":\"\",\"messageAction\":\"MESSAGE_ACTION_JUMP_H5_1#scene_id=" .. tostring(sceneID) .. "&tailword=<zh-CN><![CDATA[\230\184\184\230\136\143\232\175\166\230\131\133]]></zh-CN><en><![CDATA[Game Details]]></en><zh-TW><![CDATA[\233\129\138\230\136\178\232\169\179\230\131\133]]></zh-TW>\"}"
    log(bWriteLog and "ShareMgr.shareWithPhotoByChannel NosChat tail share: " .. param.strMessageExt)
  end
  local shareData = ShareDataList[param.strMediaTag]
  if nil == shareData then
    log(bWriteLog and string.format("share: not exist share type(%s)", strMediaTag))
    return
  end
  if nil == param.strDesc or "" == param.strDesc then
    param.strDesc = shareData.strDesc
  end
  local ShareHandle = function()
    IMSDKSystem.StartIMSDKTimer(4)
    if iChannel == BP_ENUM_PLAYFORM_LINE then
      local HDmpveSDKObj = ShareMgr.GetHDmpveSDKObj()
      if HDmpveSDKObj then
        local destFileKey = ShareMgr.GenerateFileKeyInS3(param.strImgPath, 1)
        HDmpveSDKObj:ShareWithUploadPhotoByChannel(param.strImgPath, iChannel, ShareMgr.GetOldShareUrl(), destFileKey)
      end
    else
      local logic_msdk_share_interface = require("client.logic.share.logic_msdk_share_interface")
      logic_msdk_share_interface:ShareWithPhotoByChannel(param.strImgPath, param.strMediaTag, param.strMessageExt, param.strMessageAction, param.iChannel, ShareMgr.GetOldShareUrl())
    end
  end
  local EUGDPRSystem = require("client.logic.countryarea.logic_eugdpr")
  if EUGDPRSystem.GetIsGDPRUser() then
    local OKHandle = function()
      log(bWriteLog and "shareWithPhotoByChannel iChannel=" .. tostring(iChannel))
      IMSDKSystem.StartIMSDKTimer(4)
      ShareHandle()
    end
    ShareMgr.ShowGDPRHint(OKHandle)
    return
  end
  log(bWriteLog and "shareWithPhotoByChannel iChannel=" .. tostring(iChannel))
  IMSDKSystem.StartIMSDKTimer(4)
  ShareHandle()
end
function ShareMgr.ShowGDPRHint(OKHandle)
  log(bWriteLog and "ShareMgr.ShowGDPRHint")
  local title = LocUtil.LocalizeResFormat(4975)
  local msg = LocUtil.LocalizeResFormat(7391)
  local btnOK = LocUtil.LocalizeResFormat(4975)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, msg, OKHandle, nil, btnOK)
end
function ShareMgr.onShareResult(bSuccess, strDesc)
  local param = ShareParam
  log(bWriteLog and string.format("onShareResult ret=(%s), desc=(%s), meditaTag=(%s)", tostring(bSuccess), strDesc, param.strMediaTag))
  local vars = {}
  table.insert(vars, bSuccess)
  table.insert(vars, param.strMediaTag)
  EventSystem:postEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, vars)
end
function ShareMgr.openShareSeasonResultUI(table)
  log(bWriteLog and "Enter openShareSeasonResultUI")
  ShareMgr.ShareImageURL = table.url
  ShareMgr.ShareH5Title = table.title
  log(bWriteLog and "Qpp ShareH5Title:" .. ShareMgr.ShareH5Title)
  log(bWriteLog and "Qpp ShareImageURL:" .. ShareMgr.ShareImageURL)
  local SeasonSystem = require("client.logic.season.logic_season")
  SeasonSystem.ShowShare()
end
function ShareMgr.GetTraitidNum(traitid, isUpdateGun)
  if ShareMgr.ShareInfo == nil then
    log(bWriteLog and "ShareMgr.GetTraitidNum_0")
    return 0
  end
  if ShareMgr.ShareInfo.statics == nil then
    log(bWriteLog and "ShareMgr.GetTraitidNum_000")
    return 0
  end
  local num = 0
  if isUpdateGun then
    num = ShareMgr.ShareInfo.statics[traitid + 200] or 0
    log(bWriteLog and "[ :isUpdateGun  num" .. tostring(num))
    return num
  end
  for k, _ in pairs(ShareMgr.ShareInfo.statics) do
    if k == traitid then
      num = ShareMgr.ShareInfo.statics[traitid]
      break
    end
  end
  log(bWriteLog and "ShareMgr.GetTraitidNum" .. tostring(num))
  return num
end
ShareSceneType = {
  WonderfulReply = 0,
  GetItem = 1,
  Daily = 2,
  PersonBattle = 3,
  ResultRank = 4,
  ResultData = 5,
  SendGift = 9,
  Pandora = 16,
  RecallInvite = 20,
  WebviewShare = 21,
  ActivitySNSShare = 22,
  RecruitInvite = 23,
  DIYCommon = 24,
  DIYGet = 25,
  SocialLobby = 26,
  BlackFridayMain = 27,
  UPassGroupBuy = 28,
  AvalonSpeed = 29,
  EsportWin = 30,
  CorpFight = 31,
  SmallPayment = 32,
  Futruetechnology = 33,
  WorldCupShare = 34,
  WorldCupMyTeamInteractRecord = 35,
  WorldCupMyTeamGaming = 36,
  WorldCupMyTeamEnd = 37,
  ActCenter13 = 13,
  ActCenter46 = 46,
  RoleInfoCard = 47,
  SeasonLookBack = 48,
  SeasonLookBackLongPic = 49,
  TxmissionHistory = 50,
  VehicleCollect = 51,
  GoldenSuitCollect = 52,
  TarotCardGoldenSuit = 53,
  ShowAliasListShare = 54,
  ShowJPDrawShare = 55,
  ManorShare = 56,
  SmallRPCollectShare = 57,
  BirthDayShare = 58,
  ChatRoomShare = 59,
  LudoInvite = 60,
  PartyMemories = 61,
  PartyInviteShare = 62,
  RPPassPreOrder = 63,
  PeakGame_Weekly_Result_Award_Popup_Share = 64,
  PeakGame_Hof_Result_Award_Popup_Share = 65,
  PeakGame_Ability_KD_Result_Award_Popup_Share = 66,
  PeakGame_Ability_Win_Solo_Share = 67,
  PeakGame_Ability_Win_Multi_Share = 68,
  PeakGame_Ability_Win_Squad_Share = 69,
  PeakGame_Ability_Win_Weekly_Solo_Share = 70,
  PeakGame_Ability_Win_Weekly_Multi_Share = 71,
  PeakGame_Ability_Win_Weekly_Squad_Share = 72,
  BornIslandTeamShow = 73,
  RoleInfo_Intimacy_Relationship_Share = 74,
  ZNQ7thLookBackGlory = 75,
  Lobby_Souvenirs_Special_Share = 76,
  XmissionHeritageArmed = 77,
  XmissionSouvenirsShowShare = 78,
  XmissionGoldSellItemShare = 79,
  Intimacy_BondingBook_Share = 80,
  SmartAssistantV2_DailyQuote_Result_Share = 81,
  BattleResultMedalDisplayShare = 82,
  GroupBuyShare = 83,
  FlashMatchTeamAddShare = 84,
  CardCollectionExchange = 85
}
function ShareMgr.ShareSuccReq(share_type, channel_type, itemId, actId)
  channel_type = channel_type or 0
  local TimeUtil = require("client.common.time_util")
  local timeDiff = TimeUtil.OSTime() - ShareMgr.shareDiffTime
  log(bWriteLog and "ShareMgr.ShareSuccReq, timeDiff = " .. tostring(timeDiff))
  if 2 <= timeDiff then
    log(bWriteLog and "ShareMgrShareSuccReq, timeDiff >= 2s, type = " .. share_type .. ", channel = " .. channel_type)
    log(bWriteLog and "  :ShareSuccReq itemId" .. tostring(itemId))
    ShareMgr.shareDiffTime = TimeUtil.OSTime()
    local ShareHandler = require("client.network.Protocol.ShareHandler")
    ShareHandler.send_share_succ_request(tonumber(share_type), tonumber(channel_type), tonumber(itemId), tonumber(actId))
  end
end
function ShareMgr.onGetShareInfoRsp(data)
  if data == nil then
    log(bWriteLog and "onGetShareInfoRsp data is none")
    return
  end
  ShareMgr.ShareInfo = data
  log_tree("ShareMgr.ShareInfo", ShareMgr.ShareInfo)
end
function ShareMgr.GetClientNetObj()
  if slua_GameFrontendHUD then
    return slua_GameFrontendHUD:GetClientNetObj()
  end
  return nil
end
function ShareMgr.GetHDmpveSDKObj()
  local netObj = ShareMgr.GetClientNetObj()
  if netObj then
    return netObj._ConnectorInst
  end
  return nil
end
function ShareMgr.WebviewSharePhoto(title, desc, source, adjust_campaign, imgPath, jump)
  if not ShareMgr.isShareEnable() then
    log(bWriteLog and "ShareMgr.WebviewSharePhoto, share is closed!")
    return
  end
  IMSDKSystem.StartIMSDKTimer(4)
  ShareMgr.HDmpveUploadFile(imgPath, function(isSuccess, imgURL)
    log(bWriteLog and "ShareMgr.HDmpveUploadFile, success = " .. tostring(isSuccess) .. ", imgURL = " .. tostring(imgURL))
    if isSuccess then
      local shareUrl = ShareMgr.GetWebviewShareURL(title, desc, imgURL, source, adjust_campaign, jump)
      local channel
      if source == ShareSource.Twitter then
        ShareMgr.ShareTwitterClipBoardPopUI(shareUrl)
        return
      elseif source == ShareSource.VK then
        channel = BP_ENUM_PLAYFORM_VK
      elseif source == ShareSource.Line then
        channel = BP_ENUM_PLAYFORM_LINE
      end
      if channel then
        local EUGDPRSystem = require("client.logic.countryarea.logic_eugdpr")
        if EUGDPRSystem.GetIsGDPRUser() then
          local OKHandle = function()
            local logic_msdk_share_interface = require("client.logic.share.logic_msdk_share_interface")
            logic_msdk_share_interface:ShareWithPhotoByChannel_Simple(imgPath, title, desc .. " " .. shareUrl, channel)
          end
          ShareMgr.ShowGDPRHint(OKHandle)
          return
        end
        local logic_msdk_share_interface = require("client.logic.share.logic_msdk_share_interface")
        logic_msdk_share_interface:ShareWithPhotoByChannel_Simple(imgPath, title, desc .. " " .. shareUrl, channel)
      else
        log(bWriteLog and "ShareMgr.WebviewSharePhoto, channel is nil.")
      end
    end
  end, 3, ShareMgr.ShareFileType.Share)
end
function ShareMgr.WebviewShareLink(title, desc, source, adjust_campaign, imgPath, jump)
  if not ShareMgr.isShareEnable() then
    log(bWriteLog and "ShareMgr.WebviewShareLink, share is closed!")
    return
  end
  IMSDKSystem.StartIMSDKTimer(4)
  ShareMgr.HDmpveUploadFile(imgPath, function(isSuccess, imgURL)
    log(bWriteLog and "ShareMgr.HDmpveUploadFile, success = " .. tostring(isSuccess) .. ", imgURL = " .. tostring(imgURL))
    if isSuccess then
      if title == "" then
        title = LocUtil.LocalizeResFormat(4053)
      end
      if desc == "" then
        desc = LocUtil.LocalizeResFormat(4054)
      end
      local shareUrl = ShareMgr.GetWebviewShareURL(title, desc, imgURL, source, adjust_campaign, jump)
      local EUGDPRSystem = require("client.logic.countryarea.logic_eugdpr")
      if EUGDPRSystem.GetIsGDPRUser() then
        local OKHandler = function()
          ShareMgr.ShareLinkByPlatform(source, title, desc, shareUrl)
        end
        ShareMgr.ShowGDPRHint(OKHandler)
      else
        ShareMgr.ShareLinkByPlatform(source, title, desc, shareUrl)
      end
    end
  end, 3, ShareMgr.ShareFileType.Share)
end
function ShareMgr.ShareLinkByPlatform(source, title, desc, shareUrl)
  log(bWriteLog and "ShareMgr.ShareLinkByPlatform, source = " .. tostring(source) .. ", shareUrl = " .. tostring(shareUrl))
  if source == ShareSource.Facebook then
    local logic_msdk_share_interface = require("client.logic.share.logic_msdk_share_interface")
    logic_msdk_share_interface:ShareFacebookLink(title, desc, shareUrl)
  elseif source == ShareSource.SMS then
    local content = desc .. " " .. shareUrl
    Client.InviteSMSOfflineFriends(NetInterface, content)
  elseif source == ShareSource.Whatsapp then
    local content = desc .. " " .. shareUrl
    Client.InviteWhatsappOfflineFriends(NetInterface, title, content)
  elseif source == ShareSource.Messenger then
    local content = desc .. " " .. shareUrl
    Client.InviteSystemOfflineFriends(NetInterface, title, content)
  elseif source == ShareSource.Discord then
    local content = desc .. " " .. shareUrl
    local logic_msdk_share_interface = require("client.logic.share.logic_msdk_share_interface")
    logic_msdk_share_interface:ShareTextByCahnnel(BP_ENUM_PLAYFORM_DiscordByiTOP, "", content, "")
  end
end
function ShareMgr.HDmpveUploadFile(filePath, completeFunc, interval, shareFileType, dontShowWaitingUI, extraS3Key)
  if not dontShowWaitingUI then
    log(bWriteLog and "ShareMgr.HDmpveUploadFile, logic_connection_waiting show")
    logic_connection_waiting:Show(0, true, true)
  end
  local HDmpveSDKObj = ShareMgr.GetHDmpveSDKObj()
  if not HDmpveSDKObj then
    if not dontShowWaitingUI then
      log(bWriteLog and string.format("HDmpveUploadFile, Hide:%s", 1))
      logic_connection_waiting:Hide(0)
    end
    completeFunc(false)
    return
  end
  interval = interval or 3
  local TimeUtil = require("client.common.time_util")
  if 0 < interval and interval > TimeUtil.GetServerTimeInSec() - ShareMgr.LastHDmpveUploadTime then
    if not dontShowWaitingUI then
      log(bWriteLog and string.format("HDmpveUploadFile, Hide:%s", 2))
      logic_connection_waiting:Hide(0)
    end
    completeFunc(false)
    return
  end
  if shareFileType == nil then
    shareFileType = ShareMgr.ShareFileType.Share
  end
  ShareMgr.LastHDmpveUploadTime = TimeUtil.GetServerTimeInSec()
  local time_ticker = require("common.time_ticker")
  if ShareMgr.LastHDmpveTimerHandle ~= nil then
    time_ticker.RemoveTimer(ShareMgr.LastHDmpveTimerHandle)
  end
  log(bWriteLog and "ShareMgr.LastHDmpveTimerHandle1")
  ShareMgr.LastHDmpveTimerHandle = time_ticker.AddTimer(0, function()
    log(bWriteLog and "ShareMgr.LastHDmpveTimerHandle2")
    local destFileKey = ShareMgr.GenerateFileKeyInS3(filePath, shareFileType, extraS3Key)
    HDmpveSDKObj:UploadFile(filePath, shareFileType, destFileKey)
    repeat
      coroutine.yield(1)
    until HDmpveSDKObj:GetUploadStatusByFile(filePath) == 1 or TimeUtil.GetServerTimeInSec() - ShareMgr.LastHDmpveUploadTime >= 60
    log(bWriteLog and "ShareMgr.LastHDmpveTimerHandle3")
    if not dontShowWaitingUI then
      log(bWriteLog and string.format("HDmpveUploadFile, Hide:%s", 3))
      logic_connection_waiting:Hide(0)
    end
    if HDmpveSDKObj:GetUploadStatusByFile(filePath) == 1 then
      log(bWriteLog and "ShareMgr.LastHDmpveTimerHandle4")
      local url = HDmpveSDKObj:GetUploadUrlByFile(filePath)
      log(bWriteLog and "get upload url: " .. url)
      completeFunc(true, url)
    else
      log(bWriteLog and "ShareMgr.LastHDmpveTimerHandle5")
      completeFunc(false)
    end
    HDmpveSDKObj:ClearFileUpload(filePath)
    log(bWriteLog and "clear file upload")
  end)
end
function ShareMgr.ClearCloudTimerHandle()
  if ShareMgr.LastHDmpveTimerHandle ~= nil then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(ShareMgr.LastHDmpveTimerHandle)
    ShareMgr.LastHDmpveTimerHandle = nil
  end
end
local Crs = {
  JAPAN = "jk",
  KOREA = "jk",
  VNG = "vn",
  TW = "tw",
  BLUEHOLE = "bh",
  FIT = "fit",
  DEFAULT = "gl"
}
local DefaultDomains = {
  DEFAULT = FuncUtil.GetDomainByID(3366205),
  BLUEHOLE = "bgmi.globh.com",
  OLD = FuncUtil.GetDomainByID(3366174)
}
local Domains, RegionData
function ShareMgr.GetShareDomain(isOld)
  ShareMgr.CheckTableData()
  local domain = Domains.DEFAULT
  local Region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Region == PublishRegionMacros.BLUEHOLE then
    domain = Domains.BLUEHOLE
  elseif isOld then
    domain = Domains.OLD
  end
  return domain
end
function ShareMgr.GetCr(region)
  ShareMgr.CheckTableData()
  local result = RegionData.DEFAULT
  if RegionData[region] then
    result = RegionData[region]
  end
  return result.cr
end
function ShareMgr.CheckTableData()
  if RegionData then
    return
  end
  RegionData = {}
  if not Domains then
    Domains = {}
    local domainCfg = CDataTable.GetTable("ShareDomainCfg")
    local _domain
    for k, _default in pairs(DefaultDomains) do
      Domains[k] = domainCfg[k].Url
      _domain = Domains[k]
      if not _domain or _domain == "" then
        log(bWriteLog and "  : cfg lost" .. tostring(k))
        Domains[k] = _default
      end
    end
    log_tree("  : Domains", Domains)
  end
  for region, oneCr in pairs(Crs) do
    if not RegionData[region] then
      RegionData[region] = {cr = oneCr}
    end
  end
end
function ShareMgr.DoUrlOKHandle()
  if ShareMgr.resultUrl and ShareMgr.resultUrl ~= "" and ShareMgr.GetUrlOKFunc then
    ShareMgr.GetUrlOKFunc(ShareMgr.resultUrl)
  end
  ShareMgr.resultUrl = nil
  ShareMgr.GetUrlOKFunc = nil
end
function ShareMgr.OnGetUrl(ShareUrl)
  ShareMgr.resultUrl = ShareUrl
  local EUGDPRSystem = require("client.logic.countryarea.logic_eugdpr")
  if EUGDPRSystem.GetIsGDPRUser() then
    ShareMgr.ShowGDPRHint(ShareMgr.DoUrlOKHandle)
  else
    ShareMgr.DoUrlOKHandle()
  end
end
function ShareMgr.ShareWithUploadNew(imgPath, getUrlFunc, okFunc, useShortUrl, modInfo, cfg, src)
  log(bWriteLog and "[gordon]:ShareWithUploadNew path =" .. imgPath)
  if not ShareMgr.isShareEnable() then
    log(bWriteLog and "the share system is not open!")
    return
  end
  IMSDKSystem.StartIMSDKTimer(4)
  local HDmpveSDKObj = ShareMgr.GetHDmpveSDKObj()
  if HDmpveSDKObj then
    ShareMgr.GetUrlOKFunc = okFunc
    if getUrlFunc then
      getUrlFunc(nil, modInfo, cfg, src, function(link)
        if useShortUrl then
          ShareMgr.GetShortUrl(link, ShareMgr.OnGetUrl)
        else
          ShareMgr.OnGetUrl(link)
        end
      end)
    end
  end
end
function ShareMgr.ShareWithUpload(imgPath, getUrlFunc, okFunc, useShortUrl, title, desc, ...)
  log(bWriteLog and "[gordon]:ShareWithUploadOld path =" .. imgPath)
  if not ShareMgr.isShareEnable() then
    log(bWriteLog and "the share system is not open!")
    return
  end
  local params = table.pack(...)
  IMSDKSystem.StartIMSDKTimer(4)
  ShareMgr.HDmpveUploadFile(imgPath, function(isSuccess, imgUrl)
    if isSuccess then
      local HDmpveSDKObj = ShareMgr.GetHDmpveSDKObj()
      if HDmpveSDKObj then
        local ShareUrl
        if getUrlFunc then
          ShareUrl = getUrlFunc(imgUrl, title, desc, table.unpack(params))
        end
        ShareMgr.GetUrlOKFunc = okFunc
        if useShortUrl then
          ShareMgr.GetShortUrl(ShareUrl, ShareMgr.OnGetUrl)
        else
          ShareMgr.OnGetUrl(ShareUrl)
        end
      end
    end
  end, 3, ShareMgr.ShareFileType.Share)
end
function ShareMgr.shareFacebook(imgPath, getUrlFunc, title, desc, ...)
  local OKHandle = function(ShareUrl)
    local logic_msdk_share_interface = require("client.logic.share.logic_msdk_share_interface")
    logic_msdk_share_interface:ShareFacebookLink(title, desc, ShareUrl)
  end
  ShareMgr.ShareWithUpload(imgPath, getUrlFunc, OKHandle, false, title, desc, ...)
end
function ShareMgr.shareDiscord(imgPath, getUrlFunc, title, desc, ...)
  local OKHandle = function(ShareUrl)
    local HDmpveSDKObj = ShareMgr.GetHDmpveSDKObj()
    if HDmpveSDKObj then
      local content = desc .. " " .. ShareUrl
      local logic_msdk_share_interface = require("client.logic.share.logic_msdk_share_interface")
      logic_msdk_share_interface:ShareTextByCahnnel(BP_ENUM_PLAYFORM_DiscordByiTOP, "", content, "")
    end
  end
  ShareMgr.ShareWithUpload(imgPath, getUrlFunc, OKHandle, true, title, desc, ...)
end
function ShareMgr.ShareTwitterClipBoardPopUI(sShareUrl)
  local HDmpveSDKObj = ShareMgr.GetHDmpveSDKObj()
  if HDmpveSDKObj then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    local nStyleType = CommonMsgBoxMgr.SHOW_TYPE_TWO
    local sTitle = LocUtil.GetLocalizeResStr(101001)
    local sMsg = LocUtil.GetLocalizeResStr(64149)
    local sBtnOK = LocUtil.GetLocalizeResStr(64150)
    local fClickOkCallback = function()
      Client.ClipBoardCopy(sShareUrl)
      ShowNotice(64151)
    end
    CommonMsgBoxMgr.Show(nStyleType, sTitle, sMsg, fClickOkCallback, nil, sBtnOK)
  end
end
function ShareMgr.GetDefaultShareUrl(imageUrl, title, desc, campaign, moduleParams, tokenType, source)
  if not imageUrl then
    return
  end
  title = title or LocUtil.GetLocalizeResStr("4366")
  desc = desc or ""
  title = Client.UrlEncode(Client.HtmlEncode(title))
  desc = Client.UrlEncode(Client.HtmlEncode(desc))
  local cdnDomain = "https://" .. ShareMgr.GetShareImageDomain() .. "/"
  local image_Path = string.sub(imageUrl, string.len(cdnDomain) + 1, string.len(imageUrl))
  image_Path = Client.UrlEncode(image_Path)
  local region = Client.GetPublishRegion()
  local acceptor = ""
  if moduleParams then
    if source then
      acceptor = moduleParams .. "&src=" .. tostring(source)
    else
      acceptor = moduleParams
    end
  end
  local content = "image=%s&title=%s&descript=%s&"
  content = string.format(content, image_Path, title, "")
  local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
  log(bWriteLog and "  : tokenType" .. tostring(tokenType))
  local adjToken = AdjustSystem:GetRegionToken(tokenType or AdjustSystem.E_TokenType.CallbackPlayer)
  local adjUrlScheme = AdjustSystem:GetRegionDeeplinkUrlScheme()
  local adjust_deeplink = adjUrlScheme .. acceptor
  adjust_deeplink = Client.UrlEncode(adjust_deeplink)
  local campaignName = campaign or "recall"
  local domain = ShareMgr.GetShareDomain()
  local logic_deeplink = require("client.slua.logic.deeplink.logic_deeplink")
  local gameId = logic_deeplink:GetDeeplinkUrlSchemeAppId()
  local cr = ShareMgr.GetCr(region)
  local sLink = "https://%s/recallfriend.php?cdn=2&gameid=%s&%s%s&cr=%s&adjust_t=%s&adjust_deeplink=%s&adjust_campaign=%s"
  local link = string.format(sLink, domain, gameId, content, acceptor, cr, adjToken, adjust_deeplink, campaignName)
  log(bWriteLog and "GetDefaultShareUrl " .. tostring(link))
  return link
end
function ShareMgr.shareWhatsApp(imgPath, getUrlFunc, title, desc, ...)
  local OKHandle = function(ShareUrl)
    local HDmpveSDKObj = ShareMgr.GetHDmpveSDKObj()
    if HDmpveSDKObj then
      local content = desc .. ShareUrl
      Client.InviteWhatsappOfflineFriends(NetInterface, title, content)
    end
  end
  ShareMgr.ShareWithUpload(imgPath, getUrlFunc, OKHandle, true, title, desc, ...)
end
function ShareMgr.shareMessenger(imgPath, getUrlFunc, title, desc, ...)
  local OKHandle = function(ShareUrl)
    local HDmpveSDKObj = ShareMgr.GetHDmpveSDKObj()
    if HDmpveSDKObj then
      local content = desc .. ShareUrl
      Client.InviteSystemOfflineFriends(NetInterface, title, content)
    end
  end
  ShareMgr.ShareWithUpload(imgPath, getUrlFunc, OKHandle, true, title, desc, ...)
end
function ShareMgr.shareWithPhoto(imgPath, source, ShareUrl, title, desc)
  if not ShareMgr.isShareEnable() then
    log(bWriteLog and "the share system is not open!")
    return
  end
  IMSDKSystem.StartIMSDKTimer(4)
  local HDmpveSDKObj = ShareMgr.GetHDmpveSDKObj()
  if HDmpveSDKObj then
    local OnGetUrl = function(_shareUrl)
      local channel
      if source == ShareSource.VK then
        channel = BP_ENUM_PLAYFORM_VK
      elseif source == ShareSource.Line then
        channel = BP_ENUM_PLAYFORM_LINE
      end
      if channel then
        local EUGDPRSystem = require("client.logic.countryarea.logic_eugdpr")
        local OKHandle = function()
          log(bWriteLog and "[ :imgPath" .. imgPath)
          log(bWriteLog and "[ :shareUrl" .. _shareUrl)
          log(bWriteLog and "[ :channel" .. channel)
          local logic_msdk_share_interface = require("client.logic.share.logic_msdk_share_interface")
          logic_msdk_share_interface:ShareWithPhotoByChannel_Simple(imgPath, title, desc .. " " .. _shareUrl, channel)
        end
        if EUGDPRSystem.GetIsGDPRUser() then
          ShareMgr.ShowGDPRHint(OKHandle)
          return
        end
        OKHandle()
      else
        log(bWriteLog and "shareRecallInviteWithPhoto no channel")
      end
    end
    ShareMgr.GetShortUrl(ShareUrl, OnGetUrl)
  end
end
function ShareMgr.GetWebviewShareURL(title, desc, imageURL, source, adjust_campaign, jump)
  if title == "" then
    title = LocUtil.LocalizeResFormat(4053)
  end
  title = Client.UrlEncode(Client.HtmlEncode(title))
  if desc == "" then
    desc = LocUtil.LocalizeResFormat(4054)
  end
  desc = Client.UrlEncode(Client.HtmlEncode(desc))
  local cdnDomain = "https://" .. ShareMgr.GetShareImageDomain() .. "/"
  local imagePath = string.sub(imageURL, string.len(cdnDomain) + 1)
  local logic_deeplink = require("client.slua.logic.deeplink.logic_deeplink")
  local gameId = logic_deeplink:GetDeeplinkUrlSchemeAppId()
  local area = "gl"
  local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
  local adjust_t = AdjustSystem:GetRegionToken(AdjustSystem.E_TokenType.NewPlayer)
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    area = "jk"
  elseif region == PublishRegionMacros.VNG then
    area = "vn"
    adjust_t = "gw3v7j9"
  elseif region == PublishRegionMacros.TW then
    area = "tw"
  elseif region == PublishRegionMacros.BLUEHOLE then
    area = "bh"
  elseif region == PublishRegionMacros.FIT then
    area = "fit"
  else
    area = "gl"
  end
  local content = "gameid=%s&image=%s&title=%s&descript=%s&"
  if jump then
    content = "gameid=%s&image=%s&title=%s&descript=%s&jump=%s&"
    content = string.format(content, gameId, imagePath, title, desc, Client.UrlEncode(jump))
  else
    content = string.format(content, gameId, imagePath, title, desc)
  end
  local acceptor = "module=1010000&uid=%s&src=%s"
  acceptor = string.format(acceptor, tostring(DataMgr.roleData.uid), source)
  local adjust_deeplink = FuncUtil.GetKeywordByID(3377010) .. "%s://" .. acceptor
  adjust_deeplink = string.format(adjust_deeplink, gameId)
  adjust_deeplink = Client.UrlEncode(adjust_deeplink)
  local tail = "&adjust_campaign=%s&cr=%s"
  tail = string.format(tail, adjust_campaign, area)
  local domain = ShareMgr.GetShareDomain()
  local link = "https://" .. domain .. "/h5campaign.php?cdn=2&" .. content .. acceptor .. "&adjust_t=" .. adjust_t .. "&adjust_deeplink=" .. adjust_deeplink .. tail
  log(bWriteLog and "ShareMgr.GetWebviewShareURL, url = " .. tostring(link))
  return link
end
function ShareMgr.GetShareImageDomain()
  local domain = FuncUtil.GetDomainByID(3366204)
  local Region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Region == PublishRegionMacros.BLUEHOLE then
    domain = "share.globh.com"
  else
    domain = FuncUtil.GetDomainByID(3366204)
  end
  return domain
end
function ShareMgr.SetShortUrlAndHandle(_url, _handle)
  log(bWriteLog and "ShareMgr.SetShortUrlAndHandle url = " .. tostring(_url))
  ShareMgr.GetShortUrlHandle = _handle
  ShareMgr.LastUrl = _url
end
function ShareMgr.DoShortUrlAndHandle()
  log(bWriteLog and "ShareMgr.DoShortUrlAndHandle url = " .. tostring(ShareMgr.LastUrl))
  if ShareMgr.LastUrl and ShareMgr.LastUrl ~= "" and ShareMgr.GetShortUrlHandle then
    ShareMgr.GetShortUrlHandle(ShareMgr.LastUrl)
    ShareMgr.SetShortUrlAndHandle(nil, nil)
  end
end
function ShareMgr.GetShortUrl(url, handle, mark)
  if not url then
    return
  end
  log(bWriteLog and "ShareMgr.GetShortUrl url = " .. tostring(url) .. "|| switch = " .. tostring(LobbySystem.CheckOpen(BP_ENUM_SHORT_URL_SWITCH_ID)))
  ShareMgr.SetShortUrlAndHandle(url, handle)
  local shortMark = mark
  if mark == nil then
    shortMark = ShareMgr.GetShortUrlMask()
  end
  if LobbySystem.CheckOpen(BP_ENUM_SHORT_URL_SWITCH_ID) then
    logic_connection_waiting:Show(1)
    local time_ticker = require("common.time_ticker")
    ShareMgr.GetShortUrlTimer = time_ticker.AddTimerOnce(3, function()
      ShareMgr.GetShortUrlTimeOut()
    end)
    local IMSDKHelper = import("IMSDKHelper")
    local IMSDKHelperInstance = IMSDKHelper.GetInstance()
    IMSDKHelperInstance:GetShortUrl(url, shortMark, "")
  else
    ShareMgr.DoShortUrlAndHandle()
  end
end
function ShareMgr.SetSponsorAward(reward_cnt, refresh_time)
  ShareMgr.SponsorAward.reward_cnt = reward_cnt or 0
  ShareMgr.SponsorAward.refresh_time = refresh_time or 0
end
function ShareMgr.HasSponsorAward()
  local TimeUtil = require("client.common.time_util")
  if ShareMgr.SponsorAward then
    local bNoReward = ShareMgr.SponsorAward.reward_cnt == 0
    local bNoToday = TimeUtil.FormatTime_YMD(ShareMgr.SponsorAward.refresh_time) ~= TimeUtil.FormatTime_YMD(TimeUtil.GetServerTimeInSec())
    log(bWriteLog and "[moment] time" .. tostring(ShareMgr.SponsorAward.refresh_time) .. "cnt" .. tostring(ShareMgr.SponsorAward.reward_cnt))
    return bNoReward or bNoToday
  end
end
function ShareMgr.GetShortUrlTimeOut()
  log(bWriteLog and "ShareMgr.GetShortUrlTimeOut")
  logic_connection_waiting:Hide(1)
  ShareMgr.DoShortUrlAndHandle()
end
function ShareMgr.OnGetShortUrl(retCode, shortUrl)
  log(bWriteLog and "ShareMgr.OnGetShortUrl  " .. tostring(retCode) .. " || shortUrl = " .. tostring(shortUrl))
  logic_connection_waiting:Hide(1)
  if ShareMgr.GetShortUrlTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(ShareMgr.GetShortUrlTimer)
    ShareMgr.GetShortUrlTimer = nil
  end
  if retCode ~= 1 then
    log_error("ShareMgr.OnGetShortUrl Error!")
    ShareMgr.DoShortUrlAndHandle()
    return
  end
  ShareMgr.SetShortUrlAndHandle(shortUrl, ShareMgr.GetShortUrlHandle)
  ShareMgr.DoShortUrlAndHandle()
end
function ShareMgr.Check180ShareOpen()
  return LobbySystem.CheckOpen(20226)
end
local status = {medal = nil}
function ShareMgr.GetCheckBoxStatusByIdx(idx)
  if ShareMgr.status[idx] then
    return true
  end
  return false
end
function ShareMgr.SetCheckBoxStatusByIdx(idx, bSwitch)
  ShareMgr.status[idx] = bSwitch
end
function ShareMgr.SetMedalCheckBoxStatus(bSwitch)
  status.medal = bSwitch
end
local getChannelName = function()
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  local HDmpveChannelID = Client.GetLoginChannel(NetInterface)
  local ChannelName = SettingAccount.GetNameByHDmpveChannel(HDmpveChannelID)
  return ChannelName
end
function ShareMgr.ReportClickShare(uiName)
  local cfg = {
    channelName = getChannelName(),
      }
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.SHARE_180_CLICK, 0, json.encode(cfg))
end
function ShareMgr.ShareBtnReq(actions, share_type, channel_type, itemid, battle_id, share_content_type)
  battle_id = battle_id or tostring(BattleResultUI.battle_id)
  log(bWriteLog and string.format("ShareMgr.ShareBtnReq actions:%s share_type:%s channel_type:%s itemid:%s battle_id:%s", tostring(actions), tostring(share_type), tostring(channel_type), tostring(itemid), tostring(battle_id)))
  local ShareHandler = require("client.network.Protocol.ShareHandler")
  if not share_type then
    error("send_share_actions_request share_type is nil")
  end
  ShareHandler.send_share_actions_request(actions, share_type, channel_type, itemid, battle_id, share_content_type)
end
function ShareMgr.IsNoschatAndBgBgShow(channel)
  if not LobbySystem.CheckOpen(950004) and (channel == ShareSource.BgBg or channel == ShareSource.Noschat) then
    return false
  end
  return true
end
function ShareMgr.GenerateFileKeyInS3(filepath, shareType, extraS3Key)
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local openid = IMSDKHelperInstance:getOpenID()
  local currentTimestamp = os.time()
  local currentDateStr = os.date("%Y%m%d", currentTimestamp)
  local fileHash
  if extraS3Key ~= nil and extraS3Key.fileHash ~= nil then
    fileHash = extraS3Key.fileHash
  else
    fileHash = Client.GetFileHash(filepath)
  end
  local shareKeyTemplateByType = {
    {key = "1", value = "shares"},
    {key = "2", value = "moments"},
    {key = "3", value = "replays"},
    {key = "4", value = "voices"},
    {key = "5", value = "intimacy"},
    {key = "6", value = "diy"},
    {key = "7", value = "ugc"},
    {key = "8", value = "local"},
    {key = "9", value = "manor"},
    {key = "10", value = "memoir"}
  }
  local subKeyName = "shares"
  for i, v in pairs(shareKeyTemplateByType) do
    if v.key == tostring(shareType) then
      subKeyName = v.value
      break
    end
  end
  local uploadFileKey = string.format("%s/%s/%s%s%s_%s", subKeyName, currentDateStr, "igshare", openid, tostring(currentTimestamp), fileHash)
  log(bWriteLog and "ShareMgr.GenerateFileKeyInS3 return: " .. uploadFileKey)
  return uploadFileKey
end
function ShareMgr.GetGameDeeplinkUrlSchemeId()
end
return ShareMgr