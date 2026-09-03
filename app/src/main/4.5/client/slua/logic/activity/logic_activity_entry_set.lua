local ActivityEntrySetSystem = {data = nil, bHaveData = false}
function ActivityEntrySetSystem.ClearData()
  ActivityEntrySetSystem.data = nil
  ActivityEntrySetSystem.bHaveData = false
end
function ActivityEntrySetSystem.GetData()
  if ActivityEntrySetSystem.bHaveData then
    for index = 1, #ActivityEntrySetSystem.data do
      if not ActivityEntrySetSystem.data[index].data.isShopTip then
        local jumpUrl = ActivityEntrySetSystem.data[index].data.JumpUrl
        local isTip = ActivityEntrySetSystem.GetTurntableModule(jumpUrl)
        ActivityEntrySetSystem.data[index].data.isShopTip = isTip
      end
    end
    return ActivityEntrySetSystem.data
  end
  local actData = LobbySystem.activityDisplayDataList
  if not actData then
    ActivityEntrySetSystem.bHaveData = false
    ActivityEntrySetSystem.data = nil
    return nil
  end
  local list = {}
  for i, v in ipairs(actData) do
    if v.ShowSceneID == ActivitySceneID.EntrySet and v.EntryImagePath ~= "" and ActivityEntrySetSystem.IsDisplayToSetTime(v) then
      v.isShopTip = ActivityEntrySetSystem.GetTurntableModule(v.JumpUrl)
      table.insert(list, {type = "act", data = v})
    end
  end
  if 0 < #list then
    if 1 < #list then
      table.sort(list, function(a, b)
        if a.data.Priority and b.data.Priority and a.data.Priority ~= b.data.Priority then
          return a.data.Priority < b.data.Priority
        else
          return a.data.StartTimeUTC > b.data.StartTimeUTC
        end
      end)
    end
    local entryConfig = require("client.slua.logic.activity.activity_entry_set_config")
    table.sort(entryConfig, function(a, b)
      return a.sort < b.sort
    end)
    for i, v in ipairs(entryConfig) do
      table.insert(list, {type = "local", data = v})
    end
    ActivityEntrySetSystem.bHaveData = true
    ActivityEntrySetSystem.data = list
    return list
  end
  ActivityEntrySetSystem.bHaveData = false
  ActivityEntrySetSystem.data = nil
  return nil
end
function ActivityEntrySetSystem.IsDisplayToSetTime(data)
  local TimeUtil = require("client.common.time_util")
  if not (data and data.BackupParam1) or data.BackupParam1 == "" then
    return false
  end
  local uctTime = data.BackupParam1
  local disTime = TimeUtil.TimeStringToUnixstamp(uctTime)
  local now = TimeUtil.GetServerTimeInSec()
  if disTime and disTime <= now then
    return true
  end
  return false
end
function ActivityEntrySetSystem.GetTurntableModule(jumpUrl)
  local StringUtil = require("common.string_util")
  local params = StringUtil.ParseURLParams(tostring(jumpUrl))
  local module = params.module
  if BP_ENUM_MODULE_LUCKY_BACK == tonumber(module) and module then
    local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
    local isshowtip = false
    isshowtip = CouponSystem.IsHaveCouldUseCoupon(CouponSystem._Enum_Scene._LuckySpin, 540)
    if isshowtip then
      return true
    end
    isshowtip = CouponSystem.IsHaveCouldUseCoupon(CouponSystem._Enum_Scene._LuckySpin, 60)
    if isshowtip then
      return true
    end
    CouponSystem = nil
    isshowtip = nil
  end
  return false
end
function ActivityEntrySetSystem.GetActivitySubData()
  local data = ActivityEntrySetSystem.GetData()
  if not data then
    return nil
  end
  local GetRedDotNumFunc = function()
    if not ActivityEntrySetSystem.data then
      return 0
    end
    local redNum = 0
    for i, v in ipairs(ActivityEntrySetSystem.data) do
      if v.type == "act" and v.data.IsNew then
        redNum = redNum + 1
      end
    end
    return redNum
  end
  return {
    nActID = ActivityFixedID.ENTRY_SET,
    sName = LocUtil.LocalizeResFormat("9119"),
    nRedDotNum = GetRedDotNumFunc,
    bRedDot = false,
    sBgUrl = "",
    nStartTime = 0
  }
end
return ActivityEntrySetSystem