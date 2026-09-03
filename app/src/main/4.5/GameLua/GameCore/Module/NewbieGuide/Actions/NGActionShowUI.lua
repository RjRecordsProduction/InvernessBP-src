local EHighlightOutlineType = {
  None = -1,
  Circle = 0,
  Rectangle = 1
}
local NewbieGuideActionShowUI = {}
function NewbieGuideActionShowUI:ctor(selfType, Params)
  self.AttachParentWindow = Params.AttachParentWindow or ""
  self.AttachParentSlot = Params.AttachParentSlot or ""
  self.RegisterButtonName = Params.RegisterButtonName or ""
  self.GetButtonAndSlotFunc = Params.GetButtonAndSlotFunc
  self.HighlightOutlineType = Params.HighlightOutlineType or EHighlightOutlineType.Rectangle
  self.bEnableCircleEffect = Params.bEnableCircleEffect or false
  self.TextID = Params.TextID or -1
  self.PostProcessTextFunc = Params.PostProcessTextFunc or nil
  self.RegisterButtonEventName = Params.RegisterButtonEventName or "OnClicked"
  self.ClickEndReason = Params.ClickEndReason or "ButtonClick"
  self.uGuideItem = nil
  self.ForceDirection = Params.ForceDirection or nil
  self.bIsInAsyncLoading = false
  self.bIsActionPandingKill = false
  self.bNeedArraw = Params.NeedArrow or nil
  self.Offsets = Params.Offset and FVector2D(Params.Offset[1], Params.Offset[2]) or FVector2D(0, 0)
  self.Size = Params.Size and FVector2D(Params.Size[1], Params.Size[2]) or FVector2D(0, 0)
  self.bUseAbsoluteSize = Params.bUseAbsoluteSize or false
end
function NewbieGuideActionShowUI:RunAction(InGuideID)
  NewbieGuideActionShowUI.__super.RunAction(self, InGuideID)
  log(bWriteLog and "Debug NewbieGuideActionShowUI RunAction GuideID:" .. tostring(InGuideID) .. " AttachParentWindow:" .. tostring(self.AttachParentWindow) .. " AttachParentSlot:" .. tostring(self.AttachParentSlot) .. " RegisterButtonName:" .. tostring(self.RegisterButtonName))
  self.bIsActionPandingKill = false
  if not self:CreateGuideUI() then
    self:EndAction()
    return false
  end
  return true
end
function NewbieGuideActionShowUI:CreateGuideUI()
  if not self:CanCreateGuideUI() then
    return false
  end
  if not UIManager then
    return false
  end
  self.uAttachParentSlot, self.uRegisterBtn = self:GetAttachParentAndButton()
  if not slua.isValid(self.uAttachParentSlot) or self.uAttachParentSlot.AddChild == nil then
    sandbox.LogError("Attach slot is not valid:" .. self.AttachParentSlot)
    return false
  end
  if not slua.isValid(self.uRegisterBtn) then
    sandbox.LogError("Register button is not valid:" .. self.RegisterButtonName)
    return false
  end
  if self.bIsInAsyncLoading then
    sandbox.LogError("NewbieGuideActionShowUI:CreateGuideUI uGuideItem is Loading")
    return false
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not uPlayerController or not slua.isValid(uPlayerController) then
    sandbox.LogError("NewbieGuideActionShowUI:CreateGuideUI playerController not valid.")
    return false
  end
  self:CreateWidget()
  return true
end
function NewbieGuideActionShowUI:CanCreateGuideUI()
  return true
