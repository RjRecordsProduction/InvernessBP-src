local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local Config = require("GameLua.Mod.BaseMod.GamePlay.Config.HighlightMomentConfig")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local BackpackUtils = import("BackpackUtils")
local ESTEPoseState = import("ESTEPoseState")
local EPawnState = import("EPawnState")
local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
local ASTExtraShootWeapon = import("STExtraShootWeapon")
local ShowPawnActorPath = "/Game/Arts_Player/Characters/Animation/Shared_Anim/Hightlight/Vehicle/HighLightShowPawn_BP.HighLightShowPawn_BP"
local LobbyVehiclePath = "/Game/Arts_Player/Characters/Animation/Shared_Anim/Hightlight/Vehicle/HighlightShowVehicle_BP.HighlightShowVehicle_BP"
local TableUtil = require("common.table_util")
local LevelSequencePath = "/Game/Arts_Player/Characters/Animation/Shared_Anim/Hightlight/Vehicle/SEQ_VehicleLight_Universal.SEQ_VehicleLight_Universal"
local LevelSequenceActorPath = "/Game/Arts_Player/Characters/Animation/Shared_Anim/Hightlight/Vehicle/BP_Vehicle_HighLight_SeqActor.BP_Vehicle_HighLight_SeqActor_C"
local STExtraGameplayStatics = import("STExtraGameplayStatics")
local KismetMathLibrary = import("KismetMathLibrary")
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local FHitResult = import("/Script/Engine.HitResult")
local UEPathUtilityMethods = import("UEPathUtilityMethods")
local SocialVehicleSystem = require("client.slua.logic.lobby.Left.logic_social_vehicle")
local VehicleRefitHandler = require("client.network.Protocol.VehicleRefitHandler")
local CommonUtility = require("common.utility")
local HighlightMomentUtility = require("GameLua.Mod.BaseMod.GamePlay.HighlightMoment.HighlightMomentUtility")
local HighlightMomentSubsystem_DSChecker = require("GameLua.Mod.BaseMod.GamePlay.HighlightMoment.HighlightMomentSubsystem_DSChecker")
local EnvironmentTools = require("GameLua.Mod.BaseMod.Common.EnvironmentTools")
local ECharSpecLvSeq = import("ECharSpecialLevelSequenceType")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
local MultipleKillHighlightType = 9
local AngelRescueHighlightType = 15
local LightningWarHighlightType = 16
local HighlightMomentSubsystem = {}
local ETLogID = {
  TriggerHighlightCount = 16601,
  ConsumeCount = 16602,
  VehicleTriggerCount = 11524,
  VehicleClickCount = 11525,
  VehiclePlayCount = 11526
}
local ShowTrackNameList = {
  [1] = "HighLightShowPawn_BP",
  [2] = "HighLightShowPawn_BP2",
  [3] = "HighLightShowPawn_BP3",
  [4] = "HighLightShowPawn_BP4"
}
local ShowVehicleTrackPath = "HighlightShowVehicle_BP"
local WEAPON_HIGHTLIGHT_ID = 7
local UE_KINDA_SMALL_NUMBER = 1.0E-5
function HighlightMomentSubsystem:ctor()
  self.CurHighlightList = {}
  self.CurWeaponHighlightParam = nil
  self.CurTriggerOrder = 0
  self.nCurPlayingType = -1
  self.ShowPawnList = {}
  self.ShowVictim = nil
  self.VehicleKillRecords = {}
  self.VehicleInfoCache = {}
  self.VictimInfoCache = {}
  self.LastShowTouchInterface = true
end
function HighlightMomentSubsystem:OnInit()
  HighlightMomentSubsystem.__super.OnInit(self)
  Config = GamePlayTools.GetCurrentConfig("HighlightMomentConfig")
  local ModeID = GameMainConfig.GetModeID() or 0
  self.ScreenShotIdx = 1
  self.ScreenShotData = {}
  local ModeID = GameMainConfig.GetModeID()
  local IsBRMode = GamePlayTools.IsBRMode(ModeID)
  local IsThemeBRMode = GamePlayTools.IsThemeBRMode()
  local IsPeakGameMode = LogicPeakGameUtil.IsPeakGameMode(ModeID)
  print(bWriteLog and "HighlightMomentSubsystem:OnInit ModeID:" .. ModeID, IsBRMode, IsThemeBRMode, IsPeakGameMode)
  if not IsBRMode and not IsThemeBRMode and not IsPeakGameMode then
    print(bWriteLog and "HighlightMomentSubsystem:OnInit not enable mode", ModeID, IsBRMode, IsThemeBRMode)
    return
  end
  if not Client then
    self.CheckFuncRouter = {
      [-1] = {
        [-1] = {}
      }
    }
    for nHighlightID, tHighlightConfig in pairs(Config) do
      if type(nHighlightID) == "number" and not tHighlightConfig.bIgnoreCheck then
        local DamageType = tHighlightConfig.DamageType or -1
        local DamageItemID = tHighlightConfig.DamageItemID or -1
        if not self.CheckFuncRouter[DamageType] then
          self.CheckFuncRouter[DamageType] = {}
        end
        if not self.CheckFuncRouter[DamageType][DamageItemID] then
          self.CheckFuncRouter[DamageType][DamageItemID] = {}
        end
        local sFuncName = "CheckFunc" .. tHighlightConfig.HighlightName
        if type(HighlightMomentSubsystem_DSChecker[sFuncName]) == "function" then
          if not self[sFuncName] then
            self[sFuncName] = HighlightMomentSubsystem_DSChecker[sFuncName]
          end
          self.CheckFuncRouter[DamageType][DamageItemID][nHighlightID] = self[sFuncName]
          print(bWriteLog and string.format("HighlightMomentSubsystem:OnInit CheckFuncRouter HighlightID:%d, DamageType:%d, DamageItemID:%d, Func:%s", nHighlightID, DamageType, DamageItemID, sFuncName))
        end
      end
    end
    print(bWriteLog and "HighlightMomentSubsystem:OnInit - Adding DS module functions to self:")
    for sFuncName, fFunc in pairs(HighlightMomentSubsystem_DSChecker) do
      if type(fFunc) == "function" then
        if not self[sFuncName] then
          self[sFuncName] = fFunc
        end
        print(bWriteLog and string.format("HighlightMomentSubsystem:OnInit - %s is available as self:%s", sFuncName, sFuncName))
      end
    end
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_CHARACTER_DIED_BEFORE_BATTLERESULT, self.OnCharacterDied, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PAWN_GO_TO_NEAR_DEATH, self.OnNearDeath, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_REFRESH_ELIMINATION_KING, self.OnRefreshEliminationKing, self)
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_VEHICLE, EVENTID_VEHICLE_PLAYER_CHANGED, self.OnVehiclePlayerChange, self)
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_ADD_KILLS, self.OnAddKills, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_POST_PAWN_RESCUE, self.OnHandleRescued, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PROJECTILE_LAUNCH, self.OnHandleProjectileLaunch, self)
  else
    self.PlayFuncRouter = {}
    for nHighlightID, tHighlightConfig in pairs(Config) do
      if type(nHighlightID) == "number" then
        local sFuncName = "PlayFunc" .. tHighlightConfig.HighlightName
        if type(self[sFuncName]) == "function" then
          self.PlayFuncRouter[nHighlightID] = self[sFuncName]
          print(bWriteLog and string.format("HighlightMomentSubsystem:OnInit PlayFuncRouter HighlightID:%d, Func:%s", nHighlightID, sFuncName))
        end
      end
    end
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLAY_HIGHLIGHT_MOMENT, self.OnPressPlayHighlight, self)
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLAY_WEAPON_HIGHLIGHT_MOMENT, self.OnPressPlayWeaponHighlight, self)
    self.CurHighlightList = {}
    self.CurTriggerOrder = 0
    self.FlauntBtnPanel = UIManager.ShowUI(UIManager.UI_Config_InGame.FlauntBtnPanel)
    self.AutoExitSelfieModeTimer = nil
    self.nCurPlayingType = -1
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_TRIGGER_HIGHLIGHT_MOMENT, self.ClientOnTriggerHighlightMoment, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ENTER_SELFIE_MODE, self.OnEnterSelfieMode, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_EXIT_SELFIE_MODE, self.OnExitSelfieMode, self)
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_CONSUME_HIGHLIGHT_MOMENT, self.OnConsumeHighlightMoment, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_SEQUENCE_MSG, self.OnSeqMsg, self)
    self.bApplyingHighLightLayout = false
    GameplayData.AddSelfPlayerControllerEvent(self, "OnPostTakeDamageDelegate", self.OnPostTakeDamage, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ON_VEHICLE_TAKEDAMAGE, self.OnPostTakeDamage, self)
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_CARRY_BOX_SOMEONE_PUT_DOWN, self.OnSomeonePutDownCarriedBox, self)
  end
end
function HighlightMomentSubsystem:OnPostTakeDamage()
  if self.bPlayingVehicleHighlight then
    print(bWriteLog and "HighlightMomentSubsystem:OnPostTakeDamage")
    self:AutoExitSelfieMode()
  end
