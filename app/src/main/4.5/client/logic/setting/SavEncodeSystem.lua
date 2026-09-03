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
local _ValidateSaveFile = function(filePath)
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
local LoadFileMap = {
  [SavEncodeSystem.EncodeType.RealBytes] = LoadFile_RealBytes
}
local SaveFileMap = {
  [SavEncodeSystem.EncodeType.RealBytes] = SaveFile_RealBytes
}
local VerifySavFileMap = {
  [SavEncodeSystem.EncodeType.RealBytes] = VerifySavFile_RealBytes
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
  return false
end
return SavEncodeSystem