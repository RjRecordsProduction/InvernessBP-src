local EPawnState = import("EPawnState")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local EWeaponChangeInvenroryDataType = import("EWeaponChangeInvenroryDataType")
local ShootingUIPanelIMP = require("GameLua.Mod.BaseMod.Client.ShootingUI.ShootingUIPanelIMP")
local BackpackUtils = import("BackpackUtils")
local FBattleItemUseTarget = import("BattleItemUseTarget")
local EBattleItemUseReason = import("EBattleItemUseReason")
local ShowHideUIFlag = require("GameLua.Mod.BaseMod.Client.Config.ShowHideUIFlag")
local MelleeWeaponList = {
  108001,
  108004,
  108005
}
function ShootingUIPanelIMP:WeaponSlot_ctor()
  self.TimerBindPickupUpdateBullet = nil
  self.TimerHandleChangeInventoryData = nil
  self.TimerForBindWeaponChangeDelegate = nil
  self.bHaveRegisterHandlePickupUpdateBulletEvent = false
  self.ModWeaponUI = {}
end
function ShootingUIPanelIMP:RegistEvents_WeaponSlot()
  print(bWriteLog and "ShootingUIPanelUIBase:RegistEvents_WeaponSlot")
  self:AddUIMessageEvent("UIMsg_WeaponEquipAttachment", self.UIMsg_WeaponEquipAttachment, self)
end
function ShootingUIPanelIMP:BLETakeOrCollapseWeapon1()
  self:SimulateUseWeapon(ESurviveWeaponPropSlot.SWPS_MainShootWeapon1)
end
function ShootingUIPanelIMP:BLETakeOrCollapseWeapon2()
  self:SimulateUseWeapon(ESurviveWeaponPropSlot.SWPS_MainShootWeapon2)
end
function ShootingUIPanelIMP:BLETakeOrCollapsePistol()
  self:SimulateUseWeapon(ESurviveWeaponPropSlot.SWPS_SubShootWeapon)
end
function ShootingUIPanelIMP:SimulateUseWeapon(WeaponSlot)
  self:HandleTopRightWeaponSwitch(WeaponSlot)
end
function ShootingUIPanelIMP:ShowLongGunFireMode(bShow)
  print(bWriteLog and "ShootingUIPanelUIBase:ShowLongGunFireMode")
  self.FirWeaponSlot:UpdateFireModeShape(bShow)
  self.SecWeaponSlot:UpdateFireModeShape(bShow)
end
function ShootingUIPanelIMP:BindPickupUpdateBullet()
  print(bWriteLog and "ShootingUIPanelUIBase:BindPickupUpdateBullet")
  if self.TimerBindPickupUpdateBullet then
    self:RemoveGameTimer(self.TimerBindPickupUpdateBullet)
    self.TimerBindPickupUpdateBullet = nil
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "ShootingUIPanelUIBase:BindPickupUpdateBullet not uPlayerController")
    self.TimerBindPickupUpdateBullet = self:AddGameTimer(0.5, false, function()
      print(bWriteLog and "ShootingUIPanelUIBase:BindPickupUpdateBullet Loop")
      self.TimerBindPickupUpdateBullet = nil
      self:BindPickupUpdateBullet()
    end)
    return
  end
  local BackpackComp = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(PlayerController)
  if not slua.isValid(BackpackComp) then
    print(bWriteLog and "ShootingUIPanelUIBase:BindPickupUpdateBullet not uBackpackComp")
    self.TimerBindPickupUpdateBullet = self:AddGameTimer(0.5, false, function()
      print(bWriteLog and "ShootingUIPanelUIBase:BindPickupUpdateBullet Loop")
      self.TimerBindPickupUpdateBullet = nil
      self:BindPickupUpdateBullet()
    end)
    return
  end
  if self.bHaveRegisterHandlePickupUpdateBulletEvent then
    self:RemoveCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_SINGLE_ITEM_UPDATED_AMMO_3)
    self.bHaveRegisterHandlePickupUpdateBulletEvent = false
  end
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_SINGLE_ITEM_UPDATED_AMMO_3, self.HandlePickupUpdateBullet, self)
  self.bHaveRegisterHandlePickupUpdateBulletEvent = true
end
function ShootingUIPanelIMP:HandlePickupUpdateBullet(_, _, uBackpackComponent, DefineID, bUpdateOrDelete)
  self:UpdateWeaponBulletCount()
end
function ShootingUIPanelIMP:HandleChangeInventoryData(TargetChangeSlot, EChangeType)
  print(bWriteLog and "ShootingUIPanelUIBase:HandleChangeInventoryData")
  self:UpdateTopRightWeaponBulletWhenEquipAndUnequip(TargetChangeSlot, EChangeType)
  self:UpdateInventoryDataByTimer()
  self:NextUseWeaponChangedDelegate_Handle()
