local CreativeModeUtility = {}
local PBUtility = require("GameLua.Mod.CreativeBase.BinaryData.CreativeModePbUtility")
local VectorZero = FVector2D(0, 0)
local UKismetSystemLibrary = import("KismetSystemLibrary")
local UCreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
local CreativeGlobalDefine = require("GameLua.Mod.CreativeBase.Gameplay.Config.Asset.Common.CreativeGlobalDefine")
local _bCacheIsShipping, _bForceVoiceBlockSwitch
function CreativeModeUtility:dump_value_(v)
  if type(v) == "string" then
    v = "\"" .. v .. "\""
  end
  return tostring(v)
end
function CreativeModeUtility:split(input, delimiter)
  input = tostring(input)
  delimiter = tostring(delimiter)
  if delimiter == "" then
    return false
  end
  local pos, arr = 0, {}
  for st, sp in function()
    return string.find(input, delimiter, pos, true)
  end, nil, nil do
    table.insert(arr, string.sub(input, pos, st - 1))
    pos = sp + 1
  end
  table.insert(arr, string.sub(input, pos))
  return arr
end
function CreativeModeUtility:trim(input)
  return (string.gsub(input, "^%s*(.-)%s*$", "%1"))
end
function CreativeModeUtility:contains(SourceStr, TargetStr)
  return string.find(SourceStr, TargetStr, 1, true) ~= nil
