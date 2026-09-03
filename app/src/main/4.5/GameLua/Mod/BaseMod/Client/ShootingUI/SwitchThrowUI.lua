local SwitchThrowUI = {}
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local EWeaponOperationMode = import("EWeaponOperationMode")
local EThrowGrenadeMode = import("EThrowGrenadeMode")
local UAESkillManagerUtils = import("UAESkillManagerUtils")
function SwitchThrowUI:ctor()
  self.HighThrowBrush = "/Game/Arts/UI/Atlas/BattleUI/Grenade/Frames/ZD_icon_gaopao_Normal_png.ZD_icon_gaopao_Normal_png"
  self.LowThrowBrush = "/Game/Arts/UI/Atlas/BattleUI/Grenade/Frames/ZD_icon_dipao_Normal_png.ZD_icon_dipao_Normal_png"
  self.CurThrowSkillID = -1
  self.CurGrenadeID = 0
  self.bInChangeThorwModeCD = false
  self.TimerForBindWeaponChangeDelegate = nil
end
function SwitchThrowUI:OnInitialize()
  self:BindWeaponChangeDelegate()
end
function SwitchThrowUI:RegistEvents()
  self:AddDataListener(GameplayData.GetSuperData(), "PlayerCharacter", self.OnPlayerCharacterChange, self)
  self:AddUIMessageEvent("UIMsg_RespawnSetUI", self.ResetUIStateAfterRespawn, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.Reconnect_ResetUIByPlayerControllerState, self)
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_SwitchThrowCanvas, self, "ShootingUIPanel_MultiLayer_SwitchThrowCanvas")
  self:AddControlEventByControl(self.UIRoot.Button_Throw_Mode, "OnClicked", self.OnClickedChangeThrowMode, self)
  self:AddUIMessageEvent("UIMsg_ShowCancelGrenadeThrow", self.UIMsg_ShowCancelGrenadeThrow, self)
  self:AddUIMessageEvent("UIMsg_UpdateWeaponFuntion", self.UIMsg_UpdateWeaponFuntion, self)
  GameplayData.AddSelfPlayerCharacterEvent(self, "ThrowGrenadeModeChangedDelegate", self.CharacterThrowGrenadeModeChange, self)
end
function SwitchThrowUI:OnPostInitialize()
end
function SwitchThrowUI:OnClose()
  self.bInChangeThorwModeCD = false
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_SwitchThrowCanvas)
  if self.TimerForBindWeaponChangeDelegate then
    self:RemoveGameTimer(self.TimerForBindWeaponChangeDelegate)
    self.TimerForBindWeaponChangeDelegate = nil
  end
end
function SwitchThrowUI:UIMsg_ShowCancelGrenadeThrow()
  print(bWriteLog and "SwitchThrowUI:UIMsg_ShowCancelGrenadeThrow")
  if self.CurGrenadeID == 0 then
    self.CurThrowSkillID = 0
  end
end
function SwitchThrowUI:ResetUIStateAfterRespawn()
  print(bWriteLog and "SwitchThrowUI:ResetUIStateAfterRespawn")
  self:ResetUIOnPlane()
  self:ToogleThrowMode(EThrowGrenadeMode.LowThrowMode)
  self:BindWeaponChangeDelegate()
end
function SwitchThrowUI:ResetUIOnPlane()
  print(bWriteLog and "SwitchThrowUI:ResetUIOnPlane")
  self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function SwitchThrowUI:RefreshSwitchThrowUI(GrenadeID)
  print(bWriteLog and "SwitchThrowUI:RefreshSwitchThrowUI" .. tostring(GrenadeID))
  self.Cur  self.CurThrowSkillID = -1
  local bShowThrow = self:NeedShowThrowSwitch()
  if bShowThrow then
    self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  if GrenadeID ~= 602111 and GrenadeID ~= 602113 then
    local ThrowMode = PlayerCharacter:GetThrowGrenadeMode()
    if ThrowMode ~= EThrowGrenadeMode.HighThrowMode and ThrowMode ~= EThrowGrenadeMode.LowThrowMode then
      self:ToogleThrowMode(EThrowGrenadeMode.LowThrowMode)
    end
    self:CharacterThrowGrenadeModeChange()
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    return
  end
  local CurWeapon = WeaponManager:GetCurrentUsingWeapon()
  if not slua.isValid(CurWeapon) then
    return
  end
  if CurWeapon.GetGrenadeSkillID then
    self.CurThrowSkillID = CurWeapon:GetGrenadeSkillID()
  end
end
function SwitchThrowUI:UIMsg_UpdateWeaponFuntion()
  print(bWriteLog and "SwitchThrowUI:UIMsg_UpdateWeaponFuntion")
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
    print(bWriteLog and "SwitchThrowUI:UpdateWeaponFuntion Fail not slua.isValid(uPlayerController)")
    return
  end
  if PlayerController.CurrentWeaponFunction == EWeaponOperationMode.Throw then
    self:RefreshSwitchThrowUI(0)
  end
