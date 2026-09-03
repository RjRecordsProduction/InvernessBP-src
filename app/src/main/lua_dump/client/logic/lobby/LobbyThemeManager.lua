local LobbyThemeManager = {}
function LobbyThemeManager:DefineAndResetData()
  log(bWriteLog and "LobbyThemeManager:DefineAndResetData")
  self.previewStatus = false
  self.previewThemeItem = nil
  self.reqPaks = {}
  self.downloadItem = nil
  self.bInXMission = false
  self.bTips = false
  self.LoadingSkinQueue = {
    now = 0,
    loading = 0,
    wait = 0
  }
  self.sequencePlayer = nil
  self.sequenceActor = nil
  self.SpecialThemeEffect = {
    XMissionSceneSkinID = 10099,
    EgyptThemeSkinId = 10034,
    EgyptForeverThemeSkinId = 10035,
    G_EgyptActorPlayIdle = false,
    EgyptActor = nil
  }
  self.bShowingGarageType = nil
  self.bShowingGarageEffect = nil
  self.ShowingGarageSkinID = nil
  self.bGMShowTLobbyScene = false
  self.LoopSeqTimer = nil
end
function LobbyThemeManager:OnDestroy()
  log(bWriteLog and "LobbyThemeManager:OnDestroy")
end
function LobbyThemeManager:SetGMShowTLobbyScene(bShow)
  self.bGMShowTLobbyScene = bShow
end
function LobbyThemeManager:_RecordDownloadPaks(itemID)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local paks = PufferODPakManager:GetPakNamesByItemID(itemID)
  self.reqPaks = {}
  for pakName, _ in pairs(paks) do
    if PufferODPakManager:GetStateByPakName(pakName) ~= PufferConst.ENUM_DownloadState.Done then
      self.reqPaks[pakName] = true
    end
  end
end
function LobbyThemeManager:_OnDownloadDataInitSucEvent()
  self:ShowTheme(self.bTips)
end
function LobbyThemeManager:_OnDownloadFinish(_, _, eventData)
  if not eventData or eventData.errorCode ~= 0 then
    log(bWriteLog and "LobbyThemeManager:_OnDownloadFinish error")
    return
  end
  local pakName = eventData.pakName or ""
  if self.reqPaks[pakName] then
    self.reqPaks[pakName] = nil
  else
    return
  end
  if next(self.reqPaks) then
    return
  end
  log(bWriteLog and string.format("LobbyThemeManager:_OnDownloadFinish pakName=%s, previewStatus=%s, previewThemeItem=%s, downloadItem=%s", tostring(pakName), tostring(self.previewStatus), tostring(self.previewThemeItem), tostring(self.downloadItem)))
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbyTheme_DownloadFinish)
  if not self.downloadItem then
    log(bWriteLog and "LobbyThemeManager:_OnDownloadFinish not downloadItem")
    return
  end
  if self.previewStatus then
    self:BeginPreviewTheme(self.previewThemeItem, true)
  else
    local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
    self:ShowThemeByItemID(self.downloadItem)
    HallThemeUtils.ShowThemeVehicle()
  end
end
function LobbyThemeManager:_HandleSwitchLobbySkin(bSwitchCamera)
  if self.LoadingSkinQueue.loading ~= 0 then
    log(bWriteLog and "LobbyThemeManager:_HandleSwitchLobbySkin loading " .. tostring(self.LoadingSkinQueue.loading))
    return
  end
  self.LoadingSkinQueue.loading = self.LoadingSkinQueue.wait
  self.LoadingSkinQueue.wait = 0
  self:_BeginLoadingSkin(bSwitchCamera)
