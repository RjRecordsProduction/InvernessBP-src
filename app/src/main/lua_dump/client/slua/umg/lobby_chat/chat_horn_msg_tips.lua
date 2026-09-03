local chat_horn_msg_tips = {}
local DELAY_TIME = 8
function chat_horn_msg_tips:ctor(selfType)
  self.timerDelay = 8.0
end
function chat_horn_msg_tips:RegistEvents()
  chat_horn_msg_tips.__super.RegistEvents(self)
  if self.UIRoot.Button_OpenChat then
    self:AddOnClickedEventByControl(self.UIRoot.Button_OpenChat, self.OnOpenChat, self)
  end
  if self.UIRoot.Common_Avatar_BP then
    self:AddControlEventByControl(self.UIRoot.Common_Avatar_BP, "OnClickItemCallback", self.OnChatHeadClicked, self)
  end
end
function chat_horn_msg_tips:InitTips(channel_type, chat_content, avatarData, self_msg, topic)
  self.  self.  self.  self.  if avatarData ~= nil then
    self.Gid = avatarData.Gid
    self:RefreshTipsInfo(avatarData)
  end
  self.timerDelay = DELAY_TIME
end
function chat_horn_msg_tips:OnPostInitialize()
  chat_horn_msg_tips.__super.OnPostInitialize(self)
  local timeInterval = 1
  self.delayTimer = self:AddTimer(timeInterval, function()
    while true do
      self.timerDelay = self.timerDelay - timeInterval
      while self.timerDelay > 0 do
        self.timerDelay = self.timerDelay - timeInterval
        coroutine.yield(timeInterval)
      end
      self:Collapsed()
      while self.timerDelay < 0 do
        coroutine.yield(timeInterval)
      end
    end
  end)
end
function chat_horn_msg_tips:RefreshTipsInfo(avatarData)
  if self.UIRoot == nil then
    return
  end
  if avatarData ~= nil then
    self.UIRoot.sender_name:SetText(avatarData.NickName)
    self.UIRoot.Common_Avatar_BP:InitView(1, avatarData.Gid, avatarData.Url, 0, avatarData.AvatarBox, avatarData.Level, false, "", false)
    self:SetPass(avatarData)
    if self.UIRoot.Title_UIBP then
      self.UIRoot.Title_UIBP:SetAliasInfo(avatarData.AliasId or 0, avatarData.AliasTitle or "", avatarData.AliasNation or "", 0, avatarData.AliasRankId or 0)
    end
  end
  if self.chat_content ~= nil then
    self.UIRoot.chat_content:SetText(self.chat_content)
  end
end
function chat_horn_msg_tips:SetPass(avatarData)
  if self.UIRoot.UnknowPass_ContinuousBuy_BP_0 then
    if avatarData and avatarData.UpassShow ~= 0 and avatarData.UpassShow ~= false then
      self.UIRoot.UnknowPass_ContinuousBuy_BP_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.UIRoot.UnknowPass_ContinuousBuy_BP_0:SetTypeData(0, avatarData.UpassKeepBuy, avatarData.UpassIsBuy, 1, avatarData.UpassCurValue, avatarData.pass_type or 0)
    else
      self.UIRoot.UnknowPass_ContinuousBuy_BP_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function chat_horn_msg_tips:OnOpenChat()
  self:PlayAudio(sound_config.click_v1)
  if self.channel_type ~= nil then
    self:Collapsed()
    local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
    logic_chat_main.OpenChatMainByTopic(self.topic)
  end
end
function chat_horn_msg_tips:OnChatHeadClicked()
  if not self.self_msg and self.Gid ~= nil then
    self:PlayAudio(sound_config.click_v1)
    local ChatMenuSystem = require("client.slua.logic.lobby_chat.logic_chat_menu")
    UIManager.ShowUI(UIManager.UI_Config.ChatMenu_BP, {
      Uid = self.Gid,
      Name = "",
      ChatContent = "",
      IsShowReport = false
    }, ChatMenuSystem.EShowLocationType.Chat)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CChatHornMsgTips = class(ui_base, nil, chat_horn_msg_tips)
return CChatHornMsgTips