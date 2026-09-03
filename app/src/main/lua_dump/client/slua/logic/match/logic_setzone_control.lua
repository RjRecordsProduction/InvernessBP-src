local logic_setzone_control = {}
function logic_setzone_control:SetDelayArea(most_used_shadow, shadow_default, only_use_shadow_ping)
  self.MostUsedShadow = most_used_shadow or ""
  self.Shadow_default = shadow_default
  self.bOnlyUseShadowSvr = only_use_shadow_ping
end
function logic_setzone_control:SetBestZone(ZoneId)
  self.BestZone = ZoneId
end
function logic_setzone_control:OnInitialize()
  logic_setzone_control.__super.OnInitialize(self)
  self.MostUsedShadow = ""
  self.Notify_Data = {}
  self.CurrentItems = {}
  self.BestZone = nil
  self.Shadow_default = {}
  self.bOnlyUseShadowSvr = false
end
function logic_setzone_control:DelayPopupDisplay(flag, notify_data)
  self.Notify_Data = notify_data
  if flag == 1 then
    for rule_id, value in pairs(notify_data) do
      if self.Notify_Data and self.Notify_Data[rule_id] then
        self.Notify_Data[rule_id] = nil
      end
    end
    self:RefreshItems()
    return
  end
  if flag == 2 then
    self:RefreshItems()
    return
  end
  if flag == 0 then
    self.Notify_Data = notify_data
    self:RefreshItems()
  end
  local IsShow = self:CheckCanShow()
  if not IsShow then
    return
  end
  local jumpInfo = {}
  function jumpInfo.callback()
    log(bWriteLog and "[PXY]Common_ServerSwitch is jumpinfo.callback")
    local SettingUtil = require("client.slua.logic.setting.setting_util")
    SettingUtil.Enter("Account")
    local ui = UIManager.ShowUI(UIManager.UI_Config.Setting_ChangeServer, nil, true)
    local timer_ticker = require("common.time_ticker")
    timer_ticker.AddTimerOnce(0.2, function()
      if ui and ui.UIRoot then
        local widget = ui.UIRoot.Panel_Zone
        if UIManager.GetUI(UIManager.UI_Config.NewbieGuide_UIBP) then
          UIManager.CloseUI(UIManager.UI_Config.NewbieGuide_UIBP)
        end
        local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
        local CurrentZoneId = ZoneSystem.nChooseZoneID
        local logic_setzone_control = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_setzone_control)
        local bestZone = logic_setzone_control:GetBestZone()
        if bestZone then
          log(bWriteLog and "[DeanJYT] logic_setzone_control:DelayPopupDisplay BestZone = ", bestZone)
          CurrentZoneId = bestZone
        end
        local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
        local ZoneName = logic_multiple_area:GetDisplayNameByZoneID(CurrentZoneId)
        local Str = LocUtil.LocalizeResFormat(46036, ZoneName)
        UIManager.ShowUI(UIManager.UI_Config.NewbieGuide_UIBP, 1, Str, widget, function()
          if UIManager.GetUI(UIManager.UI_Config.NewbieGuide_UIBP) then
            UIManager.CloseUI(UIManager.UI_Config.NewbieGuide_UIBP)
          end
        end, true, 2)
      end
    end)
  end
  local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
  local name = LocUtil.GetLocalizeResStr(46027)
  local desc = LocUtil.GetLocalizeResStr(46028)
  local ItemData = {}
  local ItemId = 0
  local number = 0
  if self.CurrentItems and next(self.CurrentItems) then
    for item_id, value in pairs(self.CurrentItems) do
      ItemData = CDataTable.GetTableData("Item", item_id)
      ItemId = item_id
    end
    number = self.CurrentItems[ItemId]
    local path = ""
    local ItemQuality = 1
    if ItemData and ItemData.ItemBigIcon then
      path = ItemData.ItemBigIcon
    end
    if ItemData and ItemData.ItemQuality then
      ItemQuality = ItemData.ItemQuality
    end
    RightPopSystem.CommonRewardPopup(name, desc, ItemId, number, jumpInfo, 10)
  end
end
function logic_setzone_control:RefreshItems()
  if self.Notify_Data and next(self.Notify_Data) then
    for rule_id, Data in pairs(self.Notify_Data) do
      if Data.display_type == 7 then
        self.CurrentItems = Data.items
      end
    end
  end
end
function logic_setzone_control:CheckCanShow()
  for key, data in pairs(self.Notify_Data) do
    if data.display_type == 7 then
      return true
    end
  end
  return false
end
function logic_setzone_control:OnLogOut()
  self:ResetData()
end
function logic_setzone_control:ResetData()
  self.MostUsedShadow = ""
  self.Notify_Data = {}
  self.CurrentItems = {}
  self.BestZone = nil
end
function logic_setzone_control:GetCurrentItems()
  return self.CurrentItems
end
function logic_setzone_control:GetMostUsedShadow()
  return self.MostUsedShadow
end
function logic_setzone_control:GetShadow_default()
  return self.Shadow_default
end
function logic_setzone_control:GetBestZone()
  return self.BestZone
end
function logic_setzone_control:CheckIsOnlyUseShadowSvr()
  return self.bOnlyUseShadowSvr
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_setzone_control = class(CModuleBase, nil, logic_setzone_control)
return Clogic_setzone_control