end
function LobbyThemeManager:_BeginLoadingSkin(bSwitchCamera)
  log(bWriteLog and string.format("LobbyThemeManager:_BeginLoadingSkin 1 now = %d, loading = %d", self.LoadingSkinQueue.now, self.LoadingSkinQueue.loading))
  if self.LoadingSkinQueue.loading <= 0 then
    log(bWriteLog and string.format("LobbyThemeManager:_BeginLoadingSkin return now = %d, loading = %d", self.LoadingSkinQueue.now, self.LoadingSkinQueue.loading))
    return
  end
  local _now = self.LoadingSkinQueue.now
  self:DestroySequenceAndInteractive()
  if 0 < _now then
    local nowSkinCfg = CDataTable.GetTableData("LobbySceneSkinTable", _now)
    if nowSkinCfg and nowSkinCfg.SkinStreamLevelName then
      LobbySceneManager.LoadStreamLevel(false, nowSkinCfg.SkinStreamLevelName)
      if nowSkinCfg.SkinStreamLevelName == "Lobby_CarShowRoom_310" or nowSkinCfg.SkinStreamLevelName == "Lobby_CarShowRoom_New" then
        self.bShowingGarageEffect = nil
        self.bShowingGarageType = nil
      end
    end
  end
  log(bWriteLog and string.format("LobbyThemeManager:_BeginLoadingSkin 2 now = %d, loading = %d", self.LoadingSkinQueue.now, self.LoadingSkinQueue.loading))
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local CameraIndex
  if bSwitchCamera then
    CameraIndex = Lobby_camera_manager_module.Enum_CameraID.Lobby_Team
  end
  if self.LoadingSkinQueue.loading > 0 then
    local _loading = self.LoadingSkinQueue.loading
    local loadingSkinCfg = CDataTable.GetTableData("LobbySceneSkinTable", self.LoadingSkinQueue.loading)
    if loadingSkinCfg and loadingSkinCfg.SkinStreamLevelName then
      local LightLevel
      if bSwitchCamera and CameraIndex or LobbySceneManager.IsMainLobbyCameraID(Lobby_camera_manager_module:GetCurrentCameraID()) then
        LightLevel = "Lobby_Light"
        if loadingSkinCfg.LightLevel ~= "" then
          LightLevel = loadingSkinCfg.LightLevel
        end
      end
      LobbySceneManager.LoadStreamLevel(true, loadingSkinCfg.SkinStreamLevelName, CameraIndex, LightLevel, {
        Callback = function()
          self.LoadingSkinQueue.now = self.LoadingSkinQueue.loading
          log(bWriteLog and string.format("LobbyThemeManager:_BeginLoadingSkin 3 now = %d, prenow = %d", self.LoadingSkinQueue.now, _now))
          EventSystem:postEvent(EVENTTYPE_LOBBY_SKIN, EVENTID_LOBBY_SKIN_LOADED)
          self:_FinishLoadingSkin()
        end
      })
    end
  end
end
function LobbyThemeManager:_FinishLoadingSkin()
  log(bWriteLog and "LobbyThemeManager:_FinishLoadingSkin")
  self.LoadingSkinQueue.loading = 0
  if self.LoadingSkinQueue.wait ~= 0 then
    self:_HandleSwitchLobbySkin()
    return
  end
  self:DestroySequenceAndInteractive()
  self:ShowGarageEffect(false, -1)
  self:PlayLevelSequence()
  local LobbyThemeInteractiveManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeInteractiveManager)
  LobbyThemeInteractiveManager:CreateInteractive(self.sequencePlayer)
  local LobbyThemeParallaxManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeParallaxManager)
  LobbyThemeParallaxManager:StartParallax()
  EventSystem:postEvent(EVENTTYPE_LOBBY_SKIN, EVENTID_LOBBY_SKIN_CHANGE, self.LoadingSkinQueue.now)
end
function LobbyThemeManager:_ShowEgyptActor()
  log(bWriteLog and "LobbyThemeManager:_ShowEgyptActor")
  if slua.isValid(self.SpecialThemeEffect.EgyptActor) then
    return
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local DeviceLevel = GameInstance:GetDeviceLevel()
  if 0 < DeviceLevel then
    local world = slua_GameFrontendHUD:GetWorld()
    local showActorClass = import("/Game/Arts_Scenes/Lobby/LobbyTheme/Lobby_Egypt_02/Egypt/Egypt_LobbyActor.Egypt_LobbyActor_C")
    local Loc = FVector(2578.0, -1816, 48.8)
    local rot = FRotator(0, 0, 0)
    self.SpecialThemeEffect.EgyptActor = world:SpawnActor(showActorClass, Loc, rot, nil)
  end
end
function LobbyThemeManager:_HideEgyptActor()
  if slua.isValid(self.SpecialThemeEffect.EgyptActor) then
    self.SpecialThemeEffect.EgyptActor:K2_DestroyActor()
  end
  self.SpecialThemeEffect.EgyptActor = nil
