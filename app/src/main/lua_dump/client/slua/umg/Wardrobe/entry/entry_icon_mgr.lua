local EntryIconMgr = {}
EntryIconMgr.ENUM_DECOMPOSE = 1
EntryIconMgr.ENUM_DISPLAY_SETTING = 2
EntryIconMgr.ENUM_GENDER = 3
EntryIconMgr.ENUM_CHARACTER = 4
EntryIconMgr.ENUM_PREPARE_SCHEME = 5
EntryIconMgr.ENUM_SUBSCRIBE_SHARE = 6
EntryIconMgr.ENUM_GOLDEN_HEAD_ZOOM = 7
EntryIconMgr.ENUM_SPRAY_EXCHANGE = 8
EntryIconMgr.ENUM_MINI_TV_SWITCH = 9
local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
local macroTabString = wardrobe_macro.ENUM_WardrobeSubTabString
local IconConfigTable = {}
local InitIconConfigTable = function()
  IconConfigTable[EntryIconMgr.ENUM_DECOMPOSE] = {
    nameStrId = "7392",
    iconPath = "/Game/UMG/Texture/Atlas/WardrobeUI_New/Frames/Wardrobe_icon_Jigsaw_png.Wardrobe_icon_Jigsaw_png",
    entry_icon_bp_path = "/Game/UMG/UI_BP/Wardrobe/Wardrobe_EntryIconItem_Decompose.Wardrobe_EntryIconItem_Decompose",
    entry_icon_module_name = "client.slua.umg.Wardrobe.entry.entry_icon_decompose",
    attachPoint = "GridPanel_entry",
    index = 6
  }
  IconConfigTable[EntryIconMgr.ENUM_DISPLAY_SETTING] = {
    nameStrId = "7393",
    iconPath = "/Game/UMG/Texture_200/Atlas/Detail/Frames/Common_Btn_Setting_png.Common_Btn_Setting_png",
    entry_icon_bp_path = "/Game/UMG/UI_BP/Wardrobe/Wardrobe_EntryIconItem_Settting.Wardrobe_EntryIconItem_Settting",
    entry_icon_module_name = "client.slua.umg.Wardrobe.entry.entry_icon_setting",
    attachPoint = "GridPanel_entry",
    index = 7
  }
  IconConfigTable[EntryIconMgr.ENUM_GENDER] = {
    nameStrId = "69101",
    entry_icon_bp_path = "/Game/UMG/UI_BP/Wardrobe/Wardrobe_GenderIconItem_Change_UIBP.Wardrobe_GenderIconItem_Change_UIBP",
    entry_icon_module_name = "client.slua.umg.Wardrobe.entry.entry_icon_gender",
    attachPoint = "GridPanel_entry",
    index = 5
  }
  IconConfigTable[EntryIconMgr.ENUM_CHARACTER] = {
    nameStrId = "7576",
    entry_icon_bp_path = "/Game/UMG/UI_BP/Wardrobe/Wardrobe_EntryCharacterItem_BP.Wardrobe_EntryCharacterItem_BP",
    entry_icon_module_name = "client.slua.umg.Wardrobe.entry.entry_icon_character",
    attachPoint = "GridPanel_entry",
    index = 4
  }
  IconConfigTable[EntryIconMgr.ENUM_PREPARE_SCHEME] = {
    nameStrId = "7947",
    iconPath = "/Game/Arts/UI/Atlas/BattleUI/Tmode/Frames/Team_competition_icon_rukou_png.Team_competition_icon_rukou_png",
    entry_icon_bp_path = "/Game/UMG/UI_BP/Wardrobe/Wardrobe_Team_competition_rukou.Wardrobe_Team_competition_rukou",
    entry_icon_module_name = "client.slua.umg.Wardrobe.entry.entry_icon_prepare_scheme",
    attachPoint = "GridPanel_entry",
    index = 8
  }
  IconConfigTable[EntryIconMgr.ENUM_SUBSCRIBE_SHARE] = {
    nameStrId = "7576",
    entry_icon_bp_path = "/Game/UMG/UI_BP/Wardrobe/SharePackage/Item/Wardrobe_EntryIconItem_SharePackage.Wardrobe_EntryIconItem_SharePackage",
    entry_icon_module_name = "client.slua.umg.Wardrobe.entry.entry_icon_subscribe_share",
    attachPoint = "GridPanel_entry",
    index = 2
  }
  IconConfigTable[EntryIconMgr.ENUM_GOLDEN_HEAD_ZOOM] = {
    nameStrId = "77238",
    entry_icon_bp_path = "/Game/UMG/UI_BP/Wardrobe/Wardrobe_EntryIconItem_GoldenHeadZoom.Wardrobe_EntryIconItem_GoldenHeadZoom",
    entry_icon_module_name = "client.slua.umg.Wardrobe.entry.entry_icon_golden_head_zoom",
    attachPoint = "GridPanel_entry",
    index = 1
  }
  IconConfigTable[EntryIconMgr.ENUM_SPRAY_EXCHANGE] = {
    nameStrId = "76207",
    entry_icon_bp_path = "/Game/UMG/UI_BP/Wardrobe/Wardrobe_EntryIconItem_Spary_Exchange.Wardrobe_EntryIconItem_Spary_Exchange",
    entry_icon_module_name = "client.slua.umg.Wardrobe.entry.entry_icon_spray_exchange",
    attachPoint = "GridPanel_entry",
    index = 3
  }
  IconConfigTable[EntryIconMgr.ENUM_MINI_TV_SWITCH] = {
    nameStrId = "7947",
    entry_icon_bp_path = "/Game/UMG/UI_BP/Wardrobe/Wardrobe_EntryIconItem_MiniTv_Switch.Wardrobe_EntryIconItem_MiniTv_Switch",
    entry_icon_module_name = "client.slua.umg.Wardrobe.entry.entry_icon_minitv_switch_type",
    attachPoint = "GridPanel_entry",
    index = 9
  }