end
function HighlightMomentSubsystem:OnRelease()
  self.CurHighlightList = {}
  self.CurTriggerOrder = 0
  self.nCurPlayingType = -1
  self.ShowPawnList = {}
  self.VehicleKillRecords = {}
  if slua.isValid(self.VehicleInfoCache.SkeletalMesh) then
    slua.removeRef(self.VehicleInfoCache.SkeletalMesh)
  end
  self.VehicleInfoCache = {}
  self._SuperData = nil
  if self.HighlightPreloadHandleID then
    local asset_util = require("common.asset_util")
    asset_util.CancelAssetAsync(self.HighlightPreloadHandleID)
    self.HighlightPreloadHandleID = nil
  end
  self:Dispose()
end
function HighlightMomentSubsystem:TriggerHighlightMoment(PlayerCharacter, Type, Param, AchievementParams)
  if not slua.isValid(PlayerCharacter) or not PlayerCharacter.ClientRPC_TriggerHighlightMoment then
    print(bWriteLog and "HighlightMomentSubsystem:TriggerHighlightMoment PlayerCharacter is not valid", PlayerCharacter)
    return
  end
  Param = Param or 0
  local HighlightConfig = Config[Type]
  if not HighlightConfig then
    print(bWriteLog and "HighlightMomentSubsystem:TriggerHighlightMoment HighlightConfig is not valid", Type)
    return
  end
  print(bWriteLog and string.format("HighlightMomentSubsystem:TriggerHighlightMoment %s Type = %d, Param = %s", PlayerCharacter.PlayerKey, Type, Param))
  if HighlightConfig.IgnoreHighlight ~= true then
    PlayerCharacter:ClientRPC_TriggerHighlightMoment(Type, Param)
  end
  if HighlightConfig and HighlightConfig.EmoteID then
    local nCount = Game:GetItemNumByResID(PlayerCharacter, HighlightConfig.EmoteID)
    print(bWriteLog and string.format("HighlightMomentSubsystem:TriggerHighlightMoment %s Type = %d, EmoteID = % d, Count = %d", PlayerCharacter.PlayerKey, Type, HighlightConfig.EmoteID, nCount))
    if nCount <= 0 then
      Game:AddItemByResID(PlayerCharacter, HighlightConfig.EmoteID, 1, false)
    end
  end
  local uPlayerState = PlayerCharacter:GetPlayerStateSafety()
  if HighlightConfig and HighlightConfig.TLogID and 0 < HighlightConfig.TLogID and slua.isValid(uPlayerState) then
    print(bWriteLog and "HighlightMomentSubsystem:TriggerHighlightMoment TLogID: " .. tostring(HighlightConfig.TLogID))
    uPlayerState:AddGeneralCount(HighlightConfig.TLogID, 1, false)
  end
  if HighlightConfig and HighlightConfig.TriggerAchievementID and slua.isValid(uPlayerState) then
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_TRIGGER_ACHIEVEMENT, uPlayerState.UID, HighlightConfig.TriggerAchievementID, AchievementParams)
  end
end
function HighlightMomentSubsystem:ClientOnTriggerHighlightMoment(_, _, Type, Param)
  print(bWriteLog and "HighlightMomentSubsystem:ClientOnTriggerHighlightMoment" .. Type, Param)
  local ScriptHelperEngine = import("ScriptHelperEngine")
  if ScriptHelperEngine.IsLowMemoryDevice() then
    print(bWriteLog and "HighlightMomentSubsystem:ClientOnTriggerHighlightMoment LowMemoryDevice, return")
    return
  end
  if Type == 7 then
    self:ClientOnTriggerWeaponHighlightMoment(Param)
    return
  end
  if Type == 6 and not self:CollectVehicleInfoOnClient() then
    return
  end
  local HighlightConfig = Config[Type]
  if not HighlightConfig then
    print(bWriteLog and "HighlightMomentSubsystem:ClientOnTriggerHighlightMoment HighlightConfig is not valid", Type)
    return
  end
  if self.CurHighlightList[Type] == nil then
    self:SentPlayerTLog(ETLogID.TriggerHighlightCount)
    if Type == 6 then
      self:SentPlayerTLog(ETLogID.VehicleTriggerCount)
    end
  end
  local bNeedCover = true
  if self.CurHighlightList[Type] and self.CurHighlightList[Type].Param then
    Config = GamePlayTools.GetCurrentConfig("HighlightMomentConfig")
    if Config and Config[Type] then
      local Name = Config[Type].HighlightName
      if Name and self["CompareFunc" .. Name] and Param then
        bNeedCover = self["CompareFunc" .. Name](self, Param, self.CurHighlightList[Type].Param)
      end
    end
  end
  self.CurTriggerOrder = self.CurTriggerOrder + 1
  if bNeedCover then
    self.CurHighlightList[Type] = {Param = Param}
    self.CurHighlightList[Type].TriggerOrder = self.CurTriggerOrder
    if self.FlauntBtnPanel then
      self.FlauntBtnPanel:RefreshUI(self:GetHighlightNum())
      self.FlauntBtnPanel:ResetShinningTime(Type)
    end
  end
  xpcall(function()
    if HighlightConfig.EmoteID then
      local bpCfg = CDataTable.GetTableData("EmoteBPTable", HighlightConfig.EmoteID)
      if bpCfg and bpCfg.Path then
        self:AsyncLoadAsset(bpCfg.Path, function()
          print(bWriteLog and "HighlightMomentSubsystem:ClientOnTriggerHighlightMoment load emote ", HighlightConfig.EmoteID, tostring(bpCfg.Path))
        end)
      end
    end
    if HighlightConfig.SmartCameraID then
      local Cfg = CDataTable.GetTableData("CamMaster", HighlightConfig.SmartCameraID)
      if Cfg and Cfg.AnimPath then
        self:AsyncLoadAsset(Cfg.AnimPath, function()
          print(bWriteLog and "HighlightMomentSubsystem:ClientOnTriggerHighlightMoment load smart camera", HighlightConfig.SmartCameraID, tostring(Cfg.AnimPath))
        end)
      end
    end
  end, CommonUtility.ErrorMessageHandler, self)
end
function HighlightMomentSubsystem:ClientOnTriggerWeaponHighlightMoment(Param)
  print(bWriteLog and "HighlightMomentSubsystem:ClientOnTriggerWeaponHighlightMoment", Param)
  if not self:CacheVictimInfoOnClient(Param) then
    return
  end
  if self.CurWeaponHighlightParam == nil then
    self:SentPlayerTLog(ETLogID.TriggerHighlightCount)
  end
  self.CurWeaponHighlightParam = {Param = Param}
  if self.FlauntBtnPanel then
    self.FlauntBtnPanel:RefreshWeaponUI(true)
    self.FlauntBtnPanel:ResetWeaponShinningTime()
  end
end
function HighlightMomentSubsystem:GetHighlightNum()
  local Num = 0
  for Type, Param in pairs(self.CurHighlightList) do
    if Type and Param and Param.bConsumed ~= true then
      Num = Num + 1
    end
  end
  return Num
end
function HighlightMomentSubsystem:OnEnterSelfieMode()
  Client.RequireSlateTickEveryFrame(SlateUI_ID.HIGH_LIGHIT_MOVEMENT)
  print(bWriteLog and "HighlightMomentSubsystem:OnEnterSelfieMode-", self.nCurPlayingType, self.bApplyingHighLightLayout)
  local uCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uCharacter) and uCharacter.GetSkillManager and self:IsInPlayingState() then
    local SkillMgr = uCharacter:GetSkillManager()
    if slua.isValid(SkillMgr) and (SkillMgr:IsCastingSkill() or SkillMgr:IsPendingCastSkill()) then
      print(bWriteLog and "HighlightMomentSubsystem:OnEnterSelfieMode casting skill!")
      self:AutoExitSelfieMode()
      self.nCurPlayingType = -1
      return
    end
  end
  if self:IsInPlayingState() then
    self.bApplyingHighLightLayout = true
    local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
    if MainControlPanelTochButton then
      local UILayoutConfig = require("GameLua.Mod.BaseMod.Client.MainControlUI.UILayoutConfig")
      MainControlPanelTochButton:ApplyLayout(UILayoutConfig.LayoutNameConfig.HighLightLayout)
    end
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) then
      self.LastShowTouchInterface = PlayerController.bIsJoyStickShow == true
      PlayerController:ShowTouchInterface(false)
    end
    local uCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(uCharacter) and uCharacter.GetSkillManager then
      local SkillMgr = uCharacter:GetSkillManager()
      if slua.isValid(SkillMgr) then
        SkillMgr:SetSkillTagsDisable({0}, true, "PlayHighLight")
      end
    end
  end
  if self.EnterSelfieCallBack then
    self.EnterSelfieCallBack()
    self.EnterSelfieCallBack = nil
  end
