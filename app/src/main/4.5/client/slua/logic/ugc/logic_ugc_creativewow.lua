local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local NetManager = require("client.network.comm.NetManager")
local LogicUGCCreativeWoW = {}
local ReportMissionInfoTimeroutDuration = 10
local ReportTimeoutRetryNum = 1
local SaveFailErrorCodeTipsID = {}
local SaveFailErrorCodeDefaultTipsID = 511806
local SaveTimerOutTipsID = 511807
local RandomInfoDefine = {RandomBinary = -1, RandomShortcut = -1}
local MissionInfoDefine = {
  MissionID = 0,
  MissionProgress = 0,
  RandomInfos = nil
}
function LogicUGCCreativeWoW:DefineAndResetData()
  self.CacheKey = "cache_creativewow"
  self.MapKey = "map_creativewow"
  self.MissionInfo = nil
  self.TestEnable = false
  self.TestMissionInfo = {MissionID = 1, MissionProgress = 0}
  self.AllMisionInfo = {}
  self.ReportMissionInfoQueue = {}
  self.ReportMissionInfoTiemr = nil
  self.bFromCWoW = false
end
function LogicUGCCreativeWoW:SetFromCWoW(bFromCWoW)
  self.end
function LogicUGCCreativeWoW:ReturnLobbyChangeToReturnCWoW()
  if slua_GameFrontendHUD and slua.isValid(CGameState) and CGameState.IsCreativeMode ~= nil and not CGameState:IsCreativeMode() then
    printf(bWriteLog and "LogicUGCCreativeWoW:NeedChangeReturnLobbyToReturnCWoW ,is not creativemode,return")
    return false
  end
  if CGameState and CGameState.bIsCreativeWoW then
    printf(bWriteLog and "LogicUGCCreativeWoW:NeedChangeReturnLobbyToReturnCWoW ,is creativewow,return")
    return false
  end
  if not self.bFromCWoW then
    printf(bWriteLog and "LogicUGCCreativeWoW:NeedChangeReturnLobbyToReturnCWoW ,is not from_cwow,return")
    return false
  end
  return true
end
function LogicUGCCreativeWoW:BackToCWoW()
  NetUtil.SendPkg("giveup_enter_game")
  NetUtil.SendPkg("exit_result")
  self:ReqEnter()
end
function LogicUGCCreativeWoW:SetCreativeWoWMissionID(missionID)
  printf(bWriteLog and "LogicUGCCreativeWoW:SetCreativeWoWMissionID missionID: %s", tostring(missionID))
  local serverInfo = self.AllMisionInfo[missionID]
  self.MissionInfo = {
    MissionID = missionID,
    MissionProgress = serverInfo and serverInfo.MissionProgress or 0,
    RandomInfos = serverInfo and serverInfo.RandomInfos or nil
  }
end
function LogicUGCCreativeWoW:GetCreativeWoWMissionInfo()
  printf(bWriteLog and "LogicUGCCreativeWoW:GetCreativeWoWMissionInfo MissionInfo: %s", tostring(self.MissionInfo))
  if self.MissionInfo == nil and self.TestEnable then
    local TableUtil = require("common.table_util")
    self.MissionInfo = TableUtil.CopyTable(self.TestMissionInfo)
  end
  return self.MissionInfo
end
function LogicUGCCreativeWoW:OnPreSwitchGameStatus(preState, nextState)
  print(bWriteLog and "LogicUGCCreativeWoW:OnPreSwitchGameStatus")
  if nextState == GameStatus.Lobby and preState == GameStatus.Fighting then
    self:OnClientFightingToLobby()
  end
end
function LogicUGCCreativeWoW:OnClientFightingToLobby()
  print(bWriteLog and "LogicUGCCreativeWoW:OnClientFightingToLobby")
  self.MissionInfo = nil
  self.bFromCWoW = false
end
function LogicUGCCreativeWoW:ChangeView()
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_team_change_type_request(1012, {90043})
  print(bWriteLog and "LogicUGCCreativeWoW:ChangeView")
end
function LogicUGCCreativeWoW:ReqEnter()
  if not self:CheckHaveDownload() then
    return
  end
  local UGCPlayHallRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCPlayHallRoom)
  if UGCPlayHallRoom and UGCPlayHallRoom:GetRoomInfo() then
    ShowNotice(655719)
    return
  end
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  DeviceOSInfo.getDeviceOSInfo()
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  MatchHandler.send_on_match_req(1012, 0, {600091}, DeviceOSInfo.InfoList)
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  LogicUGCMatch:SetIsCreativeWoW(true)
  print(bWriteLog and "LogicUGCCreativeWoW:ReqEnter")