end
function ShootingUIPanelIMP:UpdateInventoryDataByTimer()
  if self.TimerHandleChangeInventoryData then
    self:RemoveGameTimer(self.TimerHandleChangeInventoryData)
    self.TimerHandleChangeInventoryData = nil
  end
  self.TimerHandleChangeInventoryData = self:AddGameTimer(0.1, false, function()
    self.TimerHandleChangeInventoryData = nil
    self:UpdateWeaponBulletCount()
    self:UpdateGunImage()
  end)
end
function ShootingUIPanelIMP:ClickOnSwitchWeapon(Slot)
  print(bWriteLog and "ShootingUIPanelUIBase:ClickOnSwitchWeapon " .. tostring(Slot))
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ShootingUIPanelUIBase:ClickOnSwitchWeapon not uPlayerCharacter")
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    print(bWriteLog and "ShootingUIPanelUIBase:ClickOnSwitchWeapon not WeaponManager")
    return
  end
  local Weapon = WeaponManager:GetInventoryWeaponByPropSlot(Slot)
  if Weapon then
    self:HandleTopRightWeaponSwitch(Slot)
  elseif Slot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 or ESurviveWeaponPropSlot.SWPS_MainShootWeapon2 then
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
    if MainControlPanelTochButton then
      MainControlPanelTochButton:SendQuickNeedText(23)
    end
  end
end
function ShootingUIPanelIMP:BindWeaponChangeDelegate()
  self:_BindWeaponChangeDelegateInternal()
end
function ShootingUIPanelIMP:_BindWeaponChangeDelegateInternal()
  print(bWriteLog and "ShootingUIPanelUIBase:BindWeaponChangeDelegate")
  if self.TimerForBindWeaponChangeDelegate then
    self:RemoveGameTimer(self.TimerForBindWeaponChangeDelegate)
    self.TimerForBindWeaponChangeDelegate = nil
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ShootingUIPanelUIBase:BindWeaponChangeDelegate not uPlayerCharacter")
    self.TimerForBindWeaponChangeDelegate = self:AddGameTimer(0.5, false, function()
      print(bWriteLog and "ShootingUIPanelUIBase:BindWeaponChangeDelegate Loop1")
      self.TimerForBindWeaponChangeDelegate = nil
      self:BindWeaponChangeDelegate()
    end)
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    self.TimerForBindWeaponChangeDelegate = self:AddGameTimer(0.5, false, function()
      print(bWriteLog and "ShootingUIPanelUIBase:BindWeaponChangeDelegate Loop2")
      self.TimerForBindWeaponChangeDelegate = nil
      self:BindWeaponChangeDelegate()
    end)
    return
  end
  self.  self:AddControlEventByControl(WeaponManager, "ChangeCurrentUsingWeaponDelegate", self.WeaponChange, self)
  self:AddControlEventByControl(WeaponManager, "ChangeInventoryDataDelegate", self.HandleChangeInventoryData, self)
  self:AddControlEventByControl(WeaponManager, "NextUseWeaponChangedDelegate", self.NextUseWeaponChangedDelegate_Handle, self)
  self.WeaponManager.bUIHasBoundDelegate = true
  local CurrentUsingSlot = WeaponManager:GetCurrentUsingPropSlot()
  self:WeaponChange(CurrentUsingSlot)
  self:HandleChangeInventoryData(ESurviveWeaponPropSlot.SWPS_MainShootWeapon1, EWeaponChangeInvenroryDataType.EWCIDT_Init)
  self:HandleChangeInventoryData(ESurviveWeaponPropSlot.SWPS_MainShootWeapon2, EWeaponChangeInvenroryDataType.EWCIDT_Init)
  self:HandleChangeInventoryData(ESurviveWeaponPropSlot.SWPS_SubShootWeapon, EWeaponChangeInvenroryDataType.EWCIDT_Init)
  self:HandleChangeInventoryData(ESurviveWeaponPropSlot.SWPS_MeleeWeapon, EWeaponChangeInvenroryDataType.EWCIDT_Init)
  self:HandleChangeInventoryData(ESurviveWeaponPropSlot.SWPS_HandProp, EWeaponChangeInvenroryDataType.EWCIDT_Init)
  self:NextUseWeaponChangedDelegate_Handle()
end
function ShootingUIPanelIMP:WeaponChange(TargetChangeSlot)
  self:HandleWeaponChange(TargetChangeSlot)
  local CurrentWeaponManager = self.WeaponManager
  if not slua.isValid(self.WeaponManager) then
    local PlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(PlayerCharacter) then
      local WeaponManager = PlayerCharacter:GetWeaponManager()
      if slua.isValid(WeaponManager) then
        self.        Current      end
    end
  end
  if slua.isValid(CurrentWeaponManager) and self.ReleaseFireWeaponCache ~= CurrentWeaponManager:GetCurrentUsingWeapon() then
    self:ResetCancelFireBtn()
  end
  EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_PLAYEREVENT_WEAPON_SWITCHWEAPON_FINISHED)
  self:UpdateWeaponBulletCount()
