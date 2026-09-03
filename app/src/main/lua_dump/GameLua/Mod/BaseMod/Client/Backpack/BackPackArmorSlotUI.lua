local BackPackArmorSlotUI = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local UEPathUtilityMethods = import("UEPathUtilityMethods")
function BackPackArmorSlotUI:ctor()
  print(bWriteLog and "BackPackArmorSlotUI:ctor")
  local EBackpackClothArmorType = UEnums.EBackpackClothArmorType
  self.tClothType2ChatID = {
    [EBackpackClothArmorType.Helmet] = 24,
    [EBackpackClothArmorType.ArmoredVest] = 25,
    [EBackpackClothArmorType.Package] = 26,
    [EBackpackClothArmorType.NightVision] = 27
  }
end
function BackPackArmorSlotUI:SetDescByItemID(ItemID)
  print(bWriteLog and "BackPackArmorSlotUI:SetDescByItemID ItemID:" .. ItemID)
  local BackpackConfig = GamePlayTools.GetCurrentConfig("BackpackConfig")
  if BackpackConfig and BackpackConfig.ArmorSlotDesc and BackpackConfig.ArmorSlotDesc[ItemID] then
    local LocalizeID = BackpackConfig.ArmorSlotDesc[ItemID].LocalizeID
    if LocalizeID == nil then
      return
    end
    local text
    if BackpackConfig.ArmorSlotDesc[ItemID].Params then
      text = LocUtil.LocalizeResFormat(LocalizeID, table.unpack(BackpackConfig.ArmorSlotDesc[ItemID].Params))
    else
      text = LocUtil.LocalizeResFormat(LocalizeID)
    end
    print(bWriteLog and "BackPackArmorSlotUI:SetDescByItemID", text)
    self.TextBlock_Desc:SetText(text)
  end
end
function BackPackArmorSlotUI:ShowSkillPropToolTip()
  local ClothType = self:GetCurrentClothType()
  if ClothType ~= UEnums.EBackpackClothArmorType.SkillProp then
    return
  end
  local BackPackPanelUI = UIManager.GetUI(UIManager.UI_Config_InGame.BackPackPanelUI)
  if not BackPackPanelUI then
    return
  end
  local SpecificID = self.ItemData.DefineID.TypeSpecificID
  local Brush = slua.IndexReference(self.Image_EquipIcon, "Brush"):clone()
  BackPackPanelUI.UIRoot:ShowArmoToolTips_SkillProp(SpecificID, Brush)
end
function BackPackArmorSlotUI:ShowItemIcon(ItemData, AvatarItemID)
  print(bWriteLog and "BackPackArmorSlotUI:ShowItemIcon AvatarItemID:" .. AvatarItemID)
  local ItemPathExist = false
  local AvatarItemData = CDataTable.GetTableData("Item", AvatarItemID)
  if AvatarItemData then
    if Client.IsJaguar() then
      local PufferConst = require("client.slua.logic.download.puffer_const")
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {AvatarItemID})
      if state == PufferConst.ENUM_DownloadState.Done then
        ItemPathExist = true
      end
    else
      ItemPathExist = UEPathUtilityMethods.IsAvatarResPathExist(AvatarItemData.ItemSmallIcon)
    end
  end
  if ItemPathExist then
    self.Image_EquipIcon:SetBrushFromPathAsync(AvatarItemData.ItemSmallIcon, true)
  else
    local ItemID = ItemData.DefineID.TypeSpecificID
    local DefaultItemData = CDataTable.GetTableData("Item", ItemID)
    if DefaultItemData and DefaultItemData.ItemSmallIcon then
      self.Image_EquipIcon:SetBrushFromPathAsync(DefaultItemData.ItemSmallIcon, true)
    end
  end
  self:CheckShowImageByAdditionalData(ItemData.AdditionalData)
  self:ShowArmorShieldBg()
end
function BackPackArmorSlotUI:SendQuickChatText(nClothType)
  print(bWriteLog and "BackPackArmorSlotUI:SendQuickChatText nClothType" .. nClothType)
  local nChatID = self.tClothType2ChatID[nClothType]
  if nChatID then
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    local MainControlPanelTouchButton = InGameUITools.GetMainControlPanelTochButton()
    if slua.isValid(MainControlPanelTouchButton) then
      MainControlPanelTouchButton:SendQuickNeedText(nChatID)
      print(bWriteLog and "BackPackArmorSlotUI:SendQuickChatText nChatID:" .. nChatID)
    end
  end
