local CircleChooseUtil = require("GameLua.Mod.BaseMod.Client.InGameUI.NewCircleChooseUI.CircleChooseUtil")
local TableUtil = require("common.table_util")
local TableUtil_ClearArray = TableUtil.ClearArray
local table_remove = table.remove
local GrenadesListPanel = {}
function GrenadesListPanel:ctor(selfType, BattleItemDataList, bIsGrenadePanel)
  self.AutoCollapseTimer = nil
  self.AutoCollapseTime = 2.0
  self.IsListExpand = false
  self.  self.GrenadeWidgets = {}
  self.GrenadeWidgetsMarkIndex = 1
  self.  self.MaxRows = 5
end
function GrenadesListPanel:OnInitialize()
  GrenadesListPanel.__super.OnInitialize(self)
  self.UIRoot.ItemsBoxPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if not self.bIsGrenadePanel then
    self.MaxRows = 3
  end
end
function GrenadesListPanel:RegistEvents()
  GrenadesListPanel.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.NewButton_Arrow, self.ShowGrenadesListBox, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_CIRCLECHOOSEWIDGET, EVENTID_UPDATE_LIST_PANEL, self.UpdateList, self)
end
function GrenadesListPanel:OnPostInitialize()
  GrenadesListPanel.__super.OnPostInitialize(self)
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_ADD_TO_FORCE_HIDE_UI_ARRAY, self.UIRoot.CanvasPanel_spread)
end
function GrenadesListPanel:OnClose()
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_REMOVE_FROM_FORCE_HIDE_UI_ARRAY, self.UIRoot.CanvasPanel_spread)
  GrenadesListPanel.__super.OnClose(self)
end
function GrenadesListPanel:Close()
  if self.AutoCollapseTimer then
    self:RemoveGameTimer(self.AutoCollapseTimer)
    self.AutoCollapseTimer = nil
  end
  self:CloseGrenadeList()
  GrenadesListPanel.__super.Close(self)
end
function GrenadesListPanel:UpdateList(_, _, BattleItemDataList, bGrenades)
  if self.bIsGrenadePanel ~= bGrenades then
    return
  end
  self.  if self.IsListExpand then
    self:UpdateGrenadesBox()
  end
  self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function GrenadesListPanel:CreateGrenadeList()
  self.GrenadeWidgetsMarkIndex = 1
  if not self.bIsGrenadePanel then
    self:CreateMedsList()
    return
  end
  local Count = #self.BattleItemDataList
  local MaxColumn = math.ceil((Count - 1) / self.MaxRows)
  for i = self.MaxRows, 1, -1 do
    local Index = self.MaxRows - i + 1
    self:CreateGrenadeListItem(self.BattleItemDataList[Index + 1], i - 1, 0)
  end
  for Column = 1, MaxColumn - 1 do
    for Row = 0, self.MaxRows - 1 do
      local Index = Column * self.MaxRows + Row + 2
      self:CreateGrenadeListItem(self.BattleItemDataList[Index], Row, Column)
    end
  end
end
function GrenadesListPanel:CreateMedsList()
  local Count = #self.BattleItemDataList
  local MaxColumn = math.ceil((Count - 1) / self.MaxRows)
  for i = self.MaxRows, 1, -1 do
    local Index = self.MaxRows - i + 1
    self:CreateGrenadeListItem(self.BattleItemDataList[Index + 1], i - 1, MaxColumn - 1)
  end
  for Column = MaxColumn - 2, 0, -1 do
    for Row = 0, self.MaxRows - 1 do
      local NewCol = MaxColumn - 1 - Column
      local Index = NewCol * self.MaxRows + Row + 2
      self:CreateGrenadeListItem(self.BattleItemDataList[Index], Row, Column)
    end
  end
end
function GrenadesListPanel:CloseGrenadeList()
  for Index, Value in ipairs(self.GrenadeWidgets) do
    Value:Close()
  end
  TableUtil_ClearArray(self.GrenadeWidgets)
