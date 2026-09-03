local Collect_Milestone_Item_UIBP = {}
function Collect_Milestone_Item_UIBP:ctor()
end
function Collect_Milestone_Item_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Jump, self.OnClickButton_Jump, self)
end
function Collect_Milestone_Item_UIBP:OnRefresh(data, selectIndex)
  self.UIRoot.TextBlock_3:SetText(LocUtil.GetLocalizeResStr(82027))
  self.UIRoot.TextBlock_0:SetText(data.name)
  local UIUtil = require("client.common.ui_util")
  self:SetTexture(self.UIRoot.Image_Icon, UIUtil.GetPreview(data.itemID, self.UIRoot.Image_Icon), {sync = false})
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Lock, not data.acquired)
  self:CheckShowGuideView()
end
function Collect_Milestone_Item_UIBP:CheckShowGuideView()
  if self.index ~= 1 then
    self.UIRoot.CanvasPanel_Guide:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local parent = self:GetLoopScrollBoxParentUI()
  if parent and parent.IsShowViewGuide and parent:IsShowViewGuide() then
    self.UIRoot.CanvasPanel_Guide:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.CanvasPanel_Guide:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Collect_Milestone_Item_UIBP:OnClickButton_Jump()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.Collect_Milestone_Detail_UIBP, self.data.sysType, self.data.itemID)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.component.scroll_box_child_base")
local CCollect_Milestone_Item_UIBP = class(ui_base, nil, Collect_Milestone_Item_UIBP)
return CCollect_Milestone_Item_UIBP