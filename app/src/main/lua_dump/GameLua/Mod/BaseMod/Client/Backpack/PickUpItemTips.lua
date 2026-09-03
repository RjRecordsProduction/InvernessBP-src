local PickUpItemTips = {}
local BackpackUtils = import("BackpackUtils")
local KismetMathLibrary = import("KismetMathLibrary")
local KismetTextLibrary = import("KismetTextLibrary")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local STExtraUIUtils = import("STExtraUIUtils")
local ESlateVisibility = import("ESlateVisibility")
local ItemConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.ItemConfig")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function PickUpItemTips:ctor()
  self.IconMap = {
    Up1 = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/AccessoriesDescribe_icon_5_png.AccessoriesDescribe_icon_5_png",
    Up2 = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/AccessoriesDescribe_icon_6_png.AccessoriesDescribe_icon_6_png",
    Up3 = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/AccessoriesDescribe_icon_7_png.AccessoriesDescribe_icon_7_png",
    Down1 = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/AccessoriesDescribe_icon_8_png.AccessoriesDescribe_icon_8_png",
    Down2 = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/AccessoriesDescribe_icon_9_png.AccessoriesDescribe_icon_9_png",
    Down3 = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/AccessoriesDescribe_icon_10_png.AccessoriesDescribe_icon_10_png"
  }
end
function PickUpItemTips:UpdateData(Image, ItemName, ItemDesc, ItemCount, ItemVolume, TypeSpecificID)
  local CalProduct = function(A, B)
    return A * KismetMathLibrary.FTrunc(1000 * B) / 1000.0
  end
  local UIRoot = self.UIRoot
  self.  UIRoot.TextBlock_Name:SetText(KismetTextLibrary.Conv_StringToText(ItemName))
  local kismet_string_library = require("common.kismet_string_library")
  UIRoot.TextBlock_ItemDescrip:SetText(KismetTextLibrary.Conv_StringToText(kismet_string_library.Replace(ItemDesc, "ItemDescribe", "ItemDescribeBig", kismet_string_library.ESearchCase.CaseSensitive)))
  UIRoot.Image_ItemIcon:SetBrush(Image)
  local sTotalVolume = STExtraUIUtils.GetFloatAsStringWithPrecision(CalProduct(ItemCount, ItemVolume), 3, true)
  local sItemVolume = STExtraUIUtils.GetFloatAsStringWithPrecision(ItemVolume, 3, true)
  if sTotalVolume == "0" then
    local ZeroText = BackpackUtils.GetRawBattleTextByRawTextID(42942)
    UIRoot.TextBlock_Volume:SetText(ZeroText)
  else
    local RawBattleTextByRawTextID = BackpackUtils.GetRawBattleTextByRawTextID(32002)
    UIRoot.TextBlock_Volume:SetText(FuncUtil.GetFormatText(KismetTextLibrary.Conv_StringToText(RawBattleTextByRawTextID), sTotalVolume, sItemVolume, ItemCount))
  end
  local TableData = CDataTable.GetTableData("Item", self.TypeSpecificID)
  local IsTaskItemType = TableData and BackpackUtils.IsTaskItemType(TableData.ItemType)
  if IsTaskItemType then
    UIRoot.VolumeBox:SetWidgetVisibility(ESlateVisibility.Collapsed)
    UIRoot.PickProcess:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self:HideAccessoryDesc()
    local OwningPlayerPawnOrVehicleDriver = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(UIRoot)
    if slua.isValid(OwningPlayerPawnOrVehicleDriver) then
      local BackpackComponentFromCharacter = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromCharacter(OwningPlayerPawnOrVehicleDriver)
      local ItemDefineID = FItemDefineID(TableData.ItemType, TableData.ItemID)
      local SpecialItemBefore = BackpackComponentFromCharacter:GetSpecialItemBefore(ItemDefineID.TypeSpecificID)
      if SpecialItemBefore.cur_count >= SpecialItemBefore.total_count then
        UIRoot.PickProcess:SetWidgetVisibility(ESlateVisibility.Collapsed)
      else
        UIRoot.PickProcess:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
        local RawBattleTextByRawTextID_1 = BackpackUtils.GetRawBattleTextByRawTextID(32001)
        local SpecialItemNow = BackpackComponentFromCharacter:GetSpecialItemNow(ItemDefineID)
        local Text = FuncUtil.GetFormatText(KismetTextLibrary.Conv_StringToText(RawBattleTextByRawTextID_1), SpecialItemNow.cur_count, SpecialItemNow.total_count)
        UIRoot.TextBlock_describe:SetText(Text)
      end
    end
  else
    UIRoot.VolumeBox:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    UIRoot.PickProcess:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self:UpdateAccessoryDesc()
    self:UpdateLivikXTDesc()
  end
