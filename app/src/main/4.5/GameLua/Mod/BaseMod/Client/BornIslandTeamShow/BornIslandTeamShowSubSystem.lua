local BornIslandTeamShowSubSystem = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameplayStatics = import("GameplayStatics")
local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
local TableUtil = require("common.table_util")
local Util = require("client.slua_ui_framework.util")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local UKismetMathLibrary = import("KismetMathLibrary")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local UIUtil = require("client.common.ui_util")
local LobbyPawnClassPath = "/Game/Arts_PlayerBluePrints/Character_Show/BP_PlayerLobbyPawn.BP_PlayerLobbyPawn"
local PawnClassPath = "/Game/BluePrints/Core/BP_PlayerPawn.BP_PlayerPawn"
local PlayerTransformClassPath = "/Game/Mod/EvoBase/Arts_PlayerBluePrints/BornIslandTeamShow/BP_TeamShowTransform.BP_TeamShowTransform"
local CarClassPath = "/Game/Arts_PlayerBluePrints/Vehicle/BP_STExtraWheeledVehicle.BP_STExtraWheeledVehicle"
local LobbyVehiclePath = "/Game/Mod/EvoBase/Arts_PlayerBluePrints/BornIslandTeamShow/BP_TeamShowVehicle.BP_TeamShowVehicle"
local WingmanClassPath = "/Game/Arts_PlayerBluePrints/Wingman_Show/BP_LobbyWingman.BP_LobbyWingman"
local BornTeamShowUIPath = "/Game/Mod/EvoBase/BluePrints/UI/BornIslandTeamShow/BornIslandTeamShow_UIBP.BornIslandTeamShow_UIBP"
local BornTeamShowUIPathLow = "/Game/Mod/EvoBase/BluePrints/UI/BornIslandTeamShow/BornIslandTeamShow_New_UIBP.BornIslandTeamShow_New_UIBP"
local EPetState = import("EPetState")
local EPawnState = import("EPawnState")
local ShowHideUIFlag = require("GameLua.Mod.BaseMod.Client.Config.ShowHideUIFlag")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local UAESequenceUtils = require("GameLua.Mod.BaseMod.GamePlay.SequenceMgr.UAESequenceUtils")
local LobbyTankPath = "/Game/Arts_PlayerBluePrints/Vehicle_Show/BP_LobbyTank.BP_LobbyTank"
local uActor = import("/Script/Engine.Actor")
local CONST_MINITV_ATTACH_BASE_SCALE = 0.3
local ShowStateEnum = {
  None = 0,
  PreReady = 1,
  Showing = 2,
  EndShow = 3
}
function BornIslandTeamShowSubSystem:ctor()
  print(bWriteLog and "BornIslandTeamShowSubSystem:ctor()")
  self.TotalShowTime = 9
  self.ShowState = ShowStateEnum.None
  self.ShowConfig = nil
  self.SeqActor = nil
  self.PlayerPawnList = {}
  self.PlayerDefaultAnims = {}
  self.PlayerTransformClassObject = nil
  self.PlayerTransformClass = nil
  self.CarObjectList = {}
  self.LobbyCarObjectClass = nil
  self.CarObjectClass = nil
  self.WingmanObjectList = {}
  self.WingmanObjectClass = nil
  self.MinItemQuality = 6
  self.PlayerAnimDelayTime = 1
  self.BornislandTeamShowUIAsset = nil
  self.UIDelayShowTime = 3
  self.PetObjectList = {}
  self.NeedHiddenClassPath = {
    "/Game/Mod/EvoBase/Arts_PlayerBluePrints/BornlslandRedpacket/602056/BluePrints/BP_InBattleRedpacket.BP_InBattleRedpacket",
    "/Game/Arts_PlayerBluePrints/Vehicle/BP_VehicleContainer.BP_VehicleContainer",
    "/Game/Arts_PlayerBluePrints/Vehicle/WingMan/wing_Vehicle.wing_Vehicle"
  }
  self.NeedHiddenClassTable = {}
  self.TraceGroundIgnoreList = nil
  self.PlayerHadOffset = {}
  self.PendingPawnDataList = {}
  self.PendingPetDataList = {}
  self.PendingCarDataList = {}
  self.PendingWingmanDataList = {}
  self.HavePlayedAnim = false
  self.PlayerAvatarItem = {}
  self.PlayerAvatarShapeID = {}
  self.PlayerClothSchemeMap = {}
  self.PlayerXSuitUnlockMap = {}
  self.CachePlayerInfoList = {}
  self.PreCacheTableAsset = {}
  self.PreCacheTableConfig = {
    "VehiclePlaneSkinMapping",
    "BackpackMapping",
    "BPMappingTable",
    "FeaturesItems",
    "EmoteBPTable",
    "PetTable",
    "PetDressTable",
    "WeaponBPTable",
    "VehicleBPTable",
    "PlaneBPTable",
    "AvatarSuitsTable",
    "AvatarBPTable",
    "PetActionTable",
    "PetScaleTable",
    "VehicleRefitInfo",
    "TeamShowLowDeviceCfg"
  }
  self.PreCachePetAsset = {}
  self.StopCountDownHandle = false
  self.SpecialVehicleObjTable = {}
  self.HadCreatedActorForShow = false
  self.AccessoryVehicleObjCacheTable = {}
  self.CachedPlayerAdjustLoc = {}
  self.CachedPlayerMiniTvInfo = {}
end
function BornIslandTeamShowSubSystem:OnInit()
  print(bWriteLog and "BornIslandTeamShowSubSystem:OnInit")
  for _, tableName in pairs(self.PreCacheTableConfig) do
    local tableAsset = CDataTable.GetTable(tableName)
    if tableAsset then
      table.insert(self.PreCacheTableAsset, tableAsset)
    end
  end
  self:InitConfig()
  self:AddGameTimer(3, false, function()
    print(bWriteLog and "BornIslandTeamShowSubSystem:OnInit After")
    if slua.isValid(CGameState) and CGameState.ReadyStateTime and CGameState.ReadyStateTime > self.TotalShowTime then
      local ShowBeginDelay = CGameState.ReadyStateTime - self.TotalShowTime
      self:InitShowOnStart()
      if not self:IsTeamShowEnable() then
        print(bWriteLog and "BornIslandTeamShowSubSystem:OnInit IsTeamShowEnable == false, return!")
        self.PreCacheTableAsset = {}
        return
      end
      if self.ShowConfig.UIDelayShowTime then
        self.UIDelayShowTime = self.ShowConfig.UIDelayShowTime
      end
      print(bWriteLog and "BornIslandTeamShowSubSystem:OnInit After ReadyStateTime:", CGameState.ReadyStateTime, " ShowBeginDelay:", ShowBeginDelay)
      GameplayData.AddSelfPlayerControllerEvent(self, "OnGameStartCountDownDelegate", self.CountDownHandle, self)
      self:RegisiterEvent()
      self:RefreshCacheInfo()
    else
      self.PreCachePetAsset = {}
    end
  end)
end
function BornIslandTeamShowSubSystem:CountDownHandle(CountDownTime)
  if self.StopCountDownHandle then
    return
  end
  print(bWriteLog and "BornIslandTeamShowSubSystem:CountDownHandle ReadyStateTime:", CountDownTime)
  if CountDownTime >= self.TotalShowTime - 1 and CountDownTime <= self.TotalShowTime then
    self:BeginShow()
    self.StopCountDownHandle = true
    self:AddGameTimer(CountDownTime + 2, false, function()
      self:EndShow()
    end)
    print(bWriteLog and "BornIslandTeamShowSubSystem:OnInit BeginShow ReadyStateTime:", CountDownTime)
  end
  if CountDownTime < self.TotalShowTime - 1 then
    self.StopCountDownHandle = true
    self.PreCacheTableAsset = {}
    print(bWriteLog and "BornIslandTeamShowSubSystem:OnInit Do not Begin Show,There is something wrong, ReadyStateTime:", CountDownTime)
  end
  if CountDownTime == self.TotalShowTime + 1 then
    self:PreReadyForShow()
  end
  if CountDownTime <= self.TotalShowTime + 3 and CountDownTime > self.TotalShowTime and not self.PreReadyForShow3Begin then
    self:PreReadyForShow3()
    self.PreReadyForShow3Begin = true
  end
end
function BornIslandTeamShowSubSystem:OnRelease()
  self:EndShow()
  print(bWriteLog and "BornIslandTeamShowSubSystem:OnRelease()")
  BornIslandTeamShowSubSystem.__super.OnRelease(self)
end
function BornIslandTeamShowSubSystem:RegisiterEvent()
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANE_CREATE, self.EndShow, self)
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.OnRepTeammateChange then
    self:AddControlEvent(uPlayerController, "OnRepTeammateChange", self.OnRepTeammateChange_Handle, self)
  end
end
function BornIslandTeamShowSubSystem:InitConfig()
  local curLevelName = GameplayStatics.GetCurrentLevelName(UIUtil.GetGameInstance(), true)
  local BornIslandTeamShowConfig = GamePlayTools.GetCurrentConfig("BornIslandTeamShowConfig")
  if not BornIslandTeamShowConfig or not BornIslandTeamShowConfig.Default then
    print(bWriteLog and "BornIslandTeamShowSubSystem:InitShowOnStart Error Config!!!")
    return
  end
  local TempShowConfig = TableUtil.DeepCloneTable(BornIslandTeamShowConfig.Default)
  if BornIslandTeamShowConfig[curLevelName] then
    TableUtil.OverrideTable(TempShowConfig, BornIslandTeamShowConfig[curLevelName])
  end
  self.ShowConfig = TempShowConfig
  self.PlayAnimationConfigInfo = BornIslandTeamShowConfig.PlayAnimationConfigInfo
  print(bWriteLog and "BornIslandTeamShowSubSystem:InitShowOnStart curLevelName:", curLevelName)
  if self.ShowConfig.PlayerDefaultAnims then
    self.PlayerDefaultAnims = self.ShowConfig.PlayerDefaultAnims
  end
  if self.ShowConfig.MinItemQuality and self.ShowConfig.MinItemQuality > 0 then
    self.MinItemQuality = self.ShowConfig.MinItemQuality
  end
  if self.ShowConfig.PlayerAnimDelayTime and 0 <= self.ShowConfig.PlayerAnimDelayTime then
    self.PlayerAnimDelayTime = self.ShowConfig.PlayerAnimDelayTime
  end
  if self.ShowConfig.TotalShowTime and 0 <= self.ShowConfig.TotalShowTime then
    self.TotalShowTime = self.ShowConfig.TotalShowTime
  end
  if curLevelName == "FourMaps_Main" then
    local SuperData = GameplayData.GetSuperData()
    self:AddDataListener(SuperData, "PlayerCharacter", function()
      if self.ShowConfig and self.ShowConfig.LivikSequencePositions and self.ShowConfig.LivikSequenceRotator then
        local uPlayerCharacter = GameplayData.GetPlayerCharacter()
        if not slua.isValid(uPlayerCharacter) then
          return
        end
        local PlayerLocation = Game:GetActorLocation(uPlayerCharacter)
        local minDistance
        local minIdx = -1
        local TempDis = 0
        for LivikIdx, LivikPos in pairs(self.ShowConfig.LivikSequencePositions) do
          LivikPos = FVector(LivikPos.X, LivikPos.Y, LivikPos.Z)
          TempDis = FVector.Distance(PlayerLocation, LivikPos)
          if minIdx == -1 or minDistance > TempDis then
            minDistance = TempDis
            minIdx = LivikIdx
          end
        end
        if -1 < minIdx and minIdx <= #self.ShowConfig.LivikSequencePositions and minIdx <= #self.ShowConfig.LivikSequenceRotator then
          self.ShowConfig.SequencePosition = self.ShowConfig.LivikSequencePositions[minIdx]
          self.ShowConfig.SequenceRotator = self.ShowConfig.LivikSequenceRotator[minIdx]
        end
      end
    end)
  end
