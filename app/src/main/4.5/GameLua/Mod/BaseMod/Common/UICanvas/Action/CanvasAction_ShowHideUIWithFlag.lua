local ShowHideUIFlag = require("GameLua.Mod.BaseMod.Client.Config.ShowHideUIFlag")
local CanvasAction_ShowHideUIWithFlag = {
  sActionName = "CanvasAction_ShowHideUIWithFlag"
}
function CanvasAction_ShowHideUIWithFlag:ctor()
  self.CurrentFlgValue = {}
end
function CanvasAction_ShowHideUIWithFlag:BindEvent()
  if not self.Config.Show and not self.Config.Hide then
    return
  end
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_SHOW_HIDE_UI_WITH_FLAG, self.OnFlagChange, self)
end
function CanvasAction_ShowHideUIWithFlag:UnbindEvent()
  self.CurrentFlgValue = {}
  self:RemoveCommonEvent(EVENTTYPE_INGAME, EVENTID_SHOW_HIDE_UI_WITH_FLAG)
end
function CanvasAction_ShowHideUIWithFlag:OnFlagChange(_, _, FlagName, FlagValue)
  if self.Config.Show and self.Config.Show[FlagName] == nil or self.Config.Hide and self.Config.Hide[FlagName] == nil then
    return
  end
  self.CurrentFlgValue[FlagName] = FlagValue
  if bWriteLog then
    print(bWriteLog and "OnFlagChange", FlagName, FlagValue)
  end
  if self.Config.Show then
    self.bIsShow = self:HasValue(self.Config.Show)
  elseif self.Config.Hide then
    self.bIsShow = not self:HasValue(self.Config.Hide)
  end
  self:UpdateCanvasShow()
end
function CanvasAction_ShowHideUIWithFlag:HasValue(ConfigFlags)
  for FlagName, FlagValue in pairs(ConfigFlags) do
    if self.CurrentFlgValue[FlagName] == FlagValue then
      return true
    end
  end
  return false
end
local class = require("class")
local CanvasActionBase = require("GameLua.Mod.BaseMod.Common.UICanvas.Action.CanvasActionBase")
return class(CanvasActionBase, nil, CanvasAction_ShowHideUIWithFlag)