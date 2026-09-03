local CircleChooseUtil = {
  MeleeCache = {
    [812146] = false,
    [812147] = false,
    [812148] = false,
    [812149] = false
  },
  GrenadeCache = {},
  Medicine = {
    [1004001] = true
  }
}
local BackpackUtils = import("BackpackUtils")
local UAESkillManagerUtils = import("UAESkillManagerUtils")
local AvatarUtils = import("AvatarUtils")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local FBattleItemUseTarget = import("BattleItemUseTarget")
local EBattleItemUseReason = import("EBattleItemUseReason")
local EBattleItemDisuseReason = import("EBattleItemDisuseReason")
local AvatarDataUtil = require("GameLua.Mod.Library.GamePlay.Avatar.AvatarDataUtil")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local LuaBackpackUtils = require("GameLua.Mod.Library.GamePlay.Backpack.LuaBackpackUtils")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local BackpackConsumableProxy
function CircleChooseUtil.SetBackpackConsumableProxy(InBackpackConsumableProxy)
  BackpackConsumableProxy = InBackpackConsumableProxy
end
function CircleChooseUtil.GetBackpackConsumableProxy()
  return BackpackConsumableProxy
end
function CircleChooseUtil.GetLogicMgrSubsystem()
  local MySubsystem = SubsystemMgr:Get("GrenadesMedsSubsytem")
  if MySubsystem then
    return MySubsystem
  end
  return nil
end
function CircleChooseUtil.GetLogicThemePropSubsystem()
  local MySubsystem = SubsystemMgr:Get("ThemePropsWidgetLogic")
  if MySubsystem then
    return MySubsystem
  end
  return nil
end
function CircleChooseUtil.GetSettingByStrKey(sKey)
  local UIUtil = require("client.common.ui_util")
  local uGameFrontendHUD = UIUtil.GetFirstGameFrontendHUD()
  local uSettingConfig = uGameFrontendHUD:GetUserSettings()
  if slua.isValid(uSettingConfig) then
    local SettingSwitch = uSettingConfig[sKey] or false
    print(bWriteLog and "CircleChooseUtil:GetSettingByStrKey ", sKey, SettingSwitch)
    return SettingSwitch
  end
  print(bWriteLog and "CircleChooseUtil:GetSettingByStrKey Failed to get SettingConfig", sKey)
  return false
end
function CircleChooseUtil.GetAvatarPath(ItemID, bMed, bWithSkin)
  local AvatarID = CircleChooseUtil.GetGrenadeAvatarID(ItemID, bWithSkin)
  if bMed then
    local uIconConfig = UAESkillManagerUtils.GetGrenadeIconConfig(AvatarID)
    return uIconConfig.IconPath
  else
    local AvatarRecord = CDataTable.GetTableData("Item", AvatarID)
    if not AvatarRecord then
      print(bWriteLog and "CircleChooseUtil.GetAvatarPath Failed to Get Path. AvatarRecord is nil", ItemID, AvatarID, bMed)
      return ""
    end
    local AvatarItemIconPath = AvatarRecord.ItemSmallIcon
    if AvatarItemIconPath then
      local ItemPathExist = false
      if Client.IsJaguar() then
        local PufferConst = require("client.slua.logic.download.puffer_const")
        local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
        local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {AvatarID})
        if state == PufferConst.ENUM_DownloadState.Done then
          ItemPathExist = true
        end
      else
        ItemPathExist = true
      end
      if ItemPathExist then
        local isVehicleConsumable
        for _, v in pairs(CDataTable.GetTable("VehicleUseConfig")) do
          if v.Consumable == ItemID then
            isVehicleConsumable = true
            break
          end
        end
        local pak_util = require("client.common.pak_util")
        if isVehicleConsumable and not pak_util.IsFileExist(AvatarItemIconPath) then
          AvatarItemIconPath = "/Game/Arts/UI/NoAtlas/XSuit/XSuit_Icon_Aircraft_03.XSuit_Icon_Aircraft_03"
        end
        return AvatarItemIconPath
      else
        local ItemRecord = CDataTable.GetTableData("Item", ItemID)
        if not ItemRecord then
          return ""
        end
        local ItemSmallIcon = ItemRecord.ItemSmallIcon
        if not ItemSmallIcon then
          return ""
        end
        return ItemSmallIcon
      end
    end
  end
  print(bWriteLog and "CircleChooseUtil.GetAvatarPath Failed to Get Path. ", ItemID, AvatarID, bMed)
  return ""