end
function ShootingUIPanelIMP:UIMsg_WeaponEquipAttachment()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  self:ShowWeaponEquipAttachmentAnim(PlayerController.AttachmentAttachSlot, PlayerController.AttachmentDefineID, true)
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    local ESTEScopeType = import("ESTEScopeType")
    PlayerCharacter:ScopeOut(ESTEScopeType.Normal)
  end
end
function ShootingUIPanelIMP:UpdateTopRightWeapnIcon(Slot, ImagePath)
  print(bWriteLog and "ShootingUIPanelUIBase:UpdateTopRightWeapnIcon")
  if Slot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 then
    self.FirWeaponSlot:ChangeWeaponImage(ImagePath)
  elseif Slot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon2 then
    self.SecWeaponSlot:ChangeWeaponImage(ImagePath)
  elseif Slot == ESurviveWeaponPropSlot.SWPS_SubShootWeapon then
    self.PistolModeUI:ChangeWeaponImage(ImagePath)
  end
end
function ShootingUIPanelIMP:NextUseWeaponChangedDelegate_Event()
  self:NextUseWeaponChangedDelegate_Handle()
end
function ShootingUIPanelIMP:NextUseWeaponChangedDelegate_Handle()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ShootingUIPanelUIBase:NextUseWeaponChangedDelegate_Handle not slua.isValid(uPlayerCharacter)")
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    print(bWriteLog and "ShootingUIPanelUIBase:NextUseWeaponChangedDelegate_Handle not slua.isValid(WeaponManager)")
    return
  end
  local bIsSwim = PlayerCharacter:HasState(EPawnState.Swim)
  self:ResetNextUseWeaponSlot(WeaponManager)
  if bIsSwim then
    local NextWeaponSlot = WeaponManager:GetNextUseWeaponSlot()
    self:SetNextUseWeaponBorder(NextWeaponSlot)
    print(bWriteLog and "SetNextUseWeapon_Debug_Msg: eNextWeaponSlot == " .. NextWeaponSlot)
  end
end
function ShootingUIPanelIMP:ResetNextUseWeaponSlot(WeaponManager)
  print(bWriteLog and "ShootingUIPanelUIBase:ResetNextUseWeaponSlot")
  if not (self.PistolModeUI and self.FirWeaponSlot) or not self.SecWeaponSlot then
    return
  end
  if not (slua.isValid(self.PistolModeUI.UIRoot) and slua.isValid(self.FirWeaponSlot.UIRoot)) or not slua.isValid(self.SecWeaponSlot.UIRoot) then
    return
  end
  local CurrentUseWeaponSlot = WeaponManager:GetCurrentUsingPropSlot()
  if CurrentUseWeaponSlot ~= ESurviveWeaponPropSlot.SWPS_SubShootWeapon then
    self.PistolModeUI.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  end
  self.FirWeaponSlot:SetNextSelect(false)
  self.SecWeaponSlot:SetNextSelect(false)
  self.PistolModeUI.UIRoot.Weapon_select:SetOpacity(1)
end
function ShootingUIPanelIMP:SetNextUseWeaponBorder(NextWeaponSlot)
  print(bWriteLog and "ShootingUIPanelUIBase:SetNextUseWeaponBorder")
  if not (slua.isValid(self.PistolModeUI.UIRoot) and slua.isValid(self.FirWeaponSlot.UIRoot)) or not slua.isValid(self.SecWeaponSlot.UIRoot) then
    return
  end
  if NextWeaponSlot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 then
    self.FirWeaponSlot:SetNextSelect(true)
    self.PistolModeUI.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    print(bWriteLog and "SetNextUseWeapon_Debug_Msg: \228\184\187\230\173\166\229\153\1681\233\154\144\230\128\167\230\140\129\230\158\170 ")
  elseif NextWeaponSlot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon2 then
    self.SecWeaponSlot:SetNextSelect(true)
    self.PistolModeUI.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    print(bWriteLog and "SetNextUseWeapon_Debug_Msg: \228\184\187\230\173\166\229\153\1682\233\154\144\230\128\167\230\140\129\230\158\170 ")
  elseif NextWeaponSlot == ESurviveWeaponPropSlot.SWPS_SubShootWeapon then
    self.PistolModeUI.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    self.PistolModeUI.UIRoot.Weapon_select:SetOpacity(0.45)
    self.PistolModeUI.UIRoot.Button_ChangeShootingType:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    print(bWriteLog and "SetNextUseWeapon_Debug_Msg: \229\137\175\230\173\166\229\153\168\233\154\144\230\128\167\230\140\129\230\158\170 ")
  end
