local SavEncodeSystem = {
  EncodeType = {
    RealBytes = 1,
    FlippedBytes = 2,
    DoubledBytes = 3,
    HEX = 4
  },
  PreferredEncodeType = 1,
  TryAgainCount = 3
}
local string_sub = string.sub
local string_char = string.char
local string_byte = string.byte
local table_insert = table.insert
local table_concat = table.concat
local local _ValidateSaveFile = function(filePath)
  local ScriptHelperClient = import("ScriptHelperClient")
  local content = ScriptHelperClient.LoadFileToArrayByFullPath(filePath)
  if not content or #content < 4 then
    return true, "File too small"
  end
  local magic = string_sub(content, 1, 4)
  if magic ~= "GVAS" then
    return false, "Invalid file format (not an Unreal save file)"
  end
  if #content < 20 then
    return false, "File appears truncated"
  end
  local expectedEnd = "None" .. string_char(0, 0, 0, 0, 0)
  local actualEnd = string_sub(content, -9)
  if actualEnd == expectedEnd then
    return true
  end
  local terminator = "None"
  local lastText = ""
  local foundTerminator = false
  local searchStart = #content - 16
  for i = #content, searchStart, -1 do
    local char = string_sub(content, i, i)
    local byte = string_byte(char)
    if 65 <= byte and byte <= 90 or 97 <= byte and byte <= 122 or 48 <= byte and byte <= 57 then
      lastText = char .. lastText
    elseif 0 < #lastText then
      if lastText == terminator then
        foundTerminator = true
      end
      break
    end
  end
  if not foundTerminator then
    return false, "Valid terminator not found"
  end
  return true
end
function SavEncodeSystem.ValidateSaveFile(SlotName)
  local ValidateEnable = HDmpveRemote.HDmpveRemoteConfigGetInt("ValidateSaveFileEnable", 1)
  if ValidateEnable == 0 then
    return true
  end
  local result, filepath, error
  local time = slua.getMiliseconds()
  if SlotName then
    filepath = Client.ProjectSavedDir() .. "SaveGames/" .. SlotName .. ".sav"
    if not Client.IsFileExistByFileName("SaveGames/" .. SlotName .. ".sav") then
      result = false
      error = SlotName .. " File Not Exist"
    end
  else
    result = false
    error = "no SlotName"
  end
  if filepath and not error then
    result, error = _ValidateSaveFile(filepath)
  end
  time = slua.getMiliseconds() - time
  print(bWriteLog and string.format("SavEncodeSystem.ValidateSaveFile %s time cost:%dms", error or "pass", math.floor(time)))
  return result
