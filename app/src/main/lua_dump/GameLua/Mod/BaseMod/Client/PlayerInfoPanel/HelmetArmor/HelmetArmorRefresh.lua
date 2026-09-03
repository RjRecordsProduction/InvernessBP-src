local HelmetArmor = require("GameLua.Mod.BaseMod.Client.PlayerInfoPanel.HelmetArmor.HelmetArmorConfig")
local UBackpackUtils = import("BackpackUtils")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function HelmetArmor:UpdateHelmetAndArmorLevel(uBackpackComponent, DefineID)
  self:CheckIsSpectator()
  if not slua.isValid(uBackpackComponent) then
    local uPlayerController = GameplayData.GetPlayerController()
    if not slua.isValid(uPlayerController) then
      print(bWriteLog and "HelmetArmor_Debug_Msg: UpdateHelmetAndArmorLevel PC is nil")
      return
    end
    uBackpackComponent = uPlayerController:GetBackpackComponent()
    if not slua.isValid(uBackpackComponent) then
      print(bWriteLog and "HelmetArmor_Debug_Msg: UpdateHelmetAndArmorLevel uBackpackComponent is nil")
      return
    end
  end
  if not DefineID then
    local EuqippedArmorInBackpackList = UBackpackUtils.GetEuqippedArmorInBackpack(uBackpackComponent)
    for _, EuqippedArmorInBackpack in pairs(EuqippedArmorInBackpackList) do
      if EuqippedArmorInBackpack.DefineID and EuqippedArmorInBackpack.DefineID.Type == 5 then
        self:UpdateHelmetAndArmorLevel_Imp(uBackpackComponent, EuqippedArmorInBackpack.DefineID)
      end
    end
  else
    self:UpdateHelmetAndArmorLevel_Imp(uBackpackComponent, DefineID)
  end
end
function HelmetArmor:UpdateHelmetAndArmorLevel_Imp(uBackpackComponent, DefineID)
  local SubType = UBackpackUtils.GetItemSubType(DefineID.TypeSpecificID)
  print(bWriteLog and "HelmetArmor_Debug_Msg UpdateHelmetAndArmorLevel: DefineID.TypeSpecificID", DefineID.TypeSpecificID, "SubType = ", SubType)
  if SubType == 502 then
    self:UpdateHelmetLevel(uBackpackComponent)
  elseif SubType == 503 then
    self:UpdateArmorLevel(uBackpackComponent)
  end
end
function HelmetArmor:UpdateHelmetLevel(uBackpackComponent)
  self.bHasHelmet = false
  self.bRedrawHelmet = false
  local nHelmetDefineID, nHelmetLevel = UBackpackUtils.GetEquipmentHelmetInBackpack(uBackpackComponent, 0)
  if 0 < nHelmetDefineID.TypeSpecificID and 0 < nHelmetLevel then
    self:UpdateHelmetData(nHelmetDefineID, nHelmetLevel)
  end
  if self.bHasHelmet then
    if self.bRedrawHelmet then
      self.UIRoot.GridPanel_Helmet:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    end
  else
    self.UIRoot.GridPanel_Helmet:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    self.CacheHelmetDefineID = nil
    self.CacheHelmetLevel = 0
  end
end
function HelmetArmor:UpdateArmorLevel(uBackpackComponent)
  self.bHasArmor = false
  self.bRedrawArmor = false
  local ArmorDefineID, nArmorLevel = UBackpackUtils.GetEquipmentArmorInBackpack(uBackpackComponent, 0)
  if 0 < ArmorDefineID.TypeSpecificID and 0 < nArmorLevel then
    self:UpdateArmorData(ArmorDefineID, nArmorLevel)
  end
  if self.bHasArmor then
    if self.bRedrawArmor then
      self.UIRoot.GridPanel_Armor:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    end
  else
    self.UIRoot.GridPanel_Armor:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    self.CacheArmorDefineID = nil
    self.CacheArmorLevel = 0
  end
end
function HelmetArmor:UpdateHelmetData(DefineID, ItemLevel)
  if self.CacheHelmetLevel == ItemLevel then
    self.bRedrawHelmet = false
  else
    local sLevelImagePath = self:GetLevelImage(ItemLevel)
    if sLevelImagePath then
      self.UIRoot.Helmet_Level:SetBrushFromPathAsync(sLevelImagePath, false)
    else
      print(bWriteLog and "HelmetArmor_Debug_Msg: UpdateHelmetData sLevelImagePath is nil")
    end
    local sHelmetLevelImagePath = self:GetHelmetLevelImage(ItemLevel)
    if sHelmetLevelImagePath then
      self.UIRoot.Helmet_Image:SetBrushFromPathAsync(sHelmetLevelImagePath, false)
    else
      print(bWriteLog and "HelmetArmor_Debug_Msg: UpdateHelmetData sHelmetLevelImagePath is nil")
    end
    self.bRedrawHelmet = true
  end
  self.bHasHelmet = true
  self.CacheHelmet  self.CacheHelmetLevel = ItemLevel
