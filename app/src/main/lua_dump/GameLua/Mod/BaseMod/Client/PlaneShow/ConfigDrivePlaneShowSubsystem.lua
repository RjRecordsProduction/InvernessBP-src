local ConfigDrivePlaneShowSubsystem = {}
local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
local TableUtil = require("common.table_util")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameplayStatics = import("GameplayStatics")
local utility = require("common.utility")
local UKismetMathLibrary = import("KismetMathLibrary")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local UAESequenceUtils = require("GameLua.Mod.BaseMod.GamePlay.SequenceMgr.UAESequenceUtils")
function ConfigDrivePlaneShowSubsystem:ctor()
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:ctor()")
  self.OnPlaneDelegate = nil
  self.PlaneShowActor = nil
  self.RealPlaneActor = nil
  self.ShowConfig = nil
  self.StateConfig = nil
  self.StateID = -1
  self.TotalTime = 0
  self.LevelSequenceActor = nil
  self.EventTable = {}
end
function ConfigDrivePlaneShowSubsystem:OnInit()
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:OnInit")
  if Client then
    self:InitConfig()
    self:PostInitConfig()
  else
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "ReadyState"
    }, function()
      self:InitConfig()
      self:PostInitConfig()
    end)
  end
end
function ConfigDrivePlaneShowSubsystem:PostInitConfig()
  if not self.ShowConfig or not self:IsPlaneShowEnable(self.ShowConfig) then
    self.TotalTime = 0
    print(bWriteLog and "ConfigDrivePlaneShowSubsystem:PostInitConfig  IsPlaneShowEnable == false, return!!!")
    return
  end
  local CurrentTime = CGameState:GetServerWorldTimeSeconds()
  if CurrentTime and 100 < CurrentTime then
    print(bWriteLog and "ConfigDrivePlaneShowSubsystem:PostInitConfig  CurrentTime > 100, return!!!")
    return
  end
  self:RegistEvents()
  self:PreReadyForNextState(1)
  if not Client then
    local AliasDataUtil = require("GameLua.Activity.Commercialize.GamePlay.Alias.AliasDataUtil")
    AliasDataUtil:ClearBroadcastAliasCache()
  end
end
function ConfigDrivePlaneShowSubsystem:OnRelease()
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:OnRelease()")
  self:EndShow()
  ConfigDrivePlaneShowSubsystem.__super.OnRelease(self)
end
function ConfigDrivePlaneShowSubsystem:RegistEvents()
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:RegistEvents")
  if Client then
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANE_CREATE, self.StartShow, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_TEAM_SHOW_END, self.TeamShowEnd, self)
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANESHOW_CHANGE_STATIC, self.ChangeStaticShowFlyingInfo, self)
  else
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANE_CREATE, self.DSCheckSkyTransition, self)
  end
  self.HaveRegistEvent = true
end
function ConfigDrivePlaneShowSubsystem:HandleEnterGameModeReadyState()
  self:InitConfig()
end
function ConfigDrivePlaneShowSubsystem:DSCheckSkyTransition()
  local Config = self.StateConfig[1]
  if not Config.WeatherID or not Config.WeatherDuration then
    return
  end
  local PlayerCharacters = GameplayData.GetAllPlayerCharacters()
  for _, PlayerCharacter in pairs(PlayerCharacters) do
    PlayerCharacter.SkyTransition:SetStateActive(Config.WeatherID, true)
  end
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:PlaneActorSequenceShowBegin Change Weather")
  if Config.WeatherDuration <= 0 then
    return
  end
  self:AddGameTimer(Config.WeatherDuration, false, function()
    print(bWriteLog and "ConfigDrivePlaneShowSubsystem:PlaneActorSequenceShowBegin Reset Weather")
    local PlayerCharacters = GameplayData.GetAllPlayerCharacters()
    for _, PlayerCharacter in pairs(PlayerCharacters) do
      PlayerCharacter.SkyTransition:SetStateActive(Config.WeatherID, false)
    end
  end)
end
function ConfigDrivePlaneShowSubsystem:OnUnRegistEvents()
  ConfigDrivePlaneShowSubsystem.__super.OnUnRegistEvents(self)
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:OnUnRegistEvents")
  if self.HaveRegistEvent then
    self:RemoveCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANE_CREATE)
    self:RemoveCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED_EX)
  end
  self.HaveRegistEvent = false