end
function LogicUGCCreativeWoW:GetResState()
  local ResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  local cacheInfo = ResManager:GetUGCModCacheInfo(self.CacheKey)
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {
    self.MapKey
  })
  local BundleState = ResManager:GetUGCBundleState()
  state = PufferManager.GetMixDownloadState(state, BundleState)
  if state ~= PufferConst.ENUM_DownloadState.Done then
    if NetManager.bConnected == false then
      print(bWriteLog and "LogicUGCCreativeWoW:GetResState Net disconnected,pause download")
      self:PauseRes()
      return PufferConst.ENUM_DownloadState.Pause
    end
    cacheInfo.  else
    cacheInfo.state = PufferConst.ENUM_DownloadState.Done
    self:ReportMapDownloadState(state)
  end
  return cacheInfo.state
end
function LogicUGCCreativeWoW:DownloadRes()
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  local ResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  local cacheInfo = ResManager:GetUGCModCacheInfo(self.CacheKey)
  cacheInfo.state = PufferConst.ENUM_DownloadState.Download
  local mapState = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {
    self.MapKey
  })
  if mapState ~= PufferConst.ENUM_DownloadState.Done then
    cacheInfo.mapKey = self.MapKey
    PufferManager.Download(PufferConst.ENUM_DownloadType.MAP, {
      self.MapKey
    })
  end
  if ResManager:GetUGCBundleState() ~= PufferConst.ENUM_DownloadState.Done then
    log(bWriteLog and "LogicUGCCreativeWoW:DownloadRes bundle need download")
    cacheInfo.bundleKey = PufferConst.UGC_BUNDLE_ID
    LogicPufferBundle.DownloadBundle(PufferConst.UGC_BUNDLE_ID)
  end
  if self:GetResState() == PufferConst.ENUM_DownloadState.Done then
    cacheInfo.state = PufferConst.ENUM_DownloadState.Done
  end
end
function LogicUGCCreativeWoW:PauseRes()
  local ResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  local cacheInfo = ResManager:GetUGCModCacheInfo(self.CacheKey)
  cacheInfo.state = PufferConst.ENUM_DownloadState.Pause
  local cacheInfos = ResManager.modResCaches
  PufferManager.Pause(PufferConst.ENUM_DownloadType.MAP, {
    self.MapKey
  })
  local existOtherBundle = false
  for mK, mV in pairs(cacheInfos) do
    if mV.state == PufferConst.ENUM_DownloadState.Download and mV.bundleKey then
      existOtherBundle = true
      break
    end
  end
  if existOtherBundle == false then
    local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
    LogicPufferBundle.StopDownloadBundle(PufferConst.UGC_BUNDLE_ID)
  end
end
function LogicUGCCreativeWoW:GetResSize()
  local cSize, tSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.MAP, {
    self.MapKey
  })
  cSize = cSize / PufferConst.MB
  tSize = tSize / PufferConst.MB
  local ResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  local bundleCSize, bundleTSize = ResManager:GetUGCBundleSize()
  cSize = cSize + bundleCSize
  tSize = tSize + bundleTSize
  return cSize, tSize
end
function LogicUGCCreativeWoW:GetCWoWMissionDataRsp(errorCode, data_table, cwow_mission_score)
  print(bWriteLog and "LogicUGCCreativeWoW:GetCWoWMissionDataRsp errorCode = " .. errorCode .. "  cwow_mission_score = " .. tostring(cwow_mission_score))
  if errorCode == 0 then
    self.AllMisionInfo = data_table
    self.    if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
      UIManager.ShowUI(UIManager.UI_Config_InGame.CreativeWoWMissionUI)
    elseif GameStatus.IsInLobbyOrMainCity() then
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_CENTER_CHALLENGE_REFRESH)
    end
  end
end
function LogicUGCCreativeWoW:UpdateChallengeMissionData(MissionInfo)
  print(bWriteLog and "LogicUGCCreativeWoW:UpdateChallengeMissionData")
  log_tree("MissionInfo:" .. tostring(MissionInfo))
  local TableUtil = require("common.table_util")
  local CopyMissionInfo = TableUtil.CopyTable(MissionInfo)
  table.insert(self.ReportMissionInfoQueue, {NewMissionInfo = CopyMissionInfo, RetryCount = 0})
  self:ReportChallengeMissionInfo()