end
function HelmetArmor:UpdateArmorData(DefineID, ItemLevel)
  if self.CacheArmorLevel == ItemLevel then
    self.bRedrawArmor = false
  else
    local sLevelImagePath = self:GetLevelImage(ItemLevel)
    if sLevelImagePath then
      self.UIRoot.Armor_Level:SetBrushFromPathAsync(sLevelImagePath, false)
    else
      print(bWriteLog and "HelmetArmor_Debug_Msg: UpdateArmorData sLevelImagePath is nil")
    end
    local sArmorLevelImagePath = self:GetArmorLevelImage(ItemLevel)
    if sArmorLevelImagePath then
      self.UIRoot.Armor_Image:SetBrushFromPathAsync(sArmorLevelImagePath, false)
    else
      print(bWriteLog and "HelmetArmor_Debug_Msg: UpdateArmorData sArmorLevelImagePath is nil")
    end
    self.bRedrawArmor = true
  end
  self.bHasArmor = true
  self.CacheArmor  self.CacheArmorLevel = ItemLevel
end
function HelmetArmor:ShowHelmetArmorPanel()
  if self.bHideHelmetArmorUI then
    print(bWriteLog and "HelmetArmor_Debug_Msg: ShowHelmetArmorPanel Failed")
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and (uPlayerController:IsSpectator() or uPlayerController:IsInPetSpectator()) then
    self:HideHelmetArmorPanel()
    return
  end
  print(bWriteLog and "HelmetArmor_Debug_Msg: ShowHelmetArmorPanel")
  self:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
end
function HelmetArmor:HideHelmetArmorPanel()
  print(bWriteLog and "HelmetArmor_Debug_Msg: HideHelmetArmorPanel")
  self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function HelmetArmor:UpdateEquipmentDurability(nCurHP, RatioHP)
  if not slua.isValid(self.CachedBackpackComponent) then
    local uPlayerController = GameplayData.GetPlayerController()
    if not slua.isValid(uPlayerController) then
      print(bWriteLog and "HelmetArmor_Debug_Msg: UpdateEquipmentDurability PC is nil")
      return
    end
    self.CachedBackpackComponent = uPlayerController:GetBackpackComponent()
  end
  if not slua.isValid(self.CachedBackpackComponent) then
    print(bWriteLog and "self.CachedBackpackComponent is nil")
    return
  end
  if self.CacheHelmetDefineID then
    local nHelmetPercent = self:UpdateEquipmentDurabilityImp(self.CachedBackpackComponent:GetItemByDefineID(self.CacheHelmetDefineID))
    if 0 <= nHelmetPercent and nHelmetPercent <= 1 then
      self.UIRoot.Helmet_RuinPercentage:SetPercent(nHelmetPercent)
      local DynamicBattleFBTipsWidget = self:GetDynamicBattleFBTipsWidget()
      if slua.isValid(DynamicBattleFBTipsWidget) and slua.isValid(DynamicBattleFBTipsWidget.Helmet_RuinPercentage) then
        DynamicBattleFBTipsWidget.Helmet_RuinPercentage:SetPercent(nHelmetPercent)
      end
    end
  end
  if self.CacheArmorDefineID then
    local nArmorPercent = self:UpdateEquipmentDurabilityImp(self.CachedBackpackComponent:GetItemByDefineID(self.CacheArmorDefineID))
    if 0 <= nArmorPercent and nArmorPercent <= 1 then
      self.UIRoot.Armor_RuinPercentage:SetPercent(nArmorPercent)
      local DynamicBattleFBTipsWidget = self:GetDynamicBattleFBTipsWidget()
      if slua.isValid(DynamicBattleFBTipsWidget) and slua.isValid(DynamicBattleFBTipsWidget.Armor_RuinPercentage) then
        DynamicBattleFBTipsWidget.Armor_RuinPercentage:SetPercent(nArmorPercent)
      end
    end
  end
end
function HelmetArmor:UpdateEquipmentDurabilityImp(BattleItemData)
  local nCount = BattleItemData.Count
  local nTypeSpecificID = BattleItemData.DefineID.TypeSpecificID
  local ItemData = CDataTable.GetTableData("Item", nTypeSpecificID)
  if ItemData then
    local nDurability = ItemData.Durability
    if 0 < nCount and 0 < nDurability then
      local nCurDurability = self:GetTargetAvatarCurDurability(BattleItemData.AdditionalData)
      return FuncUtil.Clamp(1 - nCurDurability / nDurability, 0, 1)
    end
  end
  return -1
end