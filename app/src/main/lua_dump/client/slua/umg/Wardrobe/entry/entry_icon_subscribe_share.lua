local EntryIconSubscribeShare = {}
function EntryIconSubscribeShare:RegistEvents()
  EntryIconSubscribeShare.__super.RegistEvents(self)
  local display_setting_redpoint_data = require("client.slua.logic.wardrobe.display_setting_redpoint_data")
  local redPointData = display_setting_redpoint_data.GetData()
  if redPointData then
    self:AddDataListener(redPointData, "checked", function(oldValue, value)
      self:SetWidgetVisible(self.UIRoot.Image_Reddot, not value)
    end)
  end
end
function EntryIconSubscribeShare:OnEntryButtonClick()
  self:PlayAudio(sound_config.click_v1)
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  local SubscribeEnumConfig = require("client.slua.logic.subscribe.logic_subscribe_enum_config")
  if subscribeModuleObj:Get_Is_Valid(SubscribeEnumConfig.ENUM_SubId.Super) then
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SUBSCRIBE_CLEAR_TIPS)
    local logic_share_bag_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_guide)
    logic_share_bag_guide:SetShareBagGuideStatus(logic_share_bag_guide.SHARE_TYPE_SUBSCRIPBE, logic_share_bag_guide.GUIDETYPE_SUBSCRIBE_WARDROBE, logic_share_bag_guide.GUIDE_SHOWSTATUS_HAS_SHOWN)
  end
  local logic_share_bag_privilege_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_privilege_util)
  local preferShareType = self:_GetPreferShareType()
  logic_share_bag_privilege_util:OpenShareBagConfigPanel(preferShareType)
end
function EntryIconSubscribeShare:OnClose()
  EntryIconSubscribeShare.__super.OnClose(self)
end
function EntryIconSubscribeShare:_GetPreferShareType()
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local curPageId = WardrobeLogicManager:GetCurrentPageId()
  local share_bag_macros = require("client.slua.logic.share_bag.share_bag_macros")
  if curPageId == wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Avatar then
    local logic_share_bag_privilege_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_privilege_util)
    local lastShowShareType = logic_share_bag_privilege_util:GetLastShowShareType()
    if lastShowShareType == share_bag_macros.ENUM_ShareType.Subscribe or lastShowShareType == share_bag_macros.ENUM_ShareType.Collection then
      return lastShowShareType
    end
    if logic_share_bag_privilege_util:HasSharingPrivilege(share_bag_macros.ENUM_ShareType.Collection) then
      return share_bag_macros.ENUM_ShareType.Collection
    end
    return share_bag_macros.ENUM_ShareType.Subscribe
  elseif curPageId == wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Weapon then
    return share_bag_macros.ENUM_ShareType.Weapon
  end
  return nil
end
local class = require("class")
local ui_EntryIconBase = require("client.slua.umg.Wardrobe.entry.entry_icon_base")
local CEntryIconSubscribeShare = class(ui_EntryIconBase, nil, EntryIconSubscribeShare)
return CEntryIconSubscribeShare