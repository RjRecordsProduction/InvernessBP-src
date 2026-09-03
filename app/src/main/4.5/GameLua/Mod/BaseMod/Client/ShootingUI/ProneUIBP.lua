local ProneUIBP = {}
local EPawnState = import("EPawnState")
local ESTEPoseState = import("ESTEPoseState")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
function ProneUIBP:OnInitialize()
  print(bWriteLog and "ProneUIBP:OnInitialize")
  self.IsOneKeyProneAndCrouch = false
  self.IconPaths = {
    ProneNormal = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_wodao_1_png.ZD_icon_wodao_1_png",
    ProneSelected = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_wodao_2_png.ZD_icon_wodao_2_png"
  }
end
function ProneUIBP:RegistEvents()
  print(bWriteLog and "ProneUIBP:RegistEvents")
  self:AddControlEventByControl(self.UIRoot.RightProne, "OnPressedParam", self.OnPressdProne, self)
  self:AddControlEventByControl(self.UIRoot.RightProne, "OnReleased", self.OnReleasedProne, self)
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_ProneCanvas, self, "ShootingUIPanel_MultiLayer_ProneCanvas")
  self:AddUIMessageEvent("UIMsg_UpdateStandCrouchAndSprint", self.UIMsg_UpdateStandCrouchAndSprint, self)
  self:AddUIMessageEvent("UIMsg_RespawnSetUI", self.ResetUIStateAfterRespawn, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_SHOOTINGUI_PANEL, EVENTID_SHOOTINGUI_OPERATION_CHANGE, self.OnOperationChange, self)
  self:AddDataListener(GameplayData.GetSuperData(), "PlayerCharacter", self.OnPlayerCharacterChange, self)
end
function ProneUIBP:OnPostInitialize()
  print(bWriteLog and "ProneUIBP:OnPostInitialize")
  self:HandleProneVisibility()
end
function ProneUIBP:OnClose()
  print(bWriteLog and "ProneUIBP:OnClose")
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_ProneCanvas)
end
function ProneUIBP:SetWidgetVisibilityByName(WidgetName, Visibility)
  if self.UIRoot and self.UIRoot[WidgetName] and slua.isValid(self.UIRoot[WidgetName]) then
    self.UIRoot[WidgetName]:SetWidgetVisibility(Visibility)
  end