end
function BornIslandTeamShowSubSystem:InitShowOnStart()
  if not self:IsTeamShowEnable() then
    return
  end
  local SequenceActorPath = self.ShowConfig.SequenceActorPath or ""
  local SequencePath = self.ShowConfig.SequencePath or ""
  local SequenceActorPos = self.ShowConfig.SequencePosition or FVector(0, 0, 0)
  local SequenceRotator = self.ShowConfig.SequenceRotator or FRotator(0, 0, 0)
  local SequenceScale = self.ShowConfig.SequenceScale or FVector(1, 1, 1)
  if self.ShowConfig.ExtraNeedHiddenClassPath then
    for _, HideClassPath in pairs(self.ShowConfig.ExtraNeedHiddenClassPath) do
      table.insert(self.NeedHiddenClassPath, HideClassPath)
    end
  end
  local TempTran = UKismetMathLibrary.MakeTransform(SequenceActorPos, SequenceRotator, SequenceScale)
  Util.GetAssetAsync(SequenceActorPath, function(SequenceActorAsset)
    if SequenceActorAsset then
      self.SeqActor = Game:PlayLevelSequence(UIUtil.GetGameInstance(), SequencePath, TempTran, SequenceActorPath, false)
      if not slua.isValid(self.SeqActor) then
        print(bWriteLog and "BornIslandTeamShowSubSystem:InitShowOnStart SequenceAcotr Init Failed !!!!")
      end
    end
  end)
  Util.GetAssetAsync(LobbyPawnClassPath .. "_C", function(PawnClass)
    if PawnClass then
      self.playerLobbyPawnClass = slua.loadClass(LobbyPawnClassPath)
    else
      print(bWriteLog and "BornIslandTeamShowSubSystem:InitShowOnStart playerLobbyPawnClass Failed !!!! PawnClass:", PawnClass)
    end
  end)
  Util.GetAssetAsync(PlayerTransformClassPath .. "_C", function(TClassObject)
    if TClassObject then
      self.PlayerTransformClass = slua.loadClass(PlayerTransformClassPath)
    else
      print(bWriteLog and "BornIslandTeamShowSubSystem:InitShowOnStart PlayerTransformClass Failed !!!! TClassObject:", TClassObject)
    end
  end)
  Util.GetAssetAsync(LobbyVehiclePath .. "_C", function(TClassObject)
    if TClassObject then
      self.LobbyCarObjectClass = slua.loadClass(LobbyVehiclePath)
    else
      print(bWriteLog and "BornIslandTeamShowSubSystem:InitShowOnStart LobbyCarObjectClass Failed !!!! TClassObject:", TClassObject)
    end
  end)
  Util.GetAssetAsync(WingmanClassPath .. "_C", function(TClassObject)
    if TClassObject then
      self.WingmanObjectClass = slua.loadClass(WingmanClassPath)
    else
      print(bWriteLog and "BornIslandTeamShowSubSystem:InitShowOnStart WingmanObjectClass Failed !!!! TClassObject:", TClassObject)
    end
  end)
  Util.GetAssetAsync(CarClassPath .. "_C", function(TClassObject)
    if TClassObject then
      self.CarObjectClass = slua.loadClass(CarClassPath)
    else
      print(bWriteLog and "BornIslandTeamShowSubSystem:InitShowOnStart CarClassPath Failed !!!! TClassObject:", TClassObject)
    end
  end)
  if not self:IsLowDevice() then
    Util.GetAssetAsync(BornTeamShowUIPath .. "_C", function(TClassObject)
      if TClassObject then
        self.BornislandTeamShowUIAsset = TClassObject
        print(bWriteLog and "BornIslandTeamShowSubSystem:InitShowOnStart BornTeamShowUIPath Loaded")
      end
    end)
  else
    Util.GetAssetAsync(BornTeamShowUIPathLow .. "_C", function(TClassObject)
      if TClassObject then
        self.BornislandTeamShowUIAsset = TClassObject
        print(bWriteLog and "BornIslandTeamShowSubSystem:InitShowOnStart BornTeamShowUIPath Loaded")
      end
    end)
  end
  for _, HiddenPath in pairs(self.NeedHiddenClassPath) do
    Util.GetAssetAsync(HiddenPath .. "_C", function(TClassObject)
      if TClassObject then
        table.insert(self.NeedHiddenClassTable, TClassObject)
        print(bWriteLog and "BornIslandTeamShowSubSystem:InitShowOnStart HiddenPath Loaded")
      end
    end)
  end
end
function BornIslandTeamShowSubSystem:IsTeamShowEnable()
  if not self.ShowConfig then
    return false
  end
  local MapEnable = false
  local ModeEnable = false
  if self.ShowConfig and self.ShowConfig.EnableShow == true then
    MapEnable = true
  end
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModType, ModeType2 = GameMainConfig.GetModType()
  if ModeType2 == "" then
    ModeType2 = GameMainConfig.GetMapType()
  end
  local ModeID = GameMainConfig.GetModeID()
  if ModeType2 and self.ShowConfig.EnableMode and self.ShowConfig.EnableSubMode then
    for _, MainMode in pairs(self.ShowConfig.EnableMode) do
      if ModType == MainMode then
        ModeEnable = true
        break
      end
    end
    for _, TempSubMode in pairs(self.ShowConfig.EnableSubMode) do
      if ModeType2 == TempSubMode then
        ModeEnable = true
        break
      end
    end
    if self.ShowConfig.DisableModeID and ModeEnable then
      for _, DisModeID in pairs(self.ShowConfig.DisableModeID) do
        if DisModeID == ModeID then
          ModeEnable = false
          break
        end
      end
    end
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and (uPlayerController:IsObserver() or uPlayerController:IsSpectator() or uPlayerController:IsInPetSpectator()) then
    print(bWriteLog and "BornIslandTeamShowSubSystem:IsTeamShowEnable OB not show")
    return false
  end
  local memorySize = Client.GetMemorySize()
  if memorySize < 2 then
    print(bWriteLog and "BornIslandTeamShowSubSystem:IsTeamShowEnable memorySize < 2, return false")
    return false
  end
  print(bWriteLog and string.format("BornIslandTeamShowSubSystem:IsTeamShowEnable MapEnable:%s,ModeEnable:%s,ModType:%s,ModeType2:%s", tostring(MapEnable), tostring(ModeEnable), ModType, ModeType2))
  return MapEnable and ModeEnable
end
function BornIslandTeamShowSubSystem:CreateDataForShow()
  print(bWriteLog and "BornIslandTeamShowSubSystem:CreateDataForShow ")
  local MyPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(MyPlayerState) then
    print(bWriteLog and "BornIslandTeamShowSubSystem:CreateDataForShow invalid PlayerState, Return!!!")
    return
  end
  local TeamPlayerCount = 0
  local TempTransform, TempCarTransform, TempWingmanTransform, TempPetTransform
  local SequenceActorPos = self.ShowConfig.SequencePosition or FVector(0, 0, 0)
  local SequenceRotator = self.ShowConfig.SequenceRotator or FRotator(0, 0, 0)
  self.UIShowData = {}
  local Actor_C = import("/Script/Engine.Actor")
  local tOtherTeammate = slua.Array(UEnums.EPropertyClass.Object, Actor_C)
  if MyPlayerState.GetTeamMatePlayerStateList then
    tOtherTeammate = MyPlayerState:GetTeamMatePlayerStateList({}, false)
  end
  if not (tOtherTeammate and tOtherTeammate.Num) or tOtherTeammate:Num() < 1 then
    local OnePlayerState = GameplayData.GetPlayerState()
    if slua.isValid(OnePlayerState) then
      tOtherTeammate:Add(OnePlayerState)
    else
      print(bWriteLog and "BornIslandTeamShowSubSystem:CreateDataForShow invalid OnePlayerState, Return!!!")
      return
    end
  end
  if not (tOtherTeammate and tOtherTeammate.Num) or tOtherTeammate:Num() < 1 then
    print(bWriteLog and "BornIslandTeamShowSubSystem:CreateDataForShow invalid tOtherTeammate, Return!!!")
    return
  end
  local CurPositionIndex = 0
  for _, TempPlayerState in pairs(tOtherTeammate) do
    if slua.isValid(TempPlayerState) then
      TeamPlayerCount = TeamPlayerCount + 1
    end
  end
  local PlayerTransformList, CarTransformList, WingmanTransformList, PetTransFormList = self:GetPlayerTransformList(TeamPlayerCount, SequenceActorPos, SequenceRotator)
  if not (PlayerTransformList and CarTransformList and WingmanTransformList) or not PetTransFormList then
    print(bWriteLog and "BornIslandTeamShowSubSystem:CreateDataForShow invalid PlayerTransformList or CarTransformList or WingmanTransformList , Return!!!")
    return
  end
  for key, MatePlayerState in pairs(tOtherTeammate) do
    if slua.isValid(MatePlayerState) then
      if PlayerTransformList and CurPositionIndex < PlayerTransformList:Num() then
        TempTransform = PlayerTransformList:Get(CurPositionIndex)
      end
      if CarTransformList and CurPositionIndex < CarTransformList:Num() then
        TempCarTransform = CarTransformList:Get(CurPositionIndex)
      end
      if WingmanTransformList and CurPositionIndex < WingmanTransformList:Num() then
        TempWingmanTransform = WingmanTransformList:Get(CurPositionIndex)
      end
      if PetTransFormList and CurPositionIndex < PetTransFormList:Num() then
        TempPetTransform = PetTransFormList:Get(CurPositionIndex)
      end
      CurPositionIndex = CurPositionIndex + 1
      local LuaIndex = CurPositionIndex
      print(bWriteLog and "BornIslandTeamShowSubSystem:CreateDataForShow MatePlayerState.nWingman_skin:", MatePlayerState.nWingman_skin, " MatePlayerState.nVst_skin:", MatePlayerState.nVst_skin, " LuaIndex:", LuaIndex)
      self.PendingPawnDataList[LuaIndex] = {
        LuaIndex,
        MatePlayerState,
        TempTransform
      }
      self.PendingPetDataList[LuaIndex] = {
        LuaIndex,
        MatePlayerState,
        TempPetTransform
      }
      self.PendingCarDataList[LuaIndex] = {
        LuaIndex,
        MatePlayerState,
        TempCarTransform
      }
      self.PendingWingmanDataList[LuaIndex] = {
        LuaIndex,
        MatePlayerState,
        TempWingmanTransform
      }
      local SyncData = self:GetPawnSyncDataBySlot(MatePlayerState)
      if SyncData then
        self.PlayerAvatarItem[LuaIndex] = SyncData.ItemID
        self.PlayerAvatarShapeID[LuaIndex] = SyncData.CustomInfo.ShapeInfo
      end
      self.PlayerClothSchemeMap[LuaIndex] = self:_GetMateClothSchemeMap(MatePlayerState)
      self.PlayerXSuitUnlockMap[LuaIndex] = self:_GetMateXSuitUnlockMap(MatePlayerState)
      local NicknameColorManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NicknameColorManager)
      NicknameColorManager:SetUserData(MatePlayerState.UID, MatePlayerState.NicknameColor)
      local TempUIData = {}
      local TempUpassInfo = {
        upassKeepBuy = MatePlayerState.UpassKeepBuy,
        isBuy = MatePlayerState.UpassIsBuy,
        upassCurValue = MatePlayerState.UpassCurValue,
        upassShow = MatePlayerState.UpassShow,
        pass_type = MatePlayerState.pass_type
      }
      TempUIData.UID = MatePlayerState.UID
      TempUIData.Gender = MatePlayerState.Gender
      TempUIData.PlayerName = MatePlayerState.PlayerName
      TempUIData.UpassInfo = TempUpassInfo
      TempUIData.nWingman_skin = MatePlayerState.nWingman_skin
      TempUIData.nVst_skin = MatePlayerState.nVst_skin
      TempUIData.bShowSubscribe = MatePlayerState.bShowSubscribe
      TempUIData.CollectScore = MatePlayerState.CollectScore
      TempUIData.SeasonCollectScore = MatePlayerState.SeasonCollectScore
      TempUIData.CollectScorePrivacy = MatePlayerState.CollectScorePrivacy
      TempUIData.CardCollectCareerScore = MatePlayerState.CardCollectCareerScore
      if MatePlayerState.IntimacyValue and 0 < MatePlayerState.IntimacyValue then
        TempUIData.intimacy = MatePlayerState.IntimacyValue
        TempUIData.relation = MatePlayerState.IntimacyRelation
        TempUIData.friend_uid = MatePlayerState.IntimacyTargetUID
      end
      table.insert(self.UIShowData, TempUIData)
    end
  end
  local TimeInterval = 0.05
  self.CreateObjectTimer = self:AddGameTimer(TimeInterval, true, function()
    self:CreateObjectEveryFrame()
  end)
