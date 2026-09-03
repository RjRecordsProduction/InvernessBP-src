local LogicCustomAccessories = {GunAccessoriesData = false, UploadTask = 0}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local Types = {
  "Muzzles",
  "Lowers",
  "Magazines",
  "Stocks",
  "Uppers"
}
local IgnoreItems = {
  [204016] = true,
  [203201] = true,
  [203202] = true,
  [202100] = true,
  [203051] = true,
  [203052] = true,
  [203053] = true,
  [203054] = true,
  [203055] = true,
  [203056] = true,
  [203057] = true,
  [203023] = true,
  [203150] = true,
  [203151] = true,
  [201101] = true,
  [201102] = true,
  [201103] = true
}
local _local NumberString = "number"
local IsNumber = function(Value)
  return _type(Value) == NumberString
end
local Parts_default_Name = {
  4510,
  4512,
  4511,
  4513,
  100014,
  100100
}
function LogicCustomAccessories.Read()
  local FilePath = Client.ProjectSavedDir() .. "/SaveGames/GA.json"
  local FileStr = Client.LoadFileToStringByFullPath(FilePath)
  if FileStr ~= nil and FileStr ~= "" then
    local base64 = require("client.slua.logic.lobby_watermark.base64")
    FileStr = base64.dec(FileStr)
    LogicCustomAccessories.GunAccessoriesData = json.decode(FileStr)
    if not LogicCustomAccessories.GunAccessoriesData then
      LogicCustomAccessories.GunAccessoriesData = {}
      return
    end
    for Key1, Value1 in pairs(LogicCustomAccessories.GunAccessoriesData) do
      if Value1.Acce then
        for Key2, Value2 in pairs(Value1.Acce) do
          if not IsNumber(Value2) then
            Value1.Acce[Key2] = nil
          end
        end
      end
    end
    table.sort(LogicCustomAccessories.GunAccessoriesData, function(a, b)
      return (a.ID or 0) < (b.ID or 0)
    end)
  else
    LogicCustomAccessories.GunAccessoriesData = {}
  end
end
function LogicCustomAccessories.Save()
  local Str = json.encode(LogicCustomAccessories.GunAccessoriesData)
  if Str == "" then
    return
  end
  local base64 = require("client.slua.logic.lobby_watermark.base64")
  Str = base64.enc(Str)
  Client.SaveStringToFile(Str, "SaveGames/GA.json")
end
function LogicCustomAccessories.SetPlayer()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local uBackPackComp = USTExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(PlayerController)
  if uBackPackComp and slua.isValid(uBackPackComp) and LogicCustomAccessories.GunAccessoriesData then
    local UBackpackUtils = import("BackpackUtils")
    local DelayTime = 0
    local TimeTicker = require("common.time_ticker")
    if IsEditor then
      DelayTime = 5
      TimeTicker.AddTimer(0, function()
        for Index, Data in pairs(LogicCustomAccessories.GunAccessoriesData) do
          if Data.ID and Data.Acce then
            for Index, Value in pairs(Data.Acce) do
              if Value and IsNumber(Data.ID) and IsNumber(Index) and IsNumber(Value) then
                if uBackPackComp and slua.isValid(uBackPackComp) then
                  UBackpackUtils.SetCustomAccessories(uBackPackComp, Data.ID, Index - 1, Value, true)
                end
                coroutine.yield(TimeTicker.NEXT_FRAME)
              end
            end
          end
        end
      end)
    end
    TimeTicker.AddTimer(DelayTime, function()
      for Index, Data in pairs(LogicCustomAccessories.GunAccessoriesData) do
        if Data.ID and Data.Acce then
          for Index, Value in pairs(Data.Acce) do
            if Value and IsNumber(Data.ID) and IsNumber(Index) and IsNumber(Value) then
              if uBackPackComp and slua.isValid(uBackPackComp) then
                UBackpackUtils.SetCustomAccessories(uBackPackComp, Data.ID, Index - 1, Value, true)
              end
              coroutine.yield(TimeTicker.NEXT_FRAME)
            end
          end
        end
      end
    end)
  end
end
function LogicCustomAccessories.RemoveWeaponConfig(WeaponID)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  if not LogicCustomAccessories.GunAccessoriesData then
    return
  end
  local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local uBackPackComp = USTExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(PlayerController)
  if uBackPackComp and slua.isValid(uBackPackComp) and LogicCustomAccessories.GunAccessoriesData then
    local UBackpackUtils = import("BackpackUtils")
    for Index, Data in pairs(LogicCustomAccessories.GunAccessoriesData) do
      if Data.ID and Data.Acce and Data.ID == WeaponID then
        for Index, Value in pairs(Data.Acce) do
          if Value and IsNumber(Data.ID) and IsNumber(Index) and IsNumber(Value) then
            UBackpackUtils.SetCustomAccessories(uBackPackComp, Data.ID, Index - 1, Value, false)
          end
        end
        break
      end
    end
  end
