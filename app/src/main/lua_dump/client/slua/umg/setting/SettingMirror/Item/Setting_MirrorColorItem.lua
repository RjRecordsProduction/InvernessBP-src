local Setting_MirrorColorItem = {}
function Setting_MirrorColorItem:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_select, self.OnClickButton_select, self)
end
function Setting_MirrorColorItem:OnRefresh(_, selectIndex)
  self:SetWidgetVisible(self.UIRoot.color, true)
  self:SetWidgetVisible(self.UIRoot.SizeBox_Icon, false)
  self:SetWidgetVisible(self.UIRoot.Image_Whiteblock_select, selectIndex == self.index)
  local Setting_Mirror_Main_UIBP = self:GetLoopScrollBoxParentUI()
  local itemColors = Setting_Mirror_Main_UIBP.itemColors[self.index]
  self.UIRoot.color:SetColorAndOpacity(itemColors)
end
function Setting_MirrorColorItem:OnClickButton_select()
  self:PlayAudio(sound_config.click_v1)
  local Setting_Mirror_Main_UIBP = self:GetLoopScrollBoxParentUI()
  Setting_Mirror_Main_UIBP:SelectOneColor(self.index)
  local CrosshairColor = {crosshair = nil, color = nil}
  CrosshairColor.crosshair = Setting_Mirror_Main_UIBP:GetColorKey()
  CrosshairColor.color = tostring(self.index)
  local TLog_ReasonStr = json.encode(CrosshairColor)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.SetCrosshairColor, 0, TLog_ReasonStr)
end
local class = require("class")
local scroll_box_child_base = require("client.slua_ui_framework.component.scroll_box_child_base")
return class(scroll_box_child_base, nil, Setting_MirrorColorItem)