end
function BornIslandTeamShowSubSystem:BeginShow()
  print(bWriteLog and "BornIslandTeamShowSubSystem:BeginShow")
  if Game:IsFightingState() then
    print(bWriteLog and "BornIslandTeamShowSubSystem:BeginShow IsFightingState, Return!!!!")
    return
  end
  if self.HadCreatedActorForShow == false then
    print(bWriteLog and "BornIslandTeamShowSubSystem:BeginShow self.HadCreatedActorForShow == false, Return!!!!")
    return
  end
  self.ShowState = ShowStateEnum.Showing
  self.AdjustFpsTemporarily(true)
  self:ReadyToShow()
  self:HandleObjectVisibility(nil, self.PlayerPawnList)
  for _, TPawn in pairs(self.PlayerPawnList) do
    if slua.isValid(TPawn) and slua.isValid(TPawn.CharacterAvatarComp2_BP) then
      TPawn:ResetSkirtParticles()
    end
  end
  self:PlayPlayerAnim()
  self:ShowPetEffect()
  self:HandleObjectVisibility(nil, self.PetObjectList)
  self:HandleObjectVisibility(nil, self.CarObjectList)
  self:HandleObjectVisibility(nil, self.WingmanObjectList)
  self:InitUIAndShow(self.UIShowData)
  if slua.isValid(self.SeqActor) then
    self.SeqActor:Play(0)
  end
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:LuaHideJoystickWidgetWithTag("BornIslandTeamShowUI")
  end
end
function BornIslandTeamShowSubSystem:EndShow()
  self.SpecialVehicleObjTable = {}
  self.AccessoryVehicleObjCacheTable = {}
  if slua.isValid(self.SeqActor) then
    self.SeqActor:K2_DestroyActor()
    self.SeqActor = nil
  end
  if self.PlayerPawnList then
    for _, Pawn in pairs(self.PlayerPawnList) do
      if slua.isValid(Pawn) then
        Pawn:K2_DestroyActor()
      end
    end
    self.PlayerPawnList = {}
  end
  if self.CarObjectList then
    for _, Car in pairs(self.CarObjectList) do
      if slua.isValid(Car) then
        Car:K2_DestroyActor()
      end
    end
    self.CarObjectList = {}
  end
  if self.WingmanObjectList then
    for _, Wingman in pairs(self.WingmanObjectList) do
      if slua.isValid(Wingman) then
        Wingman:K2_DestroyActor()
      end
    end
    self.WingmanObjectList = {}
  end
  if self.PetObjectList then
    for _, Pet in pairs(self.PetObjectList) do
      if slua.isValid(Pet) then
        Pet:K2_DestroyActor()
      end
    end
    self.PetObjectList = {}
  end
  if slua.isValid(self.PlayerTransformClassObject) then
    self.PlayerTransformClassObject:K2_DestroyActor()
  end
  if self.CachedPlayerMiniTvInfo then
    for _, Info in pairs(self.CachedPlayerMiniTvInfo) do
      if Info and slua.isValid(Info.MiniTvActor) then
        Info.MiniTvActor:K2_DestroyActor()
      end
    end
  end
  self.UIShowData = {}
  self.CarObjectClass = nil
  self.LobbyCarObjectClass = nil
  self.WingmanObjectClass = nil
  self.PlayerTransformClassObject = nil
  self.PlayerTransformClass = nil
  self.BornislandTeamShowUIAsset = nil
  self.playerLobbyPawnClass = nil
  self.TraceGroundIgnoreList = nil
  self.PlayerHadOffset = {}
  self.NeedHiddenClassTable = {}
  self.PreCacheTableAsset = {}
  self.PreCachePetAsset = {}
  self.PendingPawnDataList = {}
  self.PendingPetDataList = {}
  self.PendingCarDataList = {}
  self.PendingWingmanDataList = {}
  self.HavePlayedAnim = false
  self:ClearCreateTimer()
  self.PlayerAvatarItem = {}
  self.PlayerClothSchemeMap = {}
  self.PlayerXSuitUnlockMap = {}
  self.CachePlayerInfoList = {}
  self:UnRegistEvents()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:LuaShowJoystickWidgetWithTag("BornIslandTeamShowUI")
  end
  if self.ShowState == ShowStateEnum.EndShow or self.ShowState == ShowStateEnum.None then
    print(bWriteLog and "BornIslandTeamShowSubSystem:EndShow show ended, so return")
    return
  end
  print(bWriteLog and "BornIslandTeamShowSubSystem:EndShow")
  self.ShowState = ShowStateEnum.EndShow
  self:FinishedShow()
  self:AddGameTimer(2, false, function()
    local UI
    if not self:IsLowDevice() then
      UI = UIManager.GetUI(UIManager.UI_Config_InGame.BornIslandTeamShowUI)
    else
      UI = UIManager.GetUI(UIManager.UI_Config_InGame.BornIslandTeamShowUILow)
    end
    if UI and not UI._IsClosed then
      if not self:IsLowDevice() then
        UIManager.CloseUI(UIManager.UI_Config_InGame.BornIslandTeamShowUI)
      else
        UIManager.CloseUI(UIManager.UI_Config_InGame.BornIslandTeamShowUILow)
      end
    end
  end)
end
function BornIslandTeamShowSubSystem:CreateSingleRole()
  local SingleActor
  if not self.playerLobbyPawnClass then
    return
  end
  local world = slua_GameFrontendHUD:GetWorld()
  SingleActor = world:SpawnActor(self.playerLobbyPawnClass, FVector(0, 0, 0), FRotator(0, 0, 0), nil)
  SingleActor.canRotate = false
  return SingleActor
