local bIsDevelopment = Client and Client.IsDevelopment()
local DRAG_CHECK_FIRST_DELAY = 0.3
local DRAG_CHECK_INTERVAL = 0.3
local DRAG_ALIVE_TIMEOUT = 0.5
local Common_DragDrop_Item = {}
function Common_DragDrop_Item:Initialize()
  self.dragStyle = 0
  self.dragItem = 0
  self.dragIndex = 0
  self.dragExtendData = ""
  self.DragPath = ""
  self.touchPos = FVector2D(0, 0)
  self.isTouching = false
  self.dragEnable = true
  self.dropEnable = true
  self.allDirectionEnable = false
  self.dragVertical = false
  self.DragDropItemMap = {}
  local EDragPivot = import("EDragPivot")
  self.dragPivot = EDragPivot.CenterCenter
  self.acceptableDragType = {}
  self.dragDropWidget = nil
  self.isSimpleMode = false
  self.bpPath = ""
  if IsWoWEditor then
    self._isDragging = false
    self._cachedDragOperation = nil
    self._lastDragAliveTime = 0
    self._dragCheckTimerHandle = nil
    self._onDraggedHandle = nil
    self._onDropHandle = nil
  end
  self:SetEnable(false)
end
function Common_DragDrop_Item:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH, self.OnModePreSwitch, self)
end
function Common_DragDrop_Item:OnModePreSwitch(preStatus, currentStatus)
  log(bWriteLog and string.format("Common_DragDrop_Item:OnModePreSwitch clear dragDropWidget"))
  self:_ClearDragTrackingState()
  self.dragDropWidget = nil
  local pool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ui_pool)
  for _, obj in pairs(self.DragDropItemMap) do
    pool:Release(obj)
  end
  self.DragDropItemMap = {}
end
function Common_DragDrop_Item:_ClearDragTrackingState()
  if not IsWoWEditor then
    return
  end
  self._isDragging = false
  if self._dragCheckTimerHandle then
    self:RemoveTimer(self._dragCheckTimerHandle)
    self._dragCheckTimerHandle = nil
  end
  if self._cachedDragOperation and slua.isValid(self._cachedDragOperation) then
    if self._onDraggedHandle then
      self._cachedDragOperation.OnDragged:Remove(self._onDraggedHandle)
    end
    if self._onDropHandle then
      self._cachedDragOperation.OnDrop:Remove(self._onDropHandle)
    end
  end
  self._onDraggedHandle = nil
  self._onDropHandle = nil
  self._cachedDragOperation = nil
  self._lastDragAliveTime = 0
end
function Common_DragDrop_Item:_ForceResetDrag()
  if not IsWoWEditor then
    return
  end
  if not self._isDragging then
    return
  end
  local cachedOp = self._cachedDragOperation
  self:_ClearDragTrackingState()
  if cachedOp then
    log(bWriteLog and "Common_DragDrop_Item:_ForceResetDrag OnDragged heartbeat timeout, force cancel")
    self.OnDragCanceled:BroadCast(cachedOp)
  end
end
function Common_DragDrop_Item:_CheckDragAliveTimeout()
  if not self._isDragging then
    self:_ClearDragTrackingState()
    return
  end
  if os.clock() - self._lastDragAliveTime > DRAG_ALIVE_TIMEOUT then
    self:_ForceResetDrag()
  end
end
function Common_DragDrop_Item:_StartDragAliveCheck(op)
  if not IsWoWEditor then
    return
  end
  self:_ClearDragTrackingState()
  self._isDragging = true
  self._cachedDragOperation = op
  self._lastDragAliveTime = os.clock()
  self._onDraggedHandle = op.OnDragged:Add(function()
    self._lastDragAliveTime = os.clock()
  end)
  self._onDropHandle = op.OnDrop:Add(function()
    self:_ClearDragTrackingState()
  end)
  self._dragCheckTimerHandle = self:AddTimerLoop(DRAG_CHECK_FIRST_DELAY, function()
    self:_CheckDragAliveTimeout()
  end, 0, DRAG_CHECK_INTERVAL)