end
function CircleChooseUtil.GetGrenadeAvatarID(ItemID, bWithSkin)
  if AvatarDataUtil.TryGetGrenadeAvatarID == nil then
    return ItemID
  end
  if not bWithSkin then
    return ItemID
  end
  if 602001 <= ItemID and ItemID <= 602004 then
    local avatarID = AvatarDataUtil.TryGetGrenadeAvatarID(GameplayData.GetPlayerController(), ItemID)
    if avatarID ~= nil and avatarID ~= 0 then
      return avatarID
    else
      return ItemID
    end
  else
    return ItemID
  end
end
function CircleChooseUtil.GetItemCountFromBackpack(TypeSpecificID)
  local playerController = GameplayData.GetPlayerController()
  if not slua.isValid(playerController) then
    return 0
  end
  local BackPackComp = playerController:GetBackpackComponent()
  if not slua.isValid(BackPackComp) then
    print(bWriteLog and "CircleGrenadeItem:GetItemCountFromBackpack Failed, Backpack is nil")
    return 0
  end
  return BackPackComp:GetItemCountByItemSpecialID(TypeSpecificID)
end
function CircleChooseUtil.IsAGrenade(ItemID)
  if not ItemID then
    return false
  end
  if CircleChooseUtil.GrenadeCache[ItemID] ~= nil then
    return CircleChooseUtil.GrenadeCache[ItemID]
  end
  local ItemCfg = CDataTable.GetTableData("Item", ItemID)
  local bResult = ItemCfg and ItemCfg.ItemSubType == 602 or false
  CircleChooseUtil.GrenadeCache[ItemID] = bResult
  return bResult
end
function CircleChooseUtil.SimGrenade(ItemID)
  if not ItemID then
    return false
  end
  local CircleChooseCfg = GamePlayTools.GetCurrentConfig("CircleChooseCfg")
  local SimGrenadeIDs = CircleChooseCfg.SimGrenadeID
  local bSimMelee = SimGrenadeIDs and SimGrenadeIDs[ItemID]
  return CircleChooseUtil.IsAGrenade(ItemID) or bSimMelee
end
function CircleChooseUtil.NeedSwitchToFirst(ItemID)
  if not ItemID then
    return false
  end
  local CircleChooseCfg = GamePlayTools.GetCurrentConfig("CircleChooseCfg")
  local NeedSwitchToFirstList = CircleChooseCfg.NeedSwitchToFirst
  return NeedSwitchToFirstList and NeedSwitchToFirstList[ItemID]
end
function CircleChooseUtil.IsAMelee(ItemID)
  if not ItemID or ItemID <= 0 then
    return false
  end
  if CircleChooseUtil.MeleeCache[ItemID] ~= nil then
    return CircleChooseUtil.MeleeCache[ItemID]
  end
  local ItemCfg = CDataTable.GetTableData("Item", ItemID)
  if not ItemCfg then
    return false
  end
  local bResult = ItemCfg.ItemSubType == 108
  CircleChooseUtil.MeleeCache[ItemID] = bResult
  return bResult
end
function CircleChooseUtil.SimMelee(ItemID)
  if not ItemID then
    return false
  end
  local CircleChooseCfg = GamePlayTools.GetCurrentConfig("CircleChooseCfg")
  local SimMeleeIDs = CircleChooseCfg.SimMeleeID
  local bSimMelee = SimMeleeIDs and SimMeleeIDs[ItemID]
  return CircleChooseUtil.IsAMelee(ItemID) or bSimMelee
end
function CircleChooseUtil.IsAMedicine(ItemID)
  if not ItemID or ItemID <= 0 then
    return false
  end
  if CircleChooseUtil.Medicine[ItemID] ~= nil then
    return CircleChooseUtil.Medicine[ItemID]
  end
  local ItemCfg = CDataTable.GetTableData("Item", ItemID)
  if not ItemCfg then
    return false
  end
  local bResult = ItemCfg.ItemSubType == 601
  CircleChooseUtil.Medicine[ItemID] = bResult
  return bResult
