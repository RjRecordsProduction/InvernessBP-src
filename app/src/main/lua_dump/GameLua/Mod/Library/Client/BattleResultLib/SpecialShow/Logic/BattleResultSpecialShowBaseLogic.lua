local BattleResultSpecialShowBaseLogic = {}
local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
local ResultUtil = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultUtil")
local UKismetMathLibrary = import("KismetMathLibrary")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local TableUtil = require("common.table_util")
local GameplayStatics = import("GameplayStatics")
local uActor = import("/Script/Engine.Actor")
local Util = require("client.slua_ui_framework.util")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function BattleResultSpecialShowBaseLogic:OnInit()
  print(bWriteLog and "BattleResultSpecialShowBaseLogic:OnInit")
  self:InitBaseConfig()
  if not self.ShowConfig then
    print(bWriteLog and "BattleResultSpecialShowBaseLogic:OnInit Error Config!!!")
    return
  end
  self.PreCacheTableConfig = {
    "MatchModeTable",
    "PveLevel",
    "RPTaskDesc",
    "NewLevelTask",
    "MilitaryRankLevel",
    "SeasonInfo",
    "SeasonSegmentReward",
    "SeasonInReward",
    "RankIntegralLevel_MODE_25",
    "SeasonCardsConfig",
    "ReddotCategoryConfig",
    "ItemUpgradeConfig",
    "AvatarDefaultConfig"
  }
  self.tSpecialShowResultData = nil
  self.ShowPawnList = {}
  self.SequenceActor = nil
  self.ViewTargetActor = nil
  self.ShowPawnNum = 0
  self.ResultProcessOver = false
  self.ForceEndTimer = nil
  self.CharacterDataNum = 0
  self.PreCacheTableAsset = {}
  self.UIDToPawnBindMap = {}
  self.UIDToUINameBindMap = {}
  self.DragonShowUI = nil
  self.UILoopTimes = 20
  self.ShowAssetLoaded = false
  self.ButtonUI = nil
  self.PlayerNameList = {}
  self.LoadedAssetList = {}
  self.CreatePawnTimer = nil
  self.bPawnAllCreated = false
  self.bHasShowUI = false
  self.preArtQualityCMDSetting = nil
  self.bEnableLensFlareActorBackUp = false
  self.bSwitchToHDR = false
end
function BattleResultSpecialShowBaseLogic:InitBaseConfig()
  print(bWriteLog and "BattleResultSpecialShowBaseLogic:InitMapConfig")
  local BaseConfig = GamePlayTools.GetCurrentConfig("BattleResultSpecialShowConfig")
  if not BaseConfig then
    print(bWriteLog and "BattleResultSpecialShowBaseLogic:OnInit Error Config!!!")
    return
  end
  local MapType = GameMainConfig.GetMapType()
  if not MapType or not BaseConfig[MapType] then
    print(bWriteLog and "BattleResultSpecialShowBaseLogic:InitMapConfig invalid MapConfig")
    return
  end
  self.ShowConfig = BaseConfig[MapType]
  self.TotalShowTime = self.ShowConfig.TotalShowTime or 45
  self.LoadingMaxTime = self.ShowConfig.LoadingMaxTime or 20
  self.LevelAssetPath = self.ShowConfig.LevelAssetPath
  self.LevelAssetName = self.ShowConfig.LevelAssetName
  self.ViewTargetPos = self.ShowConfig.ViewTargetPos
  self.ViewTargetRot = self.ShowConfig.ViewTargetRot
  self.SequenceActorPos = self.ShowConfig.SequenceActorPos
  self.SequenceActorRot = self.ShowConfig.SequenceActorRot
  self.TransitionUIPath = self.ShowConfig.TransitionUIPath
  self.NameCardIDMap = self.ShowConfig.NameCardIDMap
  self.ButtonUIPath = self.ShowConfig.ButtonUIPath
  self.LobbyPawnClassPath = self.ShowConfig.LobbyPawnClassPath
  self.SequencePath = self.ShowConfig.SequencePath
  self.SequenceActorPath = self.ShowConfig.SequenceActorPath
  self.SkyTransitionID = self.ShowConfig.SkyTransitionID or 0
  self.NeedHideClass = self.ShowConfig.NeedHideClass
  if self.ShowConfig.NameCardFinalPos then
    self.NameCardFinalPos = self.ShowConfig.NameCardFinalPos
  end
  if self.ShowConfig.NameCardAllShowPos then
    self.NameCardAllShowPos = self.ShowConfig.NameCardAllShowPos
  end
  if self.ShowConfig.NameCardSinglePos then
    self.NameCardSinglePos = self.ShowConfig.NameCardSinglePos
  end
  if self.ShowConfig.CameraButtonUIName then
    self.CameraButtonUIName = self.ShowConfig.CameraButtonUIName
  end
  self.DefaultPawnIndex = 1
