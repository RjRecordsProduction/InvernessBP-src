local CrouchUIBP = {}
local EPawnState = import("EPawnState")
local ESTEPoseState = import("ESTEPoseState")
local EMovementMode = import("EMovementMode")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
function CrouchUIBP:OnInitialize()
  print(bWriteLog and "CrouchUIBP:OnInitialize")
  self.IsCrouchLongPressExcuted = false
  self.CrouchLongPressedTimerHandler = nil
  self.IsOneKeyProneAndCrouch = false
  self.IsOpenShovelingAbility = false
  self.CrouchImageIndex = 1
  self.CrouchLongPressStartTime = 0
  self.CrouchLongPressDuration = 0.4
  self.SliderUpdateTimerID = nil
  self.bInShovelingCD = false
  self.ShovelingCDTotalTime = 0
  self.ShovelingCDStartTime = 0
  self.ShovelingGameTimerID = nil
  self.IconPaths = {
    CrouchNormal = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_dunxia_1_png.ZD_icon_dunxia_1_png",
    ProneNormal = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_wodao_1_png.ZD_icon_wodao_1_png",
    ShovelNormal = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_huachan_png.ZD_icon_huachan_png",
    CrouchSelected = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_dunxia_2_png.ZD_icon_dunxia_2_png",
    ProneSelected = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_wodao_2_png.ZD_icon_wodao_2_png",
    ShovelSelected = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_huachan_2_png.ZD_icon_huachan_2_png"
  }
end
function CrouchUIBP:RegistEvents()
  print(bWriteLog and "CrouchUIBP:RegistEvents")
  self:AddControlEventByControl(self.UIRoot.RightCrouch, "OnPressedParam", self.OnCrouchBtnPressed, self)
  self:AddControlEventByControl(self.UIRoot.RightCrouch, "OnReleased", self.OnCrouchBtnReleased, self)
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_CrouchCanvas, self, "ShootingUIPanel_MultiLayer_CrouchCanvas")
  self:AddUIMessageEvent("UIMsg_UpdateStandCrouchAndSprint", self.UIMsg_UpdateStandCrouchAndSprint, self)
  self:AddUIMessageEvent("UIMsg_RespawnSetUI", self.ResetUIStateAfterRespawn, self)
  self:AddDataListener(GameplayData.GetSuperData(), "PlayerCharacter", self.OnPlayerCharacterChange, self)
end
function CrouchUIBP:OnPostInitialize()
  print(bWriteLog and "CrouchUIBP:OnPostInitialize")
  self:HandleCrouchVisibility()
end
function CrouchUIBP:OnClose()
  print(bWriteLog and "CrouchUIBP:OnClose")
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_CrouchCanvas)
  if self.CrouchLongPressedTimerHandler then
    self:RemoveGameTimer(self.CrouchLongPressedTimerHandler)
    self.CrouchLongPressedTimerHandler = nil
  end
  if self.SliderUpdateTimerID then
    self:RemoveGameTimer(self.SliderUpdateTimerID)
    self.SliderUpdateTimerID = nil
  end
  if self.ShovelingGameTimerID then
    self:RemoveGameTimer(self.ShovelingGameTimerID)
    self.ShovelingGameTimerID = nil
  end
end
function CrouchUIBP:HandleCrouchVisibility()
  print(bWriteLog and "CrouchUIBP:HandleCrouchVisibility")
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    self:AddGameTimer(1, false, function()
      self:HandleCrouchVisibility()
    end)
    return
  end
  local RefreshCrouchVisibility = function(OneKeyProneAndCrouchSwitch)
    print(bWriteLog and "CrouchUIBP:HandleCrouchVisibility RefreshCrouchVisibility " .. tostring(OneKeyProneAndCrouchSwitch))
    if not self.UIRoot or not slua.isValid(self.UIRoot) then
      return
    end
    self.IsOneKeyProneAndCrouch = OneKeyProneAndCrouchSwitch
    local PlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(PlayerCharacter) then
      self:UpdateStandCrouchProneAndSprint(PlayerCharacter.PoseState)
    end
  end
  SettingSubsystem:RegisterUserSettingsDelegate_Bool("OneKeyProneAndCrouchSwitch", RefreshCrouchVisibility)
  RefreshCrouchVisibility(SettingSubsystem:GetUserSettings_Bool("OneKeyProneAndCrouchSwitch"))
