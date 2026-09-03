local wonderful_play_lua_interface = {}
local replay_macro = require("client.slua.logic.replay.replay_macro")
local WonderfulPlayType = replay_macro.WonderfulPlayType
local WonderFulErrorCode = replay_macro.WonderFulErrorCode
local WonderfulPlaybackInstance
function wonderful_play_lua_interface.InitWonderfulPlaybackInstance()
  local bRet = slua.isValid(WonderfulPlaybackInstance)
  if bRet == false then
    local UIUtil = require("client.common.ui_util")
    local GameInstance = UIUtil.GetGameInstance()
    if slua.isValid(GameInstance) and GameInstance.GetWonderfulPlayback ~= nil then
      WonderfulPlaybackInstance = GameInstance:GetWonderfulPlayback()
      bRet = slua.isValid(WonderfulPlaybackInstance)
    end
  end
  if bRet == false then
    log(bWriteLog and "InitWonderfulPlaybackInstance error")
  end
  return bRet
end
function wonderful_play_lua_interface.RealPlayReplayFile(path, playType, subMode, index)
  playType = playType or WonderfulPlayType.FromLobby
  if not wonderful_play_lua_interface.InitWonderfulPlaybackInstance() then
    return false
  end
  local bRet = false
  if wonderful_play_lua_interface.InitWonderfulPlaybackInstance() then
    if playType == replay_macro.WonderfulPlayType.FromLobby then
      local errorCode = WonderfulPlaybackInstance:AnalyzeReplayFile(path)
      if errorCode == WonderFulErrorCode.None then
        local UIUtil = require("client.common.ui_util")
        local GameInstance = UIUtil.GetGameInstance()
        log(bWriteLog and "NetUtil.MountPakOfMode subMode is" .. tostring(subMode))
        NetUtil.MountPakOfMode(subMode)
        WonderfulPlaybackInstance:PreSetPeriodIndex(index and index - 1 or 0)
        bRet = WonderfulPlaybackInstance:PlayReplayFile(path)
        print(bWriteLog and "RealPlayReplayFile WonderfulPlaybackInstance", GameInstance, WonderfulPlaybackInstance, WonderfulPlaybackInstance.WonderfulPlayType, bRet)
      else
        wonderful_play_lua_interface.ShowErrorTips(errorCode)
        log(bWriteLog and "RealPlayReplayFile errorCode " .. tostring(errorCode))
      end
    else
      log(bWriteLog and "error playType is " .. tostring(playType))
    end
  else
    log(bWriteLog and "InitWonderfulPlaybackInstance error")
  end
  if bRet then
  else
  end
  log(bWriteLog and "bRet" .. tostring(bRet))
  return bRet
end
function wonderful_play_lua_interface.ShowErrorTips()
  ShowNotice(25719)
