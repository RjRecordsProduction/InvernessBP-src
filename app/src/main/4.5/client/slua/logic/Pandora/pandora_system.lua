local FirstLineBanner = {}
local PandoraSystem = {
  NPreviewActId = nil,
  BLocalStatus = true,
  bFriendReady = false,
  pandora2Id = {},
  PandoraTimer = {}
}
local Pandora2ActivityId = {}
local ModuleMustLoad = {
  "client.slua.logic.Pandora.pandora_protocol_layer",
  "client.slua.logic.Pandora.pandora_logic"
}
local CloudTestFlag = {
  Release = 0,
  Develop = 1,
  CE = 2
}
local pandoraUtils = require("client.slua.logic.Pandora.pandora_utils")
function PandoraSystem.GetAreaId()
  local BusinessHelper = import("BusinessHelper")
  if Client.IsShipping() and globalConfig.IsDirectConnect() and BusinessHelper.GetIMSDKEnv() == 1 then
    return 9
  else
    return DataMgr.roleData.idip_area_id or -1
  end
end
local GetCloudTest = function()
  local BusinessHelper = import("BusinessHelper")
  if BusinessHelper.GetIMSDKEnv() == 1 then
    return CloudTestFlag.Release
  end
  return CloudTestFlag.Develop
end
function PandoraSystem.GetMainAppVersion()
  local appVersion = Client.GetAppVersion()
  local ts = string.reverse(appVersion)
  local _, i = string.find(ts, "%.")
  local subLen = string.len(ts) - i
  return string.sub(appVersion, 1, subLen)
