local CustomLayoutArchiver = {}
local TableArchiver = require("client.logic.NewSetting.TableArchiver")
local math_tointeger = math.tointeger
local TimeUtil = require("client.common.time_util")
local SCALE_MULTIPLIER = 10000
local SCALE_SHIFT = 32
local SCALE_MASK = 65535
local EncodeViewportData = function(ViewportSize, ViewportScale)
  local x = math.floor(ViewportSize.X) & 65535
  local y = math.floor(ViewportSize.Y) & 65535
  local scale_fixed = math.floor(ViewportScale * SCALE_MULTIPLIER + 0.5) & SCALE_MASK
  return x | y << 16 | scale_fixed << SCALE_SHIFT
end
local DecodeViewportData = function(ViewportData)
  local x = ViewportData & 65535
  local y = ViewportData >> 16 & 65535
  local scale_fixed = ViewportData >> SCALE_SHIFT & SCALE_MASK
  local scale = scale_fixed / SCALE_MULTIPLIER
  return x, y, scale
end
local CreateTableFromSaveGame = function(CustomLayoutUserSetting)
  local UIUtil = require("client.common.ui_util")
  local ViewportScale = UIUtil.GetViewportScale()
  local ViewportSize = UIUtil.GetViewportSize()
  local ViewportData = EncodeViewportData(ViewportSize, ViewportScale)
  local CustomLayoutUserSettingClass = import("CustomLayoutUserSetting")
  if not Game:IsClassOf(CustomLayoutUserSetting, CustomLayoutUserSettingClass) then
    return
  end
  local TableData = {
    VwP = ViewportData,
    t = CustomLayoutUserSetting:GetTimeTagAsUnixTimestamp(),
    iSm = CustomLayoutUserSetting:GetLayoutCodeCheckSum(),
    tCodes = {}
  }
  for Key, Value in pairs(CustomLayoutUserSetting.LayoutCodeMap) do
    TableData.tCodes[Key] = Value
  end
  return TableData, CustomLayoutUserSetting.SaveSlotName
end
CustomLayoutArchiver.local LoadSaveGameFromTable = function(TableData, SlotName)
  if not TableData then
    return
  end
  local GameplayStatics = import("GameplayStatics")
  local CustomLayoutUserSettingClass = import("CustomLayoutUserSetting")
  local CustomLayoutUserSetting = GameplayStatics.CreateSaveGameObject(CustomLayoutUserSettingClass)
  if not slua.isValid(CustomLayoutUserSetting) then
    return
  end
  CustomLayoutUserSetting.Save  if TableData.VwP then
    local x, y, scale = DecodeViewportData(TableData.VwP)
    CustomLayoutUserSetting.ViewportWidth = x
    CustomLayoutUserSetting.ViewportHeight = y
    CustomLayoutUserSetting.ViewportScale = scale
  else
    if TableData.WH then
      CustomLayoutUserSetting.ViewportWidth = TableData.WH % 100000
      CustomLayoutUserSetting.ViewportHeight = TableData.WH // 100000
    end
    if TableData.Scl then
      CustomLayoutUserSetting.ViewportScale = TableData.Scl
    end
  end
  if TableData.t then
    CustomLayoutUserSetting:SetTimeTagFromUnixTimestamp(TableData.t)
  end
  if TableData.tCodes then
    for Key, Value in pairs(TableData.tCodes) do
      if math_tointeger(Key) and math_tointeger(Value) then
        CustomLayoutUserSetting.LayoutCodeMap:Add(Key, Value)
      else
        log_error("LoadSaveGameFromTable non-integer founded in tCodes")
      end
    end
  end
  local CheckSumNow = CustomLayoutUserSetting:GetLayoutCodeCheckSum()
  if TableData.iSm and CheckSumNow ~= TableData.iSm then
    log_error("LoadSaveGameFromTable CheckSum failed")
  end
  return CustomLayoutUserSetting
end
CustomLayoutArchiver.
function CustomLayoutArchiver.SaveFile(SaveGame)
  local TableData, SlotName = CreateTableFromSaveGame(SaveGame)
  if not SlotName or SlotName == "" then
    log_error("CustomLayoutArchiver.SaveFile invalid SlotName")
    return
  end
  print(bWriteLog and string.format("CustomLayoutArchiver.SaveFile %s", SlotName))
  return TableArchiver.SaveFile("SaveGames/CustomLayout/" .. SlotName, TableData)
end
function CustomLayoutArchiver.LoadFile(SlotName)
  local utility = require("common.utility")
  local SaveGame
  xpcall(function()
    local TableData = TableArchiver.LoadFile("SaveGames/CustomLayout/" .. SlotName)
    SaveGame = LoadSaveGameFromTable(TableData, SlotName)
  end, utility.ErrorMessageHandler)
  print(bWriteLog and string.format("CustomLayoutArchiver.LoadFile %s result=%s", SlotName, tostring(SaveGame and true or false)))
  return SaveGame
end
return CustomLayoutArchiver