end
function BornIslandTeamShowSubSystem:GetPlayerTransformList(PlayerNum, SpawnLocation, SpawnRotator)
  local Transform, CarTransform, WingmanTransform, PetTransform
  if self.PlayerTransformClass then
    local world = slua_GameFrontendHUD:GetWorld()
    local SequenceScale = self.ShowConfig.SequenceScale or FVector(1, 1, 1)
    local TempTran = UKismetMathLibrary.MakeTransform(SpawnLocation, SpawnRotator, SequenceScale)
    self.PlayerTransformClassObject = world:SpawnActor(self.PlayerTransformClass, FVector(0, 0, 0), FRotator(0, 0, 0), nil)
    if slua.isValid(self.PlayerTransformClassObject) and self.PlayerTransformClassObject.GetTransfroms and self.PlayerTransformClassObject.GetCarTransfroms and self.PlayerTransformClassObject.GetWingmanTransfroms and self.PlayerTransformClassObject.GetPetTransfroms then
      self.PlayerTransformClassObject:K2_SetActorTransform(TempTran, false, nil, false)
      Transform = self.PlayerTransformClassObject:GetTransfroms(PlayerNum)
      CarTransform = self.PlayerTransformClassObject:GetCarTransfroms(PlayerNum)
      WingmanTransform = self.PlayerTransformClassObject:GetWingmanTransfroms(PlayerNum)
      PetTransform = self.PlayerTransformClassObject:GetPetTransfroms(PlayerNum)
      print(bWriteLog and "BornIslandTeamShowSubSystem:GetPlayerTransformList PlayerTransformClassObject work well")
      self.PlayerTransformClassObject:K2_DestroyActor()
      print(bWriteLog and "BornIslandTeamShowSubSystem:GetPlayerTransformList PlayerTransformClassObject K2_DestroyActor")
      self.TraceGroundIgnoreList = slua.Array(UEnums.EPropertyClass.Object, uActor)
      for _, HideClass in pairs(self.NeedHiddenClassTable) do
        local HideActors = GameplayStatics.GetAllActorsOfClass(UIUtil.GetGameInstance(), HideClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
        for __, HideObjects in pairs(HideActors) do
          self.TraceGroundIgnoreList:Add(HideObjects)
        end
      end
      local TempLoc, TempGroundLoc
      for aIdx, aTran in pairs(Transform) do
        TempLoc = aTran:GetLocation()
        TempGroundLoc = self:TryGetGroundLocation(TempLoc) + FVector(0, 0, 90)
        if TempGroundLoc then
          aTran:SetLocation(TempGroundLoc)
          Transform:Set(aIdx, aTran)
        end
      end
      for aIdx, aTran in pairs(CarTransform) do
        TempLoc = aTran:GetLocation()
        TempGroundLoc = self:TryGetGroundLocation(TempLoc)
        if TempGroundLoc then
          aTran:SetLocation(TempGroundLoc)
          CarTransform:Set(aIdx, aTran)
        end
      end
      for aIdx, aTran in pairs(PetTransform) do
        TempLoc = aTran:GetLocation()
        TempGroundLoc = self:TryGetGroundLocation(TempLoc)
        if TempGroundLoc then
          aTran:SetLocation(TempGroundLoc)
          PetTransform:Set(aIdx, aTran)
        end
      end
    end
  end
  return Transform, CarTransform, WingmanTransform, PetTransform
end
function BornIslandTeamShowSubSystem:SetPawnData(Pawn, PlayerState, Trans, Index)
  local ComponentClass = import("CharacterAvatarComponent2")
  if slua.isValid(Pawn) and slua.isValid(PlayerState) then
    local PlayerKey = PlayerState:GetPlayerKey()
    local CacheData = self.CachePlayerInfoList[PlayerKey]
    if CacheData then
      Pawn:K2_SetActorTransform(Trans, false, nil, false)
      if CacheData.UID then
        Pawn:SetPlayerUID(CacheData.UID)
      end
      self:PutOnAvatar(Pawn, CacheData.Gender, CacheData.HeadId, CacheData.AvatarList, CacheData.NetAvatarData)
      Pawn:SetForceUseDefaultIdle(false)
      local SchemeMap = self.PlayerClothSchemeMap and self.PlayerClothSchemeMap[Index]
      if SchemeMap and slua.isValid(Pawn.CharacterAvatarComp2_BP) then
        local SchemeIDList = {}
        for SchemeID in pairs(SchemeMap) do
          if SchemeID and 0 < SchemeID then
            table.insert(SchemeIDList, SchemeID)
          end
        end
        Pawn.CharacterAvatarComp2_BP:SetClothSchemeIDList(SchemeIDList)
      end
    end
  else
    print(bWriteLog and "BornIslandTeamShowSubSystem:SetPawnData PlayerState or CharacterOwner invalid")
  end
end
function BornIslandTeamShowSubSystem:PutOnAvatar(SingleActor, sex, headId, avatarList, NetAvatarData)
  if not SingleActor then
    return
  end
  print(bWriteLog and "BornIslandTeamShowSubSystem:PutOnAvatar", sex, headId)
  if SingleActor == nil then
    return
  end
  if sex == 0 then
    SingleActor:SetMaleAnimClass()
  elseif sex == 1 then
    SingleActor:SetFemaleAnimClass()
  end
  local CharacterAvartarCom = SingleActor.CharacterAvatarComp2_BP
  if CharacterAvartarCom and NetAvatarData then
    self:FliterSynData(NetAvatarData)
    self:UpdateAvatarLevel(SingleActor, NetAvatarData)
    CharacterAvartarCom.bSyncAvatar = false
    CharacterAvartarCom.    CharacterAvartarCom:SetAvatarGender(sex)
    CharacterAvartarCom:OnRep_BodySlotStateChanged()
    return
  end
end
function BornIslandTeamShowSubSystem:UpdateAvatarLevel(Pawn, NetAvatarData)
  local Config = CDataTable.GetTable("TeamShowLowDeviceCfg")
  if Config and NetAvatarData and NetAvatarData.SlotSyncData then
    local TempSlotSyncData = slua.IndexReference(NetAvatarData, "SlotSyncData")
    for _, AvatarSynData in pairs(TempSlotSyncData) do
      if AvatarSynData.ItemID and AvatarSynData.ItemID ~= 0 and Config[AvatarSynData.ItemID] then
        print(bWriteLog and "BornIslandTeamShowSubSystem:UpdateAvatarLevel" .. tostring(AvatarSynData.ItemID))
        Pawn:SetAvatarLevel(2)
        return
      end
    end
  end
  print(bWriteLog and "BornIslandTeamShowSubSystem:UpdateAvatarLevel not Change")
end
function BornIslandTeamShowSubSystem:GetCharacterAvatarList(UCharacterAvatarComponent)
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
function BornIslandTeamShowSubSystem:ReadyToShow()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
  if IngameSelfieSubsystem then
    IngameSelfieSubsystem:ExitSelfie()
  end
  print(bWriteLog and "BornIslandTeamShowSubSystem:ReadyToShow")
  local uPlayerController = GameplayData.GetPlayerController()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if slua.isValid(MainControlBaseUI) and MainControlBaseUI.ChildrenWidgets and MainControlBaseUI.bTouchStart then
    for _, Widget in pairs(MainControlBaseUI.ChildrenWidgets) do
      if Widget and Widget.OnTurnplateBtnTouchEnd then
        Widget:OnTurnplateBtnTouchEnd()
        break
      end
    end
  end
  UAESequenceUtils:HideAllUI()
  UAESequenceUtils:ForbiddenPlayerInput(true)
  if slua.isValid(uPlayerController) then
    if slua.isValid(uPlayerController.PlayerCameraManager) and uPlayerController.PlayerCameraManager.bApplyCameraShake then
      uPlayerController.PlayerCameraManager:StopAllCameraShakes(true)
      uPlayerController.PlayerCameraManager.bApplyCameraShake = false
      self.bApplyCameraShake = true
    end
    local DecalManager = uPlayerController:GetIdeaDecalManager()
    if slua.isValid(DecalManager) then
      DecalManager:SetActorHiddenInGame(true)
    end
    uPlayerController:ExitFreeCamera(true)
  end
  local HUD = uPlayerController:GetHUD()
  if HUD then
    HUD.bShowHUD = false
  end
  if UIManager.UI_Config_InGame.EnterGameFaceGuide and UIManager.IsUIShow(UIManager.UI_Config_InGame.EnterGameFaceGuide) then
    UIManager.HideUI(UIManager.UI_Config_InGame.EnterGameFaceGuide)
  end
  if UIManager.UI_Config_InGame.IngameLikeUIBP and UIManager.IsUIShow(UIManager.UI_Config_InGame.IngameLikeUIBP) then
    UIManager.HideUI(UIManager.UI_Config_InGame.IngameLikeUIBP)
  end
  if UIManager.UI_Config_InGame.EntireMapWindow and UIManager.IsUIShow(UIManager.UI_Config_InGame.EntireMapWindow) then
    UIManager.HideUI(UIManager.UI_Config_InGame.EntireMapWindow)
  end
  if UIManager.UI_Config.setting_main and UIManager.IsUIShow(UIManager.UI_Config.setting_main) then
    UIManager.HideUI(UIManager.UI_Config.setting_main)
  end
  if UIManager.UI_Config.BattleReportBug and UIManager.IsUIShow(UIManager.UI_Config.BattleReportBug) then
    UIManager.HideUI(UIManager.UI_Config.BattleReportBug)
  end
  local uGameInstance = UIUtil.GetGameInstance()
  local uClass = slua.loadClass(PawnClassPath)
  self.Actors = GameplayStatics.GetAllActorsOfClass(uGameInstance, uClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
  for _, PlayerActor in pairs(self.Actors) do
    if slua.isValid(PlayerActor) then
      self:SetPetEnable(PlayerActor, false)
      PlayerActor:SetActorHiddenInGame(true)
      if PlayerActor:HasState(EPawnState.HoldGrenade) then
        PlayerActor:DestroyGrenadeAndSwitchBackToPreviousWeaponOnServer()
        print(bWriteLog and "BornIslandTeamShowSubSystem:ReadyToShow PlayerActor:HasState(EPawnState.HoldGrenade) DestroyGrenade")
      end
    end
  end
  if slua.isValid(uPlayerCharacter) and uPlayerCharacter.SwitchWeaponBySlot then
    local ESurviveWeaponPropSlotDef = import("ESurviveWeaponPropSlot")
    uPlayerCharacter:SwitchWeaponBySlot(ESurviveWeaponPropSlotDef.SWPS_None, false, true, true)
  end
  uClass = slua.loadClass(CarClassPath)
  local CarsInBorn = GameplayStatics.GetAllActorsOfClass(uGameInstance, uClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
  for _, Obj in pairs(CarsInBorn) do
    if slua.isValid(Obj) and Obj.Mesh then
      Obj:SetActorHiddenInGame(true)
    end
  end
  print(bWriteLog and "BornIslandTeamShowSubSystem:ReadyToShow Handle NeedHiddenClassPath")
  for _, ClassPath in pairs(self.NeedHiddenClassPath) do
    Util.GetAssetAsync(ClassPath .. "_C", function(TClassObject)
      if TClassObject then
        local uTempClass = slua.loadClass(ClassPath)
        local HiddenObjeInBorn = GameplayStatics.GetAllActorsOfClass(uGameInstance, uTempClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
        for _, Obj in pairs(HiddenObjeInBorn) do
          if slua.isValid(Obj) then
            Obj:SetActorHiddenInGame(true)
          end
        end
        print(bWriteLog and "BornIslandTeamShowSubSystem:ReadyToShow NeedHiddenClassPath:", ClassPath)
      else
        print(bWriteLog and "BornIslandTeamShowSubSystem:ReadyToShow Error NeedHiddenClassPath:", ClassPath)
      end
    end)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_TEAM_SHOW_READY)
end
function BornIslandTeamShowSubSystem:FinishedShow()
  print(bWriteLog and "BornIslandTeamShowSubSystem:FinishedShow")
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    if slua.isValid(uPlayerController.PlayerCameraManager) and self.bApplyCameraShake then
      uPlayerController.PlayerCameraManager.bApplyCameraShake = true
      self.bApplyCameraShake = nil
    end
    local DecalManager = uPlayerController:GetIdeaDecalManager()
    if slua.isValid(DecalManager) then
      DecalManager:SetActorHiddenInGame(false)
    end
  end
  UAESequenceUtils:ForbiddenPlayerInput(false)
  UAESequenceUtils:RecoveryUI()
  if not self.Actors then
    local uGameInstance = UIUtil.GetGameInstance()
    local uClass = slua.loadClass(PawnClassPath)
    self.Actors = GameplayStatics.GetAllActorsOfClass(uGameInstance, uClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
  end
  for _, PlayerActor in pairs(self.Actors) do
    if slua.isValid(PlayerActor) and slua.isValid(uPlayerController) then
      if not PlayerActor:HasState(EPawnState.InPlane) then
        PlayerActor:SetActorHiddenInGame(false)
      end
      self:SetPetEnable(PlayerActor, true)
    end
  end
  self.Actors = nil
  self.AdjustFpsTemporarily(false)
  if not slua.isValid(uPlayerController) then
    return
  end
  local HUD = uPlayerController:GetHUD()
  if HUD then
    HUD.bShowHUD = true
  end
  if uPlayerController and uPlayerController:IsInPlane() or not GameStatus.IsInFightingStatus() then
    uPlayerController:ShowTouchInterface(false)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_TEAM_SHOW_END)
end
function BornIslandTeamShowSubSystem:IsNeedSlotType(SlotTypeID, SubSlotID)
  local EAvatarSlotType = import("EAvatarSlotType")
  if SlotTypeID == EAvatarSlotType.EAvatarSlotType_BackpackEquipemtSlot or SlotTypeID == EAvatarSlotType.EAvatarSlotType_FootEffectEquipemtSlot or SlotTypeID == EAvatarSlotType.EAvatarSlotType_GlideEquipemtSlot or SlotTypeID == EAvatarSlotType.EAvatarSlotType_HandEffectEquipemtSlot or SlotTypeID == EAvatarSlotType.EAvatarSlotType_BackPack_PendantSlot or SlotTypeID == EAvatarSlotType.EAvatarSlotType_ArmorEquipemtSlot or SlotTypeID == EAvatarSlotType.EAvatarSlotType_ParachuteEquipemtSlot then
    return false
  end
  return true
end
function BornIslandTeamShowSubSystem:InitUIAndShow(Data)
  self:AddGameTimer(self.UIDelayShowTime, false, function()
    if not Data then
      return
    end
    if not self:IsLowDevice() then
      UIManager.ShowUI(UIManager.UI_Config_InGame.BornIslandTeamShowUI, Data)
    else
      UIManager.ShowUI(UIManager.UI_Config_InGame.BornIslandTeamShowUILow, Data)
    end
  end)
end
function BornIslandTeamShowSubSystem:TryGetGroundLocation(TryLocation)
  local RayStart = TryLocation + FVector(0, 0, 200)
  local RayEnd = TryLocation - FVector(0, 0, 400)
  local bHit, uHitResult = UKismetSystemLibrary.LineTraceSingle(UIUtil.GetGameInstance(), RayStart, RayEnd, 6, true, self.TraceGroundIgnoreList, 0, uHitResult, true, FLinearColor.Red, FLinearColor.Green, 1)
  if bHit and uHitResult and uHitResult.Location then
    local DragLocation = FVector(uHitResult.Location.X, uHitResult.Location.Y, uHitResult.Location.Z)
    return DragLocation
  end
  return TryLocation
end
function BornIslandTeamShowSubSystem:CreateCarObject(PlayerState, Trans, Index)
  if not slua.isValid(PlayerState) then
    return
  end
  local CarSkinID = PlayerState and PlayerState.nVst_skin or 0
  if CarSkinID <= 0 then
    print(bWriteLog and "BornIslandTeamShowSubSystem:CreateCarObject return CarSkinID <= 0")
    return nil
  end
  if not self:CheckIsDownloaded(CarSkinID) then
    print(bWriteLog and "BornIslandTeamShowSubSystem:CreateCarObject return CheckIsDownloaded")
    return nil
  end
  if not self.LobbyCarObjectClass then
    print(bWriteLog and "BornIslandTeamShowSubSystem:CreateCarObject return LobbyCarObjectClass")
    return nil
  end
  if not self:CheckItemLevel(CarSkinID) then
    print(bWriteLog and "BornIslandTeamShowSubSystem:CreateCarObject return CheckItemLevel")
    return nil
  end
  local ItemSubType = self:GetItemSubType(CarSkinID)
  local DefaultScale = self:GetScaleByItemSubType(ItemSubType)
  if ItemSubType == ENUM_ITEM_SUBTYPE.Tank then
    print(bWriteLog and "BornIslandTeamShowSubSystem:CreateCarObject CheckIsTank")
    ActorTools.SpawnActorAsync(PlayerState, LobbyTankPath .. "_C", FVector(0, 0, 0), FRotator(0, 0, 0), FVector(1, 1, 1), function(CarObj)
      if slua.isValid(CarObj) then
        CarObj:K2_SetActorTransform(Trans, false, nil, false)
        CarObj:SetActorScale3D(DefaultScale)
        if CarObj.BP_VehicleAvatarComponentTank and CarObj.BP_VehicleAvatarComponentTank.PreChangeVehicleAvatar then
          CarObj.VehicleAvatarComponent_BP.bIsLobbyAvatar = false
          CarObj.BP_VehicleAvatarComponentTank:PreChangeVehicleAvatar(CarSkinID)
        end
        self:HandleObjectVisibility(CarObj, self.CarObjectList)
      end
    end)
    return
  end
  local CarObj = ActorTools.SpawnActor(PlayerState, LobbyVehiclePath, FVector(0, 0, 0), FRotator(0, 0, 0), FVector(1, 1, 1))
  if slua.isValid(CarObj) then
    CarObj:K2_SetActorTransform(Trans, false, nil, false)
    CarObj:SetActorScale3D(DefaultScale)
    if CarObj.VehicleAvatarComponent_BP and CarObj.VehicleAvatarComponent_BP.PreChangeVehicleAvatar then
      CarObj.VehicleAvatarComponent_BP.bIsLobbyAvatar = false
      CarObj.VehicleAvatarComponent_BP:PreChangeVehicleAvatar(CarSkinID)
      CarObj.VehicleAvatarComponent_BP:PreChangeHighTireLight(CarSkinID, PlayerState.bEnableTireLight)
      CarObj.bIsProhibitOpenDoorAnim = true
    end
    local RefitInfo = CDataTable.GetTableData("VehicleRefitInfo", CarSkinID)
    if RefitInfo and RefitInfo.vehicle_group_id and RefitInfo.vehicle_group_id <= 3 then
      local ds_net = require("ds_net")
      local PlayerKey = PlayerState:GetPlayerKey()
      ds_net.SendMessage("ingame_teamshow_car_info", {PlayerKey = PlayerKey, CarItemID = CarSkinID})
      self.SpecialVehicleObjTable[PlayerKey] = CarObj
    end
    self:CheckAndReqVehicleAccessoryData(PlayerState, CarSkinID, CarObj)
    if CarObj.BP_VehicleDIYComp then
      CarObj.BP_VehicleDIYComp:UpdateCarOwnerInLobby(PlayerState.UID, CarSkinID)
    end
    return CarObj
  end
  print(bWriteLog and "BornIslandTeamShowSubSystem:CreateCarObject return CarObj")
  return nil
end
function BornIslandTeamShowSubSystem:OnVehicleLoadFinish(CarObj)
  if not slua.isValid(CarObj) then
    return
  end
  print(bWriteLog and "BornIslandTeamShowSubSystem:OnVehicleLoadFinish")
  self:RemoveControlEvent(CarObj.VehicleAvatarComponent_BP, "VehicleAvatarEqiuped")
  local animInstance = CarObj.Mesh:GetAnimInstance()
  if not slua.isValid(animInstance) then
    print(bWriteLog and "BornIslandTeamShowSubSystem:OnVehicleLoadFinish not slua.isValid(animInstance)")
    return
  end
  animInstance.isProhibitOpenDoorAnim = true
end
function BornIslandTeamShowSubSystem:CreateWingmanObject(PlayerState, Trans, Index)
  if not slua.isValid(PlayerState) then
    return
  end
  local WingmanSkinID = PlayerState and PlayerState.nWingman_skin or 0
  if WingmanSkinID <= 0 then
    print(bWriteLog and "BornIslandTeamShowSubSystem:CreateWingmanObject return WingmanSkinID <= 0")
    return nil
  end
  if not self:CheckIsDownloaded(WingmanSkinID) then
    print(bWriteLog and "BornIslandTeamShowSubSystem:CreateWingmanObject return CheckIsDownloaded")
    return nil
  end
  if not self.WingmanObjectClass then
    print(bWriteLog and "BornIslandTeamShowSubSystem:CreateWingmanObject return WingmanObjectClass")
    return nil
  end
  if not self:CheckItemLevel(WingmanSkinID) then
    print(bWriteLog and "BornIslandTeamShowSubSystem:CreateWingmanObject return CheckItemLevel")
    return nil
  end
  local WingmanObj = ActorTools.SpawnActor(PlayerState, WingmanClassPath, FVector(0, 0, 0), FRotator(0, 0, 0), FVector(1, 1, 1))
  if slua.isValid(WingmanObj) then
    WingmanObj:K2_SetActorTransform(Trans, false, nil, false)
    if WingmanObj.WingmanAvatarComp_BP and WingmanObj.WingmanAvatarComp_BP.PreChangeWingmanAvatar then
      WingmanObj.WingmanAvatarComp_BP.bIsLobbyAvatar = false
      WingmanObj.WingmanAvatarComp_BP.bIsLobbyActor = false
      WingmanObj.WingmanAvatarComp_BP.bUseLobbyAnim = true
      WingmanObj.WingmanAvatarComp_BP:PreChangeWingmanAvatar(WingmanSkinID)
    end
    return WingmanObj
  end
  print(bWriteLog and "BornIslandTeamShowSubSystem:CreateWingmanObject return WingmanObj")
  return nil
end
function BornIslandTeamShowSubSystem:CheckIsDownloaded(SkinId)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local dowloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {SkinId})
  print(bWriteLog and "BornIslandTeamShowSubSystem:CheckIsDownloaded skinId = " .. tostring(SkinId) .. ", state = " .. tostring(dowloadState))
  return dowloadState == ENUM_DownloadState.Done
end
function BornIslandTeamShowSubSystem:CheckItemLevel(SkinId)
  local ItemData = UIUtil.GetItemCfg(SkinId)
  if ItemData and ItemData.ItemQuality >= self.MinItemQuality then
    return true
  end
  return false
end
function BornIslandTeamShowSubSystem:GetItemSubType(SkinId)
  local ItemData = UIUtil.GetItemCfg(SkinId)
  if ItemData and ItemData.ItemSubType then
    return ItemData.ItemSubType
  end
  return 0
end
function BornIslandTeamShowSubSystem:GetScaleByItemSubType(ItemSubType)
  if self.ShowConfig and self.ShowConfig.ItemSubTypeDefaultScale then
    local Val = self.ShowConfig.ItemSubTypeDefaultScale[ItemSubType]
    if Val and 0 < Val then
      return FVector(Val, Val, Val)
    end
  end
  return FVector(1, 1, 1)
end
function BornIslandTeamShowSubSystem:GetCurrentConfig()
  if self.ShowConfig then
    return self.ShowConfig
  end
end
function BornIslandTeamShowSubSystem:SetPetEnable(uPlayer, bEnable)
  if slua.isValid(uPlayer) then
    print(bWriteLog and "BornIslandTeamShowSubSystem:SetPetEnable bEnable:", bEnable, " uPlayer:", uPlayer)
    if uPlayer.PetComponent_BP then
      if bEnable then
        uPlayer.PetComponent_BP:SetPetActorHiddenInGameMask(false, 3)
      else
        uPlayer.PetComponent_BP:SetPetActorHiddenInGameMask(true, 3)
      end
    end
  end
end
function BornIslandTeamShowSubSystem:CreatePetForShow(uPlayerState, PetTransform, Index)
  if not slua.isValid(uPlayerState) or not PetTransform then
    print(bWriteLog and "BornIslandTeamShowSubSystem:CreatePetForShow 1")
    return
  end
  local PlayerKey = uPlayerState:GetPlayerKey()
  local CacheData = self.CachePlayerInfoList[PlayerKey]
  if CacheData and CacheData.PetId then
    self:CreatePetRole(CacheData.PetId, CacheData.PetLevel, CacheData, PetTransform, false, PlayerKey)
    print(bWriteLog and "BornIslandTeamShowSubSystem:CreatePetForShow Create Pet with cache data")
  end
  if not CacheData or CacheData.PetId ~= 50000 then
    if LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MINI_TV_REV) then
      local bMiniTvSwitch = false
      local UIUtil = require("client.common.ui_util")
      local uGameFrontendHUD = UIUtil.GetFirstGameFrontendHUD()
      if uGameFrontendHUD then
        local uSettingConfig = uGameFrontendHUD:GetUserSettings()
        if slua.isValid(uSettingConfig) then
          local UID = CacheData and CacheData.UID
          local bSelf = tostring(UID) == DataMgr.roleData.uid
          local MiniTvSwitchKey = bSelf and "ShowMiniTvInFighting" or "ShowOtherMiniTvInFighting"
          bMiniTvSwitch = uSettingConfig[MiniTvSwitchKey]
          log(bWriteLog and "BornIslandTeamShowSubSystem:CreatePetForShow key: " .. tostring(MiniTvSwitchKey) .. " bMiniTvSwitch: " .. tostring(bMiniTvSwitch))
        end
      end
      if bMiniTvSwitch then
        local uPlayerController = GameplayData.GetPlayerController()
        if slua.isValid(uPlayerController) and uPlayerController.CommerFeature and uPlayerController.CommerFeature.bEnableMiniTV then
          local DefaultMiniTvDressID = 1601019
          local MiniTvDressID
          local UID = CacheData and tonumber(CacheData.UID)
          if UID then
            MiniTvDressID = uPlayerController.CommerFeature.TeamMemberMiniTvDressID and uPlayerController.CommerFeature.TeamMemberMiniTvDressID[UID]
          end
          if not MiniTvDressID then
            MiniTvDressID = DefaultMiniTvDressID
          elseif not self:CheckIsDownloaded(MiniTvDressID) then
            log(bWriteLog and "BornIslandTeamShowSubSystem:CreatePetForShow MiniTv skin not downloaded, use default. originID: " .. tostring(MiniTvDressID))
            MiniTvDressID = DefaultMiniTvDressID
          end
          local Transform = PetTransform:GetLocation() + FVector(100, 0, 0)
          local Rotator = PetTransform:Rotator()
          local Scale = PetTransform:GetScale3D()
          local MiniTVTransform = UKismetMathLibrary.MakeTransform(Transform, Rotator, Scale)
          local MiniTvPawnData = {}
          if MiniTvDressID then
            MiniTvPawnData.PetAvatarID = {MiniTvDressID}
          end
          self:CreatePetRole(50000, 1, MiniTvPawnData, MiniTVTransform, true, PlayerKey)
        end
      else
        log(bWriteLog and "BornIslandTeamShowSubSystem:CreatePetForShow bMiniTvSwitch is false.")
      end
    else
      log(bWriteLog and "BornIslandTeamShowSubSystem:CreatePetForShow switcher BP_ENUM_LOBBY_MINI_TV_REV is closed.")
    end
  end
end
function BornIslandTeamShowSubSystem:CreatePetRole(PetID, PetLevel, RealPetPawnData, PetTransform, bMiniTv, PlayerKey)
  print(bWriteLog and "BornIslandTeamShowSubSystem:CreatePetRole", PetID, PetLevel, RealPetPawnData, bMiniTv, PlayerKey)
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  local curPetLevelData = logic_pet:GetPetLevelItemCfg(PetID, PetLevel)
  if nil == curPetLevelData or nil == curPetLevelData.LobbyPetBP then
    print(bWriteLog and "BornIslandTeamShowSubSystem:CreatePetRole GetPetLevelItemCfg failed!", PetID, PetLevel)
    return nil
  end
  print(bWriteLog and "BornIslandTeamShowSubSystem:CreatePetRole LobbyPetBP", curPetLevelData.LobbyPetBP)
  local softObjPath = UKismetSystemLibrary.MakeSoftObjectPath(curPetLevelData.LobbyPetBP)
  if softObjPath == nil then
    print(bWriteLog and "BornIslandTeamShowSubSystem:CreatePetRole pet softObjPath is nil!")
    return nil
  end
  print(bWriteLog and "BornIslandTeamShowSubSystem:CreatePetRole pet softObjPath", softObjPath)
  Util.GetAssetAsync(softObjPath.AssetPathName, function(TClassObject)
    if not TClassObject then
      return
    end
    local ClassObj = STExtraBlueprintFunctionLibrary.GetClassByAssetReference(softObjPath)
    local world = slua_GameFrontendHUD:GetWorld()
    if ClassObj == nil then
      print(bWriteLog and "BornIslandTeamShowSubSystem:CreatePetRole ClassObj is nil!")
      return nil
    end
    print(bWriteLog and "BornIslandTeamShowSubSystem:CreatePetRole ClassObj", ClassObj)
    local actorObj = world:SpawnActor(ClassObj, FVector(0, 0, 0), FRotator(0, 0, 0), nil)
    if actorObj == nil then
      print(bWriteLog and "BornIslandTeamShowSubSystem:CreatePetRole spawn pet failed")
      return nil
    end
    actorObj:SetActorScale3D(FVector(1.0, 1.0, 1.0))
    actorObj:SetPetShowType(1)
    if PlayerKey then
      if not self.CachedPlayerMiniTvInfo[PlayerKey] then
        self.CachedPlayerMiniTvInfo[PlayerKey] = {}
      end
      if bMiniTv then
        self.CachedPlayerMiniTvInfo[PlayerKey].MiniTvActor = actorObj
      else
        self.CachedPlayerMiniTvInfo[PlayerKey].PetActor = actorObj
        self.CachedPlayerMiniTvInfo[PlayerKey].      end
    end
    local curPetData = logic_pet:GetPetItemCfgByPetItemID(PetID)
    if not curPetData or not curPetData.PetID then
      print(bWriteLog and "BornIslandTeamShowSubSystem:CreatePetRole GetPetItemCfgByPetItemID failed", PetID)
      return nil
    end
    log(bWriteLog and "[ZH] curPetData.PetID: " .. tostring(curPetData.PetID))
    actorObj:K2_SetActorTransform(PetTransform, false, nil, false)
    local FPetLevelInfo = import("/Script/ShadowTrackerExtra.PetLevelInfo")
    local PetLevelInfo = FPetLevelInfo()
    PetLevelInfo.PetId = PetID
    PetLevelInfo.    actorObj:InitializePet(PetLevelInfo, false)
    local bEnlarge = false
    local uPlayerController = GameplayData.GetPlayerController()
    local UID = tonumber(RealPetPawnData.UID)
    local effectItemId = 0
    if UID and slua.isValid(uPlayerController) and uPlayerController.CommerFeature then
      bEnlarge = uPlayerController.CommerFeature.TeamMemberPetID2EnlargeState and uPlayerController.CommerFeature.TeamMemberPetID2EnlargeState[UID] and uPlayerController.CommerFeature.TeamMemberPetID2EnlargeState[UID][PetID]
      effectItemId = uPlayerController.CommerFeature.TeamMemberEffectItemMap and uPlayerController.CommerFeature.TeamMemberEffectItemMap[UID] or 0
    end
    print(bWriteLog and "BornIslandTeamShowSubSystem:CreatePetRole RealPetPawnData.bEnlarged", bEnlarge)
    actorObj:ResetPetScale(bEnlarge)
    if slua.isValid(actorObj.Bubble) then
      actorObj.Bubble:SetVisibility(false, true)
    end
    if bMiniTv and slua.isValid(actorObj.Bubble) then
      Util.GetAssetAsync("/Game/Arts_Player/MiniTV/Mesh/MiniTVBubble.MiniTVBubble", function(BubbleMesh)
        if slua.isValid(BubbleMesh) and slua.isValid(actorObj) and slua.isValid(actorObj.Bubble) then
          actorObj.Bubble:SetStaticMesh(BubbleMesh)
        end
      end)
    end
    if PetID == 50023 then
      actorObj:UpdateMeshColorMaterials(RealPetPawnData.PetColor)
    end
    local PetAvatarID = RealPetPawnData.PetAvatarID
    actorObj:SetDress(PetAvatarID)
    if actorObj.PetAvatarComponent_BP and PetAvatarID then
      for i, v in pairs(PetAvatarID) do
        if tonumber(v) and 0 < tonumber(v) then
          actorObj.PetAvatarComponent_BP:PetEquipItemById(v)
          print(bWriteLog and "BornIslandTeamShowSubSystem:CreatePetRole PetEquipItemById v", v)
        end
      end
    end
    actorObj:SetEffectItemId(effectItemId)
    self:_CheckAndRefreshMiniTvAttachState(PlayerKey)
    self:HandleObjectVisibility(actorObj, self.PetObjectList)
  end)
end
function BornIslandTeamShowSubSystem:IsLowDevice()
  local gameInst = UIUtil.GetGameInstance()
  if gameInst ~= nil and gameInst:GetExactDeviceLevel() <= 0 then
    return true
  end
  return false
end
function BornIslandTeamShowSubSystem:PreReadyForShow()
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return
  end
  local VehicleUserComponent = uPlayerController:GetVehicleUserComp()
  if slua.isValid(VehicleUserComponent) and VehicleUserComponent.TryExitVehicle then
    VehicleUserComponent:TryExitVehicle()
    print(bWriteLog and "BornIslandTeamShowSubSystem:PreReadyForShow TryExitVehicle ")
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_PRE_TEAM_SHOW_READY)
end
function BornIslandTeamShowSubSystem:PreReadyForShow3()
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_PRE_TEAM_SHOW_CREATE_READY)
  print(bWriteLog and "BornIslandTeamShowSubSystem:PreReadyForShow3")
  self.ShowState = ShowStateEnum.PreReady
  self:RefreshCacheInfo(true)
  self:CreateDataForShow()
