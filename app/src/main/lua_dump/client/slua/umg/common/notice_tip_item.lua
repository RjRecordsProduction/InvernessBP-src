local BackTime
local Notice_Tip_Item = {}
local C_Default_Pos = FVector2D(0, 72)
local C_Low_Pos = FVector2D(0, 150)
function Notice_Tip_Item:ctor(sellType, Content, bFast)
  self.  self.end
function Notice_Tip_Item:RegistEvents()
  Notice_Tip_Item.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot.DX_Tips, "OnAnimationFinished", self.AnimEnd, self)
  self:AddControlEventByControl(self.UIRoot.DX_Tips_1, "OnAnimationFinished", self.AnimEnd, self)
  self:AddCommonEvent(EVENTTYPE_REMOVE_NOTICE, EVENTID_REMOVE_NOTICE, self.Close, self)
  self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED, self.OnApplicationReactivated, self)
  self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_DEACTIVATED, self.OnApplicationDeactivated, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_BUBBLE, EVENTTYPE_TIPS_POSITION_REFRESH, self.SetContentPosition, self)
end
function Notice_Tip_Item:OnPostInitialize()
  Notice_Tip_Item.__super.OnPostInitialize(self)
  self:SetContent(self.Content, self.bFast)
end
function Notice_Tip_Item:AnimEnd()
  self:AddTimerOnce(0, function()
    self:Close()
  end)
end
function Notice_Tip_Item:SetContent(content, fast)
  if content and self.UIRoot then
    self:SetContentPosition()
    self.sContent = content
    self.UIRoot.UTRichTextBlock_Msg:SetText(content)
    local anim = self.UIRoot.DX_Tips
    if fast then
      anim = self.UIRoot.DX_Tips_1
    end
    self:PlayUserWidgetAnimation(anim, 0, 1, 0, 1)
  end
end
function Notice_Tip_Item:SetContentPosition()
  if UIManager.GetUI(UIManager.UI_Config.Crate_GuaranteeMechanism_Collect_UIBP) or UIManager.GetUI(UIManager.UI_Config.Common_ProBarTip_UIBP) then
    self.UIRoot.ItemNoticeMsg.Slot:SetPosition(C_Low_Pos)
  else
    self.UIRoot.ItemNoticeMsg.Slot:SetPosition(C_Default_Pos)
  end
end
function Notice_Tip_Item:OnApplicationReactivated()
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  if not BackTime or 1 < now - BackTime then
    self:AnimEnd()
  end
end
function Notice_Tip_Item:OnApplicationDeactivated()
  local TimeUtil = require("client.common.time_util")
  BackTime = TimeUtil.GetServerTimeInSec()
end
function Notice_Tip_Item:OnClose()
  log(bWriteLog and "  : Notice_Tip_Item:OnClose")
  local noticeSystem = require("client.slua.logic.common.logic_notice_mgr")
  noticeSystem.RemoveOneNotice(self.sContent)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CNotice_UIBP = class(ui_base, nil, Notice_Tip_Item)
return CNotice_UIBP