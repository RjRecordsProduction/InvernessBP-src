local AdjustSystem = {
  lobbyAdjustURL = "",
  DeeplinkAdjustTokens = {
    JAPAN = {
      XMissionActivity = "golkh5d_obj9v96",
      CallbackPlayer = "sin121o_mig9qte",
      NewPlayer = "q4xovjb_uqp3373",
      InviteFriend = "309y2te_92lgiiw",
      BargianDetail = "x1mtjpd_mqwt2n5",
      Esport = "1r76m1d_p6ogkcy",
      MessageInvite = "aghzhc_baol9j",
      GroupBuying = "sin121o_mig9qte"
    },
    KOREA = {
      XMissionActivity = "golkh5d_obj9v96",
      CallbackPlayer = "sin121o_mig9qte",
      NewPlayer = "q4xovjb_uqp3373",
      InviteFriend = "309y2te_92lgiiw",
      BargianDetail = "x1mtjpd_mqwt2n5",
      Esport = "1r76m1d_p6ogkcy",
      MessageInvite = "aghzhc_baol9j",
      GroupBuying = "sin121o_mig9qte"
    },
    VNG = {
      XMissionActivity = nil,
      CallbackPlayer = "du5fl4z",
      NewPlayer = "9jb3c7a",
      InviteFriend = "ou31239",
      BargianDetail = "b33tv6z",
      Esport = "f4723cs",
      MessageInvite = "q54xct7",
      GroupBuying = "du5fl4z"
    },
    TW = {
      XMissionActivity = "b2d7oyh_w6n0ov0",
      CallbackPlayer = "5ovx2gz_hr5kswb",
      NewPlayer = "rje448b_q6ee9rd",
      InviteFriend = "2yw4nqf_v7xgqie",
      BargianDetail = "jnqvn59_ngaa8kz",
      Esport = "u1fqgv5_87hbp72",
      MessageInvite = "qw5rsyd_5nc1lo9",
      GroupBuying = "5ovx2gz_hr5kswb"
    },
    BLUEHOLE = {
      XMissionActivity = "c8v7ero_zm2okly",
      CallbackPlayer = "7tnt2tu_ks0c7jb",
      NewPlayer = "px5rdom_q89mi6a",
      InviteFriend = "8jbvj9d_wfgtug1",
      BargianDetail = "wuy1rhn_jbrg87v",
      MessageInvite = "aimuy0_lxw6bo",
      GroupBuying = "20syal5k_209og9g8"
    },
    FIT = {
      XMissionActivity = "h4oqzwk_5yrbkxo",
      CallbackPlayer = "m5kke4f_ftdu4hp",
      NewPlayer = "tdklb4n_5j89b3e",
      InviteFriend = "8svhrnn_kkfpwi5",
      BargianDetail = "hti46s0_ku2yrul",
      MessageInvite = "mb9glrj_sw6j4le",
      GroupBuying = "m5kke4f_ftdu4hp"
    },
    GLOBAL = {
      XMissionActivity = "ofx0cqb_3yzt9lx",
      CallbackPlayer = "yjhb4d9_drkpe1m",
      NewPlayer = "xxry36_6dp6z9",
      InviteFriend = "d05sefz_ejv4ir5",
      BargianDetail = "1ccqjjq_28blkbm",
      Esport = "xpndwe9_n8ilgs4",
      MessageInvite = "mb9glrj_sw6j4le",
      GroupBuying = "20uqvda6_20xmgxtm"
    }
  },
  CurrentRegion = nil,
  HasCheckJump = false
}
local E_TokenType = {
  XMissionActivity = "XMissionActivity",
  CallbackPlayer = "CallbackPlayer",
  NewPlayer = "NewPlayer",
  InviteFriend = "InviteFriend",
  BargianDetail = "BargianDetail",
  Esport = "Esport",
  MessageInvite = "MessageInvite",
  GroupBuying = "GroupBuying"
}
AdjustSystem.
function AdjustSystem:OnInitialize()
  AdjustSystem.__super.OnInitialize(self)
end
function AdjustSystem:OnLogOut()
  self:ClearAdjustDeepLink()
  self.HasCheckJump = false
end
function AdjustSystem:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    self:ClearAdjustDeepLink()
    self.HasCheckJump = false
  end
end
function AdjustSystem:GetRegionToken(tokenType)
  local region = Client.GetPublishRegion()
  local tokenForRegion = self.DeeplinkAdjustTokens[region] or self.DeeplinkAdjustTokens.GLOBAL
  local token = tokenForRegion[tokenType]
  if token == nil then
    token = ""
    log(bWriteLog and "AdjustSystem:GetRegionToken return null for adjust token type:" .. tokenType)
  end
  return token