end
function BattleResultSpecialShowBaseLogic:OnRelease()
  print(bWriteLog and "BattleResultSpecialShowBaseLogic:OnRelease")
  self.ShowPawnList = {}
  self.SequenceActor = nil
  self.PreCacheTableAsset = {}
  self.LoadedAssetList = {}
end
function BattleResultSpecialShowBaseLogic:OnBattleResult(result)
  print(bWriteLog and "BattleResultSpecialShowBaseLogic:OnBattleResult sub_mode:" .. tostring(result.sub_mode) .. " battle_owner:" .. tostring(result.battle_owner))
  if result.special_result_team then
    self.tSpecialShowResultData = result.special_result_team
  end
end
function BattleResultSpecialShowBaseLogic:OnSwitchCheck()
  print(bWriteLog and "BattleResultSpecialShowBaseLogic:OnSwitchCheck ")
  if self.tSpecialShowResultData and self.tSpecialShowResultData.members then
    self.tWinnerTeamInfo = TableUtil.CopyTable(self.tSpecialShowResultData.members)
    self.CharacterDataNum = TableUtil.CountTable(self.tWinnerTeamInfo)
    if self.ShowConfig.MinumPlayerCount and self.CharacterDataNum < self.ShowConfig.MinumPlayerCount then
      print(bWriteLog and "BattleResultSpecialShowBaseLogic:InitMapConfig invalid PlayerCount")
      return false
    end
    if not self:HandleResultAddtionalData(self.tSpecialShowResultData) then
      return false
    end
    print(bWriteLog and "BattleResultSpecialShowBaseLogic:OnSwitchCheck Success")
    return true
  end
  print(bWriteLog and "BattleResultSpecialShowBaseLogic:OnSwitchCheck Failed")
  return false
end
function BattleResultSpecialShowBaseLogic:HandleResultAddtionalData(SpecialShowResultData)
  print(bWriteLog and "BattleResultSpecialShowBaseLogic:HandleResultAddtionalData")
  local tAddtionalData = SpecialShowResultData.custom_data
  if self.ShowConfig then
    local sShowTypeName = "BasicShowMode"
    if self.ShowConfig.sShowTypeName and self.ShowConfig.sShowTypeName ~= "" then
      sShowTypeName = self.ShowConfig.sShowTypeName
    end
    local sShowTypePath = "GameLua.Mod.Library.Client.BattleResultLib.SpecialShow.SpecialShowLibrary.ShowType." .. tostring(sShowTypeName)
    if not GamePlayTools.LuaFileExits(sShowTypePath) then
      print(bWriteLog and "BattleResultSpecialShowBaseLogic:HandleResultAddtionalData InValid ShowType!")
      return false
    end
    local uShowTypeProcesser = require(sShowTypePath)
    if uShowTypeProcesser then
      local bInitBaseData = uShowTypeProcesser:InitBasicData(self, self.ShowConfig, SpecialShowResultData, tAddtionalData)
      if bInitBaseData then
        if self.CharacterDataNum ~= TableUtil.CountTable(self.UIDToPawnBindMap) then
          print(bWriteLog and "BattleResultSpecialShowBaseLogic:HandleResultAddtionalData invalid Pawn Count")
          return false
        end
      else
        print(bWriteLog and "BattleResultSpecialShowBaseLogic:HandleResultAddtionalData InValid BaseData!")
        return false
      end
    else
      print(bWriteLog and "BattleResultSpecialShowBaseLogic:HandleResultAddtionalData Not Find ShowTypeProcesser" .. tostring(sShowTypeName))
      return false
    end
    local bApplyRuleSuccess = true
    if self.ShowConfig.tAdditionalRules then
      for Index = 1, 10 do
        local sRuleName = self.ShowConfig.tAdditionalRules[Index]
        if sRuleName and sRuleName ~= "" then
          local sRulePath = "GameLua.Mod.Library.Client.BattleResultLib.SpecialShow.SpecialShowLibrary.AdditionalRule." .. tostring(sRuleName)
          if not GamePlayTools.LuaFileExits(sRulePath) then
            print(bWriteLog and "BattleResultSpecialShowBaseLogic:HandleResultAddtionalData InValid RuleName: " .. tostring(sRuleName))
            return false
          end
          local uRuleProcesser = require(sRulePath)
          if uRuleProcesser and uRuleProcesser.ApplyRule then
            local bRuleResult = uRuleProcesser:ApplyRule(self, self.ShowConfig, SpecialShowResultData, tAddtionalData)
            print(bWriteLog and "BattleResultSpecialShowBaseLogic:HandleResultAddtionalData  Rule: " .. tostring(sRuleName) .. " ApplyResult: " .. tostring(bRuleResult))
            bApplyRuleSuccess = bApplyRuleSuccess and bRuleResult
          else
            print(bWriteLog and "BattleResultSpecialShowBaseLogic:HandleResultAddtionalData InValid Rule Format RuleName: " .. tostring(sRuleName))
            return false
          end
        end
      end
    end
    return bApplyRuleSuccess
  else
    return false
  end
