local CustomLayoutArchiver = {}
local TableArchiver = require("client.logic.NewSetting.TableArchiver")
local math_tointeger = math.tointeger
local CreateTableFromSaveGame = function(CustomLayoutSaveGame)
  local UIUtil = require("client.common.ui_util")
  local ViewportScale = UIUtil.GetViewportScale()
  local ViewportSize = UIUtil.GetViewportSize()
  local CustomLayoutSaveGameClass = import("CustomLayoutSaveGame")
  if not Game:IsClassOf(CustomLayoutSaveGame, CustomLayoutSaveGameClass) then
    return
  end
  local TableData = {
    sName = CustomLayoutSaveGame.SaveSlotName,
    v = CustomLayoutSaveGame.CodecVersion,
    WH = math.floor(ViewportSize.X) + math.floor(100000 * ViewportSize.Y),
    Scl = ViewportScale,
    T = CustomLayoutSaveGame:GetNewTimeTagAsString(),
    iSm = CustomLayoutSaveGame:GetLayoutCodeCheckSum(),
    tCodes = {}
  }
  for Key, Value in pairs(CustomLayoutSaveGame.LayoutCodeMap) do
    TableData.tCodes[Key] = Value
  end
  return TableData
end
CustomLayoutArchiver.local LoadSaveGameFromTable = function(Data)
  if not Data then
    return
  end
  local GameplayStatics = import("GameplayStatics")
  local CustomLayoutSaveGameClass = import("CustomLayoutSaveGame")
  local CustomLayoutSaveGame = GameplayStatics.CreateSaveGameObject(CustomLayoutSaveGameClass)
  if not slua.isValid(CustomLayoutSaveGame) then
    return
  end
  if Data.sName then
    CustomLayoutSaveGame.SaveSlotName = Data.sName
  end
  if Data.v then
    CustomLayoutSaveGame.CodecVersion = Data.v
  end
  if Data.WH then
    CustomLayoutSaveGame.ViewportWidth = Data.WH % 100000
    CustomLayoutSaveGame.ViewportHeight = Data.WH // 100000
  end
  if Data.Scl then
    CustomLayoutSaveGame.ViewportScale = Data.Scl
  end
  if Data.T then
    CustomLayoutSaveGame:SetTimeTagFromString(Data.T)
  end
  if Data.tCodes then
    for Key, Value in pairs(Data.tCodes) do
      if math_tointeger(Key) and math_tointeger(Value) then
        CustomLayoutSaveGame.LayoutCodeMap:Add(Key, Value)
      else
        log_error("LoadSaveGameFromTable non-integer founded in tCodes")
      end
    end
  end
  local CheckSumNow = CustomLayoutSaveGame:GetLayoutCodeCheckSum()
  if Data.iSm and CheckSumNow ~= Data.iSm then
    log_error("LoadSaveGameFromTable CheckSum failed")
  end
  return CustomLayoutSaveGame
end
CustomLayoutArchiver.
function CustomLayoutArchiver.SaveFile(SaveGame)
  local SlotName = SaveGame.SaveSlotName
  if not SlotName or SlotName == "" then
    return
  end
  local TableData = CreateTableFromSaveGame(SaveGame)
  return TableArchiver.SaveFile("SaveGames/CustomLayout/" .. SlotName, TableData)
end
function CustomLayoutArchiver.LoadFile(SlotName)
  local utility = require("common.utility")
  local SaveGame
  xpcall(function()
    local TableData = TableArchiver.LoadFile("SaveGames/CustomLayout/" .. SlotName)
    SaveGame = LoadSaveGameFromTable(TableData)
  end, utility.ErrorMessageHandler)
  return SaveGame
end
return CustomLayoutArchiver