end
function AdjustSystem:GetRegionDomain()
  local region = Client.GetPublishRegion()
  local domain = ""
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    domain = "mqf5.adj.st"
  elseif region == PublishRegionMacros.VNG then
    domain = "nzrm.adj.st"
  elseif region == PublishRegionMacros.TW then
    domain = "cpmx.adj.st"
  elseif region == PublishRegionMacros.BLUEHOLE then
    domain = "sazp.adj.st"
  elseif region == PublishRegionMacros.FIT then
    domain = "sehx.adj.st"
  else
    domain = "uqp6.adj.st"
  end
  return domain
end
function AdjustSystem:GetRegionDeeplinkUrlScheme()
  local region = Client.GetPublishRegion()
  local urlScheme = ""
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local urlKeyword = FuncUtil.GetKeywordByID(3377010) or ""
  if PublishRegionMacros.IsJapanOrKorea() then
    urlScheme = urlKeyword .. "1321://"
  elseif region == PublishRegionMacros.VNG then
    urlScheme = urlKeyword .. "1380://"
  elseif region == PublishRegionMacros.TW then
    urlScheme = urlKeyword .. "1390://"
  elseif region == PublishRegionMacros.BLUEHOLE then
    urlScheme = urlKeyword .. "1450://"
  elseif region == PublishRegionMacros.FIT then
    urlScheme = urlKeyword .. "1440://"
  elseif region == PublishRegionMacros.FITCE then
    urlScheme = urlKeyword .. "1445://"
  else
    urlScheme = urlKeyword .. "1320://"
  end
  return urlScheme
end
function AdjustSystem:GetRegionGameId()
  local region = Client.GetPublishRegion()
  local urlScheme = 1320
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    urlScheme = 1321
  elseif region == PublishRegionMacros.VNG then
    urlScheme = 1380
  elseif region == PublishRegionMacros.TW then
    urlScheme = 1390
  elseif region == PublishRegionMacros.BLUEHOLE then
    urlScheme = 1450
  elseif region == PublishRegionMacros.FIT then
    urlScheme = 1440
  else
    urlScheme = 1320
  end
  return urlScheme
end
function AdjustSystem:GetShareLinkDomain()
  local domain = FuncUtil.GetDomainByID(3366036) .. "/"
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    domain = FuncUtil.GetDomainByID(3366052) .. "/"
  end
  return domain
end
function AdjustSystem:GetShareLinkCr()
  local cr = ""
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    cr = "jk"
  elseif region == PublishRegionMacros.VNG then
    cr = "vn"
  elseif region == PublishRegionMacros.TW then
    cr = "tw"
  elseif region == PublishRegionMacros.BLUEHOLE then
    cr = "bh"
  elseif region == PublishRegionMacros.FIT then
    cr = "fit"
  else
    cr = "gl"
  end
  return cr
end
function AdjustSystem:AdjustDomainInURL(url)
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.BLUEHOLE == region then
    return string.gsub(url, FuncUtil.GetDomainByID(3366036), FuncUtil.GetDomainByID(3366052), 1)
  end
  return url
end
function AdjustSystem:CheckAdjustJumpTo(bFromHome)
  log(bWriteLog and "AdjustSystem:CheckAdjustJumpTo")
  local newbieGuideManager = require("client.logic.newbie_manager.newbie_guide_manager")
  local needUpdateRole = newbieGuideManager.NeedUpdateRole()
  if needUpdateRole then
    log(bWriteLog and "AdjustSystem:CheckAdjustJumpTo return of needUpdateRole = ")
    return
  end
  local curStatus = GameStatus.GetGameStatus()
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "AdjustSystem:CheckAdjustJumpTo return of curStatus = " .. tostring(curStatus))
    return
  end
  local IntlHelper = import("IntlHelper")
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    log(bWriteLog and "AdjustSystem:CheckAdjustJumpTo return of IsInXMission = true")
    self:ClearAdjustDeepLink()
    return
  end
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  local bEnterMainCityLoading = Lobby_Main_City_Enter.bEnterMainCityLoading
  log(bWriteLog and "AdjustSystem:CheckAdjustJumpTo bEnterMainCityLoading = " .. tostring(bEnterMainCityLoading))
  if bEnterMainCityLoading then
    log(bWriteLog and "AdjustSystem:CheckAdjustJumpTo return of EnterMainCityLoading")
    self:ClearAdjustDeepLink()
    return
  end
  local validDeepLink = self:GetDeepLinkUrl()
  if bFromHome and (not validDeepLink or validDeepLink == "") then
    log(bWriteLog and "AdjustSystem:CheckAndJumpToUrl, AdjustParaAnalysis validDeepLink = " .. tostring(validDeepLink))
    IntlHelper.AdjustParaAnalysis()
    validDeepLink = self:GetDeepLinkUrl()
  end
  if not validDeepLink or validDeepLink == "" then
    log(bWriteLog and "AdjustSystem:CheckAdjustJumpTo return of validDeepLink = " .. tostring(validDeepLink))
    return
  end
  self:_AdjustJumpTo(validDeepLink)