end
function LogicCustomAccessories.GetWeaponTypeData(WeaponType)
  log(bWriteLog and "LogicCustomAccessories.GetWeaponTypeData WeaponType=" .. WeaponType)
  local CurWeaponTypeData = {}
  for Index, Data in pairs(LogicCustomAccessories.GunAccessoriesData) do
    local WeaponConfig = CDataTable.GetTableData("ArmoryConfig", Data.ID)
    if WeaponConfig and WeaponConfig.WeaponType == WeaponType then
      table.insert(CurWeaponTypeData, Data)
    end
  end
  return CurWeaponTypeData
end
function LogicCustomAccessories.AddWeaponAccessories(WeaponID)
  log(bWriteLog and "LogicCustomAccessories.AddWeaponAccessories WeaponID=" .. tostring(WeaponID))
  if not WeaponID then
    return false
  end
  if not LogicCustomAccessories.GunAccessoriesData then
    LogicCustomAccessories.GunAccessoriesData = {}
  end
  for _, Data in pairs(LogicCustomAccessories.GunAccessoriesData) do
    if Data.ID == WeaponID then
      log_error(bWriteLog and "LogicCustomAccessories.AddWeaponAccessories WeaponID already exists")
      return false
    end
  end
  local Data = {}
  Data.ID = WeaponID
  table.insert(LogicCustomAccessories.GunAccessoriesData, Data)
  table.sort(LogicCustomAccessories.GunAccessoriesData, function(a, b)
    return (a.ID or 0) < (b.ID or 0)
  end)
  return true