end
function ConfigDrivePlaneShowSubsystem:InitConfig()
  local curLevelName = GameplayStatics.GetCurrentLevelName(slua.getGameInstance(), true)
  local PlaneShowConfig = GamePlayTools.GetCurrentConfig("PlaneShowConfig")
  if not PlaneShowConfig or not PlaneShowConfig.Default then
    print(bWriteLog and "ConfigDrivePlaneShowSubsystem:InitShowOnStart Error Config!!!")
    return
  end
  local TempShowConfig = TableUtil.DeepCloneTable(PlaneShowConfig.Default)
  if PlaneShowConfig[curLevelName] then
    TableUtil.OverrideTable(TempShowConfig, PlaneShowConfig[curLevelName])
  end
  local NeedUseSimpleDefault = false
  if slua_GameFrontendHUD then
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(uPlayerController) and uPlayerController.IsSpectatorOrDemoPlayer and uPlayerController:IsSpectatorOrDemoPlayer() then
      print(bWriteLog and "ConfigDrivePlaneShowSubsystem:IsPlaneShowEnable: IsSpectator")
      NeedUseSimpleDefault = true
    end
  end
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModType, ModeType2 = GameMainConfig.GetModType()
  if ModeType2 == "" then
    ModeType2 = GameMainConfig.GetMapType()
  end
  local ModeID = GameMainConfig.GetModeID()
  if TempShowConfig.SimpleModeID then
    for _, DisModeID in pairs(TempShowConfig.SimpleModeID) do
      if DisModeID == ModeID then
        NeedUseSimpleDefault = true
        break
      end
    end
  end
  if not NeedUseSimpleDefault and Client then
    print(bWriteLog and "ConfigDrivePlaneShowSubsystem:InitShowOnStart Check pak download")
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {
      TempShowConfig.CheckPakDownLoadPath
    })
    if state ~= PufferConst.ENUM_DownloadState.Done then
      NeedUseSimpleDefault = true
      print(bWriteLog and "ConfigDrivePlaneShowSubsystem:InitShowOnStart pak notdownload")
    end
  end
  if NeedUseSimpleDefault then
    TableUtil.OverrideTable(TempShowConfig, PlaneShowConfig.DefaultSimple)
    TempShowConfig.EnableSwitchUI = PlaneShowConfig.DefaultSimple.EnableSwitchUI
  end
  if CGameState and CGameState.RevisePlaneShowConfig then
    CGameState:RevisePlaneShowConfig(TempShowConfig)
  end
  self.ShowConfig = TempShowConfig
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:InitShowOnStart curLevelName:", curLevelName, " self.ShowConfig:", self.ShowConfig)
  self.StateConfig = TempShowConfig and TempShowConfig.StateConfig
  for _, StateCon in pairs(self.StateConfig) do
    if StateCon and StateCon.StateTime then
      self.TotalTime = self.TotalTime + StateCon.StateTime
    end
  end
end
function ConfigDrivePlaneShowSubsystem:IsPlaneShowEnable(EnableConfig)
  if not EnableConfig or not EnableConfig.StateConfig then
    print(bWriteLog and "ConfigDrivePlaneShowSubsystem:IsPlaneShowEnable return EnableConfig:", EnableConfig)
    return false
  end
  local MapEnable = false
  local ModeEnable = false
  if EnableConfig and EnableConfig.EnableShow == true then
    MapEnable = true
    print(bWriteLog and "ConfigDrivePlaneShowSubsystem:IsPlaneShowEnable MapEnable:", MapEnable)
  end
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModType, ModeType2 = GameMainConfig.GetModType()
  if ModeType2 == "" then
    ModeType2 = GameMainConfig.GetMapType()
  end
  local ModeID = GameMainConfig.GetModeID()
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:IsPlaneShowEnable ModType:", ModType, " ModeType2:", ModeType2, " ModeID:", ModeID)
  if ModeType2 and EnableConfig.EnableMode and EnableConfig.EnableSubMode then
    for _, MainMode in pairs(EnableConfig.EnableMode) do
      if ModType == MainMode then
        ModeEnable = true
        print(bWriteLog and "ConfigDrivePlaneShowSubsystem:IsPlaneShowEnable Enable by Mode ModType:", ModType)
      end
    end
    for _, TempSubMode in pairs(EnableConfig.EnableSubMode) do
      if ModeType2 == TempSubMode then
        print(bWriteLog and "ConfigDrivePlaneShowSubsystem:IsPlaneShowEnable Enable by SubMode ModeType2:", ModeType2)
        ModeEnable = true
      end
    end
    if EnableConfig.DisableModeID and ModeEnable then
      for _, DisModeID in pairs(EnableConfig.DisableModeID) do
        if DisModeID == ModeID then
          ModeEnable = false
          break
        end
      end
    end
  end
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:IsPlaneShowEnable MapEnable:", MapEnable, " ModeEnable:", ModeEnable)
  if Client and Client.IsWindowsClientReplay() then
    return false
  end
  return MapEnable and ModeEnable