end
local two_hex_permutation = {
  "00",
  "01",
  "02",
  "03",
  "04",
  "05",
  "06",
  "07",
  "08",
  "09",
  "0A",
  "0B",
  "0C",
  "0D",
  "0E",
  "0F",
  "10",
  "11",
  "12",
  "13",
  "14",
  "15",
  "16",
  "17",
  "18",
  "19",
  "1A",
  "1B",
  "1C",
  "1D",
  "1E",
  "1F",
  "20",
  "21",
  "22",
  "23",
  "24",
  "25",
  "26",
  "27",
  "28",
  "29",
  "2A",
  "2B",
  "2C",
  "2D",
  "2E",
  "2F",
  "30",
  "31",
  "32",
  "33",
  "34",
  "35",
  "36",
  "37",
  "38",
  "39",
  "3A",
  "3B",
  "3C",
  "3D",
  "3E",
  "3F",
  "40",
  "41",
  "42",
  "43",
  "44",
  "45",
  "46",
  "47",
  "48",
  "49",
  "4A",
  "4B",
  "4C",
  "4D",
  "4E",
  "4F",
  "50",
  "51",
  "52",
  "53",
  "54",
  "55",
  "56",
  "57",
  "58",
  "59",
  "5A",
  "5B",
  "5C",
  "5D",
  "5E",
  "5F",
  "60",
  "61",
  "62",
  "63",
  "64",
  "65",
  "66",
  "67",
  "68",
  "69",
  "6A",
  "6B",
  "6C",
  "6D",
  "6E",
  "6F",
  "70",
  "71",
  "72",
  "73",
  "74",
  "75",
  "76",
  "77",
  "78",
  "79",
  "7A",
  "7B",
  "7C",
  "7D",
  "7E",
  "7F",
  "80",
  "81",
  "82",
  "83",
  "84",
  "85",
  "86",
  "87",
  "88",
  "89",
  "8A",
  "8B",
  "8C",
  "8D",
  "8E",
  "8F",
  "90",
  "91",
  "92",
  "93",
  "94",
  "95",
  "96",
  "97",
  "98",
  "99",
  "9A",
  "9B",
  "9C",
  "9D",
  "9E",
  "9F",
  "A0",
  "A1",
  "A2",
  "A3",
  "A4",
  "A5",
  "A6",
  "A7",
  "A8",
  "A9",
  "AA",
  "AB",
  "AC",
  "AD",
  "AE",
  "AF",
  "B0",
  "B1",
  "B2",
  "B3",
  "B4",
  "B5",
  "B6",
  "B7",
  "B8",
  "B9",
  "BA",
  "BB",
  "BC",
  "BD",
  "BE",
  "BF",
  "C0",
  "C1",
  "C2",
  "C3",
  "C4",
  "C5",
  "C6",
  "C7",
  "C8",
  "C9",
  "CA",
  "CB",
  "CC",
  "CD",
  "CE",
  "CF",
  "D0",
  "D1",
  "D2",
  "D3",
  "D4",
  "D5",
  "D6",
  "D7",
  "D8",
  "D9",
  "DA",
  "DB",
  "DC",
  "DD",
  "DE",
  "DF",
  "E0",
  "E1",
  "E2",
  "E3",
  "E4",
  "E5",
  "E6",
  "E7",
  "E8",
  "E9",
  "EA",
  "EB",
  "EC",
  "ED",
  "EE",
  "EF",
  "F0",
  "F1",
  "F2",
  "F3",
  "F4",
  "F5",
  "F6",
  "F7",
  "F8",
  "F9",
  "FA",
  "FB",
  "FC",
  "FD",
  "FE",
  "FF"
}
local hex2byte_map = {}
local byte2hex_map = {}
local gen_hex_byte_maps = function()
  for i = 1, 256 do
    local two_hex = two_hex_permutation[i]
    local low = tonumber(string_sub(two_hex, 1, 1), 16)
    local high = tonumber(string_sub(two_hex, 2, 2), 16)
    local byte = high << 4 | low
    hex2byte_map[two_hex] = string_char(byte)
    byte2hex_map[string_char(byte)] = two_hex
  end
