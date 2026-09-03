local death_play_lua_interface = {}
local replay_macro = require("client.slua.logic.replay.replay_macro")
local DeathPlayType = replay_macro.DeathPlayType
local DeathErrorCode = replay_macro.DeathErrorCode
local DeathPlaybackInstance
function death_play_lua_interface.InitDeathPlaybackInstance()
  local bRet = slua.isValid(DeathPlaybackInstance)
  if bRet == false then
    local UIUtil = require("client.common.ui_util")
    local GameInstance = UIUtil.GetGameInstance()
    if slua.isValid(GameInstance) and GameInstance.GetDeathPlayback ~= nil then
      DeathPlaybackInstance = GameInstance:GetDeathPlayback()
      bRet = slua.isValid(DeathPlaybackInstance)
    end
  end
  if bRet == false then
    log(bWriteLog and "InitDeathPlaybackInstance error")
  end
  return bRet
end
function death_play_lua_interface.RealPlayReplayFile(path, playType, subMode, index)
  playType = playType or DeathPlayType.FromLobby
  if not death_play_lua_interface.InitDeathPlaybackInstance() then
    return false
  end
  local bRet = false
  if death_play_lua_interface.InitDeathPlaybackInstance() then
    if playType == replay_macro.DeathPlayType.FromLobby then
      local errorCode = DeathPlaybackInstance:AnalyzeReplayFile(path)
      if errorCode == DeathErrorCode.None then
        local UIUtil = require("client.common.ui_util")
        local GameInstance = UIUtil.GetGameInstance()
        log(bWriteLog and "NetUtil.MountPakOfMode subMode is" .. tostring(subMode))
        NetUtil.MountPakOfMode(subMode)
        if index then
          bRet = DeathPlaybackInstance:PlayReplayFileInHistory(path, index, false)
        else
          bRet = DeathPlaybackInstance:PlayReplayFile(path, false)
        end
        print(bWriteLog and "RealPlayReplayFile DeathPlaybackInstance", GameInstance, DeathPlaybackInstance, DeathPlaybackInstance.DeathPlayType, bRet)
      else
        death_play_lua_interface.ShowErrorTips(errorCode)
        log(bWriteLog and "RealPlayReplayFile errorCode " .. tostring(errorCode))
      end
    else
      log(bWriteLog and "error playType is " .. tostring(playType))
    end
  else
    log(bWriteLog and "InitDeathPlaybackInstance error")
  end
  if bRet then
  else
  end
  log(bWriteLog and "bRet" .. tostring(bRet))
  return bRet
end
function death_play_lua_interface.ShowErrorTips()
  ShowNotice(25719)
end
function death_play_lua_interface.GetJsonFromInfo(filepath)
  local bRet = false
  if not death_play_lua_interface.InitDeathPlaybackInstance() then
    return
  end
  local data = DeathPlaybackInstance:AnalyzeInfoFile(filepath)
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
      DeathTime = v.DeathTime
    }
  end
  jsonTbl.TypeInfoArray = infoArray
  local AdditionData
  if data.AdditionData then
    AdditionData = {}
    for k, v in pairs(data.AdditionData) do
      AdditionData[k] = v
    end
  end
  jsonTbl.  log_tree(bWriteLog and "death GetJsonFromInfo", jsonTbl)
  return jsonTbl
end
function death_play_lua_interface.GetNewestDeathFileName()
  local UIUtil = require("client.common.ui_util")
  local GameInstance = UIUtil.GetGameInstance()
  if slua.isValid(GameInstance) and GameInstance.GetClientInGameReplay ~= nil then
    local ClientInGameReplayInstance = GameInstance:GetClientInGameReplay()
    if slua.isValid(ClientInGameReplayInstance) and ClientInGameReplayInstance.GetCompressedDeathFileName then
      local filename = ClientInGameReplayInstance:GetCompressedDeathFileName()
      log(bWriteLog and "[yuanwu] filename before is " .. tostring(filename))
      filename = string.gsub(filename, ".*/", "")
      if filename == "" then
        log(bWriteLog and "[yuanwu] filename is empty string")
      end
      log(bWriteLog and "[yuanwu] filename is " .. tostring(filename))
      return filename
    end
  end
  log(bWriteLog and "[yuanwu] GetCompressedDeathFileName is nil")
  return ""
end
function death_play_lua_interface.SetEnableDeathPlayback(bEnable)
  log(bWriteLog and "SetEnableDeathPlayback" .. tostring(bEnable))
  local UIUtil = require("client.common.ui_util")
  local GameInstance = UIUtil.GetGameInstance()
  if slua.isValid(GameInstance) and GameInstance.GetClientInGameReplay ~= nil then
    local ClientInGameReplayInstance = GameInstance:GetClientInGameReplay()
    if slua.isValid(ClientInGameReplayInstance) and ClientInGameReplayInstance.EnableDeathPlayback then
      ClientInGameReplayInstance:EnableDeathPlayback(bEnable)
    end
  end
end
function death_play_lua_interface.StopReplay()
  if not death_play_lua_interface.InitDeathPlaybackInstance() then
    return
  end
  local isReplay = DeathPlaybackInstance:IsInPlayState()
  if isReplay then
    log(bWriteLog and "[v_wllwu] DeathPlaybackInstance.StopReplay()")
    DeathPlaybackInstance:StopPlay()
  end
end
return death_play_lua_interface