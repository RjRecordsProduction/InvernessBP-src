local NetManager = {
  isInit = false,
  sendPkgMap = {},
  waitPkgMap = {},
  selfSendQueueMap = {},
  hisSendPkgMap = {},
  ingameSaveMsgList = {},
  checkTimer = nil,
  mustArrivePkgMap = {},
  tCurrentClientTime = 0,
  isLogMsgAfterLogin = false,
  logMsgMap = {},
  bConnected = false,
  onSendUniqueLimitFunc = nil,
  bIsMuteMsgForReLogin = true,
  netTypeStr = "NULL",
  onTimeOutCallbackMap = {},
  isLock = false,
  tLockUIShowTamp = 0,
  OverloadProtect = false,
  checkRecoveryTimer = nil,
  checkRecoveryCD = 0,
  checkRecoveryTimes = 0,
  overloadTipsShowts = 0,
  nProtoHandleDelaySec = 0
}
local string_format = string.format
local table_remove = table.remove
local table_pack = table.pack
local table_unpack = table.unpack
local local local local local local local local local local local local local local local local local local local LobbyHandler
local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
local NetMacros, NetConfig, NetRsp2ID, table_pool, _net_tb_Pool, time_ticker, TimeUtil, TableUtil, GM_Util, PufferNetManager, NetErrorCode, gem_report_utils, ShareMgr, OverLoadMsgConfig
local _modInjectedMsgIds = {}
local _modInjectedRspNames = {}
local _modInjectedReconnectIds = {}
function NetManager.Init()
  NetManager.InitRequireFile()
  if not NetManager.isInit then
    NetConfig.Init()
    NetManager.isInit = true
    local PlanDLobbyNetMgr = require("GameLua.Mod.PlanDLobby.GamePlay.Net.PlanDLobbyNetMgr")
    PlanDLobbyNetMgr.OnEnterMod()
  end
  NetManager.ClearRegularMap()
  NetManager.onTimeOutCallbackMap = {}
  NetManager.unit_testing_table = {}
  NetManager.bConnected = false
  NetManager.onSendUniqueLimitFunc = nil
  if NetManager.checkTimer then
    time_ticker.RemoveTimer(NetManager.checkTimer)
    NetManager.checkTimer = nil
  end
  NetManager.checkTimer = time_ticker.AddTimerLoop(1, function()
    NetManager.checkTimeHandler()
  end, TIMER_INFINITE, 1)
  if IsEditor then
    NetMacros.CONST_MSG_DEFAULT_TIME_OUT_INTERVAL = 60
  end
  NetManager.isLock = false
end
function NetManager.InitRequireFile()
  local status
  status, NetConfig = pcall(require, "client.network.comm.NetConfig")
  status, NetRsp2ID = pcall(require, "client.network.comm.NetRsp2IndexConfig")
  status, NetMacros = pcall(require, "client.network.comm.NetMacros")
  status, time_ticker = pcall(require, "common.time_ticker")
  status, TimeUtil = pcall(require, "client.common.time_util")
  status, TableUtil = pcall(require, "common.table_util")
  status, PufferNetManager = pcall(require, "client.slua.logic.download.network.logic_puffer_netmanager")
  status, NetErrorCode = pcall(require, "client.network.comm.NetErrorCode")
  status, gem_report_utils = pcall(require, "client.logic.store.gem_report_utils")
  status, ShareMgr = pcall(require, "client.logic.share.share_logic")
  status, GM_Util = RequireBlackList("blacklist.unit_testing.gm_unit_test_util")
  status, OverLoadMsgConfig = pcall(require, "client.network.comm.OverLoadMsgConfig")
  status, table_pool = pcall(function()
    table_pool = require("common.table_pool")
    _net_tb_Pool = table_pool.Create()
  end)
end
function NetManager.ProcRespondMsg(msg, ...)
  log(bWriteLog and string.format("NetManager.ProcRespondMsg %s", msg))
  local id = NetRsp2ID[msg] and NetRsp2ID[msg].hashCode
  if not id then
    log_error(string_format("NetManager.ProcRespondMsg undefined msg: %s", msg))
    return
  end
  NetManager.OnRecvPkg(id, ...)
  if Client.IsShipping() then
    return
  end
  local NetDataPrinter = RequireBlackList("blacklist.netMsgDataPrinter.logic.NetDataPrinter")
  if NetDataPrinter then
    NetDataPrinter.OnRecvPkg(msg, ...)
  end
