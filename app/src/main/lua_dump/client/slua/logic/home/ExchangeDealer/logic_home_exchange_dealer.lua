local logic_home_exchange_dealer = {}
function logic_home_exchange_dealer:DefineAndResetData()
  log(bWriteLog and "[DeanJYT] logic_home_exchange_dealer:DefineAndResetData")
  self.bShouldShowEntry = false
  self.bShouldReqForLatestBag = true
  self.dealData = nil
end
function logic_home_exchange_dealer:RegistEvents()
  logic_home_exchange_dealer.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_SET_MODE, self.OnManorSetMode, self)
end
function logic_home_exchange_dealer:OnInitialize()
  log(bWriteLog and "[DeanJYT] logic_home_exchange_dealer:OnInitialize")
  self:ReqExchangeBoxDealDetail()
end
function logic_home_exchange_dealer:OnLogin()
  log(bWriteLog and "[DeanJYT] logic_home_exchange_dealer:OnLogin")
  self:ReqExchangeBoxDealDetail()
end
function logic_home_exchange_dealer:OnPostSwitchGameStatus(_, next)
  log(bWriteLog and "[DeanJYT] logic_home_exchange_dealer:OnPostSwitchGameStatus next = " .. tostring(next))
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if next == GameStatus.Fighting and PlanPH_GamePlay_Tools.IsPHomeMode() then
    self.bShouldReqForLatestBag = true
    log(bWriteLog and "[DeanJYT] logic_home_exchange_dealer:OnPostSwitchGameStatus should req for data")
    self:ReqExchangeDealerEntryData()
    self:ReqBagLatestData()
  end
end
function logic_home_exchange_dealer:OnManorSetMode()
  self.bShouldReqForLatestBag = true
end
function logic_home_exchange_dealer:ComputeEntryStatus()
  print(bWriteLog and "[DeanJYT] logic_home_exchange_dealer:ComputeEntryStatus")
  if not self.entryInfo then
    print(bWriteLog and "[DeanJYT] logic_home_exchange_dealer:ComputeEntryStatus self.entryInfo is nil")
    return
  end
  if not self.dealData then
    print(bWriteLog and "[DeanJYT] logic_home_exchange_dealer:ComputeEntryStatus self.dealData is nil")
    return
  end
  if not self.dropData then
    print(bWriteLog and "[DeanJYT] logic_home_exchange_dealer:ComputeEntryStatus self.dropData is nil")
    return
  end
  self.bShouldShowEntry = true
  local entryCloseTime = self.entryInfo.mystery_man_expire_time
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  if entryCloseTime < curTime then
    self.bShouldShowEntry = false
  end
  local TimeUtil = require("client.common.time_util")
  local version_util = require("client.common.version_util")
  local clientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  local time = TimeUtil.GetServerTimeInSec()
  local bAllExchanged = true
  for id, v in pairs(self.dealData) do
    if version_util.CompareVersionStandard(clientVersion, v.min_ver) >= 0 and time >= TimeUtil.TimeStringToUnixstamp(v.begin_time) and time <= TimeUtil.TimeStringToUnixstamp(v.end_time) and not self.entryInfo.exchanged_boxs[id] and self.entryInfo.mystery_man_id == v.mystery_man_id then
      bAllExchanged = false
      break
    end
  end
  if bAllExchanged then
    self.bShouldShowEntry = false
  end
  EventSystem:postEvent(EVENTTYPE_PLANPH_NORMAL, EVENTID_PLANPH_GET_SPECIAL_DEAL_ENTRY, self.bShouldShowEntry, entryCloseTime)
end
function logic_home_exchange_dealer:GetEntryCloseTime()
  if not self.entryInfo then
    return 0
  end
  return self.entryInfo.mystery_man_expire_time or 0
end
function logic_home_exchange_dealer:CheckBoxExchanged(boxID)
  local bExchanged = self.entryInfo.exchanged_boxs[boxID] or false
  return bExchanged
end
function logic_home_exchange_dealer:ReqExchangeDealerEntryData()
  print(bWriteLog and "[DeanJYT] logic_home_exchange_dealer:ReqHomePartyGiftCfg")
  local PHomeExchangeDealerHandler = require("client.network.Protocol.PHomeExchangeDealerHandler")
  PHomeExchangeDealerHandler.send_manor_mystery_man_info_req()
end
function logic_home_exchange_dealer:SaveExchangeDealerEntryData(info)
  print(bWriteLog and "[DeanJYT] logic_home_exchange_dealer:SaveExchangeDealerEntryData")
  self.entryInfo = info
  self:ComputeEntryStatus()
end
function logic_home_exchange_dealer:ReqExchangeBoxDealDetail()
  print(bWriteLog and "[DeanJYT] logic_home_exchange_dealer:ReqExchangeBoxDealDetail")
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.manor_mystery_man_table, function(_, data)
    self.dealData = data
  end)
  BasicDataServerTable:GetOrReqData(data_config_marco.manor_mystery_man_drop_table, function(_, data)
    self.dropData = data
  end)
