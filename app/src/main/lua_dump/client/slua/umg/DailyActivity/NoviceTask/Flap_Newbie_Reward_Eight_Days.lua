local Flap_Newbie_Reward_Eight_Days = {}
function Flap_Newbie_Reward_Eight_Days:ctor()
end
function Flap_Newbie_Reward_Eight_Days:OnInitialize()
  Flap_Newbie_Reward_Eight_Days.__super.OnInitialize(self)
  local UIUtil = require("client.common.ui_util")
  UIUtil.SetAdaptation(self.UIRoot.ScaleBox_IPX)
end
function Flap_Newbie_Reward_Eight_Days:RegistEvents()
  Flap_Newbie_Reward_Eight_Days.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_CloseUI, self.OnButton_CloseUIClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Common_UIPopupBG.Button_0, self.OnButton_CloseUIClick, self)
end
function Flap_Newbie_Reward_Eight_Days:UpdateSelect()
end
function Flap_Newbie_Reward_Eight_Days:OnPostInitialize()
  Flap_Newbie_Reward_Eight_Days.__super.OnPostInitialize(self)
end
function Flap_Newbie_Reward_Eight_Days:OnButton_CloseUIClick()
  self:PlayAudio(sound_config.close_v1)
  log(bWriteLog and "Flap_Newbie_Reward_Eight_Days:OnButton_CloseUIClick")
  self:CloseSelf()
end
local class = require("class")
local Newbie_Reward_Eight_Days_UIBP = require("client.slua.umg.DailyActivity.NoviceTask.Newbie_Reward_Eight_Days_UIBP")
local CFlap_Newbie_Reward_Eight_Days = class(Newbie_Reward_Eight_Days_UIBP, nil, Flap_Newbie_Reward_Eight_Days)
return CFlap_Newbie_Reward_Eight_Days