end
function NetManager.OnLogin()
  local roleData = LobbySystem.roleData
  if roleData.protocol_config_table and type(roleData.protocol_config_table) == "table" then
    for k, v in pairs(roleData.protocol_config_table) do
      if NetConfig.msgMap[k] then
        for kk, vv in pairs(v) do
          NetConfig.msgMap[k][kk] = vv
        end
      else
        NetConfig.msgMap[k] = v
      end
      if v.needReconnect and v.needReconnect == 1 then
        NetConfig.reconnectMsgMap[#NetConfig.reconnectMsgMap + 1] = k
      else
        for z = #NetConfig.reconnectMsgMap, 1, -1 do
          if NetConfig.reconnectMsgMap[z] == k then
            table_remove(NetConfig.reconnectMsgMap, z)
          end
        end
      end
    end
    log_tree("[CCL] netconfig reconnect ", NetConfig.reconnectMsgMap)
  end
end
function NetManager.RegisterTimeOutCallback(id, func)
  NetManager.onTimeOutCallbackMap[id] = func
end
local _GetMsgReqName = function(id)
  if id == nil then
    return "req_nil"
  end
  local info = NetConfig.msgMap[id]
  return info.req or ""
end
local _GetMsgRespName = function(id)
  if id == nil then
    return "resp_nil"
  end
  local info = NetConfig.msgMap[id]
  return info.res or ""
end
local _RecycleSendInfoList = function(sendInfoList)
  if not sendInfoList then
    return
  end
  for _, item in pairs(sendInfoList) do
    if type(item) == "table" and item.param then
      _net_tb_Pool:Recycle(item.param)
    end
  end
  _net_tb_Pool:RecycleAll(sendInfoList)
  _net_tb_Pool:Recycle(sendInfoList)
end
function NetManager.FindMsgInfo(id)
  if id == nil then
    return nil
  end
  return NetConfig.msgMap[id]
end
function NetManager.IsNeedReconnectMsg(id)
  if id == nil then
    return false
  end
  for k, v in pairs(NetConfig.reconnectMsgMap) do
    if v == id then
      return true
    end
  end
  return false
end
function NetManager.HasSendInfo(id)
  if id == nil then
    return false
  end
  local info = NetManager.sendPkgMap[id]
  if info then
    return true
  else
    return false
  end
end
function NetManager.AppendSendInfo(id, msgInfo, isWrapByHome, ...)
  if id == nil then
    return
  end
  if not msgInfo.res or msgInfo.res == "" then
    return
  end
  local info = NetManager.sendPkgMap[id]
  local tNow = TimeUtil.GetMiliseconds() / 1000
  local _sendInfo = _net_tb_Pool:Get()
  if not _sendInfo then
    return
  end
  _sendInfo.param = _net_tb_Pool:Get()
  if not _sendInfo.param then
    _net_tb_Pool:Recycle(_sendInfo)
    return
  end
  for index = 1, select("#", ...) do
    local v = select(index, ...)
    _sendInfo.param[index] = v
  end
  _sendInfo.t = tNow
  if info then
    info[#info + 1] = _sendInfo
  else
    info = _net_tb_Pool:Get()
    info[#info + 1] = _sendInfo
    NetManager.sendPkgMap[id] = info
  end
  if msgInfo.isLock then
    NetManager.waitPkgMap[id] = info
  end
  if msgInfo.needRsp and 1 <= msgInfo.needRsp and not NetManager.mustArrivePkgMap[id] then
    NetManager.mustArrivePkgMap[id] = {
      t = tNow,
      param = {
        ...
      },
      resend_times = msgInfo.needRsp,
          }
  end
end
function NetManager.RemoveFirstSendInfo(id, msgInfo)
  if id == nil then
    return
  end
  local info = NetManager.sendPkgMap[id]
  if info and type(info) == "table" then
    if #info <= 1 or msgInfo.req == "heart_beat" then
      _RecycleSendInfoList(NetManager.sendPkgMap[id])
      NetManager.sendPkgMap[id] = nil
    else
      local _item = info[1]
      _net_tb_Pool:Recycle(info[1].param)
      _net_tb_Pool:Recycle(_item)
      table_remove(info, 1)
    end
  end
  if msgInfo.isLock then
    info = NetManager.waitPkgMap[id]
    if info then
      if #info <= 1 then
        NetManager.waitPkgMap[id] = nil
      else
        table_remove(info, 1)
      end
    end
  end
end
function NetManager.RecordHisSendInfo(id, tNow)
  NetManager.hisSendPkgMap[id] = tNow
end
local blockList = {}
function NetManager.CheckWaitingUIShow(bForceShow)
  local bShow = false
  if bForceShow then
    bShow = true
  elseif next(NetManager.waitPkgMap) then
    bShow = true
    blockList = {}
    for k, v in pairs(NetManager.waitPkgMap) do
      blockList[#blockList + 1] = k
    end
  else
    bShow = false
  end
  if bShow then
    local isSocialIsland = MatchModeMgrSystem and MatchModeMgrSystem.IsSocialIslandMode(true)
    local bIsInHomeMod = PlanPH_GamePlay_Tools and PlanPH_GamePlay_Tools.IsPHomeMode()
    local bIsInCollectionHallMod = GameStatus.IsCollectionHallMode()
    local isFighting = GameStatus and GameStatus.IsInFightingNotMainCity and GameStatus.IsInFightingNotMainCity()
    local Util_UGC = require("client.slua.logic.ugc.util_ugc")
    if isFighting and not isSocialIsland and not Util_UGC.IsCreativeWow() and not bIsInHomeMod and not bIsInCollectionHallMod then
      return
    end
    logic_connection_waiting:Show(2)
    if NetManager.tLockUIShowTamp == 0 then
      NetManager.tLockUIShowTamp = NetManager.tCurrentClientTime
    end
  else
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    logic_connection_waiting:Hide(2)
    if NetManager.tLockUIShowTamp ~= 0 and NetManager.tCurrentClientTime - NetManager.tLockUIShowTamp > NetMacros.CONST_MSG_BLOCK_REPORT then
      for _, v in ipairs(blockList) do
        if login_module.commonSwitch and login_module.commonSwitch.RepLoadingTimeoutEnable and NetConfig.msgMap[v].req ~= "heart_beat" then
          LobbyHandler = LobbyHandler or require("client.network.Protocol.LobbyHandler")
          LobbyHandler.send_client_timeout_report_req(NetConfig.msgMap[v].req, NetManager.tCurrentClientTime - NetManager.tLockUIShowTamp)
        end
      end
    end
    NetManager.tLockUIShowTamp = 0
  end
end
function NetManager.CheckSelfQueueSendPkg(id, isWrapByHome, ...)
  local bHasSend = NetManager.HasSendInfo(id)
  if bHasSend == false then
    return false
  end
  local cachePkg = {}
  cachePkg.params = {
    ...
  }
  cachePkg.  if NetManager.selfSendQueueMap[id] then
    local temp = NetManager.selfSendQueueMap[id]
    temp[#temp + 1] = cachePkg
  else
    local tb = {}
    tb[#tb + 1] = cachePkg
    NetManager.selfSendQueueMap[id] = tb
  end
  return true
end
function NetManager.SendQueuePkg()
  for k, v in pairs(NetManager.selfSendQueueMap) do
    if not NetManager.HasSendInfo(k) then
      local pkg = v[1]
      if pkg then
        table_remove(v, 1)
        NetManager.SelfSendWithCache(k, v.isWrapByHome, table_unpack(pkg.params))
      end
    end
  end
end
function NetManager.SendPkg(id, ...)
  if not NetManager.isInit then
    NetManager.ErrorReport("Send Msg before NetManager Init.", id)
    return
  end
  local info = NetManager.FindMsgInfo(id)
  if info == nil or info.req == nil or info.req == "" then
    NetManager.ErrorReport("NetManager.SendPkg nil info id:" .. tostring(id), id)
    return
  end
  if NetManager.OverloadProtect and OverLoadMsgConfig[info.req] == nil then
    if GameStatus.IsInFightingNotMainCity() and TimeUtil.GetServerTimeInSec() > NetManager.overloadTipsShowts then
      ShowNotice(66412)
      NetManager.overloadTipsShowts = TimeUtil.GetServerTimeInSec() + 10
    end
    log(bWriteLog and string_format("[kkjhuang] NetManager.SendPkg, info.req:%s", info.req))
    return
  end
  if NetManager.bConnected == false and not info.needRsp then
    log_error(string_format("NetManager.SendPkg when net closed req = %s", _GetMsgReqName(id)))
    return
  end
  local isWrapByHome = id == 1828043943
  local result = NetManager.ApplyRules(id, isWrapByHome, ...)
  if NetMacros and result ~= NetMacros.NORMAL then
    return result
  end
  if GM_Util and GM_Util.HookNetPkg(id) then
    return
  end
  NetUtil.SendPkg(info.req, ...)
end
function NetManager.SelfSendWithCache(id, isWrapByHome, ...)
  local info = NetManager.FindMsgInfo(id)
  if info == nil or info.req == nil or info.req == "" then
    NetManager.ErrorReport("NetManager.SelfSendWithCache nil info id:" .. tostring(id), id)
    return
  end
  if isWrapByHome then
    NetManager.SendPkg(1828043943, info.req, ...)
  else
    NetManager.SendPkg(id, ...)
  end
end
function NetManager.GetIdByReq(req)
  if not req then
    return nil
  end
  local StringUtil = require("common.string_util")
  local rsp = StringUtil.StrReplace(req, "req", "rsp")
  return NetRsp2ID[rsp] and NetRsp2ID[rsp].hashCode
end
function NetManager.ApplyRules(id, isWrapByHome, ...)
  local sendParam = {
    ...
  }
  id = isWrapByHome and NetManager.GetIdByReq(sendParam[1]) or id
  local tNow = TimeUtil.GetMiliseconds() / 1000
  local tLastSend = NetManager.hisSendPkgMap[id] or 0
  local tSendInterval = tNow - tLastSend
  local info = NetManager.FindMsgInfo(id)
  if not info then
    log_error(string_format("NetManager.ApplyRules can't get info by id = %s, param = %s", id, sendParam[1]))
    return NetMacros.PRE_QUIT
  end
  if info.isUnique and info.isUnique == 1 then
    local bSameSendInfo = false
    local sendInfoArr = NetManager.sendPkgMap[id]
    if sendInfoArr then
      for _, v in pairs(sendInfoArr) do
        local sendParamOld = v.param
        if not (sendParam or sendParamOld) or TableUtil.IsDataEqual(sendParam, sendParamOld) then
          bSameSendInfo = true
          break
        end
      end
    end
    if bSameSendInfo then
      local _timeOutConfigInfo = info.timeout and 0 < info.timeout and info.timeout or NetMacros.CONST_MSG_DEFAULT_TIME_OUT_INTERVAL
      if tSendInterval > _timeOutConfigInfo then
        NetManager.ClearRecordById(id)
      else
        if NetManager.onSendUniqueLimitFunc then
          local func = NetManager.onSendUniqueLimitFunc
          if func then
            NetManager.onSendUniqueLimitFunc = nil
            func(id)
          end
        end
        return NetMacros.PRE_QUIT
      end
    end
  end
  if info.timeInterval and 0 < info.timeInterval and tSendInterval < info.timeInterval then
    log(bWriteLog and string_format("NetManager.SendPkg send too frequently, req = %s", _GetMsgReqName(id)))
    return NetMacros.ERROR_INCD
  end
  local bQueue = false
  if info.queueType and info.queueType == NetMacros.ENUM_QUEUE_TYPE.ONESELF then
    bQueue = NetManager.CheckSelfQueueSendPkg(id, isWrapByHome, ...)
  end
  if bQueue then
    return NetMacros.PRE_QUIT
  end
  if info.isLock then
    NetManager.CheckWaitingUIShow(true)
  end
  NetManager.AppendSendInfo(id, info, isWrapByHome, ...)
  NetManager.RecordHisSendInfo(id, tNow)
  return NetMacros.NORMAL
end
function NetManager.OnRecvPkg(id, ...)
  local info = NetManager.FindMsgInfo(id)
  if info == nil or info.handler == nil or info.handler == "" then
    NetManager.ErrorReport("NetManager.OnRecvPkg nil info msgid:" .. tostring(id), id)
    return
  end
  NetManager.RemoveFirstSendInfo(id, info)
  NetManager.CheckWaitingUIShow(false)
  if GM_Util then
    GM_Util.ConstructLuaFile(id, ...)
  end
  if NetManager.mustArrivePkgMap[id] then
    NetManager.mustArrivePkgMap[id] = nil
  end
  NetManager.SendQueuePkg()
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  if not GameStatus.IsInFightingNotMainCity() or Util_UGC.IsCreativeWow() or GameStatus.IsInLobbyOrSpecialFighting() then
    NetManager.ProcPkg2Handler(id, ...)
    PufferNetManager.OnNetRecvPkg()
  elseif LobbySystem and LobbySystem.CheckOpen(BP_ENUM_INGAME_NET_GRAY_SWITCH) and info.inGameOper then
    if info.inGameOper == NetMacros.ENUM_INGAME_OPERATE_TYPE.DELAY then
      NetManager.ingameSaveMsgList[#NetManager.ingameSaveMsgList + 1] = table_pack(id, ...)
    elseif info.inGameOper == NetMacros.ENUM_INGAME_OPERATE_TYPE.DROP then
    else
      NetManager.ProcPkg2Handler(id, ...)
    end
  elseif not info.inGameOper then
    NetManager.ingameSaveMsgList[#NetManager.ingameSaveMsgList + 1] = table_pack(id, ...)
  else
    NetManager.ProcPkg2Handler(id, ...)
  end
end
function NetManager.GetMsgHandlerByInfo(info)
  if not info or not info.handler then
    return
  end
  local handler
  if info.handlerBasePath and info.handlerBasePath ~= "" then
    handler = require(info.handlerBasePath .. "." .. info.handler)
  elseif info.modName and info.modName ~= "" then
    handler = RequireModDownload("GameLua.Mod.Lobby.Split." .. info.modName .. "." .. info.handler)
  else
    handler = require("client.network.Protocol." .. info.handler)
  end
  return handler
end
function NetManager.ProcPkg2Handler(id, ...)
  local info = NetManager.FindMsgInfo(id)
  if info == nil then
    return
  end
  local nErrorCode = select(1, ...)
  local handler = NetManager.GetMsgHandlerByInfo(info)
  if not handler or type(handler) ~= "table" then
    log_error(string_format("NetManager ProcPkg2Handler handler is nil, id:%s req:%s res:%s, modName:%s", id, info.req, info.res, tostring(info.modName)))
    return
  end
  local funcName = "on_" .. info.res
  if not NetErrorCode.IsHandlerLogic(info.res, nErrorCode) then
    return
  end
  if not handler[funcName] then
    NetManager.ErrorReport(string_format("NetManager FuncName not found:%s rsp:%s", funcName, _GetMsgRespName(id)), id)
    return
  end
  if not Client.IsShipping() and NetManager.nProtoHandleDelaySec > 0 then
    local args = table_pack(...)
    time_ticker.AddTimer(NetManager.nProtoHandleDelaySec, function()
      handler[funcName](table_unpack(args, 1, args.n))
    end)
    log(bWriteLog and string_format("NetManager ProcPkg2Handler delayed %.3fs: %s", NetManager.nProtoHandleDelaySec, funcName))
  else
    handler[funcName](...)
  end
end
function NetManager.SetProtoHandleDelay(nSec)
  NetManager.nProtoHandleDelaySec = tonumber(nSec) or 0
  log(string_format("NetManager.SetProtoHandleDelay: %.3fs", NetManager.nProtoHandleDelaySec))
end
function NetManager.GetProtoHandleDelay()
  return NetManager.nProtoHandleDelaySec
end
function NetManager.checkTimeHandler()
  if NetManager.OverloadProtect then
    return
  end
  local tNow = TimeUtil.GetMiliseconds() / 1000
  local bTimeOut = false
  local bKeyMsgTimeOut = false
  local keyMsgTimeOutId = 0
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local timeoutReq = 0
  for k, v in pairs(NetManager.sendPkgMap) do
    local id = k
    local msgCfg = NetManager.FindMsgInfo(id)
    if msgCfg then
      local bTimeOutForSingleKey = false
      for i = #v, 1, -1 do
        local vv = v[i]
        if type(vv) == "table" then
          local tSend = vv.t
          local timeout = msgCfg.timeout or NetMacros.CONST_MSG_DEFAULT_TIME_OUT_INTERVAL
          if tSend and timeout < tNow - tSend then
            bTimeOut = true
            bTimeOutForSingleKey = true
            timeoutReq = k
            log_error(string_format("NetManager timeout req: %s, sendTime: %s, curTime: %s, key: %s", msgCfg.req, vv.t, tNow, timeoutReq))
            _net_tb_Pool:Recycle(vv.param)
            _net_tb_Pool:Recycle(vv)
            table_remove(v, i)
            if login_module.commonSwitch and login_module.commonSwitch.RepLoadingTimeoutEnable and msgCfg.req ~= "heart_beat" then
              LobbyHandler = LobbyHandler or require("client.network.Protocol.LobbyHandler")
              LobbyHandler.send_client_timeout_report_req(msgCfg.req)
            end
            ProtoPromiseHookTool.RemovePromiseByTimeout(msgCfg.req)
          end
        end
      end
      if bTimeOutForSingleKey then
        if #v == 0 then
          _net_tb_Pool:Recycle(NetManager.sendPkgMap[id])
          NetManager.sendPkgMap[id] = nil
        end
        if msgCfg.isLock then
          NetManager.waitPkgMap[id] = NetManager.sendPkgMap[id]
        end
        if NetManager.IsNeedReconnectMsg(id) then
          bKeyMsgTimeOut = true
          keyMsgTimeOutId = id
        end
      end
    end
  end
  NetManager.CheckWaitingUIShow(false)
  if bKeyMsgTimeOut then
    LobbySystem.isInLobby = false
    local msgCfg = NetManager.FindMsgInfo(keyMsgTimeOutId)
    if keyMsgTimeOutId and msgCfg and msgCfg.req and msgCfg.req == "heart_beat" then
      NetUtil.tryConnect(Enum_LOGIN_REPORT_CFG.NET_MSG_TIME_OUT)
      gem_report_utils.ReportEventDelay(gem_report_utils.EventName_Network, "timeout")
    else
      NetUtil.tryConnect(Enum_LOGIN_REPORT_CFG.NET_MSG_TIME_OUT_OTHER)
    end
  elseif bTimeOut then
    if not GameStatus.IsInFightingNotMainCity() and not NetMacros.TimeOutWhiteList[timeoutReq] then
      local msgCfg = NetManager.FindMsgInfo(timeoutReq)
      if msgCfg then
        if IsShipping then
          if not msgCfg.req or msgCfg.timeout then
          end
        else
          local noticeStr = msgCfg.req and msgCfg.timeout and LocUtil.GetLocalizeResStr(19810424) .. " (Dev Only)MsgID = " .. tostring(msgCfg.req)
        end
      end
      PufferNetManager.OnNetTimeOut()
    end
    NetManager.SendQueuePkg()
  end
  for k, v in pairs(NetManager.mustArrivePkgMap) do
    if v and v.t and tNow - v.t > NetMacros.CONST_MSG_RESEND_INTERVAL then
      if 0 < v.resend_times then
        NetManager.SelfSendWithCache(k, v.isWrapByHome, table_unpack(v.param))
        v.resend_times = v.resend_times - 1
        v.t = tNow
      else
        NetManager.mustArrivePkgMap[k] = nil
        local func = NetManager.onTimeOutCallbackMap[k]
        if func then
          func(table_unpack(v.param))
        end
      end
    end
  end
  if not GameStatus.IsInFightingNotMainCity() and next(NetManager.ingameSaveMsgList) then
    local count = 0
    for k, v in pairs(NetManager.ingameSaveMsgList) do
      NetManager.ProcPkg2Handler(table_unpack(v))
      NetManager.ingameSaveMsgList[k] = nil
      count = count + 1
      if count > NetMacros.CONST_OPERATE_MSG_PER_FRAME then
        break
      end
    end
  end
  NetManager.CheckClientTimeFlowBack(tNow)
end
function NetManager.CheckClientTimeFlowBack(tNow)
  if tNow < NetManager.tCurrentClientTime then
    NetUtil.Disconnect()
    Client.DestroyConnector(NetInterface)
    NetUtil.tryConnect(Enum_LOGIN_REPORT_CFG.NET_MSG_TIME_BACK)
  end
  NetManager.tCurrentClientTime = tNow
end
function NetManager.InitLogRequestMsg()
  NetManager.logMsgMap = {}
  if NetManager.isLogMsgAfterLogin then
    time_ticker.AddTimerOnce(30, NetManager.LogRequestMsgAfterLoginToFile)
  end
  if PufferNetManager then
    log_format("NetManager.InitLogRequestMsg. set puffer net manager")
    PufferNetManager.UseNewTimeOutHandler = HDmpveRemote.HDmpveRemoteConfigGetBool("PufferNetUseNewTimeOutHandler", true)
    PufferNetManager.NewTimeOutParams.TimeOutSpeedDownTime = HDmpveRemote.HDmpveRemoteConfigGetInt("PufferNetTimeOutSpeedDownTime", 10)
    PufferNetManager.NewTimeOutParams.ReconnectMeasureTime = HDmpveRemote.HDmpveRemoteConfigGetInt("PufferNetReconnectMeasureTime", 5)
    PufferNetManager.NewTimeOutParams.SpeedDownRate = HDmpveRemote.HDmpveRemoteConfigGetInt("PufferNetSpeedDownRate", 2)
    log_tree("NetManager.InitLogRequestMsg. PufferNetManager.NewTimeOutParams = ", PufferNetManager.NewTimeOutParams)
  end
end
function NetManager.LogRequestMsgAfterLoginToFile()
  if IsShipping then
    return
  end
  local fileName = "RequestAfterLogin_" .. Client.GetAppVersion() .. "_" .. TimeUtil.FormatTime_YMDHMS(TimeUtil.OSTime(), true) .. ".txt"
  local msgTb = {}
  for k, v in pairs(NetManager.logMsgMap) do
    local _item = {}
    _item.name = k
    _item.count = v
    msgTb[#msgTb + 1] = _item
  end
  table.sort(msgTb, function(a, b)
    return a.name < b.name
  end)
  local _content = ""
  for i = 1, #msgTb do
    local v = msgTb[i]
    _content = _content .. v.name .. "\t\t\t\t" .. tostring(v.count) .. "\n"
  end
  Client.SaveStringToFile(_content, fileName)
end
function NetManager.FindMsgInfoByReqName(req)
  if req == nil then
    return nil, nil
  end
  for k, v in pairs(NetConfig.msgMap) do
    if v.req and v.req == req then
      return k, v
    end
  end
  return nil, nil
end
function NetManager.ProcReqLimited(msg)
  if msg == nil then
    return
  end
  local id = 0
  local msgInfo
  id, msgInfo = NetManager.FindMsgInfoByReqName(msg)
  if msgInfo == nil then
    return
  end
  NetManager.RemoveFirstSendInfo(id, msgInfo)
  NetManager.CheckWaitingUIShow(false)
  if NetManager.mustArrivePkgMap[id] then
    NetManager.mustArrivePkgMap[id] = nil
  end
  NetManager.SendQueuePkg()
end
function NetManager.ProcConnected(bConnected)
  log(bWriteLog and string_format("NetManager.ProcConnected bConnected = %s", bConnected))
  for _, sendInfoList in pairs(NetManager.sendPkgMap) do
    _RecycleSendInfoList(sendInfoList)
  end
  NetManager.ClearRegularMap()
  NetManager.  local netType = Client.GetNetWorkType()
  if netType and netType ~= NetManager.netTypeStr then
    local net_type_change = {}
    net_type_change.old_type = NetManager.netTypeStr
    net_type_change.new_type = netType
    NetManager.netTypeStr = netType
    log(bWriteLog and "NetManager.ProcConnected " .. tostring(netType))
    EventSystem:postEvent(EVENTTYPE_NETWORK, EVENTID_NET_STATE_CHANGE, net_type_change)
  end
  EventSystem:postEvent(EVENTTYPE_NETWORK, EVENTID_NET_CONNECTED_CHANGE, bConnected)
  NetManager.isLock = false
end
function NetManager.ClearRegularMap()
  NetManager.sendPkgMap = {}
  NetManager.waitPkgMap = {}
  NetManager.selfSendQueueMap = {}
  NetManager.hisSendPkgMap = {}
  NetManager.ingameSaveMsgList = {}
end
function NetManager.ClearRecordById(msgID)
  if msgID == nil or type(msgID) ~= "number" then
    return
  end
  _RecycleSendInfoList(NetManager.sendPkgMap[msgID])
  NetManager.sendPkgMap[msgID] = nil
  NetManager.waitPkgMap[msgID] = nil
  NetManager.selfSendQueueMap[msgID] = nil
  NetManager.hisSendPkgMap[msgID] = nil
  NetManager.CheckWaitingUIShow(false)
end
function NetManager.CheckResCode(param1)
  if param1 then
    if type(param1) == "number" and param1 ~= 0 then
      log_warning(string_format("NetManager get error code: %d!!!", param1))
    elseif type(param1) == "string" and param1 ~= NetErrorCode_NONE then
      log_warning(string_format("NetManager get error code: %s!!!", param1))
    end
  end
end
function NetManager.ErrorReport(err_info, id)
  log_warning(err_info)
  if not NetManager.bConnected or not NetManager.isInit then
    return
  end
end
function NetManager.CheckOverloadRecovery()
  if not NetManager.checkRecoveryTimer then
    NetManager.checkRecoveryTimer = time_ticker.AddTimerLoop(0, function()
      if not NetManager.OverloadProtect then
        time_ticker.RemoveTimer(NetManager.checkRecoveryTimer)
        NetManager.checkRecoveryTimer = nil
        return
      end
      if NetManager.checkRecoveryCD == 0 or TimeUtil.GetServerTimeInSec() > NetManager.checkRecoveryCD then
        local OverloadHandler = require("client.network.Protocol.OverloadHandler")
        OverloadHandler.send_check_overload_recovery()
      end
    end, 0, 5)
  end
end
function _G.Decode(data)
  if type(data) == "string" then
    local decodeData = slua.LuaArchiverDecode(LuaStateWrapper, data)
    if decodeData == nil or type(decodeData) == "table" then
      log_tree("decodeData = ", decodeData)
      return decodeData
    end
  end
  return data
end
function _G.Encode(data)
  if data then
    return slua.LuaArchiverEncode(LuaStateWrapper, data)
  end
  return data
end
function NetManager.ResetLocalVariance()
  log = log or _G.log
  log_warning = log_warning or _G.log_warning
  log_error = log_error or _G.log_error
  log_tree = log_tree or _G.log_tree
  IsEditor = IsEditor or _G.IsEditor
  NetUtil = NetUtil or _G.NetUtil
  GameStatus = GameStatus or _G.GameStatus
  EventSystem = EventSystem or _G.EventSystem
  IsShipping = IsShipping or _G.IsShipping
  Client = Client or _G.Client
  pcall = pcall or _G.pcall
  ModuleManager = ModuleManager or _G.ModuleManager
end
function NetManager.AppendModConfig(modMsgMap, modRsp2IDMap, modReconnectMsgList, handlerBasePath)
  if modMsgMap then
    for id, config in pairs(modMsgMap) do
      if not NetConfig.msgMap[id] then
        local configCopy = {}
        for k, v in pairs(config) do
          configCopy[k] = v
        end
        if handlerBasePath and handlerBasePath ~= "" and not configCopy.handlerBasePath then
          configCopy.        end
        NetConfig.msgMap[id] = configCopy
        _modInjectedMsgIds[id] = true
      end
    end
  end
  if modRsp2IDMap then
    for rspName, config in pairs(modRsp2IDMap) do
      if not NetRsp2ID[rspName] then
        NetRsp2ID[rspName] = config
        _modInjectedRspNames[rspName] = true
      end
    end
  end
  if modReconnectMsgList then
    for _, id in ipairs(modReconnectMsgList) do
      local bFound = false
      for _, existId in ipairs(NetConfig.reconnectMsgMap) do
        if existId == id then
          bFound = true
          break
        end
      end
      if not bFound then
        NetConfig.reconnectMsgMap[#NetConfig.reconnectMsgMap + 1] = id
        _modInjectedReconnectIds[id] = true
      end
    end
  end
  log(bWriteLog and "NetManager:AppendModConfig - mod net config injected")
end
function NetManager.RemoveModConfig()
  for id, _ in pairs(_modInjectedMsgIds) do
    NetConfig.msgMap[id] = nil
  end
  for rspName, _ in pairs(_modInjectedRspNames) do
    NetRsp2ID[rspName] = nil
  end
  for i = #NetConfig.reconnectMsgMap, 1, -1 do
    if _modInjectedReconnectIds[NetConfig.reconnectMsgMap[i]] then
      table_remove(NetConfig.reconnectMsgMap, i)
    end
  end
  _modInjectedMsgIds = {}
  _modInjectedRspNames = {}
  _modInjectedReconnectIds = {}
  log(bWriteLog and "NetManager:RemoveModConfig - mod net config removed")
end
return NetManager