end
function PandoraSystem.Init()
  if not PandoraSystem.CheckSysOpen() then
    return
  end
  if BP_Panduola_Init then
    log(bWriteLog and "PandoraSystem.Init PandoraSystem is already initialized")
    return
  end
  local EnableLog = false
  if Client and Client.IsDevelopment() then
    EnableLog = true
  end
  local PandoraAdapter = require("client.slua.logic.Pandora.pandora_v2_adapter")
  PandoraAdapter:SetDebugLog(EnableLog)
  local closeActLog = EnableLog and 0 or 1
  local BusinessHelper = import("BusinessHelper")
  local iEnv = BusinessHelper.GetIMSDKEnv()
  if iEnv == 1 then
    closeActLog = 0
  end
  for _, v in ipairs(ModuleMustLoad) do
    local m = require(v)
    if m and m.Init then
      m.Init()
    end
  end
  local AkGameplayStatics = import("AkGameplayStatics")
  AkGameplayStatics.LoadBankByName("Pandora")
  local openId = tostring(DataMgr.roleData.openID)
  local roleId = tostring(DataMgr.roleData.uid)
  local appId = Client.GetITopGameId(NetInterface)
  local platId = "1"
  local accType = ""
  local area = tostring(PandoraSystem.GetAreaId())
  local partion = "1"
  local cloudTest = tostring(GetCloudTest())
  local accessToken = Client.GetToken(NetInterface)
  local sdkVersion = ""
  local gameAppVersion = PandoraSystem.GetMainAppVersion()
  local roleName = DataMgr.roleData.nickName
  local payToken = ""
  local headUrl = DataMgr.roleData.headIconUrl
  local registerchannelID = Client.GetRegisterChannelID(NetInterface)
  local deviceplatform = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if deviceplatform == DevicePlatformNameMacros.Android then
    platId = "1"
    sdkVersion = "GziPubgM_Android_V1"
  elseif deviceplatform == DevicePlatformNameMacros.IOS then
    platId = "0"
    local is5sDevices = Client.IsIPhoneFiveS(GameFrontendHUD)
    if is5sDevices == true then
      sdkVersion = "GziPubgM_IOS_5S_V1"
    else
      sdkVersion = "GziPubgM_IOS_V1"
    end
  else
    platId = "1"
    sdkVersion = "GziPubgM_Android_V1"
  end
  local channel = Client.GetLoginChannel(NetInterface)
  log(bWriteLog and "PandoraSystem.Init channel=" .. channel)
  accType = PANDORA_PLAYFORM[channel] or ""
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local belongingId = DataMgr.RegionData and DataMgr.RegionData.region or login_module.sIpRegion
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  local myLanguage = webModule:GetCurrentLanguage()
  local ticket = Client.GetWebViewTicket(NetInterface)
  local ipAddr = Client.GetIpAddr()
  local netWorkType = Client.GetNetWorkType()
  local publishRegion = Client.GetPublishRegion()
  local region = login_module.sIpRegion
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local sGameArea = ZoneSystem.GetChooseZone()
  if cloudTest == "1" then
    log(bWriteLog and "PandoraSystem.Init openId=" .. openId)
    log(bWriteLog and "PandoraSystem.Init roleId=" .. roleId)
    log(bWriteLog and "PandoraSystem.Init appId=" .. appId)
    log(bWriteLog and "PandoraSystem.Init platId=" .. platId)
    log(bWriteLog and "PandoraSystem.Init accType=" .. accType)
    log(bWriteLog and "PandoraSystem.Init area=" .. area)
    log(bWriteLog and "PandoraSystem.Init partion=" .. partion)
    log(bWriteLog and "PandoraSystem.Init cloudTest=" .. cloudTest)
    log(bWriteLog and "PandoraSystem.Init accessToken=" .. accessToken)
    log(bWriteLog and "PandoraSystem.Init sdkVersion=" .. sdkVersion)
    log(bWriteLog and "PandoraSystem.Init gameAppVersion=" .. gameAppVersion)
    log(bWriteLog and "PandoraSystem.Init roleName=" .. roleName)
    log(bWriteLog and "PandoraSystem.Init payToken=" .. payToken)
    log(bWriteLog and "PandoraSystem.Init headUrl=" .. headUrl)
    log(bWriteLog and "PandoraSystem.Init registerchannelID=" .. registerchannelID)
    log(bWriteLog and "PandoraSystem.Init belongingId=" .. belongingId)
    log(bWriteLog and "PandoraSystem.Init language=" .. myLanguage)
    log(bWriteLog and "PandoraSystem.Init ticket=" .. ticket)
    log(bWriteLog and "PandoraSystem.Init ipAddr=" .. ipAddr)
    log(bWriteLog and "PandoraSystem.Init netWorkType=" .. netWorkType)
  end
  local Init = function()
    log(bWriteLog and "PandoraSystem.Init RealInit")
    belongingId = DataMgr.RegionData and DataMgr.RegionData.region or login_module.sIpRegion
    local PandoraAdapter = require("client.slua.logic.Pandora.pandora_v2_adapter")
    PandoraAdapter:Init()
    local UserData = {
      sOpenId = openId,
      sAppId = appId,
      sRoleId = roleId,
      sPlatID = platId,
      sAcountType = accType,
      sArea = area,
      sPartition = partion,
      sAccessToken = accessToken,
      sGameVer = gameAppVersion,
      sPayToken = payToken,
      sChannelID = registerchannelID,
      publishRegion = publishRegion,
      m_netType = netWorkType,
      m_nation = region,
      m_ip = ipAddr,
      m_ticket = ticket,
      m_language = myLanguage,
      m_belongingId = belongingId,
      m_headUrl = headUrl,
      m_roleName = roleName,
      m_sdkVersion = sdkVersion,
      m_cloudTest = cloudTest,
      sGameArea = sGameArea,
      closeLog = closeActLog
    }
    PandoraAdapter:PandoraInit(UserData)
    log_warning(bWriteLog and "  . pandora later Init ")
    BP_Panduola_Init = true
    PandoraSystem.PandoraTimer = {}
  end
  if not DataMgr.RegionData.region or DataMgr.RegionData.region == "" then
    log(bWriteLog and string.format("PandoraSystem.Init region == nil"))
    local async = require("client.common.async")
    async.Run(function(co)
      async.AwaitEvent(co, 3, EVENTTYPE_SETTING, EVENTID_SET_REGION_OK)
      Init()
    end)
  else
    Init()
  end
