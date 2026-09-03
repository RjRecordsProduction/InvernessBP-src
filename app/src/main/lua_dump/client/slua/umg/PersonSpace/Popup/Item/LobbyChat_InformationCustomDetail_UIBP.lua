local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
local custom_presentation_config = require("client.slua.logic.person_space.custom_presentation_config")
local LobbyChat_InformationCustomDetail_UIBP = {}
local EnumDirType = {
  LEFT_TOP = 1,
  RIGHT_TOP = 2,
  LEFT_BOTTOM = 3,
  RIGHT_BOTTOM = 4
}
local EnumShowType = {
  ["2x2"] = 1,
  ["1x2"] = 2,
  ["1x1"] = 3
}
local GetTableSize = function(t)
  local Count = 0
  for _, __ in pairs(t) do
    Count = Count + 1
  end
  return Count
end
function LobbyChat_InformationCustomDetail_UIBP:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_DELETE, self.OnDeleteAllItem, self)
end
function LobbyChat_InformationCustomDetail_UIBP:OnInitialize()
  self.LoopScrollGridActionSlot = self:InitScrollBox(self.UIRoot.LoopScrollGrid)
  self.LoopScrollGridActionSlot:SetRefreshItemCallback(self.OnScrollBoxCallBack, self)
  local emptyTb = {}
  self.isItemRegistEvent = {}
  for i = 1, 16 do
    table.insert(emptyTb, {index = i})
    self.isItemRegistEvent[i] = false
  end
  self.LoopScrollGridActionSlot:SetData(emptyTb)
  self.spawnItemList = {}
  self.isInitEvent = false
end
function LobbyChat_InformationCustomDetail_UIBP:OnPostInitialize()
  self:ResetAllItemData()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Tips, false)
end
function LobbyChat_InformationCustomDetail_UIBP:OnShow()
end
function LobbyChat_InformationCustomDetail_UIBP:OnHide()
  self.isEdit = false
end
function LobbyChat_InformationCustomDetail_UIBP:OnClose()
  self:RecycleAllItemUI()
  self.isEdit = false
  self.uid = nil
end
function LobbyChat_InformationCustomDetail_UIBP:RecycleItemUI(index)
  local itemUI = self.spawnItemList[index]
  if itemUI then
    if slua.isValid(itemUI) and itemUI.Close then
      itemUI:Close()
    end
    self.spawnItemList[index] = nil
  end
  local widget = self.LoopScrollGridActionSlot and self.LoopScrollGridActionSlot:GetIndexOfWidget(index)
  if widget and widget.SizeBox_ItemParent then
    widget.SizeBox_ItemParent:ClearChildren()
  end
end
function LobbyChat_InformationCustomDetail_UIBP:RecycleAllItemUI()
  if self.spawnItemList then
    for _, itemUI in pairs(self.spawnItemList) do
      if itemUI.Close then
        itemUI:Close()
      end
    end
  end
  self.spawnItemList = {}
end
function LobbyChat_InformationCustomDetail_UIBP:ResetAllItemData()
  self.itemData = {}
  for row = 1, 4 do
    self.itemData[row] = {}
    for col = 1, 4 do
      self.itemData[row][col] = {isCanAccept = true, info = nil}
    end
  end
end
function LobbyChat_InformationCustomDetail_UIBP:SetDataByUid(uid)
  self.  self.isInitCurData = false
  self.isEdit = false
  self:RefreshCurShowData()
end
function LobbyChat_InformationCustomDetail_UIBP:HideBg()
  self.UIRoot.Image_0:SetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function LobbyChat_InformationCustomDetail_UIBP:SetEdit(isEdit)
  self.  if isEdit then
    if not self.isInitEvent then
      self.isInitEvent = true
      self.LoopScrollGridActionSlot:AddItemWidgetChildEvent("Common_DragDrop_Item", "OnDragSuccess", self.OnActionSlotDrop, self)
      self.LoopScrollGridActionSlot:AddItemWidgetChildEvent("Common_DragDrop_Item", "OnDragReadyToShape", self.OnDragReadyToShape, self)
      self.LoopScrollGridActionSlot:AddItemWidgetChildEvent("Common_DragDrop_Item", "OnDragCanCeled", self.OnActionSlotRemove, self)
      self.LoopScrollGridActionSlot:AddItemWidgetChildEvent("Common_DragDrop_Item", "OnDragClicked", self.OnClickedItemSlotItem, self)
      self.LoopScrollGridActionSlot:AddItemWidgetChildEvent("Common_DragDrop_Item", "OnTestDragEnter", self.OnDragStart, self)
      self.LoopScrollGridActionSlot:AddItemWidgetChildEvent("Common_DragDrop_Item", "OnItemTouchMoved", self.OnItemTouchMoved, self)
      self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_ITEM_DRAG, self.OnDragBegin, self)
      self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_ITEM_CLICK, self.OnItemSelect, self)
    end
  else
    self:OnResetBox()
  end