end
function SwitchThrowUI:HandleWeaponChange(Slot)
  print(bWriteLog and "SwitchThrowUI:HandleWeaponChange Slot=" .. tostring(Slot))
  self.Current  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "SwitchThrowUI:HandleWeaponChange not slua.isValid(uPlayerCharacter)")
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    print(bWriteLog and "SwitchThrowUI:HandleWeaponChange not uWeaponManager")
    return
  end
  local RefreshUI = function(bShowSwitchThrow)
    if bShowSwitchThrow then
      self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  local OnRefreshMeleeOrHandProp = function(bMelee)
    local CurWeapon = WeaponManager:GetCurrentUsingWeapon()
    if slua.isValid(CurWeapon) then
      local CurGrenadeDefineID = CurWeapon:GetItemDefineID()
      self:RefreshSwitchThrowUI(CurGrenadeDefineID.TypeSpecificID)
    end
  end
  if Slot == ESurviveWeaponPropSlot.SWPS_MeleeWeapon then
    RefreshUI(false)
    OnRefreshMeleeOrHandProp(true)
  elseif Slot == ESurviveWeaponPropSlot.SWPS_HandProp then
    RefreshUI(true)
    OnRefreshMeleeOrHandProp(false)
  else
    RefreshUI(false)
  end
  self:UIMsg_UpdateWeaponFuntion()
end
function SwitchThrowUI:NeedShowThrowSwitch()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return false
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    return false
  end
  local CurWeapon = WeaponManager:GetCurrentUsingWeapon()
  if not slua.isValid(CurWeapon) then
    return false
  end
  local ItemDefineID = CurWeapon:GetItemDefineID()
  local TypeSpecificID = ItemDefineID.TypeSpecificID
  print(bWriteLog and "SwitchThrowUI:NeedShowThrowSwitch TypeSpecificID=" .. tostring(TypeSpecificID) .. "ItemDefineID=" .. tostring(ItemDefineID))
  local ItemData = CDataTable.GetTableData("Item", TypeSpecificID)
  local ItemSubType = -1
  ItemSubType = ItemData and ItemData.ItemSubType or ItemSubType
  local HideThrowSwitch = UAESkillManagerUtils.GetHideThrowSwitchFlag(TypeSpecificID)
  return not HideThrowSwitch and ItemSubType ~= 108
end
function SwitchThrowUI:ToogleThrowMode(ThrowMode)
  print(bWriteLog and "SwitchThrowUI:ToogleThrowMode ThrowMode=" .. tostring(ThrowMode))
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "SwitchThrowUI:ToogleThrowMode Fail not slua.isValid(uPlayerCharacter)")
    return false
  end
  local bCanChangeThrowMode = self:CanChangeThrowMode()
  if not bCanChangeThrowMode then
    print(bWriteLog and "SwitchThrowUI:ToogleThrowMode Fail not bCanChangeThrowMode")
    return
  end
  if ThrowMode == EThrowGrenadeMode.HighThrowMode then
    PlayerCharacter:SetThrowGrenadeMode(EThrowGrenadeMode.LowThrowMode)
    self.UIRoot.TextBlock_ThrowTextTips:SetText(LocUtil.GetLocalizeResStr(45451))
    self.ThrowMode = EThrowGrenadeMode.LowThrowMode
    self.UIRoot.Throw_Mode_Image:SetBrushFromPathAsync(self.LowThrowBrush, false)
  elseif ThrowMode == EThrowGrenadeMode.LowThrowMode then
    PlayerCharacter:SetThrowGrenadeMode(EThrowGrenadeMode.HighThrowMode)
    self.UIRoot.TextBlock_ThrowTextTips:SetText(LocUtil.GetLocalizeResStr(45450))
    self.ThrowMode = EThrowGrenadeMode.HighThrowMode
    self.UIRoot.Throw_Mode_Image:SetBrushFromPathAsync(self.HighThrowBrush, false)
  end
end
function SwitchThrowUI:CharacterThrowGrenadeModeChange(NewMode, PrevMode)
  print(bWriteLog and "SwitchThrowUI:CharacterThrowGrenadeModeChange")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "SwitchThrowUI:CharacterThrowGrenadeModeChange not slua.isValid(uPlayerCharacter)")
    return
  end
  local NextMode = PlayerCharacter:GetThrowGrenadeMode()
  print(bWriteLog and "SwitchThrowUI:CharacterThrowGrenadeModeChange Character Throw Mode=" .. tostring(NextMode))
  if NewMode then
    NextMode = NewMode
    print(bWriteLog and "SwitchThrowUI:CharacterThrowGrenadeModeChange NewMode=" .. tostring(NewMode))
  end
  if NextMode == EThrowGrenadeMode.LowThrowMode then
    self.UIRoot.TextBlock_ThrowTextTips:SetText(LocUtil.GetLocalizeResStr(45451))
    self.ThrowMode = EThrowGrenadeMode.LowThrowMode
    self.UIRoot.Throw_Mode_Image:SetBrushFromPathAsync(self.LowThrowBrush, false)
  elseif NextMode == EThrowGrenadeMode.HighThrowMode then
    self.UIRoot.TextBlock_ThrowTextTips:SetText(LocUtil.GetLocalizeResStr(45450))
    self.ThrowMode = EThrowGrenadeMode.HighThrowMode
    self.UIRoot.Throw_Mode_Image:SetBrushFromPathAsync(self.HighThrowBrush, false)
  end
