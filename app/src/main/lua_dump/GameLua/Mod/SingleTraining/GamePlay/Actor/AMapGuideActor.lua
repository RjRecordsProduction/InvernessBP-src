local AMapGuideActor = {}
function AMapGuideActor:ctor(selfType)
  print(bWriteLog and "AMapGuideActor:ctor")
  self.bWidgetCreated = false
end
function AMapGuideActor:ReceiveBeginPlay()
  print(bWriteLog and "AMapGuideActor:ReceiveBeginPlay")
  AMapGuideActor.__super.ReceiveBeginPlay(self)
  if Client then
    self:Create3DWidget()
  end
end
function AMapGuideActor:Create3DWidget()
  print(bWriteLog and "AMapGuideActor:Create3DWidget", self.bWidgetCreated)
  if self.bWidgetCreated then
    return
  end
  local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local path = "/Game/Mod/SingleTraining/BluePrints/UI/SingleTrain_3DGuide_UIBP.SingleTrain_3DGuide_UIBP_C"
  local Widget = USTExtraBlueprintFunctionLibrary.CreateWidgetByPathName(path, self.Object)
  if slua.isValid(Widget) then
    print(bWriteLog and "AMapGuideActor:Create3DWidget success")
    self.Widget:SetWidget(Widget)
    print(bWriteLog and "AMapGuideActor:Create3DWidget SetWidget success")
    self.Widget:RequestRedraw()
    print(bWriteLog and "AMapGuideActor:Create3DWidget RequestRedraw success")
    self.bWidgetCreated = true
  else
    print(bWriteLog and "AMapGuideActor:Create3DWidget failed")
  end
end
function AMapGuideActor:CloseUI(component)
  component = component or self:GetInteractiveComponent()
  if UIManager.UI_Config_InGame and UIManager.UI_Config_InGame.MapGuideInteractiveUI then
    local ui = UIManager.GetUI(UIManager.UI_Config_InGame.MapGuideInteractiveUI)
    if ui then
      ui:Hide(component)
    end
    UIManager.HideUI(UIManager.UI_Config_InGame.SingleTraining_MapGuide)
  end
end
function AMapGuideActor:ShowUI(component)
  component = component or self:GetInteractiveComponent()
  if UIManager.UI_Config_InGame.MapGuideInteractiveUI == nil then
    return
  end
  local ui = UIManager.GetUI(UIManager.UI_Config_InGame.MapGuideInteractiveUI)
  if ui ~= nil then
    if component and slua.isValid(component) then
      ui:Show(component, component.BtnImage, component.TextId, component.SkillId)
    else
      print(bWriteLog and "AMapGuideActor:ShowUI, component = nil")
    end
  elseif component and slua.isValid(component) then
    UIManager.ShowUI(UIManager.UI_Config_InGame.MapGuideInteractiveUI, component, component.BtnImage, component.TextId, component.SkillId)
  else
    print(bWriteLog and "AMapGuideActor:ShowUI, component = nil")
  end
end
local Class = require("class")
local CInteractiveActorBase = require("GameLua.Mod.BaseMod.GamePlay.Actor.AInteractiveActorBase")
local AMapGuideActorClass = Class(CInteractiveActorBase, nil, AMapGuideActor)
return AMapGuideActorClass