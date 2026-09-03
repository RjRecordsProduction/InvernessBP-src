local WardrobeIndexSystem = {UIRoot_Common_Get = nil, is_have_decompose_item = false}
local ENUM_TabIndex = {ENUM_TabIndex_Forever = 1, ENUM_TabIndex_ValidHours = 2}
function WardrobeIndexSystem:Init()
  self.first_tab = ENUM_TabIndex.ENUM_TabIndex_ValidHours
  self.is_have_decompose_item = false
end
local DealWithPlayerPrefs = function()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local TriggerTimeStamp = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eWardrobeDecomposeTriggerTime) or 0
  log(bWriteLog and "TriggerTimeStamp " .. tostring(TriggerTimeStamp))
  if 0 <= TriggerTimeStamp then
    local TimeUtil = require("client.common.time_util")
    local gap_time = TimeUtil.GetServerTimeInSec() - TriggerTimeStamp
    log(bWriteLog and "gap_time " .. tostring(gap_time))
    if gap_time < 604800 then
      return false
    else
      return true
    end
  end
end
function WardrobeIndexSystem:JudgeIsShow()
  if not DealWithPlayerPrefs() then
    return
  end
  self:Init()
  local logic_decompose = require("client.logic.decompose.logic_decompose")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local arrayHallDepotItemInfo = wardrobe_data:GetArrayHallDepotItemInfo()
  logic_decompose.BatchCheckListDecomposeInfo(arrayHallDepotItemInfo)
end
function WardrobeIndexSystem:CheckJudgeToShowDecompose()
  log(bWriteLog and "CheckJudgeToShowDecompose")
  local depose_total_num = 0
  local logic_decompose = require("client.logic.decompose.logic_decompose")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local arrayHallDepotItemInfo = wardrobe_data:GetArrayHallDepotItemInfo()
  local maxSendIds = 0
  for i, v in pairs(arrayHallDepotItemInfo) do
    if 100 <= maxSendIds then
      break
    end
    maxSendIds = maxSendIds + 1
    local itemCfg = CDataTable.GetTableData("Item", v.resID)
    local bIsLimit = logic_decompose.CheckItemCanDecompose(v, itemCfg, true)
    local bNotLimit = logic_decompose.CheckItemCanDecompose(v, itemCfg, false)
    if (bIsLimit or bNotLimit) and logic_decompose.CanBatchDecompose(v.resID) then
      if 0 < v.validHours then
        depose_total_num = depose_total_num + v.count
        self.is_have_decompose_item = true
      elseif v.ItemType ~= 1 and v.ItemType ~= 9 and v.ItemType ~= 4 and v.itemSubType ~= 701 and 1 < v.count then
        depose_total_num = depose_total_num + v.count - 1
        self.first_tab = ENUM_TabIndex.ENUM_TabIndex_Forever
        self.is_have_decompose_item = true
      end
    end
  end
  log(bWriteLog and "WardrobeIndexSystem.first_tab " .. tostring(self.first_tab))
  log(bWriteLog and "depose_total_num : " .. tostring(depose_total_num))
  local WardrobeDecomposeTriggerNum = DataMgr.GetSystemConfig("WardrobeDecomposeTriggerNum")
  if WardrobeDecomposeTriggerNum then
    log(bWriteLog and "WardrobeDecomposeTriggerNum " .. tostring(WardrobeDecomposeTriggerNum))
    WardrobeDecomposeTriggerNum = tonumber(WardrobeDecomposeTriggerNum)
    if WardrobeDecomposeTriggerNum and depose_total_num >= WardrobeDecomposeTriggerNum then
      WardrobeIndexSystem:Show()
    end
  end
end
function WardrobeIndexSystem:GetDefault_ItemDecompose_TabIndex()
  if self.is_have_decompose_item then
    log(bWriteLog and "WardrobeIndexSystem.first_tab-1 " .. tostring(self.first_tab - 1))
    return self.first_tab - 1
  else
    return 0
  end
end
function WardrobeIndexSystem:Show()
  log(bWriteLog and " WardrobeIndexSystem:Show()")
  local title = LocUtil.GetLocalizeResStr(5077)
  local tips = LocUtil.LocalizeResFormat(6808, tostring(DataMgr.GetSystemConfig("WardrobeDecomposeTriggerNum")))
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, tips, function()
    local logic_decompose = require("client.logic.decompose.logic_decompose")
    logic_decompose.Show()
  end, nil)
  local TimeUtil = require("client.common.time_util")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(TimeUtil.GetServerTimeInSec(), PlayerPrefsSystem.ePlayerPrefsType.eWardrobeDecomposeTriggerTime)
end
return WardrobeIndexSystem