end
function LogicCustomAccessories.GetWeaponSupportAccessiories(WeaponID, IndexInItem)
  local PickUpCountSetting = CDataTable.GetTable("PickUpCountSetting")
  if not PickUpCountSetting or not PickUpCountSetting[WeaponID] then
    return
  end
  local WeaponAttCfg = CDataTable.GetTableData("WeaponAttachments", WeaponID)
  if not WeaponAttCfg then
    return
  end
  local Type = Types[IndexInItem]
  local SupportItemIDs = {}
  local ItemIDStr = WeaponAttCfg[Type .. "_a"]
  for Index = 0, ItemIDStr:Num() - 1 do
    local ItemID = tonumber(ItemIDStr:Get(Index))
    if ItemID and ItemID ~= 0 and not IgnoreItems[ItemID] then
      SupportItemIDs[#SupportItemIDs + 1] = ItemID
    end
  end
  return SupportItemIDs
end
function LogicCustomAccessories.IsIgnoreWeaponID(WeaponID)
  for IndexInItem, Type in ipairs(Types) do
    local Support = LogicCustomAccessories.GetWeaponSupportAccessiories(WeaponID, IndexInItem)
    if 0 < #Support then
      return false
    end
  end
  return true
end
function LogicCustomAccessories.GetTypes()
  return Types
end
function LogicCustomAccessories.GetAccessoriesItemByIndex(Widget, IndexInItem)
  return Widget["Seeting_GunParts_item_" .. tostring(31 + IndexInItem)]
end
function LogicCustomAccessories.GetPartSlotName(Index)
  if Index == nil then
    return ""
  end
  if Index <= #Parts_default_Name then
    return Parts_default_Name[Index]
  else
    return ""
  end
end
function LogicCustomAccessories.HasCurWeaponConfig(WeaponID)
  if not WeaponID then
    return false
  end
  log(bWriteLog and "LogicCustomAccessories.HasCurWeaponConfig WeaponID=" .. WeaponID)
  if not LogicCustomAccessories.GunAccessoriesData then
    return false
  end
  for _, Data in pairs(LogicCustomAccessories.GunAccessoriesData) do
    if Data.ID == WeaponID then
      return true
    end
  end
  return false
end
function LogicCustomAccessories.GetCurWeaponItemID(WeaponID, IndexInItem)
  if not WeaponID then
    return 0
  end
  log(bWriteLog and "LogicCustomAccessories.HasCurWeaponConfig WeaponID=" .. WeaponID)
  if not LogicCustomAccessories.GunAccessoriesData then
    return false
  end
  for _, Data in pairs(LogicCustomAccessories.GunAccessoriesData) do
    if Data.ID == WeaponID and Data.Acce then
      return Data.Acce[IndexInItem]
    end
  end
  return 0
end
function LogicCustomAccessories.UseCloudData(CloudGunAccessoriesData)
  if not CloudGunAccessoriesData then
    print(bWriteLog and "LogicCustomAccessories.UseCloudData not CloudGunAccessoriesData")
    return
  end
  local OnlyLocalWeaponIDs
  for IndexInOrigin, OriginData in pairs(LogicCustomAccessories.GunAccessoriesData) do
    local bCloudExist = false
    for IndexInCloud, CloudData in pairs(CloudGunAccessoriesData) do
      if OriginData.ID == CloudData.ID then
        bCloudExist = true
        break
      end
    end
    if not bCloudExist then
      OnlyLocalWeaponIDs = OnlyLocalWeaponIDs or {}
      table.insert(OnlyLocalWeaponIDs, OriginData.ID)
    end
  end
  if OnlyLocalWeaponIDs then
    local WeaponStr = ""
    for _, WeaponID in pairs(OnlyLocalWeaponIDs) do
      local WeaponConfig = CDataTable.GetTableData("ArmoryDescConfig", WeaponID)
      if WeaponConfig then
        WeaponStr = WeaponStr .. WeaponConfig.ArmorySimpleDesc .. " "
      end
    end
    local Msg = LocUtil.LocalizeResFormat("21145", WeaponStr)
    ShowNotice(Msg)
  end
  for IndexInCloud, CloudData in pairs(CloudGunAccessoriesData) do
    if CloudData.Acce then
      for Key, Value in pairs(CloudData.Acce) do
        if not IsNumber(Value) then
          CloudData.Acce[Key] = nil
        end
      end
    end
    local bLocalExist = false
    for IndexInOrigin, OriginData in pairs(LogicCustomAccessories.GunAccessoriesData) do
      if OriginData.ID == CloudData.ID then
        bLocalExist = true
        OriginData.Acce = CloudData.Acce
        break
      end
    end
    if not bLocalExist then
      table.insert(LogicCustomAccessories.GunAccessoriesData, CloudData)
    end
  end
  LogicCustomAccessories.Save()
end
function LogicCustomAccessories.CompareGunDataWithLocal(GunDataList)
  if not LogicCustomAccessories.GunAccessoriesData or not GunDataList then
    print(bWriteLog and "LogicCustomAccessories.CompareGunDataWithLocal local or remote not existing")
    return false
  end
  print(bWriteLog and "LogicCustomAccessories.CompareGunDataWithLocal")
  local TableUtil = require("common.table_util")
  local bSame = TableUtil.IsSameTable(LogicCustomAccessories.GunAccessoriesData, GunDataList)
  if not bSame and bWriteLog then
    log_tree("LocalData", LogicCustomAccessories.GunAccessoriesData)
    log_tree("RemoveData", GunDataList)
  end
  return bSame
end
function LogicCustomAccessories.UploadCloud()
  local TimeTicker = require("common.time_ticker")
  TimeTicker.AddTimer(0, function()
    local base64 = require("client.slua.logic.lobby_watermark.base64")
    local SettingHandler = require("client.network.Protocol.SettingHandler")
    LogicCustomAccessories.UploadTask = 10
    for WeaponType = 1, 10 do
      local LogicCustomAccessories = require("client.logic.setting.logic_setting_custom_accessiores")
      local CurWeaponTypeData = LogicCustomAccessories.GetWeaponTypeData(WeaponType)
      if CurWeaponTypeData then
        local Data = json.encode(CurWeaponTypeData)
        if Data ~= "" then
          Data = base64.enc(Data)
          SettingHandler.send_save_weapon_settings_req(Data, 2, WeaponType)
        end
      end
      coroutine.yield(0.15)
    end
  end)
end
function LogicCustomAccessories.OnUploadCloud()
  LogicCustomAccessories.UploadTask = LogicCustomAccessories.UploadTask - 1
  if LogicCustomAccessories.UploadTask == 0 then
    ShowNotice(9644)
    local TimeUtil = require("client.common.time_util")
    LogicCustomAccessories.last_save_weapon_settings_tm = TimeUtil.GetTodayStartTimestamp()
    EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_UPLOAD_SUCCESS)
  end
end
function LogicCustomAccessories.IsUploading()
  return LogicCustomAccessories.UploadTask > 1
end
return LogicCustomAccessories