end
function ConfigDrivePlaneShowSubsystem:StartShow()
  if not self.ShowConfig or not self.ShowConfig then
    print(bWriteLog and "ConfigDrivePlaneShowSubsystem:StartShow Return Check 1")
    return
  end
  local PlaneActor = ActorTools.GetOneActor(slua.getGameInstance(), self.ShowConfig.PlaneActorClassPath)
  if not slua.isValid(PlaneActor) then
    print(bWriteLog and "ConfigDrivePlaneShowSubsystem:StartShow Return Check 2")
    return
  end
  if self.StateID > 0 then
    print(bWriteLog and "ConfigDrivePlaneShowSubsystem:StartShow Return Check StateID>0 3")
    return
  end
  self.Real  local StateIDByDSTime, StateInnerTime = self:GetStateIDAndTime()
  if StateInnerTime < 0 then
    print(bWriteLog and "ConfigDrivePlaneShowSubsystem:StartShow StateInnerTime < 0 Set to 0:", StateInnerTime)
    StateInnerTime = 0
  end
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:StartShow StateIDByDSTime, StateInnerTime:", StateIDByDSTime, " ", StateInnerTime)
  if 0 < StateIDByDSTime then
    self:StartState(StateIDByDSTime, StateInnerTime)
  else
    print(bWriteLog and "ConfigDrivePlaneShowSubsystem:StartShow InValid StateIDByDSTime return")
    return
  end
  if self.StateID == -1 or not self.ShowConfig then
    print(bWriteLog and "ConfigDrivePlaneShowSubsystem:StartShow return!!! not self.ShowConfig or self.StateID == -1 right after StartState")
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    uPlayerController:SetDisableTouchMoveInput(true)
    uPlayerController:ShowTouchInterface(false)
  end
  UAESequenceUtils:HideAllUI()
  if self.ShowConfig.EnableSwitchUI and slua.isValid(self.PlaneShowActor) then
    self.PlaneShowActor:ShowUIPanel()
  end
  self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED_EX, self.OnApplicationReactived, self)
end
function ConfigDrivePlaneShowSubsystem:EndShow()
  if self.StateID == -1 then
    print(bWriteLog and "ConfigDrivePlaneShowSubsystem:EndShow self.StateID == -1 so Return ")
    return
  end
  if self.ShowConfig.EnableSwitchUI and slua.isValid(self.PlaneShowActor) then
    self.PlaneShowActor:UnloadUI()
  end
  local CurrentStateConfig = self.StateConfig[self.StateID]
  local StateName = CurrentStateConfig and CurrentStateConfig.Name
  if StateName and StateName ~= "FinishPlaneShow" then
    local StateEnd = StateName .. "End"
    local EndFunc = self[StateEnd]
    if EndFunc and type(EndFunc) == "function" then
      print(bWriteLog and "ConfigDrivePlaneShowSubsystem:EndShow call StateEnd:", StateEnd)
      xpcall(EndFunc, utility.ErrorMessageHandler, self, CurrentStateConfig)
    end
  end
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:EndShow")
  self.RealPlaneActor = nil
  if slua.isValid(self.PlaneShowActor) then
    self.PlaneShowActor:K2_DestroyActor()
  end
  self.PlaneShowActor = nil
  self.OnPlaneDelegate = nil
  self.ShowConfig = nil
  self.StateConfig = nil
  self.StateID = -1
  self:AdjustFpsTemporarily(false)
  for _, TimerID in pairs(self.EventTable) do
    self:RemoveGameTimer(TimerID)
  end
  self.EventTable = {}
  UAESequenceUtils:RecoveryUI()
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    uPlayerController:SetDisableTouchMoveInput(false)
    if uPlayerController.IsInPlane and uPlayerController:IsInPlane() then
      local PCPlane = uPlayerController:GetThePlane()
      if slua.isValid(PCPlane) and not uPlayerController:IsViewTarget(PCPlane) then
        local EViewTargetBlendFunction = import("EViewTargetBlendFunction")
        uPlayerController:SetViewTargetWithBlend(PCPlane, 0.5, EViewTargetBlendFunction.VTBlend_Linear, 0, false)
        print(bWriteLog and "ConfigDrivePlaneShowSubsystem:EndShow Set View Target to Playercontroller Plane")
      end
    end
  end
  if slua.isValid(uPlayerController) and uPlayerController:IsInPlane() or not GameStatus.IsInFightingStatus() then
    uPlayerController:ShowTouchInterface(false)
  end
  self:UnRegistEvents()
  EventSystem:postEvent(EVENTTYPE_INGAME_PLANESHOW, EVENTID_INGAME_PLANESHOW_END)
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:EndShow postEvent EVENTID_INGAME_PLANESHOW_END ")
end
function ConfigDrivePlaneShowSubsystem:StartState(StateID, InnerTime)
  if self.StateConfig and self.StateConfig[StateID] and self.StateConfig[StateID].Name then
    self.    print(bWriteLog and "ConfigDrivePlaneShowSubsystem:StartState StateID:", StateID)
  else
    print(bWriteLog and "ConfigDrivePlaneShowSubsystem:StartState Failed StateID:", StateID)
    self:NextState()
    return
  end
  local StateName = self.StateConfig[StateID].Name
  if StateName == "FinishPlaneShow" then
    self:EndShow()
    return
  end
  local StateBegin = StateName .. "Begin"
  local StateEnd = StateName .. "End"
  local StateTime = self:GetStateRealTime(self.StateConfig[StateID])
  self.TotalTime = self.TotalTime + StateTime - self.StateConfig[StateID].StateTime
  local EndDelayTime = StateTime - (InnerTime or 0)
  local BeginFunc = self[StateBegin]
  local EndFunc = self[StateEnd]
  local CurrentStateConfig = self.StateConfig[StateID]
  CurrentStateConfig.InnerTime = InnerTime or 0
  if BeginFunc and type(BeginFunc) == "function" and EndFunc and type(EndFunc) == "function" then
    local CallSuccess, FuncRes = xpcall(BeginFunc, utility.ErrorMessageHandler, self, CurrentStateConfig)
    if not CallSuccess or not FuncRes then
      print(bWriteLog and "ConfigDrivePlaneShowSubsystem:StartState BeginFunc CallSuccess==false StateID:", StateID)
      self:NextState()
      return
    end
    self:EveryStateStart(CurrentStateConfig)
    self:AddGameTimer(EndDelayTime, false, function()
      xpcall(EndFunc, utility.ErrorMessageHandler, self, CurrentStateConfig)
      self:EveryStateClean(CurrentStateConfig)
      self:NextState()
    end)
  else
    print(bWriteLog and "ConfigDrivePlaneShowSubsystem:StartState invalid BeginFunc and EndFunc:", StateID)
    self:NextState()
    return
  end
