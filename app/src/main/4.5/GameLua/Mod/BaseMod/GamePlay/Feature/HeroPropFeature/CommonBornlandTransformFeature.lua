local CommonTransformConfig = require("GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.Config.CommonBornLandTransformConfig")
local ECameraDataType = import("ECameraDataType")
local EPawnState = import("EPawnState")
local ESTEPoseState = import("ESTEPoseState")
local CommonBornlandTransformFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
CommonBornlandTransformFeature.ServerRPC.RPC_Server_DoTransfrom = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool
  }
}
function CommonBornlandTransformFeature:RPC_Server_DoTransfrom(bToSnowMan)
  if Game:IsValid(self.Owner) and self.Owner:IsAuthority() then
    local PlayerController = self.Owner:GetPlayerControllerSafety()
    if not slua.isValid(PlayerController) then
      return
    end
    if PlayerController.HeroPropFeature and PlayerController.HeroPropFeature.ServerChooseHeroData then
      PlayerController.HeroPropFeature:ServerChooseHeroData(0)
    end
  end
end
function CommonBornlandTransformFeature:EnterHero(InHeroID)
  print(bWriteLog and "CommonBornlandTransformFeature:EnterHero")
  self:EnterCommonPawn(InHeroID)
  self:EnsureTransformTimer(InHeroID)
end
function CommonBornlandTransformFeature:ExitHero(bForceExit)
  print(bWriteLog and "CommonBornlandTransformFeature:ExitHero")
  if self.TransformTimer then
    self:RemoveGameTimer(self.TransformTimer)
    self.TransformTimer = nil
  end
  self:ExitCommonPawn()
end
function CommonBornlandTransformFeature:EnterCommonPawn(InHeroID)
  if Game:IsValid(self.Owner) and self.Owner:IsAuthority() and CommonTransformConfig.CommonBornlandTransformConfig[InHeroID] then
    Game:AddItemByResID(self.Owner, CommonTransformConfig.CommonBornlandTransformConfig[InHeroID].ItemID, 1, false)
    if self.Owner.PoseState == ESTEPoseState.Crouch or self.Owner.PoseState == ESTEPoseState.Prone or self.Owner.PoseState == ESTEPoseState.ProneMove then
      self.Owner:SwitchPoseState(ESTEPoseState.Stand, false, false, true, false)
      print(bWriteLog and "CommonBornlandTransformFeature:EnterCommonPawn AdjustPawnState to stand")
    end
    self.Owner:OnStateLeave(EPawnState.Sprint)
    self.Owner:EnterState(EPawnState.Variation)
    self.PreIsFPP = self.Owner.IsNetFPP
    self.Owner.IsNetFPP = false
    self.Owner:SetPawnStateDisabled(EPawnState.SwitchPP, true)
    self.Owner:SetAllowPawnState(EPawnState.UseConsumables, true)
    self.Owner.bAllowToInteract = false
    self:SetInsectState(1)
  else
    self:ClientEnterCommonPawn(InHeroID)
  end
end
function CommonBornlandTransformFeature:ExitCommonPawn(InHeroID)
  if not Game:IsValid(self.Owner) then
    return
  end
  print(bWriteLog and "CommonBornlandTransformFeature:ExitCommonPawn, uOwnerPawn.PlayerKey:" .. tostring(self.Owner.PlayerKey))
  local CurrentHeroID = self.Owner.HeroPropFeature:GetCurrentHeroID()
  if CommonTransformConfig:CheckCommonBornlandTransform(CurrentHeroID) and self.Owner:IsAuthority() then
    self:CheckSpiritDeadHide(self.Owner)
    self.Owner:LeaveState(EPawnState.Variation)
    self.Owner.IsNetFPP = self.PreIsFPP
    if self.Owner:IsPawnStateDisabled(EPawnState.SwitchPP) then
      self.Owner:SetPawnStateDisabled(EPawnState.SwitchPP, false)
    end
    self.Owner.bAllowToInteract = true
    self:SetInsectState(0)
  end
  if Client then
    self:ClientExitCommonPawn()
  end