end
function PickUpItemTips:UpdateDataByIconPath(IconPath, ItemName, ItemDesc, ItemCount, ItemVolume, TypeSpecificID)
  local CalProduct = function(A, B)
    return A * KismetMathLibrary.FTrunc(1000 * B) / 1000.0
  end
  local UIRoot = self.UIRoot
  self.  UIRoot.TextBlock_Name:SetText(KismetTextLibrary.Conv_StringToText(ItemName))
  local kismet_string_library = require("common.kismet_string_library")
  UIRoot.TextBlock_ItemDescrip:SetText(KismetTextLibrary.Conv_StringToText(kismet_string_library.Replace(ItemDesc, "ItemDescribe", "ItemDescribeBig", kismet_string_library.ESearchCase.CaseSensitive)))
  UIRoot.Image_ItemIcon:SetBrushfromPathAsync(IconPath)
  local sTotalVolume = STExtraUIUtils.GetFloatAsStringWithPrecision(CalProduct(ItemCount, ItemVolume), 3, true)
  local sItemVolume = STExtraUIUtils.GetFloatAsStringWithPrecision(ItemVolume, 3, true)
  if sTotalVolume == "0" then
    local ZeroText = BackpackUtils.GetRawBattleTextByRawTextID(42942)
    UIRoot.TextBlock_Volume:SetText(ZeroText)
  else
    local RawBattleTextByRawTextID = BackpackUtils.GetRawBattleTextByRawTextID(32002)
    UIRoot.TextBlock_Volume:SetText(FuncUtil.GetFormatText(KismetTextLibrary.Conv_StringToText(RawBattleTextByRawTextID), sTotalVolume, sItemVolume, ItemCount))
  end
  local TableData = CDataTable.GetTableData("Item", self.TypeSpecificID)
  local IsTaskItemType = BackpackUtils.IsTaskItemType(TableData.ItemType)
  if IsTaskItemType then
    UIRoot.VolumeBox:SetWidgetVisibility(ESlateVisibility.Collapsed)
    UIRoot.PickProcess:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self:HideAccessoryDesc()
    local OwningPlayerPawnOrVehicleDriver = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(UIRoot)
    if slua.isValid(OwningPlayerPawnOrVehicleDriver) then
      local BackpackComponentFromCharacter = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromCharacter(OwningPlayerPawnOrVehicleDriver)
      local ItemDefineID = FItemDefineID(TableData.ItemType, TableData.ItemID)
      local SpecialItemBefore = BackpackComponentFromCharacter:GetSpecialItemBefore(ItemDefineID.TypeSpecificID)
      if SpecialItemBefore.cur_count >= SpecialItemBefore.total_count then
        UIRoot.PickProcess:SetWidgetVisibility(ESlateVisibility.Collapsed)
      else
        UIRoot.PickProcess:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
        local RawBattleTextByRawTextID_1 = BackpackUtils.GetRawBattleTextByRawTextID(32001)
        local SpecialItemNow = BackpackComponentFromCharacter:GetSpecialItemNow(ItemDefineID)
        local Text = FuncUtil.GetFormatText(KismetTextLibrary.Conv_StringToText(RawBattleTextByRawTextID_1), SpecialItemNow.cur_count, SpecialItemNow.total_count)
        UIRoot.TextBlock_describe:SetText(Text)
      end
    end
  else
    UIRoot.VolumeBox:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    UIRoot.PickProcess:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self:UpdateAccessoryDesc()
    self:UpdateLivikXTDesc()
  end