end
function LobbyThemeManager:PlayLevelSequenceByParam(SeqAsset, LoopTime, bFreezeEndFrame, bHideUI)
  if not self or not slua.isValid(SeqAsset) then
    log(bWriteLog and "LobbyThemeManager:PlayLevelSequenceByParam SeqAsset is not valid")
    return
  end
  LoopTime = LoopTime or -1
  bFreezeEndFrame = bFreezeEndFrame or false
  bHideUI = bHideUI or false
  self:CreateAndPlaySeq(SeqAsset, LoopTime, bFreezeEndFrame)
  if bHideUI then
    self:HideUIOnPlaySeq()
  end
end
function LobbyThemeManager:CreateAndPlaySeq(SeqAsset, LoopTime, bFreezeEndFrame)
  if not self or not slua.isValid(SeqAsset) then
    return
  end
  if self.sequencePlayer then
    self:DestroySequencePlayer()
  end
  local LobbyCameraFunctionLibrary = import("/Game/UMG/UI_Utility/LobbyCameraFunctionLibrary.LobbyCameraFunctionLibrary_C")
  local UIUtil = require("client.common.ui_util")
  self.sequencePlayer, self.sequenceActor = LobbyCameraFunctionLibrary.CreateLevelSequencePlayerAndActor(SeqAsset, UIUtil.GetGameInstance())
  if self.sequencePlayer then
    self.sequencePlayer.FreezeEndFrame = bFreezeEndFrame
    self.sequencePlayer:PlayLooping(LoopTime)
    local LobbyThemeInteractiveManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeInteractiveManager)
    LobbyThemeInteractiveManager:UpdateSequencePlayer(self.sequencePlayer)
  end
end
function LobbyThemeManager:HideUIOnPlaySeq()
  local UIs = {
    UIManager.UI_Config.team_main,
    UIManager.UI_Config.Lobby_Main_UIBP
  }
  local UIStates = {}
  if not self.sequencePlayer then
    return
  end
  local SeqDuration = self.sequencePlayer:GetLength()
  if tonumber(SeqDuration) > 0 then
    for k, UIName in pairs(UIs) do
      local UI = UIManager.GetUI(UIName)
      if UI then
        UIStates[UI] = UI:GetVisibility()
        UI:Hide()
      end
    end
    self:AddTimerOnce(SeqDuration, function()
      for k, UIName in pairs(UIs) do
        local UI = UIManager.GetUI(UIName)
        if UI and UIStates[UI] and UEnums.ESlateVisibility.Hidden == UI:GetVisibility() then
          UI:SetWidgetVisibility(UIStates[UI])
        end
      end
    end)
  end
