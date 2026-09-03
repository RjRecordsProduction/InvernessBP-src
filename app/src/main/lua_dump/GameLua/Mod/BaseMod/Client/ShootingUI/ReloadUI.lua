local ReloadUI = {}
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local EWeaponOperationMode = import("EWeaponOperationMode")
function ReloadUI:ctor()
  print(bWriteLog and "ReloadUI:ctor")
  self.ReloadingCD = 0
  self.TimerForBindWeaponChangeDelegate = nil
end
function ReloadUI:OnInitialize()
  print(bWriteLog and "ReloadUI:OnInitialize")
  self:BindWeaponChangeDelegate()
end
function ReloadUI:RegistEvents()
  print(bWriteLog and "ReloadUI:RegistEvents")
  self:AddDataListener(GameplayData.GetSuperData(), "PlayerCharacter", self.OnPlayerCharacterChange, self)
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_ReloadCanvas, self, "ShootingUIPanel_MultiLayer_ReloadCanvas")
  self:AddControlEventByControl(self.UIRoot.ReloadButton, "OnPressedParam", self.OnPressdReload, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.Reconnect_ResetUIByPlayerControllerState, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_ENTER_HOT_AIR_BALLOON, self.HandEnterHotAirBallon, self)
  self:AddUIMessageEvent("UIMsg_RespawnSetUI", self.ResetUIStateAfterRespawn, self)
  self:AddUIMessageEvent("UIMsg_UpdateWeaponFuntion", self.UIMsg_UpdateWeaponFuntion, self)
end
function ReloadUI:OnPostInitialize()
  if not self.ReloadTimer then
    self.ReloadTimer = self:AddGameTimer(0.1, true, function()
      self:OnReloadTimerTick()
    end)
  end
end
function ReloadUI:OnClose()
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_ReloadCanvas)
  if self.ReloadTimer then
    self:RemoveGameTimer(self.ReloadTimer)
    self.ReloadTimer = nil
  end
  if self.TimerForBindWeaponChangeDelegate then
    self:RemoveGameTimer(self.TimerForBindWeaponChangeDelegate)
    self.TimerForBindWeaponChangeDelegate = nil
  end
end
function ReloadUI:OnReloadTimerTick()
  if self.ReloadingCD > 0 then
    local ReloadCountDownText = string.format("%.1fS", self.ReloadingCD)
    self.UIRoot.ReloadCountDownTextBlock:SetText(ReloadCountDownText)
    self.ReloadingCD = self.ReloadingCD - 0.1
    EventSystem:postEvent(EVENTTYPE_SOCIALISLAND, EVENTID_BULLET_RELOAD_CONNT_DOWN, ReloadCountDownText)
  elseif self.ReloadingCD <= 0 then
    self.ReloadingCD = 0
    self.UIRoot.ReloadButton:SetIsEnabled(true)
    self.UIRoot.ReloadBtnBGImage:SetOpacity(1)
    self.UIRoot.CDMask:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.ReloadCountDownTextBlock:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function ReloadUI:ResetUIStateAfterRespawn()
  print(bWriteLog and "ReloadUI:ResetUIStateAfterRespawn")
  self:ResetUIOnPlane()
  self:HandleReloadFinish()
  self:StopAnimation("ReloadCountDown")
  self:BindWeaponChangeDelegate()
end
function ReloadUI:HandEnterHotAirBallon(_, _, bIsEnter)
  if bIsEnter then
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function ReloadUI:Reconnect_ResetUIByPlayerControllerState()
  print(bWriteLog and "ReloadUI:Reconnect_ResetUIByPlayerControllerState")
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and (PlayerController:IsInPlane() or PlayerController:IsInParachute()) then
    self:ResetUIOnPlane()
  end
  self:BindWeaponChangeDelegate()
end
function ReloadUI:ResetUIOnPlane()
  print(bWriteLog and "ReloadUI:ResetUIOnPlane")
  self.UIRoot.ReloadCountDownTextBlock:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function ReloadUI:OnPressdReload(MyGeometry, MouseEvent)
  self:SimReload()
  local OperationalStatsSubsystem = SubsystemMgr:Get("OperationalStatsSubsystem")
  if OperationalStatsSubsystem then
    OperationalStatsSubsystem:AddOperationalStats(OperationalStatsSubsystem.StatsDataKey.Reload, 1)
  end
end
function ReloadUI:BindWeaponChangeDelegate()
  self:_BindWeaponChangeDelegateInternal()
