local EntireMapTaskItemTitleUI = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function EntireMapTaskItemTitleUI:ctor()
  self.Index = 0
  self.TitleAndIcon = GamePlayTools.GetCurrentConfig("EntireMapTaskConfig").TitleConfig
  self.bIsOpen = true
end
function EntireMapTaskItemTitleUI:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_View, self.CollapsedBtnClick, self)
end
function EntireMapTaskItemTitleUI:RefreshUI(subValue, index)
  self.Index = index
  if self.TitleAndIcon[index] then
    local titleID = self.TitleAndIcon[index].Title
    self.UIRoot.TextBlock_0:SetText(LocUtil.GetLocalizeResStr(titleID))
  end
end
function EntireMapTaskItemTitleUI:CollapsedBtnClick()
  self.bIsOpen = not self.bIsOpen
  if self.UIRoot and self.UIRoot.Image_Arrow then
    local originSize = self.UIRoot.Image_Arrow.Brush.ImageSize.X
    local size = self.bIsOpen and originSize or -originSize
    local uBrush = slua.IndexReference(self.UIRoot.Image_Arrow, "Brush"):clone()
    uBrush.ImageSize = FVector2D(originSize, size)
    self.UIRoot.Image_Arrow:SetBrush(uBrush)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_TASK_COLLAPSE_BUTTON_CLICK, self.Index, self.bIsOpen, self)
end
function EntireMapTaskItemTitleUI:OnClose()
  EntireMapTaskItemTitleUI.__super.OnClose(self)
end
local class = require("class")
local UIBase = require("GameLua.Mod.BaseMod.Client.Map.EntireMapLeftPanel.EntireMapLeftSubItemUI.EntireMapLeftSubItemUIBase")
return class(UIBase, nil, EntireMapTaskItemTitleUI)