end
function BattleResultSpecialShowBaseLogic:OnResultProcessStart()
  print(bWriteLog and "BattleResultSpecialShowBaseLogic:OnResultProcessStart")
  for _, tableName in pairs(self.PreCacheTableConfig) do
    local tableAsset = CDataTable.GetTable(tableName)
    if tableAsset then
      table.insert(self.PreCacheTableAsset, tableAsset)
    end
  end
  self:AddGameTimer(0, false, function()
    self:StartSpecialShow()
  end)
  return true
end
function BattleResultSpecialShowBaseLogic:OnPostReconnection(curProcessIndex)
  print(bWriteLog and "BattleResultSpecialShowBaseLogic:OnPostReconnection", curProcessIndex)
end
function BattleResultSpecialShowBaseLogic:StartSpecialShow()
  print(bWriteLog and "BattleResultSpecialShowBaseLogic:StartSpecialShow")
  self.ForceEndTimer = self:AddGameTimer(self.LoadingMaxTime, false, function()
    self:ShowTransitionUI(false)
    self:EndResultProcess()
  end)
  local world = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(world) then
    print(bWriteLog and "BattleResultSpecialShowBaseLogic:StartSpecialShow return world")
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "BattleResultSpecialShowBaseLogic:StartSpecialShow return PlayerController")
    return
  end
  if slua.isValid(PlayerController.PlayerCameraManager) then
    print(bWriteLog and "BattleResultSpecialShowBaseLogic:StartSpecialShow Stop Player CameraShake")
    PlayerController.PlayerCameraManager:StopAllCameraShakes(true)
  end
  if not slua.isValid(CGameState) then
    return
  end
  local nStartTime = CGameState:GetServerWorldTimeSeconds()
  Util.GetAssetAsync(self.LobbyPawnClassPath .. "_C", function(LobbyPawnAsset)
    if LobbyPawnAsset then
      self:CreatePawnEveryFrame()
      self.CreatePawnTimer = self:AddGameTimer(0.3, true, function()
        self:CreatePawnEveryFrame()
      end)
      local StartLoadPaths = {
        self.TransitionUIPath,
        self.SequenceActorPath,
        self.SequencePath,
        self.LevelAssetPath,
        self.ButtonUIPath
      }
      print(bWriteLog and "BattleResultSpecialShowBaseLogic:StartSpecialShow AsyncLoadAsset Start ")
      self.AsyncLoadArrayID = slua.AsyncLoadAssetArray(StartLoadPaths, function()
        print(bWriteLog and "BattleResultSpecialShowBaseLogic:StartSpecialShow AsyncLoadAsset Done add to LoadedAssetList")
        local BusinessHelper = import("BusinessHelper")
        for index, AssetPath in pairs(StartLoadPaths) do
          if AssetPath ~= self.TransitionUIPath and AssetPath ~= self.ButtonUIPath then
            print(bWriteLog and "BattleResultSpecialShowBaseLogic:StartSpecialShow AsyncLoadAsset Done add to LoadedAssetList Start ", AssetPath)
            local TAsset = BusinessHelper.LoadAssetFromPath(AssetPath)
            table.insert(self.LoadedAssetList, TAsset)
            print(bWriteLog and "BattleResultSpecialShowBaseLogic:StartSpecialShow AsyncLoadAsset Done add to LoadedAssetList End ", AssetPath)
          end
        end
        self.AsyncLoadArrayID = nil
        self:ChangeGraphQuality(true)
        self.ShowAssetLoaded = true
      end)
    else
      self:ForceEndShow()
      print(bWriteLog and "BattleResultSpecialShowBaseLogic:StartSpecialShow Error LobbyPawnAsset ForceEndShow")
    end
  end)
  self:CheckAndShowStartUI()
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_SEQUENCE_MSG, self.ReceiveSeqEvent, self)
  self:AddCommonEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_SPECIAL_SHOW_SKIP, self.ForceEndShow, self)
  print(bWriteLog and "BattleResultSpecialShowBaseLogic:StartSpecialShow AddCommonEvent")