end
function LobbyChat_InformationCustomDetail_UIBP:OnResetBox()
  local allCnt = self.LoopScrollGridActionSlot:GetItemCount()
  if allCnt then
    for i = 1, allCnt do
      local widget = self.LoopScrollGridActionSlot:GetIndexOfWidget(i)
      if widget then
        self:SetWidgetVisible(widget.CanvasPanel_Add, false)
        self:SetWidgetVisible(widget.Button_remove, false)
        self:SetWidgetVisible(widget.Button_ShowTips, not self.isEdit, true)
        if not self.isItemRegistEvent[i] then
          self:AddOnClickedEventByControl(widget.Button_remove, self.OnClickButton_remove, self)
          if not self.isEdit then
            self:AddOnClickedEventByControl(widget.Button_ShowTips, function()
              self:OnClickButton_ShowTips(i)
            end, self)
          end
        end
      end
    end
  end
end
function LobbyChat_InformationCustomDetail_UIBP:OnRegisterDrag(isCanDrag, showType)
  local allCnt = self.LoopScrollGridActionSlot:GetItemCount()
  if allCnt then
    for i = 1, allCnt do
      local widget = self.LoopScrollGridActionSlot:GetIndexOfWidget(i)
      if widget then
        self:OnRefreshActionSlotItem(widget, isCanDrag, showType)
      end
    end
  end
end
function LobbyChat_InformationCustomDetail_UIBP:OnRegisterLeftDrag()
  local allCnt = self.LoopScrollGridActionSlot:GetItemCount()
  if allCnt then
    for i = 1, allCnt do
      local widget = self.LoopScrollGridActionSlot:GetIndexOfWidget(i)
      if widget then
        self:SetWidgetVisible(widget.Button_ShowTips, false)
        local row, col = self:IndexToRowCol(i)
        local itemInfo = self.itemData[row][col]
        if itemInfo.info then
          self:OnRefreshActionSlotItem(widget, true, itemInfo.info.showType)
        else
          self:OnRefreshActionSlotItem(widget, false)
        end
      end
    end
  end
  self:ResetAllPreview()
end
function LobbyChat_InformationCustomDetail_UIBP:OnScrollBoxCallBack()
  local maxCnt = self.LoopScrollGridActionSlot:GetItemCount()
  local widget = self.LoopScrollGridActionSlot:GetIndexOfWidget(maxCnt)
  if not widget then
    return
  end
  self:OnResetBox()
  if self.isEdit then
    self:OnRegisterLeftDrag()
  else
    self:OnRegisterDrag(false)
  end
  self:RefreshCurShowData()
end
function LobbyChat_InformationCustomDetail_UIBP:OnRefreshActionSlotItem(widget, isCanDrag, inShowType)
  local DragDropItem = widget.Common_DragDrop_Item
  if not isCanDrag then
    DragDropItem:SetEnable(false)
    return
  end
  local logic_custom_presentation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_custom_presentation)
  local showType = inShowType or logic_custom_presentation:GetInformationType()
  local path = "/Game/UMG/UI_BP/Common/Info/Common_InformationCustom_Large_Item.Common_InformationCustom_Large_Item"
  if showType == 2 then
    path = "/Game/UMG/UI_BP/Common/Info/Common_InformationCustom_Middle_Item.Common_InformationCustom_Middle_Item"
  elseif showType == 3 then
    path = "/Game/UMG/UI_BP/Common/Info/Common_InformationCustom_Tiny_Item.Common_InformationCustom_Tiny_Item"
  end
  DragDropItem:SetEnable(isCanDrag)
  DragDropItem:RegisterDragWithDragPath(2, 0, 0, "", path, true)
  DragDropItem:RegisterDrop(2)
end
function LobbyChat_InformationCustomDetail_UIBP:SetPreviewWidget(indexList, isCan)
  for _, index in ipairs(indexList) do
    local widget = self.LoopScrollGridActionSlot:GetIndexOfWidget(index)
    if widget then
      self:SetWidgetVisible(widget.WidgetSwitcher_Review, true)
      widget.WidgetSwitcher_Review:SetActiveWidgetIndex(isCan and 0 or 1)
    end
  end
end
function LobbyChat_InformationCustomDetail_UIBP:SelectDir(showType, row, col)
  local allDir = {}
  if showType == EnumShowType["2x2"] then
    if row == 1 then
      if col == 4 then
        table.insert(allDir, EnumDirType.RIGHT_TOP)
      elseif col == 1 then
        table.insert(allDir, EnumDirType.LEFT_TOP)
      else
        table.insert(allDir, EnumDirType.LEFT_TOP)
        table.insert(allDir, EnumDirType.RIGHT_TOP)
      end
    elseif row == 4 then
      if col == 4 then
        table.insert(allDir, EnumDirType.RIGHT_BOTTOM)
      elseif col == 1 then
        table.insert(allDir, EnumDirType.LEFT_BOTTOM)
      else
        table.insert(allDir, EnumDirType.LEFT_BOTTOM)
        table.insert(allDir, EnumDirType.RIGHT_BOTTOM)
      end
    elseif col == 4 then
      table.insert(allDir, EnumDirType.RIGHT_TOP)
      table.insert(allDir, EnumDirType.RIGHT_BOTTOM)
    elseif col == 1 then
      table.insert(allDir, EnumDirType.LEFT_TOP)
      table.insert(allDir, EnumDirType.LEFT_BOTTOM)
    else
      table.insert(allDir, EnumDirType.LEFT_TOP)
      table.insert(allDir, EnumDirType.RIGHT_TOP)
      table.insert(allDir, EnumDirType.LEFT_BOTTOM)
      table.insert(allDir, EnumDirType.RIGHT_BOTTOM)
    end
  elseif showType == EnumShowType["1x2"] then
    if col == 4 then
      table.insert(allDir, EnumDirType.RIGHT_TOP)
    elseif col == 1 then
      table.insert(allDir, EnumDirType.LEFT_TOP)
    else
      table.insert(allDir, EnumDirType.LEFT_TOP)
      table.insert(allDir, EnumDirType.RIGHT_TOP)
    end
  elseif showType == EnumShowType["1x1"] then
    table.insert(allDir, EnumDirType.LEFT_TOP)
  end
  return allDir
