local EntireMapVersionTaskItemDetailsUI = {}
function EntireMapVersionTaskItemDetailsUI:ctor()
end
function EntireMapVersionTaskItemDetailsUI:RegistEvents()
end
function EntireMapVersionTaskItemDetailsUI:RefreshUI(subValue, index)
  local AimValue = subValue.AimProgress
  local CurID = subValue.ItemID2
  local ShowProgress = subValue.CurProgress
  if ShowProgress > subValue.AimProgress then
    AimValue = subValue.AimProgress2
    if subValue.ItemID1 ~= 0 then
      CurID = subValue.ItemID1
    end
    if ShowProgress > subValue.AimProgress2 then
      ShowProgress = subValue.AimProgress2
    end
  end
  local Percent = ShowProgress / AimValue
  local ContentText = LocUtil.LocalizeResFormat(37372, subValue.TaskName, ShowProgress, AimValue)
  self.UIRoot.ProgressBar_0:SetPercent(Percent)
  self.UIRoot.UTRichTextBlock_0:SetText(ContentText)
  self.UIRoot.Lua_CommonItems:InitView(CurID)
end
function EntireMapVersionTaskItemDetailsUI:OnClose()
  EntireMapVersionTaskItemDetailsUI.__super.OnClose(self)
end
local class = require("class")
local UIBase = require("GameLua.Mod.BaseMod.Client.Map.EntireMapLeftPanel.EntireMapLeftSubItemUI.EntireMapLeftSubItemUIBase")
return class(UIBase, nil, EntireMapVersionTaskItemDetailsUI)