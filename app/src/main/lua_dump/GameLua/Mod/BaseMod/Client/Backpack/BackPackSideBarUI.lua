local BackPackSideBarUI = {}
function BackPackSideBarUI:OnInitialize()
  print(bWriteLog and "BackPackSideBarUI:OnInitialize")
end
function BackPackSideBarUI:RegistEvents()
  print(bWriteLog and "BackPackSideBarUI:RegistEvents")
  self:AddOnClickedEventByControl(self.UIRoot.Button_AllItem, self.OnClickButtonAllItem, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ArmorFit, self.OnClickButtonArmorFit, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_WeaponFit, self.OnClickButtonWeaponFit, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Consumption, self.OnClickButtonConsumption, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Other, self.OnClickButtonOther, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Clothing, self.OnClickButtonClothing, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Store, self.OnClickButtonStore, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_CloseBackPackUI, self.OnClickButtonCloseBackPackUI, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Drop, self.OnClickButtonCloseBackPackUI, self)
  if self.UIRoot and self.UIRoot.Button_AllExcluded then
    self:AddOnClickedEventByControl(self.UIRoot.Button_AllExcluded, self.OnClickButtonFirework, self)
  end
  if self.UIRoot and self.UIRoot.Button_MapStore then
    self:AddOnClickedEventByControl(self.UIRoot.Button_MapStore, self.OnClickButtonMapStore, self)
  end
end
function BackPackSideBarUI:OnClickButtonAllItem()
  local EBackpackTab = UEnums.EBackpackTab
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_NOTIFY_PARENT_SWITCHTAB, EBackpackTab.AllItem, 0)
end
function BackPackSideBarUI:OnClickButtonArmorFit()
  local EBackpackTab = UEnums.EBackpackTab
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_NOTIFY_PARENT_SWITCHTAB, EBackpackTab.ArmorItem, 0)
end
function BackPackSideBarUI:OnClickButtonWeaponFit()
  local EBackpackTab = UEnums.EBackpackTab
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_NOTIFY_PARENT_SWITCHTAB, EBackpackTab.WeaponFitItem, 0)
end
function BackPackSideBarUI:OnClickButtonConsumption()
  local EBackpackTab = UEnums.EBackpackTab
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_NOTIFY_PARENT_SWITCHTAB, EBackpackTab.ConsumableItem, 1)
end
function BackPackSideBarUI:OnClickButtonOther()
  local EBackpackTab = UEnums.EBackpackTab
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_NOTIFY_PARENT_SWITCHTAB, EBackpackTab.SundriesItem, 1)
end
function BackPackSideBarUI:OnClickButtonClothing()
  local EBackpackTab = UEnums.EBackpackTab
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_NOTIFY_PARENT_SWITCHTAB, EBackpackTab.AvatarItem, 2)
end
function BackPackSideBarUI:OnClickButtonStore()
  local EBackpackTab = UEnums.EBackpackTab
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_NOTIFY_PARENT_SWITCHTAB, EBackpackTab.StoreItem, 2)
end
function BackPackSideBarUI:OnClickButtonFirework()
  local EBackpackTab = UEnums.EBackpackTab
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_NOTIFY_PARENT_SWITCHTAB, EBackpackTab.AllExcludedItem, 1)
end
function BackPackSideBarUI:OnClickButtonMapStore()
  local EBackpackTab = UEnums.EBackpackTab
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_NOTIFY_PARENT_SWITCHTAB, EBackpackTab.UGCProp, 1)
end
function BackPackSideBarUI:OnClickButtonCloseBackPackUI()
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_NOTIFY_PARENT_CLOSE)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, BackPackSideBarUI)