end
function LobbyChat_InformationCustomDetail_UIBP:GetIndexListByDir(showType, row, col, dir)
  if showType == EnumShowType["2x2"] then
    if dir == EnumDirType.LEFT_TOP then
      return {
        self:RowColToIndex(row, col),
        self:RowColToIndex(row + 1, col),
        self:RowColToIndex(row, col + 1),
        self:RowColToIndex(row + 1, col + 1)
      }
    elseif dir == EnumDirType.RIGHT_TOP then
      return {
        self:RowColToIndex(row, col),
        self:RowColToIndex(row + 1, col),
        self:RowColToIndex(row, col - 1),
        self:RowColToIndex(row + 1, col - 1)
      }
    elseif dir == EnumDirType.LEFT_BOTTOM then
      return {
        self:RowColToIndex(row, col),
        self:RowColToIndex(row - 1, col),
        self:RowColToIndex(row, col + 1),
        self:RowColToIndex(row - 1, col + 1)
      }
    elseif dir == EnumDirType.RIGHT_BOTTOM then
      return {
        self:RowColToIndex(row, col),
        self:RowColToIndex(row - 1, col),
        self:RowColToIndex(row, col - 1),
        self:RowColToIndex(row - 1, col - 1)
      }
    end
  elseif showType == EnumShowType["1x2"] then
    if dir == EnumDirType.LEFT_TOP then
      return {
        self:RowColToIndex(row, col),
        self:RowColToIndex(row, col + 1)
      }
    elseif dir == EnumDirType.RIGHT_TOP then
      return {
        self:RowColToIndex(row, col),
        self:RowColToIndex(row, col - 1)
      }
    end
  elseif showType == EnumShowType["1x1"] then
    return {
      self:RowColToIndex(row, col)
    }
  end
end
function LobbyChat_InformationCustomDetail_UIBP:IsItemCanAcceptDrag(index, _showType, isShowReview)
  local logic_custom_presentation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_custom_presentation)
  local showType = _showType or logic_custom_presentation:GetInformationType()
  local row, col = self:IndexToRowCol(index)
  local allDir = self:SelectDir(showType, row, col)
  for dirIndex, dir in ipairs(allDir) do
    local indexList = self:GetIndexListByDir(showType, row, col, dir)
    local isCan = true
    for _, cellIndex in ipairs(indexList) do
      local indexRow, indexCol = self:IndexToRowCol(cellIndex)
      if not self.itemData[indexRow][indexCol].isCanAccept then
        isCan = false
        break
      end
    end
    if isCan then
      if isShowReview then
        self:SetPreviewWidget(indexList, true)
      end
      return true, dir
    end
    if dirIndex == #allDir then
      if isShowReview then
        self:SetPreviewWidget(indexList, false)
      end
      return false, dir
    end
  end
end
function LobbyChat_InformationCustomDetail_UIBP:ResetItemData(itemData, showType, isCantAccept, info, spawnIdx)
  itemData = itemData or {}
  itemData.isCanAccept = isCantAccept
  itemData.  itemData.  itemData.end
function LobbyChat_InformationCustomDetail_UIBP:IndexToRowCol(Index)
  local row = math.ceil(Index / 4)
  local col = Index % 4
  if col == 0 then
    col = 4
  end
  return row, col
end
function LobbyChat_InformationCustomDetail_UIBP:RowColToIndex(row, col)
  return (row - 1) * 4 + col
end
function LobbyChat_InformationCustomDetail_UIBP:SetItemCantAcceptDrag(index, showType, _isCantAccept, info)
  if not self.itemData then
    return
  end
  local isCantAccept = _isCantAccept or false
  local row, col = self:IndexToRowCol(index)
  local spawnIdx = index
  if showType == 1 then
    self:ResetItemData(self.itemData[row][col], showType, isCantAccept, info, spawnIdx)
    self:ResetItemData(self.itemData[row + 1][col], showType, isCantAccept, info, spawnIdx)
    self:ResetItemData(self.itemData[row][col + 1], showType, isCantAccept, info, spawnIdx)
    self:ResetItemData(self.itemData[row + 1][col + 1], showType, isCantAccept, info, spawnIdx)
  elseif showType == 2 then
    self:ResetItemData(self.itemData[row][col], showType, isCantAccept, info, spawnIdx)
    self:ResetItemData(self.itemData[row][col + 1], showType, isCantAccept, info, spawnIdx)
  elseif showType == 3 then
    self:ResetItemData(self.itemData[row][col], showType, isCantAccept, info, spawnIdx)
  end
  self:RefreshInformationAllItems()
