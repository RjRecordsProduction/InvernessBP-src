local SettingCloudHelper = {
  SingleRspDelegate = false,
  RequestTimeout = 3,
  RequestTimeoutHandle = false
}
function SettingCloudHelper.RequestCloudData(ReqFunc, RspFunc)
  print(bWriteLog and "SettingCloudHelper.RequestCloudData")
  if SettingCloudHelper.SingleRspDelegate then
    log_error("SettingCloudHelper.RequestCloudData Already Execute Once before Response")
    return false
  else
    ReqFunc()
    SettingCloudHelper.SingleRspDelegate = RspFunc
    local time_ticker = require("common.time_ticker")
    SettingCloudHelper.RequestTimeoutHandle = time_ticker.AddTimerOnce(SettingCloudHelper.RequestTimeout, function(...)
      SettingCloudHelper.SingleRspDelegate = false
      SettingCloudHelper.RequestTimeoutHandle = false
    end)
    return true
  end
end
function SettingCloudHelper.OnReceiveCloudData(CloudData)
  print(bWriteLog and "SettingCloudHelper.OnReceiveCloudData")
  log_tree("CloudData", CloudData)
  if SettingCloudHelper.RequestTimeoutHandle then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(SettingCloudHelper.RequestTimeoutHandle)
    SettingCloudHelper.RequestTimeoutHandle = false
  end
  if SettingCloudHelper.SingleRspDelegate then
    SettingCloudHelper.SingleRspDelegate(CloudData)
    SettingCloudHelper.SingleRspDelegate = false
  end
end
function SettingCloudHelper.RequestGlobalSensCloudData(Delegate)
  SettingCloudHelper.RequestCloudData(function()
    local SettingHandler = require("client.network.Protocol.SettingHandler")
    SettingHandler.send_query_custom_sensitive()
  end, Delegate)
end
function SettingCloudHelper.RequestWeaponSensCloudData(Delegate)
  SettingCloudHelper.RequestCloudData(function()
    local SettingHandler = require("client.network.Protocol.SettingHandler")
    SettingHandler.send_query_weapon_settings_req(1)
  end, Delegate)
end
function SettingCloudHelper.RequestWeaponAttachmentCloudData(Delegate)
  SettingCloudHelper.RequestCloudData(function()
    local SettingHandler = require("client.network.Protocol.SettingHandler")
    SettingHandler.send_query_weapon_settings_req(2)
  end, Delegate)
end
function SettingCloudHelper.PreprocessGunData(InData)
  if InData then
    local base64 = require("client.slua.logic.lobby_watermark.base64")
    local GunDataList = {}
    for WeaponType = 1, 10 do
      if InData[WeaponType] and InData[WeaponType] ~= "" then
        local FileStr = base64.dec(InData[WeaponType])
        local CurWeaponTypeData = json.decode(FileStr)
        print(bWriteLog and "LogGunSens Dnload", WeaponType, #CurWeaponTypeData, #InData[WeaponType])
        for Key, Value in pairs(CurWeaponTypeData) do
          table.insert(GunDataList, Value)
        end
      end
    end
    if not next(GunDataList) then
      return nil
    end
    table.sort(GunDataList, function(a, b)
      return (a.ID or 0) < (b.ID or 0)
    end)
    return GunDataList
  end
end
return SettingCloudHelper