end
function ShootingUIPanelIMP:HandleTopRightWeaponSwitch(WeaponSlot)
  print(bWriteLog and "ShootingUIPanelUIBase:HandleTopRightWeaponSwitch WeaponSlot=" .. tostring(WeaponSlot))
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ShootingUIPanelUIBase:HandleTopRightWeaponSwitch not slua.isValid(uPlayerCharacter)")
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    print(bWriteLog and "ShootingUIPanelUIBase:HandleTopRightWeaponSwitch not slua.isValid(WeaponManager)")
    return
  end
  local Weapon = WeaponManager:GetInventoryWeaponByPropSlot(WeaponSlot)
  if not self:IsCanSwitchTargetWeapon(Weapon) then
    self:ShowTips(733003)
    return
  end
  if not WeaponManager.bIsSwitching and WeaponManager:GetCurrentUsingPropSlot() == WeaponSlot then
    if PlayerController.bAutoEquipMelleeWeapon then
      local CurMelleWeapon = WeaponManager:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlot.SWPS_MeleeWeapon)
      if slua.isValid(CurMelleWeapon) then
        PlayerCharacter:SwitchWeaponBySlot(ESurviveWeaponPropSlot.SWPS_MeleeWeapon, true, false, false)
      else
        local MelleeItemCount = 0
        local bHasMelleeItem = false
        if PlayerController.GetBackpackComponent then
          local uBackPackComp = PlayerController:GetBackpackComponent()
          if slua.isValid(uBackPackComp) then
            for index, MelleeWeaponListId in ipairs(MelleeWeaponList) do
              MelleeItemCount = uBackPackComp:GetItemCountByItemSpecialID(MelleeWeaponListId)
              if 0 < MelleeItemCount then
                local ItemHandle = uBackPackComp:GetFirstItemByDefineIDIgnoreInstance(BackpackUtils.GetItemDefineIDByItemID(MelleeWeaponListId))
                if ItemHandle.DefineID.bValidInstance then
                  local BattleItemUseTarget = FBattleItemUseTarget()
                  PlayerController:ServerUseItem(ItemHandle.DefineID, BattleItemUseTarget, EBattleItemUseReason.Manually)
                  bHasMelleeItem = true
                end
                break
              end
            end
          end
        end
        if not bHasMelleeItem then
          PlayerCharacter:SwitchWeaponBySlot(ESurviveWeaponPropSlot.SWPS_None, true, false, false)
        end
      end
    else
      PlayerCharacter:SwitchWeaponBySlot(ESurviveWeaponPropSlot.SWPS_None, true, false, false)
    end
    print(bWriteLog and "ShootingUIPanelUIBase:HandleTopRightWeaponSwitch To Empty")
  else
    local SwitchWeaponAuxLib = require("GameLua.Mod.BaseMod.Client.MainControlUI.SwitchWeaponAuxLib")
    SwitchWeaponAuxLib.SwitchWeaponBySlot(PlayerCharacter, WeaponSlot, true, false, false)
    print(bWriteLog and "ShootingUIPanelUIBase:HandleTopRightWeaponSwitch To CurWeapon")
    self:TryCancelGrenadeAndSwitchWeapon(WeaponSlot)
  end
end
function ShootingUIPanelIMP:UpdateTopRightWeaponBulletWhenEquipAndUnequip(WeaponSlot, ChangeType)
  print(bWriteLog and "ShootingUIPanelUIBase:UpdateTopRightWeaponBulletWhenEquipAndUnequip")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ShootingUIPanelUIBase:UpdateTopRightWeaponBulletWhenEquipAndUnequip not uPlayerCharacter")
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    print(bWriteLog and "ShootingUIPanelUIBase:UpdateTopRightWeaponBulletWhenEquipAndUnequip not uWeaponManager")
    return
  end
  local Weapon = WeaponManager:GetInventoryWeaponByPropSlot(WeaponSlot)
  if slua.isValid(Weapon) then
    local ASTExtraShootWeapon = import("STExtraShootWeapon")
    if Game:IsClassOf(Weapon, ASTExtraShootWeapon) then
      if WeaponSlot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 then
        self:ChangeSlotWeapon(self.FirWeaponSlot.UIRoot, Weapon, ChangeType)
      elseif WeaponSlot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon2 then
        self:ChangeSlotWeapon(self.SecWeaponSlot.UIRoot, Weapon, ChangeType)
      elseif WeaponSlot == ESurviveWeaponPropSlot.SWPS_SubShootWeapon then
        self.PistolModeUI:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self.PistolModeUI:UpdatePistol()
        self.FirWeaponSlot:UpdateFireModeShape(true)
        self.SecWeaponSlot:UpdateFireModeShape(true)
      end
    end
  elseif WeaponSlot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 then
    self:HandleUnequipWeapon(self.FirWeaponSlot.UIRoot, ChangeType)
  elseif WeaponSlot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon2 then
    self:HandleUnequipWeapon(self.SecWeaponSlot.UIRoot, ChangeType)
  elseif WeaponSlot == ESurviveWeaponPropSlot.SWPS_SubShootWeapon then
    self.PistolModeUI:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.PistolModeUI:UpdatePistol()
    self.FirWeaponSlot:UpdateFireModeShape(true)
    self.SecWeaponSlot:UpdateFireModeShape(true)
  end
  self:UpdateModWeaponUI(WeaponSlot, 0)
