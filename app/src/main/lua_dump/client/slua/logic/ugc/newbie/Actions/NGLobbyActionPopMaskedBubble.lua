local NGLobbyActionPopMaskedBubble = {}
function NGLobbyActionPopMaskedBubble:ctor(selfType, Params)
  self.TargetUIName = Params and Params.TargetUIName
  self.TargetWidgetName = Params and Params.TargetWidgetName
  self.BubbleConfigID = Params and Params.BubbleConfigID
  self.OverrideClickedFunc = Params and Params.OverrideClickedFunc
  self.BubbleDelayTime = Params and Params.BubbleDelayTime or 0
  self.GetUIContainerFunc = Params and Params.GetUIContainerFunc
end
function NGLobbyActionPopMaskedBubble:GetTargetWidget()
  log(bWriteLog and "Debug NGLobbyActionPopMaskedBubble GetTargetWidget" .. " TargetUIName:" .. tostring(self.TargetUIName) .. " TargetWidgetName:" .. tostring(self.TargetWidgetName))
  local UIConfig = UIManager.UI_Config[self.TargetUIName]
  UIConfig = UIConfig or UIManager.UI_Config_InGame[self.TargetUIName]
  local ui = UIManager.GetUI(UIConfig)
  if ui then
    return ui.UIRoot:GetWidgetFromName(self.TargetWidgetName), ui
  end
  return nil
end
function NGLobbyActionPopMaskedBubble:GetTargetContainer()
  if self.GetUIContainerFunc then
    return self.GetUIContainerFunc()
  end
  return nil
end
function NGLobbyActionPopMaskedBubble:RunAction(InGuideID, ...)
  self.GuideID = InGuideID
  local logic_ugc_newbie_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_newbie_guide)
  if logic_ugc_newbie_guide then
    local TargetWidget, UI = self:GetTargetWidget()
    local Container, UIName = self:GetTargetContainer()
    if TargetWidget then
      local time_ticker = require("common.time_ticker")
      self._Timer = time_ticker.AddTimer(self.BubbleDelayTime, function()
        self.ui = logic_ugc_newbie_guide:ShowBubble(self.BubbleConfigID, TargetWidget, TargetWidget, self.OverrideClickedFunc, self.GuideID, Container, UIName)
        self:ClearTimer()
      end)
    else
      EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_BTN_DAEMON_UI_HIDDEN, self.GuideID)
    end
  end
  return true
end
function NGLobbyActionPopMaskedBubble:ClearTimer()
  if self._Timer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(self._Timer)
  end
  self._Timer = nil
end
function NGLobbyActionPopMaskedBubble:EndAction(InGuideID)
  if self.ui and slua.isValid(self.ui.UIRoot) then
    self.ui:Close()
  end
  self:ClearTimer()
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Actions.NewbieGuideActionBase")
local CNewbieGuideActionShowUI = class(CObject, nil, NGLobbyActionPopMaskedBubble)
return CNewbieGuideActionShowUI