end
function CommonBornlandTransformFeature:ClientEnterCommonPawn()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) or not Game:IsValid(self.Owner) then
    print(bWriteLog and "CommonBornlandTransformFeature:ClientEnterCommonPawn Fail not slua.isValid(uPlayerController)")
    return
  end
  uPlayerController.IsPlayerUnableToDoAutoSprintOperation = true
  if Game:IsValid(self.Owner) then
    print(bWriteLog and "debugChangeHero CommonBornlandTransformFeature:ClientEnterCommonPawn, uOwnerPawn.PlayerKey:" .. tostring(self.Owner.PlayerKey))
    self.Owner.ClientHitPartJudgment = 0
    if slua.isValid(self.Owner.CustomSpringArm) and not self.Owner.CustomSpringArm:HasActiveCameraOffsetData(ECameraDataType.ECameraDataType_Insect) then
      self.Owner:SetInsectCameraEnable(true)
    end
    if self.Owner.PoseState == ESTEPoseState.Crouch or self.Owner.PoseState == ESTEPoseState.Prone or self.Owner.PoseState == ESTEPoseState.ProneMove then
      self.Owner:SwitchPoseState(ESTEPoseState.Stand, false, false, true, false)
      print(bWriteLog and "CommonBornlandTransformFeature:EnterCommonPawn AdjustPawnState to stand")
    end
    if uPlayerController.SetVirtualStickAutoSprintStatus then
      uPlayerController:SetVirtualStickAutoSprintStatus(false)
      EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_STOP_SPRINT_STATE)
    end
  else
    print(bWriteLog and "CommonBornlandTransformFeature  ClientEnterCommonPawn not uCharacter")
  end
  self:CloseMainBackPackPanel()
  local BackpackClothingEntryUI = UIManager.GetUI(UIManager.UI_Config_InGame.BackpackClothingEntryUI)
  if BackpackClothingEntryUI then
    BackpackClothingEntryUI:HideClothingBackpack()
  end
end
function CommonBornlandTransformFeature:CloseMainBackPackPanel()
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local BackpackUI = InGameUITools.GetBackpackUI()
  if BackpackUI and slua.isValid(BackpackUI.UIRoot) and not BackpackUI:IsCollapsed() then
    BackpackUI:ClickCloseBackpack()
  end
end
function CommonBornlandTransformFeature:ClientExitCommonPawn()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) or not Game:IsValid(self.Owner) then
    print(bWriteLog and "CommonBornlandTransformFeature:ClientExitCommonPawn Fail not slua.isValid(uPlayerController)")
    return
  end
  uPlayerController.IsPlayerUnableToDoAutoSprintOperation = false
  if Game:IsValid(self.Owner) and self.Owner.PlayerKey ~= nil then
    print(bWriteLog and "debugChangeHero CommonBornlandTransformFeature:ClientExitCommonPawn, uOwnerPawn.PlayerKey:" .. tostring(self.Owner.PlayerKey))
    if slua.isValid(self.Owner.CustomSpringArm) and self.Owner.CustomSpringArm:HasActiveCameraOffsetData(ECameraDataType.ECameraDataType_Insect) then
      self.Owner:SetInsectCameraEnable(false)
    end
    self:EnsureGyroscope(false)
    local uAvatarComp2 = self.Owner:getAvatarComponent2()
  end
  local BackpackClothingEntryUI = UIManager.GetUI(UIManager.UI_Config_InGame.BackpackClothingEntryUI)
  if BackpackClothingEntryUI then
    BackpackClothingEntryUI:ShowClothingBackpack()
  end
end
function CommonBornlandTransformFeature:CheckSpiritDeadHide(uCharacter)
  if slua.isValid(uCharacter) and (uCharacter.bDead == true or uCharacter.bDying == true) then
    local ECharacterHideMovementAcive = import("ECharacterHideMovementAcive")
    uCharacter:SetCharacterHideInGame(true, true, true, 1, ECharacterHideMovementAcive.Normal)
    uCharacter:ForceNetUpdate()
  end