end
function CircleChooseUtil.IsArmorPieces(ItemID)
  return ItemID == 1004001
end
function CircleChooseUtil.IsAIceDrink(ItemID)
  if not ItemID then
    return false
  end
  return 1532076 <= ItemID and ItemID <= 1532120
end
function CircleChooseUtil.OnUseFistByRing()
  local uPlayerPawn = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerPawn) and uPlayerPawn.SwitchWeaponBySlot then
    local uESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
    uPlayerPawn:SwitchWeaponBySlot(uESurviveWeaponPropSlot.SWPS_None, true, false, false)
  end
end
function CircleChooseUtil.OnDirectUseGrenade(ItemID)
  local SkillID = UAESkillManagerUtils.GetGrenadeSkillID(ItemID)
  if 0 < SkillID then
    local PlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(PlayerCharacter) then
      PlayerCharacter:TriggerEntrySkillWithID(SkillID, true)
    end
  end
end
function CircleChooseUtil.OnUseGrenadebyRing(Type, ItemID)
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if not OperateSubsystem then
    return
  end
  local uPlayerPawn = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerPawn) then
    local bCanUse = OperateSubsystem:CanUseGrenadeWeapon(ItemID)
    if bCanUse then
      print(bWriteLog and "CircleChooseUtil.OnUseGrenadebyRing >ASTExtraBaseCharacter::SwitchWeaponBySlot")
      local SwitchWeaponAuxLib = require("GameLua.Mod.BaseMod.Client.MainControlUI.SwitchWeaponAuxLib")
      SwitchWeaponAuxLib.UseGrenadebyRing(uPlayerPawn, ItemID)
    end
  end
end
function CircleChooseUtil.OnUseMeleebyRing(DefineID)
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.ServerUseItem then
    local PlayerCharacter = GameplayData.GetPlayerCharacter()
    local EPawnState = import("EPawnState")
    if slua.isValid(PlayerCharacter) and PlayerCharacter:HasState(EPawnState.UseConsumables) then
      print(bWriteLog and "CircleChooseUtil.OnUseMeleebyRing Cancel skill when useConsumable")
      local UTSkillStopReason = import("UTSkillStopReason")
      PlayerCharacter:StopAllSkills(UTSkillStopReason.SkillStopReason_Interrupted)
    end
    if slua.isValid(PlayerCharacter) and PlayerCharacter.SwitchMeleeDirectly then
      local ESurviveWeaponPropSlotDef = import("ESurviveWeaponPropSlot")
      PlayerCharacter:SwitchWeaponBySlot(ESurviveWeaponPropSlotDef.SWPS_MeleeWeapon, true, false, false)
    else
      local BattleItemUseTarget = FBattleItemUseTarget()
      local SwitchWeaponAuxLib = require("GameLua.Mod.BaseMod.Client.MainControlUI.SwitchWeaponAuxLib")
      SwitchWeaponAuxLib.ServerUseItem(uPlayerController, PlayerCharacter, DefineID, BattleItemUseTarget, EBattleItemUseReason.Manually)
    end
  end
end
function CircleChooseUtil.HandleItemChosen(BattleItem)
  local MySubsystem = CircleChooseUtil.GetLogicMgrSubsystem()
  if BattleItem then
    local ItemID = BattleItem.DefineID.TypeSpecificID
    local Type = BattleItem.DefineID.Type
    if CircleChooseUtil.IsAMedicine(ItemID) or CircleChooseUtil.IsAGrenade(ItemID) then
      CircleChooseUtil.OnUseGrenadebyRing(Type, ItemID)
    elseif CircleChooseUtil.IsAMelee(ItemID) then
      CircleChooseUtil.OnUseMeleebyRing(BattleItem.DefineID)
    else
      CircleChooseUtil.UseConsumables(BattleItem)
    end
    if CircleChooseUtil.IsAMedicine(ItemID) then
      MySubsystem:SetIsChoosingMedicine(true)
    else
      MySubsystem:SetIsChoosingMedicine(false)
    end
  else
    CircleChooseUtil.OnUseFistByRing()
    MySubsystem:SetIsChoosingMedicine(false)
  end
end
function CircleChooseUtil.IsRingListItem(ItemID)
  local CircleChooseCfg = GamePlayTools.GetCurrentConfig("CircleChooseCfg")
  for _, v in ipairs(CircleChooseCfg.RingListItem) do
    if v == ItemID then
      return true
    end
  end
  return false