end
function HighlightMomentSubsystem:OnExitSelfieMode()
  Client.ResetSlateTickEveryFrame(SlateUI_ID.HIGH_LIGHIT_MOVEMENT)
  Client.RequireSlateTickEveryFrameBeforeTargetFrame(130)
  print(bWriteLog and "HighlightMomentSubsystem:OnExitSelfieMode", self.nCurPlayingType, self.bApplyingHighLightLayout, self.LastShowTouchInterface)
  EnvironmentTools.ResetGrassDisplay()
  if self.bApplyingHighLightLayout then
    local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
    if MainControlPanelTochButton then
      local UILayoutConfig = require("GameLua.Mod.BaseMod.Client.MainControlUI.UILayoutConfig")
      MainControlPanelTochButton:UnApplyLayout(UILayoutConfig.LayoutNameConfig.HighLightLayout)
    end
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) then
      PlayerController:ShowTouchInterface(true)
    end
    self.bApplyingHighLightLayout = false
    local uCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(uCharacter) and uCharacter.GetSkillManager then
      local SkillMgr = uCharacter:GetSkillManager()
      if slua.isValid(SkillMgr) then
        SkillMgr:SetSkillTagsDisable({0}, false, "PlayHighLight")
      end
    end
  end
  self:ClearConsumedHighlights()
  if self.AutoExitSelfieModeTimer then
    self:RemoveGameTimer(self.AutoExitSelfieModeTimer)
    self.AutoExitSelfieModeTimer = nil
    print(bWriteLog and "HighlightMomentSubsystem:OnExitSelfieMode Remove AutoExitSelfieModeTimer")
  end
  self.nCurPlayingType = -1
  self:ShowLobbyPawn(false)
  self:ShowLobbyVehicle(false)
  if self.ExitSelfieCallBack then
    self.ExitSelfieCallBack()
    self.ExitSelfieCallBack = nil
  end
end
function HighlightMomentSubsystem:OnConsumeHighlightMoment(_, _, Type)
  print(bWriteLog and "HighlightMomentSubsystem:OnConsumeHighlightMoment", Type)
  if Type then
    self.CurHighlightList[Type].bConsumed = true
  end
  self.FlauntBtnPanel:RefreshUI(self:GetHighlightNum())
end
function HighlightMomentSubsystem:ClearConsumedHighlights()
  local elementsToRemove = {}
  for Type, Param in pairs(self.CurHighlightList) do
    if Type and Param and Param.bConsumed == true then
      table.insert(elementsToRemove, Type)
    end
  end
  for _, Type in ipairs(elementsToRemove) do
    self.CurHighlightList[Type] = nil
  end
end
function HighlightMomentSubsystem:OnPressPlayHighlight()
  local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
  if not IngameSelfieSubsystem then
    return
  end
  local uCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uCharacter) or not uCharacter.GetSkillManager then
    return
  end
  local SkillMgr = uCharacter:GetSkillManager()
  if slua.isValid(SkillMgr) and (SkillMgr:IsCastingSkill() or SkillMgr:IsPendingCastSkill()) then
    IngameTipsTools.BattleNormalTipsByTextID(3600024)
    return
  end
  local PlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(PlayerState) or not PlayerState.PhotoGrapherFeature then
    print(bWriteLog and "HighlightMomentSubsystem:OnPressPlayHighlight no PhotoGrapherFeature")
    return
  end
  local PhotoGrapherFeature = PlayerState.PhotoGrapherFeature
  if PhotoGrapherFeature.bPhotoGrapherOpenState then
    print(bWriteLog and "HighlightMomentSubsystem:OnPressPlayHighlight bPhotoGrapherOpenState")
    return
  end
  self:ClearConsumedHighlights()
  log_tree(bWriteLog and "HighlightMomentSubsystem:OnPressPlayHighlight CurHighlightList", self.CurHighlightList)
  local bPlayerInDoor = Game:IsPlayer(uCharacter) and uCharacter.InDoor
  local bBlockPlayByInDoor = false
  local OrderedHighlights = {}
  for Type, Param in pairs(self.CurHighlightList) do
    if Type and Param and Param.bConsumed ~= true and Param.TriggerOrder then
      table.insert(OrderedHighlights, {Type = Type, Param = Param})
    end
  end
  if not self:WaterCheck(uCharacter) then
    print(bWriteLog and "HighlightMomentSubsystem:OnPressPlayHighlight water check failed!")
    return
  end
  log_tree(bWriteLog and "HighlightMomentSubsystem:OnPressPlayHighlight OrderedHighlights", OrderedHighlights)
  if OrderedHighlights and 0 < #OrderedHighlights then
    for idx, Data in ipairs(OrderedHighlights) do
      local Type = Data.Type
      local HighlightConfig = Config[Type]
      if HighlightConfig then
        if bPlayerInDoor and not HighlightConfig.bCanPlayIndoor then
          bBlockPlayByInDoor = true
        else
          if Type == 6 and Data.Param and not Data.Param.bClick then
            Data.Param.bClick = true
            self:SentPlayerTLog(ETLogID.VehicleClickCount)
          end
          if Type == 6 and not self:VehiclePlayCheck() then
            print(bWriteLog and "HighlightMomentSubsystem:OnPressPlayHighlight vehicle play check failed!")
            return
          end
          local fPlayFunc = self.PlayFuncRouter[Type] or nil
          if fPlayFunc and not fPlayFunc(self, Data, HighlightConfig) then
            return
          end
          self.nCurPlaying          if HighlightConfig.EmoteID then
            if not uCharacter:AllowState(UEnums.EPawnState.PlayEmote, true) or uCharacter:HasState(UEnums.EPawnState.PlayEmote, true) then
              ShowNotice(30121)
              print(bWriteLog and "HighlightMomentSubsystem:OnPressPlayHighlight not AllowState PlayEmote!")
              return
            end
            local uEmoteComp = uCharacter:GetPlayEmoteComponent()
            if slua.isValid(uEmoteComp) then
              local bCanPlayEmote = uEmoteComp:IsCanPlayEmote(HighlightConfig.EmoteID, true)
              if not bCanPlayEmote then
                print(bWriteLog and "HighlightMomentSubsystem:OnPressPlayHighlight Can not PlayEmote!")
                break
              end
              self.EmoteMontageFinishedDalagate = uEmoteComp.EmoteMontageFinishedEvent:Add(function(emoteID, reason)
                print(bWriteLog and "HighlightMomentSubsystem:OnPressPlayHighlight EmoteMontageFinishedDalagate", emoteID, reason)
                self:AutoExitSelfieMode()
                if self.EmoteMontageFinishedDalagate then
                  uEmoteComp.EmoteMontageFinishedEvent:Remove(self.EmoteMontageFinishedDalagate)
                  self.EmoteMontageFinishedDalagate = nil
                end
              end)
            end
            IngameSelfieSubsystem:EnterSelfieWithSmartCameraAndEmote(HighlightConfig.SmartCameraID, {
              HighlightConfig.EmoteID
            }, {
              bSwitchWeapon = true,
              bNeedSwitchBack = true,
              bForbidNotice = true,
              bAutoStartSmartCamera = true,
              bIgnoreMomentReleaseMUI = true
            })
            IngameSelfieSubsystem:EnterSelfieWithSmartCamera(HighlightConfig.SmartCameraID)
          end
          EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_CONSUME_HIGHLIGHT_MOMENT, Type)
          self:SentPlayerTLog(ETLogID.ConsumeCount)
          if 0 < HighlightConfig.CloseTime then
            if self.AutoExitSelfieModeTimer then
              self:RemoveGameTimer(self.AutoExitSelfieModeTimer)
              self.AutoExitSelfieModeTimer = nil
            end
            self.AutoExitSelfieModeTimer = self:AddGameTimer(HighlightConfig.CloseTime, false, function()
              self:AutoExitSelfieMode()
            end)
          end
          bBlockPlayByInDoor = false
          break
        end
      end
    end
    if bBlockPlayByInDoor then
      IngameTipsTools.BattleNormalTipsByTextID(65338)
    end
  end
end
function HighlightMomentSubsystem:OnPressPlayWeaponHighlight()
  local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
  if not IngameSelfieSubsystem then
    return
  end
  local uCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uCharacter) or not uCharacter.GetSkillManager then
    return
  end
  local SkillMgr = uCharacter:GetSkillManager()
  if slua.isValid(SkillMgr) and (SkillMgr:IsCastingSkill() or SkillMgr:IsPendingCastSkill()) then
    IngameTipsTools.BattleNormalTipsByTextID(3600024)
    return
  end
  local PlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(PlayerState) or not PlayerState.PhotoGrapherFeature then
    print(bWriteLog and "HighlightMomentSubsystem:OnPressPlayWeaponHighlight no PhotoGrapherFeature")
    return
  end
  local PhotoGrapherFeature = PlayerState.PhotoGrapherFeature
  if PhotoGrapherFeature.bPhotoGrapherOpenState then
    print(bWriteLog and "HighlightMomentSubsystem:OnPressPlayWeaponHighlight bPhotoGrapherOpenState")
    return
  end
  if not self.CurWeaponHighlightParam then
    return
  end
  log_tree(bWriteLog and "HighlightMomentSubsystem:OnPressPlayWeaponHighlight CurWeaponHighlightParam", self.CurWeaponHighlightParam)
  local HighlightConfig = Config[WEAPON_HIGHTLIGHT_ID]
  local OutParams = {}
  if HighlightConfig then
    local fPlayFunc = self.PlayFuncRouter[WEAPON_HIGHTLIGHT_ID] or nil
    if fPlayFunc and not fPlayFunc(self, self.CurWeaponHighlightParam, HighlightConfig, OutParams) then
      if OutParams.bNeedClearUIHint then
        self.FlauntBtnPanel:ReleaseWeaponUIHint()
      end
      return
    end
    self.nCurPlayingType = WEAPON_HIGHTLIGHT_ID
    self.CurWeaponHighlightParam = nil
    self.FlauntBtnPanel:RefreshWeaponUI(false)
    self:SentPlayerTLog(ETLogID.ConsumeCount)
    if HighlightConfig.CloseTime > 0 then
      if self.AutoExitSelfieModeTimer then
        self:RemoveGameTimer(self.AutoExitSelfieModeTimer)
        self.AutoExitSelfieModeTimer = nil
      end
      self.AutoExitSelfieModeTimer = self:AddGameTimer(HighlightConfig.CloseTime, false, function()
        self:AutoExitSelfieMode()
      end)
    end
  end