end
function ProneUIBP:HandleProneVisibility()
  print(bWriteLog and "ProneUIBP:HandleProneVisibility")
  local RefreshProneVisibility = function(OneKeyProneAndCrouchSwitch)
    print(bWriteLog and "ProneUIBP:HandleProneVisibility RefreshProneVisibility " .. tostring(OneKeyProneAndCrouchSwitch))
    if not self.UIRoot or not slua.isValid(self.UIRoot) then
      return
    end
    self.IsOneKeyProneAndCrouch = OneKeyProneAndCrouchSwitch
    if OneKeyProneAndCrouchSwitch then
      self:SetWidgetVisibilityByName("Prone_SettingControl", UEnums.ESlateVisibility.Collapsed)
    else
      self:SetWidgetVisibilityByName("Prone_SettingControl", UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
    local PlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(PlayerCharacter) then
      self:UpdateStandCrouchProneAndSprint(PlayerCharacter.PoseState)
    end
  end
  self:AddSettingOptionEvent("OneKeyProneAndCrouchSwitch", RefreshProneVisibility, true)
end
function ProneUIBP:ResetUIStateAfterRespawn()
  print(bWriteLog and "ProneUIBP:ResetUIStateAfterRespawn")
  self:UpdateProneBtnStatus(0)
end
function ProneUIBP:OnPressdProne(MyGeometry, MouseEvent)
  print(bWriteLog and "ProneUIBP:OnPressdProne [1]")
  EventSystem:postEvent(EVENTTYPE_INGAME_CREATIVE_MODE, EVENTID_UGC_NATIVE_BUTTON_PRESSED, "Prone")
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:BleProne()
  end
end
function ProneUIBP:OnReleasedProne()
  print(bWriteLog and "ProneUIBP:OnReleasedProne")
  EventSystem:postEvent(EVENTTYPE_INGAME_CREATIVE_MODE, EVENTID_UGC_NATIVE_BUTTON_RELEASED, "Prone")
end
function ProneUIBP:IsPronePose()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return false
  end
  return PlayerCharacter:HasState(EPawnState.ProneMove) or PlayerCharacter:HasState(EPawnState.Prone)
end
function ProneUIBP:FireInteruptedIfProne()
end
function ProneUIBP:UpdateProneBtnStatus(Index)
  if not self.UIRoot.Image_Selected_Right_Prone then
    return
  end
  local IconPath
  if Index == 2 and not self.IsOneKeyProneAndCrouch then
    IconPath = self.IconPaths.ProneSelected
  else
    IconPath = self.IconPaths.ProneNormal
  end
  if IconPath then
    self:SetTexture(self.UIRoot.Image_Selected_Right_Prone, IconPath, {sync = false})
  end
end
function ProneUIBP:UIMsg_UpdateStandCrouchAndSprint()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    self:UpdateStandCrouchProneAndSprint(PlayerCharacter.PoseState)
  end
end
function ProneUIBP:UpdateStandCrouchProneAndSprint(PoseState)
  if PoseState == ESTEPoseState.Prone then
    self:UpdateProneBtnStatus(2)
    return
  end
  if PoseState == ESTEPoseState.Crawl then
    return
  end
  self:UpdateProneBtnStatus(0)
end
function ProneUIBP:OnPlayerCharacterChange(_, PlayerCharacter)
  print(bWriteLog and "ProneUIBP:OnPlayerCharacterChange")
  if slua.isValid(PlayerCharacter) then
    self:AddControlEventByControl(PlayerCharacter, "OnPlayerPoseChange", self.HandlePlayerPoseChange, self)
    self:HandlePlayerPoseChange(-1, PlayerCharacter.PoseState)
    GameplayData.AddSelfPlayerCharacterEvent(self, "OnJoyStickInteruptDelegate", self.FireInteruptedIfProne, self)
  end
end
function ProneUIBP:OnPlayerControllerChange(_, PlayerController)
  print(bWriteLog and "ProneUIBP:OnPlayerControllerChange")
  if slua.isValid(PlayerController) then
  end
end
function ProneUIBP:HandlePlayerPoseChange(LastPoseState, NewPoseState)
  print(bWriteLog and "ProneUIBP:HandlePlayerPoseChange LastPoseState: " .. tostring(LastPoseState) .. " NewPoseState: " .. tostring(NewPoseState))
  if LastPoseState == NewPoseState then
    return
  end
  self:UpdateStandCrouchProneAndSprint(NewPoseState)
end
function ProneUIBP:OnOperationChange(_, __, Operation)
  print(bWriteLog and "ProneUIBP:OnOperationChange Operation=" .. tostring(Operation))
  if Operation == UEnums.UIOperation.Shoot then
    self:SetProneButtonVisibility(true)
  elseif Operation == UEnums.UIOperation.Drive then
    self:SetProneButtonVisibility(false)
  elseif Operation == UEnums.UIOperation.DriveAsPassenger then
    self:SetWidgetVisibilityByName("RightProne", UEnums.ESlateVisibility.Collapsed)
  end
end
function ProneUIBP:ShowUIByOperation(Operation)
  print(bWriteLog and "ProneUIBP:ShowUIByOperation Operation=" .. tostring(Operation))
  if Operation == UEnums.UIOperation.Shoot then
    self:SetWidgetVisibilityByName("RightProne", UEnums.ESlateVisibility.Visible)
  elseif Operation == UEnums.UIOperation.Drive then
    self:SetWidgetVisibilityByName("RightProne", UEnums.ESlateVisibility.Collapsed)
  elseif Operation == UEnums.UIOperation.DriveAsPassenger then
    self:SetWidgetVisibilityByName("RightProne", UEnums.ESlateVisibility.Collapsed)
  end
end
function ProneUIBP:SetProneButtonVisibility(bVisible)
  print(bWriteLog and "ProneUIBP:SetProneButtonVisibility [1] bVisible=" .. tostring(bVisible))
  local Visibility = bVisible and UEnums.ESlateVisibility.Visible or UEnums.ESlateVisibility.Collapsed
  self:SetWidgetVisibilityByName("RightProne", Visibility)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CProneUIBP = class(ui_base, nil, ProneUIBP)
return CProneUIBP