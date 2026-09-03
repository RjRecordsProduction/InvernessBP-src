local Collect_Library_Clothe_Tab_Item_UIBP = {}
function Collect_Library_Clothe_Tab_Item_UIBP:OnRefresh(_, selectIndex)
  local bSelect = selectIndex == self.index
  local widgetIndex = 0
  if bSelect then
    widgetIndex = 1
  end
  if self.data and self.data.SeriesName then
    self.UIRoot["TextBlock_" .. widgetIndex]:SetText(self.data.SeriesName)
  end
  self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(widgetIndex)
  self:RefreshTabReddot()
end
function Collect_Library_Clothe_Tab_Item_UIBP:RefreshTabReddot()
  if not self.data or not next(self.data) then
    return
  end
  local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
  if not reddot_node_collect_manager:ShowNewReddot(self.UIRoot, self.UIRoot.Reddot_Anchor, self.data.SeriesID) then
    local collect_clothe_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_clothe_module)
    local bShow = collect_clothe_module:IsRedOneClothe(self.data)
    reddot_node_collect_manager:ShowBoxReddot(self.UIRoot, self.UIRoot.Reddot_Anchor, self.data.SeriesID, bShow)
  end
end
function Collect_Library_Clothe_Tab_Item_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Sort, self.OnClickTab, self)
end
function Collect_Library_Clothe_Tab_Item_UIBP:OnClickTab()
  self:PlayAudio(sound_config.click_v1)
  local Collect_Library_Clothe_UIBP = self:GetLoopScrollBoxParentUI()
  Collect_Library_Clothe_UIBP:OnClickTab(self.index)
  self:RefreshTabReddot()
end
function Collect_Library_Clothe_Tab_Item_UIBP:OnClose()
  local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
  reddot_node_collect_manager:HideOldReddotWithMap(self.UIRoot)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.component.scroll_box_child_base")
local CCollect_Library_Weapon_Tab_Item_UIBP = class(ui_base, nil, Collect_Library_Clothe_Tab_Item_UIBP)
return CCollect_Library_Weapon_Tab_Item_UIBP