end
local GenderEntryLimitSubPage = {
  [macroTabString.Enum_WardrobeSubTabString_ShowBrand] = true,
  [macroTabString.ENUM_WardrobeSubTabString_parachute] = true,
  [macroTabString.ENUM_WardrobeSubTabString_quicksign] = true,
  [macroTabString.ENUM_WardrobeSubTabString_quickmessage] = true,
  [macroTabString.ENUM_WardrobeSubTabString_plane] = true,
  [macroTabString.ENUM_WardrobeSubTabString_throw_object] = true,
  [macroTabString.ENUM_WardrobeSubTabString_MiniTVSuit] = true,
  [macroTabString.ENUM_WardrobeSubTabString_emoji_bubble] = true,
  [macroTabString.ENUM_WardrobeSubTabString_holography] = true,
  [macroTabString.ENUM_WardrobeSubTabString_plating] = true
}
function EntryIconMgr:Init(pageId)
  InitIconConfigTable()
  self.IconTable = {}
  self:RefreshIcon(pageId)
end
function EntryIconMgr:Destroy()
  self.IconTable = {}
end
function EntryIconMgr:SetIconVisibility(type, vis)
  local entryIcon = self:GetIcon(type)
  if not entryIcon then
    return
  end
  if vis then
    entryIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  else
    entryIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function EntryIconMgr:SetIconVisibilityNoCreat(type, vis)
  local entryIcon = self:GetIconNoCreat(type)
  if not entryIcon then
    return
  end
  if vis then
    entryIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  else
    entryIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function EntryIconMgr:RefreshIcon(pageId)
  EntryIconMgr:SetIconVisibility(EntryIconMgr.ENUM_GOLDEN_HEAD_ZOOM, false)
  EntryIconMgr:SetIconVisibility(EntryIconMgr.ENUM_SUBSCRIBE_SHARE, self:CanShowSubscribeShareEntry(pageId))
  EntryIconMgr:SetIconVisibility(EntryIconMgr.ENUM_SPRAY_EXCHANGE, false)
  EntryIconMgr:SetIconVisibility(EntryIconMgr.ENUM_CHARACTER, self:CanShowCharacter(pageId))
  EntryIconMgr:SetIconVisibility(EntryIconMgr.ENUM_GENDER, self:CanShowGenderEntry(pageId))
  EntryIconMgr:SetIconVisibility(EntryIconMgr.ENUM_DECOMPOSE, self:CanShowDecompose(pageId))
  EntryIconMgr:SetIconVisibility(EntryIconMgr.ENUM_DISPLAY_SETTING, true)