end
gen_hex_byte_maps()
local verify_hex_string = function(hexStr)
  if #hexStr % 2 ~= 0 then
    log_error("encode_hex_string failed! data len is odd! len = %s", #hexStr)
    return false
  end
  local two_hex
  local len = #hexStr
  for i = 1, len, 2 do
    two_hex = string_sub(hexStr, i, i + 1)
    if not hex2byte_map[two_hex] then
      log_error("encode_hex_string failed! hexStr[%s-%s] not in hex2byte_map, two_hex_char = %s", i, i + 1, two_hex)
      return false
    end
  end
  return true
end
local encode_hex_string = function(hexStr)
  local bytes = {}
  if #hexStr % 2 ~= 0 then
    log_error("encode_hex_string failed! data len is odd! len = %s", #hexStr)
    return false, nil
  end
  local two_hex
  local len = #hexStr
  for i = 1, len, 2 do
    two_hex = string_sub(hexStr, i, i + 1)
    if not hex2byte_map[two_hex] then
      log_error("encode_hex_string failed! hexStr[%s-%s] not in hex2byte_map, two_hex_char = %s", i, i + 1, two_hex)
      return false, nil
    end
    table_insert(bytes, hex2byte_map[two_hex])
  end
  return true, table_concat(bytes)
end
local decode_hex_string = function(encodedStr)
  local hexStr = {}
  local startIdx = 1
  local cur_byte_char = ""
  local len = #encodedStr
  for i = startIdx, len do
    cur_byte_char = string_sub(encodedStr, i, i)
    if not byte2hex_map[cur_byte_char] then
      log_error("decode_hex_string failed! encodedStr[%s] not in byte2hex_map, byte value = %s", i, string_byte(cur_byte_char))
      return false, nil
    end
    table_insert(hexStr, byte2hex_map[cur_byte_char])
  end
  return true, table_concat(hexStr)
end
local LoadFile_RealBytes = function(FileName)
  local ScriptHelperClient = import("ScriptHelperClient")
  local SavFileData = ScriptHelperClient.LoadSavFileAsByteArray(FileName)
  if SavFileData.UnCompressedSize == 0 then
    return false
  end
  local Config = {
    CompressedData = SavFileData.ByteArray,
    CompressedSize = SavFileData.CompressedSize,
    UnCompressedFileSize = SavFileData.UncompressedSize
  }
  return true, Config
end
local SaveFile_RealBytes = function(FileName, Config)
  local ScriptHelperClient = import("ScriptHelperClient")
  return ScriptHelperClient.SaveSavFileByByteArray(FileName, Config.CompressedSize, Config.UnCompressedFileSize, Config.CompressedData)
end
local VerifySavFile_RealBytes = function(Config)
  local ScriptHelperClient = import("ScriptHelperClient")
  return ScriptHelperClient.VerifySavFileData(Config.CompressedSize, Config.UnCompressedFileSize, Config.CompressedData, 2)
end
local LoadFile_FlippedBytes = function(FileName)
  local config = Client.LoadSavFile(FileName, true)
  if not config then
    return false
  end
  local bSuccessful, encodedStr = encode_hex_string(config.CompressedData)
  if not bSuccessful then
    return false
  end
  config.CompressedData = encodedStr
  return true, config
end
local SaveFile_FlippedBytes = function(FileName, Config)
  local encodedStr = Config.CompressedData
  local bSuccessful, hexStr = decode_hex_string(encodedStr)
  if not bSuccessful then
    return false
  end
  return Client.SaveSavFile(hexStr, FileName, Config.CompressedSize, Config.UnCompressedFileSize, true)
end
local VerifySavFile_FlippedBytes = function(Config)
  local encodedStr = Config.CompressedData
  local bSuccessful, hexStr = decode_hex_string(encodedStr)
  if not bSuccessful then
    return false
  end
  return Client.IsSavFileData(hexStr, Config.CompressedSize, Config.UnCompressedFileSize, 2, true)
end
local LoadFile_DoubledBytes = function(FileName)
  local config = Client.LoadSavFile(FileName, false)
  if not config then
    return false
  end
  return true, config
end
local SaveFile_DoubledBytes = function(FileName, Config)
  return Client.SaveSavFile(Config.CompressedData, FileName, Config.CompressedSize, Config.UnCompressedFileSize, false)
end
local VerifySavFile_DoubledBytes = function(Config)
  return Client.IsSavFileData(Config.CompressedData, Config.CompressedSize, Config.UnCompressedFileSize, 2, false)
end
local LoadFile_HEX = function(FileName)
  local config = Client.LoadSavFile(FileName, true)
  if not config then
    return false
  end
  return true, config
end
local SaveFile_HEX = function(FileName, Config)
  return Client.SaveSavFile(Config.CompressedData, FileName, Config.CompressedSize, Config.UnCompressedFileSize, true)
end
local VerifySavFile_HEX = function(Config)
  local corrupted = not verify_hex_string(Config.CompressedData)
  if corrupted then
    return false
  end
  return Client.IsSavFileData(Config.CompressedData, Config.CompressedSize, Config.UnCompressedFileSize, 2, true)
end
local LoadFileMap = {
  [SavEncodeSystem.EncodeType.RealBytes] = LoadFile_RealBytes,
  [SavEncodeSystem.EncodeType.FlippedBytes] = LoadFile_FlippedBytes,
  [SavEncodeSystem.EncodeType.DoubledBytes] = LoadFile_DoubledBytes,
  [SavEncodeSystem.EncodeType.HEX] = LoadFile_HEX
}
local SaveFileMap = {
  [SavEncodeSystem.EncodeType.RealBytes] = SaveFile_RealBytes,
  [SavEncodeSystem.EncodeType.FlippedBytes] = SaveFile_FlippedBytes,
  [SavEncodeSystem.EncodeType.DoubledBytes] = SaveFile_DoubledBytes,
  [SavEncodeSystem.EncodeType.HEX] = SaveFile_HEX
}
local VerifySavFileMap = {
  [SavEncodeSystem.EncodeType.RealBytes] = VerifySavFile_RealBytes,
  [SavEncodeSystem.EncodeType.FlippedBytes] = VerifySavFile_FlippedBytes,
  [SavEncodeSystem.EncodeType.DoubledBytes] = VerifySavFile_DoubledBytes,
  [SavEncodeSystem.EncodeType.HEX] = VerifySavFile_HEX
}
function SavEncodeSystem.LoadFile(FileName, InEncodeType)
  InEncodeType = InEncodeType or -1
  print(bWriteLog and string.format("SavEncodeSystem.LoadFile %s EncodeType:%d ", FileName, InEncodeType))
  local LoadFileFunction = LoadFileMap[InEncodeType]
  if LoadFileFunction then
    local time = slua.getMiliseconds()
    local bSuccessful, Config = LoadFileFunction(FileName)
    time = slua.getMiliseconds() - time
    if bSuccessful then
      Config.EncodeType = InEncodeType
      print(bWriteLog and string.format("SavEncodeSystem.LoadFile Success, time cost %dms", math.floor(time)))
      return true, Config
    else
      print(bWriteLog and "SavEncodeSystem.LoadFile Failed, time cost %dms")
      return false
    end
  else
    print(bWriteLog and string.format("SavEncodeSystem.LoadFile no such EncodeType:%d", InEncodeType))
    return false
  end
end
function SavEncodeSystem.SaveFile(FileName, Config, InEncodeType)
  InEncodeType = InEncodeType or -1
  print(bWriteLog and string.format("SavEncodeSystem.SaveFile %s EncodeType:%d ", FileName, InEncodeType))
  if Config.CompressedSize == nil or Config.UnCompressedFileSize == nil or Config.CompressedData == nil then
    if Config.CompressedSize == nil then
      print("SavEncodeSystem.SaveFile CompressedSize nil")
    end
    if Config.UnCompressedFileSize == nil then
      print("SavEncodeSystem.SaveFile UnCompressedFileSize nil")
    end
    if Config.CompressedData == nil then
      print("SavEncodeSystem.SaveFile CompressedData nil")
    end
    return false
  end
  local SaveFileFunction = SaveFileMap[InEncodeType]
  if SaveFileFunction then
    local time = slua.getMiliseconds()
    local bSuccessful = SaveFileMap[InEncodeType](FileName, Config)
    time = slua.getMiliseconds() - time
    print(bWriteLog and string.format("SavEncodeSystem.SaveFile Success %s, time cost %dms", tostring(bSuccessful), math.floor(time)))
    return bSuccessful
  else
    print(bWriteLog and string.format("SavEncodeSystem.LoadFile no such EncodeType:%d", InEncodeType))
    return false
  end
end
function SavEncodeSystem.VerifySavFile(Config, InEncodeType)
  InEncodeType = InEncodeType or -1
  print(bWriteLog and string.format("SavEncodeSystem.VerifySavFile EncodeType:%d", InEncodeType))
  if Config.CompressedSize == nil or Config.UnCompressedFileSize == nil or Config.CompressedData == nil then
    if Config.CompressedSize == nil then
      print("SavEncodeSystem.VerifySavFile CompressedSize nil")
    end
    if Config.UnCompressedFileSize == nil then
      print("SavEncodeSystem.VerifySavFile UnCompressedFileSize nil")
    end
    if Config.CompressedData == nil then
      print("SavEncodeSystem.VerifySavFile CompressedData nil")
    end
    return false
  end
  local bPassed = false
  local time_0 = slua.getMiliseconds()
  local VerifySavFileFunction = VerifySavFileMap[InEncodeType]
  if VerifySavFileFunction then
    bPassed = VerifySavFileFunction(Config)
    local time = slua.getMiliseconds() - time_0
    print(bWriteLog and string.format("SavEncodeSystem.VerifySavFile initial Passed %s, time cost %dms", tostring(bPassed), math.floor(time)))
  else
    print(bWriteLog and string.format("SavEncodeSystem.VerifySavFile no such EncodeType:%d", InEncodeType))
  end
  if bPassed then
    return true, InEncodeType
  end
  for CheckType = 1, 4 do
    if CheckType ~= InEncodeType and VerifySavFileMap[CheckType](Config) then
      local time_i = slua.getMiliseconds() - time_0
      print(bWriteLog and string.format("SavEncodeSystem.VerifySavFile Try Again and Pass with EncodeType %d, total time cost %dms", CheckType, math.floor(time_i)))
      return true, CheckType
    end
  end
  local time_all = slua.getMiliseconds() - time_0
  print(bWriteLog and string.format("SavEncodeSystem.VerifySavFile Failed, total time cost %dms", math.floor(time_all)))
  return false
end
return SavEncodeSystem