end
function CircleChooseUtil.UseConsumableItem(BattleItem)
  if not BattleItem then
    return
  end
  local EItemAssociationType = import("EItemAssociationType")
  local DefineID = BattleItem.DefineID
  local uPlayerController = GameplayData.GetPlayerController()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  local EPawnState = import("EPawnState")
  if slua.isValid(PlayerCharacter) and PlayerCharacter:HasState(EPawnState.Jump) then
    return
  end
  if slua.isValid(uPlayerController) then
    local Target = FBattleItemUseTarget()
    Target.Target    Target.TargetAssociationType = EItemAssociationType.None
    Target.TargetActor = nil
    uPlayerController:ServerUseItem(DefineID, Target, EBattleItemUseReason.Manually)
    uPlayerController:OnPlayerUseRecoverItem()
  end
end
function CircleChooseUtil.UseConsumables(BattleItem)
  if not BattleItem then
    return
  end
  local DefineID = BattleItem.DefineID
  local uPlayerController = GameplayData.GetPlayerController()
  local EItemAssociationType = import("EItemAssociationType")
  if slua.isValid(uPlayerController) then
    local Target = FBattleItemUseTarget()
    Target.Target    Target.TargetAssociationType = EItemAssociationType.None
    Target.TargetActor = nil
    uPlayerController:ServerUseItem(DefineID, Target, EBattleItemUseReason.Manually)
    uPlayerController:OnPlayerUseRecoverItem()
  end
end
function CircleChooseUtil.UseArmorItem(BattleItem)
  if not BattleItem then
    return
  end
  local DefineID = BattleItem.DefineID
  local TempPC = GameplayData.GetPlayerController()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  local EPawnState = import("EPawnState")
  if slua.isValid(PlayerCharacter) and PlayerCharacter:HasState(EPawnState.Jump) then
    return
  end
  if slua.isValid(TempPC) then
    local ItemTableData = CDataTable.GetTableData("Item", DefineID.TypeSpecificID)
    local CanEquipItemMap = AvatarUtils.GetChipCanEquipItemList(ItemTableData.ItemSubType)
    local BackpackComponentFromController = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(TempPC)
    local EuqippedArmorInBackpack = BackpackUtils.GetEuqippedArmorInBackpack(BackpackComponentFromController)
    local IsFind, ItemUseTarget = LuaBackpackUtils.GetEquipChipSlot(EuqippedArmorInBackpack, CanEquipItemMap, true, ItemTableData, BattleItem)
    if IsFind then
      TempPC:ServerUseItem(DefineID, ItemUseTarget, EBattleItemUseReason.Manually)
      return
    else
      local IsFind_1, ItemUseTarget_1 = LuaBackpackUtils.GetEquipChipSlot(EuqippedArmorInBackpack, CanEquipItemMap, false, ItemTableData, BattleItem)
      if IsFind_1 then
        TempPC:ServerUseItem(DefineID, ItemUseTarget_1, EBattleItemUseReason.Manually)
        return
      elseif ItemTableData.ItemType == ENUM_ITEM_TYPE.TKFProperty_10 and ItemTableData.ItemSubType == 1004 then
        IngameTipsTools.BattleNormalTipsByTextID(42663)
      end
    end
  end
end
function CircleChooseUtil.UseThemeProp(BattleItem, bIsUsing)
  if not BattleItem then
    return
  end
  local DefineID = BattleItem.DefineID
  local uPlayerController = GameplayData.GetPlayerController()
  local EItemAssociationType = import("EItemAssociationType")
  if slua.isValid(uPlayerController) then
    local Target = FBattleItemUseTarget()
    Target.Target    Target.TargetAssociationType = EItemAssociationType.None
    Target.TargetActor = nil
    if bIsUsing then
      uPlayerController:ServerDisuseItem(DefineID, EBattleItemDisuseReason.Manually)
    else
      uPlayerController:ServerUseItem(DefineID, Target, EBattleItemUseReason.Manually)
    end
  end
end
function CircleChooseUtil.GetCanUseChipSlotIdx(ItemData, SupportChipNum, EquipItemTableData, EquipItemData)
  LuaBackpackUtils.GetCanUseChipSlotIdx(ItemData, SupportChipNum, EquipItemTableData, EquipItemData)
