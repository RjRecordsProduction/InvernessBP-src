local logic_activity_recharge_mgr = {}
function logic_activity_recharge_mgr:DefineAndResetData()
  self.activityBlackList = {}
  self.tabId2ActId = {}
  self.actId2TabId = {}
  self.isGMTest = false
  self.bGetBlackActListReq = false
end
function logic_activity_recharge_mgr:OnLogOut()
  self:DefineAndResetData()
end
function logic_activity_recharge_mgr:RegistEvents()
end
function logic_activity_recharge_mgr:GetActivityBlackList()
  return self.activityBlackList
end
function logic_activity_recharge_mgr:SetActivityBlackList(list)
  if not GlobalData.IsJapanOrKorea() then
    return
  end
  if self.isGMTest then
    local blackList = {
      act_id_list = {
        [130040101] = true,
        [130040102] = true,
        [130116001] = true
      }
    }
    self.activityBlackList = blackList
  else
    self.bGetBlackActListReq = true
    self.activityBlackList = list or {}
  end
end
function logic_activity_recharge_mgr:ShowActivityBlackListTips()
  local title = LocUtil.GetLocalizeResStr(34696)
  local msg = LocUtil.GetLocalizeResStr(65345)
  local callback = function()
    local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
    BasicDataTLogReport:ReportImmediate(TLogEventDefine.LobbySettingHelp, 0)
    local SettingSystem = require("client.logic.setting.logic_setting")
    local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
    SettingSystem.OpenService(LogicCustomerService.E_EntranceType.Events)
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(3, title, msg, callback)
end
function logic_activity_recharge_mgr:IsInActivityBlackList(actId, bShowTip)
  if not GlobalData.IsJapanOrKorea() then
    return false
  end
  if not actId then
    return false
  end
  local blackList = self:GetActivityBlackList()
  log_tree("blackList", blackList)
  if blackList and blackList.act_id_list and blackList.act_id_list[actId] then
    if bShowTip then
      self:ShowActivityBlackListTips()
    end
    return true
  end
  return false
end
function logic_activity_recharge_mgr:IsInActivityBlackListByTabId(tabId, bShowTip)
  if not GlobalData.IsJapanOrKorea() then
    return false
  end
  if self:IsInActivityBlackList(tabId, true) then
    return true
  end
  local cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  if tabId ~= cfg.CONSUME_UC then
    return false
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actData = ActivityNewSystem.GetActivityByTypeAndLabel(ActivityType.CONSUME_UC, ActivitySwitchType.SpecialOffer)
  if not actData then
    if bShowTip then
      self:ShowActivityBlackListTips()
    end
    return true
  end
  if self.tabId2ActId[tabId] then
    return self:IsInActivityBlackList(self.tabId2ActId[tabId], bShowTip)
  end
  self:SetActId(cfg.CONSUME_UC, actData)
  if self.tabId2ActId[tabId] then
    return self:IsInActivityBlackList(self.tabId2ActId[tabId], bShowTip)
  end
  return false
end
function logic_activity_recharge_mgr:SetActId(tabId, actData)
  if actData then
    self.tabId2ActId[tabId] = tonumber(actData.ID)
    self.actId2TabId[tonumber(actData.ID)] = tabId
  end
end
function logic_activity_recharge_mgr:send_get_refund_black_act_list_req()
  if not GlobalData.IsJapanOrKorea() then
    return
  end
  if self.activityBlackList and next(self.activityBlackList) then
    return
  end
  if self.bGetBlackActListReq then
    return
  end
  self.bGetBlackActListReq = true
  local ActivityHandler = require("client.network.Protocol.ActivityHandler")
  ActivityHandler.send_get_refund_black_act_list_req()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_activity_recharge_mgr = class(CModuleBase, nil, logic_activity_recharge_mgr)
return Clogic_activity_recharge_mgr