end
function HighlightMomentSubsystem:OnSeqMsg(_, __, Player, sSeqEventMsg, ID)
  print(bWriteLog and "HighlightMomentSubsystem:OnSeqMsg", sSeqEventMsg, ID)
  if ID == nil or ID == "" then
    ID = self.nCurPlayingType
  end
  print(bWriteLog and "HighlightMomentSubsystem:OnSeqMsg ID", ID)
  if sSeqEventMsg == "Highlight" and ID then
    local nHighlightID = tonumber(ID)
    local tHighlightConfig = Config[nHighlightID]
    if tHighlightConfig then
      do
        local SkinVehicleConfig
        local UIName = tHighlightConfig.HighlightName .. "FlauntDynamicUI"
        if nHighlightID == 6 and self.VehicleInfoCache and self.VehicleInfoCache.VehicleSkinItemID and self.VehicleInfoCache.VehicleSkinItemID > 0 then
          SkinVehicleConfig = self.VehicleInfoCache.VehicleSkinItemID and Config.VehicleSpecialSkinConfig[self.VehicleInfoCache.VehicleSkinItemID] or nil
          if SkinVehicleConfig then
            local SkinUIName = UIName .. "_" .. (SkinVehicleConfig.Type and SkinVehicleConfig.Type or self.VehicleInfoCache.VehicleSkinItemID)
            if UIManager.UI_Config_InGame[SkinUIName] then
              UIName = SkinUIName
            end
          end
        end
        if not UIManager.UI_Config_InGame[UIName] then
          UIName = "NewCommonFlauntDynamicUI"
        end
        local tUIConfig = UIManager.UI_Config_InGame[UIName] or UIManager.UI_Config[UIName]
        if tUIConfig then
          local TempUIConfig = TableUtil.CopyTable(tUIConfig)
          local itemDefineID = FItemDefineID(9, self.VehicleInfoCache.VehicleSkinItemID or 0)
          local bIsItemExist = self.VehicleInfoCache.VehicleSkinItemID and BackpackUtils.IsBattleItemHandleExist(itemDefineID, true, false, false) or false
          if SkinVehicleConfig and SkinVehicleConfig.UIPath and bIsItemExist then
            TempUIConfig.path = SkinVehicleConfig.UIPath
          end
          print(bWriteLog and "HighlightMomentSubsystem:OnSeqMsg", ID, UIName, TempUIConfig.path, bIsItemExist)
          local DoShowUI = function()
            local FlauntDynamicUI = UIManager.ShowUI(TempUIConfig)
            if FlauntDynamicUI then
              FlauntDynamicUI:Play(tHighlightConfig.HighlightName, self.CurHighlightList[nHighlightID], nHighlightID, tHighlightConfig)
            end
          end
          local PathList = {}
          if tHighlightConfig.IconPath and tHighlightConfig.IconPath ~= "" then
            table.insert(PathList, tHighlightConfig.IconPath)
          end
          if tHighlightConfig.BadgePath and tHighlightConfig.BadgePath ~= "" then
            table.insert(PathList, tHighlightConfig.BadgePath)
          end
          if #PathList == 0 then
            DoShowUI()
          else
            do
              local asset_util = require("common.asset_util")
              if self.HighlightPreloadHandleID then
                asset_util.CancelAssetAsync(self.HighlightPreloadHandleID)
              end
              self.HighlightPreloadHandleID = asset_util.GetAssetsArrayAsyncParallel(PathList, function()
                print(bWriteLog and "HighlightMomentSubsystem:OnSeqMsg PreloadAssetAsyncParallel", self.HighlightPreloadHandleID)
                self.HighlightPreloadHandleID = nil
                DoShowUI()
              end)
            end
          end
        end
      end
    end
  elseif sSeqEventMsg == "ScreenShot" and ID then
    local IsSharing = UIManager.IsUIShow(UIManager.UI_Config.share_component)
    if IsSharing then
      print(bWriteLog and "HighlightMomentSubsystem IsSharing")
      return
    end
    local ScreenshotMaker = import("ScreenshotMaker")
    local ScreenShotName = "Highlight" .. self.ScreenShotIdx .. ".jpg"
    local sSharePath = ScreenshotMaker.MakePictureWithName(ScreenShotName)
    print(bWriteLog and "HighlightMomentSubsystem sSharePath", sSharePath, ID)
    table.insert(self.ScreenShotData, {
      PicPath = sSharePath,
      ID = tonumber(ID)
    })
    self.ScreenShotIdx = self.ScreenShotIdx + 1
  end
end
function HighlightMomentSubsystem:AutoExitSelfieMode()
  local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
  if not IngameSelfieSubsystem then
    return
  end
  print(bWriteLog and "HighlightMomentSubsystem:AutoExitSelfieMode")
  IngameSelfieSubsystem:ExitSelfie()
  self.nCurPlayingType = -1
end
function HighlightMomentSubsystem:IsInPlayingState()
  return self.nCurPlayingType and self.nCurPlayingType > 0
end
function HighlightMomentSubsystem:SentPlayerTLog(nTLogID)
  local uPlayerState = GameplayData.GetPlayerState()
  if slua.isValid(uPlayerState) then
    uPlayerState:RPC_ServerAddGeneralCount(nTLogID, 1, false)
    print(bWriteLog and "HighlightMomentSubsystem:SentPlayerTLog " .. tostring(nTLogID))
  end
end
function HighlightMomentSubsystem:PlayFuncVehicleMultiKill(Data, HighlightConfig)
  print(bWriteLog and "HighlightMomentSubsystem:PlayFuncVehicleMultiKill", Data, HighlightConfig)
  local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
  local PhotoGrapherSubSystem = SubsystemMgr:Get("PhotoGrapherSubSystem")
  if not IngameSelfieSubsystem or not PhotoGrapherSubSystem then
    print(bWriteLog and "HighlightMomentSubsystem:PlayFuncVehicleMultiKill failed")
    return false
  end
  local uVehicle = self:GetCurrentVehicle()
  if slua.isValid(uVehicle) and uVehicle.VehicleTransform then
    local ETransformState = import("ETransformState")
    local MajorTransformComponent = uVehicle.VehicleTransform:GetMajorTransformComponent()
    local ClientNetState = MajorTransformComponent and MajorTransformComponent.ClientNetState or nil
    if ClientNetState and ClientNetState.State == ETransformState.PreTransform or ClientNetState.State == ETransformState.Transforming then
      print(bWriteLog and "HighlightMomentSubsystem:PlayFuncVehicleMultiKill is Transforming")
      return false
    end
  end
  if not IngameSelfieSubsystem:EnterSelfie() then
    print(bWriteLog and "HighlightMomentSubsystem:PlayFuncVehicleMultiKill EnterSelfie failed")
    return false
  end
  function self.EnterSelfieCallBack()
    local PhotoGrapherSubSystem = SubsystemMgr:Get("PhotoGrapherSubSystem")
    if not PhotoGrapherSubSystem then
      self.bWaitingEnterVehicleHighlight = false
      return
    end
    PhotoGrapherSubSystem:SetHideAllPawn(true, true)
    PhotoGrapherSubSystem:ModifyPetOpen(false)
    self:AddGameTimer(0.1, false, function()
      self.bWaitingEnterVehicleHighlight = false
      self:PlayVehicleHighlightInternal()
    end)
  end
  self.bWaitingEnterVehicleHighlight = true
  self:AddGameTimer(1, false, function()
    self.bWaitingEnterVehicleHighlight = false
  end)
  return true
