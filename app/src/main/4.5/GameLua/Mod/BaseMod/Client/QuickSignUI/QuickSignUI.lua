local QuickSignUI = {
  DefaultImgPath = "/Game/Arts/UI/Atlas/BattleUI/Ingame_QuickSign/Frames/DJ_Icon_xibiao_02_png.DJ_Icon_xibiao_02_png",
  MarkUIType = {Normal = 1, Item = 2}
}
local KismetInputLibrary = import("KismetInputLibrary")
local WidgetBlueprintLibrary = import("WidgetBlueprintLibrary")
local EQuickSignType = import("EQuickSignType")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local QuickMarkConfig = require("GameLua.Mod.BaseMod.Client.Config.QuickMarkConfig")
local ClientTLogUtil = require("GameLua.Mod.BaseMod.Client.ClientTLog.ClientTLogUtil")
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
local table_insert = table.insert
local table_remove = table.remove
function QuickSignUI:ctor()
  self._MarkUIPool = {}
  for Name, Value in pairs(QuickSignUI.MarkUIType) do
    self._MarkUIPool[Value] = {}
  end
  self._PendingRemoveMarkUI = {}
  self._MarkDataQueueMap = {}
  for Name, Value in pairs(QuickSignUI.MarkUIType) do
    self._MarkDataQueueMap[Value] = {}
  end
  self._AsyncHandleMap = {}
  self.bNeedDelayRegistEvents = true
  self.ClickTimeThreshold = 0.3
  self.BeginDragThreshold = 5.0
  self._TouchState = "Idle"
  self._AccumulatedPointDelta = FVector2D(0, 0)
  self._ClampLength = 100
  self._RadialMenuConfig = nil
end
function QuickSignUI:OnInitialize()
  for i = 1, 3 do
    self:CreateMarkInPool(QuickSignUI.MarkUIType.Normal)
  end
  for i = 1, 2 do
    self:CreateMarkInPool(QuickSignUI.MarkUIType.Item)
  end
end
function QuickSignUI:_StartCheckCenterTimer()
  if self.TickTimer then
    return
  end
  self.TickTimer = self:AddGameTimer(0.1, true, function()
    self:CheckMarkCenterActive()
  end)
end
function QuickSignUI:_StopCheckCenterTimer()
  if self.TickTimer then
    self:RemoveGameTimer(self.TickTimer)
    self.TickTimer = nil
  end
  self:CheckMarkCenterActive()