end
function CrouchUIBP:ResetUIStateAfterRespawn()
  print(bWriteLog and "CrouchUIBP:ResetUIStateAfterRespawn")
  self:UpdateCrouchBtnStatus(0)
end
function CrouchUIBP:OnCrouchBtnPressed(MyGeometry, MouseEvent)
  print(bWriteLog and "CrouchUIBP:OnCrouchBtnPressed")
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if not OperateSubsystem then
    return
  end
  if self.IsOneKeyProneAndCrouch then
    self:OnCrouchBtnLongPressBegin()
  else
    OperateSubsystem:BleCrouch()
  end
end
function CrouchUIBP:OnCrouchBtnReleased()
  print(bWriteLog and "CrouchUIBP:OnCrouchBtnReleased")
  if not self.IsOneKeyProneAndCrouch then
    return
  end
  self:OnCrouchBtnLongPressEnd()
end
function CrouchUIBP:OnCrouchBtnLongPressBegin()
  print(bWriteLog and "CrouchUIBP:OnCrouchBtnLongPressBegin")
  self.IsCrouchLongPressExcuted = false
  if self.CrouchLongPressedTimerHandler then
    self:RemoveGameTimer(self.CrouchLongPressedTimerHandler)
  end
  self.CrouchLongPressedTimerHandler = self:AddGameTimer(0.4, false, function()
    self.CrouchLongPressedTimerHandler = nil
    self:OnCrouchBtnLongPressExcute()
  end)
end
function CrouchUIBP:OnCrouchBtnLongPressExcute()
  print(bWriteLog and "CrouchUIBP:OnCrouchBtnLongPressExcute")
  self.IsCrouchLongPressExcuted = true
  if self.CrouchLongPressedTimerHandler then
    self:RemoveGameTimer(self.CrouchLongPressedTimerHandler)
    self.CrouchLongPressedTimerHandler = nil
  end
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if not OperateSubsystem then
    return
  end
  if self:IsPronePose() then
    OperateSubsystem:BleCrouch()
  else
    OperateSubsystem:BleProne()
  end
end
function CrouchUIBP:OnCrouchBtnLongPressEnd()
  print(bWriteLog and "CrouchUIBP:OnCrouchBtnLongPressEnd")
  if self.CrouchLongPressedTimerHandler then
    self:RemoveGameTimer(self.CrouchLongPressedTimerHandler)
    self.CrouchLongPressedTimerHandler = nil
  end
  self.UIRoot.Slider:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if self.IsCrouchLongPressExcuted then
    print(bWriteLog and "ShootingUIPanelUIBase:OnCrouchBtnLongPressEnd IsCrouchLongPressExcuted")
    return
  end
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if not OperateSubsystem then
    return
  end
  if self:IsPronePose() then
    OperateSubsystem:BleProne()
  else
    OperateSubsystem:BleCrouch()
  end
end
function CrouchUIBP:IsPronePose()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return false
  end
  return PlayerCharacter:HasState(EPawnState.ProneMove) or PlayerCharacter:HasState(EPawnState.Prone)
end
function CrouchUIBP:InShovelingCD()
  return self.bInShovelingCD