end
function ShootingUIPanelIMP:ChangeSlotWeapon(WeaponSlotWidget, Weapon, ChangeType)
  print(bWriteLog and "ShootingUIPanelUIBase:ChangeSlotWeapon 0")
  if not WeaponSlotWidget then
    print(bWriteLog and "ShootingUIPanelUIBase:ChangeSlotWeapon 1")
    return
  end
  WeaponSlotWidget:ChangeSlotWeapon(Weapon)
  WeaponSlotWidget.TextBlock_CurrentNumberOfBullets:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  WeaponSlotWidget.TextBlock_1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  WeaponSlotWidget.TextBlock_MaxNumberOfBullets:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local bCanRecordHitDetail = Weapon:GetCanRecordHitDetailFromEntity()
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local SurviveInfoPanel = InGameUITools.GetSurviveInfoPanel()
  if not SurviveInfoPanel then
    return
  end
  if ChangeType == EWeaponChangeInvenroryDataType.EWCIDT_Init or ChangeType == EWeaponChangeInvenroryDataType.EWCIDT_PickUp then
    if bCanRecordHitDetail then
      SurviveInfoPanel:UIMsg_HandleEquipCanRecordHitInfoGun(WeaponSlotWidget.WeaponSlotType)
    else
      SurviveInfoPanel:UIMsg_HandleUnEquipCanRecordHitInfoGun(WeaponSlotWidget.WeaponSlotType)
    end
  elseif ChangeType == EWeaponChangeInvenroryDataType.EWCIDT_Swap then
    SurviveInfoPanel:UIMsg_HandleEquipChangeSwap(WeaponSlotWidget.WeaponSlotType, bCanRecordHitDetail)
  end
end
function ShootingUIPanelIMP:HandleUnequipWeapon(WeaponSlotWidget, ChangeType)
  print(bWriteLog and "ShootingUIPanelUIBase:HandleUnequipWeapon 0")
  if not WeaponSlotWidget then
    print(bWriteLog and "ShootingUIPanelUIBase:HandleUnequipWeapon 1")
    return
  end
  WeaponSlotWidget.TextBlock_CurrentNumberOfBullets:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  WeaponSlotWidget.TextBlock_1:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  WeaponSlotWidget.TextBlock_MaxNumberOfBullets:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  WeaponSlotWidget:Show_HideFireMode(false, nil)
  WeaponSlotWidget:SetBorderOpacity(0.5)
  WeaponSlotWidget:ClearWeaponSlotData()
  self.PistolModeUI:ShowOrHideFireMode(false)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local SurviveInfoPanel = InGameUITools.GetSurviveInfoPanel()
  if not SurviveInfoPanel then
    return
  end
  if ChangeType == EWeaponChangeInvenroryDataType.EWCIDT_PutDown then
    SurviveInfoPanel:UIMsg_HandleUnEquipCanRecordHitInfoGun(WeaponSlotWidget.WeaponSlotType)
  elseif ChangeType == EWeaponChangeInvenroryDataType.EWCIDT_Swap then
    SurviveInfoPanel:UIMsg_HandleEquipChangeSwap(WeaponSlotWidget.WeaponSlotType, false)
  end
end
function ShootingUIPanelIMP:IsCanSwitchTargetWeapon(Weapon)
  print(bWriteLog and "ShootingUIPanelUIBase:IsCanSwitchTargetWeapon")
  if not slua.isValid(Weapon) or not slua.isValid(Weapon.WeaponEntityComp) then
    print(bWriteLog and "ShootingUIPanelUIBase:IsCanSwitchTargetWeapon not slua.isValid(Weapon)")
    return true
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ShootingUIPanelUIBase:IsCanSwitchTargetWeapon not slua.isValid(uPlayerCharacter)")
    return false
  end
  return Weapon.WeaponEntityComp.bEnableProneHolding or not PlayerCharacter:HasState(EPawnState.Prone)