end
function Common_DragDrop_Item:OnDragCancelled(PointerEvent, Operation)
  self:_ClearDragTrackingState()
  log(bWriteLog and string.format("Common_DragDrop_Item:OnDragCancelled"))
  local OperationClass = slua.loadClass("/Game/UMG/UI_BP/Common/Common_DragDrop_Data.Common_DragDrop_Data")
  if Game:IsClassOf(Operation, OperationClass) then
    self.OnDragCanceled:BroadCast(Operation)
  end
end
function Common_DragDrop_Item:OnMouseLeave()
  log(bWriteLog and string.format("Common_DragDrop_Item:OnMouseLeave"))
  self.isTouching = false
end
function Common_DragDrop_Item:OnDragEnter()
  if self.dropEnable and self.OnTestDragEnter then
    self.OnTestDragEnter:BroadCast()
  end
end
function Common_DragDrop_Item:OnDragLeave()
  if self.dropEnable and self.OnTestDragLeave then
    self.OnTestDragLeave:BroadCast()
  end
end
function Common_DragDrop_Item:OnDragDetected(MyGeometry, PointerEvent)
  log(bWriteLog and string.format("Common_DragDrop_Item:OnDragDetected self.dragEnable = %s", self.dragEnable))
  if not self.dragEnable then
    return
  end
  if not self.allDirectionEnable then
    local UKismetInputLibrary = import("KismetInputLibrary")
    local delta = UKismetInputLibrary.PointerEvent_GetCursorDelta(PointerEvent)
    local absA = math.abs(delta.X)
    local absB = math.abs(delta.Y)
    if not self.dragVertical and absA < absB or self.dragVertical and absA > absB then
      log(bWriteLog and string.format("Common_DragDrop_Item:OnDragDetected absA < absB"))
      return
    end
  end
  local op
  if self.isSimpleMode then
    if not slua.isValid(self.dragDropWidget) then
      self.dragDropWidget = self:GetDragDropWidgetByPath(self.bpPath)
    end
    op = self:CreateDragDropData(self.dragDropWidget)
    return op
  end
  if not slua.isValid(self.dragDropWidget) then
    local Common_DragDrop_Widget = slua.loadUI("/Game/UMG/UI_BP/Common/Common_DragDrop_Widget.Common_DragDrop_Widget")
    local texture = self:GetDefaultTexture()
    Common_DragDrop_Widget.DefaultTexture:SetBrushFromTexture(texture, false)
    op = self:CreateDragDropData(Common_DragDrop_Widget)
  else
    op = self:CreateDragDropData(self.dragDropWidget)
  end
  return op
end
function Common_DragDrop_Item:OnDrop(MyGeometry, PointerEvent, Operation)
  self:_ClearDragTrackingState()
  log(bWriteLog and string.format("Common_DragDrop_Item:OnDrop"))
  if not self.dropEnable then
    return false
  end
  if self.isSimpleMode then
    self.OnDragSuccess:BroadCast(Operation)
    return true
  end
  if not next(self.acceptableDragType) then
    return false
  end
  if not slua.isValid(Operation) then
    return false
  end
  if self.acceptableDragType[Operation.Tag] then
    self.OnDragSuccess:BroadCast(Operation)
    return true
  end
  return false
end
function Common_DragDrop_Item:OnTouchStarted(MyGeometry, InTouchEvent)
  log(bWriteLog and string.format("Common_DragDrop_Item:OnTouchStarted"))
  local KismetInputLibrary = import("KismetInputLibrary")
  self.touchPos = KismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
  self.isTouching = true
  self.OnItemTouchStarted:BroadCast()
  local WidgetBlueprintLibrary = import("WidgetBlueprintLibrary")
  local FKey = import("/Script/InputCore.Key")
  local CachedKey = FKey()
  CachedKey.KeyName = "LeftMouseButton"
  local DragHandle = WidgetBlueprintLibrary.DetectDragIfPressed(InTouchEvent, self, CachedKey)
  return DragHandle
