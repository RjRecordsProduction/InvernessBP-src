local Common_Right_Reward_UIBP = {}
function Common_Right_Reward_UIBP:ctor(_, title, content, itemId, count, expireTS, jumpInfo, nSecond)
  log(bWriteLog and "Common_Right_Reward_UIBP:ctor" .. " title = " .. tostring(title) .. " content = " .. tostring(content) .. " itemId = " .. tostring(itemId) .. " count = " .. tostring(count) .. " expireTS = " .. tostring(expireTS) .. " nSecond = " .. tostring(nSecond))
  log_tree(bWriteLog and "Common_Right_Reward_UIBP:ctor jumpInfo = ", jumpInfo)
  self.  self.  self.  self.count = count or 0
  self.expireTS = expireTS or 0
  self.nSecond = nSecond or 8
  self.end
function Common_Right_Reward_UIBP:OnShow()
  Common_Right_Reward_UIBP.__super.OnShow(self)
  self:UpdateUI()
  self:PlayUserWidgetAnimation(self.UIRoot.MoveIn, 0, 1, 0, 1)
end
function Common_Right_Reward_UIBP:UpdateUI()
  log(bWriteLog and "Common_Right_Reward_UIBP:UpdateUI")
  if self.jumpInfo then
    self:InitChildUI("Common_Right_Reward_UIBP", true, false, true, self.nSecond)
  else
    self:InitChildUI("Common_Right_Reward_UIBP", true, true, false, self.nSecond)
  end
  self:InitText()
  self:InitReward()
end
function Common_Right_Reward_UIBP:InitText()
  log(bWriteLog and "Common_Right_Reward_UIBP:InitText")
  self.childUI.UIRoot.UTRichTextBlock_Title:SetText(self.title)
  self.childUI.UIRoot.UTRichTextBlock_Content:SetText(self.content)
end
function Common_Right_Reward_UIBP:InitReward()
  log(bWriteLog and "Common_Right_Reward_UIBP:InitReward")
  self.childUI.UIRoot.Lua_CommonItems:InitView(tonumber(self.itemId), self.count, self.expireTS)
end
function Common_Right_Reward_UIBP:OnClickJump()
  Common_Right_Reward_UIBP.__super.OnClickJump(self)
  log(bWriteLog and "Common_Right_Reward_UIBP:OnClickJump")
  local jumpInfo = self.jumpInfo
  if not jumpInfo then
    return
  end
  if jumpInfo.checkJump and type(jumpInfo.checkJump) == "function" and not jumpInfo.checkJump() then
    return
  end
  if jumpInfo.callback and type(jumpInfo.callback) == "function" then
    UIManager.AndroidBackToLobby()
    jumpInfo.callback()
  end
end
local class = require("class")
local ui_base = require("client.slua.umg.common.Common_RightBottom_Tip_Base")
local CUITemplate = class(ui_base, nil, Common_Right_Reward_UIBP)
return CUITemplate