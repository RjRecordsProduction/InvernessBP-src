local XSuitPlatform = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local Time1 = 180.0
local Time2 = 150.0
local Time3 = 300.0
local CallIndex = 1
local GetCallIndex = function()
  if CallIndex == 1 then
    CallIndex = 2
  else
    CallIndex = 1
  end
  return CallIndex
end
local InCDCharacterMap = {}
function XSuitPlatform:ctor(selfType)
  self.CanChange = true
  self.ChangeCallerTimer = nil
  self.DestroyStatueTimer = nil
  self.CallerStartTime = 0.0
  self.NeedShowStatue = false
  self.CallerInfo = ""
  self.CurItemID = 0
  self.DeActiveAll = false
  self.LoopRotateTimer = nil
  self.SequenceCamera = nil
  self.LastViewTarget = nil
  self.CameraTag = "XSuitPlatformCamera"
  self.CameraRetryCount = 0
  self.bApplySeqCamera = false
  self.SkyMaterialPath = nil
  self.SkyChangeInterpTimer = nil
  self.SkyChangeInterpStartTime = 0.0
  self.SkyChangeInterpMaterial = nil
end
XSuitPlatform.MulticastRPC.MulticastRPC_ShowCallTips = {
  Reliable = false,
  Params = {
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Str
  }
}
function XSuitPlatform:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "CallerInfo",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Str
    },
    {
      "DeActiveAll",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    }
  }
end
function XSuitPlatform:ReceiveBeginPlay()
  XSuitPlatform.__super.ReceiveBeginPlay(self)
  if not self:HasAuthority() then
    self:InitNamePlate()
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_XSUITPLATFORM_SWITCH_CAMERA, self.OnSwitchCamera, self)
  else
    self:AddGameTimer(1, false, function()
      local IsOpen = self:IsDsOpen()
      if not IsOpen then
        self:DeactiveXSuitPlatform()
      end
    end)
    print(bWriteLog and "XSuitPlatform:AddCommonEventWithConditions")
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "FightingState"
    }, self.HandleEnterGame, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_PRE_TEAM_SHOW_READY, self.OnPreTeamShow, self)
  end
end
function XSuitPlatform:ReceiveEndPlay(EndPlayReason)
  if not self:HasAuthority() then
    self:UncallStatue()
    if self.NamePlate then
      self.NamePlate:Close()
      self.NamePlate = nil
    end
  end
  if self.SkyChangeInterpTimer then
    self:RemoveGameTimer(self.SkyChangeInterpTimer)
    self.SkyChangeInterpTimer = nil
  end
  self.SkyChangeInterpMaterial = nil
  XSuitPlatform.__super.ReceiveEndPlay(self, EndPlayReason)
end
function XSuitPlatform:HandleEnterGame(...)
  print(bWriteLog and "XSuitPlatform:HandleEnterGame")
  local GameplayStatics = import("GameplayStatics")
  local GameState = GameplayStatics.GetGameState(self.Object)
  local EGameModeType = import("EGameModeType")
  if not slua.isValid(GameState) then
    print(bWriteLog and "XSuitPlatform:HandleEnterGame GameState Not Valid")
    return
  end
  if GameState.GameModeType == EGameModeType.ESocialIsland then
    return
  end
  self:DeactiveXSuitPlatform()
end
function XSuitPlatform:OnPreTeamShow()
  print(bWriteLog and "XSuitPlatform:OnPreTeamShow")
  self:DeactiveXSuitPlatform()
end
function XSuitPlatform:IsCharacterInCD(Character)
  if not slua.isValid(Character) then
    return false
  end
  local PlayerName = Character:GetPlayerNameSafety()
  if InCDCharacterMap[PlayerName] then
    return true
  else
    return false
  end
end
function XSuitPlatform:AddCharacterInCD(Character, StartTime)
  if not slua.isValid(Character) then
    return
  end
  local PlayerName = Character:GetPlayerNameSafety()
  if InCDCharacterMap[PlayerName] ~= nil then
    return
  end
  InCDCharacterMap[PlayerName] = StartTime
  self:AddGameTimer(Time1, false, function()
    InCDCharacterMap[PlayerName] = nil
  end)