end
function Common_DragDrop_Item:OnTouchEnded()
  log(bWriteLog and string.format("Common_DragDrop_Item:OnTouchEnded"))
  self.OnItemTouchEnded:BroadCast()
  if self.isTouching then
    self.OnDragClicked:BroadCast()
  end
  self.isTouching = false
end
function Common_DragDrop_Item:OnTouchMoved(MyGeometry, InTouchEvent)
  log(bWriteLog and string.format("Common_DragDrop_Item:OnTouchMoved"))
  self.OnItemTouchMoved:BroadCast()
  local KismetInputLibrary = import("KismetInputLibrary")
  local cPos = KismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
  local px = math.abs(self.touchPos.X - cPos.X)
  local py = math.abs(self.touchPos.Y - cPos.Y)
  if (2 < px or 2 < py) and self.isTouching then
    self.OnItemTouchEnded:BroadCast()
    self.isTouching = false
  end
end
function Common_DragDrop_Item:SetEnable(enable)
  log(bWriteLog and string.format("Common_DragDrop_Item:SetEnable enable = %s", enable))
  if enable then
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  else
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Common_DragDrop_Item:SetDragEnable(enable)
  log(bWriteLog and string.format("Common_DragDrop_Item:SetDragEnable"))
  self.dragEnable = enable
end
function Common_DragDrop_Item:SetDropEnable(enable)
  log(bWriteLog and string.format("Common_DragDrop_Item:SetDropEnable"))
  self.dropEnable = enable
end
function Common_DragDrop_Item:RegisterDrag(style, itemId, index, extraData)
  log(bWriteLog and string.format("Common_DragDrop_Item:RegisterDrag"))
  self.dragStyle = style
  self.dragItem = itemId
  self.dragIndex = index
  self.dragExtendData = extraData
  self.DragPath = ""
  self.dragDropWidget = self:GetDragDropWidget(style)
end
function Common_DragDrop_Item:RegisterDragWithDragPath(style, itemId, index, extraData, extraPath, NoCash)
  log(bWriteLog and string.format("Common_DragDrop_Item:RegisterDrag"))
  self.dragStyle = style
  self.dragItem = itemId
  self.dragIndex = index
  self.dragExtendData = extraData
  self.DragPath = extraPath or ""
  self.dragDropWidget = self:GetDragDropWidget(style, NoCash)
end
function Common_DragDrop_Item:RegisterSimpleDrag(bpPath)
  log(bWriteLog and string.format("Common_DragDrop_Item:RegisterSimpleDrag bpPath = %s", bpPath))
  self.isSimpleMode = true
  self.allDirectionEnable = true
  self.  self.dragStyle = 1
end
function Common_DragDrop_Item:GetDragDropWidget(_type, NoCash)
  log(bWriteLog and string.format("Common_DragDrop_Item:GetDragDropWidget"))
  if self.DragDropItemMap[_type] and not NoCash then
    return self.DragDropItemMap[_type]
  else
    if NoCash and self.DragDropItemMap[_type] then
      local pool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ui_pool)
      local obj = self.DragDropItemMap[_type]
      pool:Release(obj)
    end
    local widget = self:CreateWidgetByDragDropType(_type)
    if not slua.isValid(widget) then
      return nil
    end
    self.DragDropItemMap[_type] = widget
    return widget
  end
end
function Common_DragDrop_Item:GetDragDropWidgetByPath(bpPath)
  log(bWriteLog and string.format("Common_DragDrop_Item:GetDragDropWidgetByPath bpPath = %s", bpPath))
  if string.sub(bpPath, -2) == "_C" then
    if bIsDevelopment then
      log(bWriteLog and string.format("Common_DragDrop_Item:GetDragDropWidgetByPath remove _C suffix"))
      log(bWriteLog and debug.traceback())
    end
    bpPath = string.sub(bpPath, 1, -3)
  end
  return slua.loadUI(bpPath)