end
function BattleResultSpecialShowBaseLogic:ShowTransitionUI(bShow)
  print(bWriteLog and "BattleResultSpecialShowBaseLogic:ShowTransitionUI " .. tostring(bShow))
  if not UIManager then
    print(bWriteLog and "BattleResultSpecialShowBaseLogic:ShowTransitionUI invalid UIManager")
    return
  end
  if self.ShowConfig and self.ShowConfig.TransitionUIName and UIManager.UI_Config_InGame[self.ShowConfig.TransitionUIName] then
    if bShow then
      self.TransitionUI = UIManager.ShowUI(UIManager.UI_Config_InGame[self.ShowConfig.TransitionUIName], self)
    else
      UIManager.CloseUI(UIManager.UI_Config_InGame[self.ShowConfig.TransitionUIName])
      self.TransitionUI = nil
    end
  else
    print(bWriteLog and "BattleResultSpecialShowBaseLogic:ShowTransitionUI invalid UIConfig")
  end
end
function BattleResultSpecialShowBaseLogic:ShowButtonUI(bShow)
  print(bWriteLog and "BattleResultSpecialShowBaseLogic:ShowButtonUI " .. tostring(bShow))
  if self.ShowConfig and self.CameraButtonUIName and UIManager.UI_Config_InGame[self.CameraButtonUIName] then
    if bShow then
      self.ButtonUI = UIManager.ShowUI(UIManager.UI_Config_InGame[self.CameraButtonUIName])
      if self.ButtonUI and self.ButtonUI.InitPlayer and self.UIDToUINameBindMap then
        if self.NameCardIDMap then
          self.ButtonUI:InitNameCardID(self.NameCardIDMap)
        end
        if self.NameCardFinalPos then
          self.ButtonUI:InitNameCardFinalPos(self.NameCardFinalPos)
        end
        if self.NameCardAllShowPos then
          self.ButtonUI:InitNameCardAllShowPos(self.NameCardAllShowPos)
        end
        if self.NameCardSinglePos then
          self.ButtonUI:InitNameCardSinglePos(self.NameCardSinglePos)
        end
        for nUID, sPlayerName in pairs(self.PlayerNameList) do
          if nUID and self.UIDToUINameBindMap[nUID] then
            self.ButtonUI:InitPlayer(self.UIDToUINameBindMap[nUID], sPlayerName)
          else
            print(bWriteLog and "BattleResultSpecialShowBaseLogic:ShowButtonUI invalid UIDToUINameBindMap UID = " .. tostring(nUID))
          end
        end
      end
    else
      UIManager.CloseUI(UIManager.UI_Config_InGame[self.CameraButtonUIName])
      self.ButtonUI = nil
    end
  else
    print(bWriteLog and "BattleResultSpecialShowBaseLogic:ShowButtonUI invalid UIConfig")
  end
end
function BattleResultSpecialShowBaseLogic:CheckAndShowStartUI()
  if not self.bHasShowUI then
    self.bHasShowUI = true
    print(bWriteLog and "BattleResultSpecialShowBaseLogic:CheckAndShowStartUI")
    local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
    if IngameSelfieSubsystem then
      print(bWriteLog and "BattleResultSpecialShowBaseLogic:CheckAndShowStartUI Exit IngameSelfieSubsystem")
      IngameSelfieSubsystem:ExitSelfie()
    end
    if UIManager.UI_Config_InGame.BattlePopTips then
      UIManager.HideUI(UIManager.UI_Config_InGame.BattlePopTips)
    end
    self:HideAllUI()
    self:ShowTransitionUI(true)
  end
end
function BattleResultSpecialShowBaseLogic:ChangePlayerCameraToSeqPos()
  print(bWriteLog and "BattleResultSpecialShowBaseLogic:ChangePlayerCameraToSeqPos")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local ACameraActor = import("CameraActor")
  self.ViewTargetActor = CGameWorld:SpawnActor(ACameraActor, self.ViewTargetPos, self.ViewTargetRot, nil)
  if not slua.isValid(self.ViewTargetActor) then
    return
  end
  if self.ViewTargetActor.CameraComponent then
    self.ViewTargetActor.CameraComponent:SetFieldOfView(95.4)
    self.ViewTargetActor.CameraComponent:SetConstraintAspectRatio(false)
  end
  local EViewTargetBlendFunction = import("EViewTargetBlendFunction")
  PlayerController:SetViewTargetWithBlend(self.ViewTargetActor, 0, EViewTargetBlendFunction.VTBlend_Linear, 0, false)