end
function SwitchThrowUI:OnClickedChangeThrowMode()
  print(bWriteLog and "SwitchThrowUI:OnClickedChangeThrowMode")
  if self.bInChangeThorwModeCD then
    print(bWriteLog and "SwitchThrowUI:OnClickedChangeThrowMode self.bInChangeThorwModeCD")
    return
  end
  self.bInChangeThorwModeCD = true
  self:ToogleThrowMode(self.ThrowMode)
  self:AddGameTimer(0.4, false, function()
    self.bInChangeThorwModeCD = false
  end)
end
function SwitchThrowUI:CanChangeThrowMode()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "SwitchThrowUI:ToogleThrowMode Fail not slua.isValid(uPlayerCharacter)")
    return false
  end
  local uSkillManagerComp = PlayerCharacter:GetSkillManager()
  if not slua.isValid(uSkillManagerComp) then
    return false
  end
  local CurSkillID = self.CurThrowSkillID
  if 0 < CurSkillID and uSkillManagerComp:IsCastingSkillID(CurSkillID) then
    local GrenadeSkillState = Game:GetSkillBlackboardValue(PlayerCharacter, CurSkillID, UEnums.EBlackBoardKeyType.Name, "State")
    return GrenadeSkillState == "" or GrenadeSkillState == "None" or GrenadeSkillState == "Aim"
  end
  return true
end
function SwitchThrowUI:OnReadyToThrowGrenade()
  local bShowThrow = self:NeedShowThrowSwitch()
  local Visibility = UEnums.ESlateVisibility.Collapsed
  if bShowThrow then
    Visibility = UEnums.ESlateVisibility.SelfHitTestInvisible
  end
  self:SetWidgetVisibility(Visibility)
end
function SwitchThrowUI:OnEndThrowGrenade()
  local bShowThrow = self:NeedShowThrowSwitch()
  local Visibility = UEnums.ESlateVisibility.Collapsed
  if bShowThrow then
    Visibility = UEnums.ESlateVisibility.SelfHitTestInvisible
  end
  self:SetWidgetVisibility(Visibility)
end
function SwitchThrowUI:Reconnect_ResetUIByPlayerControllerState()
  print(bWriteLog and "SwitchThrowUI:Reconnect_ResetUIByPlayerControllerState")
  self:BindWeaponChangeDelegate()
end
function SwitchThrowUI:BindWeaponChangeDelegate()
  self:_BindWeaponChangeDelegateInternal()
end
function SwitchThrowUI:_BindWeaponChangeDelegateInternal()
  print(bWriteLog and "SwitchThrowUI:BindWeaponChangeDelegate")
  if self.TimerForBindWeaponChangeDelegate then
    self:RemoveGameTimer(self.TimerForBindWeaponChangeDelegate)
    self.TimerForBindWeaponChangeDelegate = nil
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "SwitchThrowUI:BindWeaponChangeDelegate not slua.isValid(PlayerCharacter)")
    self.TimerForBindWeaponChangeDelegate = self:AddGameTimer(0.5, false, function()
      print(bWriteLog and "SwitchThrowUI:BindWeaponChangeDelegate Loop1")
      self.TimerForBindWeaponChangeDelegate = nil
      self:BindWeaponChangeDelegate()
    end)
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    self.TimerForBindWeaponChangeDelegate = self:AddGameTimer(0.5, false, function()
      print(bWriteLog and "SwitchThrowUI:BindWeaponChangeDelegate Loop2")
      self.TimerForBindWeaponChangeDelegate = nil
      self:BindWeaponChangeDelegate()
    end)
    return
  end
  self:AddControlEventByControl(WeaponManager, "ChangeCurrentUsingWeaponDelegate", self.HandleWeaponChange, self)
  local CurrentUsingSlot = WeaponManager:GetCurrentUsingPropSlot()
  self:HandleWeaponChange(CurrentUsingSlot)
end
function SwitchThrowUI:OnPlayerCharacterChange(_, PlayerCharacter)
  print(bWriteLog and "SwitchThrowUI:OnPlayerCharacterChange")
  self:BindWeaponChangeDelegate()
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CSwitchThrowUI = class(ui_base, nil, SwitchThrowUI)
return CSwitchThrowUI