end
function CreativeModeUtility:dump(value, desciption, nesting)
  if type(nesting) ~= "number" then
    nesting = 3
  end
  local lookupTable = {}
  local result = {}
  local traceback = self:split(debug.traceback("", 2), "\n")
  local function dump_(value, desciption, indent, nest, keylen)
    desciption = desciption or "<var>"
    local spc = ""
    if type(keylen) == "number" then
      spc = string.rep(" ", keylen - string.len(self:dump_value_(desciption)))
    end
    if type(value) ~= "table" then
      result[#result + 1] = string.format("%s%s%s = %s", indent, self:dump_value_(desciption), spc, self:dump_value_(value))
    elseif lookupTable[tostring(value)] then
      result[#result + 1] = string.format("%s%s%s = *REF*", indent, self:dump_value_(desciption), spc)
    else
      lookupTable[tostring(value)] = true
      if nest > nesting then
        result[#result + 1] = string.format("%s%s = *MAX NESTING*", indent, self:dump_value_(desciption))
      else
        result[#result + 1] = string.format("%s%s = {", indent, self:dump_value_(desciption))
        local indent2 = indent .. "    "
        local keys = {}
        local keylen = 0
        local values = {}
        for k, v in pairs(value) do
          keys[#keys + 1] = k
          local vk = self:dump_value_(k)
          local vkl = string.len(vk)
          if keylen < vkl then
            keylen = vkl
          end
          values[k] = v
        end
        table.sort(keys, function(a, b)
          if type(a) == "number" and type(b) == "number" then
            return a < b
          else
            return tostring(a) < tostring(b)
          end
        end)
        for i, k in ipairs(keys) do
          dump_(values[k], k, indent2, nest + 1, keylen)
        end
        result[#result + 1] = string.format("%s}", indent)
      end
    end
  end
  dump_(value, desciption, "- ", 1)
  for i, line in ipairs(result) do
    print(bWriteLog and "CreativeModeUtility" .. line)
  end
end
function CreativeModeUtility:PrintTable(value, desciption, nesting)
  print(bWriteLog and "CreativeModeUtility:PrintTable")
end
local SplitStringKeyMap = {}
function CreativeModeUtility:Split(input, delimiter)
  local outArr = SplitStringKeyMap[input]
  if outArr == nil then
    outArr = {}
    string.gsub(input, "[^" .. delimiter .. "]+", function(w)
      table.insert(outArr, w)
    end)
    SplitStringKeyMap[input] = outArr
  end
  return outArr
end
function CreativeModeUtility:ToStringEx(value)
  return PBUtility.ToStringEx(value)
end
function CreativeModeUtility:TableToStr(t)
  return PBUtility.TableToStr(t)
end
function CreativeModeUtility:StrToTable(str)
  return PBUtility.StrToTable(str)
end
function CreativeModeUtility:Table_ToString(t)
  if not t then
    return nil
  end
  local mark = {}
  local assign = {}
  local function ser_table(tbl, parent, offset)
    offset = offset + 2
    mark[tbl] = parent
    local tmp = {}
    local format_offset_str = "%" .. offset .. "s"
    local prefix = string.format(format_offset_str, "")
    for k, v in pairs(tbl) do
      local key = type(k) == "number" and "[" .. k .. "]" or type(k) == "string" and "[" .. string.format("%q", k) .. "]" or "[" .. tostring(k) .. "]"
      key = prefix .. key
      if type(v) == "table" then
        local dotkey = parent .. key
        if mark[v] then
          table.insert(assign, dotkey .. "=" .. mark[v] .. "")
        else
          table.insert(tmp, key .. "=" .. ser_table(v, dotkey, offset))
        end
      elseif type(v) == "string" then
        table.insert(tmp, key .. "=" .. string.format("%q", v))
      elseif type(v) == "number" or type(v) == "boolean" then
        table.insert(tmp, key .. "=" .. tostring(v))
      end
    end
    return "{\n" .. table.concat(tmp, ",\n") .. "\n" .. string.format("%" .. offset - 2 .. "s", "") .. "}"
  end
  return ser_table(t, "ret", 0) .. table.concat(assign, "")
end
function CreativeModeUtility:ParameterEqual(ParameterA, ParameterB)
  if ParameterA == nil or ParameterB == nil then
    if ParameterA == ParameterB then
      return true
    end
    return false
  end
  local ParameterAType = type(ParameterA)
  local ParameterBType = type(ParameterB)
  if ParameterAType ~= ParameterBType then
    return false
  end
  if ParameterAType == "table" then
    local Equal = true
    local NotEqualKey
    local surplusValueNum = 0
    for key, value in pairs(ParameterB) do
      surplusValueNum = surplusValueNum + 1
    end
    for key, value in pairs(ParameterA) do
      if ParameterB[key] ~= nil then
        surplusValueNum = surplusValueNum - 1
        Equal = self:ParameterEqual(value, ParameterB[key])
        if not Equal then
          NotEqualKey = key
          break
        end
      else
        Equal = false
        NotEqualKey = key
        break
      end
    end
    if Equal and surplusValueNum ~= 0 then
      Equal = false
      NotEqualKey = "DiffKeys"
    end
    return Equal, NotEqualKey
  elseif ParameterAType == "number" and ParameterBType == "number" then
    if math.abs(ParameterA - ParameterB) < 0.001 then
      return true
    end
    return false
  else
    local LastString = CreativeModeUtility:ToStringEx(ParameterA)
    local NewString = CreativeModeUtility:ToStringEx(ParameterB)
    return LastString == NewString
  end
end
function CreativeModeUtility:TableRecursiveReplace(table, replacements, ignoreKeys)
  if table == nil then
    return table
  end
  for Key, Value in pairs(table) do
    if ignoreKeys == nil or ignoreKeys[Key] == nil then
      if type(Value) == "table" then
        CreativeModeUtility:TableRecursiveReplace(Value, replacements, ignoreKeys)
      elseif replacements[Value] ~= nil then
        table[Key] = replacements[Value]
      end
    end
  end
  return table
end
function CreativeModeUtility:GetTableLenght(table)
  local len = 0
  if table ~= nil and type(table) == "table" then
    for k, v in pairs(table) do
      len = len + 1
    end
  end
  return len
end
function CreativeModeUtility:KeepDecimal(number, n)
  if type(number) ~= "number" then
    return number
  end
  local numberString = string.format("%." .. n .. "f", number)
  return tonumber(numberString)
end
function CreativeModeUtility:DeepCopy(tOrigin, tCopy)
  if tOrigin == nil then
    return tOrigin
  end
  if type(tOrigin) ~= "table" then
    return tOrigin
  end
  if tCopy == nil then
    tCopy = {}
  elseif type(tCopy) ~= "table" then
    return tOrigin
  end
  for key, value in pairs(tOrigin) do
    if type(value) == "table" then
      tCopy[key] = self:DeepCopy(value, tCopy[key])
    else
      tCopy[key] = value
    end
  end
  for key, value in pairs(tCopy) do
    if tOrigin[key] == nil then
      tCopy[key] = nil
    end
  end
  return tCopy
end
function CreativeModeUtility:GetModCheckConfig()
  local str = Client.LoadFileToStringByFullPath("C:/mod_check_config.txt")
  local configpath = CGame:GetCommandLineValue("configpath=")
  if configpath and configpath ~= "" then
    str = Client.LoadFileToStringByFullPath(configpath)
  end
  local config
  if str ~= "" and str ~= nil then
    config = self:StrToTable(str)
  end
  return config
end
function CreativeModeUtility:LoadFileBinaryData(FilePath)
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  return Util_UGC.LoadFileBinaryData(FilePath)
end
local ObjectParameterKeyMap = {}
local SplitString = function(str)
  local name, index = str:match("^(.-)%[(%d+)%]$")
  return name, tonumber(index)
end
function CreativeModeUtility:GetValueByKey(Tree, Key)
  local KeyTable = ObjectParameterKeyMap[Key]
  if KeyTable == nil then
    local StringUtil = require("common.string_util")
    KeyTable = StringUtil.Split(Key, ".")
    ObjectParameterKeyMap[Key] = KeyTable
  end
  local Index
  local Node = Tree
  if Node ~= nil then
    for _, Value in pairs(KeyTable) do
      if Value:sub(-1) == "]" then
        Value, Index = SplitString(Value)
        if Node[Value] == nil then
          return nil
        end
        Node = Node[Value]
        if Node.overrides then
          if Index < 1 or Index > #Node.overrides then
            return nil
          end
          Node = Node.overrides[Index]
        else
          return nil
        end
      else
        if Node[Value] == nil then
          return nil
        end
        Node = Node[Value]
      end
    end
  end
  return Node
end
function CreativeModeUtility:GetAssetIDForShow(Tree)
  if Tree then
    local CreativeEmpowerDefine = require("GameLua.Mod.CreativeBase.Gameplay.Config.Asset.Common.CreativeEmpowerDefine")
    if CreativeEmpowerDefine.IsEmpowerAsset(Tree.AssetId) then
      if CreativeEmpowerDefine.IsEmpowerAssetGroup(Tree.AssetId) then
        return Tree.AssetId, Tree.AssetId
      else
        return Tree.AssetId, CreativeEmpowerDefine.GetEmpowerAssetID(Tree)
      end
    end
    return Tree.AssetId, Tree.AssetId
  end
  return 0, 0
end
local _cacheLocation = FVector(0, 0, 0)
local _cacheRotation = FRotator(0, 0, 0)
local _cacheScale = FVector(1, 1, 1)
function CreativeModeUtility:MakeUnrealTransform(LuaTransform)
  if LuaTransform == nil then
    return FTransform()
  end
  if LuaTransform.Location then
    _cacheLocation.X = LuaTransform.Location.X
    _cacheLocation.Y = LuaTransform.Location.Y
    _cacheLocation.Z = LuaTransform.Location.Z
  else
    _cacheLocation.X = 0
    _cacheLocation.Y = 0
    _cacheLocation.Z = 0
  end
  if LuaTransform.Rotation then
    if LuaTransform.Rotation.Pitch ~= nil then
      _cacheRotation.Pitch = LuaTransform.Rotation.Pitch
    elseif LuaTransform.Rotation.P ~= nil then
      _cacheRotation.Pitch = LuaTransform.Rotation.P
    else
      _cacheRotation.Pitch = 0
    end
    if LuaTransform.Rotation.Yaw ~= nil then
      _cacheRotation.Yaw = LuaTransform.Rotation.Yaw
    elseif LuaTransform.Rotation.Y ~= nil then
      _cacheRotation.Yaw = LuaTransform.Rotation.Y
    else
      _cacheRotation.Yaw = 0
    end
    if LuaTransform.Rotation.Roll ~= nil then
      _cacheRotation.Roll = LuaTransform.Rotation.Roll
    elseif LuaTransform.Rotation.R ~= nil then
      _cacheRotation.Roll = LuaTransform.Rotation.R
    else
      _cacheRotation.Roll = 0
    end
  else
    _cacheRotation.Pitch = 0
    _cacheRotation.Yaw = 0
    _cacheRotation.Roll = 0
  end
  if LuaTransform.Scale then
    _cacheScale.X = LuaTransform.Scale.X
    _cacheScale.Y = LuaTransform.Scale.Y
    _cacheScale.Z = LuaTransform.Scale.Z
  else
    _cacheScale.X = 1
    _cacheScale.Y = 1
    _cacheScale.Z = 1
  end
  local UKismetMathLibrary = import("KismetMathLibrary")
  return UKismetMathLibrary.MakeTransform(_cacheLocation, _cacheRotation, _cacheScale)
end
function CreativeModeUtility:UnrealTransformNanCorrect(UeTransform)
  if UeTransform == nil then
    return
  end
  local bNeedCorrect = false
  local Rotation = UeTransform:Rotator()
  if tostring(Rotation.Pitch) == "nan" then
    bNeedCorrect = true
    Rotation.Pitch = 0
  end
  if tostring(Rotation.Yaw) == "nan" then
    bNeedCorrect = true
    Rotation.Yaw = 0
  end
  if tostring(Rotation.Roll) == "nan" then
    bNeedCorrect = true
    Rotation.Roll = 0
  end
  if bNeedCorrect then
    Game:TransFormSetRotator(UeTransform, Rotation)
  end
end
function CreativeModeUtility:ResetLuaTransform(luaTransTable)
  if luaTransTable then
    if luaTransTable.Location then
      luaTransTable.Location.X = 0
      luaTransTable.Location.Y = 0
      luaTransTable.Location.Z = 0
    end
    if luaTransTable.Rotation then
      luaTransTable.Rotation.Roll = 0
      luaTransTable.Rotation.Yaw = 0
      luaTransTable.Rotation.Pitch = 0
    end
    if luaTransTable.Scale then
      luaTransTable.Scale.X = 1
      luaTransTable.Scale.Y = 1
      luaTransTable.Scale.Z = 1
    end
  end
end
function CreativeModeUtility:MakeLuaTransform(UnrealTransform, luaTransTable)
  local LuaTransform
  if luaTransTable then
    LuaTransform = luaTransTable
  else
    LuaTransform = {
      Location = {
        X = 0,
        Y = 0,
        Z = 0
      },
      Rotation = {
        Roll = 0,
        Yaw = 0,
        Pitch = 0
      },
      Scale = {
        X = 1,
        Y = 1,
        Z = 1
      }
    }
  end
  if UnrealTransform then
    local KeepKeepDecimalNum = 4
    local Location = UnrealTransform:GetLocation()
    LuaTransform.Location.X = self:KeepDecimal(Location.X, KeepKeepDecimalNum)
    LuaTransform.Location.Y = self:KeepDecimal(Location.Y, KeepKeepDecimalNum)
    LuaTransform.Location.Z = self:KeepDecimal(Location.Z, KeepKeepDecimalNum)
    local Rotator = UnrealTransform:Rotator()
    LuaTransform.Rotation.Roll = self:KeepDecimal(Rotator.Roll, KeepKeepDecimalNum)
    LuaTransform.Rotation.Yaw = self:KeepDecimal(Rotator.Yaw, KeepKeepDecimalNum)
    LuaTransform.Rotation.Pitch = self:KeepDecimal(Rotator.Pitch, KeepKeepDecimalNum)
    local Scale3D = UnrealTransform:GetScale3D()
    local Scale3dX = Scale3D.X
    local Scale3dY = Scale3D.Y
    local Scale3dZ = Scale3D.Z
    LuaTransform.Scale.X = self:KeepDecimal(Scale3dX, KeepKeepDecimalNum)
    LuaTransform.Scale.Y = self:KeepDecimal(Scale3dY, KeepKeepDecimalNum)
    LuaTransform.Scale.Z = self:KeepDecimal(Scale3dZ, KeepKeepDecimalNum)
  end
  return LuaTransform
end
function CreativeModeUtility:MakeLuaTransformForData(Location, Rotator, Scale3D, luaTransTable)
  local LuaTransform
  if luaTransTable then
    LuaTransform = luaTransTable
  else
    LuaTransform = {
      Location = {
        X = 0,
        Y = 0,
        Z = 0
      },
      Rotation = {
        Roll = 0,
        Yaw = 0,
        Pitch = 0
      },
      Scale = {
        X = 1,
        Y = 1,
        Z = 1
      }
    }
  end
  if Location then
    LuaTransform.Location.X = Location.X
    LuaTransform.Location.Y = Location.Y
    LuaTransform.Location.Z = Location.Z
  end
  if Rotator then
    LuaTransform.Rotation.Roll = Rotator.Roll
    LuaTransform.Rotation.Yaw = Rotator.Yaw
    LuaTransform.Rotation.Pitch = Rotator.Pitch
  end
  if Scale3D then
    LuaTransform.Scale.X = Scale3D.X
    LuaTransform.Scale.Y = Scale3D.Y
    LuaTransform.Scale.Z = Scale3D.Z
  end
  return LuaTransform
end
function CreativeModeUtility:UeVectorAss(selfVector, otherVector)
  selfVector.X = otherVector.X
  selfVector.Y = otherVector.Y
  selfVector.Z = otherVector.Z
  return selfVector
end
function CreativeModeUtility:UeVectorAdd(selfVector, otherVector)
  selfVector.X = selfVector.X + otherVector.X
  selfVector.Y = selfVector.Y + otherVector.Y
  selfVector.Z = selfVector.Z + otherVector.Z
  return selfVector
end
function CreativeModeUtility:UeVectorSub(selfVector, otherVector)
  selfVector.X = selfVector.X - otherVector.X
  selfVector.Y = selfVector.Y - otherVector.Y
  selfVector.Z = selfVector.Z - otherVector.Z
  return selfVector
end
function CreativeModeUtility:UeVectorMul(selfVector, other)
  if type(other) == "number" then
    selfVector.X = selfVector.X * other
    selfVector.Y = selfVector.Y * other
    selfVector.Z = selfVector.Z * other
  else
    selfVector.X = selfVector.X * other.X
    selfVector.Y = selfVector.Y * other.Y
    selfVector.Z = selfVector.Z * other.Z
  end
  return selfVector
end
function CreativeModeUtility:UeVectorDiv(selfVector, other)
  if type(other) == "number" then
    selfVector.X = selfVector.X / other
    selfVector.Y = selfVector.Y / other
    selfVector.Z = selfVector.Z / other
  else
    selfVector.X = selfVector.X / other.X
    selfVector.Y = selfVector.Y / other.Y
    selfVector.Z = selfVector.Z / other.Z
  end
  return selfVector
end
function CreativeModeUtility:UeVectorSize(selfVector, other)
  if type(other) == "number" then
    selfVector.X = selfVector.X / other
    selfVector.Y = selfVector.Y / other
    selfVector.Z = selfVector.Z / other
  else
    selfVector.X = selfVector.X / other.X
    selfVector.Y = selfVector.Y / other.Y
    selfVector.Z = selfVector.Z / other.Z
  end
  return selfVector
end
function CreativeModeUtility:ClearCacheData()
  ObjectParameterKeyMap = {}
  SplitStringKeyMap = {}
  _bCacheIsShipping = nil
  local EditConfig = require("GameLua.Mod.CreativeBase.Client.CreativeModeParameterEdit.CreativeModeObjectParameterEditConfig")
  EditConfig.CleanCacheConfig()
end
local Cache_WorldBoxCenterVector = FVector(1, 1, 1)
local Cache_WorldBoxExtentVector = FVector(1, 1, 1)
function CreativeModeUtility:CheckLocationInWorld(location, context)
  if context == nil then
    if CGameWorld ~= nil then
      context = CGameWorld
    elseif slua and slua.getWorld then
      context = slua.getWorld()
    else
      local STExtraGameInstance = import("STExtraGameInstance")
      context = STExtraGameInstance.GetInstance()
    end
  end
  local STExtraMapFunctionLibrary = import("STExtraMapFunctionLibrary")
  local levelExtent = STExtraMapFunctionLibrary.GetLevelLandscapeBounds(context)
  if levelExtent < 500 then
    return true
  end
  local CreativeModeGameSubsystem = SubsystemMgr:Get("CreativeModeGameSubsystem")
  local zConfig, MapExtentLimitOffset
  if CreativeModeGameSubsystem then
    zConfig = CreativeModeGameSubsystem:GetCurMapZLimitConfig()
    MapExtentLimitOffset = CreativeModeGameSubsystem:GetCurMapExtentLimitOffsetConfig()
  end
  if MapExtentLimitOffset then
    levelExtent = levelExtent + MapExtentLimitOffset
  end
  local center = STExtraMapFunctionLibrary.GetLandscapeMidPoint(context)
  Cache_WorldBoxCenterVector.X = center.X
  Cache_WorldBoxCenterVector.Y = center.Y
  Cache_WorldBoxCenterVector.Z = 0
  Cache_WorldBoxExtentVector.X = levelExtent / 2
  Cache_WorldBoxExtentVector.Y = levelExtent / 2
  Cache_WorldBoxExtentVector.Z = 100000
  local KismetMathLibrary = import("KismetMathLibrary")
  return KismetMathLibrary.IsPointInBox(location, Cache_WorldBoxCenterVector, Cache_WorldBoxExtentVector)
end
function CreativeModeUtility:GetWorldBBox(context)
  if context == nil then
    if CGameWorld ~= nil then
      context = CGameWorld
    elseif slua and slua.getWorld then
      context = slua.getWorld()
    else
      local STExtraGameInstance = import("STExtraGameInstance")
      context = STExtraGameInstance.GetInstance()
    end
  end
  local STExtraMapFunctionLibrary = import("STExtraMapFunctionLibrary")
  local levelExtent = STExtraMapFunctionLibrary.GetLevelLandscapeBounds(context)
  local CreativeModeGameSubsystem = SubsystemMgr:Get("CreativeModeGameSubsystem")
  local zConfig, MapExtentLimitOffset
  if CreativeModeGameSubsystem then
    zConfig = CreativeModeGameSubsystem:GetCurMapZLimitConfig()
    MapExtentLimitOffset = CreativeModeGameSubsystem:GetCurMapExtentLimitOffsetConfig()
  end
  if MapExtentLimitOffset then
    levelExtent = levelExtent + MapExtentLimitOffset
  end
  local center = STExtraMapFunctionLibrary.GetLandscapeMidPoint(context)
  Cache_WorldBoxCenterVector.X = center.X
  Cache_WorldBoxCenterVector.Y = center.Y
  Cache_WorldBoxCenterVector.Z = 0
  Cache_WorldBoxExtentVector.X = levelExtent / 2
  Cache_WorldBoxExtentVector.Y = levelExtent / 2
  Cache_WorldBoxExtentVector.Z = 100000
  return Cache_WorldBoxCenterVector, Cache_WorldBoxExtentVector
end
function CreativeModeUtility:ProjectWorldToScreen(WorldPos, OutPosition, uPlayerCtrl)
  if OutPosition == nil then
    OutPosition = FVector2D(0, 0)
  end
  if uPlayerCtrl == nil then
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    uPlayerCtrl = GameplayData.GetPlayerController()
  end
  if uPlayerCtrl == nil then
    sandbox.LogError("uPlayerCtrl is nil")
    return VectorZero, false
  end
  local UGameplayStatics = CreativeModeUtility.ImportGameplayStatics()
  local bResult, ScreenPosition = UGameplayStatics.ProjectWorldToScreen(uPlayerCtrl, WorldPos, OutPosition, false)
  if bResult then
    return ScreenPosition, true
  end
  return VectorZero, false
end
local UGameplayStatics_Cache
function CreativeModeUtility.ImportGameplayStatics()
  if UGameplayStatics_Cache == nil then
    UGameplayStatics_Cache = import("GameplayStatics")
  end
  return UGameplayStatics_Cache
end
function CreativeModeUtility.GetPlayerCharacter()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return nil
  end
  if uPlayerController.bIsInFreeBuildState then
    return uPlayerController.uFreeViewPawn
  else
    return GameplayData.GetPlayerCharacter()
  end
end
function CreativeModeUtility:GetPlayerKeyByUID(playerUid)
  local uPlayerController = Game:GetPlayerControllerByUID(playerUid)
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "[CreativeModeUtility] invalid player controller")
    return -1
  end
  return uPlayerController.PlayerKey
end
function CreativeModeUtility:GetPlayerUID2PlayerState()
  local ret = {}
  local tPawns = Game:GetAllPlayerPawns()
  for _, uPawn in pairs(tPawns) do
    local uPC = uPawn:GetPlayerControllerSafety()
    if uPC ~= nil and slua.isValid(uPC) then
      local uPlayerState = uPC.PlayerState
      if slua.isValid(uPlayerState) and uPlayerState.PlayerUID then
        ret[uPlayerState.PlayerUID] = uPlayerState
      end
    end
  end
  return ret
end
local DuplicateResetInstanceKeys = {
  "AssetNameIndex"
}
local DuplicateResetInstanceValues = {AssetNameIndex = 0}
function CreativeModeUtility.ResetInstanceValueFromDuplicate(DuplicateInstanceNode)
  for i = 1, #DuplicateResetInstanceKeys do
    local ResetKey = DuplicateResetInstanceKeys[i]
    DuplicateInstanceNode[ResetKey] = DuplicateResetInstanceValues[ResetKey]
  end
end
function CreativeModeUtility.OverrideInstanceDataWithObjectParam(instanceData)
  local CreativeModeObjectParameterConfig = require("GameLua.Mod.CreativeBase.Gameplay.Config.CreativeModeObjectParameterConfig")
  local ParameterConfig = CreativeModeObjectParameterConfig.GetObjectParameterMap(instanceData.AssetId, true)
  local InstanceManager = GetInstanceManager()
  local AssetInfo = GetAssetManager():GetAsset(instanceData.AssetId)
  for key, value in pairs(ParameterConfig) do
    local AssetValue = CreativeModeUtility:GetValueByKey(AssetInfo, key)
    if AssetValue ~= nil then
      local TempKey = key
      if type(AssetValue) == "table" then
        TempKey = key .. ".overrides"
      end
      InstanceManager:AddKeyToInstanceTable(instanceData, TempKey, AssetValue, false)
    end
  end
end
function CreativeModeUtility:GetPlayersByRangeType(PlayerRangeType, TriggerPlayerUID, TriggerPlayerKey, TriggerTeamID, CustomTeamID, IncludeSpectator)
  local PlayerList = {}
  TriggerTeamID = TriggerTeamID or 0
  CustomTeamID = CustomTeamID or 0
  if IncludeSpectator == nil then
    IncludeSpectator = true
  end
  if PlayerRangeType == 2 then
    local PlayerPawns = Game:GetAllPlayerPawns()
    for index = 1, PlayerPawns:Num() do
      local PlayerPawn = PlayerPawns:Get(index - 1)
      self:_AddPlayerFilterSectator(PlayerList, PlayerPawn, IncludeSpectator)
    end
  elseif PlayerRangeType == 0 then
    self:GetTeamPlayersByTeamID(TriggerTeamID, PlayerList, IncludeSpectator)
  elseif PlayerRangeType == 1 then
    local PlayerCharacter = Game:GetCharacterByUID(tonumber(TriggerPlayerUID))
    self:_AddPlayerFilterSectator(PlayerList, PlayerCharacter, IncludeSpectator)
  elseif PlayerRangeType == 3 then
    self:GetTeamPlayersByTeamID(CustomTeamID, PlayerList, IncludeSpectator)
  end
  return PlayerList
end
function CreativeModeUtility:GetTeamPlayersByTeamID(TeamID, PlayerList, IncludeSpectator)
  local TeamArray = CGameMode:CreativeGetTeammates(TeamID)
  for key, uPlayerState in pairs(TeamArray) do
    if slua.isValid(uPlayerState) then
      local PlayerCharacter = uPlayerState:GetPlayerCharacter()
      self:_AddPlayerFilterSectator(PlayerList, PlayerCharacter, IncludeSpectator)
    end
  end
end
function CreativeModeUtility:_AddPlayerFilterSectator(PlayerList, PlayerCharacter, IncludeSpectator)
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local PC = PlayerCharacter:GetPlayerControllerSafety()
  if slua.isValid(PC) and (IncludeSpectator or not PC:IsSpectator() and not PC:IsInPetSpectator()) then
    table.insert(PlayerList, PlayerCharacter)
  end
end
function CreativeModeUtility:ValidateTeam(uPlayer, EnableTeamType, TeamID)
  if not slua.isValid(uPlayer) then
    return false
  end
  local PlayerTeamID = uPlayer.TeamID
  printf(bWriteLog and "CreativeModeUtility:ValidateTeam Name:%s TeamID:%s", tostring(uPlayer:GetPlayerNameSafety()), tostring(uPlayer.TeamID))
  return EnableTeamType == 0 or EnableTeamType == 1 and TeamID == PlayerTeamID
end
function CreativeModeUtility:ValidateProfession(uPlayer, EnableProfessionType, ProfessionID)
  if not slua.isValid(uPlayer) then
    return false
  end
  local PlayerProfessionID = 0
  local Subsystem = SubsystemMgr:Get("PlayerStateManagerSubsystem")
  if Subsystem and Subsystem:GetReviveDataTable() then
    local ReviveData = Subsystem:GetReviveData(uPlayer.PlayerKey)
    if ReviveData then
      PlayerProfessionID = ReviveData:GetProfessionId()
    end
  end
  printf(bWriteLog and "CreativeModeUtility:ValidateTeam Name:%s PlayerProfessionID:%s", tostring(uPlayer:GetPlayerNameSafety()), tostring(PlayerProfessionID))
  return EnableProfessionType == 1 or EnableProfessionType == 2 and ProfessionID == PlayerProfessionID or EnableProfessionType == 0 and PlayerProfessionID == 0
end
function CreativeModeUtility:TreesEqual(Tree1, Tree2)
  if type(Tree1) ~= "table" or type(Tree2) ~= "table" then
    return false
  end
  local Value1, Value2
  for Key, _ in pairs(Tree1) do
    Value1 = Tree1[Key]
    Value2 = Tree2[Key]
    if type(Value1) == "table" or type(Value2) == "table" then
      if not self:TreesEqual(Value1, Value2) then
        return false
      end
    elseif Value1 ~= Value2 then
      return false
    end
  end
  for Key, _ in pairs(Tree2) do
    Value1 = Tree1[Key]
    Value2 = Tree2[Key]
    if type(Value1) == "table" or type(Value2) == "table" then
      if not self:TreesEqual(Value1, Value2) then
        return false
      end
    elseif Value1 ~= Value2 then
      return false
    end
  end
  return true
end
function CreativeModeUtility:ParamKeySplitString(str)
  local name, index, rest = str:match("^(.-)%[(%d+)%](.*)$")
  if name and index and rest then
    return name, tonumber(index), rest:sub(2)
  else
    return str
  end
end
function CreativeModeUtility:IsNewbieMod()
  local GameParameterManager = GetGameParameterManager()
  if GameParameterManager then
    local UGCTutorialID = GameParameterManager:GetGameParameter("UGCTutorialID")
    if UGCTutorialID and UGCTutorialID.Value then
      local Val = UGCTutorialID.Value
      if IsEditor then
        local DebugModeTemplateConfig = require("GameLua.Mod.CreativeBase.Client.NewbieGuide.Config.DebugModeTemplateConfig")
        Val = DebugModeTemplateConfig.DebugUGCTutorialID or Val
      end
      return 0 < Val
    end
  end
  return false
end
function CreativeModeUtility:IsNewbieModBanSaved()
  local GameParameterManager = GetGameParameterManager()
  if GameParameterManager then
    local UGCTutorialID = GameParameterManager:GetGameParameter("UGCTutorialID")
    if UGCTutorialID and UGCTutorialID.Value then
      local Val = UGCTutorialID.Value
      if IsEditor then
        local DebugModeTemplateConfig = require("GameLua.Mod.CreativeBase.Client.NewbieGuide.Config.DebugModeTemplateConfig")
        Val = DebugModeTemplateConfig.DebugUGCTutorialID or Val
      end
      return 0 < Val and Val ~= 5
    end
  end
  return false
end
function CreativeModeUtility:GetAssetAsync(Path, Callback, ...)
  if Path == nil and Callback then
    local args = table.pack(...)
    local common = require("client.slua_ui_framework.common")
    common.CallCombinationArgs(Callback, args, nil)
  end
  local KismetSystemLibrary = import("KismetSystemLibrary")
  local ObjectPath = KismetSystemLibrary.MakeSoftObjectPath(Path)
  local args = table.pack(...)
  local OnLoadedDelegate = slua.createDelegate(function(LoadObject, LoadObjectPath)
    if Callback then
      local common = require("client.slua_ui_framework.common")
      common.CallCombinationArgs(Callback, args, LoadObject)
    end
  end)
  local UAELoadedClassManagerCls = import("UAELoadedClassManager")
  local UAELoadedClassManager = UAELoadedClassManagerCls.Get()
  UAELoadedClassManager:GetAssetAsyncWithStringForManage(ObjectPath, Path, OnLoadedDelegate)
end
function CreativeModeUtility:TraverseUserDataKeys(KeyTable, UserData)
  if KeyTable == nil then
    KeyTable = {}
  end
  for Key, Value in pairs(UserData) do
    local PropertyType = type(Value)
    if PropertyType == "userdata" then
      KeyTable[Key] = {}
      CreativeModeUtility:TraverseUserDataKeys(KeyTable[Key], Value)
    else
      KeyTable[Key] = true
    end
  end
end
function CreativeModeUtility:IsModAuthor(PS)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerState = PS or GameplayData.GetPlayerState()
  printf(bWriteLog and "CreativeModeUtility:IsModAuthor %s", tostring(self:IsModAuthorByPS(PlayerState)))
  return self:IsModAuthorByPS(PlayerState)
end
function CreativeModeUtility:IsModAuthorByUID(UID)
  if UID then
    if _G.GetGameParameterManager then
      local ParameterManager = GetGameParameterManager()
      if ParameterManager ~= nil then
        local AuthorIdInfo = ParameterManager:GetGameParameter("AuthorID")
        if AuthorIdInfo ~= nil then
          local bIsAuthor = UID == AuthorIdInfo.Value
          if bIsAuthor then
            return true
          else
            log(bWriteLog and "CreativeModeUtility:IsModAuthor false. author id = " .. tostring(AuthorIdInfo.Value) .. ", self UID = " .. tostring(UID))
          end
        else
          log_warning("CreativeModeUtility:IsModAuthor GetGameParameter AuthorId = nil")
        end
      else
        log_warning("CreativeModeUtility:IsModAuthor GetGameParameterManager = nil")
      end
    end
  else
    log_warning("CreativeModeUtility:IsModAuthor self uid missing")
  end
  return false
end
function CreativeModeUtility:IsModAuthorByPS(PlayerState)
  if not slua.isValid(PlayerState) then
    log_warning("CreativeModeUtility:IsModAuthor PlayerState is nil")
    return false
  end
  return self:IsModAuthorByUID(PlayerState.UID)
end
function CreativeModeUtility:GetModAuthorController()
  if _G.GetGameParameterManager then
    local ParameterManager = GetGameParameterManager()
    if ParameterManager ~= nil then
      local AuthorIdInfo = ParameterManager:GetGameParameter("AuthorID")
      if AuthorIdInfo ~= nil then
        local UID = AuthorIdInfo.Value
        if UID then
          return Game:GetPlayerControllerByUID(UID)
        end
      else
        log_warning("CreativeModeUtility:IsModAuthor GetGameParameter AuthorId = nil")
      end
    else
      log_warning("CreativeModeUtility:IsModAuthor GetGameParameterManager = nil")
    end
  end
end
function CreativeModeUtility:GetPartOfModInfo()
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  return Util_UGC.GetPartOfModInfo()
end
function CreativeModeUtility:GetDraftModUniqueID()
  print(bWriteLog and "CreativeModeUtility:GetDraftModUniqueID")
  local GameParameterMgr = _G.GetGameParameterManager()
  local CreateTime = GameParameterMgr:GetGameParameter("CreateTime").Value
  return tostring(CreateTime)
end
function CreativeModeUtility:GetBinaryDataMd5()
  print(bWriteLog and "[yintaoxu] CreativeModeUtility:GetBinaryDataMd5")
  local ModDataCheckMgr = GetModDataCheckManager()
  local BinaryData
  if ModDataCheckMgr then
    print(bWriteLog and "CreativeModeUtility:GetBinaryDataMd5 In CensorMode")
    local LoadUtil = require("GameLua.Mod.CreativeBase.Gameplay.Manager.ModDataCheck.CreativeModDataCheckLoadUtil")
    local BinaryDataPath = LoadUtil.GetLoadModBinPath()
    if BinaryDataPath then
      BinaryData = LoadUtil.LoadBinaryFile(BinaryDataPath)
    else
      print(bWriteLog and "CreativeModeUtility:GetBinaryDataMd5 CensorMode BinPath Get Failed")
      return
    end
  else
    BinaryData = ServerDataMgr and ServerDataMgr:GetUGCModBinData()
    if BinaryData == nil then
      print(bWriteLog and "CreativeModeUtility:GetBinaryDataMd5 GetUGCModBinData Failed")
      return
    end
  end
  if BinaryData and string.len(BinaryData) > 0 then
    print(bWriteLog and "CreativeModeUtility:GetBinaryDataMd5, #BinaryData: " .. tostring(#BinaryData))
    local BinaryDataMd5 = UCreativeModeBlueprintLibrary.MD5HashByteArray(BinaryData)
    print(bWriteLog and "CreativeModeUtility:GetBinaryDataMd5, Md5: " .. BinaryDataMd5)
    return BinaryDataMd5
  else
    print(bWriteLog and "CreativeModeUtility:GetBinaryDataMd5 BinaryData Length is 0")
    return
  end
  print(bWriteLog and "CreativeModeUtility:GetBinaryDataMd5 IUnexpected return")
  return
end
function CreativeModeUtility:GetAlbumOriginImgList()
  local GameParameterMgr = GetGameParameterManager()
  local hasPhoto, modInfo
  if GameParameterMgr then
    modInfo = GameParameterMgr:GetMetaGameParameterData({})
    if modInfo.setting and modInfo.setting.album and #modInfo.setting.album > 0 then
      hasPhoto = true
    end
  end
  if hasPhoto then
    local ret = {}
    for Index, Info in pairs(modInfo.setting.album) do
      table.insert(ret, Info.origin_url)
    end
    return ret
  else
    return {}
  end
end
function CreativeModeUtility:IsCreativeWow()
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  return Util_UGC.IsCreativeWow()
end
local CreativeModeMaterialConfig = require("GameLua.Mod.CreativeBase.Gameplay.Config.CreativeModeMaterialConfig")
function CreativeModeUtility:GetMaterialTextureId(MatId)
  if MatId > CreativeModeMaterialConfig.CustomEditMaterialId then
    return (MatId & 4278190080) >> 24
  end
  return 0
end
function CreativeModeUtility:GetMaterialColorRGB(MatId)
  if MatId > CreativeModeMaterialConfig.CustomEditMaterialId then
    local colorR = (MatId & 16711680) >> 16
    local colorG = (MatId & 65280) >> 8
    local colorB = MatId & 255
    return colorR / CreativeModeMaterialConfig.HSBDefine.MAX_RGB, colorG / CreativeModeMaterialConfig.HSBDefine.MAX_RGB, colorB / CreativeModeMaterialConfig.HSBDefine.MAX_RGB
  end
  return 0, 0, 0
end
function CreativeModeUtility:GetMaterialIdFromCustomInfo(TexId, R, G, B)
  if TexId and 0 < TexId then
    return TexId << 24 | R << 16 | G << 8 | B
  end
end
function CreativeModeUtility:CustomMaterialIDConversion(cppInstanceNode, CustomMaterialID)
  if not CreativeModeMaterialConfig.bColorISMEnable then
    return
  end
  local MaterialTextureId = CreativeModeUtility:GetMaterialTextureId(CustomMaterialID)
  if MaterialTextureId == 0 then
    return
  end
  local colorR, colorG, colorB = CreativeModeUtility:GetMaterialColorRGB(CustomMaterialID)
  local MAX_RGB = CreativeModeMaterialConfig.HSBDefine.MAX_RGB
  cppInstanceNode.MaterialId = CreativeModeUtility:GetMaterialIdFromCustomInfo(MaterialTextureId, MAX_RGB, MAX_RGB, MAX_RGB)
  cppInstanceNode.CustomMatColorR = math.floor(colorR * MAX_RGB)
  cppInstanceNode.CustomMatColorG = math.floor(colorG * MAX_RGB)
  cppInstanceNode.CustomMatColorB = math.floor(colorB * MAX_RGB)
  cppInstanceNode.SplicingCustomMatID = CustomMaterialID
  cppInstanceNode.MatColorMarkDirty = true
end
function CreativeModeUtility:GetRGBFromCustomHSB(h, s, b)
  if h and s and b then
    local KismetMathLibrary = import("KismetMathLibrary")
    local result = KismetMathLibrary.HSVToRGB(h, s / CreativeModeMaterialConfig.HSBDefine.MAX_SATURATION, b / CreativeModeMaterialConfig.HSBDefine.MAX_BRIGHTNESS, 1)
    return result
  end
  return CreativeModeMaterialConfig.CustomEditMaterialDefaultColor
end
function CreativeModeUtility:GetLinearRGBFromCustomHSB(h, s, b)
  if h and s and b then
    local KismetMathLibrary = import("KismetMathLibrary")
    return KismetMathLibrary.HSVToRGB(h, s / CreativeModeMaterialConfig.HSBDefine.MAX_SATURATION, b / CreativeModeMaterialConfig.HSBDefine.MAX_BRIGHTNESS, 1)
  end
  return CreativeModeMaterialConfig.CustomEditMaterialDefaultColor
end
function CreativeModeUtility:GetHSBFromRGB(color)
  if color then
    color = {
      R = color.R ^ 0.45454545454545453,
      G = color.G ^ 0.45454545454545453,
      B = color.B ^ 0.45454545454545453
    }
    local KismetMathLibrary = import("KismetMathLibrary")
    local h, s, b, a
    h, s, b, a = KismetMathLibrary.RGBToHSV(color, h, s, b, a)
    return h, s * CreativeModeMaterialConfig.HSBDefine.MAX_SATURATION, b * CreativeModeMaterialConfig.HSBDefine.MAX_BRIGHTNESS
  end
end
function CreativeModeUtility:IsCharacterMonster(Character)
  if Game:IsHuman(Character) and Character.SpawnSpeciesIndex and Character.SpawnSpeciesIndex >= 3 then
    return true
  end
  return false
end
function CreativeModeUtility:GetCustomVarDebugStr(Val)
  if type(Val) == "boolean" then
    if Val then
      return "True"
    else
      return "False"
    end
  end
  if type(Val) == "number" then
    if math.floor(Val) == Val then
      return tostring(Val)
    else
      return string.format("%.3f", Val)
    end
  end
  return tostring(Val)
end
function CreativeModeUtility:IsCoinKeptWhenAddItem()
  local GameMgr = GetGameParameterManager()
  if GameMgr then
    local CoinKept = GameMgr:GetGameParameter("KeepCoinInGames")
    if CoinKept ~= nil and CoinKept.Value ~= nil then
      return CoinKept.Value
    end
  end
  return false
end
function CreativeModeUtility:IsCoinKeptAcrossGame()
  local GameMgr = GetGameParameterManager()
  if GameMgr then
    local CoinKept = GameMgr:GetGameParameter("KeepCoinAcrossGames")
    if CoinKept ~= nil and CoinKept.Value ~= nil then
      return CoinKept.Value
    end
  end
  return false
end
function CreativeModeUtility:IsDropCoinWhenFailOrEscaped()
  local GameMgr = GetGameParameterManager()
  if GameMgr then
    local DropCoinWhenFail = GameMgr:GetGameParameter("DropCoinWhenFail")
    if DropCoinWhenFail ~= nil and DropCoinWhenFail.Value ~= nil then
      print(bWriteLog and "CreativeModeUtility:IsDropCoinWhenFailOrEscaped DropCoinWhenFail:" .. tostring(DropCoinWhenFail.Value))
      return DropCoinWhenFail.Value
    end
  end
  return false
end
function CreativeModeUtility:GetCoinID()
  return 3000324
end
function CreativeModeUtility:GetTalentPointID()
  return 3000347
end
function CreativeModeUtility:IsEditorMode()
  local initTypeIsEditor = false
  if CGameState and slua.isValid(CGameState) and CGameState.GetInitializeGameType then
    local InitializeGameType = CGameState:GetInitializeGameType()
    local ECreativeModeGameType = import("ECreativeModeGameType")
    initTypeIsEditor = InitializeGameType == ECreativeModeGameType.CreativeModeGameType_Editor
  end
  print(bWriteLog and "CreativeModeUtility initTypeIsEditor:" .. tostring(initTypeIsEditor))
  return initTypeIsEditor
end
function CreativeModeUtility:IsCurrentEditorMode()
  local TypeIsEditor = false
  if CGameState and slua.isValid(CGameState) then
    if CGameState.GetCurrentGameType then
      local CurrentGameType = CGameState:GetCurrentGameType()
      local ECreativeModeGameType = import("ECreativeModeGameType")
      TypeIsEditor = CurrentGameType == ECreativeModeGameType.CreativeModeGameType_Editor
    end
  else
    print(bWriteLog and "CreativeModeUtility CGameState is nil")
  end
  print(bWriteLog and "CreativeModeUtility TypeIsEditor:" .. tostring(TypeIsEditor))
  return TypeIsEditor
end
function CreativeModeUtility:IsVoiceBlocked()
  if _bForceVoiceBlockSwitch ~= nil then
    return _bForceVoiceBlockSwitch == true
  end
  return IsWoWEditor == true
end
function CreativeModeUtility:SetVoiceBlockSwitch(bEnable)
  if bEnable == nil then
    _bForceVoiceBlockSwitch = nil
  else
    _bForceVoiceBlockSwitch = bEnable == true
  end
end
function CreativeModeUtility:GetCurFrameNumber()
  return UCreativeModeBlueprintLibrary.GetCurFrameNumber()
end
function CreativeModeUtility:IsOfficialGame()
  if slua.isValid(CGameState) and CGameState:IsOfficialGame() and not CGameState.bIsCreativeWoW then
    return true
  end
  return false
end
function CreativeModeUtility:IsAIPlayer(uPlayerState)
  if not slua.isValid(uPlayerState) then
    return false
  end
  local uPlayerController = uPlayerState:GetOwner()
  if not slua.isValid(uPlayerController) then
    return false
  end
  return uPlayerController.FakePlayerBornType == 0
end
function CreativeModeUtility:IsActivePlayer(uPlayerState, bContainPureSpectator)
  if not slua.isValid(uPlayerState) then
    return false
  end
  local bIsPureSpectator = self:IsPureSpectatorByPlayerState(uPlayerState)
  if bContainPureSpectator ~= true and bIsPureSpectator then
    return false
  end
  if bIsPureSpectator == true then
    return true
  end
  if uPlayerState.UID == nil or uPlayerState.UID <= 0 then
    return false
  end
  if uPlayerState.TeamID == nil or 0 >= uPlayerState.TeamID then
    return false
  end
  return true
end
function CreativeModeUtility:IsActivePlayerByCtrl(uPlayerCtrl, bContainPureSpectator)
  if not slua.isValid(uPlayerCtrl) then
    return false
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerState = GameplayData.GetPlayerState(uPlayerCtrl.PlayerKey)
  if not slua.isValid(uPlayerState) then
    uPlayerState = uPlayerCtrl.PlayerState
  end
  return self:IsActivePlayer(uPlayerState, bContainPureSpectator)
end
function CreativeModeUtility:IsPureSpectatorByPlayerState(uPlayerState)
  if not slua.isValid(uPlayerState) then
    return false
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerCtrl = GameplayData.GetPlayerController(uPlayerState.PlayerKey)
  if not slua.isValid(uPlayerCtrl) then
    uPlayerCtrl = uPlayerState.Owner
  end
  if slua.isValid(uPlayerCtrl) and uPlayerCtrl.IsPureSpectator then
    return uPlayerCtrl:IsPureSpectator()
  end
  return false
end
function CreativeModeUtility:GetCurFrameCounter()
  return UCreativeModeBlueprintLibrary.GetCurFrameCounter()
end
function CreativeModeUtility:GetPlayerPawn(PlayerKey)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerCharacter = GameplayData.GetPlayerCharacter(PlayerKey)
  if not PlayerCharacter then
    return Game:GetPlayerByPlayerKey(PlayerKey)
  end
  return PlayerCharacter
end
function CreativeModeUtility:GetPlayerCtrl(PlayerKey)
  local Pawn = Game:GetPlayerByPlayerKey(PlayerKey)
  if slua.isValid(Pawn) then
    local Ctrl = Pawn:GetController()
    if Game:IsAIController(Ctrl) then
      return Ctrl
    end
  end
end
function CreativeModeUtility:IsSimpleEditMode()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local SelfPlayerState = GameplayData.GetPlayerState()
  local bUseSimpleEditMode = true
  if SelfPlayerState and slua.isValid(SelfPlayerState) then
    bUseSimpleEditMode = SelfPlayerState and SelfPlayerState.PlayerPersonalSettingFeature and SelfPlayerState.PlayerPersonalSettingFeature:GetPersonalPropertyValue("bUseSimpleEditMode")
  end
  return bUseSimpleEditMode
end
function CreativeModeUtility:CanOpenFunctionVS()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local SelfPlayerState = GameplayData.GetPlayerState()
  if not SelfPlayerState then
    print(bWriteLog and "CreativeModeUtility:CanOpenFunctionVS - PlayerState is nil")
    return false
  end
  if not SelfPlayerState.PlayerPersonalSettingFeature then
    print(bWriteLog and "CreativeModeUtility:CanOpenFunctionVS - PlayerPersonalSettingFeature is nil")
    return false
  end
  local bUseSimpleEditMode = SelfPlayerState.PlayerPersonalSettingFeature:GetPersonalPropertyValue("bUseSimpleEditMode")
  local bCanOpenFunctionVS = SelfPlayerState.PlayerPersonalSettingFeature:GetPersonalPropertyValue("bOpenFunctionVS")
  print(bWriteLog and string.format("CreativeModeUtility:CanOpenFunctionVS - bCanOpenFunctionVS=%s, bUseSimpleEditMode=%s, result=%s", tostring(bCanOpenFunctionVS), tostring(bUseSimpleEditMode), tostring(bCanOpenFunctionVS and not bUseSimpleEditMode)))
  return bCanOpenFunctionVS and not bUseSimpleEditMode
end
function CreativeModeUtility:GetJumpURL(WebId)
  print(bWriteLog and "CreativeModeUtility:GetJumpURL WebId:" .. tostring(WebId))
  local RetWebURL = ""
  local GuideAnchorWebConfig = CDataTable.GetTableData("UGCCreationGuideAnchorWebConfig", WebId)
  if GuideAnchorWebConfig then
    if Client.GetIMSDKEnv() ~= 1 then
      RetWebURL = GuideAnchorWebConfig.TestWebURL
    end
    if not RetWebURL or RetWebURL == "" then
      RetWebURL = GuideAnchorWebConfig.WebURL
    end
    local language = "lan_" .. Client.GetCurrentLanguage()
    local WebURLLocalize = GuideAnchorWebConfig[language]
    if WebURLLocalize ~= nil and WebURLLocalize ~= "" then
      if WebURLLocalize == "-1" then
        RetWebURL = nil
      else
        RetWebURL = WebURLLocalize
      end
    end
  else
    print(bWriteLog and "CreativeModeUtility:GetJumpURL GuideAnchorWebConfig is nil")
  end
  if RetWebURL == nil or RetWebURL == "NULL" or RetWebURL == "" then
    return ""
  end
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  local UrlWithParam = webModule:AddParameterByPersonalInfo(RetWebURL, true, true)
  local FinalUrl = UrlWithParam
  print(bWriteLog and "FinalUrl: " .. FinalUrl)
  return FinalUrl
end
function CreativeModeUtility:IsLocalBoot()
  if Client then
    if not Client.IsDevelopment() then
      return false
    end
    local uid = DataMgr.roleData.uid
    return uid == ""
  else
    return _G.IsEditor
  end
  return false
end
function CreativeModeUtility:SetCreativeObjectStaticMeshMaterials(StaticMeshComponent, Materials)
  if not slua.isValid(StaticMeshComponent) then
    return
  end
  if Materials == nil then
    return
  end
  local AssetManager = GetAssetManager()
  if AssetManager == nil then
    return
  end
  for Index, MaterialPath in pairs(Materials) do
    local DynamicMaterial
    if type(MaterialPath) == "number" then
      local MaterialID = MaterialPath
      if 0 < MaterialID then
        DynamicMaterial = AssetManager:GetOrLoadMaterialInstance(MaterialID)
      end
    else
      DynamicMaterial = AssetManager:GetMaterialInstanceByPath(MaterialPath)
    end
    if DynamicMaterial ~= nil then
      StaticMeshComponent:SetMaterial(Index - 1, DynamicMaterial)
    end
  end
end
function CreativeModeUtility:RecordLastGiveItemReason(Reason)
  self.GiveItemend
function CreativeModeUtility:GetLastGiveItemReason()
  return self.GiveItemReason or CreativeGlobalDefine.AssignItemReason.Nil
end
function CreativeModeUtility:ClearItemReason()
  self.GiveItemReason = nil
end
function CreativeModeUtility:ClearAllItemByCtrl(uPlayerCtrl)
  if not slua.isValid(uPlayerCtrl) then
    printf("CreativeModeUtility:ClearAllItemByCtrl uPlayerCtrl is invalid ")
    return
  end
  local itemTypsList = slua.Array(UEnums.EPropertyClass.Int)
  itemTypsList:Add(1)
  itemTypsList:Add(2)
  itemTypsList:Add(3)
  itemTypsList:Add(5)
  itemTypsList:Add(6)
  itemTypsList:Add(12)
  itemTypsList:Add(42)
  uPlayerCtrl:ForceDropItemsWithTypeList(itemTypsList)
end
function CreativeModeUtility:GiveItemWithReason(IssueFunc, Reason)
  if IssueFunc and type(IssueFunc) == "function" then
    xpcall(function()
      local LastReason = self:GetLastGiveItemReason()
      self:RecordLastGiveItemReason(Reason)
      IssueFunc()
      self:RecordLastGiveItemReason(LastReason)
    end, function()
      print(bWriteLog and "CreativeModeUtility:GiveItemWithReason Failed")
    end)
  end
end
local Cached_Vec = FVector(0, 0, 0)
local ECollisionChannel = import("ECollisionChannel")
function CreativeModeUtility:TraceToGround(Start)
  Cached_Vec.X = Start.X
  Cached_Vec.Y = Start.Y
  Cached_Vec.Z = Start.Z - 200
  local bHit, HitResult = UKismetSystemLibrary.LineTraceSingle(CGameState, Start, Start, ECollisionChannel.ECC_WorldStatic, true, nil, 0, nil, true, FLinearColor.Red, FLinearColor.Green, 0.0)
  if bHit then
    return HitResult.Location
  end
  return Start
end
local _TriggerMsgBody = {
  TriggerPlayerUID = "-1",
  TriggerPlayerKey = -1,
  TriggerTeamID = -1
}
function CreativeModeUtility:NewTriggerMsgBody()
  local TableUtil = require("common.table_util")
  local newTriggerMsgBody = TableUtil.CopyTable(_TriggerMsgBody)
  return newTriggerMsgBody
end
function CreativeModeUtility:GetTriggerMsgBodyDefine()
  return _TriggerMsgBody
end
function CreativeModeUtility:GetClientPlayerState()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    if uPlayerController:IsObserver() then
      return nil
    end
    local uPlayerState = uPlayerController.PlayerState
    if slua.isValid(uPlayerState) then
      return uPlayerState
    end
  end
end
function CreativeModeUtility:AddItemToPlayer(PlayerKey, ItemID, ItemNum, ItemNumMin, ItemNumMax)
  printf("CreativeModeUtility:AddItemToPlayer PlayerKey, ItemID, ItemNum = %s %s %s", PlayerKey, ItemID, ItemNum)
  ItemNumMin = ItemNumMin or 1
  ItemNumMax = ItemNumMax or 999
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerCharacter = GameplayData.GetPlayerCharacter(PlayerKey)
  if slua.isValid(PlayerCharacter) then
    if PlayerCharacter:IsOnVehicle() then
      printf("CreativeModeUtility:AddItemToPlayer PlayerCharacter IsOnVehicle")
      return
    end
    local PlayerController = PlayerCharacter:GetController()
    if slua.isValid(PlayerController) then
      local ESpectatorReplayFlag = import("ESpectatorReplayFlag")
      if PlayerController:HasAnySpectatorReplayFlag(ESpectatorReplayFlag.ESpectatorReplayFlag_Spectator | ESpectatorReplayFlag.ESpectatorReplayFlag_Replay) then
        return
      end
    end
    local ItemCfg = CDataTable.GetTableData("Item", ItemID)
    if not ItemCfg then
      printf("CreativeModeUtility:AddItemToPlayer ItemCfg invalid")
      return
    end
    local CustomItemsSubsystem = SubsystemMgr:Get("CreativeCustomItemsSubsystem")
    if not CustomItemsSubsystem:IsValidItemID(ItemID) then
      print(bWriteLog and "CreativeModeUtility:AddItemToPlayer Fail to check")
      return
    end
    if ItemCfg.ItemType == 1 or ItemCfg.ItemType == 5 then
      ItemNum = 1
    end
    if ItemNumMin > ItemNum then
      ItemNum = ItemNumMin
      printf("CreativeModeUtility:AddItemToPlayer ItemNum invalid")
    end
    if ItemNumMax < ItemNum then
      ItemNum = ItemNumMax
      printf("CreativeModeUtility:AddItemToPlayer ItemNum invalid")
    end
    local bAutoEquip = ItemCfg.ItemType == 2 or ItemCfg.ItemType == 10 and ItemCfg.ItemSubType ~= 1004
    Game:AddItemByResID(PlayerCharacter, ItemID, ItemNum, nil, nil, nil, nil, bAutoEquip)
  end
end
function CreativeModeUtility:GetEventName(InstanceID, EventKey, branchkey)
  local CreativeModeUIUtils = require("GameLua.Mod.CreativeBase.Client.CreativeModeUIUtils")
  local CreativeModeCustomObjectNameUtil = require("GameLua.Mod.CreativeBase.Gameplay.Common.CreativeModeCustomObjectName.CreativeModeCustomObjectNameUtil")
  local SignalConfig = CreativeSignalMgr:GetObjectSignalConfig(InstanceID)
  if SignalConfig and SignalConfig.Event and SignalConfig.Event[EventKey] then
    local ObjectName = CreativeModeCustomObjectNameUtil.GetInstanceName(InstanceID) or ""
    local actionName = CreativeModeUIUtils.GetEventTitle(SignalConfig.Event[EventKey], branchkey) or ""
    return ObjectName .. " - " .. actionName
  end
  return ""
end
function CreativeModeUtility:GetBindEventName(EventConfig)
  local EventInstanceId = EventConfig.InstanceID
  local EventKey = EventConfig.EventName
  local SignalName = EventConfig.SignalName
  local branchkey = EventConfig.BranchKey
  if EventInstanceId == "" and EventKey == "" and SignalName == "" then
    return LocUtil.GetLocalizeResStr(8880552)
  end
  if EventInstanceId and EventInstanceId ~= "" then
    return self:GetEventName(EventInstanceId, EventKey, branchkey)
  else
    return SignalName
  end
  return LocUtil.GetLocalizeResStr(8880552)
end
function CreativeModeUtility:RefreshRewardItemUIByConfig(UICtrl, Widget, RewardConfig)
  local CreativeGameTaskConfig = require("GameLua.Mod.CreativeBase.Gameplay.GameTask.CreativeGameTaskConfig")
  local Widget = Widget or UICtrl.UIRoot
  local ItemId = tonumber(RewardConfig.RewardData) or 0
  local ItemCnt = tonumber(RewardConfig.RewardNum) or 0
  local CreativeCustomItemsSubsystem = SubsystemMgr:Get("CreativeCustomItemsSubsystem")
  if not CreativeCustomItemsSubsystem:IsValidItemID(ItemId) then
    print(bWriteLog and "CreativeModeUtility:RefreshRewardItemUIByConfig Fail to check")
    ItemId = 0
  end
  local ItemConfig = {}
  ItemConfig = CDataTable.GetTableData("Item", ItemId)
  local SetTextureFunc = function(Icon, Path, Param)
    if UICtrl.SetTexture then
      UICtrl:SetTexture(Icon, Path, Param)
    else
      local Util = require("client.slua_ui_framework.util")
      Util.SetTexture(Icon, Path, Param)
    end
  end
  if RewardConfig.ItemID == 0 or ItemId == 0 or ItemConfig == nil then
    if Widget.Image_Icon then
      Widget.Image_Icon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if Widget.NonePanel then
      Widget.NonePanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
    local UIUtil = require("client.common.ui_util")
    SetTextureFunc(Widget.Image_Quality, UIUtil.GetBgQualityPath(1))
  else
    local iconWidget = Widget.Image_Icon or Widget.Image_Picture
    if iconWidget then
      iconWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      if RewardConfig.RewardType == CreativeGameTaskConfig.Enum_TaskRewardType.Item and ItemConfig then
        SetTextureFunc(iconWidget, ItemConfig.ItemSmallIcon, {sync = false})
        local UIUtil = require("client.common.ui_util")
        SetTextureFunc(Widget.Image_Quality, UIUtil.GetBgQualityPath(ItemConfig and ItemConfig.ItemQuality or 1))
      end
      if RewardConfig.RewardType == CreativeGameTaskConfig.Enum_TaskRewardType.Custom then
        local IconPath
        local CreativeModeSelectorIconConfig = require("GameLua.Mod.CreativeBase.Gameplay.Config.CreativeModeSelectorIconConfig")
        IconPath = CreativeModeSelectorIconConfig.GetTexturePathById(RewardConfig.CustomIcon)
        SetTextureFunc(iconWidget, IconPath, {sync = false})
        local UIUtil = require("client.common.ui_util")
        SetTextureFunc(Widget.Image_Quality, UIUtil.GetBgQualityPath(1))
      end
    end
    if Widget.NonePanel then
      Widget.NonePanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  if Widget.Image_Select then
    Widget.Image_Select:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if RewardConfig.RewardType == CreativeGameTaskConfig.Enum_TaskRewardType.Item then
    if ItemCnt and 0 < ItemCnt then
      if Widget.TextBlock_Cnt then
        Widget.TextBlock_Cnt:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        Widget.TextBlock_Cnt:SetText(ItemCnt)
      end
    elseif Widget.TextBlock_Cnt then
      Widget.TextBlock_Cnt:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  elseif Widget.TextBlock_Cnt then
    Widget.TextBlock_Cnt:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function CreativeModeUtility:GetRewardItemNameByConfig(RewardConfig)
  local CreativeGameTaskConfig = require("GameLua.Mod.CreativeBase.Gameplay.GameTask.CreativeGameTaskConfig")
  local ItemId = tonumber(RewardConfig.RewardData)
  local ItemConfig = CDataTable.GetTableData("Item", ItemId)
  local ItemType = RewardConfig.RewardType
  local CreativeCustomItemsSubsystem = SubsystemMgr:Get("CreativeCustomItemsSubsystem")
  if not CreativeCustomItemsSubsystem:IsValidItemID(ItemId) then
    print(bWriteLog and "CreativeModeUtility:GetRewardItemNameByConfig Fail to check")
    return ""
  end
  local Ret = ""
  if ItemType == CreativeGameTaskConfig.Enum_TaskRewardType.Item then
    Ret = ItemConfig and ItemConfig.ItemName or ""
  end
  if ItemType == CreativeGameTaskConfig.Enum_TaskRewardType.Custom then
    Ret = RewardConfig.CustomName
  end
  if Ret == "" then
    return LocUtil.GetLocalizeResStr(8888610)
  end
  return Ret
end
function CreativeModeUtility:GetRewardItemDescByConfig(RewardConfig)
  local CreativeGameTaskConfig = require("GameLua.Mod.CreativeBase.Gameplay.GameTask.CreativeGameTaskConfig")
  local ItemId = tonumber(RewardConfig.RewardData)
  local ItemConfig = CDataTable.GetTableData("Item", ItemId)
  local ItemType = RewardConfig.RewardType
  if ItemType == CreativeGameTaskConfig.Enum_TaskRewardType.Item then
    return ItemConfig and ItemConfig.ItemDesc or ""
  end
  if ItemType == CreativeGameTaskConfig.Enum_TaskRewardType.Custom then
    return RewardConfig.CustomDescription
  end
  return ""
end
local STATIC_FUNCCALL_NUM = 0
local C_MAX_FUNCCALL_NUM = 999999
function CreativeModeUtility:ExecuateBindFunction(BindFunctionConfig, Reason, PlayerKey)
  printf(bWriteLog and "CreativeModeUtility:ExecuateBindFunction Reason: " .. tostring(Reason))
  if BindFunctionConfig == nil then
    printf(bWriteLog and "CreativeModeUtility:ExecuateBindFunction BindFunctionConfig is nil")
    return
  end
  if BindFunctionConfig.InstanceID == nil or BindFunctionConfig.SignalName == nil then
    printf(bWriteLog and "CreativeModeUtility:ExecuateBindFunction BindFunctionConfig.InstanceID or BindFunctionConfig.SignalName is nil")
    return
  end
  log_tree("CreativeModeUtility:ExecuateBindFunction BindFunctionConfig", BindFunctionConfig)
  STATIC_FUNCCALL_NUM = STATIC_FUNCCALL_NUM + 1
  if C_MAX_FUNCCALL_NUM <= STATIC_FUNCCALL_NUM then
    printf(bWriteLog and "CreativeModeUtility:ExecuateBindFunction C_MAX_FUNCCALL_NUM <= STATIC_FUNCCALL_NUM")
    return
  end
  if BindFunctionConfig.SignalName and BindFunctionConfig.SignalName ~= "" then
    local UCreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
    local SignalNameMd5 = UCreativeModeBlueprintLibrary.GetCustomEventHashString(BindFunctionConfig.SignalName, false)
    printf(bWriteLog and "CreativeModeUtility:ExecuateBindFunction PrevStageConfig.BindAction.SignalNameMd5: " .. SignalNameMd5)
    EventSystem:postEvent(EVENTTYPE_CREATIVE, EVENTID_CUSTOM_EVENT, SignalNameMd5, PlayerKey)
  elseif BindFunctionConfig.InstanceID and BindFunctionConfig.InstanceID ~= "" then
    local Msg = self:NewTriggerMsgBody()
    local uPlayerState = Game:GetPlayerStateByPlayerKey(PlayerKey)
    if uPlayerState then
      Msg.TriggerPlayerUID = uPlayerState.PlayerUID
      Msg.TriggerTeamID = uPlayerState.TeamID
    end
    Msg.TriggerPlayerKey = PlayerKey or 0
    CreativeSignalMgr:CallSignalObjectFunctionByFunctionIndex(BindFunctionConfig.InstanceID, BindFunctionConfig.FunctionIndex, Msg)
  end
end
function CreativeModeUtility:IsAssetNeedPreload()
  if Client then
    local so_version = Client.GetAndroidSOVersion()
    if so_version and so_version == 32 or HDmpveRemote.HDmpveRemoteConfigGetBool("UGCForbidAssetPreload", false) then
      return false
    end
  end
  return true
end
function CreativeModeUtility:SwitchSceneCaptureRenderingForceLDR(bOpen)
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client and Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    local STExtraGameInstance = import("STExtraGameInstance")
    local GameInstance = STExtraGameInstance.GetInstance()
    if GameInstance then
      GameInstance:ExecuteCMD("r.Mobile.SceneCaptureRenderingForceLDR", bOpen and 1 or 0)
    end
  end
end
function CreativeModeUtility:RuntimeIssueReward(RewardConfig, PlayerKey, Reason)
  if not RewardConfig then
    return
  end
  local CreativeGameTaskConfig = require("GameLua.Mod.CreativeBase.Gameplay.GameTask.CreativeGameTaskConfig")
  if RewardConfig.RewardType == CreativeGameTaskConfig.Enum_TaskRewardType.Item then
    local ItemId = tonumber(RewardConfig.RewardData)
    local ItemNum = RewardConfig.RewardNum
    if ItemId and ItemNum and 0 < ItemNum then
      self:AddItemToPlayer(PlayerKey, ItemId, ItemNum)
    end
  end
  if RewardConfig.RewardType == CreativeGameTaskConfig.Enum_TaskRewardType.Custom then
    self:ExecuateBindFunction(RewardConfig.CustomEvent, Reason or "", PlayerKey)
  end
end
function CreativeModeUtility:IsPositionInNavmeshVolume(Position)
  local ANavMeshBoundsVolume = import("NavMeshBoundsVolume")
  local Actor_C = import("/Script/Engine.Actor")
  local GameplayStatics = import("GameplayStatics")
  local actors = GameplayStatics.GetAllActorsOfClass(CGameWorld, ANavMeshBoundsVolume, slua.Array(UEnums.EPropertyClass.Object, Actor_C))
  for _, actor in pairs(actors) do
    if UCreativeModeBlueprintLibrary.IsPointInVolume and UCreativeModeBlueprintLibrary.IsPointInVolume(actor, Position) then
      return true
    end
  end
  return false
end
function CreativeModeUtility:GetSubModeOverrideConfigByKey(OverrideKey)
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local CreativeSubModeOverrideConfig = GamePlayTools.GetCurrentConfig("CreativeSubModeOverrideConfig")
  if CreativeSubModeOverrideConfig == nil then
    return nil
  end
  return CreativeModeUtility:GetValueByKey(CreativeSubModeOverrideConfig, OverrideKey)
end
function CreativeModeUtility:IsShipping()
  if _bCacheIsShipping ~= nil then
    return _bCacheIsShipping
  end
  local bIsShipping = true
  local STExtraGameplayStatics = import("STExtraGameplayStatics")
  if STExtraGameplayStatics then
    bIsShipping = STExtraGameplayStatics.IsShipping()
  end
  _bCacheIsShipping = bIsShipping == true
  return _bCacheIsShipping
end
function CreativeModeUtility:GetPlayerStateByUID(PlayerUID)
  local n  if type(PlayerUID) == "string" then
    nPlayerUID = tonumber(PlayerUID)
  end
  if slua.isValid(CGameMode) and CGameMode.GetPlayerKeyByUID then
    local PlayerKey = CGameMode:GetPlayerKeyByUID(nPlayerUID)
    if PlayerKey ~= 0 then
      local GameplayData = require("GameLua.GameCore.Data.GameplayData")
      local uPlayerState = GameplayData.GetPlayerState(PlayerKey)
      if slua.isValid(uPlayerState) then
        return uPlayerState
      end
    end
  end
  return Game:GetPlayerStateByUID(nPlayerUID)
end
return CreativeModeUtility