local Common_RightBottom_Tip_Base = {}
local EClick_v1 = sound_config.click_v1
function Common_RightBottom_Tip_Base:ctor()
end
function Common_RightBottom_Tip_Base:OnInitialize()
  Common_RightBottom_Tip_Base.__super.OnInitialize(self)
end
function Common_RightBottom_Tip_Base:RegistEvents()
  Common_RightBottom_Tip_Base.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_OK, self.OnClickOK, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Jump, self.OnClickJump, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Close, self.OnClickClose, self)
  self:AddControlEventByControl(self.UIRoot.MoveOut, "OnAnimationFinished", self.OnAnimationEnd, self)
end
function Common_RightBottom_Tip_Base:OnShow()
  Common_RightBottom_Tip_Base.__super.OnShow(self)
end
function Common_RightBottom_Tip_Base:OnClose()
  Common_RightBottom_Tip_Base.__super.OnClose(self)
end
function Common_RightBottom_Tip_Base:InitChildUI(bpName, bShowCloseBtn, bShowOKBtn, bShowJumpBtn, second, timeEndCallBack)
  log(bWriteLog and "[chub]Common_RightBottom_Tip_Base:InitChildUI, bpName = " .. tostring(bpName) .. " bShowCloseBtn = " .. tostring(bShowCloseBtn) .. " bShowOKBtn = " .. tostring(bShowOKBtn) .. " bShowJumpBtn = " .. tostring(bShowJumpBtn) .. " second = " .. tostring(second) .. " timeEndCallBack = " .. tostring(timeEndCallBack))
  local UIUtil = require("client.common.ui_util")
  if bpName and bpName ~= "" then
    local bpPath = string.format("/Game/UMG/UI_BP/Universal_Popup/Child/%s.%s", bpName, bpName)
    self.childUI = self:CreateChildWindowWithBpPath("CanvasPanel_Attach", UIManager.UI_Config.Common_RightBottom_Tip_Child_UIBP, bpPath)
  end
  self:SetWidgetVisible(self.UIRoot.Button_Close, bShowCloseBtn, true)
  self:SetWidgetVisible(self.UIRoot.Button_OK, bShowOKBtn, true)
  self:SetWidgetVisible(self.UIRoot.Button_Jump, bShowJumpBtn, true)
  if second and tonumber(second) > 0 then
    local nSecond = tonumber(second)
    self:SetWidgetVisible(self.UIRoot.ProgressBar_Time, true)
    local RemainTime = 0
    self:AddTimer(0, function()
      while RemainTime < nSecond do
        self.UIRoot.ProgressBar_Time:SetPercent(RemainTime / nSecond)
        RemainTime = RemainTime + 0.033
        coroutine.yield(0.033)
      end
      self:PlayUserWidgetAnimation(self.UIRoot.MoveOut, 0, 1, 0, 1)
      if timeEndCallBack and type(timeEndCallBack) == "function" then
        timeEndCallBack()
      end
    end)
  else
    self:SetWidgetVisible(self.UIRoot.ProgressBar_Time, false)
  end
end
function Common_RightBottom_Tip_Base:OnClickClose()
  log(bWriteLog and "[chub]Common_RightBottom_Tip_Base:OnClickClose")
  self:PlayAudio(EClick_v1)
  self:PlayUserWidgetAnimation(self.UIRoot.MoveOut, 0, 1, 0, 1)
end
function Common_RightBottom_Tip_Base:OnClickOK()
  log(bWriteLog and "[chub]Common_RightBottom_Tip_Base:OnClickOK")
  self:PlayAudio(EClick_v1)
  self:PlayUserWidgetAnimation(self.UIRoot.MoveOut, 0, 1, 0, 1)
end
function Common_RightBottom_Tip_Base:OnClickJump()
  log(bWriteLog and "[chub]Common_RightBottom_Tip_Base:OnClickJump")
  self:PlayAudio(EClick_v1)
  self:CloseSelf()
  UIManager.AndroidBackToLobby()
end
function Common_RightBottom_Tip_Base:OnAnimationEnd()
  log(bWriteLog and "[chub]Common_RightBottom_Tip_Base:OnAnimationEnd")
  self:AddTimerOnce(0, function()
    self:CloseSelf()
  end)
end
function Common_RightBottom_Tip_Base:GetSwitchPosWidget()
  local target
  if slua.isValid(self.UIRoot.AnimeBorder_R_Whole) then
    target = self.UIRoot.AnimeBorder_R_Whole
  elseif slua.isValid(self.UIRoot.Border_Side) then
    target = self.UIRoot.Border_Side
  end
  return target
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CUICommon_RightBottom_Tip_Base = class(ui_base, nil, Common_RightBottom_Tip_Base)
return CUICommon_RightBottom_Tip_Base