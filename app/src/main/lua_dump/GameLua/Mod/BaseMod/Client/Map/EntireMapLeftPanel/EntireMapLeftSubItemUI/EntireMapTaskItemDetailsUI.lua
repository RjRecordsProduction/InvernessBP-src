local EntireMapTaskItemDetailsUI = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function EntireMapTaskItemDetailsUI:ctor()
  self.TitleAndIcon = GamePlayTools.GetCurrentConfig("EntireMapTaskConfig").TitleConfig
end
function EntireMapTaskItemDetailsUI:RegistEvents()
end
function EntireMapTaskItemDetailsUI:RefreshUI(subValue, index)
  local DataCfg = CDataTable.GetTableData("LobbyToFightTaskInfo", subValue.ID)
  if DataCfg then
    local TextID = tonumber(DataCfg.TaskDesc)
    local ContentText = LocUtil.LocalizeResFormat(TextID, DataCfg.AimValue)
    if subValue.AimProgress > 0 then
      if subValue.CurProgress >= subValue.AimProgress then
        ContentText = LocUtil.LocalizeResFormat(9486, ContentText, subValue.CurProgress, subValue.AimProgress)
      else
        local FormatText = LocUtil.LocalizeResFormat(37372, ContentText, subValue.CurProgress, subValue.AimProgress)
        ContentText = FormatText
      end
    end
    self.UIRoot.UTRichTextBlock_0:SetText(ContentText)
    self.UIRoot.ProgressBar_0:SetPercent(subValue.Percent)
    if self.TitleAndIcon[index] then
      self.UIRoot.Image_Task:SetBrushFromPathAsync(self.TitleAndIcon[index].IconPath, false)
    end
  else
    print(bWriteLog and "EntireMapTaskItemDetailsUI:RefreshUI Failed Case Config Data None ID :", subValue.ID)
  end
end
function EntireMapTaskItemDetailsUI:OnClose()
  EntireMapTaskItemDetailsUI.__super.OnClose(self)
end
local class = require("class")
local UIBase = require("GameLua.Mod.BaseMod.Client.Map.EntireMapLeftPanel.EntireMapLeftSubItemUI.EntireMapLeftSubItemUIBase")
return class(UIBase, nil, EntireMapTaskItemDetailsUI)