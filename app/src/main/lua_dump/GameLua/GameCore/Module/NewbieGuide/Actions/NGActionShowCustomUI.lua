local NGActionShowCustomUI = {}
function NGActionShowCustomUI:ctor(selfType, Params)
  self.GuideCanvasTag = Params.GuideCanvasTag
  self.CustomUIPath = Params.CustomUIPath
  self.AttachParentWindow = Params.AttachParentWindow or nil
  self.AttachParentSlot = Params.AttachParentSlot or nil
  self.TextBlockName = Params.TextBlockName or nil
  self.nTextId = Params.nTextId or 0
  self.bIsInAsyncLoading = false
  self.uGuideItem = nil
  self.uGuideCanvas = nil
  self.bIsActionPandingKill = false
  self.UseSizeToContent = Params.UseSizeToContent or false
end
function NGActionShowCustomUI:RunAction(InGuideID)
  log(bWriteLog and "Debug NewbieGuide: NGActionShowCustomUI RunAction CustomUIPath:" .. self.CustomUIPath)
  NGActionShowCustomUI.__super.RunAction(self, InGuideID)
  if slua.isValid(self.uGuideItem) then
    sandbox.LogError("Debug NewbieGuide: NGActionShowCustomUI RunAction uGuideItem is exist, CustomUIPath:" .. self.CustomUIPath)
    return false
  end
  if self.bIsInAsyncLoading then
    sandbox.LogError("Debug NewbieGuide: NGActionShowCustomUI RunAction uGuideItem is Loading, CustomUIPath:" .. self.CustomUIPath)
    return false
  end
  local NewbieGuideMgr = require("GameLua.GameCore.Module.NewbieGuide.NewbieGuideMgr")
  self.uGuideCanvas = NewbieGuideMgr.GuideCanvasMap[self.GuideCanvasTag]
  if not self.GuideCanvasTag and self.AttachParentWindow and self.AttachParentSlot then
    self.uGuideCanvas = self:GetAttachParent()
  end
  if not slua.isValid(self.uGuideCanvas) then
    sandbox.LogError("Debug NewbieGuide: NGActionShowCustomUI RunAction No find GuideCanvasTag:" .. self.GuideCanvasTag)
    return false
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    local USTExtraUIUtils = import("STExtraUIUtils")
    USTExtraUIUtils.AsyncCreateWidgetWithCallBack(self.CustomUIPath, uPlayerController, slua.createDelegate(function(widget, InstID)
      self:OnCreateWidgetCallback(widget, InstID)
    end), 0)
    self.bIsInAsyncLoading = true
  end
  return true
end
function NGActionShowCustomUI:OnCreateWidgetCallback(widget, InstID)
  self.bIsInAsyncLoading = false
  if self.bIsActionPandingKill then
    log(bWriteLog and "Debug NewbieGuide: NGActionShowCustomUI:OnCreateWidgetCallback() bIsActionPandingKill == true")
    return
  end
  if slua.isValid(widget) and slua.isValid(self.uGuideCanvas) then
    log(bWriteLog and "Debug NewbieGuide: NGActionShowCustomUI OnCreateWidgetCallback widget:" .. self.CustomUIPath)
    self.uGuideItem = widget
    local uGuideSlot = self.uGuideCanvas:AddChildToCanvas(widget)
    if self.UseSizeToContent then
      uGuideSlot:SetAutoSize(true)
    else
      uGuideSlot:SetAnchors(FAnchors(0, 0, 1, 1))
      uGuideSlot:SetOffsets(FMargin(0, 0, 0, 0))
    end
    if widget.AdjustTextPosition then
      widget:AdjustTextPosition()
    end
    if self.TextBlockName and self.nTextId then
      local TextBlock = widget:GetWidgetFromName(self.TextBlockName)
      if slua.isValid(TextBlock) then
        TextBlock:SetText(LocUtil.GetLocalizeResStr(self.nTextId))
      end
    end
  end
end
function NGActionShowCustomUI:GetAttachParent()
  local UIConfig = UIManager.UI_Config_InGame[self.AttachParentWindow]
  local uAttachParentSlot
  if UIConfig then
    local Window = UIManager.GetUI(UIConfig)
    if Window then
      local uAttachParentWindow = Window.UIRoot
      if uAttachParentWindow then
        uAttachParentSlot = uAttachParentWindow:GetWidgetFromName(self.AttachParentSlot)
      end
    end
  else
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(uPlayerController) then
      sandbox.LogError("playercontroller is nil")
      return uAttachParentSlot
    end
    local Logic = slua_GameFrontendHUD:GetLogicManagerByName(self.AttachParentWindow)
    if not slua.isValid(Logic) then
      sandbox.LogError("can not find valid logic:" .. self.AttachParentWindow)
      return uAttachParentSlot
    end
    local WidgetList = Logic:GetWidgetList()
    for Index = 0, WidgetList:Num() - 1 do
      local Widget = WidgetList:Get(Index)
      if slua.isValid(Widget) and Widget.GetWidgetsByName and not slua.isValid(uAttachParentSlot) then
        uAttachParentSlot = Widget:GetWidgetsByName(self.AttachParentSlot, "", false)
      end
      if slua.isValid(uAttachParentSlot) then
        break
      end
    end
  end
  return uAttachParentSlot
end
function NGActionShowCustomUI:EndAction()
  NGActionShowCustomUI.__super.EndAction(self)
  if slua.isValid(self.uGuideItem) then
    self.uGuideItem:RemoveFromViewport()
  end
  self.uGuideItem = nil
  self.uGuideCanvas = nil
end
function NGActionShowCustomUI:Clear()
  log(bWriteLog and "Debug NewbieGuide: NGActionShowCustomUI:Clear()")
  if slua.isValid(self.uGuideItem) then
    self.uGuideItem:RemoveFromViewport()
  end
  self.uGuideItem = nil
  self.uGuideCanvas = nil
  self.bIsActionPandingKill = true
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Actions.NewbieGuideActionBase")
local CNGActionShowCustomUI = class(CObject, nil, NGActionShowCustomUI)
return CNGActionShowCustomUI