end
function PandoraSystem.Release()
  log(bWriteLog and "PandoraSystem.Release")
  if not BP_Panduola_Init then
    return
  end
  local PandoraAdapter = require("client.slua.logic.Pandora.pandora_v2_adapter")
  PandoraAdapter:PandoraClose()
  BP_Panduola_Init = false
  local AkGameplayStatics = import("AkGameplayStatics")
  AkGameplayStatics.UnloadBankByName("Pandora")
  local HostedProtoBridge = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.HostedProtoBridge)
  local HostedConst = require("client.slua.logic.HostedProtoBridge.HostedConst")
  HostedProtoBridge:ClearStaticState(HostedConst.HostedType.Pandora)
  for _, v in ipairs(ModuleMustLoad) do
    local m = require(v)
    if m and m.Release then
      m.Release()
    end
  end
end
function PandoraSystem.CheckSysOpen()
  return PandoraSystem.BLocalStatus and LobbySystem.CheckOpen(BP_ENUM_PANDORA_OPEN)
end
function PandoraSystem.CheckActIsShowByUrl(actUrl)
  local JumpUtils = require("client.logic.store.jump_utils")
  if actUrl and actUrl ~= "" and JumpUtils.IsPanDoraJumpUrl(actUrl) then
    log(bWriteLog and "PandoraSystem.CheckActIsShowByUrl actUrl: " .. actUrl)
    if not PandoraSystem.CheckSysOpen() then
      return false
    end
    local actId = pandoraUtils.GetActIdByUrl(actUrl)
    if actId == nil or actId == 0 then
      return false
    end
  end
  return true
end
function PandoraSystem.ActIsReady(actId)
  local pandoraLogic = require("client.slua.logic.Pandora.pandora_logic")
  return pandoraLogic.ActIsReady(actId)
end
function PandoraSystem.ActPakIsReady(actId)
  local pandoraLogic = require("client.slua.logic.Pandora.pandora_logic")
  return pandoraLogic.ActPakIsReady(actId)
end
function PandoraSystem.GetRedDotType(actId)
  local pandoraLogic = require("client.slua.logic.Pandora.pandora_logic")
  return pandoraLogic.GetRedDotType(actId)
end
function PandoraSystem.ActHasRedPoint(actId, subID)
  local pandoraLogic = require("client.slua.logic.Pandora.pandora_logic")
  if subID then
    Pandora2ActivityId[actId] = subID
  end
  return pandoraLogic.ActHasRedPoint(actId)
end
function PandoraSystem.SendGolds(shareReason)
  local pandora_common_protocol = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.pandora_common_protocol)
  pandora_common_protocol:SendGolds(shareReason)
end
function PandoraSystem.SendCmd(sendTable)
  local protocolLayer = require("client.slua.logic.Pandora.pandora_protocol_layer")
  protocolLayer.SendCmd(sendTable)
end
function PandoraSystem.SendShowNotice()
  local pandoraNotice = require("client.pandora.pandora_notice")
  pandoraNotice.SendShowNotice()
end
function PandoraSystem.SendHideNotice()
  local pandoraNotice = require("client.pandora.pandora_notice")
  pandoraNotice.SendHideNotice()
end
function PandoraSystem.Share(strTitle, strDesc, strUrl, shareType)
  pandoraUtils.Share(strTitle, strDesc, strUrl, shareType)
end
function PandoraSystem.PopJumpScene(url, FromModuleID)
  if url == nil then
    return
  end
  log(bWriteLog and "PandoraSystem.PopJumpScene url: " .. url .. " FromModuleID =" .. tostring(FromModuleID))
  local JumpID = pandoraUtils.GetModuleIdByUrl(url)
  if JumpID == nil or JumpID == 0 then
    log_error("PandoraSystem PopJumpScene error: JumpID is nil")
    return
  end
  GlobalData.JumpUrl(url)
  local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
  if FromModuleID and FromModuleID ~= 0 then
    ui_jump_manager.AttachPandoraNode(FromModuleID)
  end