end
function QuickSignUI:RegistEvents()
  print(bWriteLog and "QuickSignUI:RegistEvents")
  self.QuickSignAreaIDMap = {}
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_PLAYER_STATE_AREA_ID_CHANGED, self.HandlePlayerStateAreaChange, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_TEAM_SHOW_READY, self.OnTeamShowReady, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_ENTER_TEAM_SHOW, self.OnTeamShowReady, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_NEW_EXPANDPANEL_MUTEX, function(_, __, Object)
    if Object ~= self then
      self:OnTouchEnded()
    end
  end)
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_SignBtn, self, "MainControlBaseUI_CanvasPanel_QuickSign")
  self:AddSettingOptionEvent("UniversalSignSwitch", function(UniversalSignSwitch)
    print(bWriteLog and "QuickSignUI:RegistEvents UniversalSignSwitch", UniversalSignSwitch)
    if UniversalSignSwitch then
      self.UIRoot.Border_Opacity:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    else
      self.UIRoot.Border_Opacity:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end, true)
  self:AddSettingOptionEvent("OldMarkStyle", function(OldMarkStyle)
    self.  end, true)
  self:AddSettingOptionEvent("bQuickSignDoubleRing", function(bQuickSignDoubleRing)
    if bQuickSignDoubleRing then
      self:SetRadialMenuConfig(UIManager.UI_Config_InGame.QuickSignRadialMenu)
    else
      self:SetRadialMenuConfig(UIManager.UI_Config_InGame.QuickSignCircleUI)
    end
  end, true)
  self:RefreshQuickSignVisibility()
  local SuperData = GameplayData.GetSuperData()
  self:AddDataListener(SuperData, "CharacterDataReady", function()
    self:RegisterControllerEvent()
  end)
  self:AddCommonEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_INIT_COMPLETE_PLAYBACK_UI, self.OnReplayUIInit, self)
  self:OnReplayUIInit()
  self:AddControlEventByControl(self.UIRoot.Border_Opacity, "OnMouseButtonDownEvent", self.OnTouchStarted, self)
  self:AddControlEventByControl(self.UIRoot.Border_Opacity, "OnMouseButtonUpEvent", self.OnTouchEnded, self)
  self:AddControlEventByControl(self.UIRoot.Border_Opacity, "OnMouseMoveEvent", self.OnTouchMoved, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_HIDE_ALL_UI, self.OnHideAllUI, self)
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_ADD_TO_FORCE_HIDE_UI_ARRAY, self.UIRoot.CanvasPanel_SignBtn)
end
function QuickSignUI:OnClose()
  for _, Handle in pairs(self._AsyncHandleMap) do
    slua.CancelLoadUI(Handle)
  end
  self.QuickSignAreaIDMap = {}
  if self.UIRoot.SignMarkWidgetMap then
    self.UIRoot.SignMarkWidgetMap:Clear()
  end
  for Key, SubTable in pairs(self._MarkUIPool) do
    for Id, Widget in pairs(SubTable) do
      if slua.isValid(Widget) then
        Widget:RemoveFromParent()
      end
      SubTable[Id] = nil
    end
    self._MarkUIPool[Key] = nil
  end
  self._MarkUIPool = nil
  if slua.isValid(self.UIRoot.CanvasPanel_Mark) then
    self.UIRoot.CanvasPanel_Mark:ClearChildren()
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_REMOVE_FROM_FORCE_HIDE_UI_ARRAY, self.UIRoot.CanvasPanel_SignBtn)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_SignBtn)
  UIManager.CloseUI(self._RadialMenuConfig)
  QuickSignUI.__super.OnClose(self)
end
function QuickSignUI:OnHideAllUI()
  print(bWriteLog and "QuickSignUI:OnHideAllUI", self._RadialMenuConfig)
  if self._RadialMenuConfig then
    UIManager.CloseUI(self._RadialMenuConfig)
  end
end
function QuickSignUI:OnReplayUIInit()
  print(bWriteLog and "QuickSignUI:OnReplayUIInit")
  if not self:IsPlayingReplay() then
    print(bWriteLog and "QuickSignUI:OnReplayUIInit not replay")
    return
  end
  self.UIRoot.CanvasPanel_SignBtn:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:RegisterControllerEvent()
  self:AddUIMessageEvent("OnFreeCameraChange", self.OnFreeCameraChange, self)
end
function QuickSignUI:IsPlayingReplay()
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.bIsForReplay then
    return true
  end
  return false
end
function QuickSignUI:RegisterControllerEvent()
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  self:AddControlEventByControl(uPlayerController, "OnRepTeammateChange", self.OnTeammateChanged, self)
  local QuickSignComponent = uPlayerController:GetQuickSignComponent()
  if slua.isValid(QuickSignComponent) then
    self:AddControlEventByControl(QuickSignComponent, "IntelligentTpeChangedDel", self.OnIntelligentSignTypeChanged, self)
    self:AddControlEventByControl(QuickSignComponent, "OnAddSignMarkDelegate", self.OnAddSignMarkHandle, self)
    self:AddControlEventByControl(QuickSignComponent, "OnDelSignMarkDelegate", self.OnDelSignMarkHandle, self)
  end
end
function QuickSignUI:OnFreeCameraChange()
  print(bWriteLog and "QuickSignUI:OnFreeCameraChange")
  self:ClearSignMarkHandle()