end
function LobbyChat_InformationCustomDetail_UIBP:OnActionSlotDrop(DragWidget, Index, DragDropData)
  log("WardrobeAction:OnActionSlotDrop")
  local logic_custom_presentation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_custom_presentation)
  local info = logic_custom_presentation:GetCurDragData()
  if info then
    self:SetItemDataByIndex(Index, info.showType)
    self.isDrag = false
    self.dragSelf = false
    logic_custom_presentation:SetCurDragData(nil)
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_LEFT_ITEM_DRAG, false)
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_REFRESH_EQUIP)
  end
  self:OnRegisterLeftDrag()
end
function LobbyChat_InformationCustomDetail_UIBP:OnDragReadyToShape(DragWidget, Index, GeneratedWidget, DragDropData)
  if self.isDrag then
    return
  end
  self:SetWidgetVisible(GeneratedWidget, true)
  self:RefreshDragWidget(GeneratedWidget, DragDropData, Index)
end
function LobbyChat_InformationCustomDetail_UIBP:RefreshDragWidget(widget, data, index)
  local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
  local widgetItem = UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.Common_InformationCustom_Item, widget)
  if widgetItem then
    local row, col = self:IndexToRowCol(index)
    local info = self.itemData[row][col].info
    if info then
      widgetItem:SetIsLeft(true)
      widgetItem:OnRefresh(info)
      local logic_custom_presentation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_custom_presentation)
      logic_custom_presentation:SetCurDragData(info)
    end
  end
  widget.Border_Main.Slot:SetPosition(FVector2D(1, 1))
end
function LobbyChat_InformationCustomDetail_UIBP:OnActionSlotRemove(DragWidget, Index, DragDropData)
  if self.isDrag then
    return
  end
  self:RemoveItemByIndex(Index)
  local logic_custom_presentation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_custom_presentation)
  logic_custom_presentation:SetCurDragData(nil)
  self:ResetItems(true)
  self.dragSelf = false
  self:OnRegisterLeftDrag()
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_LEFT_ITEM_DRAG, false)
end
function LobbyChat_InformationCustomDetail_UIBP:BeginActionDragHint(selection)
end
function LobbyChat_InformationCustomDetail_UIBP:EndActionDragHint()
end
function LobbyChat_InformationCustomDetail_UIBP:OnDragStart(DragWidget, Index, DragDropData)
  self:PlayAudio(sound_config.click_v1)
  if self.isDrag or self.dragSelf then
    return
  end
  self.dragSelf = true
  self:OnRegisterDrag(true)
  local row, col = self:IndexToRowCol(Index)
  local data = self.itemData[row][col]
  if data and data.info then
    local logic_custom_presentation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_custom_presentation)
    data.info.showType = data.showType
    logic_custom_presentation:SetCurDragData(data.info)
    local spawnIndx = data.spawnIdx
    if 0 < spawnIndx then
      self:RemoveItemByIndex(spawnIndx)
    end
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_LEFT_ITEM_DRAG, true)
  end
end
function LobbyChat_InformationCustomDetail_UIBP:RefreshInformationAllItems()
  local allCnt = self.LoopScrollGridActionSlot:GetItemCount()
  for index = 1, allCnt do
    local widget = self.LoopScrollGridActionSlot:GetIndexOfWidget(index)
    if widget then
      self:RefreshItems(widget, index)
    end
  end
end
function LobbyChat_InformationCustomDetail_UIBP:RefreshItems(widget, index)
  local isCanAccept = self:IsItemCanAcceptDrag(index)
  local logic_custom_presentation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_custom_presentation)
  local info = logic_custom_presentation:GetCurDragData()
  if not info then
    isCanAccept = false
  end
  self:SetWidgetVisible(widget.CanvasPanel_Add, isCanAccept)
end
function LobbyChat_InformationCustomDetail_UIBP:IsSelectData(selectData)
  local logic_custom_presentation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_custom_presentation)
  local info = selectData or logic_custom_presentation:GetCurDragData()
  if info then
    for row, rowData in ipairs(self.itemData) do
      for col, data in ipairs(rowData) do
        if data.info and data.info.moduleData and data.info.moduleData.mId and info.moduleData and info.moduleData.mId and data.info.moduleData.mId == info.moduleData.mId then
          local index = (row - 1) * 4 + col
          if data.info.mmId then
            if data.info.mmId == info.mmId then
              return true, index, data
            end
          else
            return true, index, data
          end
        end
      end
    end
  end
  return false, 0
