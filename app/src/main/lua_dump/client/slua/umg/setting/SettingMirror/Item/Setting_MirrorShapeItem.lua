local Setting_MirrorShapeItem = {}
function Setting_MirrorShapeItem:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_select, self.OnClickButton_select, self)
end
function Setting_MirrorShapeItem:OnRefresh(data, selectIndex)
  local Setting_Mirror_Main_UIBP = self:GetLoopScrollBoxParentUI()
  local path = Setting_Mirror_Main_UIBP:GetShapePath(data)
  self:SetTexture(self.UIRoot.Image_Icon, path)
  self:SetWidgetVisible(self.UIRoot.color, false)
  self:SetWidgetVisible(self.UIRoot.SizeBox_Icon, true)
  self:SetWidgetVisible(self.UIRoot.Image_Whiteblock_select, selectIndex == self.index)
end
function Setting_MirrorShapeItem:OnClickButton_select()
  self:PlayAudio(sound_config.click_v1)
  local Setting_Mirror_Main_UIBP = self:GetLoopScrollBoxParentUI()
  Setting_Mirror_Main_UIBP:SelectOneShape(self.index)
  local CrossHairShape = {crosshair = nil, shape = nil}
  CrossHairShape.crosshair = Setting_Mirror_Main_UIBP:GetShapeKey()
  CrossHairShape.shape = tostring(self.index)
  local TLog_ReasonStr = json.encode(CrossHairShape)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.SetCrosshairShape, 0, TLog_ReasonStr)
end
local class = require("class")
local scroll_box_child_base = require("client.slua_ui_framework.component.scroll_box_child_base")
return class(scroll_box_child_base, nil, Setting_MirrorShapeItem)