end
function BattleResultSpecialShowBaseLogic:StartLoadFinished()
  print(bWriteLog and "BattleResultSpecialShowBaseLogic:StartLoadFinished")
  local world = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(world) then
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local GameplayStatics = import("GameplayStatics")
  local PlatformID = GameplayStatics.GetPlatformInt()
  if PlatformID ~= 5 then
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    UKismetSystemLibrary.ExecuteConsoleCommand(PlayerController, "r.SetNearClipPlane 3")
  end
  if slua.isValid(PlayerController) and PlayerController.SetIsShowBlood then
    PlayerController:SetIsShowBlood(false)
  end
  if PlayerController.SkyTransition and self.SkyTransitionID and self.SkyTransitionID > 0 then
    PlayerController.SkyTransition:ClientSetState(self.SkyTransitionID, 0)
  end
  print(bWriteLog and "BattleResultSpecialShowBaseLogic:StartLoadFinished Load Level Start")
  local LevelStreamingMgr = SubsystemMgr:Get("LevelStreamingMgr")
  LevelStreamingMgr:LoadStreamLevelNoLatent(self.LevelAssetName, true, true)
  print(bWriteLog and "BattleResultSpecialShowBaseLogic:StartLoadFinished Load Level End")
  self:ShowPlayerPawn()
  if slua_GameFrontendHUD then
    slua_GameFrontendHUD:ShutdownUnrealNetwork()
  end
  self:ShowButtonUI(true)
  local BindingList = {}
  local TempBingdingName
  if self.UIDToPawnBindMap then
    for nUID, TempPawn in pairs(self.ShowPawnList) do
      TempBingdingName = self.UIDToPawnBindMap[nUID] or ""
      BindingList[TempBingdingName] = TempPawn
    end
  else
    print(bWriteLog and "BattleResultSpecialShowBaseLogic:StartLoadFinished InValid UIDToPawnBindMap")
    self:EndResultProcess()
    return
  end
  local SequenceActorPos = self.SequenceActorPos
  local SequenceRotator = self.SequenceActorRot
  local SequenceScale = FVector(1, 1, 1)
  local TempTran = UKismetMathLibrary.MakeTransform(SequenceActorPos, SequenceRotator, SequenceScale)
  if not slua.isValid(TempTran) then
    return
  end
  self.SequenceActor = Game:PlayLevelSequence(world, self.SequencePath, TempTran, self.SequenceActorPath .. "_C", false, BindingList)
  if not slua.isValid(self.SequenceActor) then
    print(bWriteLog and "BattleResultSpecialShowBaseLogic:StartLoadFinished InValid SequenceActor")
    self:EndResultProcess()
    return
  end
  EventSystem:postEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_SPECIAL_SHOW_START)
  if self.ForceEndTimer then
    Game:ClearTimer(self.ForceEndTimer)
  end
  self:AddGameTimer(self.TotalShowTime, false, function()
    self:EndResultProcess()
  end)
  self:HideBlueCircle()
  local Mgr = PlayerController:GetScreenAppearanceMgr()
  if slua.isValid(Mgr) then
    Mgr:SetAllAppearancesActive(false, true)
  end
  if PlayerController.NotifyIsInResultView then
    PlayerController:NotifyIsInResultView(true)
  end
  self:HandleNeedHideObject()
  self.SequenceActor:Play(0)
  if UIManager.UI_Config_InGame.BattlePopTips then
    UIManager.ShowUI(UIManager.UI_Config_InGame.BattlePopTips)
  end
  return true
end
function BattleResultSpecialShowBaseLogic:HideBlueCircle()
  local BP_radiation = slua.loadClass("/Game/BluePrints/Environment/BP_radiation.BP_radiation")
  local OutList = slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.Actor"))
  local UGameplayStatics = import("GameplayStatics")
  OutList = UGameplayStatics.GetAllActorsOfClass(slua_GameFrontendHUD, BP_radiation, OutList)
  local nLen = OutList:Num()
  if 0 < nLen then
    for _, uActor in pairs(OutList) do
      uActor:SetActorHiddenInGame(true)
    end
  end