end
function NewbieGuideActionShowUI:GetAttachParentAndButton()
  local UIConfig = UIManager.UI_Config_InGame[self.AttachParentWindow]
  local uAttachParentSlot, uRegisterBtn
  if self.GetButtonAndSlotFunc and type(self.GetButtonAndSlotFunc) == "function" then
    self.uRegisterBtn, self.uAttachParentSlot = self.GetButtonAndSlotFunc()
    return self.uAttachParentSlot, self.uRegisterBtn
  elseif UIConfig then
    local Window = UIManager.GetUI(UIConfig)
    if Window then
      local uAttachParentWindow = Window.UIRoot
      if uAttachParentWindow then
        uAttachParentSlot = uAttachParentWindow:GetWidgetFromName(self.AttachParentSlot)
        uRegisterBtn = uAttachParentWindow:GetWidgetFromName(self.RegisterButtonName)
      end
    end
  else
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(uPlayerController) then
      sandbox.LogError("playercontroller is nil")
      return uAttachParentSlot, uRegisterBtn
    end
    local Logic = slua_GameFrontendHUD:GetLogicManagerByName(self.AttachParentWindow)
    if not slua.isValid(Logic) then
      sandbox.LogError("can not find valid logic:" .. self.AttachParentWindow)
      return uAttachParentSlot, uRegisterBtn
    end
    local WidgetList = Logic:GetWidgetList()
    for Index = 0, WidgetList:Num() - 1 do
      local Widget = WidgetList:Get(Index)
      if slua.isValid(Widget) and Widget.GetWidgetsByName then
        if not slua.isValid(uAttachParentSlot) then
          uAttachParentSlot = Widget:GetWidgetsByName(self.AttachParentSlot, "", false)
        end
        if not slua.isValid(uRegisterBtn) then
          uRegisterBtn = Widget:GetWidgetsByName(self.RegisterButtonName, "", false)
        end
      end
      if slua.isValid(uAttachParentSlot) and slua.isValid(uRegisterBtn) then
        break
      end
    end
  end
  return uAttachParentSlot, uRegisterBtn
end
function NewbieGuideActionShowUI:CreateWidget()
  self.bIsInAsyncLoading = true
  local sLoadUIPath = "/Game/BluePrints/ControlInput/NewbieItem/GuideDefaultUI.GuideDefaultUI"
  slua.AsyncLoadUI(sLoadUIPath, function(_, widget)
    self:OnCreateWidgetCallback(widget)
  end)
end
function NewbieGuideActionShowUI:OnCreateWidgetCallback(widget)
  self.bIsInAsyncLoading = false
  if self.bIsActionPandingKill then
    log(bWriteLog and "NewbieGuideActionShowUI:OnCreateWidgetCallback bIsActionPandingKill == true")
    return
  end
  if slua.isValid(widget) then
    self.uGuideItem = widget
    if not slua.isValid(self.uAttachParentSlot) or self.uAttachParentSlot.AddChild == nil then
      self:EndAction()
      return
    end
    local uSlot = self.uAttachParentSlot:AddChild(self.uGuideItem)
    if slua.isValid(uSlot) then
      if uSlot.SetZOrder then
        uSlot:SetZOrder(5)
      elseif uSlot.SetLayer then
        uSlot:SetLayer(5)
      end
    end
    log(bWriteLog and "NewbieGuideActionShowUI OnCreateWidgetCallback success.")
    if not self:InitTextUI() then
      self:EndAction()
      return
    end
    if not self:RegisterBtnClick() then
      self:EndAction()
      return
    end
  end