end
function QuickSignUI:OnTouchStarted(MyGeometry, InTouchEvent)
  print(bWriteLog and "QuickSignUI:OnTouchStarted")
  if self._TouchState == "WaitSecondTap" then
    self:_CancelClickTimer()
    self:OnDoublleClick()
    self._TouchState = "Idle"
  else
    self._TouchState = "Pressed"
    self:_CancelLongPressTimer()
    self._LongPressTimer = self:AddGameTimer(self.ClickTimeThreshold, false, function()
      self._LongPressTimer = nil
      if self._TouchState == "Pressed" then
        self:_ShowCircleUI()
        self._TouchState = "Dragging"
      end
    end)
  end
  return WidgetBlueprintLibrary.CaptureMouse(WidgetBlueprintLibrary.Handled(), self.UIRoot.Border_Opacity)
end
function QuickSignUI:OnTouchMoved(MyGeometry, InTouchEvent)
  if self._TouchState ~= "Pressed" and self._TouchState ~= "Dragging" then
    return WidgetBlueprintLibrary.Unhandled()
  end
  local Delta = KismetInputLibrary.PointerEvent_GetCursorDelta(InTouchEvent)
  local ClampLength = self._ClampLength
  local Accumulated = self._AccumulatedPointDelta + Delta
  local AccumLength = Accumulated:Size()
  if ClampLength < AccumLength then
    Accumulated = Accumulated * (ClampLength / AccumLength)
  end
  self._AccumulatedPointDelta = Accumulated
  if self._TouchState == "Pressed" and AccumLength >= self.BeginDragThreshold then
    self:_CancelLongPressTimer()
    self:_ShowCircleUI()
    self._TouchState = "Dragging"
  end
  if self._TouchState == "Dragging" then
    local FinalOffset = Accumulated * (1 / ClampLength)
    local RadialMenu = self:GetRadialMenu()
    if RadialMenu then
      RadialMenu:InputOffset(FinalOffset * FVector2D(1, -1))
    end
    self.UIRoot.CanvasPanel_SignIcon:SetRenderTranslation(FinalOffset * 20)
  end
  return WidgetBlueprintLibrary.Handled()
end
function QuickSignUI:OnTouchEnded(MyGeometry, InTouchEvent)
  print(bWriteLog and "QuickSignUI:OnTouchEnded")
  local PrevState = self._TouchState
  if PrevState == "Dragging" then
    self:_HandleDragEnd()
  end
  if PrevState == "Pressed" then
    self:_CancelLongPressTimer()
    self._TouchState = "WaitSecondTap"
    self:_CancelClickTimer()
    self._ClickTimer = self:AddGameTimer(self.ClickTimeThreshold, false, function()
      self._ClickTimer = nil
      self._TouchState = "Idle"
      self:OnSingleClickEvent()
    end)
  else
    self._TouchState = "Idle"
  end
  self._AccumulatedPointDelta = self._AccumulatedPointDelta * 0
  self.UIRoot.CanvasPanel_SignIcon:SetRenderTranslation(FVector2D(0, 0))
  self.UIRoot.WidgetSwitcher_Base:SetActiveWidgetIndex(0)
  return WidgetBlueprintLibrary.ReleaseMouseCapture(WidgetBlueprintLibrary.Handled())
end
function QuickSignUI:_ShowCircleUI()
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_NEW_EXPANDPANEL_MUTEX, self)
  self.UIRoot.WidgetSwitcher_Base:SetActiveWidgetIndex(1)
  local RadialMenu = self:GetRadialMenu(true)
  if RadialMenu then
    RadialMenu:SelfHitTestInvisible()
  end
end
function QuickSignUI:_HandleDragEnd()
  local RadialMenu = self:GetRadialMenu()
  if RadialMenu then
    RadialMenu:Collapsed()
  end
end
function QuickSignUI:_CancelLongPressTimer()
  if self._LongPressTimer then
    self:RemoveGameTimer(self._LongPressTimer)
    self._LongPressTimer = nil
  end