end
function BornIslandTeamShowSubSystem:PlayerMakeOffset(PlayerIndex, PlayerTemp, bFront)
  if not slua.isValid(PlayerTemp) then
    return
  end
  local TempPlayerLoc, TempOffsetVector
  if self.ShowConfig.DefaultPlayerAnimOffset then
    local ActorForward = PlayerTemp:GetActorRightVector()
    TempOffsetVector = self.ShowConfig.DefaultPlayerAnimOffset[PlayerIndex]
    if TempOffsetVector then
      TempOffsetVector = FVector(TempOffsetVector.X, TempOffsetVector.Y, TempOffsetVector.Z)
      if bFront then
        TempPlayerLoc = Game:GetActorLocation(PlayerTemp) + ActorForward * TempOffsetVector.Y
      else
        TempPlayerLoc = Game:GetActorLocation(PlayerTemp) - ActorForward * TempOffsetVector.Y
      end
      PlayerTemp:K2_SetActorLocation(TempPlayerLoc, false, nil, false)
    end
  end
end
function BornIslandTeamShowSubSystem:GetPawnAvatarData(PlayerState)
  local ComponentClass = import("CharacterAvatarComponent2")
  local AvatarList
  if slua.isValid(PlayerState) and slua.isValid(PlayerState.CharacterOwner) then
    local RealPawn = PlayerState.CharacterOwner
    local UCharacterAvatarComponent = RealPawn and RealPawn:GetComponentByClass(ComponentClass)
    if slua.isValid(UCharacterAvatarComponent) then
      AvatarList = self:GetCharacterAvatarList(UCharacterAvatarComponent)
    end
  end
  return AvatarList