end
function ShootingUIPanelIMP:UpdateWeaponBulletOnShoot()
  self:AddGameTimer(0.01, false, function()
    print(bWriteLog and "ShootingUIPanelUIBase:UpdateWeaponBulletOnShoot")
    local PlayerCharacter = GameplayData.GetPlayerCharacter()
    if not slua.isValid(PlayerCharacter) then
      print(bWriteLog and "ShootingUIPanelUIBase:UpdateWeaponBulletOnShoot not uPlayerCharacter")
      return
    end
    local WeaponManager = PlayerCharacter:GetWeaponManager()
    self.    if not slua.isValid(WeaponManager) then
      print(bWriteLog and "ShootingUIPanelUIBase:UpdateWeaponBulletOnShoot not WeaponManager")
      return
    end
    local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
    if not OperateSubsystem then
      return
    end
    local CurUsingWeaponSlot = OperateSubsystem:GetCurrentUsingPropSlot()
    local Weapon = WeaponManager:GetInventoryWeaponByPropSlot(CurUsingWeaponSlot)
    if not slua.isValid(Weapon) then
      return
    end
    if Weapon.bShootWeapon then
      if CurUsingWeaponSlot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 then
        self.FirWeaponSlot:UpdateBulletByWeapon(Weapon, false)
        self.FirWeaponSlot:UpdateWeaponDurabilityAnimation()
      elseif CurUsingWeaponSlot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon2 then
        self.SecWeaponSlot:UpdateBulletByWeapon(Weapon, false)
        self.SecWeaponSlot:UpdateWeaponDurabilityAnimation()
      elseif CurUsingWeaponSlot == ESurviveWeaponPropSlot.SWPS_SubShootWeapon then
        self.PistolModeUI:UpdateBulletCounts(Weapon:GetCurrentBulletNumInClip(0), -1, Weapon:GetBulletTypeFromEntity())
        self.PistolModeUI:UpdateWeaponDurabilityAnimation()
      end
    end
  end)
end
function ShootingUIPanelIMP:UpdateWeaponBulletCount()
  print(bWriteLog and "ShootingUIPanelUIBase:UpdateWeaponBulletCount")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ShootingUIPanelUIBase:UpdateWeaponBulletCount not uPlayerPawn")
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    print(bWriteLog and "ShootingUIPanelUIBase:UpdateWeaponBulletCount not uWeaponManager")
    return
  end
  if not self.UIRoot then
    return
  end
  self.  local ASTExtraShootWeapon = import("STExtraShootWeapon")
  local ShootWeapon1 = WeaponManager:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlot.SWPS_MainShootWeapon1)
  if Game:IsClassOf(ShootWeapon1, ASTExtraShootWeapon) then
    self.FirWeaponSlot:UpdateBulletByWeapon(ShootWeapon1, true)
  end
  local ShootWeapon2 = WeaponManager:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlot.SWPS_MainShootWeapon2)
  if Game:IsClassOf(ShootWeapon2, ASTExtraShootWeapon) then
    self.SecWeaponSlot:UpdateBulletByWeapon(ShootWeapon2, true)
  end
  local ShootWeaponSub = WeaponManager:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlot.SWPS_SubShootWeapon)
  if Game:IsClassOf(ShootWeaponSub, ASTExtraShootWeapon) then
    local PlayerController = GameplayData.GetPlayerController()
    if not slua.isValid(PlayerController) then
      print(bWriteLog and "ShootingUIPanelUIBase:UpdateWeaponBulletCount not uPlayerController")
      return
    end
    local BackpackComp = PlayerController.GetBackpackComponent and PlayerController:GetBackpackComponent() or nil
    if not slua.isValid(BackpackComp) then
      print(bWriteLog and "ShootingUIPanelUIBase:UpdateWeaponBulletCount not uBackpackComp")
      return
    end
    local WeaponEntity = ShootWeaponSub.WeaponEntityComp
    if WeaponEntity.BulletType then
      local UAvatarUtils = import("AvatarUtils")
      local BulletInBackpack = UAvatarUtils.GetAvailableBulletsNumInBackpackByDefineID(BackpackComp, WeaponEntity.BulletType)
      self.PistolModeUI:UpdateBulletCounts(ShootWeaponSub:GetCurrentBulletNumInClip(0), BulletInBackpack, WeaponEntity.BulletType)
    end
  end
