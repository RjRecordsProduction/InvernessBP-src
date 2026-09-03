local StoreItemBase = {}
function StoreItemBase:ctor()
  StoreItemBase.__super.ctor(self)
  self.ParentUI = nil
  self.Index = nil
  self.SubIndex = nil
  self.Data = nil
  self.Type = nil
  self._CachedCustomItemUIMap = {}
end
function StoreItemBase:OnRefresh(Widget, Data, Index, SubIndex, Type)
end
function StoreItemBase:GetStoreUI()
  return self.ParentUI
end
function StoreItemBase:GetData()
  return self.Data
end
function StoreItemBase:GetIndex()
  return self.Index, self.SubIndex
end
function StoreItemBase:GetType()
  return self.Type
end
function StoreItemBase:OnClicked(Widget)
end
function StoreItemBase:OnClose()
  self.ParentUI = nil
  self.Index = nil
  self.SubIndex = nil
  self.Data = nil
  self.Type = nil
  self._CachedCustomItemUIMap = nil
end
function StoreItemBase:BindCustomWidgetClickEvent(Widget, CustomItemUI, Data, StoreUI)
  if not CustomItemUI or not StoreUI then
    return
  end
  local ButtonControl = CustomItemUI.UIRoot.Button_Click or CustomItemUI.UIRoot.Button_Root or CustomItemUI.UIRoot
  if not slua.isValid(ButtonControl) or not ButtonControl.OnClicked then
    print(bWriteLog and string.format("StoreItemBase:BindCustomWidgetClickEvent [1] Button control not found or has no OnClicked event, ItemID:%s", tostring(Data.ItemID)))
    return
  end
  CustomItemUI:AddControlEventByControl(ButtonControl, "OnClicked", function()
    if StoreUI.OnClickStoreItem then
      local Index = CustomItemUI.Index
      local SubIndex = CustomItemUI.SubIndex
      local Type = CustomItemUI.Type
      print(bWriteLog and string.format("StoreItemBase:BindCustomWidgetClickEvent [Clicked] ItemID:%s, Index:%s, SubIndex:%s, Type:%s", tostring(Data.ItemID), tostring(Index), tostring(SubIndex), tostring(Type)))
      StoreUI:OnClickStoreItem(CustomItemUI.UIRoot, Index, SubIndex, Type)
    end
  end)
  print(bWriteLog and string.format("StoreItemBase:BindCustomWidgetClickEvent [2] Click event bound successfully, ItemID:%s", tostring(Data.ItemID)))
end
function StoreItemBase:ShowCustomDisplay(Widget, Data, UIConfigKey, StoreUI)
  if not (Widget and UIConfigKey) or UIConfigKey == "" then
    return false
  end
  local UIConfig = UIManager.UI_Config[UIConfigKey]
  if not UIConfig then
    return false
  end
  if Widget.CanvasPanel_Main and slua.isValid(Widget.CanvasPanel_Main) then
    Widget.CanvasPanel_Main:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local CustomContainer = Widget.CanvasPanel_Custom
  if not slua.isValid(CustomContainer) then
    print(bWriteLog and string.format("StoreItemBase:ShowCustomDisplay [1] CanvasPanel_Custom not found in widget blueprint, ItemID:%s", tostring(Data.ItemID)))
    return false
  end
  CustomContainer:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if not self._CachedCustomItemUIMap[Widget] then
    self._CachedCustomItemUIMap[Widget] = {}
  end
  local WidgetCache = self._CachedCustomItemUIMap[Widget]
  local CustomItemUI = WidgetCache[UIConfigKey]
  local bHasChild = CustomContainer:GetChildrenCount() > 0
  if CustomItemUI and not bHasChild then
    CustomItemUI = nil
    self._CachedCustomItemUIMap[Widget] = {}
    WidgetCache = self._CachedCustomItemUIMap[Widget]
  end
  for CachedKey, CachedUI in pairs(WidgetCache) do
    if CachedKey ~= UIConfigKey and CachedUI and CachedUI.SetWidgetVisibility then
      CachedUI:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  if not CustomItemUI then
    CustomItemUI = StoreUI:CreateChildWindow(CustomContainer, UIConfig)
    if not CustomItemUI then
      print(bWriteLog and string.format("StoreItemBase:ShowCustomDisplay [3] Failed to create custom widget, UIConfigKey:%s", tostring(UIConfigKey)))
      return false
    end
    WidgetCache[UIConfigKey] = CustomItemUI
    CustomItemUI.ParentUI = StoreUI
    self:BindCustomWidgetClickEvent(Widget, CustomItemUI, Data, StoreUI)
    print(bWriteLog and string.format("StoreItemBase:ShowCustomDisplay [4] Custom widget created and mounted, ItemID:%s, UIConfigKey:%s", tostring(Data.ItemID), tostring(UIConfigKey)))
  end
  CustomItemUI:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  CustomItemUI.Index = self.Index
  CustomItemUI.SubIndex = self.SubIndex
  CustomItemUI.Type = self.Type
  CustomItemUI:OnRefreshCurrentWidget(CustomItemUI.UIRoot, Data, StoreUI)
  return true
end
function StoreItemBase:ShowDefaultDisplay(Widget)
  if not Widget then
    return
  end
  if Widget.CanvasPanel_Main and slua.isValid(Widget.CanvasPanel_Main) then
    Widget.CanvasPanel_Main:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  if Widget.CanvasPanel_Custom and slua.isValid(Widget.CanvasPanel_Custom) then
    Widget.CanvasPanel_Custom:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if self._CachedCustomItemUIMap and self._CachedCustomItemUIMap[Widget] then
    for _, CachedUI in pairs(self._CachedCustomItemUIMap[Widget]) do
      if CachedUI and CachedUI.SetWidgetVisibility then
        CachedUI:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    end
  end
end
function StoreItemBase:OnRefreshCurrentWidget(Widget, Data, StoreUI)
end
local class = require("class")
local base = require("client.slua_ui_framework.base")
local CStoreItemBase = class(base, nil, StoreItemBase)
return CStoreItemBase