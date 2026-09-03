local entry_icon_minitv_switch_type = {}
function entry_icon_minitv_switch_type:ctor()
  self.minitvSubTab = nil
end
function entry_icon_minitv_switch_type:RegistEvents()
  entry_icon_minitv_switch_type.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_MINI_TV_SUB_TAB, self.OnMiniTvSubTabChange, self)
end
function entry_icon_minitv_switch_type:OnPostInitialize()
  entry_icon_minitv_switch_type.__super.OnPostInitialize(self)
  self:UpdateMiniTvSwithVisibility()
end
function entry_icon_minitv_switch_type:OnEntryButtonClick()
  self:PlayAudio(sound_config.click_v1)
  local WeaponModelLogic = require("client.slua.logic.manager.WeaponModelLogic")
  local ShowActor = WeaponModelLogic.GetProperWeaponShowActor()
  if not ShowActor then
    return
  end
  local MiniTvActor = ShowActor:GetMiniTvShowActor()
  if not MiniTvActor then
    return
  end
  MiniTvActor:SwitchShowType()
end
function entry_icon_minitv_switch_type:UpdateMiniTvSwithVisibility()
  if self.minitvSubTab == 1 then
    self:SelfHitTestInvisible()
  else
    self:Collapsed()
  end
end
function entry_icon_minitv_switch_type:OnMiniTvSubTabChange(_, __, subTab)
  self.minitvSubTab = subTab
  self:UpdateMiniTvSwithVisibility()
end
local class = require("class")
local ui_EntryIconBase = require("client.slua.umg.Wardrobe.entry.entry_icon_base")
local Centry_icon_minitv_switch_type = class(ui_EntryIconBase, nil, entry_icon_minitv_switch_type)
return Centry_icon_minitv_switch_type