end
function CircleChooseUtil.GetArmorCurHP(ItemDataAdditionalData)
  LuaBackpackUtils.GetArmorCurHP(ItemDataAdditionalData)
end
function CircleChooseUtil.GetEmptyChipSlotIdx(ItemData, SupportChipNum)
  LuaBackpackUtils.GetEmptyChipSlotIdx(ItemData, SupportChipNum)
end
function CircleChooseUtil.SwitchToMelee()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  local uBackpackComp
  if slua.isValid(uPlayerCharacter) then
    uBackpackComp = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromCharacter(uPlayerCharacter)
    if not slua.isValid(uBackpackComp) then
      return
    end
  else
    return
  end
  local ResIDList = BackpackUtils.GetBattleItemDataListByIDList(uBackpackComp, {108004})
  for key, BattleItem in pairs(ResIDList) do
    CircleChooseUtil.OnUseMeleebyRing(BattleItem.DefineID)
    break
  end
  local ResList = BackpackUtils.GetDesignatedTypeItemInBackpack(uBackpackComp, {108})
  for key, BattleItem in pairs(ResList) do
    CircleChooseUtil.OnUseMeleebyRing(BattleItem.DefineID)
    break
  end
end
function CircleChooseUtil.SwitchToBurnOrStun()
  local GrenadesPanel = UIManager.GetUI(UIManager.UI_Config_InGame.GrenadeChooseWidgetNew)
  if GrenadesPanel then
    if not GrenadesPanel.RingList[3]:HandleSlotChosen() then
      return GrenadesPanel.RingList[0]:HandleSlotChosen()
    else
      return true
    end
  end
end
function CircleChooseUtil.IsCurrentWeaponMatchID(ItemID)
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) then
    local uWeaponMgr = uPlayerCharacter:GetWeaponManager()
    if slua.isValid(uWeaponMgr) then
      local uCurrentWeapon = uWeaponMgr:GetCurrentUsingWeapon()
      if slua.isValid(uCurrentWeapon) then
        local nItemID = uCurrentWeapon:GetItemDefineID().TypeSpecificID
        if nItemID == ItemID then
          return true
        end
      end
    end
  end
  return false
end
function CircleChooseUtil.IsChoosingThemeProp()
  local MySubsystem = CircleChooseUtil.GetLogicThemePropSubsystem()
  if MySubsystem then
    return MySubsystem.bIsChoosingThemeProp
  end
  return false
end
function CircleChooseUtil.IsAThemeProp(TypeSpecificID)
  local LogicThemePropSubsystem = CircleChooseUtil.GetLogicThemePropSubsystem()
  if LogicThemePropSubsystem then
    local ThemePropsIDMap = LogicThemePropSubsystem:GetThemePropsIDMap()
    if ThemePropsIDMap and ThemePropsIDMap[TypeSpecificID] then
      return true
    end
  end
  return false
end
function CircleChooseUtil.IsThemePropDisable(TypeSpecificID)
  if not slua.isValid(CGameState) then
    return false
  end
  if CGameState.ThemeSkillItemFeature and CGameState.ThemeSkillItemFeature.bHasDisable then
    for _, ItemID in pairs(CGameState.ThemeSkillItemFeature.DisableItems) do
      if ItemID == TypeSpecificID then
        return true
      end
    end
  end
  return false
end
function CircleChooseUtil.CheckThemePropDisable(TypeSpecificID)
  if CircleChooseUtil.IsThemePropDisable(TypeSpecificID) then
    local ThemeSkillItemConfig = GamePlayTools.GetCurrentConfig("ThemeSkillItemConfig")
    if ThemeSkillItemConfig then
      local MapType = GameMainConfig.GetMapType()
      local DisableCfg = ThemeSkillItemConfig.DisableCfg[MapType]
      if DisableCfg and DisableCfg.DisableUseTipsID > 0 then
        local uPlayerController = GameplayData.GetPlayerController()
        if slua.isValid(uPlayerController) then
          uPlayerController:DisplayLuaGameTips("BattleGeneralTip", DisableCfg.DisableUseTipsID, "", "")
        end
      end
    end
    return true
  end
  return false
end
return CircleChooseUtil