end
function LobbyThemeManager:PlayLevelSequence()
  if self.LoopSeqTimer then
    self:RemoveTimer(self.LoopSeqTimer)
    self.LoopSeqTimer = nil
  end
  local asset_util = require("common.asset_util")
  if self.AysncLoadAssetArrayID then
    asset_util.CancelAssetAsync(self.AysncLoadAssetArrayID)
    self.AysncLoadAssetArrayID = nil
  end
  local skinId = self:GetDisplayLobbySkin()
  log(bWriteLog and "LobbyThemeManager:PlayLevelSequence" .. tostring(skinId))
  local cfg = CDataTable.GetTableData("LobbySceneSkinTable", skinId)
  if not cfg then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local levelSequenceID = cfg.SkinStreamLevelSequence
  if cfg.SpecialSkinStreamLevelSequence ~= 0 and TimeUtil.UnixTimeStrBetween(cfg.SpecialSeqBeginTime, cfg.SpecialSeqEndTime) == 0 then
    levelSequenceID = cfg.SpecialSkinStreamLevelSequence
    log(bWriteLog and "LobbyThemeManager:PlayLevelSequence UseSpecialLevelSeq" .. tostring(levelSequenceID))
  end
  if not levelSequenceID or levelSequenceID == 0 then
    return
  end
  local LobbyLevelSequence = CDataTable.GetTableData("LobbyLevelSequence", levelSequenceID)
  if not (LobbyLevelSequence and LobbyLevelSequence.BluePrintPath) or LobbyLevelSequence.BluePrintPath == "" then
    return
  end
  local loopTime = LobbyLevelSequence.PlayTime - 1
  local bFreezeEndFrame = LobbyLevelSequence.FreezeEndFrame == 1
  local bHideUI = LobbyLevelSequence.HideUI == 1
  local AssetPathArray = {
    LobbyLevelSequence.BluePrintPath
  }
  if LobbyLevelSequence.LoopSeqBpPath and LobbyLevelSequence.LoopSeqBpPath ~= "" then
    table.insert(AssetPathArray, LobbyLevelSequence.LoopSeqBpPath)
  end
  self.AysncLoadAssetArrayID = asset_util.GetAssetsArrayAsyncParallel(AssetPathArray, function()
    self.AysncLoadAssetArrayID = nil
    if skinId ~= self:GetDisplayLobbySkin() then
      log(bWriteLog and "LobbyThemeManager:PlayLevelSequence skin has changed")
      return
    end
    local BusinessHelper = import("BusinessHelper")
    if AssetPathArray[1] then
      local SeqAsset = BusinessHelper.LoadAssetFromPath(AssetPathArray[1])
      if SeqAsset then
        self:PlayLevelSequenceByParam(SeqAsset, loopTime, bFreezeEndFrame, bHideUI)
      end
    end
    if AssetPathArray[2] and self.sequencePlayer and self.sequencePlayer:GetLength() then
      local DelayTime = self.sequencePlayer:GetLength() - 0.1
      self.LoopSeqTimer = self:AddTimerOnce(DelayTime, function()
        self.LoopSeqTimer = nil
        if skinId ~= self:GetDisplayLobbySkin() then
          log(bWriteLog and "LobbyThemeManager:PlayLevelSequence skin has changed")
          return
        end
        local LoopSeqAsset = BusinessHelper.LoadAssetFromPath(AssetPathArray[2])
        if LoopSeqAsset then
          self:PlayLevelSequenceByParam(LoopSeqAsset, -1, bFreezeEndFrame, false)
        end
      end)
    end
  end)
end
function LobbyThemeManager:ShowThemeEffect(skinId)
  if skinId == self.SpecialThemeEffect.EgyptThemeSkinId or skinId == self.SpecialThemeEffect.EgyptForeverThemeSkinId then
    log(bWriteLog and "LobbyThemeManager:ShowThemeEffect is EgyptThemeSkinId")
    self:AddTimerOnce(0, function()
      self:_ShowEgyptActor()
      self.SpecialThemeEffect.G_EgyptActorPlayIdle = true
    end)
  else
    self:_HideEgyptActor()
    self.SpecialThemeEffect.G_EgyptActorPlayIdle = false
  end
end
function LobbyThemeManager:GetDisplayLobbySkin()
  return self.LoadingSkinQueue.now
end
function LobbyThemeManager:GetDisplayLobbySkinName()
  local SkinID = self:GetDisplayLobbySkin()
  local SkinCfg = CDataTable.GetTableData("LobbySceneSkinTable", SkinID)
  if SkinCfg then
    return SkinCfg.SkinStreamLevelName
  else
    return nil
  end
end
function LobbyThemeManager:GetDisplayItemID()
  local ItemID = self:GetThemeItemIdBySkinId(self.LoadingSkinQueue.now)
  return ItemID
end
function LobbyThemeManager:GetLobbyLightBySkinID(SkinID)
  local loadingSkinCfg = CDataTable.GetTableData("LobbySceneSkinTable", SkinID)
  if loadingSkinCfg then
    return loadingSkinCfg.LightLevel
  else
    return nil
  end
end
function LobbyThemeManager:ShowThemeByItemID(itemID)
  local skinId = self:GetThemeSkinIdByItemId(itemID)
  if skinId == 0 then
    return
  end
  if self.bInXMission then
    log(bWriteLog and "LobbyThemeManager:ShowThemeByItemID bInXMission")
    return
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  log(bWriteLog and "LobbyThemeManager:ShowThemeByItemID skinId = " .. skinId)
  self:SwitchLobbySkin(skinId)
  self:ShowThemeEffect(skinId)
  if self.bTips then
    log(bWriteLog and "LobbyThemeManager:ShowThemeByItemID")
    local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
    local leaderItem = HallThemeUtils.GetTeamLeaderThemItemId()
    if leaderItem == 0 then
      leaderItem = HallThemeUtils.GetDefaultThemeItemID()
    end
    local selfItem = HallThemeUtils.homeThemeItemId
    if selfItem == 0 then
      selfItem = HallThemeUtils.GetDefaultThemeItemID()
    end
    log(bWriteLog and string.format("LobbyThemeManager:ShowThemeByItemID leader = %d, self = %d", leaderItem, selfItem))
    if selfItem ~= leaderItem then
      ShowNotice(44111)
    end
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY_THEME, EVENTID_LOBBY_THEME_CHANGE)
end
function LobbyThemeManager:GetThemeSkinIdByItemId(itemId)
  local cfg = CDataTable.GetTableData("HallThemeItem", itemId)
  if cfg then
    return tonumber(cfg.skinId)
  end
  return 0