end
function BornIslandTeamShowSubSystem:PlayPlayerAnim()
  print(bWriteLog and "BornIslandTeamShowSubSystem:PlayPlayerAnim")
  log_tree(bWriteLog and "BornIslandTeamShowSubSystem:PlayPlayerAnim self.PlayerAvatarItem", self.PlayerAvatarItem)
  if self.HavePlayedAnim then
    return
  end
  self.HavePlayedAnim = true
  for PlayerIndex, PlayerTemp in pairs(self.PlayerPawnList) do
    local EmoteID = -1
    local ShapeID = self.PlayerAvatarShapeID and self.PlayerAvatarShapeID[PlayerIndex] or 0
    if self.PlayerAvatarItem and self.PlayerAvatarItem[PlayerIndex] then
      print(bWriteLog and "BornIslandTeamShowSubSystem:PlayPlayerAnim playerIndex = " .. tostring(PlayerIndex) .. ", itemID = " .. tostring(self.PlayerAvatarItem[PlayerIndex]))
      EmoteID = self:GetGoldenItemEmoteID(self.PlayerAvatarItem[PlayerIndex], PlayerTemp, ShapeID)
    end
    local ShouldPlaySkinAnim = 0 < EmoteID and self:CheckIsDownloaded(EmoteID)
    if self.PlayerDefaultAnims[PlayerIndex] and not ShouldPlaySkinAnim then
      if self.PlayerAnimDelayTime > 1 then
        self:PlayerMakeOffset(PlayerIndex, PlayerTemp, true)
        self.PlayerHadOffset[PlayerIndex] = true
      end
      self:AddGameTimer(self.PlayerAnimDelayTime, false, function()
        Util.GetAssetAsync(self.PlayerDefaultAnims[PlayerIndex], function(AnimAsset)
          if self.PlayerHadOffset[PlayerIndex] then
            self:AddGameTimer(0, false, function()
              self:PlayerMakeOffset(PlayerIndex, PlayerTemp, false)
            end)
          end
          if AnimAsset and slua.isValid(PlayerTemp) then
            PlayerTemp:PlayAnimMontage(AnimAsset, 1, "Default")
          end
        end)
      end)
    elseif ShouldPlaySkinAnim then
      self:RestoreGoldenItemAppearLocation(PlayerIndex)
      if self.PlayerAnimDelayTime > 0 then
        local PrepareEmoteID = self:GetGoldenItemPrepareEmoteID(self.PlayerAvatarItem[PlayerIndex], ShapeID)
        if 0 < PrepareEmoteID and self:CheckIsDownloaded(PrepareEmoteID) then
          PlayerTemp:CharPlayEmoteByResId(PrepareEmoteID, "Default")
        end
      end
      self:AddGameTimer(self.PlayerAnimDelayTime, false, function()
        if slua.isValid(PlayerTemp) then
          PlayerTemp:CharPlayEmoteByResId(EmoteID, "Default")
        end
        print(bWriteLog and "BornIslandTeamShowSubSystem:PlayPlayerAnim EmoteID:", EmoteID)
      end)
    end
  end
end
function BornIslandTeamShowSubSystem:PlayPrepareEmote()
  local Index = #self.PlayerPawnList
  local Pawn = self.PlayerPawnList[Index]
  if not slua.isValid(Pawn) then
    print(bWriteLog and "BornIslandTeamShowSubSystem:PlayPrepareEmote not pawn")
    return
  end
  if self.PlayerAvatarItem and self.PlayerAvatarItem[Index] then
    local ShapeID = self.PlayerAvatarShapeID and self.PlayerAvatarShapeID[Index] or 0
    local EmoteID = self:GetGoldenItemEmoteID(self.PlayerAvatarItem[Index], Pawn, ShapeID)
    if 0 < EmoteID and self:CheckIsDownloaded(EmoteID) then
      self:UpdateGoldenItemLocation(self.PlayerAvatarItem[Index], Pawn, ShapeID)
      self:AdjuectGoldenItemAppearLocation(Index)
      local PrepareEmoteID = self:GetGoldenItemPrepareEmoteID(self.PlayerAvatarItem[Index], ShapeID)
      if 0 < PrepareEmoteID and self:CheckIsDownloaded(PrepareEmoteID) then
        Pawn:CharPlayEmoteByResId(PrepareEmoteID, "Default")
        Pawn:PreparePlayEmote(EmoteID)
      end
    end
  end
end
function BornIslandTeamShowSubSystem:CreateObjectEveryFrame()
  print(bWriteLog and "BornIslandTeamShowSubSystem:CreateObjectEveryFrame ")
  if TableUtil.CountTable(self.PendingPawnDataList) > 0 then
    local Params = self:TableGetFirstAndRemove(self.PendingPawnDataList)
    local SingleRole = self:CreateSingleRole()
    self:SetPawnData(SingleRole, Params[2], Params[3], Params[1])
    self:HandleObjectVisibility(SingleRole, self.PlayerPawnList)
    print(bWriteLog and "BornIslandTeamShowSubSystem:CreateObjectEveryFrame CreateSingleRole")
    self.HadCreatedActorForShow = true
    self:PlayPrepareEmote()
    return
  end
  if 0 < TableUtil.CountTable(self.PendingPetDataList) then
    local Params = self:TableGetFirstAndRemove(self.PendingPetDataList)
    self:CreatePetForShow(Params[2], Params[3], Params[1])
    print(bWriteLog and "BornIslandTeamShowSubSystem:CreateObjectEveryFrame CreatePetForShow")
    return
  end
  if 0 < TableUtil.CountTable(self.PendingCarDataList) then
    local Params = self:TableGetFirstAndRemove(self.PendingCarDataList)
    local CarObj = self:CreateCarObject(Params[2], Params[3], Params[1])
    self:HandleObjectVisibility(CarObj, self.CarObjectList)
    print(bWriteLog and "BornIslandTeamShowSubSystem:CreateObjectEveryFrame CreateCarObject")
    return
  end
  if 0 < TableUtil.CountTable(self.PendingWingmanDataList) then
    local Params = self:TableGetFirstAndRemove(self.PendingWingmanDataList)
    local WingmanObj = self:CreateWingmanObject(Params[2], Params[3], Params[1])
    self:HandleObjectVisibility(WingmanObj, self.WingmanObjectList)
    print(bWriteLog and "BornIslandTeamShowSubSystem:CreateObjectEveryFrame CreateWingmanObject")
    return
  end
  self:ClearCreateTimer()
  print(bWriteLog and "BornIslandTeamShowSubSystem:CreateObjectEveryFrame Finish")
end
function BornIslandTeamShowSubSystem:ClearCreateTimer()
  if self.CreateObjectTimer then
    Game:ClearTimer(self.CreateObjectTimer)
    self.CreateObjectTimer = nil
  end
end
function BornIslandTeamShowSubSystem:GetGoldenItemEmoteID(ItemID, PlayerPawn, ShapeID)
  print(bWriteLog and "BornIslandTeamShowSubSystem:GetGoldenItemEmoteID " .. tostring(ItemID))
  if not self:_IsTeamEnterAction2Unlocked(ItemID, PlayerPawn) then
    print(bWriteLog and "BornIslandTeamShowSubSystem:GetGoldenItemEmoteID not unlock " .. tostring(ItemID))
    return -1
  end
  local SchemeEmoteID = self:_TryGetTeamShowSchemeEmoteID(ItemID, PlayerPawn)
  if SchemeEmoteID and 0 < SchemeEmoteID then
    print(bWriteLog and "BornIslandTeamShowSubSystem:GetGoldenItemEmoteID by Scheme RelateItem:", SchemeEmoteID)
    return SchemeEmoteID
  end
  local EmoteTableData = self:_GetBornIslandShowEmoteDataCfg(ItemID, ShapeID)
  if EmoteTableData then
    print(bWriteLog and "BornIslandTeamShowSubSystem:GetGoldenItemEmoteID EmotionID" .. tostring(EmoteTableData.EmotionID))
    return EmoteTableData.EmotionID
  end
  return -1
