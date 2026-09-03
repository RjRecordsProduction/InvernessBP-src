local EntryIconGender = {}
local gender2SwitcherIndex = {
  [1] = 0,
  [2] = 1
}
function EntryIconGender:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_REFRESH_CURRENT_TAB, self.UpdateGenderButton, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_AVATAR_LIST, self.UpdateGender, self)
end
function EntryIconGender:OnPostInitialize()
  local switcherIndex = gender2SwitcherIndex[AvatarData.GetGameGender()] or 0
  self.UIRoot.WidgetSwitcher_gender:SetActiveWidgetIndex(switcherIndex)
end
function EntryIconGender:OnEntryButtonClick()
  self:PlayAudio(sound_config.click_v1)
  local bCanSwitchGender = true
  local tRoleWear = AvatarData.GetRoleWear()
  if not next(tRoleWear) then
    local NewCharacterNetSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterNetSystem)
    bCanSwitchGender = not NewCharacterNetSystem:CurRoleIsCharacter()
  else
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local StoreUtils = require("client.slua.logic.store.utils.store_utils")
    for _, insId in pairs(tRoleWear) do
      local itemData = wardrobe_data:GetHallDepotItemDataByInsID(insId)
      if itemData and itemData.resID and not StoreUtils.IsCanSwitchSex(itemData.resID) then
        bCanSwitchGender = false
        break
      end
    end
  end
  if not bCanSwitchGender then
    ShowNotice(LocUtil.LocalizeResFormat(8797))
    return
  end
  local WardrobeAppearance = require("client.slua.logic.wardrobe.logic_wardrobe_appearance")
  WardrobeAppearance:SwitchGender()
end
function EntryIconGender:IsFemale()
  local gender = AvatarData.GetGameGender()
  return gender == 2
end
function EntryIconGender:UpdateGenderButton()
  local switcherIndex = gender2SwitcherIndex[AvatarData.GetGameGender()]
  self.UIRoot.WidgetSwitcher_gender:SetActiveWidgetIndex(switcherIndex)
end
function EntryIconGender:UpdateGender()
  self:UpdateGenderButton()
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local pageId = logic_wardrobe.GetCurrentPageId()
  local tabId = logic_wardrobe.GetCurrentTabId()
  if wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Appearance == pageId then
    local bKeepSubTab = tabId ~= wardrobe_macro.ENUM_WardrobeSubTabString.Enum_WardrobeSubTabString_Beard
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_REFRESH_PAGE, bKeepSubTab)
  end
end
local class = require("class")
local ui_EntryIconBase = require("client.slua.umg.Wardrobe.entry.entry_icon_base")
local CEntryIconGender = class(ui_EntryIconBase, nil, EntryIconGender)
return CEntryIconGender