end
function LobbyThemeManager:GetThemeItemIdBySkinId(SkinId)
  local cfg = CDataTable.GetTableDataByFilter("HallThemeItem", "skinId", tostring(SkinId))
  if cfg then
    return tonumber(cfg.itemId)
  end
  return 0
end
function LobbyThemeManager:OnInitialize()
end
function LobbyThemeManager:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_DOWNLOAD_DATA_INIT_SUC, self._OnDownloadDataInitSucEvent, self)
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH, self._OnDownloadFinish, self)
end
function LobbyThemeManager:OnLogin(bReLogin)
end
function LobbyThemeManager:OnLogOut()
end
function LobbyThemeManager:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and string.format("LobbyThemeManager:OnPreSwitchGameStatus preState:%s, nextState:%s, now = %d, loading = %d, wait = %d", preState, nextState, self.LoadingSkinQueue.now, self.LoadingSkinQueue.loading, self.LoadingSkinQueue.wait))
  self.LoadingSkinQueue.now = 0
  self.LoadingSkinQueue.loading = 0
  self.LoadingSkinQueue.wait = 0
  self.previewThemeItem = nil
  self.downloadItem = nil
  self.bShowingGarageEffect = nil
end
function LobbyThemeManager:ShowTheme(bTips)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if not login_module.bIsInitLogin then
    log(bWriteLog and "LobbyThemeManager:ShowTheme not login")
    return
  end
  self.bTips = bTips or false
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  if self.previewStatus then
    return
  end
  local itemID = HallThemeUtils.GetCurShowThemeItemId()
  if not itemID or itemID == 0 then
    log(bWriteLog and "LobbyThemeManager:ShowTheme itemID not found!")
    itemID = self:GetDefaultThemeItemID()
  end
  local bDownloaded = false
  local loadingSkinCfg = CDataTable.GetTableData("HallThemeItem", itemID)
  if loadingSkinCfg then
    local lobby_scene_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.lobby_scene_module)
    local LevelPath = lobby_scene_module:GetStreamLevelFullPathByName(loadingSkinCfg.skinLevelName)
    local pak_util = require("client.common.pak_util")
    bDownloaded = pak_util.IsRelatedPakExistByItemID(itemID) and pak_util.IsMapExist(LevelPath)
  end
  self.reqPaks = {}
  self.downloadItem = nil
  local FBI = require("client.slua.logic.fbi.logic_fbi")
  local bIsIllegalTime = FBI.IsIllegalTime(itemID)
  if bIsIllegalTime then
    log(bWriteLog and "LobbyThemeManager:ShowTheme illegal time, itemID = " .. itemID)
    self:ShowThemeByItemID(self:GetDefaultThemeItemID())
    return
  elseif not bDownloaded then
    if PufferDownloader.InitSuccess then
      self:_RecordDownloadPaks(itemID)
      self.downloadItem = itemID
      local logic_lobby = require("client.logic.login.logic_lobby")
      local Enum_LobbyDownloadResType = logic_lobby.Enum_LobbyDownloadResType
      EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_UPDATE_LOBBY_THEME_RES_DOWNLOAD_UI, {itemID})
      local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
      local nUId = TeamUpNewSystem.GetTeamLeader() or DataMgr.roleData.uid
      EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_UPDATE_LOBBY_TEAM_RES_DOWNLOAD_UI, nUId, Enum_LobbyDownloadResType.Theme, {itemID})
    end
    self:ShowThemeByItemID(self:GetDefaultThemeItemID())
    return
  else
    log(bWriteLog and "LobbyThemeManager:ShowTheme download finish, itemID = " .. itemID)
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_UPDATE_LOBBY_THEME_RES_DOWNLOAD_UI)
  end
  self:ShowThemeByItemID(itemID)