end
function LogicUGCCreativeWoW:ReportChallengeMissionInfo()
  local MissionInfoQueueNum = #self.ReportMissionInfoQueue
  print(bWriteLog and "LogicUGCCreativeWoW:ReportChallengeMissionInfo ReportMissionInfoTiemr:" .. tostring(self.ReportMissionInfoTiemr) .. " MissionInfoQueueNum:" .. tostring(MissionInfoQueueNum))
  if self.ReportMissionInfoTiemr ~= nil then
    return
  end
  if 0 < MissionInfoQueueNum then
    local ReportMissionInfo = self.ReportMissionInfoQueue[1]
    local CurServerInfo = self.AllMisionInfo[ReportMissionInfo.NewMissionInfo.MissionID]
    local ReportServerInfo
    if CurServerInfo == nil then
      ReportServerInfo = {}
    else
      local TableUtil = require("common.table_util")
      ReportServerInfo = TableUtil.CopyTable(CurServerInfo)
    end
    ReportServerInfo.MissionProgress = ReportMissionInfo.NewMissionInfo.MissionProgress
    ReportServerInfo.RandomInfos = ReportMissionInfo.NewMissionInfo.RandomInfos
    self.ReportMissionInfoTiemr = self:AddTimer(ReportMissionInfoTimeroutDuration, function()
      self.ReportMissionInfoTiemr = nil
      self:ReportChallengeMissionInfoTimeout()
    end)
    print(bWriteLog and " MissionID:" .. tostring(ReportMissionInfo.NewMissionInfo.MissionID))
    log_tree("ReportServerInfo:" .. tostring(ReportServerInfo))
    local UGCPublishHandler = require("client.network.Protocol.UGCPublishHandler")
    UGCPublishHandler.send_save_cwow_mission_data_req(ReportMissionInfo.NewMissionInfo.MissionID, ReportServerInfo)
  end
end
function LogicUGCCreativeWoW:ReportChallengeMissionInfoTimeout()
  print(bWriteLog and "LogicUGCCreativeWoW:ReportChallengeMissionInfoTimeout")
  local ReportMissionInfo = self.ReportMissionInfoQueue[1]
  if ReportMissionInfo.RetryCount < ReportTimeoutRetryNum then
    ReportMissionInfo.RetryCount = ReportMissionInfo.RetryCount + 1
  else
    table.remove(self.ReportMissionInfoQueue, 1)
    ShowNotice(SaveTimerOutTipsID)
  end
  self:ReportChallengeMissionInfo()
end
function LogicUGCCreativeWoW:SaveCWowMissionDataRsp(errcode, scores, ag)
  if self.ReportMissionInfoTiemr ~= nil then
    self:RemoveTimer(self.ReportMissionInfoTiemr)
    self.ReportMissionInfoTiemr = nil
  end
  table.remove(self.ReportMissionInfoQueue, 1)
  if errcode ~= 0 then
    local ErrCodeTipsID = SaveFailErrorCodeDefaultTipsID
    if SaveFailErrorCodeTipsID[errcode] ~= nil then
      ErrCodeTipsID = SaveFailErrorCodeTipsID[errcode]
    end
    ShowNotice(ErrCodeTipsID)
  end
  local CreativeChallengeMissionSubsystem = SubsystemMgr:Get("CreativeChallengeMissionSubsystem")
  if CreativeChallengeMissionSubsystem then
    CreativeChallengeMissionSubsystem:OnSaveMissionDataRsp(errcode, scores, ag)
  end
  self:ReportChallengeMissionInfo()
end
function LogicUGCCreativeWoW:CheckHaveDownload(friendUid, bDontShowTips)
  local state = self:GetResState()
  if state ~= PufferConst.ENUM_DownloadState.Done then
    print(bWriteLog and "LogicUGCCreativeWoW:CheckHaveDownload state = " .. tostring(state))
    if not bDontShowTips then
      local content = LocUtil.LocalizeResFormat(511097)
      if friendUid then
        local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
        local profile = logic_profile:GetLocalProfile(friendUid)
        if profile then
          content = LocUtil.LocalizeResFormat(511101, profile.nickName)
        end
      end
      local clickOkCallback = function()
        self:DownloadRes()
      end
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(2, nil, content, clickOkCallback, nil)
    end
    return false
  end
  return true
end
function LogicUGCCreativeWoW:ReportMapDownloadState(state)
  if state ~= PufferConst.ENUM_DownloadState.Done then
    state = PufferConst.ENUM_DownloadState.Not
  end
  local param = {}
  param[5121] = state
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  PufferMapManager:SendUserFinishDownloadMap(param)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicUGCCreativeWoW = class(CModuleBase, nil, LogicUGCCreativeWoW)
return CLogicUGCCreativeWoW