end
local jumpFail = false
function PandoraSystem.TryJumpUrl(url, nActId)
  log(bWriteLog and string.format("PandoraSystem.TryJumpUrl. url=%s, nActId=%s", tostring(url), tostring(nActId)))
  if not PandoraSystem.CheckSysOpen() then
    ShowNotice(120106)
    return
  end
  local actId = pandoraUtils.GetActIdByUrl(url)
  local pandoraLogic = require("client.slua.logic.Pandora.pandora_logic")
  local ActIsReady = pandoraLogic.ActIsReady(actId)
  local ActPakIsReady = pandoraLogic.ActPakIsReady(actId)
  log(bWriteLog and string.format("Pandora Ready Status, ActIsReady : %s ActPakIsReady : %s", ActIsReady, ActPakIsReady))
  if ActIsReady or ActPakIsReady then
    if ActIsReady and ActPakIsReady then
      pandoraUtils.JumpPandoraUrl(url)
    else
      local TimeUtil = require("client.common.time_util")
      if PandoraSystem.PandoraTimer and actId and not PandoraSystem.PandoraTimer[actId] then
        PandoraSystem.PandoraTimer[actId] = TimeUtil.GetServerTimeInSec()
      end
      local tryStartTime = PandoraSystem.PandoraTimer[actId]
      local outTime = TimeUtil.GetServerTimeInSec() - tryStartTime > 60
      if ActPakIsReady and not outTime then
        local tab = {}
        tab.type = "Show"
        tab.actid = tostring(actId)
        local HostedProtoBridge = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.HostedProtoBridge)
        local HostedConst = require("client.slua.logic.HostedProtoBridge.HostedConst")
        HostedProtoBridge:SetOpenFlag(HostedConst.HostedType.Pandora, "0")
        local protocolLayer = require("client.slua.logic.Pandora.pandora_protocol_layer")
        protocolLayer.SendCmd(tab)
      end
      if not outTime then
        ShowNotice(13205)
      else
        ShowNotice(115006)
        jumpFail = true
      end
    end
  else
    ShowNotice(115006)
    jumpFail = true
  end
end
function PandoraSystem.FormatPanPrintString()
  if jumpFail then
    return "3"
  else
    return ""
  end
end
function PandoraSystem.UpdateRedPoint()
  local pandoraLogic = require("client.slua.logic.Pandora.pandora_logic")
  pandoraLogic.UpdateRedPoint()
end
function PandoraSystem.HideCurAct()
  local pandoraLogic = require("client.slua.logic.Pandora.pandora_logic")
  pandoraLogic.HideCurAct()
end
function PandoraSystem.ShowShare(data)
  local Util = require("client.slua_ui_framework.util")
  local shareCfg = {
    capturePath = data.imagePath,
    sceneType = 7,
    isOld = true,
    reason = data.content,
    sendFlag = data.isSend,
    campaign = "pandora",
    isProjectTexture = data.isProjectTexture,
    clubShareParams = {
      bShowShareClub = true,
      useCapturePath = true,
      publishFeedType = data.club and data.club.type,
      gameScene = data.club and data.club.scene
    }
  }
  Util.ShowShare(shareCfg)
end
function PandoraSystem.AddToFirstLineBanner(nActId)
  if nActId then
    FirstLineBanner[nActId] = 1
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_BANNER_DATA_CHANGE)
end
function PandoraSystem.IsFirstBanner(nActId)
  if FirstLineBanner[nActId] then
    return true
  end
  return false
end
function PandoraSystem.HandlePandoraJump(pandoraActId)
  log(bWriteLog and "  : PandoraSystem.HandlePandoraJump")
  if pandoraActId then
    log(bWriteLog and "  :PandoraSystem.NPreviewActId" .. tostring(pandoraActId))
    local pandora_common_protocol = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.pandora_common_protocol)
    pandora_common_protocol:SendShow(pandoraActId)
    PandoraSystem.NPreviewActId = nil
  end
end
function PandoraSystem.TestExchangeGm(strGMMsg)
  if string.find(strGMMsg, "gm_pandora") then
    local GMSystem = RequireBlackList("blacklist.slua.logic.lobby_gm.logic_gm")
    if not GMSystem then
      return
    end
    local results = GMSystem.GetGMWordList(strGMMsg)
    if #results == 0 then
      return
    end
    log_tree("results", results)
    local pandora_common_protocol = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.pandora_common_protocol)
    pandora_common_protocol:ShowExchange({
      exchangeId = tostring(results[2])
    })
    UIManager.CloseUI(UIManager.UI_Config.Lobby_GM)
    return true
  end
  return
end
return PandoraSystem