end
function LobbyThemeManager:BeginPreviewTheme(itemID, bNotDownload, bKeepShowAvatar)
  log(bWriteLog and string.format("LobbyThemeManager:BeginPreviewTheme itemID:%s,previewThemeItem:%s,previewStatus:%s", tostring(itemID), tostring(self.previewThemeItem), tostring(self.previewStatus)))
  self.previewStatus = true
  self.previewThemeItem = itemID
  self.  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local ThemeVehicleManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ThemeVehicleManager)
  ThemeVehicleManager:DestoryAllThemeVehicles()
  HallThemeUtils.HideHallThemeWingman()
  if not bKeepShowAvatar then
    local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
    TeamAvatarManager.HideAllAvatar()
  end
  self:ShowThemeEffect(0)
  EventSystem:postEvent(EVENTTYPE_LOBBY_THEME, EVENTID_LOBBY_THEME_PREVIEW)
  local cfg = CDataTable.GetTableData("HallThemeItem", itemID)
  if cfg == nil then
    return
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local downloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {itemID})
  self.reqPaks = {}
  self.downloadItem = nil
  if downloadState ~= ENUM_DownloadState.Done then
    if not bNotDownload then
      self:_RecordDownloadPaks(itemID)
      self.downloadItem = itemID
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {itemID})
      log(bWriteLog and "LobbyThemeManager:BeginPreviewTheme Download itemID = " .. tostring(itemID))
    end
    return
  end
  log(bWriteLog and "LobbyThemeManager:BeginPreviewTheme SkinId = " .. cfg.skinId)
  self:SwitchLobbySkin(cfg.skinId, true)
end
function LobbyThemeManager:EndPreviewTheme()
  if not self.previewStatus then
    return
  end
  log(bWriteLog and "LobbyThemeManager:EndPreviewTheme")
  self.previewStatus = false
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  self:ShowTheme()
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  HallThemeUtils.ShowThemeVehicle()
  if not self.bKeepShowAvatar then
    TeamAvatarManager.ShowAllAvatar()
  end
  TeamAvatarManager.UpdateAvatarPosition()
  self.bKeepShowAvatar = nil
end
function LobbyThemeManager:UnloadPreviewTheme(skinId)
  if not skinId or skinId <= 0 then
    return
  end
  local skinCfg = CDataTable.GetTableData("LobbySceneSkinTable", skinId)
  if not (skinCfg and skinCfg.SkinStreamLevelName) or skinCfg.SkinStreamLevelName == "" then
    return
  end
  local LobbySceneModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.lobby_scene_module)
  LobbySceneModule:UnloadStreamLevel(skinCfg.SkinStreamLevelName)
end
function LobbyThemeManager:QuitPrePreviewTheme()
  if not self.previewStatus or not self.LoadingSkinQueue then
    return
  end
  log(bWriteLog and string.format("LobbyThemeManager:QuitPrePreviewTheme now = %d, loading = %d, wait = %d", self.LoadingSkinQueue.now, self.LoadingSkinQueue.loading, self.LoadingSkinQueue.wait))
  self.LoadingSkinQueue.wait = 0
  if self.LoadingSkinQueue.now and self.LoadingSkinQueue.now > 0 then
    self:UnloadPreviewTheme(self.LoadingSkinQueue.now)
    self.LoadingSkinQueue.now = 0
  end
  if self.LoadingSkinQueue.loading and self.LoadingSkinQueue.loading > 0 then
    self:UnloadPreviewTheme(self.LoadingSkinQueue.loading)
    self.LoadingSkinQueue.loading = 0
  end
end
function LobbyThemeManager:IsPreviewTheme()
  return self.previewStatus
end
function LobbyThemeManager:EnterXMission()
  log(bWriteLog and "LobbyThemeManager:EnterXMission")
  self.bInXMission = true
  self:SwitchLobbySkin(self.SpecialThemeEffect.XMissionSceneSkinID)
  self:ShowThemeEffect(0)
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  HallThemeUtils.HideHallThemeWingman()
  local ThemeVehicleManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ThemeVehicleManager)
  ThemeVehicleManager:DestoryAllThemeVehicles()
end
function LobbyThemeManager:ExitXMission()
  log(bWriteLog and "LobbyThemeManager:ExitXMission")
  self.bInXMission = false