end
function QuickSignUI:_CancelClickTimer()
  if self._ClickTimer then
    self:RemoveGameTimer(self._ClickTimer)
    self._ClickTimer = nil
  end
end
function QuickSignUI:ResetTouchState()
  self._TouchState = "Idle"
  self:_CancelLongPressTimer()
  self:_CancelClickTimer()
  self.UIRoot.CanvasPanel_SignIcon:SetRenderTranslation(FVector2D(0, 0))
  self.UIRoot.WidgetSwitcher_Base:SetActiveWidgetIndex(0)
  WidgetBlueprintLibrary.ReleaseMouseCapture(WidgetBlueprintLibrary.Handled())
end
function QuickSignUI:SetRadialMenuConfig(Config)
  if self._RadialMenuConfig then
    UIManager.CloseUI(self._RadialMenuConfig)
  end
  self._RadialMenuend
function QuickSignUI:GetRadialMenu(bCreateIfNeeded)
  local Config = self._RadialMenuConfig
  if not Config then
    return nil
  end
  local UI = UIManager.GetUI(Config)
  if not UI and bCreateIfNeeded then
    UI = UIManager.ShowUI(Config)
  end
  return UI
end
function QuickSignUI:OnSingleClickEvent()
  local QuickSignComponent = self:GetQuickSignComponent()
  if slua.isValid(QuickSignComponent) then
    if self.IsAtCenterActive then
      QuickSignComponent:OperMark(self.CrtActiveMsgID)
    elseif QuickSignComponent.IntelligentSignType and QuickSignComponent.IntelligentSignType >= 0 then
      QuickSignComponent:MakeIntelligentSign()
    else
      QuickSignComponent:MakeQuickMark()
    end
    ClientTLogUtil.ReportGeneralCountByBRPhase(12004, 12006)
  end
end
function QuickSignUI:OnDoublleClick()
  local uQuickSignComponent = self:GetQuickSignComponent()
  if slua.isValid(uQuickSignComponent) then
    uQuickSignComponent:MakeQuickCommand(EQuickSignType.Attention)
  end
end
function QuickSignUI:OnTeamShowReady()
  local RadialMenu = self:GetRadialMenu()
  if RadialMenu and RadialMenu._isShow then
    RadialMenu:SetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self:ResetTouchState()
end
function QuickSignUI:OnTeammateChanged()
  print(bWriteLog and "QuickSignUI:OnTeammateChanged")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "QuickSignUI:OnTeammateChanged PlayerController is nil")
    return
  end
  local QuickSignComponent = PlayerController:GetQuickSignComponent()
  if not slua.isValid(QuickSignComponent) then
    print(bWriteLog and "QuickSignUI:OnTeammateChanged QuickSignComponent is nil")
    return
  end
  QuickSignComponent:CheckMsgValid()
end
function QuickSignUI:OnMarkAtCenterActive(IsActive, MsgID)
  self.CrtActive  if IsActive == self.IsAtCenterActive then
    return
  end
  print("QuickSignUI:OnMarkAtCenterActive", IsActive, MsgID)
  self.IsAtCenterActive = IsActive
  if self.IsAtCenterActive then
    local QuickSignComponent = self:GetQuickSignComponent()
    if slua.isValid(QuickSignComponent) then
      if QuickSignComponent:IsSelfMark(self.CrtActiveMsgID) then
        self.UIRoot.WidgetSwitcher_UnPressed:SetActiveWidgetIndex(2)
      else
        self.UIRoot.WidgetSwitcher_UnPressed:SetActiveWidgetIndex(1)
      end
    end
  else
    self.UIRoot.WidgetSwitcher_UnPressed:SetActiveWidgetIndex(0)
  end