end
function NewbieGuideActionShowUI:InitTextUI()
  if not (slua.isValid(self.uRegisterBtn) and slua.isValid(self.uAttachParentSlot)) or not slua.isValid(self.uGuideItem) then
    return false
  end
  self.uGuideItem.TxtPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.uGuideItem.TxtPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.uGuideItem.TxtPanel_2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.uGuideItem.TxtPanel_3:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local USlateBlueprintLibrary = import("SlateBlueprintLibrary")
  local BtnSize = USlateBlueprintLibrary.GetLocalSize(self.uRegisterBtn:GetCachedGeometry()) + self.Size
  if self.bUseAbsoluteSize then
    BtnSize = self.Size
  end
  if self.HighlightOutlineType == EHighlightOutlineType.Circle then
    self.uGuideItem.OutlineShape:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.uGuideItem.OutlineShape:SetActiveWidgetIndex(0)
    if self.bEnableCircleEffect then
      self.uGuideItem.ImageCircleEffect:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self.uGuideItem.ImageCircleEffect:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  elseif self.HighlightOutlineType == EHighlightOutlineType.Rectangle then
    self.uGuideItem.OutlineShape:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.uGuideItem.OutlineShape:SetActiveWidgetIndex(1)
  elseif self.HighlightOutlineType == EHighlightOutlineType.None then
    self.uGuideItem.OutlineShape:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.uGuideItem.OutlineShape:SetActiveWidgetIndex(2)
  else
    self.uGuideItem.OutlineShape:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
  local BtnAbsolutePosition = USlateBlueprintLibrary.GetAbsolutePosition(self.uRegisterBtn:GetCachedGeometry())
  local LocalBtnPosition = USlateBlueprintLibrary.AbsoluteToLocal(self.uAttachParentSlot:GetCachedGeometry(), BtnAbsolutePosition) + self.Offsets
  local uCanvasPanel_1Slot = WidgetLayoutLibrary.SlotAsCanvasSlot(self.uGuideItem.CanvasPanel_1)
  uCanvasPanel_1Slot:SetPosition(LocalBtnPosition)
  uCanvasPanel_1Slot:SetSize(BtnSize)
  if self.bNeedArraw then
    self.uGuideItem.Arrow:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.uGuideItem.Arrow:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local TextString = DataMgr.GetFormatMsgByIDForBattleText(self.TextID)
  if self.PostProcessTextFunc then
    local Param = self.PostProcessTextFunc(self)
    TextString = DataMgr.GetFormatMsgByIDForBattleText(self.TextID, Param)
  end
  print(bWriteLog and "Base036", TextString)
  if not TextString or TextString == "" then
    return true
  end
  local UIUtil = require("client.common.ui_util")
  local BtnLocalPos = UIUtil.GetWidgetViewportPos(self.uRegisterBtn, 0, 0)
  local CenterPos = BtnLocalPos + BtnSize / 2
  local ViewSize = UIUtil.GetViewportSize()
  local ViewScale = UIUtil.GetViewportScale()
  local OffsetX = CenterPos.X / (ViewSize.X / ViewScale)
  local OffsetY = CenterPos.Y / (ViewSize.Y / ViewScale)
  if self.ForceDirection ~= nil then
    if self.ForceDirection == "LD" then
      self.uGuideItem.TipsText:SetText(TextString)
      self.uGuideItem.TxtPanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    elseif self.ForceDirection == "LU" then
      self.uGuideItem.UTRichTextBlock_2:SetText(TextString)
      self.uGuideItem.TxtPanel_2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    elseif self.ForceDirection == "RD" then
      self.uGuideItem.UTRichTextBlock_0:SetText(TextString)
      self.uGuideItem.TxtPanel_3:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    elseif self.ForceDirection == "RU" then
      self.uGuideItem.UTRichTextBlock_1:SetText(TextString)
      self.uGuideItem.TxtPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif OffsetX <= 0.55 then
    if OffsetY <= 0.5 then
      self.uGuideItem.TipsText:SetText(TextString)
      self.uGuideItem.TxtPanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self.uGuideItem.UTRichTextBlock_2:SetText(TextString)
      self.uGuideItem.TxtPanel_2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif OffsetY <= 0.5 then
    self.uGuideItem.UTRichTextBlock_0:SetText(TextString)
    self.uGuideItem.TxtPanel_3:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.uGuideItem.UTRichTextBlock_1:SetText(TextString)
    self.uGuideItem.TxtPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  return true
end
function NewbieGuideActionShowUI:RegisterBtnClick()
  if not slua.isValid(self.uRegisterBtn) then
    return false
  end
  local EventDelegate = self.uRegisterBtn[self.RegisterButtonEventName]
  if not slua.isValid(EventDelegate) then
    return true
  end
  if EventDelegate.Add then
    if self.ClickEndReason == "ButtonClick" then
      self.RegisterFunction = EventDelegate:Add(function(...)
        EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_BTN_CLICK, self.GuideID)
      end)
    else
      self.RegisterFunction = EventDelegate:Add(function(...)
        EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_END_GUIDE_BY_ACTION, self.GuideID, self.ClickEndReason)
      end)
    end
  end
  return true
end
function NewbieGuideActionShowUI:EndAction()
  NewbieGuideActionShowUI.__super.EndAction(self)
  log(bWriteLog and "NewbieGuideActionShowUI EndAction success.")
  if slua.isValid(self.uRegisterBtn) then
    local EventDelegate = self.uRegisterBtn[self.RegisterButtonEventName]
    if slua.isValid(EventDelegate) and EventDelegate.Remove and self.RegisterFunction then
      EventDelegate:Remove(self.RegisterFunction)
    end
  end
  if slua.isValid(self.uGuideItem) then
    self.uGuideItem:RemoveFromParent()
    self.uGuideItem:ConditionalBeginDestroy()
  end
  self.uGuideItem = nil
  self.RegisterFunction = nil
  self.uRegisterBtn = nil
  self.bIsActionPandingKill = true
  self.uAttachParentSlot = nil
end
function NewbieGuideActionShowUI:Clear()
  log(bWriteLog and "Debug NewbieGuide: NGActionShowUI:Clear()")
  NewbieGuideActionShowUI.__super.Clear(self)
  self:EndAction()
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Actions.NewbieGuideActionBase")
local CNewbieGuideActionShowUI = class(CObject, nil, NewbieGuideActionShowUI)
return CNewbieGuideActionShowUI