end
function GrenadesListPanel:CreateGrenadeListItem(BattleItemData, Row, Column)
  if not BattleItemData then
    return
  end
  local bIsMedThrow = false
  if self.bIsGrenadePanel and CircleChooseUtil.IsAMedicine(BattleItemData.DefineID.TypeSpecificID) then
    bIsMedThrow = true
  end
  local GrenadeWidget
  local Index = self.GrenadeWidgetsMarkIndex
  local Count = #self.GrenadeWidgets
  while Index <= Count do
    GrenadeWidget = self.GrenadeWidgets[Index]
    if GrenadeWidget.BattleItemData.DefineID.TypeSpecificID == BattleItemData.DefineID.TypeSpecificID then
      break
    end
    GrenadeWidget = nil
    Index = Index + 1
  end
  if GrenadeWidget then
    local SwapGrenadeWidget = self.GrenadeWidgets[self.GrenadeWidgetsMarkIndex]
    self.GrenadeWidgets[self.GrenadeWidgetsMarkIndex] = GrenadeWidget
    self.GrenadeWidgets[Index] = SwapGrenadeWidget
  else
    GrenadeWidget = self:CreateChildWindow("ItemsBoxPanel", UIManager.UI_Config_InGame.GrenadeListItem)
    table.insert(self.GrenadeWidgets, self.GrenadeWidgetsMarkIndex, GrenadeWidget)
  end
  self.GrenadeWidgetsMarkIndex = self.GrenadeWidgetsMarkIndex + 1
  GrenadeWidget.UIRoot.Slot:SetRow(Row)
  GrenadeWidget.UIRoot.Slot:SetColumn(Column)
  GrenadeWidget:SetData(BattleItemData, bIsMedThrow)
end
function GrenadesListPanel:ShowGrenadesListBox()
  print(bWriteLog and "CircleChooseGrenadeUITEST::GrenadeListPanel clicked arrow, isListExpand: ", self.IsListExpand)
  self.IsListExpand = not self.IsListExpand
  self:PlayAudio(sound_config.CircleChoose_ListExpand)
  self:UpdateInteractiveTriangle()
  self:UpdateGrenadesBox()
  self:SetAutoCollapse()
end
function GrenadesListPanel:UpdateInteractiveTriangle()
  print(bWriteLog and "CircleChooseGrenadeUITEST::GrenadeListPanel UpdateInteractive Triangle, isListExpand: ", self.IsListExpand)
  if self.IsListExpand then
    self.UIRoot.WidgetSwitcher_Arrow:SetActiveWidgetIndex(1)
  else
    self.UIRoot.WidgetSwitcher_Arrow:SetActiveWidgetIndex(0)
  end
end
function GrenadesListPanel:UpdateGrenadesBox()
  self:AddTimer(0, function()
    if self.IsListExpand then
      self.UIRoot.ItemsBoxPanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self:CreateGrenadeList()
      local DataLength = #self.BattleItemDataList - 1
      local Count = #self.GrenadeWidgets
      while DataLength < Count do
        local GrenadeWidget = self.GrenadeWidgets[Count]
        if GrenadeWidget then
          GrenadeWidget:Close()
        end
        table_remove(self.GrenadeWidgets, Count)
        Count = Count - 1
      end
    else
      self.UIRoot.ItemsBoxPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end)
end
function GrenadesListPanel:CollapseFolder()
  self.IsListExpand = false
  self:UpdateInteractiveTriangle()
  self:UpdateGrenadesBox()
end
function GrenadesListPanel:SetAutoCollapse()
  if self.IsListExpand then
    if self.AutoCollapseTimer then
      self:RemoveGameTimer(self.AutoCollapseTimer)
      self.AutoCollapseTimer = nil
    end
    self.AutoCollapseTimer = self:AddGameTimer(self.AutoCollapseTime, false, function()
      self:CollapseFolder()
    end)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, GrenadesListPanel)