end
function EntryIconMgr:CreateIcon(type)
  if not type or not IconConfigTable[type] then
    return
  end
  local wardrobeUI = UIManager.GetUI(UIManager.UI_Config.wardrobe)
  if not wardrobeUI then
    log(bWriteLog and "EntryIconMgr:CreateIcon not wardrobeUI")
    return
  end
  local entryIconIns = wardrobeUI:CreateChildWindowWithLuaAndBpPath(IconConfigTable[type].attachPoint, UIManager.UI_Config.ChildUIWithoutLuaAndBpPathAsy, IconConfigTable[type].entry_icon_module_name, IconConfigTable[type].entry_icon_bp_path, IconConfigTable[type])
  self.IconTable[type] = entryIconIns
  if entryIconIns then
    local index = IconConfigTable[type].index
    if index then
      entryIconIns.UIRoot.Slot:SetRow(index - 1)
      log(bWriteLog and "EntryIconMgr:CreateIcon module" .. (IconConfigTable[type].entry_icon_module_name or "nil") .. " index = " .. tostring(index))
    end
  end
end
function EntryIconMgr:GetIcon(type)
  if not self.IconTable[type] then
    self:CreateIcon(type)
  end
  return self.IconTable[type]
end
function EntryIconMgr:GetIconNoCreat(type)
  if not self.IconTable then
    log(bWriteLog and "EntryIconMgr:GetIconNoCreat not IconTable")
    return
  end
  return self.IconTable[type]
end
function EntryIconMgr:OnWardrobePageChanged(newPageId)
  local logic_share_bag_privilege_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_privilege_util)
  local bShareBagVliad = logic_share_bag_privilege_util:IsAnyShardBagValid()
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local bIsAvtarOrWeapon = wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Avatar == newPageId or wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Weapon == newPageId
  EntryIconMgr:SetIconVisibility(EntryIconMgr.ENUM_SUBSCRIBE_SHARE, bShareBagVliad and bIsAvtarOrWeapon)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SUBSCRIBE_ENTRY_CHANGED)
  if newPageId ~= wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Avatar then
    EntryIconMgr:SetIconVisibility(EntryIconMgr.ENUM_GOLDEN_HEAD_ZOOM, false)
  end
  if newPageId ~= wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Parachute then
    EntryIconMgr:SetIconVisibility(EntryIconMgr.ENUM_SPRAY_EXCHANGE, false)
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_DECAL_EXCHANGE_ENTRY_CHANGED)
  end
end
function EntryIconMgr:OnWardrobeSubPageChanged(newPageId, newSubPageId)
  self:RefreshEnterIcon(newPageId, newSubPageId)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_DECAL_EXCHANGE_ENTRY_CHANGED)