end
function HighlightMomentSubsystem:PlayFuncUpgradedWeaponKill(Data, HighlightConfig, OutParams)
  log_tree(bWriteLog and "HighlightMomentSubsystem:PlayFuncUpgradedWeaponKill", Data, HighlightConfig)
  local VictimPlayerKey = Data.Param
  if not VictimPlayerKey then
    log_tree(bWriteLog and "HighlightMomentSubsystem:PlayFuncUpgradedWeaponKill invalid VictimPlayerKey!", Data)
    return false
  end
  OutParams = OutParams or {}
  local VictimSequenceConfig = self.VictimInfoCache
  if not VictimSequenceConfig then
    print(bWriteLog and "HighlightMomentSubsystem:PlayFuncUpgradedWeaponKill not valid VictimSequenceConfig!")
    return false
  end
  local UPropsUtils = import("PropsUtils")
  local VictimDeadBox = UPropsUtils.GetPlayerTombBoxByPlayerKey(CGameState, VictimPlayerKey)
  local uTraceStartLocation = slua.isValid(VictimDeadBox) and VictimDeadBox:K2_GetActorLocation() or VictimSequenceConfig.FreshedLocation
  local tTraceIgnoreActors = {VictimDeadBox}
  local HighlightMomentConditions = require("GameLua.Mod.BaseMod.GamePlay.HighlightMoment.Conditions.index")
  local ConditionContext = {
    CheckingActor = VictimDeadBox,
    TraceStartLocation = uTraceStartLocation,
    TraceIgnoreActors = tTraceIgnoreActors
  }
  local Blackboard = OutParams
  local ConditionList = {
    HighlightMomentConditions.PawnState.CarryBoxStateCondition(ConditionContext, Blackboard),
    HighlightMomentConditions.PawnState.GunADSStateCondition(ConditionContext, Blackboard),
    HighlightMomentConditions.VictimDistanceCondition(ConditionContext, Blackboard)
  }
  for _, Condition in ipairs(ConditionList) do
    if not Condition:Check() then
      self:HandleHighlightMomentConditionFail(Blackboard, VictimSequenceConfig)
      return false
    end
  end
  if uTraceStartLocation then
    local uCheckedLocation = VictimSequenceConfig.VictimLocation
    if uCheckedLocation and uTraceStartLocation:Equals(uCheckedLocation, UE_KINDA_SMALL_NUMBER) then
      print(bWriteLog and "HighlightMomentSubsystem:PlayFuncUpgradedWeaponKill already checked location!", uCheckedLocation:ToString())
      local TipsID = VictimSequenceConfig.nCachedTipsID
      if TipsID then
        IngameTipsTools.BattleNormalTipsByTextID(TipsID)
      end
      return false
    end
    VictimSequenceConfig.VictimLocation = uTraceStartLocation
    VictimSequenceConfig.nCachedTipsID = nil
  end
  local PostDistanceConditionList = {
    HighlightMomentConditions.WaterCheckCondition(ConditionContext, Blackboard, self),
    HighlightMomentConditions.ProperRotationCondition(ConditionContext, Blackboard, VictimSequenceConfig.nTargetLen, VictimSequenceConfig.tRotationOffset),
    HighlightMomentConditions.CheckObstacleCondition(ConditionContext, Blackboard, VictimSequenceConfig.nCeilingHeight, VictimSequenceConfig.uBoundingBox2D, VictimSequenceConfig.nFloorMaxHeight),
    HighlightMomentConditions.CheckAndEnterSelfieCondition(ConditionContext, Blackboard)
  }
  for _, Condition in ipairs(PostDistanceConditionList) do
    if not Condition:Check() then
      self:HandleHighlightMomentConditionFail(Blackboard, VictimSequenceConfig)
      return false
    end
  end
  local uProperRotation = Blackboard.ProperRotation
  if not uProperRotation or not VictimSequenceConfig then
    return false
  end
  VictimSequenceConfig.VictimRotation = uProperRotation
  function self.EnterSelfieCallBack()
    local PhotoGrapherSubSystem = SubsystemMgr:Get("PhotoGrapherSubSystem")
    if not PhotoGrapherSubSystem then
      EnvironmentTools.ResetGrassDisplay()
      return
    end
    PhotoGrapherSubSystem:SetHideAllPawn(true, true)
    EnvironmentTools.SetGrassDisplay(false)
    self:AddGameTimer(0.02, false, function()
      local bSuccess = self:PlayerUpgradedWeaponKillInternal()
      if not bSuccess then
        EnvironmentTools.ResetGrassDisplay()
      end
    end)
  end
  return true
end
function HighlightMomentSubsystem:HandleHighlightMomentConditionFail(Blackboard, VictimSequenceConfig)
  if not Blackboard then
    return
  end
  print(bWriteLog and "HighlightMomentSubsystem:HandleHighlightMomentConditionFail condition failed", Blackboard.nTipsID)
  local TipsID = Blackboard.nTipsID
  if TipsID then
    IngameTipsTools.BattleNormalTipsByTextID(TipsID)
  end
  if VictimSequenceConfig and Blackboard.nCachedTipsID then
    VictimSequenceConfig.nCachedTipsID = Blackboard.nCachedTipsID
  end
end
function HighlightMomentSubsystem:PlayVehicleHighlightInternal()
  local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
  if not IngameSelfieSubsystem or not IngameSelfieSubsystem.bIsIngameSelfieMode then
    print(bWriteLog and "HighlightMomentSubsystem:PlayVehicleHighlightInternal not in SelfieMode")
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "HighlightMomentSubsystem:PlayVehicleHighlightInternal not valid PlayerController!")
    return
  end
  if not (self.VehicleInfoCache and self.VehicleInfoCache.Loc) or not self.VehicleInfoCache.Rot then
    print(bWriteLog and "HighlightMomentSubsystem:PlayVehicleHighlightInternal not valid VehicleInfoCache!")
    return
  end
  local SkinVehicleConfig = self.VehicleInfoCache.VehicleSkinItemID and Config.VehicleSpecialSkinConfig[self.VehicleInfoCache.VehicleSkinItemID] or nil
  local BindingData = {}
  local PlayTransform
  local Cur  local BackpackUtils = import("BackpackUtils")
  local itemDefineID = FItemDefineID(9, self.VehicleInfoCache.VehicleSkinItemID or 0)
  local bIsItemExist = self.VehicleInfoCache.VehicleSkinItemID and BackpackUtils.IsBattleItemHandleExist(itemDefineID, true, false, false) or false
  print(bWriteLog and "HighlightMomentSubsystem:PlayVehicleHighlightInternal", self.VehicleInfoCache.VehicleSkinItemID, bIsItemExist)
  if bIsItemExist and SkinVehicleConfig and SkinVehicleConfig.LevelSeq and UEPathUtilityMethods.IsPathExist(SkinVehicleConfig.LevelSeq) then
    CurLevelSequencePath = SkinVehicleConfig.LevelSeq
    PlayTransform = KismetMathLibrary.MakeTransform(self.VehicleInfoCache.Loc, self.VehicleInfoCache.Rot, FVector(1, 1, 1))
    local Pawn = GameplayData.GetPlayerCharacter()
    if SkinVehicleConfig.ActorPath and slua.isValid(Pawn) then
      self.ShowVehicleActor = ActorTools.SpawnActor(Pawn, SkinVehicleConfig.ActorPath, self.VehicleInfoCache.Loc, self.VehicleInfoCache.Rot, FVector(1, 1, 1))
    end
  else
    if not self:ShowLobbyVehicle(true) then
      print(bWriteLog and "HighlightMomentSubsystem:PlayVehicleHighlightInternal not valid LobbyVehicle!", self.VehicleInfoCache.VehicleSkinItemID)
      self:SeqEndShow(false)
      return
    end
    if not slua.isValid(self.ShowVehicleActor) then
      print(bWriteLog and "HighlightMomentSubsystem:PlayVehicleHighlightInternal not valid ShowVehicleActor!")
      self:SeqEndShow(false)
      return
    end
    PlayTransform = self.ShowVehicleActor:GetTransform()
  end
  BindingData[ShowVehicleTrackPath] = self.ShowVehicleActor
  self:ShowLobbyPawn(true)
  for key, uShowPawn in pairs(self.ShowPawnList) do
    if slua.isValid(uShowPawn) then
      local ChannelName = ShowTrackNameList[key] or 0
      BindingData[ChannelName] = uShowPawn
    end
  end
  self.LevelSequenceActor = Game:PlayLevelSequence(PlayerController, CurLevelSequencePath, PlayTransform, LevelSequenceActorPath, false, BindingData, PlayerController)
  if not slua.isValid(self.LevelSequenceActor) then
    print(bWriteLog and "HighlightMomentSubsystem:PlayVehicleHighlightInternal not valid LevelSequenceActor!")
    self:SeqEndShow(false)
    return
  end
  print(bWriteLog and "HighlightMomentSubsystem:PlayVehicleHighlightInternal", self.VehicleInfoCache.VehicleSkinItemID, CurLevelSequencePath)
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ENTER_SMART_CAMERA)
  self.LevelSequenceActor:SetOnSequenceStopCallBack(function()
    self:SeqEndShow(false)
    EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_SMARTCAMERA_SEQUENCE_END)
  end, PlayerController)
  self.LevelSequenceActor:SetOnSequenceFinishedCallBack(function()
    self:SeqEndShow(true)
    EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_SMARTCAMERA_SEQUENCE_END)
  end, PlayerController)
  local Character = GameplayData.GetPlayerCharacter()
  if slua.isValid(Character) then
    self.LevelSequenceActor:SetCharacterAndPlay(Character)
  end
  self.bPlayingVehicleHighlight = true
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ENTER_VEHICLE_HIGHLIGHT_MOMENT)
  function self.ExitSelfieCallBack()
    print(bWriteLog and "HighlightMomentSubsystem:ExitSelfieCallBack", slua.isValid(self.LevelSequenceActor))
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_EXIT_VEHICLE_HIGHLIGHT_MOMENT)
    if slua.isValid(self.LevelSequenceActor) then
      self.LevelSequenceActor:Stop()
    end
    local PhotoGrapherSubSystem = SubsystemMgr:Get("PhotoGrapherSubSystem")
    if not PhotoGrapherSubSystem then
      return
    end
    PhotoGrapherSubSystem:ModifyPetOpen(true)
  end
  self:SentPlayerTLog(ETLogID.VehiclePlayCount)
