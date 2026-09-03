local Collect_JumpBase = {}
local urls = {
  "game://?module=1009501",
  "game://?module=1008403",
  "game://?module=1009000",
  "game://?module=1009430&tab=1"
}
local titles = {
  77512,
  77513,
  77514,
  77515
}
function Collect_JumpBase:ctor(_)
  self._nCalItemCountTimer = nil
end
function Collect_JumpBase:OnClose()
  self:_ClearCalItemCountTimer()
  Collect_JumpBase.__super.OnClose(self)
end
function Collect_JumpBase:_ClearCalItemCountTimer()
  if not self._nCalItemCountTimer then
    return
  end
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  collect_module:ClearCalSpecialItemCountTimer(self._nCalItemCountTimer)
  self._nCalItemCountTimer = nil
end
function Collect_JumpBase:Jump1(num, widget, index)
  self:ShowTips(LocUtil.LocalizeResFormat(titles[index], num), LocUtil.GetLocalizeResStr(77516), LocUtil.GetLocalizeResStr(77518), widget, index)
end
function Collect_JumpBase:Jump2(num, widget, index)
  self:ShowTips(LocUtil.LocalizeResFormat(titles[index], num), LocUtil.GetLocalizeResStr(77516), nil, widget, index)
end
function Collect_JumpBase:Jump3(num, widget, index)
  self:ShowTips(LocUtil.LocalizeResFormat(titles[index], num), LocUtil.GetLocalizeResStr(77517), LocUtil.GetLocalizeResStr(77519), widget, index)
end
function Collect_JumpBase:Jump4(num, widget, index)
  self:ShowTips(LocUtil.LocalizeResFormat(titles[index], num), "", LocUtil.GetLocalizeResStr(77520), widget, index)
end
function Collect_JumpBase:ShowTips(title, desc, jumpText, widget, index)
  local tipsParams = {
    widget = widget,
    title = title,
    content = desc,
    jumpText = jumpText,
    jumpCallback = function()
      log_warning(bWriteLog and "  Collect_JumpBase:ShowTips.  " .. tostring(index))
      GlobalData.JumpUrl(urls[index])
    end
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_Other_Tips_UIBP, tipsParams)
end
function Collect_JumpBase:ShowSpecialNum(_, _, data, other_uid)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local nUid = other_uid or 0
  if tostring(self.nUid) ~= tostring(nUid) then
    log("  Collect_JumpBase:ShowSpecialNum. selfUid ~= nUid")
    return
  end
  local TableUtil = require("common.table_util")
  local ItemMacros = require("client.slua.config.ClientMacros.ItemMacros")
  local collect_theme_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_theme_module)
  for i = ItemMacros.QUALITY_PURPLE, ItemMacros.QUALITY_GOLDEN do
    local num = TableUtil.CountTable(collect_theme_module.Quality2ItemTb[i])
    log_warning(bWriteLog and "  Collect_Road_UIBP:ShowSpecialNum. num: " .. tostring(num))
    self.UIRoot["TextBlock_Q" .. i]:SetText(tostring(num))
  end
  self._nCalItemCountTimer = collect_module:GetCalSpecialItemCountTimer(function(xSuit, golden, upgrade, tarot)
    self:_ClearCalItemCountTimer()
    if not self.UIRoot or not slua.isValid(self.UIRoot) then
      return
    end
    self:SetCountBoard(xSuit, golden, upgrade, tarot)
  end)
end
function Collect_JumpBase:SetDefaultCountBoard()
  local UIRoot = self.UIRoot
  UIRoot.TextBlock_tarot:SetText(tostring(0))
  UIRoot.TextBlock_xSuit:SetText(tostring(0))
  UIRoot.TextBlock_golden:SetText(tostring(0))
  UIRoot.TextBlock_upgrade:SetText(tostring(0))
  local ItemMacros = require("client.slua.config.ClientMacros.ItemMacros")
  for i = ItemMacros.QUALITY_PURPLE, ItemMacros.QUALITY_GOLDEN do
    UIRoot["TextBlock_Q" .. i]:SetText(tostring(0))
  end
end
function Collect_JumpBase:SetCountBoard(xSuit, golden, upgrade, tarot)
  local UIRoot = self.UIRoot
  UIRoot.TextBlock_tarot:SetText(tostring(tarot))
  UIRoot.TextBlock_xSuit:SetText(tostring(xSuit))
  UIRoot.TextBlock_golden:SetText(tostring(golden))
  UIRoot.TextBlock_upgrade:SetText(tostring(upgrade))
  local nums = {
    xSuit,
    golden,
    upgrade,
    tarot
  }
  for i = 1, 4 do
    local button = UIRoot["Button_Jump" .. i]
    if button then
      self:AddControlEventByControl(button, "OnClicked", self["Jump" .. i], self, nums[i], button, i)
    end
  end
end
function Collect_JumpBase:ShowOrHideJump()
  local UIRoot = self.UIRoot
  for i = 1, 4 do
    local button = UIRoot["Button_Jump" .. i]
    if button then
      self:SetWidgetVisible(button, true, self.bIsSelf)
    end
  end
end
local class = require("class")
local ui_base = require("GameLua.Mod.Lobby.Split.Collect.umg.CollectBase.Collect_UI_Base")
local CCollect_JumpBase = class(ui_base, nil, Collect_JumpBase)
return CCollect_JumpBase