end
function EntryIconMgr:RefreshEnterIcon(PageId, SubPageId)
  local bShowSprayExchange = self:CanShowSprayExchange(PageId, SubPageId)
  self:SetIconVisibility(EntryIconMgr.ENUM_SPRAY_EXCHANGE, bShowSprayExchange)
  local bShowSetting = self:CanShowSetting(PageId, SubPageId)
  self:SetIconVisibilityNoCreat(EntryIconMgr.ENUM_DISPLAY_SETTING, bShowSetting)
  local bShowCharacter = self:CanShowCharacter(PageId, SubPageId)
  self:SetIconVisibility(EntryIconMgr.ENUM_CHARACTER, bShowCharacter)
  local bShowDecompose = self:CanShowDecompose(PageId, SubPageId)
  self:SetIconVisibility(EntryIconMgr.ENUM_DECOMPOSE, bShowDecompose)
  local bShowGender = self:CanShowGenderEntry(PageId, SubPageId)
  self:SetIconVisibility(EntryIconMgr.ENUM_GENDER, bShowGender)
  self:SetIconVisibility(EntryIconMgr.ENUM_MINI_TV_SWITCH, self:CanShowMiniTvSwitch(PageId, SubPageId))
end
function EntryIconMgr:RefreshGunEntryIcons(nGunId)
  local logic_legend_weapon = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_legend_weapon)
  local bIsLegendWeapon = logic_legend_weapon:IsLegendWeaponItem(nGunId)
  self:SetIconVisibility(EntryIconMgr.ENUM_DECOMPOSE, not bIsLegendWeapon)
  self:SetIconVisibility(EntryIconMgr.ENUM_SUBSCRIBE_SHARE, not bIsLegendWeapon and self:CanShowSubscribeShareEntry())
end
function EntryIconMgr:CanShowSubscribeShareEntry(pageId)
  local logic_share_bag_privilege_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_privilege_util)
  if not logic_share_bag_privilege_util:IsAnyShardBagValid() then
    return false
  end
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  return wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Avatar == pageId
end
function EntryIconMgr:CanShowGenderEntry(pageId, subPageId)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Avatar == pageId then
    return true
  end
  if wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Weapon == pageId then
    return true
  end
  if wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Parachute == pageId and (not subPageId or not GenderEntryLimitSubPage[subPageId]) then
    return true
  end
  if wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Appearance == pageId then
    return true
  end
  return false
end
function EntryIconMgr:CanShowSprayExchange(pageId, subPageId)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if subPageId ~= wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_plating then
    return false
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local ItemMacros = require("client.slua.config.ClientMacros.ItemMacros")
  local Count = wardrobe_data:GetHallDepotItemCountByItemSubTypeAndQuality(ENUM_ITEM_SUBTYPE.Spray_Pattern, true, ItemMacros.QUALITY_PURPLE)
  return 0 < Count
end
function EntryIconMgr:CanShowSetting(pageId, subPageId)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if subPageId == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_gloves then
    return false
  end
  if subPageId == wardrobe_macro.ENUM_WardrobeSubTabString.Enum_WardrobeSubTabString_SpecialVehicle then
    return false
  end
  return true
end
function EntryIconMgr:CanShowCharacter(pageId, subPageId)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if subPageId == wardrobe_macro.ENUM_WardrobeSubTabString.Enum_WardrobeSubTabString_SpecialVehicle then
    return false
  end
  if subPageId == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_effect then
    return false
  end
  return true
end
function EntryIconMgr:CanShowDecompose(pageId, subPageId)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if subPageId == wardrobe_macro.ENUM_WardrobeSubTabString.Enum_WardrobeSubTabString_SpecialVehicle then
    return false
  end
  return true
end
function EntryIconMgr:IsCurrentGunLegendWeapon()
  local logic_wardrobe_gun = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
  local nGunId = logic_wardrobe_gun:GetPreviewGunResID()
  if not nGunId or nGunId == 0 then
    return false
  end
  local logic_legend_weapon = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_legend_weapon)
  return logic_legend_weapon:IsLegendWeaponItem(nGunId)
end
function EntryIconMgr:CanShowMiniTvSwitch(pageId, subPageId)
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MINI_TV_REV) then
    return false
  end
  return subPageId == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_MiniTVSuit
end
return EntryIconMgr