end
function AdjustSystem:IsAwakedByAdjust()
  local IntlHelper = import("IntlHelper")
  if IntlHelper.IsAwakedByAdjust() then
    return true
  end
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local SaveAdjust = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eRestartGameAdjust)
  if not (SaveAdjust and SaveAdjust.url) or SaveAdjust.url == "" then
    return false
  end
  if SaveAdjust.time and tonumber(SaveAdjust.time) > 0 then
    return true
  end
  return false
end
function AdjustSystem:GetDeepLinkUrl()
  local IntlHelper = import("IntlHelper")
  local validDeepLink = IntlHelper.GetDeepLinkUrl()
  if validDeepLink ~= "" then
    log(bWriteLog and "AdjustSystem:GetDeepLinkUrl return of C++ validDeepLink = " .. tostring(validDeepLink))
    return validDeepLink
  end
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local SaveAdjust = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eRestartGameAdjust)
  if not (SaveAdjust and SaveAdjust.url) or SaveAdjust.url == "" then
    log(bWriteLog and "AdjustSystem:GetDeepLinkUrl return of SaveAdjust.url = nil")
    return ""
  end
  if SaveAdjust.time and tonumber(SaveAdjust.time) > 0 then
    log(bWriteLog and "AdjustSystem:GetDeepLinkUrl return of SaveAdjust.url = " .. tostring(SaveAdjust.url))
    return SaveAdjust.url
  end
  return ""
end
function AdjustSystem:ClearAdjustDeepLink()
  log(bWriteLog and "AdjustSystem:ClearAdjustDeepLink")
  local IntlHelper = import("IntlHelper")
  IntlHelper.ClearAdjustDeepLink()
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  playerPrefsSystem.SaveTableToFile_N({}, playerPrefsSystem.ePlayerPrefsType.eRestartGameAdjust)
end
function AdjustSystem:SetLobbyAdjustURL(url)
  self.lobbyAdjustURL = url
end
function AdjustSystem:GetLobbyAdjustURL()
  return self.lobbyAdjustURL
end
function AdjustSystem:_JumpEnd(url)
  log(bWriteLog and "AdjustSystem:_JumpEnd url = " .. tostring(url))
  self:ClearAdjustDeepLink()
  LobbyUI.CheckToReportTLog(url)