end
function PickUpItemTips:UpdateAccessoryDesc()
  print(bWriteLog and "PickUpItemTips:UpdateAccessoryDesc")
  local ItemID = self.TypeSpecificID
  local UIRoot = self.UIRoot
  local AccessoryDescData = CDataTable.GetTableData("AccessoryDesc", ItemID)
  if not AccessoryDescData then
    self:HideAccessoryDesc()
    return
  end
  local MarksArray = AccessoryDescData.Marks_a
  local DescriptionsArray = AccessoryDescData.Descriptions_a
  if MarksArray:Num() ~= DescriptionsArray:Num() or MarksArray:Num() == 0 then
    self:HideAccessoryDesc()
    return
  end
  self:HideNormalDesc()
  local NumOfMarks = MarksArray:Num()
  for Num = 1, 4 do
    local DescWidget = UIRoot["AccessoriesDescribe_Item_" .. Num]
    if Num <= NumOfMarks then
      DescWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      local MarkNum = MarksArray:Get(Num - 1)
      if 0 <= MarkNum then
        DescWidget.TextBlock_57:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 0.7)))
      else
        DescWidget.TextBlock_57:SetColorAndOpacity(FSlateColor(FLinearColor(0.679543, 0, 0.021219, 1.0)))
      end
      if MarkNum ~= 0 then
        DescWidget.Image_1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      else
        DescWidget.Image_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
      if MarkNum == 1 then
        DescWidget.Image_1:SetBrushFromPathAsync(self.IconMap.Up1, false)
      elseif MarkNum == 2 then
        DescWidget.Image_1:SetBrushFromPathAsync(self.IconMap.Up2, false)
      elseif MarkNum == 3 then
        DescWidget.Image_1:SetBrushFromPathAsync(self.IconMap.Up3, false)
      elseif MarkNum == -1 then
        DescWidget.Image_1:SetBrushFromPathAsync(self.IconMap.Down1, false)
      elseif MarkNum == -2 then
        DescWidget.Image_1:SetBrushFromPathAsync(self.IconMap.Down2, false)
      elseif MarkNum == -3 then
        DescWidget.Image_1:SetBrushFromPathAsync(self.IconMap.Down3, false)
      end
      DescWidget.TextBlock_57:SetText(LocUtil.GetLocalizeResStr(DescriptionsArray:Get(Num - 1)))
    else
      DescWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function PickUpItemTips:UpdateLivikXTDesc()
  print(bWriteLog and "PickUpItemTips:UpdateLivikXTDesc")
  local ItemID = self.TypeSpecificID
  if not ItemConfig.WeaponUpgradeSkill[ItemID] then
    return
  end
  print(bWriteLog and "PickUpItemTips:ShowLivikXTDesc", ItemID)
  local WeaponUpgradeConfig = require("GameLua.Mod.Livik.GamePlay.Weapon.WeaponUpgradeCfg")
  local WeaponList = self:GetPlayerWeapons()
  local UIRoot = self.UIRoot
  for Slot, Weapon in pairs(WeaponList) do
    if WeaponUpgradeConfig.UpgradeCfg[ItemID][Weapon:GetItemDefineID().TypeSpecificID] and not Weapon:HasUpgrade() then
      self:HideNormalDesc()
      local UpgradeItemStrings = WeaponUpgradeConfig.UpgradeItemStrings[ItemID]
      local UpgradeItemStringsNum = #UpgradeItemStrings
      for Num = 1, 4 do
        local DescWidget = UIRoot["AccessoriesDescribe_Item_" .. Num]
        if Num <= UpgradeItemStringsNum then
          DescWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
          DescWidget.Image_1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
          DescWidget.Image_1:SetBrushfromPathAsync(self.IconMap.Up1, false)
          DescWidget.TextBlock_57:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 0.5)))
          DescWidget.TextBlock_57:SetText(LocUtil.GetLocalizeResStr(UpgradeItemStrings[Num]))
        else
          DescWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        end
      end
      return
    end
  end
  self:HideAccessoryDesc()
end
function PickUpItemTips:HideAccessoryDesc()
  local UIRoot = self.UIRoot
  for Num = 1, 4 do
    UIRoot["AccessoriesDescribe_Item_" .. Num]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self:ShowNormalDesc()
end
function PickUpItemTips:HideNormalDesc()
  self.UIRoot.TextBlock_ItemDescrip:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function PickUpItemTips:ShowNormalDesc()
  self.UIRoot.TextBlock_ItemDescrip:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function PickUpItemTips:OnDestroy()
  print(bWriteLog and "PickUpItemTips:OnDestroy")
  self:Dispose()
end
function PickUpItemTips:GetPlayerWeapons()
  local WeaponList = {}
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) or not slua.isValid(uPlayerCharacter:GetWeaponManager()) then
    return WeaponList
  end
  local uWeaponManager = uPlayerCharacter:GetWeaponManager()
  local ESurviveWeaponPropSlotDef = import("ESurviveWeaponPropSlot")
  local MainWeapon1 = uWeaponManager:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlotDef.SWPS_MainShootWeapon1)
  local MainWeapon2 = uWeaponManager:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlotDef.SWPS_MainShootWeapon2)
  if MainWeapon1 then
    WeaponList[ESurviveWeaponPropSlotDef.SWPS_MainShootWeapon1] = MainWeapon1
  end
  if MainWeapon2 then
    WeaponList[ESurviveWeaponPropSlotDef.SWPS_MainShootWeapon2] = MainWeapon2
  end
  return WeaponList
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, PickUpItemTips)