end
function LobbyThemeManager:SwitchLobbySkin(skinId, bSwitchCamera)
  local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
  if not self.bGMShowTLobbyScene and IsEditor and skinId == xMission_macro.TLobbySceneID then
    skinId = 10040
  end
  log(bWriteLog and "LobbyThemeManager:SwitchLobbySkin " .. tostring(skinId))
  skinId = tonumber(skinId)
  local Utility = require("common.utility")
  local GameAutotest = Utility.GetGameInstanceSubsystemByName("AutoTestSubsystem")
  if slua.isValid(GameAutotest) and GameAutotest:IsUIAutoTest() then
    skinId = self:GetDefaultLobbySkin()
  end
  local skinCfg = CDataTable.GetTableData("LobbySceneSkinTable", skinId)
  if not skinCfg then
    log(bWriteLog and "LobbyThemeManager:SwitchLobbySkin not found")
    return
  end
  if skinId == self.LoadingSkinQueue.loading then
    log(bWriteLog and "LobbyThemeManager:SwitchLobbySkin same")
    return
  end
  if self.LoadingSkinQueue.loading == 0 and skinId == self.LoadingSkinQueue.now then
    log(bWriteLog and "LobbyThemeManager:SwitchLobbySkin same callback")
    local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
    if bSwitchCamera then
      Lobby_camera_manager_module:SwitchCamera(Lobby_camera_manager_module.Enum_CameraID.Lobby_Wardrobe, self.BlendTime)
    end
    return
  end
  self.LoadingSkinQueue.wait = skinId
  self:DestroySequenceAndInteractive()
  self:_HandleSwitchLobbySkin(bSwitchCamera)