end
function BattleResultSpecialShowBaseLogic:PutOnAvatar(InPawn, InData)
  if not (slua.isValid(InPawn) and InData.wear_ext) or not slua.isValid(InPawn.CharacterAvatarComp2_BP) then
    return
  end
  local AvatarComp = InPawn.CharacterAvatarComp2_BP
  AvatarComp.bSyncAvatar = false
  AvatarComp.forceLodMode = true
  AvatarComp.bIsLobbyAvatar = false
  local rolewear = {}
  local wear_ext = InData.wear_ext or {}
  for k, v in pairs(wear_ext) do
    if ResultUtil.CanApplyAvatarShowType(k) then
      table.insert(rolewear, AvatarData.ConvertToAvatarCustom(v))
    end
  end
  local WearData = {
    uid = InData.UID,
    sex = InData.game_gender,
    headId = wear_ext[9] and wear_ext[9][1] or 0,
    BP_ARRAY_AvatarList = rolewear
  }
  WearData.headId = ResultUtil.CheckAvatarExist(WearData.headId)
  print(bWriteLog and "BattleResultSpecialShowBaseLogic:PutOnAvatar headId", WearData.headId)
  if WearData.sex == 0 then
    InPawn:SetMaleAnimClass()
  elseif WearData.sex == 1 then
    InPawn:SetFemaleAnimClass()
  end
  InPawn:InitDefaultAvatarByResID(WearData.sex, WearData.headId, 0)
  self:AddControlEvent(AvatarComp, "OnAvatarAllMeshLoaded", function()
    if slua.isValid(AvatarComp) then
      local ClothMesh = AvatarComp:GetMeshCompBySlotID(5)
      if slua.isValid(ClothMesh) then
        local AnimInstance = ClothMesh:GetAnimInstance()
        if slua.isValid(AnimInstance) and AnimInstance.SetForceIgnoreBoneRetarget then
          AnimInstance:SetForceIgnoreBoneRetarget(true)
          print(bWriteLog and "BattleResultSpecialShowBaseLogic:ChangeShowPawn ForceIgnoreBoneRetarget")
        end
      end
      self:RemoveControlEvent(AvatarComp, "OnAvatarAllMeshLoaded")
    end
  end)
  if slua.isValid(InPawn) and InPawn.SetPlayerUID then
    InPawn:SetPlayerUID(tostring(InData.UID))
  end
  for nSlot, AData in pairs(WearData.BP_ARRAY_AvatarList) do
    AvatarComp:PutOnEquipmentByResID(AData.ItemID, AvatarData.HashTableToAvatarCustom(AData))
  end
end
function BattleResultSpecialShowBaseLogic:HideAllUI()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    print(bWriteLog and "BattleResultSpecialShowBaseLogic:HideAllUI MainControlPanel_HideAllUI")
    if uPlayerController.CastUIMsg then
      uPlayerController:CastUIMsg("MainControlPanel_HideAllUI", "ingame")
    end
  else
    print(bWriteLog and "BattleResultSpecialShowBaseLogic:HideAllUI inValid uPlayerController")
    return
  end
  EventSystem:postEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_BEGIN_PERFORMANCE)
  local Character = uPlayerController.GetCurPlayerCharacter and uPlayerController:GetCurPlayerCharacter() or nil
  if slua.isValid(Character) then
    Character.bIsHideCrossHairType = true
  end
  local BackpackClothingEntryUI = UIManager.GetUI(UIManager.UI_Config_InGame.BackpackClothingEntryUI)
  if BackpackClothingEntryUI then
    BackpackClothingEntryUI:HideForReplayUI()
  end
end
function BattleResultSpecialShowBaseLogic:CheckBeginShow()
  print(bWriteLog and "BattleResultSpecialShowBaseLogic:CheckBeginShow ShowAssetLoaded:" .. tostring(self.ShowAssetLoaded) .. " bPawnAllCreated:" .. tostring(self.bPawnAllCreated))
  if self.ShowAssetLoaded and self.bPawnAllCreated then
    self:ShowTransitionUI(false)
    local ShowRes = self:StartLoadFinished()
    if ShowRes == false then
      self:ForceEndShow()
    end
    return true
  end
  return false
end
function BattleResultSpecialShowBaseLogic:ForceEndShow()
  self:EndResultProcess()
end
function BattleResultSpecialShowBaseLogic:EndResultProcess()
  if self.ResultProcessOver == true then
    print(bWriteLog and "BattleResultSpecialShowBaseLogic:EndResultProcess ResultProcessOver == true return")
    return
  end
  self.ResultProcessOver = true
  print(bWriteLog and "BattleResultSpecialShowBaseLogic:EndResultProcess")
  BattleResultSpecialShowBaseLogic.__super.EndResultProcess(self)
  if slua.isValid(self.SequenceActor) then
    self.SequenceActor:GoToEndAndStop()
  end
  for _, uShowPawn in pairs(self.ShowPawnList) do
    if slua.isValid(uShowPawn) then
      uShowPawn:K2_DestroyActor()
    end
  end
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.SkyTransition then
    PlayerController.SkyTransition:ClientSetState(0, 0)
  end
  self:ShowButtonUI(false)
  if self.CreatePawnTimer then
    Game:ClearTimer(self.CreatePawnTimer)
    self.CreatePawnTimer = nil
  end
  if self.AsyncLoadArrayID and slua.CancelLoadAssetArray then
    slua.CancelLoadAssetArray(self.AsyncLoadArrayID)
    self.AsyncLoadArrayID = nil
  end
  self:ChangeGraphQuality(false)