end
function ShootingUIPanelIMP:UpdateGunImage()
  print(bWriteLog and "ShootingUIPanelUIBase:UpdateGunImage")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ShootingUIPanelUIBase:UpdateGunImage not PlayerCharacter")
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    print(bWriteLog and "ShootingUIPanelUIBase:UpdateGunImage not uWeaponManager")
    return
  end
  self.  local ASTExtraShootWeapon = import("STExtraShootWeapon")
  local ShootWeapon1 = WeaponManager:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlot.SWPS_MainShootWeapon1)
  if Game:IsClassOf(ShootWeapon1, ASTExtraShootWeapon) then
    self:UpdateWeaponImageByDefineID(ESurviveWeaponPropSlot.SWPS_MainShootWeapon1, ShootWeapon1:GetItemDefineID())
  end
  local ShootWeapon2 = WeaponManager:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlot.SWPS_MainShootWeapon2)
  if Game:IsClassOf(ShootWeapon2, ASTExtraShootWeapon) then
    self:UpdateWeaponImageByDefineID(ESurviveWeaponPropSlot.SWPS_MainShootWeapon2, ShootWeapon2:GetItemDefineID())
  end
  local ShootWeaponSub = WeaponManager:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlot.SWPS_SubShootWeapon)
  if Game:IsClassOf(ShootWeaponSub, ASTExtraShootWeapon) then
    self.PistolModeUI:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:UpdateWeaponImageByDefineID(ESurviveWeaponPropSlot.SWPS_SubShootWeapon, ShootWeaponSub:GetItemDefineID())
  else
    self.PistolModeUI:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function ShootingUIPanelIMP:UpdateWeaponImageByDefineID(Slot, DefineID)
  print(bWriteLog and "ShootingUIPanelUIBase:UpdateWeaponImageByDefineID")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ShootingUIPanelUIBase:UpdateWeaponImageByDefineID not uPlayerCharacter")
    return
  end
  local TargetImageID = DefineID.TypeSpecificID
  local Weapon = PlayerCharacter:GetShootWeaponBySlot(Slot)
  if slua.isValid(Weapon) and Weapon.IsUsingGrenadeLaunch and Weapon:IsUsingGrenadeLaunch() then
    TargetImageID = 202100
  end
  local ItemCfg = CDataTable.GetTableData("Item", TargetImageID)
  if ItemCfg then
    local ItemWhiteIcon = ItemCfg.ItemWhiteIcon
    self:UpdateTopRightWeapnIcon(Slot, ItemWhiteIcon)
  else
    print(bWriteLog and "ShootingUIPanelUIBase:UpdateWeaponImageByDefineID No ItemCfg ItemID=" .. tostring(TargetImageID))
  end
  self:UpdateModWeaponUI(Slot, DefineID.TypeSpecificID)
end
function ShootingUIPanelIMP:Close_WeaponSlot()
  for ItemID, ModWeapon in pairs(self.ModWeaponUI) do
    local WeaponUI = self.ModWeaponUI[ItemID]
    for Slot, SlotUI in pairs(WeaponUI) do
      if SlotUI.ModWeaponIcon then
        SlotUI.ModWeaponIcon:Close()
        SlotUI.ModWeaponIcon = nil
      end
      if SlotUI.ModWeaponLabel then
        SlotUI.ModWeaponLabel:Close()
        SlotUI.ModWeaponLabel = nil
      end
      if SlotUI.ModWeaponReload then
        SlotUI.ModWeaponReload:Close()
        SlotUI.ModWeaponReload = nil
      end
    end
  end
  self.ModWeaponUI = nil
end
function ShootingUIPanelIMP:TryCancelGrenadeAndSwitchWeapon(WeaponSlot)
  print(bWriteLog and "[Grenade] ShootingUIPanelUIBase:TryCancelGrenadeAndSwitchWeapon", WeaponSlot)
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "[Grenade] ShootingUIPanelUIBase:TryCancelGrenadeAndSwitchWeapon, PlayerCharacter invalid")
    return
  end
  if not PlayerCharacter:HasState(EPawnState.HoldGrenade) then
    return
  end
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:CancelThrow()
  end
  self.PendingSwitch  self:AddControlEventByControl(PlayerCharacter, "OnClientStatesChange", self.OnClientStatesChange, self)
end
function ShootingUIPanelIMP:OnClientStatesChange(CurrentStates, PrevStates)
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "[Grenade] ShootingUIPanelUIBase:OnClientStatesChange, PlayerCharacter invalid")
    return
  end
  if PlayerCharacter:HasState(EPawnState.HoldGrenade) then
    return
  end
  print(bWriteLog and "[Grenade] ShootingUIPanelUIBase:OnClientStatesChange leave HoldGrenade, Slot: ", self.PendingSwitchWeaponSlot)
  self:RemoveControlEventByControl(PlayerCharacter, "OnClientStatesChange")
  if self.PendingSwitchWeaponSlot then
    self:HandleTopRightWeaponSwitch(self.PendingSwitchWeaponSlot)
    self.PendingSwitchWeaponSlot = nil
  end