end
function CrouchUIBP:StartShovelingCD()
  print(bWriteLog and "CrouchUIBP:StartShovelingCD")
  local CharacterMovement
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) and slua.isValid(PlayerCharacter.CharacterMovement) then
    CharacterMovement = PlayerCharacter.CharacterMovement
  end
  if slua.isValid(CharacterMovement) then
    self.ShovelingCDTotalTime = CharacterMovement.EnterShovelCD
  end
  self.ShovelingCDStartTime = self.ShovelingCDTotalTime
  if self.ShovelingCDTotalTime > 1 then
    self.UIRoot.RightCountDownTextBlock:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.CrouchCDBar:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local MaterialInstDynamic = self.UIRoot.CrouchCDBar:GetDynamicMaterial()
    if slua.isValid(MaterialInstDynamic) then
      MaterialInstDynamic:SetScalarParameterValue("Mask_Percent", 0)
    end
  end
  self.bInShovelingCD = true
  if self.ShovelingGameTimerID then
    self:RemoveGameTimer(self.ShovelingGameTimerID)
    self.ShovelingGameTimerID = nil
  end
  self.ShovelingGameTimerID = self:AddGameTimer(0.1, true, function()
    self:ShovelingCDLoop()
  end)
  self:AddGameTimer(1, false, function()
    self:CheckFov()
  end)
  self:AddControlEventByControl(CharacterMovement, "OnShovelStateChangeForBP", function(bShovel)
    if not bShovel then
      if slua.isValid(PlayerCharacter) then
        if PlayerCharacter:HasState(EPawnState.Crouch) then
          self:UpdateCrouchBtnStatus(1)
        else
          self:UpdateCrouchBtnStatus(0)
        end
      else
        self:UpdateCrouchBtnStatus(0)
      end
    end
    if slua.isValid(CharacterMovement) then
      self:RemoveControlEventByControl(CharacterMovement, "OnShovelStateChangeForBP")
    end
    self:AddGameTimer(1, false, function()
      self:CheckFov()
    end)
  end)
end
function CrouchUIBP:ShovelingCDLoop()
  self.ShovelingCDStartTime = self.ShovelingCDStartTime - 0.1
  if self.ShovelingCDStartTime >= 0 then
    self.UIRoot.RightCountDownTextBlock:SetText(string.format("%.1f", self.ShovelingCDStartTime))
    local MaterialInstDynamic = self.UIRoot.CrouchCDBar:GetDynamicMaterial()
    if slua.isValid(MaterialInstDynamic) then
      MaterialInstDynamic:SetScalarParameterValue("Mask_Percent", self.ShovelingCDStartTime / self.ShovelingCDTotalTime)
    end
  else
    self.bInShovelingCD = false
    self.UIRoot.CrouchCDBar:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.RightCountDownTextBlock:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:UpdateCrouchBtnStatus(0)
    if self.ShovelingGameTimerID then
      self:RemoveGameTimer(self.ShovelingGameTimerID)
      self.ShovelingGameTimerID = nil
    end
  end
end
function CrouchUIBP:CheckFov()
  print(bWriteLog and "CrouchUIBP:CheckFov")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "CrouchUIBP:CheckFov not slua.isValid(PlayerCharacter)")
    return
  end
  if not slua.isValid(PlayerCharacter.ThirdPersonCameraComponent) or not slua.isValid(PlayerCharacter.STCharacterMovement) then
    print(bWriteLog and "CrouchUIBP:CheckFov not slua.isValid(PlayerCharacter.ThirdPersonCameraComponent)")
    return
  end
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  local DefaultFov = SettingSubsystem:GetUserSettings_Int("TpViewValue")
  local FixedOffet = 5
  if FixedOffet < PlayerCharacter.ThirdPersonCameraComponent.FieldOfView - DefaultFov then
    print(bWriteLog and "CrouchUIBP:CheckFov Fixed")
    PlayerCharacter.ThirdPersonCameraComponent:InterpToTargetFov(DefaultFov - PlayerCharacter.ThirdPersonCameraComponent.FieldOfView, PlayerCharacter.STCharacterMovement.ExitShovelingTPPFovChangeSpeed, true)
    PlayerCharacter.ThirdPersonCameraComponent.FieldOfView = DefaultFov
  end