end
function LobbyChat_InformationCustomDetail_UIBP:ClearSpawnChild(Index)
  local isSelectData, idx, data = self:IsSelectData()
  if isSelectData then
    self:SetItemCantAcceptDrag(idx, data.showType, true)
    local widget = self.LoopScrollGridActionSlot:GetIndexOfWidget(Index)
    if widget then
      self:RecycleItemUI(Index)
      self.isChange = true
      return true
    end
  end
  return false
end
function LobbyChat_InformationCustomDetail_UIBP:SetItemDataByIndex(Index, showType)
  local isCan, dir = self:IsItemCanAcceptDrag(Index, showType)
  if not isCan then
    local isSelectData, idx = self:IsSelectData()
    if isSelectData then
      self:ClearSpawnChild(idx)
      self:SetItemDataByIndexFunc(Index)
    else
      self:OnResetBox()
    end
    return
  end
  local isSelectData, idx = self:IsSelectData()
  if isSelectData then
    self:ClearSpawnChild(idx)
  end
  self:SetItemDataByIndexFunc(Index, dir, nil, showType)
end
function LobbyChat_InformationCustomDetail_UIBP:GetSpawnItemIdx(index, dir, _showType)
  local logic_custom_presentation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_custom_presentation)
  local showType = _showType or logic_custom_presentation:GetInformationType()
  if showType == 1 then
    if dir == 1 then
      return index
    elseif dir == 2 then
      return index - 1
    elseif dir == 3 then
      return index - 4
    elseif dir == 4 then
      return index - 5
    end
  elseif showType == 2 then
    if dir == 1 then
      return index
    elseif dir == 2 then
      return index - 1
    end
  elseif showType == 3 then
    return index
  end
end
function LobbyChat_InformationCustomDetail_UIBP:SetItemDataByIndexFunc(Index, dir, createData, _showType)
  local logic_custom_presentation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_custom_presentation)
  local showType = _showType or createData and createData.showType or logic_custom_presentation:GetInformationType()
  local spawnIdx = self:GetSpawnItemIdx(Index, dir, createData and createData.showType)
  if spawnIdx then
    local widget = self.LoopScrollGridActionSlot:GetIndexOfWidget(spawnIdx)
    if widget then
      local typeList = {
        "Common_InformationCustom_Large_Item",
        "Common_InformationCustom_Middle_Item",
        "Common_InformationCustom_Tiny_Item"
      }
      local itemUI = UIManager.ShowUI(UIManager.UI_Config[typeList[showType]])
      if itemUI then
        local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(widget.SizeBox_ItemParent)
        if showType == 1 then
          slot:SetPosition(FVector2D(42.5, 42.5))
        elseif showType == 2 then
          slot:SetPosition(FVector2D(42.5, 0))
        elseif showType == 3 then
          slot:SetPosition(FVector2D(0, 0))
        end
        self:AttachChildWindowByControl(widget.SizeBox_ItemParent, itemUI)
        local info = createData or logic_custom_presentation:GetCurDragData()
        if info then
          itemUI:OnRefresh(info)
          self:SetItemCantAcceptDrag(spawnIdx, showType, false, info)
        end
        itemUI:SetEdit(self.isEdit)
        itemUI:SetIsLeft(true)
        self.spawnItemList[spawnIdx] = itemUI
        self.isChange = true
      end
    end
    self:ResetItems(true)
  end
end
function LobbyChat_InformationCustomDetail_UIBP:ResetItems(isSelectCancel)
  for row = 1, 4 do
    for col = 1, 4 do
      local index = (row - 1) * 4 + col
      local widget = self.LoopScrollGridActionSlot:GetIndexOfWidget(index)
      if widget then
        if isSelectCancel then
          self:SetWidgetVisible(widget.CanvasPanel_Add, false)
        else
          self:SetWidgetVisible(widget.CanvasPanel_Add, self:IsItemCanAcceptDrag(index))
        end
      end
    end
  end
end
function LobbyChat_InformationCustomDetail_UIBP:OnDragBegin(_, _, isBegin)
  if not self.isEdit then
    return
  end
  if isBegin then
    self:RefreshInformationAllItems()
    self:OnRegisterDrag(true)
    self.isDrag = true
  else
    self:ResetItems(true)
    self.isDrag = false
    self:OnRegisterLeftDrag()
  end
end
function LobbyChat_InformationCustomDetail_UIBP:OnItemSelect(_, _, selectData, selectIdx, isSelectCancel)
  if self.isDrag or not self.isEdit then
    return
  end
  self:ResetAllCanAcceptDrag()
  if not isSelectCancel then
    self:OnRegisterDrag(true)
    if selectData then
      local isSelectData, idx = self:IsSelectData(selectData)
      if isSelectData then
        self:ResetCanAcceptDrag(idx)
      end
    end
  else
    self:OnRegisterLeftDrag()
  end
  self:ResetItems(isSelectCancel)
  self:ResetAllRemoveButton()