end
function ReloadUI:_BindWeaponChangeDelegateInternal()
  print(bWriteLog and "ReloadUI:BindWeaponChangeDelegate")
  if self.TimerForBindWeaponChangeDelegate then
    self:RemoveGameTimer(self.TimerForBindWeaponChangeDelegate)
    self.TimerForBindWeaponChangeDelegate = nil
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ReloadUI:BindWeaponChangeDelegate not slua.isValid(PlayerCharacter)")
    self.TimerForBindWeaponChangeDelegate = self:AddGameTimer(0.5, false, function()
      print(bWriteLog and "ReloadUI:BindWeaponChangeDelegate Loop1")
      self.TimerForBindWeaponChangeDelegate = nil
      self:BindWeaponChangeDelegate()
    end)
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    self.TimerForBindWeaponChangeDelegate = self:AddGameTimer(0.5, false, function()
      print(bWriteLog and "ReloadUI:BindWeaponChangeDelegate Loop2")
      self.TimerForBindWeaponChangeDelegate = nil
      self:BindWeaponChangeDelegate()
    end)
    return
  end
  self:AddControlEventByControl(WeaponManager, "ChangeCurrentUsingWeaponDelegate", self.HandleWeaponChange, self)
end
function ReloadUI:OnPlayerCharacterChange(_, PlayerCharacter)
  print(bWriteLog and "ReloadUI:OnPlayerCharacterChange")
  self:BindWeaponChangeDelegate()
end
function ReloadUI:SimReload()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) and type(PlayerCharacter.Reload) == "function" then
    PlayerCharacter:Reload()
  end
end
function ReloadUI:StartReloadAnim()
  print(bWriteLog and "ReloadUI:StartReloadAnim")
  Client.RequireSlateTickEveryFrame(SlateUI_ID.SHOOTING_PANEL_RELOAD)
  local CurUsingShootWeapon = self.CurUsingShootWeapon
  if not slua.isValid(CurUsingShootWeapon) then
    print(bWriteLog and "ReloadUI:StartReloadAnim Fail not slua.isValid(self.CurUsingShootWeapon)")
    return
  end
  local RelaodTime = CurUsingShootWeapon:GetCurReloadTime()
  if 0 < RelaodTime then
    self.ReloadingCD = RelaodTime
    self.UIRoot.ReloadBtnBGImage:SetOpacity(0.5)
    self.UIRoot.ReloadButton:SetIsEnabled(true)
    self:PlayUserWidgetAnimation(self.UIRoot.ReloadCountDown, 0, 1, 0, 1 / RelaodTime)
    self.UIRoot.CDMask:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.ReloadCDBar:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.ReloadCountDownTextBlock:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    print(bWriteLog and "ReloadUI:StartReloadAnim Success")
  else
    print(bWriteLog and "ReloadUI:StartReloadAnim RelaodTime <= 0")
  end
  if Client then
    local PlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(PlayerCharacter) and PlayerCharacter.IsClientPeeking then
      PlayerCharacter:NM_ForceSetPeekState(false, false)
    end
  end
end
function ReloadUI:HandleReloadFinish()
  Client.ResetSlateTickEveryFrame(SlateUI_ID.SHOOTING_PANEL_RELOAD)
  print(bWriteLog and "ReloadUI:HandleReloadFinish")
  self.ReloadingCD = 0
  self.UIRoot.ReloadCDBar:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.CDMask:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.ReloadBtnBGImage:SetOpacity(1)
  self.UIRoot.ReloadButton:SetIsEnabled(true)
  self.UIRoot.ReloadCountDownTextBlock:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:UIMsg_ReloadEnd()
end
function ReloadUI:UIMsg_ReloadEnd()
  if not self.ScopeAfterReload then
    print(bWriteLog and "ReloadUI:HandleReloadFinish not self.ScopeAfterReload")
    return
  end
  self.ScopeAfterReload = false
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ReloadUIDelegate:HandleReloadFinish Not uPlayerCharacter")
    return
  end
  local ESTEScopeType = import("ESTEScopeType")
  PlayerCharacter:Scoping(ESTEScopeType.Normal)
