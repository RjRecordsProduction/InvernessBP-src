local Notice_Tip = {}
function Notice_Tip:ctor()
end
function Notice_Tip:OnPostInitialize()
  self.UIRoot.MsgNode:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
end
function Notice_Tip:ShowNotice(content, style)
  log(bWriteLog and "[Notice_Tip]: content" .. tostring(content))
  if not self.UIRoot then
    log(bWriteLog and "  : Notice_Tip no UIRoot")
    return
  end
  local noticeSystem = require("client.slua.logic.common.logic_notice_mgr")
  local uiConfig = noticeSystem.Tips_Style_Config[style]
  if not uiConfig then
    log(bWriteLog and string.format("Notice_Tip:ShowNotice configuration does not exist. style = %s", style))
    uiConfig = noticeSystem.Tips_Style_Config[noticeSystem.Enum_Tips_Style.Default]
  end
  self:CreateChildWindow(self.UIRoot.MsgNode, uiConfig, content)
  self:ShowMsgNode()
end
function Notice_Tip:ShowMsgNode()
  self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.MsgNode:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function Notice_Tip:IsClosing()
  return self.BClosing
end
function Notice_Tip:ShowHoldNotice(content)
  if not self.isHoldItemShowing then
    self:ShowMsgNode()
    self.holdItem = self:CreateChildWindow(self.UIRoot.MsgNode, UIManager.UI_Config.PopupTipHoldItem)
    self.holdItem:ShowItem()
    self.isHoldItemShowing = true
  end
  self.holdItem:SetContent(content)
end
function Notice_Tip:HideHoldNotice()
  self.holdItem:HideItem()
  self.isHoldItemShowing = false
end
function Notice_Tip:Close()
  self.BClosing = true
  log(bWriteLog and "[ : Notice_Tip:Close")
  Notice_Tip.__super.Close(self)
  self.BClosing = nil
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CNotice_UIBP = class(ui_base, nil, Notice_Tip)
return CNotice_UIBP