end
function XSuitPlatform:MulticastRPC_ShowCallTips(ItemID, CallerName)
  if not Client then
    return
  end
  print(bWriteLog and "XSuitPlatform:MulticastRPC_ShowCallTips" .. tostring(ItemID) .. CallerName)
  local StatueName = ""
  local ItemCfg = CDataTable.GetTableData("Item", ItemID)
  if ItemCfg then
    StatueName = ItemCfg.ItemName
  end
  local TipID = 0
  local XSuitCfg = CDataTable.GetTableData("GoldClothBattleEffect", ItemID)
  if not XSuitCfg then
    return
  end
  if self:IsInSocialIsland() then
    TipID = XSuitCfg.CallTipSocial
  else
    TipID = XSuitCfg.CallTip
  end
  IngameTipsTools.BattleGeneralTip(TipID, CallerName, StatueName)
end
function XSuitPlatform:OnRep_CallerInfo(oldValue)
  if self.CallerInfo == "" then
    self.NeedShowStatue = false
    self.CallerInfoTable = nil
    self:UncallStatue()
    self.CurItemID = 0
  else
    self.NeedShowStatue = true
    local StringUtil = require("common.string_util")
    local SplitInfo = StringUtil.Split(self.CallerInfo, "|")
    if SplitInfo and #SplitInfo == 4 then
      self.CallerInfoTable = {
        PlayerName = SplitInfo[1],
        ItemID = tonumber(SplitInfo[2]),
        Nation = SplitInfo[3]
      }
      self:CallStatue()
      self.CurItemID = self.CallerInfoTable.ItemID
    end
  end
end
function XSuitPlatform:OnRep_DeActiveAll(oldValue)
  print(bWriteLog and "XSuitPlatform:OnRep_DeActiveAll")
  self:OnDeActiveAll()
end
function XSuitPlatform:CallStatue()
  self:UncallStatue()
  if Client then
    local GameState = slua_GameFrontendHUD:GetGameState()
    local EGameModeType = import("EGameModeType")
    if slua.isValid(GameState) and GameState.GetGameModeState then
      local GameModeState = GameState:GetGameModeState() or ""
      if GameModeState ~= "ReadyState" and GameState.GameModeType ~= EGameModeType.ESocialIsland then
        return
      end
    end
  end
  if self.DeActiveAll then
    return
  end
  local CallShowSequence = self:GetStatue(self.CallerInfoTable.ItemID)
  local UEPathUtilityMethods = import("UEPathUtilityMethods")
  local IsFileExist = UEPathUtilityMethods.IsAvatarResPathExist(CallShowSequence)
  if not IsFileExist then
    print(bWriteLog and "XSuitPlatform:CallStatue Sequence File Not Exist")
    return
  end
  self:TriggerCallShowSequence(CallShowSequence)
  if not self.CallerInfoTable then
    return
  end
  if self.NamePlate then
    self.NamePlate:Show()
    self.NamePlate:UpdatedaPlayerInfo(self.CallerInfoTable)
  end
end
function XSuitPlatform:UncallStatue()
  if self.LoopRotateTimer then
    self:RemoveGameTimer(self.LoopRotateTimer)
    self.LoopRotateTimer = nil
  end
  if self.NamePlate then
    self.NamePlate:Hide()
  end
  if Client then
    self:RestorePlayerCamera()
    self:RestoreSkyMaterialForCall()
    if UIManager.UI_Config_InGame.XSuitPlatform_SwitchCamera_UIBP then
      UIManager.CloseUI(UIManager.UI_Config_InGame.XSuitPlatform_SwitchCamera_UIBP)
    end
  end
  if slua.isValid(self.SequenceActor) then
    if self.SequenceActor.SequencePlayer and slua.isValid(self.SequenceActor.SequencePlayer) and self.SequenceActor.SequencePlayer:IsPlaying() then
      self.SequenceActor.SequencePlayer:Stop()
    end
    self.SequenceActor:K2_DestroyActor()
    self.SequenceActor = nil
  end
  self.CameraRetryCount = 0
  self.SequenceCamera = nil
  self.LastViewTarget = nil
  self:SetLoopRotate(false)