end
function Common_DragDrop_Item:CreateWidgetByDragDropType(_type)
  log(bWriteLog and string.format("Common_DragDrop_Item:CreateWidgetByDragDropType"))
  local pool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ui_pool)
  if _type == 1 then
    return pool:Get("/Game/UMG/UI_Logic/Wardrobe/MotionItem_BP.MotionItem_BP")
  elseif _type == 2 then
    if string.sub(self.DragPath, -2) == "_C" then
      if bIsDevelopment then
        log(bWriteLog and string.format("Common_DragDrop_Item:CreateWidgetByDragDropType self.DragPath = %s", self.DragPath))
        log(bWriteLog and debug.traceback())
      end
      self.DragPath = string.sub(self.DragPath, 1, -3)
    end
    return pool:Get(self.DragPath)
  end
  return nil
end
function Common_DragDrop_Item:SetDragPivot(dragPivot)
  log(bWriteLog and string.format("Common_DragDrop_Item:SetDragPivot"))
  self.end
function Common_DragDrop_Item:SetAllDirectionEnable(enable, dragVertical)
  log(bWriteLog and string.format("Common_DragDrop_Item:SetAllDirectionEnable"))
  self.allDirectionEnable = enable
  self.dragVertical = dragVertical or false
end
function Common_DragDrop_Item:RegisterDrop(dragType)
  log(bWriteLog and string.format("Common_DragDrop_Item:RegisterDrop"))
  if not self.acceptableDragType then
    self.acceptableDragType = {}
  end
  self.acceptableDragType[tostring(dragType)] = true
end
function Common_DragDrop_Item:GetDefaultTexture()
  log(bWriteLog and string.format("Common_DragDrop_Item:GetDefaultTexture"))
  if self.dragStyle == 0 then
    local UIUtil = require("client.common.ui_util")
    local path = UIUtil.GetItemBigIcon(self.dragItem)
    local LogicLoadTexture = require("client.slua.logic.texture.logic_load_texture")
    local textureOrSprite = LogicLoadTexture.LoadTextureOrSprite(path)
    return textureOrSprite
  end
  return nil
end
function Common_DragDrop_Item:CreateDragDropData(widget)
  log(bWriteLog and string.format("Common_DragDrop_Item:CreateDragDropData"))
  if self._isDragging then
    self:_ForceResetDrag()
  end
  widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local op
  local OperationClass = slua.loadClass("/Game/UMG/UI_BP/Common/Common_DragDrop_Data.Common_DragDrop_Data")
  if slua.isValid(OperationClass) then
    local UWidgetBlueprintLibrary = import("WidgetBlueprintLibrary")
    op = UWidgetBlueprintLibrary.CreateDragDropOperation(OperationClass)
    if not slua.isValid(op) then
      log(bWriteLog and "Common_DragDrop_Item:CreateDragDropOperation failed")
      return op
    end
    op.Tag = tostring(self.dragStyle)
    op.Payload = widget
    op.DefaultDragVisual = widget
    op.Pivot = self.dragPivot
    op.Offset = FVector2D(0, 0)
    if not self.isSimpleMode then
      op.dragItem = self.dragItem
      op.dragExtendData = self.dragExtendData
      op.dragIndex = self.dragIndex
    end
    self:_StartDragAliveCheck(op)
  end
  self.OnDragReadyToShape:BroadCast(self.dragDropWidget, op)
  return op
end
function Common_DragDrop_Item:OnClose()
  log(bWriteLog and "Common_DragDrop_Item:OnClose.  ")
  self:_ClearDragTrackingState()
  local pool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ui_pool)
  for _, obj in pairs(self.DragDropItemMap) do
    pool:Release(obj)
  end
  self.DragDropItemMap = {}
  self.dragDropWidget = nil
  self.acceptableDragType = {}
  self.isSimpleMode = false
  self.bpPath = ""
end
local class = require("class")
local OverrideUIBase = require("client.slua_ui_framework.OverrideUIBase")
return class(OverrideUIBase, nil, Common_DragDrop_Item)