end
function AdjustSystem:_AdjustJumpTo(validDeepLink)
  log(bWriteLog and "AdjustSystem:_AdjustJumpTo, before validDeepLink = " .. validDeepLink)
  local IntlHelper = import("IntlHelper")
  local StringUtil = require("common.string_util")
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  validDeepLink = webModule:URLDecode(validDeepLink)
  log(bWriteLog and "AdjustSystem:_AdjustJumpTo, after validDeepLink = " .. validDeepLink)
  local bParse, url, JumpURL
  local ExternalJump = string.find(validDeepLink, tostring(BP_ENUM_MODULE_ExternalJumpTo_H5))
  if ExternalJump ~= nil then
    local tempURL
    local startAt = string.find(validDeepLink, "&submodule=1009619&")
    if startAt then
      tempURL = string.sub(validDeepLink, 1, startAt - 1)
      local isJumPurl = string.find(validDeepLink, "redirect")
      if isJumPurl and #validDeepLink > isJumPurl + 9 then
        JumpURL = string.sub(validDeepLink, isJumPurl + 9, #validDeepLink)
      end
    end
    bParse, url = StringUtil.AdjustParaAnalysis(tempURL)
  else
    bParse, url = StringUtil.AdjustParaAnalysis(validDeepLink)
  end
  if not bParse then
    log(bWriteLog and "AdjustSystem:_AdjustJumpTo return of bParse = " .. tostring(bParse))
    self:ClearAdjustDeepLink()
    return
  end
  local tempStr = string.match(url, "fb%d+")
  if tempStr ~= nil and StringUtil.Starts(url, tempStr) == true then
    log(bWriteLog and "AdjustSystem:_AdjustJumpTo return of tempStr = " .. tostring(tempStr))
    self:ClearAdjustDeepLink()
    return
  end
  local logic_community = require("client.slua.logic.community.logic_community")
  logic_community.SetJumpDeepLink(validDeepLink)
  local s = string.find(url, tostring(BP_ENUM_MODULE_SHARE_WONDERFUL_REPLAY))
  if s ~= nil then
    log(bWriteLog and "AdjustSystem:_AdjustJumpTo ShrareReplay, url = " .. url)
    local logic_share_replay = require("client.slua.logic.replay.logic_share_replay")
    local additionStr = logic_share_replay.GetAdditionalStrByUrl(validDeepLink)
    if additionStr ~= nil and additionStr ~= "" then
      url = url .. additionStr
    end
  end
  if ExternalJump then
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    ActivityNewSystem.JumpUrl(JumpURL, 1)
    self:_JumpEnd(url)
    return
  end
  local JumpUtils = require("client.logic.store.jump_utils")
  if JumpUtils.IsGameJumpUrl(url) == false and JumpUtils.IsPanDoraJumpUrl(url) == false then
    local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
    url = webModule:AddParameterByPersonalInfo(url)
  end
  if self:IsJumpByCommunity(url) and self:IsPlayerInRoom() then
    log(bWriteLog and "[mxiliu]AdjustSystem:_AdjustJumpTo is jump by community but room is have so clear")
    self:ClearAdjustDeepLink()
    return
  end
  if not self:IsClubDeepLink(url) then
    UIManager.AndroidBackToLobby()
  end
  self:AddTimerOnce(0.1, function()
    local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
    if Lobby_Main_City_Enter.bEnterMainCityLoading then
      log(bWriteLog and "AdjustSystem:_AdjustJumpTo 1")
      self:ClearAdjustDeepLink()
    else
      log(bWriteLog and "AdjustSystem:_AdjustJumpTo 2")
      GlobalData.JumpUrl(url)
      self:_JumpEnd(url)
    end
  end)
end
function AdjustSystem:IsJumpByCommunity(url)
  log(bWriteLog and "AdjustSystem:IsJumpByCommunity url = " .. tostring(url))
  local JumpUtils = require("client.logic.store.jump_utils")
  local params
  if JumpUtils.IsGameJumpUrl(url) then
    local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
    url = webModule:URLDecode(url)
    url = GlobalData.PreprocessUrl(url)
    local StringUtil = require("common.string_util")
    params = StringUtil.ParseURLParams(url)
    log_tree("AdjustSystem:IsJumpByCommunity params", params)
    if params.from == "app_widget" then
      return true
    end
  end
  return false
end
function AdjustSystem:IsPlayerInRoom()
  log(bWriteLog and "AdjustSystem:IsPlayerInRoom start ")
  local room_info = RoomSystem.CurrentRoomInfo
  if room_info and next(room_info) then
    log(bWriteLog and "AdjustSystem:IsPlayerInRoom room_info is have ")
    return true
  end
  if RoomSystem.IsShowWaiting() then
    log(bWriteLog and "AdjustSystem:IsPlayerInRoom IsShowWaiting")
    return true
  end
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local status = PlayerStatusMgr:GetStatusData(tonumber(DataMgr.roleData.uid))
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  if status and PlayerStatusUtil.IsRoom(status) then
    log(bWriteLog and "AdjustSystem:IsPlayerInRoom status = " .. tostring(status))
    return true
  end
  local mainCityUIShow = UIManager.IsUIShow(UIManager.UI_Config.MainCity_Main_UIBP)
  log_format("AdjustSystem:IsPlayerInRoom. mainCityUIShow=%s", mainCityUIShow)
  if mainCityUIShow then
    return false
  end
  local lobbyMainUI = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if lobbyMainUI and not lobbyMainUI:IsShow() then
    log(bWriteLog and "AdjustSystem:IsPlayerInRoom lobbyMainUI NotShow")
    return true
  end
  return false
end
function AdjustSystem:IsClubDeepLink(url)
  local logic_community = require("client.slua.logic.community.logic_community")
  local str = logic_community.GetFromScene()
  if string.find(tostring(url), str) then
    return true
  else
    return false
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CAdjustSystem = class(CModuleBase, nil, AdjustSystem)
return CAdjustSystem