end
function ShootingUIPanelIMP:UpdateModWeaponUI(Slot, ItemID)
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ShootingUIPanelUIBase:UpdateModWeaponUI, PlayerCharacter invalid")
    return
  end
  local WeaponSlot = self.FirWeaponSlot
  local ModWeaponUI, ModWeaponLabel
  if Slot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 then
    WeaponSlot = self.FirWeaponSlot
  elseif Slot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon2 then
    WeaponSlot = self.SecWeaponSlot
  elseif Slot == ESurviveWeaponPropSlot.SWPS_SubShootWeapon then
    return
  end
  if not WeaponSlot.UIRoot then
    print(bWriteLog and string.format("ShootingUIPanelIMP:UpdateModWeaponUI - Slot: %s WeaponSlot.UIRoot is nil", tostring(Slot)))
    return
  end
  for WeaponID, ModWeapon in pairs(self.ModWeaponUI) do
    local WeaponUI = self.ModWeaponUI[WeaponID]
    if WeaponUI[Slot] and ItemID ~= WeaponID then
      local SlotUI = WeaponUI[Slot]
      if SlotUI.ModWeaponIcon then
        SlotUI.ModWeaponIcon:Close()
        SlotUI.ModWeaponIcon = nil
      end
      if SlotUI.ModWeaponLabel then
        SlotUI.ModWeaponLabel:Close()
        SlotUI.ModWeaponLabel = nil
      end
      if SlotUI.ModWeaponReload then
        SlotUI.ModWeaponReload:Close()
        SlotUI.ModWeaponReload = nil
      end
    end
  end
  local Weapon = PlayerCharacter:GetShootWeaponBySlot(Slot)
  local ModWeaponConfig = GamePlayTools.GetCurrentConfig("ModWeaponConfig")
  if ModWeaponConfig and ModWeaponConfig[ItemID] and (ModWeaponConfig[ItemID].LabelUIConfig or ModWeaponConfig[ItemID].WeaponSlotUI or ModWeaponConfig[ItemID].ReloadUIConfig) then
    local WeaponConfig = ModWeaponConfig[ItemID]
    if not self.ModWeaponUI[ItemID] or not self.ModWeaponUI[ItemID][Slot] then
      self.ModWeaponUI[ItemID] = {
        [ESurviveWeaponPropSlot.SWPS_MainShootWeapon1] = {
          ModWeaponIcon = nil,
          ModWeaponLabel = nil,
          ModWeaponReload = nil
        },
        [ESurviveWeaponPropSlot.SWPS_MainShootWeapon2] = {
          ModWeaponIcon = nil,
          ModWeaponLabel = nil,
          ModWeaponReload = nil
        }
      }
    end
    local ModWeapon = self.ModWeaponUI[ItemID][Slot]
    ModWeaponUI = ModWeapon.ModWeaponIcon
    ModWeaponLabel = ModWeapon.ModWeaponLabel
    local ModWeaponReloadUI = ModWeapon.ModWeaponReload
    if ModWeaponLabel then
      ModWeaponLabel:SelfHitTestInvisible()
    else
      local LabelUIConfig = WeaponConfig.LabelUIConfig
      local ModLabelCanvas = WeaponSlot.UIRoot.CanvasPanel_UIEffect
      if LabelUIConfig and ModLabelCanvas then
        local LabelConfig = UIManager.UI_Config_InGame[LabelUIConfig]
        if LabelConfig then
          ModWeaponLabel = self:CreateChildWindow(ModLabelCanvas, LabelConfig, 1)
          self.ModWeaponUI[ItemID][Slot].        end
        if ModLabelCanvas.Slot and ModLabelCanvas.Slot.SetZOrder then
          ModLabelCanvas.Slot:SetZOrder(1)
        end
      end
    end
    if ModWeaponReloadUI then
      ModWeaponReloadUI:SelfHitTestInvisible()
    else
      local ReloadUIConfig = WeaponConfig.ReloadUIConfig
      local ModReloadCanvas = WeaponSlot.UIRoot.CanvasPanel_M1_1
      if ReloadUIConfig and ModReloadCanvas then
        local ReloadConfig = UIManager.UI_Config_InGame[ReloadUIConfig]
        if ReloadConfig then
          ModWeaponReloadUI = self:CreateChildWindow(ModReloadCanvas, ReloadConfig)
          self.ModWeaponUI[ItemID][Slot].ModWeaponReload = ModWeaponReloadUI
        end
        if ModReloadCanvas.Slot and ModReloadCanvas.Slot.SetZOrder then
          ModReloadCanvas.Slot:SetZOrder(1)
        end
        if ModWeaponReloadUI.UpdateCurrentWeapon then
          ModWeaponReloadUI:UpdateCurrentWeapon(Weapon)
        end
      end
    end
    if ModWeaponUI then
      ModWeaponUI:SelfHitTestInvisible()
      if not WeaponConfig.bShowWeaponSlotProfileImg then
        WeaponSlot.UIRoot:HideProfileImg()
      end
    else
      local WeaponIconConfig = WeaponConfig.WeaponSlotUI
      local WeaponSlotCanvas = WeaponSlot.UIRoot.CanvasPanel_2
      if WeaponIconConfig and WeaponSlotCanvas then
        local IconConfig = UIManager.UI_Config_InGame[WeaponIconConfig]
        if IconConfig then
          ModWeaponUI = WeaponSlot:CreateChildWindow(WeaponSlotCanvas, IconConfig, WeaponSlot)
          if not ModWeaponUI then
            return
          end
          if not WeaponConfig.bShowWeaponSlotProfileImg then
            WeaponSlot.UIRoot:HideProfileImg()
          end
          self.ModWeaponUI[ItemID][Slot].ModWeaponIcon = ModWeaponUI
          if ModWeaponUI.UpdateCurrentWeapon then
            ModWeaponUI:UpdateCurrentWeapon(Weapon)
          end
        end
      end
    end
  elseif ItemID ~= 0 then
    WeaponSlot.UIRoot:ShowProfileImg()
  end
end