end
function CommonBornlandTransformFeature:EnsureTransformTimer(HeroID)
  print(bWriteLog and "CommonBornlandTransformFeature:EnsureTransformTimer HeroID=" .. tostring(HeroID))
  if self.TransformTimer then
    self:RemoveGameTimer(self.TransformTimer)
    self.TransformTimer = nil
  end
  if Game:IsValid(self.Owner) and CommonTransformConfig.CommonBornlandTransformConfig[HeroID] and not Client then
    local TransformDuration = CommonTransformConfig.CommonBornlandTransformConfig[HeroID].TransformDuration
    if TransformDuration and 0 < TransformDuration then
      if CGameState and slua.isValid(CGameState) then
        self.nBeSpiritBackTime = TransformDuration + CGameState:GetServerWorldTimeSeconds()
      end
      self.TransformTimer = self:AddGameTimer(TransformDuration, false, function()
        if Game:IsValid(self.Owner) then
          local uPlayerController = self.Owner:GetControllerSafety()
          if slua.isValid(uPlayerController) then
            print(bWriteLog and "CommonBornlandTransformFeature:EnsureTransformTimer End Transform")
            uPlayerController.HeroPropFeature:ServerChooseHeroData(0)
          end
          if self.TransformTimer then
            self:RemoveGameTimer(self.TransformTimer)
            self.TransformTimer = nil
          end
        end
      end)
    end
  end
end
function CommonBornlandTransformFeature:EnsureGyroscope(bForbid)
  print(bWriteLog and "CommonBornlandTransformFeature:EnsureGyroscope bForbid=" .. tostring(bForbid))
  if not Client then
    print(bWriteLog and "CommonBornlandTransformFeature:EnsureGyroscope not Client")
    return
  end
  if not Game:IsValid(self.Owner) then
    print(bWriteLog and "CommonBornlandTransformFeature:EnsureGyroscope not slua.isValid(uCharacter)")
    return
  end
  local uPlayerController = self.Owner:GetControllerSafety()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "CommonBornlandTransformFeature:EnsureGyroscope not slua.isValid(uPlayerController)")
    return
  end
  if bForbid then
    if not self.PreGyroscope then
      self:AddSettingOptionEvent("Gyroscope", function(Gyroscope)
        if CommonTransformConfig:CheckCommonBornlandTransform(self.Owner.HeroPropFeature:GetCurrentHeroID()) then
          self:AddGameTimer(0.1, false, function()
            self:EnsureGyroscope(true)
          end)
        end
      end)
    end
    self.PreGyroscope = uPlayerController.UseMotionControlType
    uPlayerController.UseMotionControlType = 0
    print(bWriteLog and "CommonBornlandTransformFeature:EnsureGyroscope Set uPlayerController.UseMotionControlType = 0")
  else
    if not self.PreGyroscope then
      print(bWriteLog and "CommonBornlandTransformFeature:EnsureGyroscope not self.PreGyroscope")
      return
    end
    print(bWriteLog and "CommonBornlandTransformFeature:EnsureGyroscope Resume uPlayerController.UseMotionControlType = " .. self.PreGyroscope)
    uPlayerController.UseMotionControlType = self.PreGyroscope
  end
end
function CommonBornlandTransformFeature:ReceiveBeginPlay()
  CommonBornlandTransformFeature.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "CommonBornlandTransformFeature:ReceiveBeginPlay")
  if Client and self.Owner and EVENTTYPE_ROLEPLAY_NORMAL and EVENTID_LOCAL_HERO_ID_CHANGED then
    self:BindLuaObjEvent(self.Owner, "EVENTID_LOCAL_HERO_ID_CHANGED", self.OnCurrentHeroIDChangeLocal, self)
    self:BindLuaObjEvent(self.Owner, "EVENTID_HERO_ID_CHANGED", self.OnCurrentHeroIDChange, self)
  end
  if not Client and self.Owner then
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_TEAM_SHOW_READY, self.OnTeamShowPreCreate, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_PRE_TEAM_SHOW_CREATE_READY, self.OnTeamShowPreCreate, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_PRECHANGE, self.OnGameStatePreChange, self)
    if slua.isValid(self.Owner.SwimComponet) then
      self:AddControlEvent(self.Owner.SwimComponet, "OnPlayerTouchWater", self.OnPlayerTouchWater, self)
    end
  end