end
function QuickSignUI:CheckMarkCenterActive()
  local bIsActive = false
  local ActiveMsgID = ""
  if self.UIRoot and self.UIRoot.SignMarkWidgetMap and self.UIRoot.SignMarkWidgetMap:Num() > 0 then
    for MsgID, Widget in pairs(self.UIRoot.SignMarkWidgetMap) do
      if slua.isValid(Widget) and self:CheckMarkMapContain(MsgID) and Widget.IsInActiveCenter and not Widget.IsSelfMark then
        bIsActive = true
        Active        break
      end
    end
  end
  self:OnMarkAtCenterActive(bIsActive, ActiveMsgID)
end
function QuickSignUI:CheckMarkMapContain(MsgID)
  local QuickSignComponent = self:GetQuickSignComponent()
  if not slua.isValid(QuickSignComponent) or not QuickSignComponent.IsContainMark then
    print("QuickSignUI:CheckMarkMapContain QuickSignComponent is invalid")
    return false
  end
  return QuickSignComponent:IsContainMark(MsgID)
end
function QuickSignUI:OnReplyMark(MsgID)
  local QuickSignComponent = self:GetQuickSignComponent()
  if not slua.isValid(QuickSignComponent) then
    print("QuickSignUI:OnReplyMark QuickSignComponent is invalid")
    return
  end
  if QuickSignComponent:IsContainMark(MsgID) then
    print("QuickSignUI:OnReplyMark MsgID is Contain")
    return
  end
  local Widget = self.UIRoot.SignMarkWidgetMap:Get(MsgID)
  if slua.isValid(Widget) then
    Widget:OnReply()
    return
  end
  Widget = self.UIRoot.SpecialMarkWidgetMap:Get(MsgID)
  if slua.isValid(Widget) then
    Widget:OnReply()
  end
end
function QuickSignUI:OnIntelligentSignTypeChanged(Type)
  print(bWriteLog and "QuickSignUI:OnIntelligentSignTypeChanged", Type)
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local IntelligentSignConfig = CDataTable.GetTable("IntelligentSignConfig")
  if IntelligentSignConfig then
    local ConfigInfo = IntelligentSignConfig[Type]
    if ConfigInfo then
      self.UIRoot.Image_Sign:SetBrushFromPathAsync(ConfigInfo.ImagePath, false)
    else
      self.UIRoot.Image_Sign:SetBrushFromPathAsync(self.DefaultImgPath, false)
    end
  else
    self.UIRoot.Image_Sign:SetBrushFromPathAsync(self.DefaultImgPath, false)
  end
end
function QuickSignUI:GetQuickSignComponent()
  if self._QSComp then
    return self._QSComp
  end
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    self._QSComp = PlayerController:GetQuickSignComponent()
    return self._QSComp
  end
end
function QuickSignUI:CreateMarkInPool(MarkUIType, AsyncDelegate)
  print(bWriteLog and "QuickSignUI:CreateMarkInPool " .. MarkUIType)
  local BPGamePath
  if MarkUIType == QuickSignUI.MarkUIType.Normal then
    BPGamePath = "/Game/BluePrints/ControlInput/IngameUI/QuickSign/QuickSign_TipNormal_UIBP.QuickSign_TipNormal_UIBP"
  elseif MarkUIType == QuickSignUI.MarkUIType.Item then
    BPGamePath = "/Game/BluePrints/ControlInput/IngameUI/QuickSign/QuickSign_TipItem_UIBP.QuickSign_TipItem_UIBP"
  end
  local Handle = slua.AsyncLoadUI(BPGamePath, function(_, Widget)
    if not slua.isValid(Widget) or not slua.isValid(self.UIRoot) then
      print(bWriteLog and "QuickSignUI:CreateMarkInPool Failed")
      return
    end
    local WidgetSlot = self.UIRoot.CanvasPanel_Mark:AddChildToCanvas(Widget)
    WidgetSlot:SetAlignment(FVector2D(0.5, 1))
    Widget.    Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    table_insert(self._MarkUIPool[MarkUIType], Widget)
    if AsyncDelegate then
      AsyncDelegate()
    end
  end)
  return Handle