end
function HighlightMomentSubsystem:PlayerUpgradedWeaponKillInternal()
  local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
  if not IngameSelfieSubsystem or not IngameSelfieSubsystem.bIsIngameSelfieMode then
    print(bWriteLog and "HighlightMomentSubsystem:PlayerUpgradedWeaponKillInternal not in SelfieMode")
    self:VictimSeqEndShow(false)
    return false
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "HighlightMomentSubsystem:PlayerUpgradedWeaponKillInternal not valid PlayerController!")
    self:VictimSeqEndShow(false)
    return false
  end
  local VictimSequenceConfig = self.VictimInfoCache
  if not VictimSequenceConfig then
    print(bWriteLog and "HighlightMomentSubsystem:PlayerUpgradedWeaponKillInternal not valid VictimSequenceConfig!")
    self:VictimSeqEndShow(false)
    return false
  end
  local uProperRotation = VictimSequenceConfig.VictimRotation
  if not uProperRotation then
    self:VictimSeqEndShow(false)
    return false
  end
  VictimSequenceConfig.VictimLocation.Z = VictimSequenceConfig.VictimLocation.Z + 1
  local PlayTransform = KismetMathLibrary.MakeTransform(VictimSequenceConfig.VictimLocation, uProperRotation, FVector(1, 1, 1))
  local CurLevelSequenceSoftPath = VictimSequenceConfig.SequencePath
  if not CurLevelSequenceSoftPath or not CurLevelSequenceSoftPath:IsValid() then
    print(bWriteLog and "HighlightMomentSubsystem:PlayerUpgradedWeaponKillInternal not valid SequenceConfigPath!")
    self:VictimSeqEndShow(false)
    return false
  end
  local CurLevelSequencePath = CurLevelSequenceSoftPath:ToString()
  local LevelSequenceActor = Game:PlayLevelSequence(PlayerController, CurLevelSequencePath, PlayTransform, LevelSequenceActorPath, false, {}, PlayerController)
  self.  if not slua.isValid(LevelSequenceActor) then
    print(bWriteLog and "HighlightMomentSubsystem:PlayerUpgradedWeaponKillInternal not valid LevelSequenceActor!")
    self:VictimSeqEndShow(false)
    return false
  end
  print(bWriteLog and "HighlightMomentSubsystem:PlayerUpgradedWeaponKillInternal", self.VictimInfoCache.PlayerKey, CurLevelSequencePath)
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ENTER_SMART_CAMERA)
  LevelSequenceActor:SetOnSequenceStopCallBack(function()
    self:VictimSeqEndShow(false)
    self:ToggleVictimDeadBoxVisibility(true)
    EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_SMARTCAMERA_SEQUENCE_END)
  end, PlayerController)
  LevelSequenceActor:SetOnSequenceFinishedCallBack(function()
    self:VictimSeqEndShow(true)
    self:ToggleVictimDeadBoxVisibility(true)
    EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_SMARTCAMERA_SEQUENCE_END)
  end, PlayerController)
  self:ToggleVictimDeadBoxVisibility(false)
  local Character = GameplayData.GetPlayerCharacter()
  if slua.isValid(Character) then
    if slua.isValid(LevelSequenceActor.uCamera) then
      PlayerController:SetViewTargetTest(LevelSequenceActor.uCamera)
    end
    LevelSequenceActor:SetCharacterAndPlay(Character)
  end
  function self.ExitSelfieCallBack()
    print(bWriteLog and "HighlightMomentSubsystem:ExitSelfieCallBack", slua.isValid(self.LevelSequenceActor))
    if slua.isValid(self.LevelSequenceActor) then
      self.LevelSequenceActor:Stop()
    end
  end
  return true
end
function HighlightMomentSubsystem:SeqEndShow(bFinish)
  print(bWriteLog and "HighlightMomentSubsystem:SeqEndShow", bFinish)
  self:ShowLobbyPawn(false)
  self:ShowLobbyVehicle(false)
  self:AutoExitSelfieMode()
  self.bPlayingVehicleHighlight = false
end
function HighlightMomentSubsystem:VictimSeqEndShow(bFinish)
  print(bWriteLog and "HighlightMomentSubsystem:VictimSeqEndShow", bFinish)
  self:AutoExitSelfieMode()
  self.bPlayingVehicleHighlight = false
end
function HighlightMomentSubsystem:ToggleVictimDeadBoxVisibility(bVisible)
  local VictimPlayerKey = self.VictimInfoCache.PlayerKey
  if not VictimPlayerKey or VictimPlayerKey <= 0 then
    return
  end
  local UPropsUtils = import("PropsUtils")
  local VictimDeadBox = UPropsUtils.GetPlayerTombBoxByPlayerKey(GameplayData.GetPlayerController(), VictimPlayerKey)
  if not slua.isValid(VictimDeadBox) then
    return
  end
  if slua.isValid(VictimDeadBox.DeadBoxAvatarComponent_BP) then
    if not bVisible then
      VictimDeadBox.DeadBoxAvatarComponent_BP:StopCurrentSequenceActor()
    else
      VictimDeadBox.DeadBoxAvatarComponent_BP:PreChangeItemAvatar(VictimDeadBox:GetAvatarId())
    end
  end
  print(bWriteLog and string.format("HighlightMomentSubsystem:ToggleVictimDeadBoxVisibility %s %s", bVisible and "Show" or "Hide", VictimPlayerKey))
  VictimDeadBox:SetActorHiddenInGame(not bVisible)
end
function HighlightMomentSubsystem:CheckCurrentVehicle()
  local uCurrentVehicle = self:GetCurrentVehicle()
  if not (slua.isValid(uCurrentVehicle) and self.VehicleInfoCache.nGUID) or self.VehicleInfoCache.nGUID <= 0 then
    print(bWriteLog and "HighlightMomentSubsystem:CheckCurrentVehicle failed uCurrentVehicle", uCurrentVehicle, self.VehicleInfoCache.nGUID)
    return false
  end
  local nGUID = slua.GetNetGUID(uCurrentVehicle)
  if nGUID and 0 < nGUID and nGUID == self.VehicleInfoCache.nGUID then
    return true
  end
  print(bWriteLog and "HighlightMomentSubsystem:CheckCurrentVehicle failed nGUID", nGUID)
  return false
end
function HighlightMomentSubsystem:CollectVehicleInfoOnClient()
  local uCurrentVehicle = self:GetCurrentVehicle()
  if not slua.isValid(uCurrentVehicle) then
    print(bWriteLog and "HighlightMomentSubsystem:CollectVehicleInfoOnClient uCurrentVehicle invalid!")
    return false
  end
  local nGUID = slua.GetNetGUID(uCurrentVehicle)
  if not nGUID or nGUID <= 0 then
    print(bWriteLog and "HighlightMomentSubsystem:CollectVehicleInfoOnClient nGUID invalid!")
    return false
  end
  local uVehicleSeatComp = uCurrentVehicle:GetVehicleSeats()
  if not slua.isValid(uVehicleSeatComp) then
    print(bWriteLog and "HighlightMomentSubsystem:CollectVehicleInfoOnClient uVehicleSeatComp invalid!")
    return false
  end
  self.VehicleInfoCache = {}
  self.VehicleInfoCache.  self.VehicleInfoCache.SkeletalMesh = uCurrentVehicle.Mesh.SkeletalMesh
  if slua.isValid(self.VehicleInfoCache.SkeletalMesh) then
    slua.addRef(self.VehicleInfoCache.SkeletalMesh)
  end
  self.VehicleInfoCache.VehicleSkinItemID = uCurrentVehicle:GetVehicleSkinItemID()
  if Config.VehicleReplaceMap[self.VehicleInfoCache.VehicleSkinItemID] then
    self.VehicleInfoCache.VehicleSkinItemID = Config.VehicleReplaceMap[self.VehicleInfoCache.VehicleSkinItemID]
  end
  print(bWriteLog and "HighlightMomentSubsystem:CollectVehicleInfoOnClient VehicleSkinItemID", self.VehicleInfoCache.VehicleSkinItemID)
  self.VehicleInfoCache.SeatInfo = {}
  for i = 0, uVehicleSeatComp:GetSeatNum() - 1 do
    local Passenger = uVehicleSeatComp:GetPassenger(i)
    if Game:IsValid(Passenger) then
      local bIsDying = Passenger:HasState(EPawnState.Dying)
      print(bWriteLog and "HighlightMomentSubsystem:CollectVehicleInfoOnClient Passenger", Passenger.PlayerKey, bIsDying, Passenger)
      if not bIsDying then
        table.insert(self.VehicleInfoCache.SeatInfo, Passenger.PlayerKey)
      end
    end
  end
  log_tree(bWriteLog and "HighlightMomentSubsystem:CollectVehicleInfoOnClient VehicleInfoCache", self.VehicleInfoCache)
  return true