end
function LobbyThemeManager:GetDefaultLobbySkin()
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  return HallThemeUtils.GetDefaultLobbySkin()
end
function LobbyThemeManager:GetDefaultThemeItemID()
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  return HallThemeUtils.GetDefaultThemeItemID()
end
function LobbyThemeManager:ShowGarageEffect(bShow, VehicleType, bForce)
  log(bWriteLog and "LobbyThemeManager:ShowGarageEffect bShow:" .. tostring(bShow) .. " VehicleType:" .. tostring(VehicleType) .. " old bShowingGarageEffect:" .. tostring(self.bShowingGarageEffect) .. " bShowingGarageType:" .. tostring(self.bShowingGarageType))
  local LatestSkinID = self:GetDisplayLobbySkin()
  if self.bShowingGarageEffect == bShow and self.bShowingGarageType == VehicleType and LatestSkinID == self.ShowingGarageSkinID and not bForce then
    log(bWriteLog and "LobbyThemeManager:ShowGarageEffect Same bShow")
    return
  end
  local GarageThemeSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GarageThemeSystem)
  if not GarageThemeSystem:IsGarageSkinID(self:GetDisplayLobbySkin()) then
    log(bWriteLog and "LobbyThemeManager:ShowGarageEffect not IsGarageSkinID")
    return
  end
  local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
  local DefaultActors = ActorTools.GetAllActorsByTag(CGameWorld, "StaticMeshActor", "GarageEffectDefault")
  if not DefaultActors or DefaultActors:Num() <= 0 then
    log(bWriteLog and "LobbyThemeManager:ShowGarageEffect DefaultActors Is Not Valid")
    return
  end
  self.bShowingGarageType = VehicleType
  self.bShowingGarageEffect = bShow
  self.ShowingGarageSkinID = LatestSkinID
  self:DestroySequencePlayer()
  local GarageEffectActors = ActorTools.GetAllActorsByTag(CGameWorld, "Actor", "GarageEffect")
  if GarageEffectActors and GarageEffectActors:Num() > 0 then
    for key, Actor in pairs(GarageEffectActors) do
      if slua.isValid(Actor) then
        Actor:SetActorHiddenInGame(true)
      end
    end
  end
  if not (bShow and VehicleType) or VehicleType == -1 then
    for key, DefaultActor in pairs(DefaultActors) do
      if slua.isValid(DefaultActor) then
        DefaultActor:SetActorHiddenInGame(false)
      end
    end
    return
  end
  local TargetActors = ActorTools.GetAllActorsByTag(CGameWorld, "StaticMeshActor", "GarageEffect" .. tostring(VehicleType))
  if TargetActors and TargetActors:Num() > 0 then
    for key, TargetActor in pairs(TargetActors) do
      if slua.isValid(TargetActor) then
        TargetActor:SetActorHiddenInGame(false)
      end
    end
  else
    log(bWriteLog and "LobbyThemeManager:ShowGarageEffect TargetActor is not Valid")
    for key, DefaultActor in pairs(DefaultActors) do
      if slua.isValid(DefaultActor) then
        DefaultActor:SetActorHiddenInGame(false)
      end
    end
  end
  local ParticleSystemComponentClass = import("/Script/Engine.ParticleSystemComponent")
  local EmitterActors = ActorTools.GetAllActorsByTag(CGameWorld, "Emitter", "GarageEffect" .. tostring(VehicleType))
  if EmitterActors and EmitterActors:Num() > 0 then
    for key, Emitter in pairs(EmitterActors) do
      if slua.isValid(Emitter) then
        Emitter:SetActorHiddenInGame(false)
        local ParticleComp = Emitter:GetComponentByClass(ParticleSystemComponentClass)
        if slua.isValid(ParticleComp) then
          local CurrentFXAsset = ParticleComp.Template
          if CurrentFXAsset then
            ParticleComp:SetTemplate(nil)
            ParticleComp:SetTemplate(CurrentFXAsset)
            ParticleComp:Activate(true)
          end
        end
      end
    end
  end
  local ItemID = self:GetDisplayItemID()
  local SeqID = tostring(ItemID) .. "_" .. tostring(VehicleType)
  local SeqCfg = CDataTable.GetTableData("GarageThemeSeq", SeqID)
  if SeqCfg and SeqCfg.SeqPath then
    self:AsyncLoadAsset(SeqCfg.SeqPath, function(sequence)
      if ItemID ~= self:GetDisplayItemID() or self.bShowingGarageType ~= VehicleType then
        log(bWriteLog and "LobbyThemeManager:ShowGarageEffect PlaySeq out of time")
        return
      end
      log(bWriteLog and "LobbyThemeManager:ShowGarageEffect PlaySeq " .. SeqID)
      self:PlayLevelSequenceByParam(sequence, SeqCfg.LoopTime, SeqCfg.FreezeEndFrame == 1, SeqCfg.HideUI == 1)
    end)
  end
  log(bWriteLog and "LobbyThemeManager:ShowGarageEffect new self.bShowingGarageEffect:" .. tostring(self.bShowingGarageEffect) .. " self.bShowingGarageType:" .. tostring(self.bShowingGarageType))
  EventSystem:postEvent(EVENTTYPE_LOBBY_THEME, EVENTID_GARAGE_EFFECT_CHANGE, bShow, VehicleType)
end
function LobbyThemeManager:GetCurrentGarageEffectType()
  if self.bShowingGarageEffect == false then
    return -1
  end
  return self.bShowingGarageType
end
function LobbyThemeManager:DestroySequencePlayer()
  log(bWriteLog and "LobbyThemeManager:DestroySequencePlayer")
  local LobbyThemeInteractiveManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeInteractiveManager)
  LobbyThemeInteractiveManager:RemoveChangeRateTimer()
  if not self.sequencePlayer or slua.isValid(self.sequencePlayer) then
  end
  self.sequencePlayer = nil
  LobbyThemeInteractiveManager:UpdateSequencePlayer(self.sequencePlayer)
  if self.sequenceActor and slua.isValid(self.sequenceActor) then
    self.sequenceActor:K2_DestroyActor()
  end
  self.sequenceActor = nil
end
function LobbyThemeManager:DestroySequenceAndInteractive()
  log(bWriteLog and "LobbyThemeManager:DestroySequenceAndInteractive")
  self:DestroySequencePlayer()
  local LobbyThemeInteractiveManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeInteractiveManager)
  LobbyThemeInteractiveManager:DestroyInteractiveSequencePlayer()
  LobbyThemeInteractiveManager:DestroyInteractive()
end
function LobbyThemeManager:IsPreviewStatus()
  return self.previewStatus
end
function LobbyThemeManager:ClearDownloadItem()
  log(bWriteLog and "LobbyThemeManager:ClearDownloadItem")
  self.downloadItem = nil
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLobbyThemeManager = class(CModuleBase, nil, LobbyThemeManager)
return CLobbyThemeManager