end
function QuickSignUI:PopMarkFromPool(MarkUIType, Delegate)
  print(bWriteLog and "QuickSignUI:PopMarkFromPool MarkUIType " .. MarkUIType)
  local Widget = table_remove(self._MarkUIPool[MarkUIType], 1)
  if slua.isValid(Widget) then
    Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    Delegate(Widget)
  else
    local Handle = self:CreateMarkInPool(MarkUIType, function()
      local AsyncWidget = table_remove(self._MarkUIPool[MarkUIType], 1)
      AsyncWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      if Delegate then
        Delegate(AsyncWidget)
      end
    end)
    return Handle
  end
end
function QuickSignUI:PushMarkInPool(Widget)
  local MarkUIType = Widget and Widget.MarkUIType or nil
  print(bWriteLog and "QuickSignUI:PushMarkInPool Widget " .. (MarkUIType or "nil"))
  if MarkUIType then
    Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    table_insert(self._MarkUIPool[MarkUIType], Widget)
  end
end
function QuickSignUI:InQueueMarkData(MsgItem)
  local IconBGPath = MsgItem.IconBGPath
  local IconPath = MsgItem.IconPath
  local IconOutScreenBGPath = MsgItem.IconOutScreenBGPath
  local IconOutScreenIconPath = MsgItem.IconOutScreenIconPath
  local IconOutScreenArrowPath = MsgItem.IconOutScreenArrowPath
  local MarkType = MsgItem.MarkType
  local bIsOldMarkStyle = self.OldMarkStyle == 1
  if self.OldMarkStyle == 1 then
    IconBGPath = QuickMarkConfig.OldInScreenBGPath[MarkType] or IconBGPath
    IconPath = QuickMarkConfig.OldInScreenIconPath[MarkType] or IconPath
    IconOutScreenIconPath = QuickMarkConfig.OldOutScreenIconPath[MarkType] or IconOutScreenIconPath
    IconOutScreenBGPath = QuickMarkConfig.OldOutScreenBGPath[MarkType] or IconOutScreenBGPath
    IconOutScreenArrowPath = QuickMarkConfig.OldArrowPath[MarkType] or IconOutScreenArrowPath
  elseif MarkType == "M_APickUpWrapperActor" then
    IconOutScreenBGPath = IconBGPath
    IconOutScreen  end
  local _MarkData = {
    ID = MsgItem.MsgID,
    Loc = FVector(MsgItem.Loc.X, MsgItem.Loc.Y, MsgItem.Loc.Z),
    Path = IconPath,
    BGPath = IconBGPath,
    OutPath = IconOutScreenIconPath,
    OutBGPath = IconOutScreenBGPath,
    ArrowPath = IconOutScreenArrowPath,
    bSelfMark = MsgItem.IsSelfMark,
    bOldMarkStyle = bIsOldMarkStyle,
    bMaxShowDis = MsgItem.bControlByMaxShowDis
  }
  local MarkUIType
  if MsgItem.IconOuterPath == "" then
    MarkUIType = QuickSignUI.MarkUIType.Normal
  else
    MarkUIType = QuickSignUI.MarkUIType.Item
  end
  local Queue = self._MarkDataQueueMap[MarkUIType]
  Queue[#Queue + 1] = _MarkData
end
function QuickSignUI:OnAddSignMarkHandle(MsgItem)
  if self.bCooldown then
    return
  end
  self:AddGameTimer(0.1, false, function()
    self.bCooldown = false
  end)
  self.bCooldown = true
  print(bWriteLog and "QuickSignUI:OnAddSignMarkHandle MsgID = " .. MsgItem.MsgID)
  self:_StartCheckCenterTimer()
  self:InQueueMarkData(MsgItem)
  local AsyncDelegate = function(Widget)
    if slua.isValid(Widget) then
      local MarkData = table_remove(self._MarkDataQueueMap[Widget.MarkUIType], 1)
      if MarkData then
        if self._AsyncHandleMap[MarkData.ID] then
          self._AsyncHandleMap[MarkData.ID] = nil
        end
        if self:CheckPendingRemove(MarkData.ID, Widget) then
          return
        end
        Widget:ShowSelf(MarkData.Loc, MarkData.bOldMarkStyle, MarkData.bSelfMark, MarkData.Path, MarkData.BGPath, MarkData.OutPath, MarkData.OutBGPath, MarkData.ArrowPath)
        Widget.bControledByMaxShowDis = MarkData.bMaxShowDis
        self.UIRoot.SignMarkWidgetMap:Add(MarkData.ID, Widget)
      end
    end
  end
  local MarkType
  if MsgItem.IconOuterPath == "" then
    MarkType = QuickSignUI.MarkUIType.Normal
  else
    MarkType = QuickSignUI.MarkUIType.Item
  end
  local Handle = self:PopMarkFromPool(MarkType, AsyncDelegate)
  if Handle then
    self._AsyncHandleMap[MsgItem.MsgID] = Handle
  end
  self:CollectQuickSignByAreaID(MsgItem.MsgID, MsgItem.SenderPlayerKey, false)
end
function QuickSignUI:OnDelSignMarkHandle(MsgID)
  print(bWriteLog and "QuickSignUI:OnDelSignMarkHandle MsgID = " .. MsgID)
  local Widget = self.UIRoot.SignMarkWidgetMap:Get(MsgID)
  if Widget then
    self:PushMarkInPool(Widget)
    self.UIRoot.SignMarkWidgetMap:Remove(MsgID)
    self:DeleteQuickSignByAreaID(MsgID)
  else
    self._PendingRemoveMarkUI[MsgID] = true
  end
  self:_TryStopCheckCenterTimer()
end
function QuickSignUI:_TryStopCheckCenterTimer()
  if not self.UIRoot then
    self:_StopCheckCenterTimer()
    return
  end
  if self.UIRoot.SignMarkWidgetMap:Num() <= 0 and not next(self._PendingRemoveMarkUI) then
    self:_StopCheckCenterTimer()
  end
end
function QuickSignUI:ClearSignMarkHandle()
  print(bWriteLog and "QuickSignUI:ClearSignMarkHandle")
  local AllMsgID = {}
  for MsgID, Widget in pairs(self.UIRoot.SignMarkWidgetMap) do
    table.insert(AllMsgID, MsgID)
  end
  for _, MsgID in ipairs(AllMsgID) do
    self:OnDelSignMarkHandle(MsgID)
  end
  self:_TryStopCheckCenterTimer()
end
function QuickSignUI:CheckPendingRemove(MsgID, Widget)
  if self._PendingRemoveMarkUI[MsgID] then
    print(bWriteLog and string.format("QuickSignUI:CheckPendingRemove Found MsgID=%s, PendingListNum=%d", tostring(MsgID), #self._PendingRemoveMarkUI))
    self._PendingRemoveMarkUI[MsgID] = nil
    self:PushMarkInPool(Widget)
    return true
  else
    return false
  end
end
function QuickSignUI:OperSpeicalSignMark(MsgItem, Widget, bIsAdd)
  print(bWriteLog and "QuickSignUI:OperSpeicalSignMark bIsAdd = " .. bIsAdd)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "QuickSignUI:ModifySpeicalSignMark PlayerController is nil")
    return
  end
  local QuickSignComponent = PlayerController:GetQuickSignComponent()
  if not slua.isValid(QuickSignComponent) then
    print(bWriteLog and "QuickSignUI:ModifySpeicalSignMark QuickSignComponent is nil")
    return
  end
  if bIsAdd then
    self.UIRoot.SpecialMarkWidgetMap:Add(MsgItem.MsgID, Widget)
    QuickSignComponent:AddSpecialReplyMsg(MsgItem)
    self:CollectQuickSignByAreaID(MsgItem.MsgID, MsgItem.SenderPlayerKey, true)
  else
    self.UIRoot.SpecialMarkWidgetMap:Remove(MsgItem.MsgID)
    QuickSignComponent:DelSpecialReplyMsg(MsgItem)
    self:DeleteQuickSignByAreaID(MsgItem.MsgID)
  end
end
function QuickSignUI:CheckInSameAreaID(SenderPlayerKey)
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) then
    return false
  end
  if SenderPlayerKey == "" then
    return true
  end
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) then
    print(bWriteLog and "[QuickSignUI] invalid player state")
    return false
  end
  local PlayerKey = uPlayerState:GetPlayerKey()
  if tostring(PlayerKey) == SenderPlayerKey then
    return true
  end
  local SenderPlayerState = Game:GetPlayerStateByPlayerKey(tonumber(SenderPlayerKey))
  if not slua.isValid(SenderPlayerState) then
    print(bWriteLog and "[QuickSignUI] invalid SenderPlayerState")
    return false
  end
  if not SenderPlayerState.GetAreaID or not uPlayerState.GetAreaID then
    return true
  end
  if SenderPlayerState:GetAreaID() ~= uPlayerState:GetAreaID() then
    return false
  end
  return true