end
function HighlightMomentSubsystem:CacheVictimInfoOnClient(VictimPlayerKey)
  if not VictimPlayerKey then
    return false
  end
  local GameState = slua_GameFrontendHUD:GetGameState()
  if not GameState or not slua.isValid(GameState) then
    print(bWriteLog and "HighlightMomentSubsystem:PlayFuncUpgradedWeaponKill invalid GameState!")
    return
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) and PlayerCharacter.GetCurrentWeapon then
    print(bWriteLog and string.format("HighlightMomentSubsystem:CacheVictimInfoOnClient invalid PlayerCharacter!"))
    return
  end
  local CurrentWeapon = PlayerCharacter:GetCurrentWeapon()
  if not slua.isValid(CurrentWeapon) or not slua.isValid(CurrentWeapon.WeaponAvatarComponent) then
    print(bWriteLog and string.format("HighlightMomentSubsystem:CacheVictimInfoOnClient invalid CurrentWeapon!"))
    return
  end
  local GUN_MASTER_SLOT = 7
  local WeaponHandle = CurrentWeapon.WeaponAvatarComponent:GetEquippedHandle(GUN_MASTER_SLOT)
  if not slua.isValid(WeaponHandle) then
    return
  end
  local WeaponSequenceList = WeaponHandle.WeaponSpecialLevelSequenceList
  if not WeaponSequenceList or WeaponSequenceList:Num() <= 0 then
    return
  end
  local SequencePath
  local SequenceType = ECharSpecLvSeq.ECharSpecLvSeq_WeaponHighlightMoment
  for _, SequenceData in pairs(WeaponSequenceList) do
    if SequenceData.LevelSequenceType == SequenceType then
      SequencePath = SequenceData.LevelSequenceConfig and SequenceData.LevelSequenceConfig.LevelSequence:ToSoftObjectPath() or nil
      break
    end
  end
  local WeaponSequenceConfigure = WeaponHandle.WeaponLevelSequenceConfigure and WeaponHandle.WeaponLevelSequenceConfigure:Get(SequenceType) or nil
  local nTargetLen = WeaponSequenceConfigure and WeaponSequenceConfigure.CameraTargetLength or 200
  local uRotationOffset = WeaponSequenceConfigure and WeaponSequenceConfigure.CameraRotationOffset or {}
  local uBoundingBox2D = WeaponSequenceConfigure and WeaponSequenceConfigure.BoundingBox2D or nil
  local nCeilingHeight = WeaponSequenceConfigure and WeaponSequenceConfigure.CeilingHeight or 560
  local nFloorMaxHeight = WeaponSequenceConfigure and WeaponSequenceConfigure.FloorMaxHeight or 0
  local VictimCharacter = GameState:TryGetCharacterByPlayerKey(VictimPlayerKey)
  if VictimCharacter == nil then
    VictimCharacter = GameState:FindCharacterByPlayerKey(VictimPlayerKey)
  end
  local uFreshedLocation
  if slua.isValid(VictimCharacter) then
    uFreshedLocation = VictimCharacter.Mesh and VictimCharacter.Mesh:GetSocketLocation("Root") or VictimCharacter:K2_GetActorLocation()
  end
  self.VictimInfoCache = {
    PlayerKey = VictimPlayerKey,
    SequencePath = SequencePath,
    nTargetLen = nTargetLen,
    tRotationOffset = {
      Yaw = uRotationOffset.Yaw or 0,
      Pitch = uRotationOffset.Pitch or 0,
      Roll = uRotationOffset.Roll or 0
    },
    uBoundingBox2D = uBoundingBox2D,
    FreshedLocation = uFreshedLocation,
    nCeilingHeight = nCeilingHeight,
      }
  return true
end
function HighlightMomentSubsystem:OnSomeonePutDownCarriedBox(_, __, uPlayerCharacter, uOldDeadBox)
  local PlayerKey = self.VictimInfoCache and self.VictimInfoCache.PlayerKey
  if not PlayerKey or PlayerKey <= 0 then
    return
  end
  print(bWriteLog and "HighlightMomentSubsystem:OnSomeonePutDownCarriedBox", uPlayerCharacter, uOldDeadBox)
  if not slua.isValid(uPlayerCharacter) or not slua.isValid(uOldDeadBox) then
    return
  end
  if not PlayerKey == uOldDeadBox.TargetPlayerKey then
    return
  end
  self.VictimInfoCache.FreshedLocation = uOldDeadBox:K2_GetActorLocation()