end
function BattleResultSpecialShowBaseLogic:HandleNeedHideObject()
  if not self.NeedHideClass then
    return
  end
  for _, ClassPath in pairs(self.NeedHideClass) do
    Util.GetAssetAsync(ClassPath .. "_C", function(TClassObject)
      if TClassObject then
        local uTempClass = slua.loadClass(ClassPath)
        local HiddenObjeInBorn = GameplayStatics.GetAllActorsOfClass(slua_GameFrontendHUD, uTempClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
        for _, Obj in pairs(HiddenObjeInBorn) do
          if slua.isValid(Obj) then
            Obj:SetActorHiddenInGame(true)
          end
        end
        print(bWriteLog and "BattleResultSpecialShowBaseLogic:HandleNeedHideObject NeedHiddenClassPath:", ClassPath)
      else
        print(bWriteLog and "BattleResultSpecialShowBaseLogic:HandleNeedHideObject Error NeedHiddenClassPath:", ClassPath)
      end
    end)
  end
end
function BattleResultSpecialShowBaseLogic:ReceiveSeqEvent(_, _, uPlayer, MsgName, InParam1, InParam2)
  print(bWriteLog and "BattleResultSpecialShowBaseLogic:ReceiveSeqEvent MsgName:", MsgName)
  if MsgName == "SpecialShow_SunnyDay" then
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) and PlayerController.SkyTransition then
      PlayerController.SkyTransition:ClientSetState(1, 0)
    end
  elseif MsgName == "SpecialShow_ChangeWeather" and InParam1 then
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) and PlayerController.SkyTransition then
      PlayerController.SkyTransition:ClientSetState(tonumber(InParam1), 0)
    end
  end
end
function BattleResultSpecialShowBaseLogic:CreatePawnEveryFrame()
  print(bWriteLog and "BattleResultSpecialShowBaseLogic:CreatePawnEveryFrame")
  if TableUtil.CountTable(self.tWinnerTeamInfo) > 0 then
    local nUID = 0
    local PData
    nUID, PData = self:TableGetFirstAndRemove(self.tWinnerTeamInfo)
    if nUID and PData then
      self.ShowPawnNum = self.ShowPawnNum + 1
      PData.UID = nUID
      local uShowPawn = ActorTools.SpawnActor(slua_GameFrontendHUD, self.LobbyPawnClassPath, FVector(0, 0, 0), FRotator(0, 0, 0), FVector(1))
      if slua.isValid(uShowPawn) then
        uShowPawn.ForceUseDefaultIdle = true
        self:PutOnAvatar(uShowPawn, PData)
        self.ShowPawnList[nUID] = uShowPawn
        uShowPawn:SetActorHiddenInGame(true)
      else
        print(bWriteLog and "BattleResultSpecialShowBaseLogic:StartLoadFinished Error Create Pawn")
      end
      if PData.name then
        self.PlayerNameList[nUID] = PData.name
        print(bWriteLog and "BattleResultSpecialShowBaseLogic:CreatePawnEveryFrame Name: ", PData.name)
      end
    else
      print(bWriteLog and "BattleResultSpecialShowBaseLogic:StartLoadFinished Pawn Info Error")
    end
    return
  end
  self.bPawnAllCreated = true
  if self.CreatePawnTimer then
    Game:ClearTimer(self.CreatePawnTimer)
    self.CreatePawnTimer = nil
  end
end
function BattleResultSpecialShowBaseLogic:TableGetFirstAndRemove(tb)
  local ReturnVal
  for key, value in pairs(tb) do
    ReturnVal = value
    tb[key] = nil
    return key, ReturnVal
  end
end
function BattleResultSpecialShowBaseLogic:ShowPlayerPawn()
  for _, uShowPawn in pairs(self.ShowPawnList) do
    if slua.isValid(uShowPawn) and slua.isValid(uShowPawn.CharacterAvatarComp2_BP) then
      uShowPawn:SetActorHiddenInGame(false)
      uShowPawn:ResetSkirtParticles()
      if slua.isValid(uShowPawn.Mesh) then
        uShowPawn.Mesh:SetAnimationMode(2)
      end
    end
  end
