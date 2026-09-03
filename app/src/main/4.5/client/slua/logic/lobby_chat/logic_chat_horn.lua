local logic_chat_horn = {}
function logic_chat_horn:InitChatHornSwitch()
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local settingConfig = slua_GameFrontendHUD:GetUserSettings()
  self.OpenChatHorn = settingConfig.OpenChatHorn
end
function logic_chat_horn:GetChatHornSwitch()
  if self.OpenChatHorn == nil then
    self:InitChatHornSwitch()
  end
  return self.OpenChatHorn
end
function logic_chat_horn:ChangeChatHornSwitch()
  self.OpenChatHorn = not self.OpenChatHorn
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local settingConfig = slua_GameFrontendHUD:GetUserSettings()
  settingConfig.OpenChatHorn = self.OpenChatHorn
end
function logic_chat_horn:BuyHornRequest(callback)
  local price = logic_chat_horn:GetHornPrice()
  if price > DataMgr.ticket then
    if GameStatus.IsInLobbyOrMainCity() then
      local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
      CommonPayBoxMgr.ShowUcRechargeMsg(price)
    else
      ShowNotice(6494)
    end
  else
    local CommonItemBuySystem = require("client.slua.logic.common.logic_common_item_buy")
    local goodsID = CommonItemBuySystem.GetBuyGoodsIDByItemID(ChatHornItemId)
    CommonItemBuySystem.send_easy_buy_req(goodsID, 1, false)
    if callback then
      callback()
    end
  end
end
function logic_chat_horn:GetHornPrice()
  local CommonItemBuySystem = require("client.slua.logic.common.logic_common_item_buy")
  local buyCfg = CommonItemBuySystem.GetBuyCfgByItemID(ChatHornItemId)
  if buyCfg then
    return buyCfg.price
  end
  return 0
end
function logic_chat_horn:ConfirmBuyHorn(callback)
  local hornPrice = logic_chat_horn:GetHornPrice()
  local title = LocUtil.LocalizeResFormat("101001")
  local tip = LocUtil.LocalizeResFormat("9221", hornPrice)
  local buy = 0
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, tip, function()
    if buy == 0 then
      logic_chat_horn:BuyHornRequest(callback)
      buy = buy + 1
    end
  end)
end
function logic_chat_horn:CheckCanSend(chatContent, channel)
  local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
  if LobbySystem.roleData.eugdpr and GdprSystem.LessThan16() then
    ShowNotice(4071)
    return false
  end
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  if channel ~= chat_macro.Channel.channelWorld and channel ~= chat_macro.channelTopic and channel ~= chat_macro.channelTopic2 then
    ShowNotice(9002)
    return false
  end
  if logic_chat_horn:CheckNoText(chatContent) then
    return false
  end
  if logic_chat_horn:CheckOutofTextRange(chatContent) then
    return false
  end
  local StringUtil = require("common.string_util")
  local content = StringUtil.CheckNameRetrunName(chatContent)
  if logic_chat_horn:CheckNoText(content) then
    return false
  end
  return true
end
function logic_chat_horn:CheckNoText(txt)
  local len = string.len(txt)
  if len == 0 then
    ShowNotice(106018)
  end
  return len == 0
end
function logic_chat_horn:CheckOutofTextRange(txt)
  local StringUtil = require("common.string_util")
  local len = StringUtil.get_utf8_blen(txt)
  if 80 < len then
    ShowNotice(100006)
  end
  return 80 < len
end
return logic_chat_horn