end
function CrouchUIBP:UpdateCrouchBtnStatus(Index)
  print(bWriteLog and "CrouchUIBP:UpdateCrouchBtnStatus Index=" .. tostring(Index) .. " IsOneKeyProneAndCrouch=" .. tostring(self.IsOneKeyProneAndCrouch))
  if not self.UIRoot.Image_Selected_Right_Crouch then
    return
  end
  local IconPath
  local IsShowShovel = self:IsShowShovelIcon()
  if self.IsOneKeyProneAndCrouch and Index == 1 then
    local PlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(PlayerCharacter) and self:IsPronePose() then
      self.CrouchImageIndex = 2
      IconPath = self.IconPaths.ProneSelected
      if IconPath then
        self:SetTexture(self.UIRoot.Image_Selected_Right_Crouch, IconPath, {sync = false})
      end
      return
    end
  end
  if IsShowShovel then
    self.CrouchImageIndex = 3
    if Index == 1 then
      IconPath = self.IconPaths.ShovelSelected
    else
      IconPath = self.IconPaths.ShovelNormal
    end
  else
    self.CrouchImageIndex = 1
    if Index == 1 then
      IconPath = self.IconPaths.CrouchSelected
    else
      IconPath = self.IconPaths.CrouchNormal
    end
  end
  if IconPath then
    self:SetTexture(self.UIRoot.Image_Selected_Right_Crouch, IconPath, {sync = false})
  end
end
function CrouchUIBP:IsShowShovelIcon()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return false
  end
  if PlayerController.GetCurrentHeroID and PlayerController:GetCurrentHeroID() then
    print(bWriteLog and "CrouchUIBP:IsShowShovelIcon : " .. tostring(PlayerController:GetCurrentHeroID() > 0))
    return PlayerController:GetCurrentHeroID() > 0
  end
  return false
end
function CrouchUIBP:UIMsg_UpdateStandCrouchAndSprint()
  print(bWriteLog and "CrouchUIBP:UIMsg_UpdateStandCrouchAndSprint")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    self:UpdateStandCrouchProneAndSprint(PlayerCharacter.PoseState)
  end
end
function CrouchUIBP:UpdateStandCrouchProneAndSprint(PoseState)
  print(bWriteLog and "CrouchUIBP:UpdateStandCrouchProneAndSprint PoseState=" .. tostring(PoseState))
  if PoseState == ESTEPoseState.Sprint then
    self:UpdateCrouchBtnStatus(0)
    return
  end
  if PoseState == ESTEPoseState.Crawl then
    if self.IsOneKeyProneAndCrouch then
      self:UpdateCrouchBtnStatus(1)
    else
      self:UpdateCrouchBtnStatus(0)
    end
    return
  end
  if PoseState == ESTEPoseState.CrouchSprint then
    self:UpdateCrouchBtnStatus(1)
    return
  end
  if PoseState == ESTEPoseState.Prone then
    if self.IsOneKeyProneAndCrouch then
      self:UpdateCrouchBtnStatus(1)
    else
      self:UpdateCrouchBtnStatus(0)
    end
    return
  end
  if PoseState == ESTEPoseState.Stand or PoseState == ESTEPoseState.Crouch then
    if PoseState == ESTEPoseState.Stand then
      self:UpdateCrouchBtnStatus(0)
    else
      self:UpdateCrouchBtnStatus(1)
    end
    return
  end
end
function CrouchUIBP:OnPlayerCharacterChange(_, PlayerCharacter)
  print(bWriteLog and "CrouchUIBP:OnPlayerCharacterChange")
  if slua.isValid(PlayerCharacter) then
    self:AddControlEventByControl(PlayerCharacter, "OnPlayerPoseChange", self.HandlePlayerPoseChange, self)
    self:HandlePlayerPoseChange(-1, PlayerCharacter.PoseState)
  end
end
function CrouchUIBP:OnPlayerControllerChange(_, PlayerController)
  print(bWriteLog and "CrouchUIBP:OnPlayerControllerChange")
  if slua.isValid(PlayerController) then
  end
end
function CrouchUIBP:HandlePlayerPoseChange(LastPoseState, NewPoseState)
  print(bWriteLog and "CrouchUIBP:HandlePlayerPoseChange LastPoseState: " .. tostring(LastPoseState) .. " NewPoseState: " .. tostring(NewPoseState))
  if LastPoseState == NewPoseState then
    return
  end
  self:UpdateStandCrouchProneAndSprint(NewPoseState)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CCrouchUIBP = class(ui_base, nil, CrouchUIBP)
return CCrouchUIBP