end
function BackPackArmorSlotUI:OnDestroy()
  print(bWriteLog and "BackPackArmorSlotUI:OnDestroy")
  self:Dispose()
end
function BackPackArmorSlotUI:GetEquipmentAvatarRes(BattleItemData)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return BattleItemData.DefineID.TypeSpecificID
  end
  local BackpackUtils = import("BackpackUtils")
  local BPUtils = BackpackUtils.GetBPUtils()
  if slua.isValid(BPUtils) then
    local TypeSpecificID_1 = BattleItemData.DefineID.TypeSpecificID
    local SkinItemID = BPUtils:GetEquipmentSkinIDByAvatar(TypeSpecificID_1, PlayerController.InitialEquipmentAvatar)
    if SkinItemID then
      return SkinItemID
    else
      return BattleItemData.DefineID.TypeSpecificID
    end
  else
    return BattleItemData.DefineID.TypeSpecificID
  end
end
function BackPackArmorSlotUI:CheckShowImageByAdditionalData(AdditionalDataList)
  local AffixClientSubSystem = SubsystemMgr:Get("AffixClientSubSystem")
  if not AffixClientSubSystem then
    return
  end
  self.Image_Affix_PVE_02:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.Image_Affix_PVE_01:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local bHasAffix_PVE = AffixClientSubSystem:HasAffix_PVE(AdditionalDataList)
  print(bWriteLog and "BackPackArmorSlotUI:CheckShowImageByAdditionalData bHasAffix_PVE:", bHasAffix_PVE)
  local ClothType = self:GetCurrentClothType()
  if ClothType == UEnums.EBackpackClothArmorType.Helmet or ClothType == UEnums.EBackpackClothArmorType.ArmoredVest then
    if bHasAffix_PVE then
      self.Image_Affix_PVE_02:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Image_Affix_PVE_02:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  elseif bHasAffix_PVE then
    self.Image_Affix_PVE_01:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Image_Affix_PVE_01:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self.Image_Equipment:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local HandleItemOwnerSubsystem = SubsystemMgr:Get("HandleItemOwnerSubsystem")
  if HandleItemOwnerSubsystem then
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    if AdditionalDataList then
      local uPlayerState = GameplayData.GetPlayerState()
      if slua.isValid(uPlayerState) then
        local IsTeamMateOwner = HandleItemOwnerSubsystem:IsTeamMateOwner(AdditionalDataList, uPlayerState)
        if IsTeamMateOwner then
          self.Image_Equipment:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end
      end
    end
  end
  self.Image_MaxLevel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function BackPackArmorSlotUI:CheckCanShowArmor()
  local LuaBackpackUtils = require("GameLua.Mod.Library.GamePlay.Backpack.LuaBackpackUtils")
  local ClothType = self:GetCurrentClothType()
  if ClothType == UEnums.EBackpackClothArmorType.Helmet or ClothType == UEnums.EBackpackClothArmorType.ArmoredVest then
    return true
  elseif ClothType == UEnums.EBackpackClothArmorType.Package then
    return LuaBackpackUtils.IsElectromagneticBack(self.ItemData.DefineID.TypeSpecificID)
  end
  return false
end
function BackPackArmorSlotUI:ShowArmorShieldBg()
  local LuaBackpackUtils = require("GameLua.Mod.Library.GamePlay.Backpack.LuaBackpackUtils")
  if LuaBackpackUtils.IsElectromagneticBack(self.ItemData.DefineID.TypeSpecificID) then
    self.Image_ShieldBg:SetBrushfromPathAsync("/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_Icon_Shield_Durable_png.ZD_Icon_Shield_Durable_png", false)
  else
    self.Image_ShieldBg:SetBrushfromPathAsync("/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_icon_hudun2_png.ZD_icon_hudun2_png", false)
  end
end
local class = require("class")
local object = require("common.delegate_container")
return class(object, nil, BackPackArmorSlotUI)