end
function BornIslandTeamShowSubSystem:GetGoldenItemPrepareEmoteID(ItemID, ShapeID)
  print(bWriteLog and "BornIslandTeamShowSubSystem:GetGoldenItemPrepareEmoteID " .. tostring(ItemID))
  local EmoteTableData = self:_GetBornIslandShowEmoteDataCfg(ItemID, ShapeID)
  if EmoteTableData then
    print(bWriteLog and "BornIslandTeamShowSubSystem:GetGoldenItemPrepareEmoteID EmotionID" .. tostring(EmoteTableData.PrepareEmotionID))
    return EmoteTableData.PrepareEmotionID
  end
  return -1
end
function BornIslandTeamShowSubSystem:_GetMateClothSchemeMap(PlayerState)
  local ComponentClass = import("CharacterAvatarComponent2")
  if slua.isValid(PlayerState) and slua.isValid(PlayerState.CharacterOwner) then
    local RealPawn = PlayerState.CharacterOwner
    local UCharacterAvatarComponent = RealPawn and RealPawn:GetComponentByClass(ComponentClass)
    if slua.isValid(UCharacterAvatarComponent) and UCharacterAvatarComponent.ClothSchemeIDMap then
      return UCharacterAvatarComponent.ClothSchemeIDMap
    end
  end
  return nil
end
function BornIslandTeamShowSubSystem:_GetMateXSuitUnlockMap(PlayerState)
  local ComponentClass = import("CharacterAvatarComponent2")
  if slua.isValid(PlayerState) and slua.isValid(PlayerState.CharacterOwner) then
    local RealPawn = PlayerState.CharacterOwner
    local UCharacterAvatarComponent = RealPawn and RealPawn:GetComponentByClass(ComponentClass)
    if slua.isValid(UCharacterAvatarComponent) and UCharacterAvatarComponent.XSuitUnlockFeatureMap then
      return UCharacterAvatarComponent.XSuitUnlockFeatureMap
    end
  end
  return nil
end
function BornIslandTeamShowSubSystem:_IsTeamEnterAction2Unlocked(ItemID, PlayerPawn)
  if not slua.isValid(PlayerPawn) then
    return true
  end
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  local Period = XSuitUtil:GetPeriodByItemId(ItemID)
  if not Period or Period <= 0 then
    return true
  end
  local Branch = XSuitUtil:GetBranchIdByItemId(ItemID)
  if not Branch then
    return true
  end
  local UnLockFeatureType = require("GameLua.Activity.Commercialize.GamePlay.XSuit.UnLockFeatureType")
  local needUnlock, level, index = XSuitUtil:IsUnlockedFeature(Period, Branch, UnLockFeatureType.TeamEnterAction2)
  if not needUnlock then
    return true
  end
  local UnlockMap
  if self.PlayerPawnList and self.PlayerXSuitUnlockMap then
    for Index, P in pairs(self.PlayerPawnList) do
      if P == PlayerPawn then
        UnlockMap = self.PlayerXSuitUnlockMap[Index]
        break
      end
    end
  end
  if not UnlockMap then
    return false
  end
  if UnlockMap[Period] and UnlockMap[Period][Branch] and UnlockMap[Period][Branch][level] and UnlockMap[Period][Branch][level][index] and UnlockMap[Period][Branch][level][index].state == 1 then
    return true
  end
  return false
end
function BornIslandTeamShowSubSystem:_TryGetTeamShowSchemeEmoteID(ItemID, PlayerPawn)
  if not slua.isValid(PlayerPawn) then
    return nil
  end
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  local Period = XSuitUtil:GetPeriodByItemId(ItemID)
  local Branch = XSuitUtil:GetBranchIdByItemId(ItemID)
  if not Period or Period <= 0 or not Branch then
    return nil
  end
  local SchemeMap
  if self.PlayerPawnList and self.PlayerClothSchemeMap then
    for Index, P in pairs(self.PlayerPawnList) do
      if P == PlayerPawn then
        SchemeMap = self.PlayerClothSchemeMap[Index]
        break
      end
    end
  end
  if not SchemeMap or not next(SchemeMap) then
    return nil
  end
  local XSuitSchemeFeatureType = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitSchemeFeatureType")
  local PPBBFF = Period * 1000000 + Branch * 10000 + XSuitSchemeFeatureType.TeamEnter2 * 100
  for SchemeID in pairs(SchemeMap) do
    if SchemeID >= PPBBFF and SchemeID < PPBBFF + 100 then
      local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
      return LogicXSuit.GetRelateItemBySchemeID(SchemeID)
    end
  end
  return nil
end
function BornIslandTeamShowSubSystem:UpdateGoldenItemLocation(ItemID, pawn, ShapeID)
  if not slua.isValid(pawn) then
    print(bWriteLog and "BornIslandTeamShowSubSystem:UpdateGoldenItemLocation not pawn")
    return
  end
  local EmoteTableData = self:_GetBornIslandShowEmoteDataCfg(ItemID, ShapeID)
  if not EmoteTableData or not EmoteTableData.LocationOffsetArray_a then
    return
  end
  local dx = EmoteTableData.LocationOffsetArray_a:Num() >= 1 and EmoteTableData.LocationOffsetArray_a:Get(0) or 0
  local dy = EmoteTableData.LocationOffsetArray_a:Num() >= 2 and EmoteTableData.LocationOffsetArray_a:Get(1) or 0
  print(bWriteLog and "BornIslandTeamShowSubSystem:UpdateGoldenItemLocation not pawn " .. tostring(dx) .. "  " .. tostring(dy))
  local ActorRight = pawn:GetActorRightVector()
  local ActorForward = pawn:GetActorForwardVector()
  local TempPlayerLoc = Game:GetActorLocation(pawn) + ActorRight * dx + ActorForward * dy
  pawn:K2_SetActorLocation(TempPlayerLoc, false, nil, false)
end
function BornIslandTeamShowSubSystem:AdjuectGoldenItemAppearLocation(PlayerIndex)
  local Pawn = self.PlayerPawnList[PlayerIndex]
  if not Pawn or not slua.isValid(Pawn) then
    print(bWriteLog and "BornIslandTeamShowSubSystem:AdjuectGoldenItemAppearLocation not pawn")
    return
  end
  local ShapeID = self.PlayerAvatarShapeID and self.PlayerAvatarShapeID[PlayerIndex] or 0
  local ItemID = self.PlayerAvatarItem and self.PlayerAvatarItem[PlayerIndex] or 0
  local EmoteTableData = self:_GetBornIslandShowEmoteDataCfg(ItemID, ShapeID)
  local AppearLocationOffset = EmoteTableData and EmoteTableData.AppearLocationOffset_a or nil
  if not AppearLocationOffset then
    return
  end
  local VectorLength = AppearLocationOffset:Num()
  local dx = 0 < VectorLength and AppearLocationOffset:Get(0) or 0
  local dy = 1 < VectorLength and AppearLocationOffset:Get(1) or 0
  if dx == 0 and dy == 0 then
    return
  end
  local XOffset = Pawn:GetActorRightVector() * dx
  local YOffset = Pawn:GetActorForwardVector() * dy
  self.CachedPlayerAdjustLoc[PlayerIndex] = {XOffset, YOffset}
  local TempPlayerLoc = Game:GetActorLocation(Pawn) + XOffset + YOffset
  Pawn:K2_SetActorLocation(TempPlayerLoc, false, nil, false)
end
function BornIslandTeamShowSubSystem:RestoreGoldenItemAppearLocation(PlayerIndex)
  if not self.CachedPlayerAdjustLoc[PlayerIndex] then
    return
  end
  local Pawn = self.PlayerPawnList[PlayerIndex]
  if not Pawn or not slua.isValid(Pawn) then
    print(bWriteLog and "BornIslandTeamShowSubSystem:RestoreGoldenItemAppearLocation not pawn")
    return
  end
  local XOffset = self.CachedPlayerAdjustLoc[PlayerIndex][1]
  local YOffset = self.CachedPlayerAdjustLoc[PlayerIndex][2]
  if not XOffset or not YOffset then
    return
  end
  local OriginPlayerLoc = Game:GetActorLocation(Pawn) - XOffset - YOffset
  Pawn:K2_SetActorLocation(OriginPlayerLoc, false, nil, false)
end
function BornIslandTeamShowSubSystem:GetPawnSyncDataBySlot(PlayerState)
  local ComponentClass = import("CharacterAvatarComponent2")
  if slua.isValid(PlayerState) and slua.isValid(PlayerState.CharacterOwner) then
    local RealPawn = PlayerState.CharacterOwner
    local UCharacterAvatarComponent = RealPawn and RealPawn:GetComponentByClass(ComponentClass)
    if slua.isValid(UCharacterAvatarComponent) then
      local EAvatarSlotType = import("EAvatarSlotType")
      local FAvatarSyncData = import("AvatarSyncData")
      local ClothesSyncData = FAvatarSyncData()
      local IsGetData = false
      IsGetData, ClothesSyncData = UCharacterAvatarComponent:GetSyncDataBySlot(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot, ClothesSyncData)
      if IsGetData then
        return ClothesSyncData
      end
    end
  end
  return nil
end
function BornIslandTeamShowSubSystem:TableGetFirstAndRemove(tb)
  local ReturnVal
  for key, value in pairs(tb) do
    ReturnVal = value
    tb[key] = nil
    return ReturnVal
  end
end
function BornIslandTeamShowSubSystem:OnRepTeammateChange_Handle()
  print(bWriteLog and "BornIslandTeamShowSubSystem:OnRepTeammateChange_Handle")
  self:RefreshCacheInfo()
end
function BornIslandTeamShowSubSystem:RefreshCacheInfo(bForceUpdate)
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) and uGameState:GetGameModeState() ~= "ReadyState" then
    return
  end
  local PlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(PlayerState) or not PlayerState.GetTeamMatePlayerStateList then
    print(bWriteLog and "BornIslandTeamShowSubSystem:RefreshCacheInfo return 1")
    return
  end
  local TeammatePlayerState = PlayerState:GetTeamMatePlayerStateList({}, false)
  if not (TeammatePlayerState and TeammatePlayerState.Num) or TeammatePlayerState:Num() < 1 then
    local OnePlayerState = GameplayData.GetPlayerState()
    if slua.isValid(OnePlayerState) then
      TeammatePlayerState:Add(OnePlayerState)
    else
      print(bWriteLog and "BornIslandTeamShowSubSystem:RefreshCacheInfo invalid OnePlayerState, Return!!!")
      return
    end
  end
  if not TeammatePlayerState or TeammatePlayerState:Num() <= 0 then
    print(bWriteLog and "BornIslandTeamShowSubSystem:RefreshCacheInfo return 2")
    return
  end
  for _, PlayerState in pairs(TeammatePlayerState) do
    if slua.isValid(PlayerState) and slua.isValid(PlayerState.CharacterOwner) then
      local PlayerKey = PlayerState:GetPlayerKey()
      if self.CachePlayerInfoList and (not self.CachePlayerInfoList[PlayerKey] or bForceUpdate) then
        local RealPawn = PlayerState.CharacterOwner
        local ComponentClass = import("CharacterAvatarComponent2")
        local UCharacterAvatarComponent = RealPawn and RealPawn:GetComponentByClass(ComponentClass)
        if slua.isValid(UCharacterAvatarComponent) then
          local CacheData = {}
          CacheData.Gender = UCharacterAvatarComponent.gender
          CacheData.HeadId = UCharacterAvatarComponent.HeadAvatarID
          CacheData.NetAvatarData = Game:CopyNetAvatarDataToLobbyPawn(UCharacterAvatarComponent)
          CacheData.AvatarList = self:GetCharacterAvatarList(UCharacterAvatarComponent)
          CacheData.UID = RealPawn.PlayerUID
          if RealPawn.PetComponent_BP and RealPawn.PetComponent_BP.PetPawn and slua.isValid(RealPawn.PetComponent_BP.PetPawn) then
            local RealPetPawn = RealPawn.PetComponent_BP.PetPawn
            if RealPetPawn and RealPetPawn.PetLevelInfo then
              CacheData.PetId = RealPetPawn.PetLevelInfo.PetId
              CacheData.PetLevel = RealPetPawn.PetLevelInfo.PetLevel
              CacheData.PetColor = RealPetPawn.PetColor
            end
            local PetAvatarID = {}
            if RealPetPawn and RealPetPawn.PetAvatarComponent_BP and RealPetPawn.PetAvatarComponent_BP.NetAvatarData then
              local AvatarData = RealPetPawn.PetAvatarComponent_BP.NetAvatarData
              if AvatarData.SlotSyncData then
                for _, AvatarSyncData in pairs(AvatarData.SlotSyncData) do
                  if AvatarSyncData and AvatarSyncData.ItemID and 0 < AvatarSyncData.ItemID then
                    table.insert(PetAvatarID, AvatarSyncData.ItemID)
                  end
                end
              end
            end
            CacheData.          end
          print(bWriteLog and "BornIslandTeamShowSubSystem:RefreshCacheInfo add Cache,PlayerKey=", PlayerKey)
          self.CachePlayerInfoList[PlayerKey] = CacheData
        end
      end
    end
  end