end
function LobbyChat_InformationCustomDetail_UIBP:ResetCanAcceptDrag(idx)
  local row, col = self:IndexToRowCol(idx)
  local data = self.itemData[row][col]
  if data.showType == 1 then
    self.itemData[row][col].isCanAccept = true
    self.itemData[row + 1][col].isCanAccept = true
    self.itemData[row][col + 1].isCanAccept = true
    self.itemData[row + 1][col + 1].isCanAccept = true
  elseif data.showType == 2 then
    self.itemData[row][col].isCanAccept = true
    self.itemData[row][col + 1].isCanAccept = true
  elseif data.showType == 3 then
    self.itemData[row][col].isCanAccept = true
  end
end
function LobbyChat_InformationCustomDetail_UIBP:ResetAllCanAcceptDrag()
  for row, rowData in ipairs(self.itemData) do
    for col, data in ipairs(rowData) do
      if data.info and GetTableSize(data.info) > 0 then
        if data.showType == 1 then
          self.itemData[row][col].isCanAccept = false
          if self.itemData[row + 1] then
            self.itemData[row + 1][col].isCanAccept = false
            if self.itemData[row + 1][col + 1] then
              self.itemData[row + 1][col + 1].isCanAccept = false
            end
          end
          if self.itemData[row][col + 1] then
            self.itemData[row][col + 1].isCanAccept = false
          end
        elseif data.showType == 2 then
          self.itemData[row][col].isCanAccept = false
          if self.itemData[row][col + 1] then
            self.itemData[row][col + 1].isCanAccept = false
          end
        elseif data.showType == 3 then
          self.itemData[row][col].isCanAccept = false
        end
      else
        self.itemData[row][col].isCanAccept = true
      end
    end
  end
end
function LobbyChat_InformationCustomDetail_UIBP:OnClickedItemSlotItem(DragWidget, Index, DragDropData)
  if self.isDrag or self.dragSelf then
    return
  end
  self:PlayAudio(sound_config.click_v1)
  local logic_custom_presentation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_custom_presentation)
  local curDragData = logic_custom_presentation:GetCurDragData()
  if curDragData then
    self:SetItemDataByIndex(Index)
    logic_custom_presentation:SetCurDragData(nil)
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_ITEM_CLICK, nil, Index, true)
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_REFRESH_EQUIP)
  else
    local spawnIdx = Index
    if not self.spawnItemList[spawnIdx] then
      local row, col = self:IndexToRowCol(Index)
      local data = self.itemData[row][col]
      if data and data.spawnIdx then
        spawnIdx = data.spawnIdx
      end
    end
    for i, itemUI in pairs(self.spawnItemList) do
      local widget = self.LoopScrollGridActionSlot:GetIndexOfWidget(i)
      if i == spawnIdx and self.spawnItemList[spawnIdx] then
        itemUI:SetLeftSelect(true)
        if widget then
          self:SetWidgetVisible(widget.Button_remove, true, true)
          self.removeIdx = spawnIdx
        end
      else
        itemUI:SetLeftSelect(false)
        if widget then
          self:SetWidgetVisible(widget.Button_remove, false)
        end
      end
    end
  end
end
function LobbyChat_InformationCustomDetail_UIBP:GetSpawnIndex(index)
  for row, rowData in ipairs(self.itemData) do
    for col, data in ipairs(rowData) do
      if data.showType and data.info and GetTableSize(data.info) > 0 then
        if data.showType == 1 then
          local indexList = {
            (row - 1) * 4 + col,
            row * 4 + col,
            (row - 1) * 4 + col + 1,
            row * 4 + col + 1
          }
          for _, x in ipairs(indexList) do
            if x == index then
              return (row - 1) * 4 + col
            end
          end
        elseif data.showType == 2 then
          local indexList = {
            (row - 1) * 4 + col,
            (row - 1) * 4 + col + 1
          }
          for _, x in ipairs(indexList) do
            if x == index then
              return (row - 1) * 4 + col
            end
          end
        elseif data.showType == 3 then
          return index
        end
      end
    end
  end