end
function BattleResultSpecialShowBaseLogic:ChangeGraphQuality(bChange)
  print(bWriteLog and "BattleResultSpecialShowBaseLogic:ChangeGraphQuality " .. tostring(bChange))
  local GraphicsNewData = require("client.slua.umg.NewSetting.GraphicsNew.GraphicsNewData")
  local logicSettingGraphics = require("client.slua.logic.setting.logic_setting_graphics")
  local ui_util = require("client.common.ui_util")
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local gameInstance = ui_util.GetGameInstance()
  local state = GraphicsNewData.BATTLE
  if bChange then
    local _, __, renderQuality = logicSettingGraphics.GetSettingByState(state)
    local TCDeviceLevel = Client.GetTCDeviceLevel()
    print(bWriteLog and "BattleResultSpecialShowBaseLogic:ChangeGraphQuality " .. tostring(renderQuality) .. tostring(TCDeviceLevel))
    if renderQuality < 4 and 7 < TCDeviceLevel then
      self.preArtQualityCMDSetting = self.GetCurrentArtQuality()
      gameInstance:ExecuteCMD("r.ShadowQuality", 1)
      gameInstance:ExecuteCMD("r.MaterialQualityLevel", 1)
      gameInstance:ExecuteCMD("r.MobileHDR", 1)
      gameInstance:ExecuteCMD("r.Mobile.SceneColorFormat", 2)
      gameInstance:ExecuteCMD("r.BloomQuality", 1)
      gameInstance:ExecuteCMD("r.Mobile.TonemapperFilm", 1)
      gameInstance:ExecuteCMD("r.ACESStyle", 0)
      gameInstance:ExecuteCMD("r.Mobile.AlwaysResolveDepth", 1)
      gameInstance:ExecuteCMD("t.MaxFPS", 30)
      self.bSwitchToHDR = true
    end
    gameInstance:ExecuteCMD("r.EnableLensFlareActor", 0)
    gameInstance:ExecuteCMD("r.EnableLowFPSRender", 0)
  else
    if self.bSwitchToHDR == true then
      self:ResetRenderQuality()
    end
    gameInstance:ExecuteCMD("r.EnableLensFlareActor", 1)
    gameInstance:ExecuteCMD("r.EnableLowFPSRender", 1)
  end
end
function BattleResultSpecialShowBaseLogic:GetCurrentArtQuality()
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local GetConsoleVariableIntValue = UKismetSystemLibrary.GetConsoleVariableIntValue
  local curArtQualityCMD = {}
  curArtQualityCMD["r.ShadowQuality"] = GetConsoleVariableIntValue("r.ShadowQuality")
  curArtQualityCMD["r.MaterialQualityLevel"] = GetConsoleVariableIntValue("r.MaterialQualityLevel")
  curArtQualityCMD["r.MobileHDR"] = GetConsoleVariableIntValue("r.MobileHDR")
  curArtQualityCMD["r.Mobile.SceneColorFormat"] = GetConsoleVariableIntValue("r.Mobile.SceneColorFormat")
  curArtQualityCMD["r.BloomQuality"] = GetConsoleVariableIntValue("r.BloomQuality")
  curArtQualityCMD["r.Mobile.TonemapperFilm"] = GetConsoleVariableIntValue("r.Mobile.TonemapperFilm")
  curArtQualityCMD["r.ACESStyle"] = GetConsoleVariableIntValue("r.ACESStyle")
  curArtQualityCMD["r.Mobile.AlwaysResolveDepth"] = GetConsoleVariableIntValue("r.Mobile.AlwaysResolveDepth")
  curArtQualityCMD["t.MaxFPS"] = GetConsoleVariableIntValue("t.MaxFPS")
  return curArtQualityCMD
end
function BattleResultSpecialShowBaseLogic:ResetRenderQuality()
  if self.preArtQualityCMDSetting == nil then
    return
  end
  print(bWriteLog and "BattleResultSpecialShowBaseLogic:ResetRenderQuality ")
  local ui_util = require("client.common.ui_util")
  local gameInstance = ui_util.GetGameInstance()
  gameInstance:ExecuteCMD("r.ShadowQuality", self.preArtQualityCMDSetting["r.ShadowQuality"])
  gameInstance:ExecuteCMD("r.MaterialQualityLevel", self.preArtQualityCMDSetting["r.MaterialQualityLevel"])
  gameInstance:ExecuteCMD("r.MobileHDR", self.preArtQualityCMDSetting["r.MobileHDR"])
  gameInstance:ExecuteCMD("r.Mobile.SceneColorFormat", self.preArtQualityCMDSetting["r.Mobile.SceneColorFormat"])
  gameInstance:ExecuteCMD("r.BloomQuality", self.preArtQualityCMDSetting["r.BloomQuality"])
  gameInstance:ExecuteCMD("r.Mobile.TonemapperFilm", self.preArtQualityCMDSetting["r.Mobile.TonemapperFilm"])
  gameInstance:ExecuteCMD("r.ACESStyle", self.preArtQualityCMDSetting["r.ACESStyle"])
  gameInstance:ExecuteCMD("r.Mobile.AlwaysResolveDepth", self.preArtQualityCMDSetting["r.Mobile.AlwaysResolveDepth"])
  gameInstance:ExecuteCMD("t.MaxFPS", self.preArtQualityCMDSetting["t.MaxFPS"])
end
local class = require("class")
local BattleResultProcessBaseLogic = require("GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.BattleResultProcessBaseLogic")
local CBattleResultSpecialShowBaseLogic = class(BattleResultProcessBaseLogic, nil, BattleResultSpecialShowBaseLogic)
return CBattleResultSpecialShowBaseLogic