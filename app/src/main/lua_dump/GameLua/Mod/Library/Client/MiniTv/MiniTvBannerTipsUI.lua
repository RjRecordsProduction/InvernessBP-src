local math = require("math")
local time_ticker = require("common.time_ticker")
local TIPSTIME = 3
local TIPSSTARTNUM = 25004
local TIPSENDNUM = 25019
local TipsList = {}
local MiniTvBannerTipsUI = {}
function MiniTvBannerTipsUI:OnInitialize()
  TipsList = {}
  self:InitTipsList()
end
function MiniTvBannerTipsUI:OnClose()
  log(bWriteLog and "MiniTvBannerTipsUI OnClose ")
end
function MiniTvBannerTipsUI:InitTipsList()
  for i = TIPSSTARTNUM, TIPSENDNUM do
    local tipsText
    tipsText = LocUtil.GetLocalizeResStr(i)
    if tipsText and tipsText ~= "" then
      table.insert(TipsList, tipsText)
    end
  end
end
function MiniTvBannerTipsUI:ctor()
end
function MiniTvBannerTipsUI:OnShow()
  log(bWriteLog and "MiniTvBannerTipsUI OnShow ")
  self:PlayTips()
end
function MiniTvBannerTipsUI:OnHide()
  log(bWriteLog and "MiniTvBannerTipsUI OnHide ")
  if self.HideCallback then
    self.HideCallback()
  end
end
function MiniTvBannerTipsUI:PlayTips()
  log(bWriteLog and "MiniTvBannerTipsUI PlayTips ")
  if not self:IsShow() then
    return
  end
  local tipsText
  tipsText = self:GetTipsText()
  if tipsText == nil then
    self:Hide()
    return
  end
  self.UIRoot.Text_Message_Tips:SetText(tipsText)
  local _HideTips = function()
    self:Hide()
  end
  self:AddTimer(TIPSTIME, _HideTips)
end
function MiniTvBannerTipsUI:GetTipsText()
  local math_random = math.random
  local tipsText, num
  num = math_random(1, #TipsList)
  if num == nil then
    return
  end
  tipsText = TipsList[num]
  return tipsText
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, MiniTvBannerTipsUI)