end
function LobbyChat_InformationCustomDetail_UIBP:RefreshCurShowData()
  local maxCnt = self.LoopScrollGridActionSlot:GetItemCount()
  local widget = self.LoopScrollGridActionSlot:GetIndexOfWidget(maxCnt)
  if not widget then
    return
  end
  if self.isInitCurData then
    return
  end
  self:OnDeleteAllItem()
  self.isInitCurData = true
  local uid = self.uid or DataMgr.roleData.uid
  local custom_presentation_util = require("client.slua.logic.person_space.custom_presentation_util")
  self._cpData = custom_presentation_util.GetDataByUID(uid)
  if self._cpData then
    local isOld = false
    if self._cpData and #self._cpData == 4 then
      isOld = true
    end
    if isOld then
      local tmp = {}
      for i = 1, 16 do
        table.insert(tmp, {
          mId = 0,
          mData = {showType = 1}
        })
      end
      local maxCppCnt = math.min(4, #self._cpData)
      for i = 1, maxCppCnt do
        local data = self._cpData[i]
        if data.mId == custom_presentation_config.NewModuleID.KingMark and not data.mData.honer_id then
          data = nil
        end
        if data then
          if i == 1 then
            tmp[1] = data
          elseif i == 2 then
            tmp[3] = data
          elseif i == 3 then
            tmp[9] = data
          elseif i == 4 then
            tmp[11] = data
          end
        end
      end
      for _, cpData in ipairs(tmp) do
        if cpData.mId == custom_presentation_config.NewModuleID.Relation then
          cpData.mData.showType = 3
        end
      end
      self._cpData = tmp
    else
      local tempData = {}
      for _, cpData in ipairs(self._cpData) do
        local isExist = false
        for _, data in ipairs(tempData) do
          if data.mId == cpData.mId and cpData.mId ~= custom_presentation_config.NewModuleID.KingMark and cpData.mId ~= custom_presentation_config.NewModuleID.KingMarkMax and cpData.mId ~= custom_presentation_config.NewModuleID.Title and cpData.mId ~= custom_presentation_config.NewModuleID.Achievement and cpData.mId ~= custom_presentation_config.NewModuleID.Relation then
            isExist = true
            break
          end
        end
        if cpData.mId == custom_presentation_config.NewModuleID.KingMark and not cpData.mData.honer_id then
          isExist = true
        end
        if not isExist then
          table.insert(tempData, cpData)
        else
          table.insert(tempData, {
            mId = 0,
            mData = {}
          })
        end
      end
      for index, cpData in ipairs(tempData) do
        if cpData.mId == custom_presentation_config.NewModuleID.Relation and cpData.mData.showType and cpData.mData.showType == 1 then
          cpData.mData.showType = 3
        elseif cpData.mId == custom_presentation_config.NewModuleID.KingMark and not cpData.mData.honer_id then
          table.remove(tempData, index)
        end
      end
      self._cpData = tempData
    end
    self.    for index, cpData in ipairs(self._cpData) do
      if cpData and cpData.mId > 0 then
        self:CreateModule(cpData, index)
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_REFRESH_EQUIP)
  self.isChange = false
end
function LobbyChat_InformationCustomDetail_UIBP:OnKeyFastGenerate()
end
function LobbyChat_InformationCustomDetail_UIBP:CreateModule(moduleData, index)
  local moduleConfigList = CDataTable.GetTable("CustomPresentationModule")
  local TableUtil = require("common.table_util")
  local createData = function(insertData, _moduleData)
    insertData.uid = self.uid
    insertData.showType = _moduleData.mData.showType or 1
    if insertData.configData.ID == custom_presentation_config.NewModuleID.Relation and insertData.showType == 1 then
      insertData.showType = 3
    end
    for _, property in ipairs(custom_presentation_config.allPropertyMap) do
      if _moduleData.mData[property] then
        insertData[property] = _moduleData.mData[property]
        local isCantUsed = TableUtil.IsInTable(custom_presentation_config.cantUsedProperty, property)
        if not isCantUsed then
          insertData.mmId = _moduleData.mData[property]
        end
      end
    end
    if not insertData.mmId then
      insertData.mmId = _moduleData.mId
    end
    local isCan, dir = self:IsItemCanAcceptDrag(index, insertData.showType)
    if isCan then
      self:SetItemDataByIndexFunc(index, dir, insertData)
      return
    end
  end
  for _, moduleConfig in ipairs(moduleConfigList) do
    local moduleId = moduleConfig.ID
    if moduleId == moduleData.mId then
      local checkCanShowFunc = custom_presentation_config.EditCheckCanShowModuleNew[moduleId]
      local canAdd = true
      local insertData = {configData = moduleConfig, moduleData = moduleData}
      if canAdd and insertData then
        insertData.cpData = moduleData
        createData(insertData, moduleData)
        local isCan, dir = self:IsItemCanAcceptDrag(index, insertData.showType)
        if isCan then
          self:SetItemDataByIndexFunc(index, dir, insertData)
          return
        end
      end
    end
  end
end
function LobbyChat_InformationCustomDetail_UIBP:GetAllItemData()
  local allItemData = {}
  for index = 1, 16 do
    local widget = self.spawnItemList[index]
    if widget then
      local data = widget:GetData()
      if data and 0 < GetTableSize(data) then
        for _, property in ipairs(custom_presentation_config.allPropertyMap) do
          local value = data[property]
          if value then
            data.moduleData.mData[property] = value
          end
        end
        table.insert(allItemData, data.moduleData)
      else
        table.insert(allItemData, {
          mId = 0,
          mData = {}
        })
      end
    else
      table.insert(allItemData, {
        mId = 0,
        mData = {}
      })
    end
  end
  return allItemData, self.isChange
end
function LobbyChat_InformationCustomDetail_UIBP:OnDeleteAllItem(_, _, isPostEvent)
  if not self.isEdit then
    return
  end
  self:RecycleAllItemUI()
  for index = 1, 16 do
    local widget = self.LoopScrollGridActionSlot:GetIndexOfWidget(index)
    if widget then
      widget.SizeBox_ItemParent:ClearChildren()
    end
  end
  self:ResetAllItemData()
  self:OnResetBox()
  self.isChange = true
  if isPostEvent then
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_REFRESH_EQUIP)
  end