end
function BornIslandTeamShowSubSystem:FliterSynData(NetAvatarData)
  if NetAvatarData and NetAvatarData.SlotSyncData then
    local TempSlotSyncData = slua.IndexReference(NetAvatarData, "SlotSyncData")
    for Index, AvatarSynData in pairs(TempSlotSyncData) do
      if AvatarSynData.ItemID > 0 and not self:IsNeedSlotType(AvatarSynData.SlotID, AvatarSynData.SubSlotID) then
        AvatarSynData.ItemID = 0
        AvatarSynData.SlotID = 0
        AvatarSynData.SubSlotID = 0
        AvatarSynData.FakeItemID = 0
        AvatarSynData.HideState = 0
        slua.IndexReference(NetAvatarData, "SlotSyncData"):Set(Index, AvatarSynData)
      elseif AvatarSynData.ForceHideState == 1 then
        AvatarSynData.ForceHideState = 0
        slua.IndexReference(NetAvatarData, "SlotSyncData"):Set(Index, AvatarSynData)
      end
    end
  end
end
function BornIslandTeamShowSubSystem:HandleObjectVisibility(Obj, MgrTable)
  local bShouldShow = self.ShowState == ShowStateEnum.Showing
  local bShowldDestory = self.ShowState == ShowStateEnum.EndShow
  if slua.isValid(Obj) then
    if bShowldDestory then
      Obj:K2_DestroyActor()
      return
    end
    if bShouldShow then
      Obj:SetActorHiddenInGame(false)
    else
      Obj:SetActorHiddenInGame(true)
      Obj:SetActorEnableCollision(false)
    end
    if MgrTable then
      table.insert(MgrTable, Obj)
    end
  elseif MgrTable then
    for _, TObj in pairs(MgrTable) do
      if slua.isValid(TObj) then
        if bShouldShow then
          TObj:SetActorHiddenInGame(false)
        else
          TObj:SetActorHiddenInGame(true)
          TObj:SetActorEnableCollision(false)
        end
      end
    end
  end
end
function BornIslandTeamShowSubSystem:HanleReceiveSpecialVehicle(PlayerKey, CarItemID, VehicleAvatarStyleData)
  print(bWriteLog and "BornIslandTeamShowSubSystem:HanleReceiveSpecialVehicle PlayerKey,CarItemID=", PlayerKey, " ", CarItemID)
  if self.SpecialVehicleObjTable and self.SpecialVehicleObjTable[PlayerKey] then
    local TempCarObj = self.SpecialVehicleObjTable[PlayerKey]
    if slua.isValid(TempCarObj) and VehicleAvatarStyleData then
      local FAvatarSyncData = import("AvatarSyncData")
      if TempCarObj.VehicleAdvanceAvatarComp_BP then
        TempCarObj:PreChangeVehicleAvatar(0, CarItemID)
        local TempAvatarSyncData = TempCarObj.VehicleAdvanceAvatarComp_BP.NetAvatarData
        for _, value in pairs(VehicleAvatarStyleData) do
          local ItemDefineID = FItemDefineID(51, value.ModelID)
          local cfg = TempCarObj.VehicleAdvanceAvatarComp_BP:MakeAvatarTableData(ItemDefineID)
          local tAvatar = FAvatarSyncData()
          tAvatar.ItemID = value.ModelID
          tAvatar.SlotID = cfg.SlotID
          slua.IndexReference(tAvatar, "CustomInfo").CustomType = 3
          slua.IndexReference(tAvatar, "CustomInfo").ColorID = value.ColorID
          slua.IndexReference(tAvatar, "CustomInfo").PatternID = value.PatternID
          slua.IndexReference(tAvatar, "CustomInfo").ParticleID = value.ParticleID
          TempCarObj.VehicleAdvanceAvatarComp_BP:ChangeOrAddSlotSyncData(tAvatar)
        end
        TempCarObj.VehicleAdvanceAvatarComp_BP.NetAvatarData = TempAvatarSyncData
        TempCarObj.VehicleAdvanceAvatarComp_BP:OnRep_BodySlotStateChanged()
      end
    end
  end
end
function BornIslandTeamShowSubSystem:IsShowing()
  return self.ShowState == ShowStateEnum.Showing
end
function BornIslandTeamShowSubSystem:CheckAndReqVehicleAccessoryData(PlayerState, CarItemID, carObj)
  if not CarItemID or not slua.isValid(PlayerState) then
    log(bWriteLog and "BornIslandTeamShowSubSystem:CheckAndReqVehicleAccessoryData param is nil")
    return
  end
  if not slua.isValid(carObj) then
    log(bWriteLog and "BornIslandTeamShowSubSystem:CheckAndReqVehicleAccessoryData carObj is invalid")
    return
  end
  local playerUid = PlayerState.UID
  if not playerUid then
    log(bWriteLog and "BornIslandTeamShowSubSystem:CheckAndReqVehicleAccessoryData playerUid is nil")
    return
  end
  local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
  local LogicVehicleAccessory = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleAccessory)
  if not LogicVehicleAccessory:CheckVehicleCanEquipAccessory(CarItemID) and not VehiclePlateLicenseUtil.CheckIsBetterVehicle(CarItemID) then
    log(bWriteLog and "BornIslandTeamShowSubSystem:CheckAndReqVehicleAccessoryData not support accessory")
    return
  end
  self.AccessoryVehicleObjCacheTable[playerUid] = carObj
  log(bWriteLog and "BornIslandTeamShowSubSystem:CheckAndReqVehicleAccessoryData CarItemID:" .. tostring(CarItemID))
  local ds_net = require("ds_net")
  ds_net.SendMessage("ingame_teamshow_car_accessory_info", {PlayerUid = playerUid, CarItemID = CarItemID})
end
function BornIslandTeamShowSubSystem:HanleReceiveVehicleAccessory(playerUid, CarItemID, AccessoryList, ChassisLight, BrakeCaliper, WheelHub, Sunroof)
  if not (playerUid and CarItemID) or not AccessoryList then
    log(bWriteLog and "BornIslandTeamShowSubSystem:HanleReceiveVehicleAccessory param is nil")
    return
  end
  local TempCarObj = self.AccessoryVehicleObjCacheTable and self.AccessoryVehicleObjCacheTable[playerUid]
  if not slua.isValid(TempCarObj) then
    log(bWriteLog and "BornIslandTeamShowSubSystem:HanleReceiveVehicleAccessory TempCarObj is nil")
    return
  end
  if not TempCarObj.SetVehicleAccessoryList then
    log(bWriteLog and "BornIslandTeamShowSubSystem:HanleReceiveVehicleAccessory SetVehicleAccessoryList is nil")
    return
  end
  TempCarObj:SetVehicleAccessoryList(AccessoryList)
  TempCarObj:SetChassisLightShowData(ChassisLight)
  if TempCarObj.SetBrakeCaliperShowData then
    TempCarObj:SetBrakeCaliperShowData(BrakeCaliper)
  end
  if TempCarObj.SetWheelHubShowData then
    TempCarObj:SetWheelHubShowData(WheelHub)
  end
  if TempCarObj.SetCanopyShowData then
    TempCarObj:SetCanopyShowData(Sunroof)
  end
  self.AccessoryVehicleObjCacheTable[playerUid] = nil
end
function BornIslandTeamShowSubSystem:ShowPetEffect()
  if self.PetObjectList then
    local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
    for _, petActor in pairs(self.PetObjectList) do
      if slua.isValid(petActor) then
        local EffectItemID = petActor:GetEffectItemId()
        local EffectCfg = logic_pet:GetPortalCfgByItemId(EffectItemID)
        local particlePath = EffectCfg.Appear
        local scale = EffectCfg.Scale or 1
        log(bWriteLog and "BornIslandTeamShowSubSystem:ShowPetEffect particle path: " .. tostring(particlePath))
        Util.GetAssetAsync(particlePath, function(uParticle)
          if slua.isValid(uParticle) and slua.isValid(petActor) then
            log(bWriteLog and "BornIslandTeamShowSubSystem:CreatePetRole uParticle is Valid " .. tostring(particlePath))
            GameplayStatics.SpawnEmitterAtLocation(petActor, uParticle, petActor:K2_GetActorLocation(), FRotator(0, 0, 0), FVector(scale, scale, scale), true)
            petActor:PlayRandomAction()
          end
        end)
      end
    end
  end
end
function BornIslandTeamShowSubSystem.AdjustFpsTemporarily(IsBeginShow)
  local logicSettingGraphics = require("client.slua.logic.setting.logic_setting_graphics")
  logicSettingGraphics.DowngradeFpsLevelTemporarily(IsBeginShow, 30)
end
function BornIslandTeamShowSubSystem:_GetBornIslandShowEmoteDataCfg(ItemID, ShapeID)
  if not ItemID then
    return nil
  end
  ShapeID = ShapeID or 0
  local EmoteDataCfg = CDataTable.GetTableDataByFilter("BornIslandShowEmoteCfg", "ItemID", ItemID, "ShapeID", ShapeID)
  if ShapeID ~= 0 and not EmoteDataCfg then
    EmoteDataCfg = CDataTable.GetTableDataByFilter("BornIslandShowEmoteCfg", "ItemID", ItemID, "ShapeID", 0)
  end
  return EmoteDataCfg
end
function BornIslandTeamShowSubSystem:_CheckAndRefreshMiniTvAttachState(PlayerKey)
  print(bWriteLog and "BornIslandTeamShowSubSystem:_CheckAndRefreshMiniTvAttachState PlayerKey:" .. tostring(PlayerKey))
  if not PlayerKey or not self.CachedPlayerMiniTvInfo[PlayerKey] then
    print(bWriteLog and "BornIslandTeamShowSubSystem:_CheckAndRefreshMiniTvAttachState invalid PlayerKey or cached info, return")
    return
  end
  local MiniTvActor = self.CachedPlayerMiniTvInfo[PlayerKey].MiniTvActor
  local PetActor = self.CachedPlayerMiniTvInfo[PlayerKey].PetActor
  if not slua.isValid(MiniTvActor) or not slua.isValid(PetActor) then
    print(bWriteLog and "BornIslandTeamShowSubSystem:_CheckAndRefreshMiniTvAttachState invalid MiniTvActor or PetActor, return")
    return
  end
  local bAttachToPet = false
  local PetID = self.CachedPlayerMiniTvInfo[PlayerKey].PetID
  if PetID and PetID ~= 0 and PetID ~= 50001 and slua.isValid(PetActor.Mesh) and slua.isValid(MiniTvActor.Mesh) and self:CheckIsDownloaded(PetID) then
    bAttachToPet = true
  end
  print(bWriteLog and "BornIslandTeamShowSubSystem:_CheckAndRefreshMiniTvAttachState bAttachToPet:" .. tostring(bAttachToPet))
  if bAttachToPet then
    local skeletalMesh = MiniTvActor.Mesh
    local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
    local socketScale = logic_pet:GetMiniTvSocketScale(PetID) or 1
    local scale = CONST_MINITV_ATTACH_BASE_SCALE * socketScale
    local EAttachmentRule = import("EAttachmentRule")
    skeletalMesh:SetWorldScale3D(FVector(scale, scale, scale))
    MiniTvActor:K2_SetActorRelativeLocation(FVector(0, 0, 0), false, nil, true)
    MiniTvActor:K2_SetActorRelativeRotation(FRotator(0, 0, 0), false, nil, true)
    skeletalMesh:K2_AttachToComponent(PetActor.Mesh, "MiniTvSocket", EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, EAttachmentRule.KeepWorld, true)
    skeletalMesh:K2_SetRelativeLocation(FVector(0, 0, 0), false, nil, true)
    skeletalMesh:K2_SetRelativeRotation(FRotator(0, 0, 0), false, nil, true)
    MiniTvActor.Mesh:SetHiddenInGame(false, false)
    MiniTvActor.Bubble:SetVisibility(true, true)
  else
    MiniTvActor.Bubble:SetVisibility(false, true)
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, BornIslandTeamShowSubSystem)