end
function HighlightMomentSubsystem:ShowLobbyPawn(bShow)
  print(bWriteLog and "HighlightMomentSubsystem:ShowLobbyPawn", bShow)
  if bShow then
    local Pawn = GameplayData.GetPlayerCharacter()
    if not slua.isValid(Pawn) then
      return
    end
    self.ShowPawnList = {}
    local Location = Pawn:K2_GetActorLocation()
    for Index, PlayerKey in ipairs(self.VehicleInfoCache.SeatInfo) do
      if PlayerKey and 0 < PlayerKey then
        local SingleActor = ActorTools.SpawnActor(Pawn, ShowPawnActorPath, FVector(Location.X, Location.Y, Location.Z - 2000), FRotator(0, 0, 0), FVector(1, 1, 1))
        if slua.isValid(SingleActor) then
          SingleActor:K2_SetActorLocation(FVector(Location.X, Location.Y, Location.Z - 1000), false, nil, false)
          Game:SetShowPawnAvatarFromPlayerKey(SingleActor, PlayerKey)
          table.insert(self.ShowPawnList, SingleActor)
          SingleActor.Mesh:SetAnimationMode(2)
          print(bWriteLog and "HighlightMomentSubsystem:ShowLobbyPawn- ", #self.ShowPawnList, PlayerKey, SingleActor.Mesh.AnimationMode)
          SingleActor:SetActorEnableCollision(false)
        end
      end
    end
  else
    for _, ShowPawn in pairs(self.ShowPawnList) do
      if slua.isValid(ShowPawn) then
        ShowPawn:K2_DestroyActor()
      end
    end
    self.ShowPawnList = {}
  end
end
function HighlightMomentSubsystem:ShowVictimHightlightPawn(bShow)
  print(bWriteLog and "HighlightMomentSubsystem:ShowVictimHightlightPawn", bShow)
  if not bShow then
    if slua.isValid(self.ShowVictim) then
      self.ShowVictim:K2_DestroyActor()
    end
    self.ShowVictim = nil
    return
  end
  local VictimObject = self.VictimInfoCache.VictimObject
  if not slua.isValid(VictimObject) then
    return
  end
  local PlayerKey = self.VictimInfoCache.PlayerKey
  local Location = VictimObject:K2_GetActorLocation()
  if not PlayerKey or PlayerKey <= 0 then
    return
  end
  local SingleActor = ActorTools.SpawnActor(VictimObject, ShowPawnActorPath, FVector(Location.X, Location.Y, Location.Z - 2000), FRotator(0, 0, 0), FVector(1, 1, 1))
  if not slua.isValid(SingleActor) then
    return
  end
  SingleActor:K2_SetActorLocation(FVector(Location.X, Location.Y, Location.Z - 1000), false, nil, false)
  Game:SetShowPawnAvatarFromPlayerKey(SingleActor, PlayerKey)
  self.ShowVictim = SingleActor
  print(bWriteLog and "HighlightMomentSubsystem:ShowVictimHightlightPawn", PlayerKey)
  SingleActor:SetActorEnableCollision(false)
end
function HighlightMomentSubsystem:ShowLobbyVehicle(bShow)
  print(bWriteLog and "HighlightMomentSubsystem:ShowLobbyVehicle", bShow)
  if bShow then
    local Pawn = GameplayData.GetPlayerCharacter()
    if not slua.isValid(Pawn) then
      return false
    end
    local VehicleSkinItemID = self.VehicleInfoCache.VehicleSkinItemID
    print(bWriteLog and "HighlightMomentSubsystem:ShowLobbyVehicle VehicleSkinItemID", VehicleSkinItemID)
    local callOb, curDataTable = xpcall(function()
      if Config.VehicleSkinModelActorConfig and Config.VehicleSkinModelActorConfig[VehicleSkinItemID] then
        self.ShowVehicleActor = ActorTools.SpawnActor(Pawn, Config.VehicleSkinModelActorConfig[VehicleSkinItemID], self.VehicleInfoCache.Loc, self.VehicleInfoCache.Rot, FVector(1, 1, 1))
      else
        local uTransform = KismetMathLibrary.MakeTransform(self.VehicleInfoCache.Loc, self.VehicleInfoCache.Rot, FVector(1, 1, 1))
        self.ShowVehicleActor = SocialVehicleSystem.CreateRefitVehicle(VehicleSkinItemID, uTransform, VehicleRefitHandler.GetCarStyleList(VehicleSkinItemID, nil, nil, {}), 1, false, true, true, true, {})
        if slua.isValid(self.ShowVehicleActor) then
          self.ShowVehicleActor:SetActorEnableCollision(false)
        end
      end
    end, CommonUtility.ErrorMessageHandler, self)
  else
    if slua.isValid(self.ShowVehicleActor) then
      self.ShowVehicleActor:K2_DestroyActor()
    end
    self.ShowVehicleActor = nil
  end
  return true
end
function HighlightMomentSubsystem:GetCurrentVehicle()
  local Pawn = GameplayData.GetPlayerCharacter()
  if not slua.isValid(Pawn) and Pawn.GetCurrentVehicle then
    print(bWriteLog and "HighlightMomentSubsystem:GetCurrentVehicle invalid Pawn!", Pawn)
    return
  end
  local uCurrentVehicle = Pawn:GetCurrentVehicle()
  if not slua.isValid(uCurrentVehicle) or not uCurrentVehicle.GetVehicleSkinItemID then
    print(bWriteLog and "HighlightMomentSubsystem:GetCurrentVehicle invalid uCurrentVehicle!", uCurrentVehicle)
    return
  end
  return uCurrentVehicle
end
function HighlightMomentSubsystem:WaterCheck(CheckingActor, bHideTips)
  if not slua.isValid(CheckingActor) then
    return false
  end
  local Location = CheckingActor:K2_GetActorLocation()
  local Rotation = CheckingActor:K2_GetActorRotation()
  local ForwardVector = KismetMathLibrary.GetForwardVector(Rotation)
  local RightVector = KismetMathLibrary.GetRightVector(Rotation)
  local UpVector = KismetMathLibrary.GetUpVector(Rotation)
  local BoxLoc = Location
  local BoxRot = Rotation
  local BoxExtent = FVector(30, 30, 80)
  local ECollisionChannel = import("ECollisionChannel")
  local bSuccess = true
  local bOverlapResult, OverlapActors = USTExtraBlueprintFunctionLibrary.LuaOverlapMultiByObjectType(CheckingActor, BoxLoc, BoxRot, {
    ECollisionChannel.ECC_WorldDynamic
  }, BoxExtent, nil)
  if bOverlapResult and OverlapActors and OverlapActors:Num() > 0 then
    for k, Actor in pairs(OverlapActors) do
      if slua.isValid(Actor) then
        if Actor.bWaterVolume then
          bSuccess = false
          break
        end
        if Actor.ActorHasTag and Actor:ActorHasTag("ocean") then
          bSuccess = false
          break
        end
      end
    end
  end
  local bShowDebug = Client.IsDevelopment() and Config.bShowDebug
  if bShowDebug then
    STExtraGameplayStatics.ClientDrawDebugBox(BoxLoc, BoxExtent, bSuccess and FLinearColor.Green or FLinearColor.Red, BoxRot, 15, 2)
  end
  if not bSuccess and not bHideTips then
    IngameTipsTools.BattleNormalTipsByTextID(78319)
  end
  return bSuccess
end
function HighlightMomentSubsystem:VehiclePlayCheck()
  if Client.IsEditor() then
    _G.package.loaded["GameLua.Mod.BaseMod.GamePlay.Config.HighlightMomentConfig"] = nil
    Config = require("GameLua.Mod.BaseMod.GamePlay.Config.HighlightMomentConfig")
  end
  local uCurrentVehicle = self:GetCurrentVehicle()
  local Pawn = GameplayData.GetPlayerCharacter()
  if not slua.isValid(Pawn) then
    return false
  end
  if not Pawn:AllowState(UEnums.EPawnState.PlayEmote, true) and not Pawn:Hasstate(UEnums.EPawnState.DriveVehicle) and not Pawn:Hasstate(UEnums.EPawnState.InVehicle) then
    ShowNotice(82212)
    return false
  end
  local bShowDebug = Client.IsDevelopment() and Config.bShowDebug
  local VehicleSkinItemID = self.VehicleInfoCache.VehicleSkinItemID
  local CheckConfig = Config.CommonCheckConfig
  if Config.VehicleSpecialSkinConfig[VehicleSkinItemID] then
    CheckConfig = Config.VehicleSpecialSkinConfig[VehicleSkinItemID].CheckConfig
  end
  local Location = slua.isValid(uCurrentVehicle) and (uCurrentVehicle.OffsetForHighlight and uCurrentVehicle:K2_GetActorLocation() + uCurrentVehicle.OffsetForHighlight or uCurrentVehicle:K2_GetActorLocation()) or Pawn:K2_GetActorLocation() - FVector(0, 0, 90)
  local Rotation = slua.isValid(uCurrentVehicle) and uCurrentVehicle:K2_GetActorRotation() or Pawn:K2_GetActorRotation()
  local bSuccess = true
  if slua.isValid(uCurrentVehicle) and (math.abs(Rotation.Pitch) > CheckConfig.HorizontalCheckAngle or math.abs(Rotation.Roll) > CheckConfig.HorizontalCheckAngle) then
    print(bWriteLog and "HighlightMomentSubsystemHighlightMomentSubsystem not horizontal!", Rotation.Pitch, Rotation.Roll)
    if not bShowDebug then
      IngameTipsTools.BattleNormalTipsByTextID(792566)
      return
    end
    bSuccess = false
  end
  self.VehicleInfoCache.Loc = Location
  self.VehicleInfoCache.Rot = Rotation
  local ForwardVector = KismetMathLibrary.GetForwardVector(Rotation)
  local RightVector = KismetMathLibrary.GetRightVector(Rotation)
  local UpVector = KismetMathLibrary.GetUpVector(Rotation)
  for Idx, BoxConfig in ipairs(CheckConfig.BoxConfig) do
    local BoxLoc = Location + ForwardVector * BoxConfig.Offset.X + RightVector * BoxConfig.Offset.Y + UpVector * BoxConfig.Offset.Z
    local BoxRot = Rotation
    if BoxConfig.RotateZ and BoxConfig.RotateZ ~= 0 then
      local additionalRotator = KismetMathLibrary.RotatorFromAxisAndAngle(UpVector, BoxConfig.RotateZ)
      BoxRot = KismetMathLibrary.ComposeRotators(Rotation, additionalRotator)
    end
    local BoxExtent = BoxConfig.Extent
    local ECollisionChannel = import("ECollisionChannel")
    local bOverlapResult, OverlapActors = USTExtraBlueprintFunctionLibrary.LuaOverlapMultiByObjectType(Pawn, BoxLoc, BoxRot, {
      ECollisionChannel.ECC_WorldStatic,
      ECollisionChannel.ECC_WorldDynamic,
      ECollisionChannel.ECC_Destructible
    }, BoxExtent, nil)
    if bShowDebug then
      STExtraGameplayStatics.ClientDrawDebugBox(BoxLoc, BoxExtent, bOverlapResult and FLinearColor.Red or FLinearColor.Green, BoxRot, 15, 2)
    end
    if bOverlapResult then
      if not bShowDebug then
        IngameTipsTools.BattleNormalTipsByTextID(792566)
        return
      end
      bSuccess = false
    end
  end
  for idx, PointConfig in ipairs(CheckConfig.FloorCheckPoint) do
    local CheckStartPoint = self.VehicleInfoCache.Loc + ForwardVector * PointConfig.StartPoint.X + RightVector * PointConfig.StartPoint.Y + UpVector * PointConfig.StartPoint.Z
    local CheckEndPoint = self.VehicleInfoCache.Loc + ForwardVector * PointConfig.EndPoint.X + RightVector * PointConfig.EndPoint.Y + UpVector * PointConfig.EndPoint.Z
    local HitResult = FHitResult()
    local Success, HitResult = USTExtraBlueprintFunctionLibrary.TraceBlock(Pawn, CheckStartPoint, CheckEndPoint, HitResult, {}, true)
    if bShowDebug then
      STExtraGameplayStatics.ClientDrawDebugArrow(CheckStartPoint, CheckEndPoint, 10, Success and FLinearColor.Green or FLinearColor.Red, 15, 10)
    end
    if not Success then
      if not bShowDebug then
        IngameTipsTools.BattleNormalTipsByTextID(792566)
        return
      end
      bSuccess = false
    end
  end
  if not bSuccess then
    IngameTipsTools.BattleNormalTipsByTextID(792566)
  end
  return bSuccess
end
function HighlightMomentSubsystem:OnAchievementTrigger(nUID, nAchievementType)
  print(bWriteLog and "HighlightMomentSubsystem:OnAchievementTrigger nUID: " .. tostring(nUID) .. " nAchievementType: " .. tostring(nAchievementType))
end
function HighlightMomentSubsystem:ClientTriggeredByBattleResult(HighlightID)
  print(bWriteLog and "HighlightMomentSubsystem:TriggeredByBattleResult nUID: " .. tostring(nUID) .. " HighlightID: " .. tostring(HighlightID))
  self:ClientOnTriggerHighlightMoment(nil, nil, HighlightID)
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, HighlightMomentSubsystem)