end
function XSuitPlatform:MustCheckResultAfterServerClick(Character, Ret, Component)
  print(bWriteLog and "XSuitPlatform:MustCheckResultAfterServerClick, result = " .. tostring(Ret))
  if self.DeActiveAll then
    print(bWriteLog and "XSuitPlatform:MustCheckResultAfterServerClick, Deactive already ")
    return
  end
  Component = Component or self:GetInteractiveComponent()
  if Ret and slua.isValid(Component) and slua.isValid(Character) then
    if self:IsGameStateBan() then
      print(bWriteLog and "XSuitPlatform:MustCheckResultAfterServerClick, GameState in fight")
      return
    end
    if not self:Wearing7StarXSuit(Character) then
      Game:UIShowTips(Character.PlayerKey, 49553)
      return
    end
    self:TrySetCurrentCaller(Character)
  else
  end
end
function XSuitPlatform:OnClientClickInteractiveButton(Character)
  if not self:Wearing7StarXSuit(Character) then
    print(bWriteLog and "XSuitPlatform:OnClientClickInteractiveButton Tips")
    IngameTipsTools.BattleNormalTipsByTextID(49553)
    return false
  end
  return true
end
function XSuitPlatform:TrySetCurrentCaller(Character)
  if not slua.isValid(Character) then
    print(bWriteLog and "XSuitPlatform:TrySetCurrentCaller error Char not valid")
    return
  end
  if not self.hasAuthority then
    print(bWriteLog and "XSuitPlatform:TrySetCurrentCaller error not in server")
    return
  end
  local GetLeftTime = function(cd, startTime)
    if startTime == nil then
      return "0"
    end
    local UGameplayStatics = import("GameplayStatics")
    local LeftTime = cd - (UGameplayStatics.GetTimeSeconds(CGameWorld) - startTime)
    if LeftTime < 0 then
      LeftTime = 0
    end
    LeftTime = math.ceil(LeftTime)
    return tostring(LeftTime)
  end
  if self:IsCharacterInCD(Character) then
    print(bWriteLog and "XSuitPlatform:TrySetCurrentCaller character in cd")
    local PlayerName = Character:GetPlayerNameSafety()
    IngameTipsTools.BattleNormalSAPTipsByTextID(49555, GetLeftTime(Time1, InCDCharacterMap[PlayerName]), "", "", Character.PlayerKey, false)
    return
  end
  if self.CanChange then
    print(bWriteLog and "XSuitPlatform:TrySetCurrentCaller change caller")
    self:DoChangeCaller(Character)
  else
    print(bWriteLog and "XSuitPlatform:TrySetCurrentCaller someone occupy")
    Game:UIShowTips(Character.PlayerKey, 49554)
  end
end
function XSuitPlatform:DoChangeCaller(Character)
  print(bWriteLog and "XSuitPlatform:DoChangeCaller")
  self.CanChange = false
  self:ModifyCallerInfo(Character)
  self:MulticastRPC_ShowCallTips(self.CurItemID, Character:GetPlayerNameSafety())
  local UGameplayStatics = import("GameplayStatics")
  self.CallerStartTime = UGameplayStatics.GetTimeSeconds(CGameWorld)
  self:AddCharacterInCD(Character, self.CallerStartTime)
  if self.ChangeCallerTimer then
    self:RemoveGameTimer(self.ChangeCallerTimer)
  end
  if self.DestroyStatueTimer then
    self:RemoveGameTimer(self.DestroyStatueTimer)
  end
  self.ChangeCallerTimer = self:AddGameTimer(Time2, false, function()
    self.CanChange = true
    self.ChangeCallerTimer = nil
  end)
  self.DestroyStatueTimer = self:AddGameTimer(Time3, false, function()
    self.CallerInfo = ""
    self.DestroyStatueTimer = nil
  end)
end
function XSuitPlatform:ModifyCallerInfo(Character)
  print(bWriteLog and "XSuitPlatform:ModifyCallerInfo")
  if not slua.isValid(Character) then
    return
  end
  local Name = Character:GetPlayerNameSafety()
  local XSuitID = self:GetWearingXSuitID(Character)
  self.CurItemID = XSuitID
  local PC = Character:GetPlayerControllerSafety()
  local Nation = "None"
  if slua.isValid(PC) and PC.Nation and PC.Nation ~= "" then
    Nation = PC.Nation
  end
  local CurCallIndex = GetCallIndex()
  if Name ~= "" and XSuitID ~= 0 then
    local CallerInfo = Name .. "|" .. tostring(XSuitID) .. "|" .. tostring(Nation) .. "|" .. tostring(CurCallIndex)
    self.  else
    self.CallerInfo = ""
  end
  local SceneID = 1
  if self:IsInSocialIsland() then
    SceneID = 2
  end
  local Param = string.format("%s|%s", Character.PlayerUID, tostring(SceneID))
  print(bWriteLog and "XSuitPlatform:DoChangeCaller, tlog param = " .. tostring(Param))
  if NetUtil then
    NetUtil.SendPacket("report_common_battle_info", "GoldDressGamesvrInteractiveFlow", Param)
  end