end
function ConfigDrivePlaneShowSubsystem:GetStateRealTime(StateItemConfig)
  local StateTime = StateItemConfig.StateTime
  if StateItemConfig.bNeedShowLobbyPawn and StateItemConfig.StateTimeByTeammate then
    self:GetCurrentTeamMatePlayerStateList()
    if self.TeamMateInfo and #self.TeamMateInfo > 0 and StateItemConfig.StateTimeByTeammate[#self.TeamMateInfo] then
      StateTime = StateItemConfig.StateTimeByTeammate[#self.TeamMateInfo]
    end
  end
  return StateTime
end
function ConfigDrivePlaneShowSubsystem:GetCurrentTeamMatePlayerStateList()
  if self.TeamMateInfo then
    return self.TeamMateInfo
  end
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:GetCurrentTeamMatePlayerStateList")
  self.TeamMateInfo = {}
  self.bNotAllTeamMateLoad = false
  local playerstate = GameplayData.GetPlayerState()
  if slua.isValid(playerstate) and playerstate.GetTeamMatePlayerStateList then
    local tTeammates = playerstate:GetTeamMatePlayerStateList({}, false)
    for i, uTeammatePlayerState in pairs(tTeammates) do
      if slua.isValid(uTeammatePlayerState) then
        local CacheData = self:GetRoleCacheData(uTeammatePlayerState)
        self.TeamMateInfo[#self.TeamMateInfo + 1] = CacheData
      else
        self.bNotAllTeamMateLoad = true
      end
    end
    if not (tTeammates and tTeammates.Num) or 1 > tTeammates:Num() then
      local CacheData = self:GetRoleCacheData(playerstate)
      self.TeamMateInfo[#self.TeamMateInfo + 1] = CacheData
    else
      print(bWriteLog and "ConfigDrivePlaneShowSubsystem:GetCurrentTeamMatePlayerStateList tTeammates:" .. tostring(tTeammates:Num()) .. " TeamMateInfo:" .. tostring(#self.TeamMateInfo))
    end
  end
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:GetCurrentTeamMatePlayerStateList:" .. tostring(self.bNotAllTeamMateLoad))
  return self.TeamMateInfo
end
function ConfigDrivePlaneShowSubsystem:GetRoleCacheData(PlayerState)
  if not slua.isValid(PlayerState) then
    print(bWriteLog and "ConfigDrivePlaneShowSubsystem:GetRoleCacheData - PlayerState is invalid")
    return nil
  end
  local RealPawn = PlayerState.CharacterOwner
  if not slua.isValid(RealPawn) then
    print(bWriteLog and "ConfigDrivePlaneShowSubsystem:GetRoleCacheData - CharacterOwner is invalid")
    return nil
  end
  local ComponentClass = import("CharacterAvatarComponent2")
  local UCharacterAvatarComponent = RealPawn:GetComponentByClass(ComponentClass)
  if slua.isValid(UCharacterAvatarComponent) then
    local CacheData = {}
    CacheData.Gender = UCharacterAvatarComponent.gender
    CacheData.HeadId = UCharacterAvatarComponent.HeadAvatarID
    CacheData.NetAvatarData = Game:CopyNetAvatarDataToLobbyPawn(UCharacterAvatarComponent)
    CacheData.AvatarList = self:GetCharacterAvatarList(UCharacterAvatarComponent)
    CacheData.UID = RealPawn.PlayerUID
    CacheData.PlayerName = RealPawn.PlayerName
    CacheData.CardCollectCareerScore = PlayerState.CardCollectCareerScore or 0
    CacheData.CabinShowActorID = PlayerState.CabinShowActorID or 0
    if RealPawn.PMGCPlayerCharacterFeature and RealPawn.PMGCPlayerCharacterFeature.CupReadyState and RealPawn.PMGCPlayerCharacterFeature.CupReadyState > 10000 then
      CacheData.SupportTeamID = RealPawn.PMGCPlayerCharacterFeature.CupReadyState
    end
    return CacheData
  end
  return nil
end
function ConfigDrivePlaneShowSubsystem:GetCharacterAvatarList(UCharacterAvatarComponent)
  local TempInfoList = {}
  if not slua.isValid(UCharacterAvatarComponent) or not UCharacterAvatarComponent.NetAvatarData then
    return TempInfoList
  end
  local TempSlotSyncData = slua.IndexReference(UCharacterAvatarComponent, "NetAvatarData", "SlotSyncData")
  if TempSlotSyncData then
    for Index, AvatarSynData in pairs(TempSlotSyncData) do
      if AvatarSynData.ItemID > 0 and self:IsNeedSlotType(AvatarSynData.SlotID, AvatarSynData.SubSlotID) then
        local Info = {}
        Info.resID = AvatarSynData.ItemID
        Info.colorID = AvatarSynData.CustomInfo.ColorID
        Info.patternID = AvatarSynData.CustomInfo.PatternID
        table.insert(TempInfoList, Info)
      end
    end
  end
  return TempInfoList
end
function ConfigDrivePlaneShowSubsystem:IsNeedSlotType(SlotTypeID, SubSlotID)
  local EAvatarSlotType = import("EAvatarSlotType")
  if SlotTypeID == EAvatarSlotType.EAvatarSlotType_BackpackEquipemtSlot or SlotTypeID == EAvatarSlotType.EAvatarSlotType_FootEffectEquipemtSlot or SlotTypeID == EAvatarSlotType.EAvatarSlotType_GlideEquipemtSlot or SlotTypeID == EAvatarSlotType.EAvatarSlotType_HandEffectEquipemtSlot or SlotTypeID == EAvatarSlotType.EAvatarSlotType_BackPack_PendantSlot or SlotTypeID == EAvatarSlotType.EAvatarSlotType_ArmorEquipemtSlot or SlotTypeID == EAvatarSlotType.EAvatarSlotType_ParachuteEquipemtSlot then
    return false
  end
  return true
end
function ConfigDrivePlaneShowSubsystem:NextState()
  if self.StateID then
    local NextID = self.StateID + 1
    if self.StateConfig and NextID <= #self.StateConfig then
      self:StartState(NextID)
      return
    end
  end
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:NextState Faild self.StateID:", self.StateID)
  self:EndShow()
end
function ConfigDrivePlaneShowSubsystem:EveryStateClean(Config)
end
function ConfigDrivePlaneShowSubsystem:EveryStateStart(Config)
  local ShowUIKey = Config and Config.ShowUIKey or {}
  for _, UIKey in pairs(ShowUIKey) do
    local ShowUIData = UIManager.UI_Config_InGame[UIKey]
    if ShowUIData then
      UIManager.ShowUI(ShowUIData)
    else
      print(bWriteLog and "ConfigDrivePlaneShowSubsystem:EveryStateStart ShowUI Faild self.StateID:", self.StateID, " ShowUIKey:", ShowUIKey)
    end
  end
  local PostEventTable = Config and Config.PostEvent or {}
  for _, Post in pairs(PostEventTable) do
    local DelayTime = Post.DelayTime or 0
    local EventType = Post.EventType or ""
    local EventName = Post.EventName or ""
    local Params = Post.Params
    local Params2 = Post.Params2
    local TimerID = self:AddGameTimer(DelayTime, false, function()
      EventSystem:postEvent(EventType, EventName, Params, Params2)
    end)
    table.insert(self.EventTable, TimerID)
  end
  self:PreReadyForNextState(self.StateID + 1)
end
function ConfigDrivePlaneShowSubsystem:LevelSequenceShowBegin(Config)
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:LevelSequenceShowBegin self.StateID:", self.StateID)
  if not (slua.isValid(self.RealPlaneActor) and Config) or not self:GetRealSequenceActorPath(Config) then
    return false
  end
  local RealDoFunc = function()
    local SequenceActorPath = self:GetRealSequenceActorPath(Config) or ""
    local SequencePath = Config.SequenceAssetPath or ""
    local SequenceActorPos = Config.SequencePosition or FVector(0, 0, 0)
    local SequenceRotator = Config.SequenceRotator or FRotator(0, 0, 0)
    local SequenceScale = Config.SequenceScale or FVector(1, 1, 1)
    local InnerTime = Config.InnerTime or 0
    local TempTran = UKismetMathLibrary.MakeTransform(SequenceActorPos, SequenceRotator, SequenceScale)
    local Util = require("client.slua_ui_framework.util")
    Util.GetAssetAsync(SequenceActorPath, function(SequenceActorAsset)
      if SequenceActorAsset then
        self.LevelSequenceActor = Game:PlayLevelSequence(slua.getGameInstance(), SequencePath, TempTran, SequenceActorPath, false)
        if not slua.isValid(self.LevelSequenceActor) then
          print(bWriteLog and "ConfigDrivePlaneShowSubsystem:LevelSequenceShowBegin SequenceAcotr Init Failed !!!!")
          return
        else
          self.LevelSequenceActor:Play(InnerTime)
        end
      end
    end)
  end
  local UPlayerController = GameplayData.GetPlayerController()
  local ControllerPlane = UPlayerController and UPlayerController:GetThePlane()
  if Config and Config.ShouldWaitControllerOnRepPlane and not slua.isValid(ControllerPlane) then
    self.LevelSequenceAddControlEvent = true
    self:AddControlEvent(UPlayerController, "OnPlayerNumOnPlaneChangedDelegate", function()
      RealDoFunc()
      self:LevelSequenceShowRemoveEvent()
    end)
  else
    RealDoFunc()
  end
  return true
end
function ConfigDrivePlaneShowSubsystem:LevelSequenceShowEnd(Config)
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:LevelSequenceShowEnd self.StateID:", self.StateID)
  if slua.isValid(self.LevelSequenceActor) then
    self.LevelSequenceActor:K2_DestroyActor()
    self.LevelSequenceActor = nil
  end
  self:LevelSequenceShowRemoveEvent()
  return true
end
function ConfigDrivePlaneShowSubsystem:LevelSequenceShowRemoveEvent()
  if self.LevelSequenceAddControlEvent then
    self.LevelSequenceAddControlEvent = false
    local UPlayerController = GameplayData.GetPlayerController()
    if slua.isValid(UPlayerController) then
      self:RemoveControlEvent(UPlayerController, "OnPlayerNumOnPlaneChangedDelegate")
    end
  end
end
function ConfigDrivePlaneShowSubsystem:PlaneActorSequenceShowBegin(Config)
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:PlaneActorSequenceShowBegin self.StateID:", self.StateID)
  local InnerTimeError = Config and Config.InnerTime and Config.InnerTime > 0.1
  local UPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(UPlayerController) and InnerTimeError and UPlayerController.IsSpectatorOrDemoPlayer and UPlayerController:IsSpectatorOrDemoPlayer() then
    InnerTimeError = false
  end
  if not (slua.isValid(self.RealPlaneActor) and self:GetRealSequenceActorPath(Config)) or InnerTimeError then
    print(bWriteLog and "ConfigDrivePlaneShowSubsystem:PlaneActorSequenceShowBegin self.RealPlaneActor or self:GetRealSequenceActorPath(Config) is not valid, return InnerTimeError:" .. tostring(InnerTimeError))
    return false
  end
  local AfterSpawnFunc = function(SpawnObject)
    if not slua.isValid(SpawnObject) or not slua.isValid(self.RealPlaneActor) then
      print(bWriteLog and string.format("ConfigDrivePlaneShowSubsystem:PlaneActorSequenceShowBegin SpawnObject or self.RealPlaneActor is not valid, return"))
      return
    end
    self.PlaneShowActor = SpawnObject
    if not self.PlaneShowActor.PlaySeq then
      print(bWriteLog and string.format("ConfigDrivePlaneShowSubsystem:PlaneActorSequenceShowBegin self.PlaneShowActor.PlaySeq is not valid, return"))
      return
    end
    if not self.PlaneShowActor:PlaySeq(self.RealPlaneActor, Config) then
      print(bWriteLog and string.format("ConfigDrivePlaneShowSubsystem:PlaneActorSequenceShowBegin PlaySeq failed, return"))
      return
    end
    self:AddGameTimer(0.2, false, function()
      self:AdjustFpsTemporarily(true)
    end)
    if self.ShowConfig and self.ShowConfig.EnableSwitchUI and slua.isValid(self.PlaneShowActor) then
      self.PlaneShowActor:ShowUIPanel()
    end
    if Config.EffectUIConfig and UIManager.UI_Config_InGame[Config.EffectUIConfig] then
      print(bWriteLog and "OnDiscoveryTipsSphereBeginOverlap, OpenNearDoorEffectUI")
      if self.EffectUI and self.EffectUI.CloseSelf then
        self.EffectUI:CloseSelf()
        self.EffectUI = nil
      end
      self.EffectUI = UIManager.ShowUI(UIManager.UI_Config_InGame[Config.EffectUIConfig])
    end
    if not Config.WeatherID then
      print(bWriteLog and string.format("ConfigDrivePlaneShowSubsystem:PlaneActorSequenceShowBegin Config.WeatherID = %s, return", Config.WeatherID))
      return
    end
    local PlayerController = GameplayData.GetPlayerController()
    if not slua.isValid(PlayerController) then
      print(bWriteLog and string.format("ConfigDrivePlaneShowSubsystem:PlaneActorSequenceShowBegin PlayerController is not valid, return"))
      return
    end
    local PlayerCharacter = PlayerController:GetCurPlayerCharacter()
    if not slua.isValid(PlayerCharacter) or not PlayerCharacter.SkyTransition then
      print(bWriteLog and string.format("ConfigDrivePlaneShowSubsystem:PlaneActorSequenceShowBegin PlayerController:GetCurPlayerCharacter is not valid, return"))
      return
    end
    print(bWriteLog and string.format("ConfigDrivePlaneShowSubsystem:PlaneActorSequenceShowBegin RefreshControllerState"))
    if PlayerCharacter.SkyTransition:GetState() == Config.WeatherID then
      PlayerCharacter.SkyTransition:RefreshControllerState()
    else
      print(bWriteLog and string.format("ConfigDrivePlaneShowSubsystem:PlaneActorSequenceShowBegin WeatherID = %s is not ready", Config.WeatherID))
      PlayerCharacter.SkyTransition.EventDelegate:Add("OnSkyTransitionStateChanged", function(_, StateId)
        print(bWriteLog and string.format("ConfigDrivePlaneShowSubsystem:PlaneActorSequenceShowBegin OnSkyTransitionStateChanged %s", StateId))
        if StateId == Config.WeatherID then
          PlayerCharacter.SkyTransition:RefreshControllerState()
          PlayerCharacter.SkyTransition.EventDelegate:Remove("OnSkyTransitionStateChanged")
        end
      end)
    end
  end
  local SpawnClassPath = self:GetRealSequenceActorPath(Config)
  ActorTools.SpawnActorAsync(self.RealPlaneActor, SpawnClassPath, FVector(0, 0, 0), FRotator(0, 0, 0), FVector(1, 1, 1), AfterSpawnFunc)
  return true
end
function ConfigDrivePlaneShowSubsystem:GetRealSequenceActorPath(Config)
  if Config.bNeedShowLobbyPawn and Config.ActorSeqPathByTeammate then
    self:GetCurrentTeamMatePlayerStateList()
    if self.TeamMateInfo and #self.TeamMateInfo > 0 and Config.ActorSeqPathByTeammate[#self.TeamMateInfo] then
      return Config.ActorSeqPathByTeammate[#self.TeamMateInfo]
    end
  end
  return Config.SequenceActorPath
end
function ConfigDrivePlaneShowSubsystem:PlaneActorSequenceShowEnd(Config)
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:PlaneActorSequenceShowEnd self.StateID:", self.StateID)
  if not slua.isValid(self.RealPlaneActor) then
    return false
  end
  if slua.isValid(self.PlaneShowActor) and self.PlaneShowActor.StopSeq then
    self.PlaneShowActor:StopSeq(self.RealPlaneActor, Config)
    if slua.isValid(self.PlaneShowActor) then
      self.PlaneShowActor:K2_DestroyActor()
    end
    self.PlaneShowActor = nil
  end
  if self.EffectUI then
    if self.EffectUI.CloseByAnimation then
      self.EffectUI:CloseByAnimation()
      self.EffectUI = nil
    elseif self.EffectUI.CloseSelf then
      self.EffectUI:CloseSelf()
      self.EffectUI = nil
    end
  end
  return true
end
function ConfigDrivePlaneShowSubsystem:DelayShowEnd(Config)
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:DelayShowEnd self.StateID:", self.StateID)
  return true
end
function ConfigDrivePlaneShowSubsystem:DelayShowBegin(Config)
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:DelayShowBegin self.StateID:", self.StateID)
  return true
end
function ConfigDrivePlaneShowSubsystem:GetTotalTime()
  return self.TotalTime
end
function ConfigDrivePlaneShowSubsystem:GetCurFightingTime()
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if slua.isValid(uGameState) and Game:IsFightingState() then
    local CurTime = uGameState:GetServerWorldTimeSeconds()
    local PastInterval = CurTime - (uGameState.StartFlyTime > 0 and uGameState.StartFlyTime or CurTime)
    return PastInterval
  end
  return 0
end
function ConfigDrivePlaneShowSubsystem:GetStateIDAndTime()
  local ReturnID = -1
  local RerurnTime = 0
  local CurFightTime = self:GetCurFightingTime()
  if CurFightTime < self.TotalTime then
    for StateID, StateConfig in pairs(self.StateConfig) do
      ReturnID = StateID
      local StateTime = self:GetStateRealTime(StateConfig)
      if StateConfig and StateTime then
        if CurFightTime - StateTime < 0 then
          RerurnTime = CurFightTime
          break
        end
        CurFightTime = CurFightTime - StateTime
      end
    end
  end
  return ReturnID, RerurnTime
end
function ConfigDrivePlaneShowSubsystem:GetBattlePassDelayTime()
  local ReturnTime = self.TotalTime - self.GetCurFightingTime()
  if 0 < ReturnTime then
    return ReturnTime
  end
  return 0
end
function ConfigDrivePlaneShowSubsystem:PreReadyForNextState(NextID)
  if not Client then
    return
  end
  if self.StateConfig and NextID <= #self.StateConfig then
    local NextConfig = self.StateConfig[NextID]
    local PreLoadAssetKey = self.ShowConfig.PreLoadAssetKey or {}
    for _, AssetKey in pairs(PreLoadAssetKey) do
      local PathInfo = NextConfig and NextConfig[AssetKey]
      if type(PathInfo) == "table" then
        for key, value in pairs(PathInfo) do
          local Util = require("client.slua_ui_framework.util")
          Util.GetAssetAsync(value, function(Asset)
          end)
        end
      elseif PathInfo then
        local Util = require("client.slua_ui_framework.util")
        Util.GetAssetAsync(PathInfo, function(Asset)
        end)
      end
    end
    return
  end
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:PreReadyForNextState Failed NextID:", NextID)
  return
end
function ConfigDrivePlaneShowSubsystem:GetCurrentConfig()
  if self.ShowConfig then
    return self.ShowConfig
  end
end
function ConfigDrivePlaneShowSubsystem:OnApplicationReactived()
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:OnApplicationReactived")
  self:EndShow()
  if self.HaveRegistEvent and Game:IsFightingState() then
    print(bWriteLog and "ConfigDrivePlaneShowSubsystem:OnApplicationReactived EndShow But HaveRegistEvent == true")
    UAESequenceUtils:RecoveryUI()
    self:UnRegistEvents()
  end
end
function ConfigDrivePlaneShowSubsystem:TeamShowEnd()
  if self.StateID > 0 then
    UAESequenceUtils:HideAllUI()
    print(bWriteLog and "ConfigDrivePlaneShowSubsystem:TeamShowEnd HideAllUI")
  end
end
function ConfigDrivePlaneShowSubsystem:AdjustFpsTemporarily(IsBeginShow)
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem.AdjustFpsTemporarily IsBeginShow:" .. tostring(IsBeginShow))
  local logicSettingGraphics = require("client.slua.logic.setting.logic_setting_graphics")
  logicSettingGraphics.DowngradeFpsLevelTemporarily(IsBeginShow)
end
function ConfigDrivePlaneShowSubsystem:HandleAliasEnterBroadcast(Config)
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:HandleAliasEnterBroadcast")
  if Config and Config.AliasBroadcastDelay then
    self.ShowAliasTimer = self:AddGameTimer(Config.AliasBroadcastDelay, false, function()
      if UIManager.UI_Config_InGame.PlaneShowAliasEnterBroadcastUI then
        UIManager.ShowUI(UIManager.UI_Config_InGame.PlaneShowAliasEnterBroadcastUI)
      end
    end)
  elseif UIManager.UI_Config_InGame.PlaneShowAliasEnterBroadcastUI then
    UIManager.ShowUI(UIManager.UI_Config_InGame.PlaneShowAliasEnterBroadcastUI)
  end
end
function ConfigDrivePlaneShowSubsystem:ChangeStaticShowFlyingInfo()
  if self.ShowAliasTimer then
    self:RemoveGameTimer(self.ShowAliasTimer)
    self.ShowAliasTimer = nil
    UIManager.ShowUI(UIManager.UI_Config_InGame.PlaneShowAliasEnterBroadcastUI)
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, ConfigDrivePlaneShowSubsystem)