end
function LobbyChat_InformationCustomDetail_UIBP:RemoveItemByIndex(index)
  local spawnIndx = index
  if not self.spawnItemList[spawnIndx] then
    local row, col = self:IndexToRowCol(index)
    local data = self.itemData[row][col]
    if data and data.spawnIdx then
      spawnIndx = data.spawnIdx
    end
  end
  if spawnIndx then
    local row, col = self:IndexToRowCol(spawnIndx)
    local info = self.itemData[row][col].info
    if info then
      self:SetItemCantAcceptDrag(spawnIndx, self.itemData[row][col].showType, true)
      local widget = self.LoopScrollGridActionSlot:GetIndexOfWidget(spawnIndx)
      if widget then
        self:RecycleItemUI(spawnIndx)
        self.isChange = true
        self:SetWidgetVisible(widget.Button_remove, false)
        EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_REFRESH_EQUIP)
        return true
      end
      self:SetItemCantAcceptDrag(spawnIndx, 0, true)
    end
  end
end
function LobbyChat_InformationCustomDetail_UIBP:OnDeleteItemIndex(_, _, index)
  self:RemoveItemByIndex(index)
end
function LobbyChat_InformationCustomDetail_UIBP:OnClickButton_remove()
  self:PlayAudio(sound_config.click_v1)
  self:RemoveItemByIndex(self.removeIdx)
end
function LobbyChat_InformationCustomDetail_UIBP:OnClickButton_ShowTips(index)
  self:PlayAudio(sound_config.click_v1)
  if self.ShowTipsIndex and self.ShowTipsIndex == index then
    self.ShowTipsIndex = nil
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Tips, false)
    return
  end
  local row, col = self:IndexToRowCol(index)
  local itemData = self.itemData[row][col]
  local spawnIdx = itemData.spawnIdx
  if spawnIdx then
    self.ShowTipsIndex = index
    local spawnRow, spawnCol = self:IndexToRowCol(spawnIdx)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Tips, true)
    local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(self.UIRoot.CanvasPanel_Tips)
    if slot then
      if itemData.showType == 1 then
        slot:SetPosition(FVector2D((spawnCol - 2) * 85, (spawnRow - 1) * 85 + 42.5))
      elseif itemData.showType == 2 then
        slot:SetPosition(FVector2D((spawnCol - 2) * 85, (spawnRow - 1) * 85))
      elseif itemData.showType == 3 then
        slot:SetPosition(FVector2D((spawnCol - 2) * 85 - 42.5, (spawnRow - 1) * 85))
      end
    end
    local cfg = CDataTable.GetTableData("CustomPresentationModule", itemData.info.cpData.mId)
    if cfg then
      self.UIRoot.TextBlock_Tips:SetText(LocUtil.GetLocalizeResStr(cfg.TextID))
    end
  end
end
function LobbyChat_InformationCustomDetail_UIBP:ResetAllRemoveButton()
  local allCnt = self.LoopScrollGridActionSlot:GetItemCount()
  if allCnt then
    for i = 1, allCnt do
      local widget = self.LoopScrollGridActionSlot:GetIndexOfWidget(i)
      if widget then
        self:SetWidgetVisible(widget.Button_remove, false)
      end
    end
  end
end
function LobbyChat_InformationCustomDetail_UIBP:GetAllSpawnItem()
  local allData = {}
  for _, spawnUI in pairs(self.spawnItemList) do
    table.insert(allData, spawnUI:GetData())
  end
  return allData
end
function LobbyChat_InformationCustomDetail_UIBP:OnItemTouchMoved(srcWidget, srcIndex, subIndex)
  self:ResetAllPreview()
  if self.isDrag or self.dragSelf then
    local logic_custom_presentation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_custom_presentation)
    local info = logic_custom_presentation:GetCurDragData()
    if info then
      self:IsItemCanAcceptDrag(srcIndex, info.showType, true)
    end
  end
end
function LobbyChat_InformationCustomDetail_UIBP:ResetAllPreview()
  for index = 1, 16 do
    local widget = self.LoopScrollGridActionSlot:GetIndexOfWidget(index)
    if widget then
      self:SetWidgetVisible(widget.WidgetSwitcher_Review, false)
    end
  end
end
function LobbyChat_InformationCustomDetail_UIBP:OnClickOneKeyCreate(ret)
  self:SetEdit(true)
  self:OnDeleteAllItem()
  for index = 1, 16 do
    local insertData = ret[index]
    if insertData then
      local canAdd = true
      if insertData.cpData and insertData.cpData.mId == 0 then
        canAdd = false
      end
      if insertData.mId and insertData.mId == 0 then
        canAdd = false
      end
      if canAdd then
        local isCan, dir = self:IsItemCanAcceptDrag(index, insertData.showType)
        if isCan then
          if self.spawnItemList[index] then
            self:RecycleItemUI(index)
          end
          self:SetItemDataByIndexFunc(index, dir, insertData)
        end
      end
    else
      log(bWriteLog and "LobbyChat_InformationCustomDetail_UIBP:OnClickOneKeyCreate insertData is nil")
    end
  end
  self:OnRegisterLeftDrag()
  self.isChange = true
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_COMMON_INFORMATION_CUSTOM_REFRESH_EQUIP)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, LobbyChat_InformationCustomDetail_UIBP)