end
function XSuitPlatform:InitNamePlate()
  print(bWriteLog and "XSuitPlatform:InitNamePlate")
  if not slua.isValid(self.Widget) then
    print(bWriteLog and "XSuitPlatform:InitNamePlate Widget not valid")
    return
  end
  local UserWidget = self.Widget:GetUserWidgetObject()
  if not slua.isValid(UserWidget) then
    print(bWriteLog and "XSuitPlatform:InitNamePlate UserWidget not valid")
    return
  end
  local UIClass = require("GameLua.Activity.Commercialize.Client.XSuit.XSuitPlatform_Nameplate")
  self.NamePlate = UIClass(self.Object)
  self.NamePlate:InitWithWidget(UserWidget)
  if self.NeedShowStatue then
    self:CallStatue()
  else
    self:UncallStatue()
  end
end
function XSuitPlatform:GetWearingXSuitID(Character)
  if not slua.isValid(Character) then
    return 0
  end
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local EAvatarSlotType = import("EAvatarSlotType")
  return STExtraBlueprintFunctionLibrary.GetPlayerWearingGoldenSuitID(Character, Character, EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
end
function XSuitPlatform:Wearing7StarXSuit(Character)
  print(bWriteLog and "XSuitPlatform:Wearing7StarXSuit")
  local SuitID = self:GetWearingXSuitID(Character)
  if SuitID == 0 then
    print(bWriteLog and "XSuitPlatform:Wearing7StarXSuit false suit id = 0")
    return false
  end
  local Statue = self:GetStatue(SuitID)
  if Statue ~= "" then
    print(bWriteLog and "XSuitPlatform:Wearing7StarXSuit true")
    return true
  end
  print(bWriteLog and "XSuitPlatform:Wearing7StarXSuit false suit does not have statue" .. tostring(SuitID))
  return false
end
function XSuitPlatform:GetStatue(SuitID)
  local XSuitCfg = CDataTable.GetTableData("GoldClothBattleEffect", SuitID)
  if not XSuitCfg then
    print(bWriteLog and "XSuitPlatform:GetStatue no cfg")
    return ""
  end
  if not XSuitCfg.CallStatue then
    print(bWriteLog and "XSuitPlatform:GetStatue no statue")
    return ""
  end
  if Client and Client.GetExactDeviceLevel() <= 1 and XSuitCfg.CallStatueLOD and XSuitCfg.CallStatueLOD ~= "" then
    print(bWriteLog and "XSuitPlatform:GetStatue use CallStatueLOD")
    return XSuitCfg.CallStatueLOD
  end
  return XSuitCfg.CallStatue
end
function XSuitPlatform:IsGameStateBan()
  local UGameplayStatics = import("GameplayStatics")
  local GameState = UGameplayStatics.GetGameState(self.Object)
  local EGameModeType = import("EGameModeType")
  if slua.isValid(GameState) and GameState.GetGameModeState then
    local GameModeState = GameState:GetGameModeState() or ""
    if GameModeState ~= "ReadyState" and GameState.GameModeType ~= EGameModeType.ESocialIsland then
      return true
    end
  end
  return false
end
function XSuitPlatform:IsInSocialIsland()
  local UGameplayStatics = import("GameplayStatics")
  local GameState = UGameplayStatics.GetGameState(self.Object)
  local EGameModeType = import("EGameModeType")
  if slua.isValid(GameState) and GameState.GetGameModeState and GameState.GameModeType == EGameModeType.ESocialIsland then
    return true
  end
  return false
end
function XSuitPlatform:OnAllowToInteract(Character)
  local Allow = not self:IsGameStateBan()
  if not Allow then
    return false
  end
  if not self.CanChange then
    return false
  end
  return true
end
function XSuitPlatform:TriggerCallShowSequence(SeqPath)
  if not slua.isValid(self.SequenceActorCls) then
    print(bWriteLog and "XSuitPlatform:TriggerCallShowSequence - Seq Class Not Valid")
    return
  end
  if slua.isValid(self.SequenceActor) then
    if self.SequenceActor.SequencePlayer and slua.isValid(self.SequenceActor.SequencePlayer) and self.SequenceActor.SequencePlayer:IsPlaying() then
      self.SequenceActor.SequencePlayer:Stop()
    end
    self.SequenceActor:K2_DestroyActor()
  end
  local uTransform = self:GetTransform()
  local UGameplayStatics = import("GameplayStatics")
  local ESpawnActorCollisionHandlingMethod = import("ESpawnActorCollisionHandlingMethod")
  local SequenceActor = UGameplayStatics.BeginDeferredActorSpawnFromClass(self.Object, self.SequenceActorCls, uTransform, ESpawnActorCollisionHandlingMethod.AlwaysSpawn, self.Object)
  if slua.isValid(SequenceActor) then
    self:SetLoopRotate(false)
    self.    SequenceActor:SetReplicates(false)
    SequenceActor:SetUseSelfTransformOrigin(true)
    SequenceActor:SetLevelSequenceAssetPath(SeqPath)
    UGameplayStatics.FinishSpawningActor(SequenceActor, uTransform)
  else
    print(bWriteLog and "XSuitPlatform:TriggerCallShowSequence - Failed to spawn SequenceActor")
  end
end
function XSuitPlatform:BeginRotate()
  print(bWriteLog and "XSuitPlatform:BeginRotate")
  self:SetLoopRotate(true)
  if Client and self.SequenceCamera and slua.isValid(self.SequenceCamera) then
    self:RestorePlayerCamera()
  end
  self.LoopRotateTimer = nil
  if UIManager.UI_Config_InGame.XSuitPlatform_SwitchCamera_UIBP then
    UIManager.CloseUI(UIManager.UI_Config_InGame.XSuitPlatform_SwitchCamera_UIBP)
  end
end
function XSuitPlatform:OnSeqActorPlay()
  if not slua.isValid(self.SequenceActor) then
    return
  end
  local SequencePlayer = self.SequenceActor.SequencePlayer
  if slua.isValid(SequencePlayer) then
    print(bWriteLog and "XSuitPlatform:OnSeqActorPlay - SequencePlayer ready, start playing")
    if Client then
      self:FindAndApplySequenceCamera()
    end
    SequencePlayer:Play()
    local CallTime = 7
    if self.CallerInfoTable and self.CallerInfoTable.ItemID then
      local XSuitCfg = CDataTable.GetTableData("GoldClothBattleEffect", self.CallerInfoTable.ItemID)
      if XSuitCfg and XSuitCfg.CallTime and XSuitCfg.CallTime > 0 then
        CallTime = XSuitCfg.CallTime
      end
    end
    self.LoopRotateTimer = self:AddGameTimer(CallTime, false, function()
      self:BeginRotate()
    end)
  else
    print(bWriteLog and "XSuitPlatform:WaitForSequencePlayerAndPlay - SequencePlayer not found")
  end
end
function XSuitPlatform:FindAndApplySequenceCamera()
  if not Client then
    return
  end
  if self.SequenceCamera and slua.isValid(self.SequenceCamera) then
    return
  end
  if not self.CameraTag or self.CameraTag == "" then
    print(bWriteLog and "XSuitPlatform:FindAndApplySequenceCamera - CameraTag is empty")
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local CurrentCharacter = GameplayData.GetPlayerCharacter()
  local IsCaller = false
  if slua.isValid(CurrentCharacter) and self.CallerInfoTable and self.CallerInfoTable.PlayerName then
    local CurrentPlayerName = CurrentCharacter:GetPlayerNameSafety()
    if CurrentPlayerName == self.CallerInfoTable.PlayerName then
      IsCaller = true
    end
  end
  print(bWriteLog and "XSuitPlatform:FindAndApplySequenceCamera IsCaller" .. tostring(IsCaller))
  if not IsCaller and self:IsInSocialIsland() then
    print(bWriteLog and "XSuitPlatform:ApplySequenceCamera IsInSocialIsland")
    return
  end
  local GameplayStatics = import("GameplayStatics")
  local ActorClass = import("/Script/Engine.Actor")
  local ActorArray = slua.Array(UEnums.EPropertyClass.Object, ActorClass)
  local GameInstance
  if UIUtil and UIUtil.GetGameInstance then
    GameInstance = UIUtil.GetGameInstance()
  else
    GameInstance = GameplayStatics.GetGameInstance(self.Object)
  end
  if not GameInstance then
    print(bWriteLog and "XSuitPlatform:FindAndApplySequenceCamera - GameInstance is nil")
    return
  end
  local CameraActor
  local CameraActorClass = import("/Script/Engine.CameraActor")
  ActorArray = GameplayStatics.GetAllActorsWithTag(GameInstance, self.CameraTag, ActorArray)
  if ActorArray and ActorArray:Num() > 0 then
    for i = 0, ActorArray:Num() - 1 do
      local actor = ActorArray:Get(i)
      if slua.isValid(actor) and Game:IsClassOf(actor, CameraActorClass) then
        local AttachParent = actor:GetAttachParentActor()
        if slua.isValid(AttachParent) and (AttachParent == self.Object or AttachParent == self.SequenceActor) then
          CameraActor = actor
          print(bWriteLog and "XSuitPlatform:FindAndApplySequenceCamera - Found CameraActor by attach relationship")
          break
        end
      end
    end
  end
  if slua.isValid(CameraActor) then
    print(bWriteLog and "XSuitPlatform:FindAndApplySequenceCamera - Found CameraActor by tag: " .. self.CameraTag)
    self:ApplySequenceCamera(CameraActor)
    self.CameraRetryCount = 0
    self:ShowSwitchCameraUIBP(IsCaller)
  elseif self.CameraRetryCount < 3 then
    self.CameraRetryCount = self.CameraRetryCount + 1
    self:AddGameTimer(0.2, false, function()
      if not self.SequenceCamera or not slua.isValid(self.SequenceCamera) then
        self:FindAndApplySequenceCamera()
      end
    end)
  else
    print(bWriteLog and "XSuitPlatform:FindAndApplySequenceCamera - CameraActor not found after retries, sequence has no camera")
    self.CameraRetryCount = 0
  end
end
function XSuitPlatform:ShowSwitchCameraUIBP(IsCaller)
  if not IsCaller then
    UIManager.ShowUI(UIManager.UI_Config_InGame.XSuitPlatform_SwitchCamera_UIBP)
  end
end
function XSuitPlatform:HideCaller(character)
  if character and character.SetActorHiddenInGameMask then
    print(bWriteLog and "XSuitPlatform:HideCaller - Hide caller")
    local EActorHiddenMask = import("EActorHiddenMask")
    character:SetActorHiddenInGameMask(true, EActorHiddenMask.ActorHiddenMask5)
  end
end
function XSuitPlatform:ShowCaller(character)
  if character and character.SetActorHiddenInGameMask then
    print(bWriteLog and "XSuitPlatform:ShowCaller - Show caller")
    local EActorHiddenMask = import("EActorHiddenMask")
    character:SetActorHiddenInGameMask(false, EActorHiddenMask.ActorHiddenMask5)
  end
end
function XSuitPlatform:ApplySequenceCamera(CameraActor)
  if not Client then
    return
  end
  if not slua.isValid(CameraActor) then
    return
  end
  self.SequenceCamera = CameraActor
  local PlayController
  if slua_GameFrontendHUD and slua_GameFrontendHUD.GetPlayerController then
    PlayController = slua_GameFrontendHUD:GetPlayerController()
  else
    local GameplayStatics = import("GameplayStatics")
    PlayController = GameplayStatics.GetPlayerController(self.Object, 0)
  end
  if not slua.isValid(PlayController) then
    print(bWriteLog and "XSuitPlatform:ApplySequenceCamera - PlayController is nil")
    return
  end
  self.LastViewTarget = PlayController:GetViewTarget()
  local EViewTargetBlendFunction = import("EViewTargetBlendFunction")
  PlayController:SetViewTargetWithBlend(CameraActor, 0, EViewTargetBlendFunction.VTBlend_Linear, 0, false)
  print(bWriteLog and "XSuitPlatform:ApplySequenceCamera - Camera switched to Sequence")
  self.bApplySeqCamera = true
  self:HideIngameMainUI()
end
function XSuitPlatform:RestorePlayerCamera()
  if not Client then
    return
  end
  if not self.SequenceCamera or not self.bApplySeqCamera then
    return
  end
  local PlayController
  if slua_GameFrontendHUD and slua_GameFrontendHUD.GetPlayerController then
    PlayController = slua_GameFrontendHUD:GetPlayerController()
  else
    local GameplayStatics = import("GameplayStatics")
    PlayController = GameplayStatics.GetPlayerController(self.Object, 0)
  end
  if not slua.isValid(PlayController) then
    return
  end
  local TargetView = self.LastViewTarget
  if not slua.isValid(TargetView) then
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local uCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(uCharacter) then
      TargetView = uCharacter
    else
      return
    end
  end
  local EViewTargetBlendFunction = import("EViewTargetBlendFunction")
  PlayController:SetViewTargetWithBlend(TargetView, 0, EViewTargetBlendFunction.VTBlend_Linear, 0, false)
  print(bWriteLog and "XSuitPlatform:RestorePlayerCamera - Camera restored to player")
  self.bApplySeqCamera = false
  self:ShowIngameMainUI()
end
function XSuitPlatform:GetSkyMaterialPath(ItemID)
  if not ItemID or ItemID == 0 then
    return nil
  end
  local XSuitCfg = CDataTable.GetTableData("GoldClothBattleEffect", ItemID)
  if not XSuitCfg then
    return nil
  end
  if XSuitCfg.CallSkyMaterial and XSuitCfg.CallSkyMaterial ~= "" then
    return XSuitCfg.CallSkyMaterial
  end
  return nil
end
function XSuitPlatform:ChangeSkyMaterialForCall()
  if not Client then
    return
  end
  if self:IsInSocialIsland() then
    print(bWriteLog and "XSuitPlatform:ChangeSkyMaterialForCall IsInSocialIsland")
    return
  end
  if not self.CallerInfoTable or not self.CallerInfoTable.ItemID then
    return
  end
  local SkyMaterialPath = self:GetSkyMaterialPath(self.CallerInfoTable.ItemID)
  if not SkyMaterialPath or SkyMaterialPath == "" then
    print(bWriteLog and "XSuitPlatform:ChangeSkyMaterialForCall - No sky material configured for ItemID: " .. tostring(self.CallerInfoTable.ItemID))
    return
  end
  local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
  local WeatherSubsystem = SubsystemMgr:Get("WeatherSubsystem")
  if not WeatherSubsystem then
    print(bWriteLog and "XSuitPlatform:ChangeSkyMaterialForCall - WeatherSubsystem not found")
    return
  end
  self.  print(bWriteLog and "XSuitPlatform:ChangeSkyMaterialForCall - Changing sky material to: " .. SkyMaterialPath)
  WeatherSubsystem:ChangeSkyMaterial(self.Object, SkyMaterialPath, function(Mat)
    self:SkyChangeMaterialTick(Mat)
  end)
end
function XSuitPlatform:SkyChangeMaterialTick(Mat)
  if not slua.isValid(Mat) then
    print(bWriteLog and "XSuitPlatform:SkyChangeMaterialTick - Material is invalid")
    return
  end
  if not Mat:K2_GetScalarParameterValue("SkyChange") then
    print(bWriteLog and "XSuitPlatform:SkyChangeMaterialTick - Material has no SkyChange parameter")
    return
  end
  if self.SkyChangeInterpTimer then
    self:RemoveGameTimer(self.SkyChangeInterpTimer)
    self.SkyChangeInterpTimer = nil
  end
  self.SkyChangeInterpMaterial = Mat
  local UGameplayStatics = import("GameplayStatics")
  self.SkyChangeInterpStartTime = UGameplayStatics.GetTimeSeconds(CGameWorld)
  Mat:SetScalarParameterValue("SkyChange", 1.0)
  local InterpDuration = 1.0
  local UpdateInterval = 0.033
  self.SkyChangeInterpTimer = self:AddGameTimer(UpdateInterval, true, function()
    if not slua.isValid(self.SkyChangeInterpMaterial) then
      if self.SkyChangeInterpTimer then
        self:RemoveGameTimer(self.SkyChangeInterpTimer)
        self.SkyChangeInterpTimer = nil
      end
      self.SkyChangeInterpMaterial = nil
      return
    end
    local CurrentTime = UGameplayStatics.GetTimeSeconds(CGameWorld)
    local ElapsedTime = CurrentTime - self.SkyChangeInterpStartTime
    if ElapsedTime >= InterpDuration then
      self.SkyChangeInterpMaterial:SetScalarParameterValue("SkyChange", 0.0)
      if self.SkyChangeInterpTimer then
        self:RemoveGameTimer(self.SkyChangeInterpTimer)
        self.SkyChangeInterpTimer = nil
      end
      self.SkyChangeInterpMaterial = nil
    else
      local LerpValue = 1.0 - ElapsedTime / InterpDuration
      self.SkyChangeInterpMaterial:SetScalarParameterValue("SkyChange", LerpValue)
    end
  end)
end
function XSuitPlatform:RestoreSkyMaterialForCall()
  if not Client then
    return
  end
  if not self.SkyMaterialPath then
    return
  end
  local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
  local WeatherSubsystem = SubsystemMgr:Get("WeatherSubsystem")
  if not WeatherSubsystem then
    print(bWriteLog and "XSuitPlatform:RestoreSkyMaterialForCall - WeatherSubsystem not found")
    return
  end
  if self.SkyChangeInterpTimer then
    self:RemoveGameTimer(self.SkyChangeInterpTimer)
    self.SkyChangeInterpTimer = nil
  end
  self.SkyChangeInterpMaterial = nil
  print(bWriteLog and "XSuitPlatform:RestoreSkyMaterialForCall - Restoring sky material")
  WeatherSubsystem:RestoreSkyMaterial(self.Object)
  self.SkyMaterialPath = nil
end
function XSuitPlatform:OnSwitchCamera(_, _, useCamera)
  print(bWriteLog and "XSuitPlatform:OnSwitchCamera " .. tostring(useCamera))
  if useCamera then
    self:ApplySequenceCamera(self.SequenceCamera)
  else
    self:RestorePlayerCamera()
  end
end
function XSuitPlatform:HideIngameMainUI()
  if not Client then
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.BroadcastUIMessage then
    PlayerController:BroadcastUIMessage("UIMsg_HideIngameMainUI", 0, "", "")
    print(bWriteLog and "XSuitPlatform:HideIngameMainUI - UI hidden")
    local character = PlayerController:GetPlayerCharacterSafety()
    if slua.isValid(character) then
      self:HideCaller(character)
      local JumpToMapModDetailUI = UIManager.GetUI(UIManager.UI_Config_InGame.JumpToMapModDetailUI)
      if JumpToMapModDetailUI then
        JumpToMapModDetailUI:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
      end
    end
  end
end
function XSuitPlatform:ShowIngameMainUI()
  if not Client then
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.BroadcastUIMessage then
    PlayerController:BroadcastUIMessage("UIMsg_ShowIngameMainUI", 0, "", "")
    print(bWriteLog and "XSuitPlatform:ShowIngameMainUI - UI shown")
    local character = PlayerController:GetPlayerCharacterSafety()
    if slua.isValid(character) then
      self:ShowCaller(character)
      local JumpToMapModDetailUI = UIManager.GetUI(UIManager.UI_Config_InGame.JumpToMapModDetailUI)
      if JumpToMapModDetailUI then
        JumpToMapModDetailUI:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
      end
    end
  end
end
function XSuitPlatform:IsDsOpen()
  if IsEditor then
    return true
  end
  if slua.isValid(CGameState) and CGameState.IsCreativeMode and CGameState:IsCreativeMode() then
    return false
  end
  if Game:CheckDSSwitchOpen(66) then
    print(bWriteLog and "XSuitPlatform open")
    return true
  else
    print(bWriteLog and "XSuitPlatform not open")
    return false
  end
end
function XSuitPlatform:DeactiveXSuitPlatform()
  if not self:HasAuthority() then
    return
  end
  self.DeActiveAll = true
  self:OnDeActiveAll()
end
function XSuitPlatform:OnDeActiveAll()
  print(bWriteLog and "XSuitPlatform:OnDeActiveAll")
  if self:HasAuthority() then
    print(bWriteLog and "XSuitPlatform:OnDeActiveAll Auth")
  end
  if Client then
    self:UncallStatue()
  end
  self:HideAll()
  self:DisableAllCollion()
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.GamePlay.Actor.AInteractiveActorBase")
local CXSuitPlatform = class(CActorBase, nil, XSuitPlatform)
return CXSuitPlatform