end
function wonderful_play_lua_interface.GetJsonFromInfo(filepath)
  local bRet = false
  if not wonderful_play_lua_interface.InitWonderfulPlaybackInstance() then
    return
  end
  local ScriptHelperClient = import("ScriptHelperClient")
  local dataFullArray = ScriptHelperClient.LoadFileToArrayByFullPath(filepath)
  print(bWriteLog and "GetJsonFromInfo", filepath, type(dataFullArray))
  if not dataFullArray or dataFullArray == "" then
    print(bWriteLog and "GetJsonFromInfo Error, file empty", filepath)
    local utility = require("common.utility")
    xpcall(function()
      Client.DeleteFile(filepath)
      local ReplayFilePath = filepath:gsub("%.info$", ".replay")
      print(bWriteLog and "GetJsonFromInfo Error, replay", ReplayFilePath, Client.IsFileExistByFileName(ReplayFilePath))
      Client.DeleteFile(ReplayFilePath)
    end, utility.ErrorMessageHandler)
    return
  end
  local data = WonderfulPlaybackInstance:AnalyzeInfoFile(filepath)
  if not data then
    print(bWriteLog and "GetJsonFromInfo Analysize Error", filepath)
    return
  end
  local jsonTbl = {}
  jsonTbl.UID = data.UID
  jsonTbl.GameID = data.GameID
  jsonTbl.SaveTimestamp = data.SaveTimestamp
  jsonTbl.ModeID = tonumber(data.ModeID) or 0
  jsonTbl.SegmentLevel = data.SegmentLevel or 0
  jsonTbl.TotalTime = data.TotalTime
  jsonTbl.AppVersion = data.AppVersion
  jsonTbl.SrcVersion = data.SrcVersion
  jsonTbl.ErrorCode = data.ErrorCode
  local infoArray = {}
  local additionArray = {}
  for k, v in pairs(data.TypeInfoArray) do
    additionArray = {}
    if v.AdditionalData ~= nil then
      for _, v1 in pairs(v.AdditionalData) do
        additionArray[#additionArray + 1] = v1
      end
    end
    infoArray[#infoArray + 1] = {
      WonderfulType = v.WondefulType,
      AdditionalData = additionArray
    }
  end
  jsonTbl.TypeInfoArray = infoArray
  local weseeArray
  if data.WeSeeInfoArray then
    weseeArray = {}
    for k, v in pairs(data.WeSeeInfoArray) do
      local weseeInfo = {
        StartTime = v.StartTime,
        EndTime = v.EndTime
      }
      table.insert(weseeArray, weseeInfo)
    end
  end
  jsonTbl.WeSeeInfoArray = weseeArray
  local AdditionData
  if data.AdditionData then
    AdditionData = {}
    for k, v in pairs(data.AdditionData) do
      AdditionData[k] = v
    end
  end
  jsonTbl.  log_tree(bWriteLog and "GetJsonFromInfo", jsonTbl)
  return jsonTbl
end
function wonderful_play_lua_interface.GetNewestWonderfulFileName()
  local UIUtil = require("client.common.ui_util")
  local GameInstance = UIUtil.GetGameInstance()
  if slua.isValid(GameInstance) and GameInstance.GetClientInGameReplay ~= nil then
    local ClientInGameReplayInstance = GameInstance:GetClientInGameReplay()
    if slua.isValid(ClientInGameReplayInstance) and ClientInGameReplayInstance.GetCompressedFileName then
      local filename = ClientInGameReplayInstance:GetCompressedFileName()
      log(bWriteLog and "[yuanwu] filename before is " .. tostring(filename))
      filename = string.gsub(filename, ".*/", "")
      if filename == "" then
        log(bWriteLog and "[yuanwu] filename is empty string")
      end
      log(bWriteLog and "[yuanwu] filename is " .. tostring(filename))
      return filename
    end
  end
  log(bWriteLog and "[yuanwu] GetNewestWonderfulFileName is nil")
  return ""
end
function wonderful_play_lua_interface.SetGWonderfulPlaybackSwitch(bSwitch)
  log(bWriteLog and "[yuanwu] SetGWonderfulPlaybackSwitch" .. tostring(bSwitch))
  local UIUtil = require("client.common.ui_util")
  local GameInstance = UIUtil.GetGameInstance()
  if slua.isValid(GameInstance) and GameInstance.GetClientInGameReplay ~= nil then
    local ClientInGameReplayInstance = GameInstance:GetClientInGameReplay()
    if slua.isValid(ClientInGameReplayInstance) and ClientInGameReplayInstance.SetGWonderfulPlaybackSwitch then
      ClientInGameReplayInstance:SetGWonderfulPlaybackSwitch(bSwitch)
    end
  end
end
function wonderful_play_lua_interface.StopReplay()
  if not wonderful_play_lua_interface.InitWonderfulPlaybackInstance() then
    return
  end
  local isReplay = WonderfulPlaybackInstance:IsInPlayState()
  if isReplay then
    log(bWriteLog and "[v_wllwu] WonderfulPlaybackInstance.StopReplay()")
    WonderfulPlaybackInstance:StopPlay()
  end
end
return wonderful_play_lua_interface