end
function ReloadUI:SetReloadBtnAndBulletVisible()
  print(bWriteLog and "ReloadUI:SetReloadBtnAndBulletVisible")
  self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local ActiveWidgetIndex = 1
  local STExtraModLogicSwitchLibrary = import("STExtraModLogicSwitchLibrary")
  if not STExtraModLogicSwitchLibrary.IsActiveBulletDegreeSwitch() then
    ActiveWidgetIndex = 0
  end
  self.UIRoot.WidgetSwitcher_ReloadMod:SetActiveWidgetIndex(ActiveWidgetIndex)
  if ActiveWidgetIndex == 0 then
    self.UIRoot.ReloadBtnBGImage:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.ChangeBullet_CanvasPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.ReloadBtnBGImage:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.ChangeBullet_CanvasPanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function ReloadUI:HandleWeaponChange(Slot)
  print(bWriteLog and "ReloadUI:HandleWeaponChange Slot=" .. tostring(Slot))
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ReloadUI:HandleWeaponChange not slua.isValid(uPlayerCharacter)")
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    print(bWriteLog and "ReloadUI:HandleWeaponChange not uWeaponManager")
    return
  end
  local RefreshBulletCountEvent = function(bSubWeapon, bVehicleWeapon)
    local CurUsingShootWeapon = self.CurUsingShootWeapon
    if slua.isValid(CurUsingShootWeapon) then
      self:RemoveControlEventByControl(CurUsingShootWeapon, "OnWeaponReloadStartDelegate")
      self:RemoveControlEventByControl(CurUsingShootWeapon, "OnWeaponReloadEndDelegage")
    end
    local ShootWeapon = WeaponManager:GetInventoryWeaponByPropSlot(Slot)
    if not bVehicleWeapon then
      self.CurUsing      self:SetReloadBtnAndBulletVisible()
    end
    CurUsingShootWeapon = self.CurUsingShootWeapon
    if slua.isValid(CurUsingShootWeapon) then
      self:AddControlEventByControl(CurUsingShootWeapon, "OnWeaponReloadStartDelegate", self.StartReloadAnim, self)
      self:AddControlEventByControl(CurUsingShootWeapon, "OnWeaponReloadEndDelegage", self.HandleReloadFinish, self)
    end
  end
  local OnRefreshMeleeOrHandProp = function(bMelee)
    local CurWeapon = WeaponManager:GetCurrentUsingWeapon()
    if slua.isValid(CurWeapon) then
      self:SetReloadUIVisibility(false)
    end
  end
  local CurWeapon = WeaponManager:GetCurrentUsingWeapon()
  if Slot == ESurviveWeaponPropSlot.SWPS_None then
    self:SetReloadUIVisibility(false)
  elseif Slot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 then
    RefreshBulletCountEvent(false)
  elseif Slot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon2 then
    RefreshBulletCountEvent(false)
  elseif Slot == ESurviveWeaponPropSlot.SWPS_SubShootWeapon then
    RefreshBulletCountEvent(true)
  elseif Slot == ESurviveWeaponPropSlot.SWPS_MeleeWeapon then
    self:SetReloadUIVisibility(false)
    OnRefreshMeleeOrHandProp(true)
  elseif Slot == ESurviveWeaponPropSlot.SWPS_HandProp then
    self:SetReloadUIVisibility(false)
    OnRefreshMeleeOrHandProp(false)
  elseif Slot == ESurviveWeaponPropSlot.SWPS_VehicleWeapon then
    self:SetReloadUIVisibility(true)
    if slua.isValid(CurWeapon) and CurWeapon.GetShootWeaponEntityComponent then
      self.CurUsingShootWeapon = CurWeapon
      RefreshBulletCountEvent(false, true)
    end
  end
  self:UIMsg_UpdateWeaponFuntion()
end
function ReloadUI:SetReloadUIVisibility(bShow)
  if bShow then
    self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function ReloadUI:UIMsg_UpdateWeaponFuntion()
  print(bWriteLog and "ReloadUI:UIMsg_UpdateWeaponFuntion")
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if not OperateSubsystem then
    return
  end
  local CurUsingWeaponSlot = OperateSubsystem:GetCurrentUsingPropSlot()
  if CurUsingWeaponSlot ~= ESurviveWeaponPropSlot.SWPS_MeleeWeapon or self.JaguarBlockTransaction or not self.bMeleeWeaponAllowThrow then
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "ReloadUI:UpdateWeaponFuntion Fail not slua.isValid(uPlayerController)")
    return
  end
  if PlayerController.CurrentWeaponFunction == EWeaponOperationMode.Throw then
    self:SetReloadUIVisibility(false)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CReloadUI = class(ui_base, nil, ReloadUI)
return CReloadUI