local NGActionShowAirLineTips = {}
function NGActionShowAirLineTips:ctor(selfType, __)
  self.AttachParentWindow = "EntireMapWindow"
  self.MapCanvasName = "EntireMapCanvas"
  self.AirLineName = "CanvasPanel_Airline"
  self.StartPointName = "Image_Start"
  self.EndPointName = "Image_End"
  self.AirLineWidgetName = "AirLineWidget"
  self.uGuideItem = nil
end
function NGActionShowAirLineTips:RunAction(InGuideID)
  NGActionShowAirLineTips.__super.RunAction(self, InGuideID)
  if not self:CreateGuideUI() then
    self:EndAction()
    return false
  end
  return true
end
function NGActionShowAirLineTips:CreateGuideUI()
  if not UIManager then
    return false
  end
  local UIConfig = UIManager.UI_Config_InGame[self.AttachParentWindow]
  local uMapCanvas, uAirLine, uImageStart, uImageEnd
  local Window = UIManager.GetUI(UIConfig)
  if Window then
    local uAttachParentWindow = Window.UIRoot
    if uAttachParentWindow then
      uMapCanvas = uAttachParentWindow:GetWidgetFromName(self.MapCanvasName)
      uAirLine = uAttachParentWindow:GetWidgetsByName(self.AirLineName, self.AirLineWidgetName, true)
      uImageStart = uAttachParentWindow:GetWidgetsByName(self.StartPointName, self.AirLineWidgetName, true)
      uImageEnd = uAttachParentWindow:GetWidgetsByName(self.EndPointName, self.AirLineWidgetName, true)
    end
  end
  if not slua.isValid(uMapCanvas) or uMapCanvas.AddChild == nil then
    sandbox.LogError("MapCanvas slog is not valid:" .. self.MapCanvasName)
    return false
  end
  if not (slua.isValid(uAirLine) and slua.isValid(uImageStart)) or not slua.isValid(uImageEnd) then
    sandbox.LogError("AirLine/ImageStart/ImageEnd is not valid:" .. self.AirLineName)
    return false
  end
  self.uGuideItem = slua.loadUI("/Game/BluePrints/ControlInput/NewbieItem/NewbieTips_Map.NewbieTips_Map")
  if not slua.isValid(self.uGuideItem) then
    sandbox.LogError("can not create guide ui item!")
    return false
  end
  local uSlot = uAirLine:AddChild(self.uGuideItem)
  if slua.isValid(uSlot) then
    if uSlot.SetZOrder then
      uSlot:SetZOrder(100)
    elseif uSlot.SetLayer then
      uSlot:SetLayer(100)
    end
  end
  local nAirLineAngle = 0
  local RenderTransform = uAirLine.RenderTransform
  if RenderTransform then
    nAirLineAngle = RenderTransform.Angle
    self.uGuideItem:SetRenderAngle(-nAirLineAngle)
  end
  local USlateBlueprintLibrary = import("SlateBlueprintLibrary")
  local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
  local KismetMathLibrary = import("KismetMathLibrary")
  local ImageStartPos = USlateBlueprintLibrary.GetAbsolutePosition(uImageStart:GetCachedGeometry())
  local ImageEndPos = USlateBlueprintLibrary.GetAbsolutePosition(uImageEnd:GetCachedGeometry())
  local AirLineCenterPos = KismetMathLibrary.MakeVector2D(ImageStartPos.X + (ImageEndPos.X - ImageStartPos.X) * 0.5, ImageStartPos.Y + (ImageEndPos.Y - ImageStartPos.Y) * 0.5)
  local EntireMapPos = USlateBlueprintLibrary.GetAbsolutePosition(uMapCanvas:GetCachedGeometry())
  local EntireMapSize = USlateBlueprintLibrary.GetAbsoluteSize(uMapCanvas:GetCachedGeometry())
  local sTipText = DataMgr.GetFormatMsgByIDForBattleText(12523)
  if not sTipText then
    sandbox.LogError("NGActionShowAirLineTips:CreateGuideUI can't find tips text!")
    return false
  end
  self.uGuideItem.UTRichTextBlock_4:SetText(sTipText)
  local TipsOffset = KismetMathLibrary.MakeVector2D((ImageEndPos.X - ImageStartPos.X) * 0.5, (ImageEndPos.Y - ImageStartPos.Y) * 0.5 + 2.5)
  local OffsetX = (AirLineCenterPos.X - EntireMapPos.X) / EntireMapSize.X
  local OffsetY = (AirLineCenterPos.Y - EntireMapPos.Y) / EntireMapSize.Y
  local TipsSlot = WidgetLayoutLibrary.SlotAsCanvasSlot(self.uGuideItem.CanvasPanel_17)
  if -15.0 < nAirLineAngle and nAirLineAngle < 15.0 or math.abs(nAirLineAngle) > 165.0 then
    if OffsetY < 0.5 then
      TipsSlot:SetPosition(KismetMathLibrary.MakeVector2D(TipsOffset.X, TipsOffset.Y + 57.0))
      TipsSlot:SetAlignment(KismetMathLibrary.MakeVector2D(0.5, 0.0))
      self.uGuideItem.Image_up:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      TipsSlot:SetPosition(KismetMathLibrary.MakeVector2D(TipsOffset.X, TipsOffset.Y - 57.0))
      TipsSlot:SetAlignment(KismetMathLibrary.MakeVector2D(0.5, 1.0))
      self.uGuideItem.Image_down:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif OffsetX < 0.5 then
    TipsSlot:SetPosition(KismetMathLibrary.MakeVector2D(TipsOffset.X + 57.0, TipsOffset.Y))
    TipsSlot:SetAlignment(KismetMathLibrary.MakeVector2D(0.0, 0.5))
    self.uGuideItem.Image_left:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    TipsSlot:SetPosition(KismetMathLibrary.MakeVector2D(TipsOffset.X - 57.0, TipsOffset.Y))
    TipsSlot:SetAlignment(KismetMathLibrary.MakeVector2D(1.0, 0.5))
    self.uGuideItem.Image_right:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  return true
end
function NGActionShowAirLineTips:EndAction()
  NGActionShowAirLineTips.__super.EndAction(self)
  if slua.isValid(self.uGuideItem) then
    self.uGuideItem:RemoveFromParent()
    self.uGuideItem:ConditionalBeginDestroy()
  end
  self.uGuideItem = nil
end
function NGActionShowAirLineTips:ClearAction()
  NGActionShowAirLineTips.__super.Clear(self)
  self:EndAction()
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Actions.NewbieGuideActionBase")
local CNGActionShowAirLineTips = class(CObject, nil, NGActionShowAirLineTips)
return CNGActionShowAirLineTips