end
function logic_home_exchange_dealer:ReqExchangeForDeal(dealID, useItemList)
  log_tree("[DeanJYT] logic_home_exchange_dealer:ReqExchangeForDeal dealID = " .. tostring(dealID) .. ", useItemList = ", useItemList)
  local encoded = slua.LuaArchiverEncode(LuaStateWrapper, useItemList)
  local PHomeExchangeDealerHandler = require("client.network.Protocol.PHomeExchangeDealerHandler")
  PHomeExchangeDealerHandler.send_manor_mystery_man_exchange_req(dealID, encoded)
end
function logic_home_exchange_dealer:OnExchangeForDeal(dealID, rewardList, refundList)
  local showList = {}
  for k, v in pairs(rewardList) do
    showList[#showList + 1] = {res_id = k, count = v}
  end
  for k, v in pairs(refundList) do
    showList[#showList + 1] = {res_id = k, count = v}
    if 0 < v then
      ShowNotice(LocUtil.LocalizeResFormat(770013, v))
    end
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(showList)
  self.entryInfo.exchanged_boxs[dealID] = true
  self:ComputeEntryStatus()
  EventSystem:postEvent(EVENTTYPE_PLANPH_NORMAL, EVENTID_PLANPH_SPECIAL_DEAL_SUCCEED, dealID)
end
function logic_home_exchange_dealer:GetIsActivityData()
  local IsActivity = false
  if self.entryInfo == nil then
    log(bWriteLog and "logic_home_exchange_dealer:GetIsActivityData no entry info")
    return false
  end
  if type(self.dealData) ~= "table" or next(self.dealData) == nil then
    log(bWriteLog and "logic_home_exchange_dealer:GetIsActivityData no deal data")
    return false
  end
  for id, v in pairs(self.dealData) do
    if self.entryInfo.mystery_man_id == v.mystery_man_id and v.is_activity == 1 then
      IsActivity = true
      break
    end
  end
  return IsActivity
end
function logic_home_exchange_dealer:GetDetailedBoxDropData(boxID)
  print(bWriteLog and "[DeanJYT] logic_home_exchange_dealer:GetDetailedBoxDropData boxID = " .. tostring(boxID))
  local boxData = self.dealData[boxID]
  if not boxData then
    print(bWriteLog and "[DeanJYT] logic_home_exchange_dealer:GetDetailedBoxDropData boxData missing")
    return
  end
  local dropData = self.dropData[boxData.mystery_pool_id]
  if not dropData then
    print(bWriteLog and "[DeanJYT] logic_home_exchange_dealer:GetDetailedBoxDropData dropData missing")
    return
  end
  return dropData
end
function logic_home_exchange_dealer:GetDetailedBoxInfo(boxID)
  print(bWriteLog and "[DeanJYT] logic_home_exchange_dealer:GetDetailedBoxInfo boxID = " .. tostring(boxID))
  local boxData = self.dealData[boxID]
  if not boxData then
    print(bWriteLog and "[DeanJYT] logic_home_exchange_dealer:GetDetailedBoxInfo boxData missing")
    return
  end
  local StringUtil = require("common.string_util")
  local refundArr = StringUtil.SplitToNum(boxData.refund_num, ":")
  local detailData = {
    prosperityNeed = boxData.prosperity_need,
    refundType = refundArr[1],
    refundCount = refundArr[2]
  }
  return detailData
end
function logic_home_exchange_dealer:ReqBagLatestData()
  print(bWriteLog and "[DeanJYT] logic_home_exchange_dealer:ReqBagLatestData")
  if not self.bShouldReqForLatestBag then
    print(bWriteLog and "[DeanJYT] logic_home_exchange_dealer:ReqBagLatestData flag not true, do not need to req for latest")
    return
  end
  local uid = DataMgr.roleData.uid
  local PHomeDetailHandler = require("client.network.Protocol.PHomeDetailHandler")
  PHomeDetailHandler.send_manor_use_item_detail_req(uid)
  PHomeDetailHandler.send_manor_draft_use_item_detail_req()
  self.bShouldReqForLatestBag = false
end
function logic_home_exchange_dealer:GetBoxItemDropRate(boxID)
  local dropData = self:GetDetailedBoxDropData(boxID)
  local totalWeight = 0
  for _, v in pairs(dropData) do
    totalWeight = totalWeight + v.weight
  end
  if totalWeight == 0 then
    return {}
  end
  local rateTable = {}
  for _, v in pairs(dropData) do
    local rate = v.weight / totalWeight
    local itemCfg = CDataTable.GetTableData("Item", v.item_id)
    local qualityRate = rateTable[itemCfg.ItemQuality] or 0
    qualityRate = qualityRate + rate
    rateTable[itemCfg.ItemQuality] = qualityRate
  end
  return rateTable
end
function logic_home_exchange_dealer:EnterExchangeDeal()
  UIManager.ShowUI(UIManager.UI_Config_InGame.PlanPH_Prize_Pool_UIBP)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, logic_home_exchange_dealer)
return CModuleTemplate