end
function QuickSignUI:CollectQuickSignByAreaID(MsgID, SenderPlayerKey, bSpecial)
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) then
    return
  end
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) then
    return
  end
  if not uPlayerState.GetAreaID then
    return
  end
  local SelfAreaID = uPlayerState:GetAreaID()
  if SenderPlayerKey == "" then
    if not self.QuickSignAreaIDMap[SelfAreaID] then
      self.QuickSignAreaIDMap[SelfAreaID] = {}
    end
    if bSpecial then
      self.QuickSignAreaIDMap[SelfAreaID][MsgID] = self.UIRoot.SpecialMarkWidgetMap:Get(MsgID)
    else
      self.QuickSignAreaIDMap[SelfAreaID][MsgID] = self.UIRoot.SignMarkWidgetMap:Get(MsgID)
    end
    return
  end
  local SenderPlayerState = Game:GetPlayerStateByPlayerKey(tonumber(SenderPlayerKey))
  if not slua.isValid(SenderPlayerState) then
    return
  end
  local SenderAreaID = SenderPlayerState:GetAreaID()
  if not self.QuickSignAreaIDMap[SenderAreaID] then
    self.QuickSignAreaIDMap[SenderAreaID] = {}
  end
  if bSpecial then
    self.QuickSignAreaIDMap[SenderAreaID][MsgID] = self.UIRoot.SpecialMarkWidgetMap:Get(MsgID)
  else
    self.QuickSignAreaIDMap[SenderAreaID][MsgID] = self.UIRoot.SignMarkWidgetMap:Get(MsgID)
  end
  if SenderAreaID ~= SelfAreaID then
    self.QuickSignAreaIDMap[SenderAreaID][MsgID]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function QuickSignUI:DeleteQuickSignByAreaID(MsgID)
  for AreaID, QuickSigns in pairs(self.QuickSignAreaIDMap) do
    QuickSigns[MsgID] = nil
  end
end
function QuickSignUI:HandlePlayerStateAreaChange(EventType, EventId, PlayerKey, AreaID)
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) then
    return
  end
  if not uPlayerState.GetPlayerKey then
    return
  end
  if uPlayerState:GetPlayerKey() == PlayerKey then
    self:RefreshQuickSignVisibility()
  end
end
function QuickSignUI:RefreshQuickSignVisibility()
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) then
    return
  end
  if not uPlayerState.GetAreaID then
    return
  end
  local SelfAreaID = uPlayerState:GetAreaID()
  for AreaID, QuickSigns in pairs(self.QuickSignAreaIDMap) do
    if AreaID == SelfAreaID then
      for MsgID, Widget in pairs(QuickSigns) do
        Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end
    else
      for MsgID, Widget in pairs(QuickSigns) do
        Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    end
  end
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
local CQuickSignUI = class(UIBase, nil, QuickSignUI)
return CQuickSignUI