end
function CommonBornlandTransformFeature:OnGameStatePreChange(__, __, PreState, NextState)
  print(bWriteLog and "CommonBornlandTransformFeature:OnGameStatePreChange PreState:" .. PreState .. " NextState:" .. NextState)
  if PreState == "ReadyState" and NextState == "FightingState" and self.Owner and self.Owner.HeroPropFeature and CommonTransformConfig:CheckCommonBornlandTransform(self.Owner.HeroPropFeature:GetCurrentHeroID()) then
    local uPlayerController = self.Owner:GetControllerSafety()
    if slua.isValid(uPlayerController) then
      print(bWriteLog and "CommonBornlandTransformFeature:OnGameStatePreChange")
      uPlayerController.HeroPropFeature:ServerChooseHeroData(0)
    end
    print(bWriteLog and "CommonBornlandTransformFeature:OnGameStatePreChange BackSpirit")
  end
end
function CommonBornlandTransformFeature:OnPlayerTouchWater()
  print(bWriteLog and "CommonBornlandTransformFeature:OnPlayerTouchWater in ")
  local bIsSpirit = self.Owner and self.Owner.HeroPropFeature and CommonTransformConfig:CheckCommonBornlandTransform(self.Owner.HeroPropFeature:GetCurrentHeroID())
  if bIsSpirit then
    print(bWriteLog and "CommonBornlandTransformFeature:OnPlayerTouchWater is spirit")
    self:RPC_Server_DoTransfrom(false)
  end
end
function CommonBornlandTransformFeature:OnTeamShowPreCreate()
  print(bWriteLog and "CommonBornlandTransformFeature:OnTeamShowPreCreate in ")
  if self.Owner and self.Owner.HeroPropFeature then
    local CurrentHeroID = self.Owner.HeroPropFeature:GetCurrentHeroID()
    if CommonTransformConfig:CheckCommonBornlandTransform(CurrentHeroID) then
      local uPlayerController = self.Owner:GetControllerSafety()
      if slua.isValid(uPlayerController) then
        print(bWriteLog and "CommonBornlandTransformFeature:OnTeamShowPreCreate transform")
        uPlayerController.HeroPropFeature:ServerChooseHeroData(0)
      end
    end
  end
end
function CommonBornlandTransformFeature:SetInsectState(nIsInsect)
  if self.Owner and self.Owner.AttrModifyComp then
    self.Owner.AttrModifyComp:LuaSetValueToAttributeSafety("IsInsectMan", nIsInsect)
  else
    print(bWriteLog and "Transfiguration:SetInsectState AttrModifyComp is nil")
  end
end
function CommonBornlandTransformFeature:OnCurrentHeroIDChangeLocal(CurrentHeroID, PlayerKey)
  printf("CommonBornlandTransformFeature:OnCurrentHeroIDChangeLocal CurrentHeroID = %d", CurrentHeroID)
  if not self.Owner then
    print(bWriteLog and "OnCurrentHeroIDChange Owner nil")
    return
  end
  local Controller = self.Owner:GetControllerSafety()
  if slua.isValid(Controller) and not slua.isValid(self.Owner:GetCurrentVehicle()) then
    if CommonTransformConfig:CheckCommonBornlandTransform(CurrentHeroID) then
      self:SetInsectState(1)
      local ESTExtraVehicleType = import("ESTExtraVehicleType")
      EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_SHOW_ENTER_VEHICLE_BUTTONS, nil, nil, false, false, false, false, false, ESTExtraVehicleType.VT_Unknown, false)
    elseif CurrentHeroID == 0 then
      self:SetInsectState(0)
    end
    Controller:BroadcastUIMessage("UIMsg_UpdateVehicleBtn", 0, "", "")
  end
  if slua.isValid(Controller) then
    Controller:BroadcastUIMessage("UIMsg_FPPModeChange", 0, "", "")
  end
end
function CommonBornlandTransformFeature:OnCurrentHeroIDChange(CurrentHeroID, PlayerKey)
  printf("CommonBornlandTransformFeature:OnCurrentHeroIDChange CurrentHeroID = %d", CurrentHeroID)
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CCommonBornlandTransformFeature = class(CFeatureBase, nil, CommonBornlandTransformFeature)
return require("combine_class").SetFeatureDynamic(CCommonBornlandTransformFeature)