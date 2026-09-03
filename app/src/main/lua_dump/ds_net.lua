local ds_net = {}
local HASH_MOD = 7393933
ds_net.local MESSAGE_BIT_NUM = 24
local MAX_BITE_LIMIT = 1800
local MessageFlags = {ECompress = 1, EUseArchiver = 2}
local USE_LUAARCHIVER = false
local packetMap = {}
local pb = require("pb")
pb.option("enum_as_value")
local UEMathUtilityMethods = import("UEMathUtilityMethods")
local HashFunc = UEMathUtilityMethods.BKDRHash
local PackageName = "ds_client"
local SendMessageFunc
require("protoc").LoadFile("ds_client/core.pb")
local DispatchMessage = function(useLuaArchiver, messageName, moduleName, pbFileName, funcName, content, additionParam)
  local GameplaySysMgr = require("GameLua.Mod.BaseMod.GamePlay.Core.GameplaySysMgr")
  local Module = GameplaySysMgr.GetSysByPath(moduleName)
  local bInstance = false
  if not Module then
    Module = require(moduleName)
  else
    bInstance = true
  end
  if not Module then
    sandbox.LogError(string.format("OnReceiveMessage module[%s] not found ", moduleName))
  end
  local func = Module[funcName]
  if not func then
    sandbox.LogError(string.format("OnReceiveMessage module[%s] function[%s] not found ", moduleName, funcName))
    return
  end
  local protoc = require("protoc")
  protoc.LoadFile(PackageName .. "/" .. pbFileName)
  local message
  if useLuaArchiver then
    message = slua.LuaArchiverDecode(LuaStateWrapper, content)
  else
    local messageFullName = PackageName .. "." .. messageName
    message = pb.decode(messageFullName, content)
    ds_net.DecodeObjects(messageFullName, message)
  end
  local logic_ds_monitor = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ds_monitor)
  logic_ds_monitor:OnRecordMsg(messageName, #content)
  if Client then
    if additionParam then
      if bInstance then
        func(Module, additionParam, message)
      else
        func(additionParam, message)
      end
    elseif bInstance then
      func(Module, message)
    else
      func(message)
    end
  elseif bInstance then
    func(Module, additionParam, message)
  else
    func(additionParam, message)
  end
end
local OnReceiveMessage = function(msgId, content, additionParam)
  local useLuaArchiver = msgId & MessageFlags.EUseArchiver << MESSAGE_BIT_NUM ~= 0
  msgId = msgId & ~(MessageFlags.EUseArchiver << MESSAGE_BIT_NUM)
  local packetInfo = packetMap[msgId]
  if packetInfo == nil then
    sandbox.LogError("OnReceiveMessage msgId[" .. msgId .. "] config not found!")
    return
  end
  sandbox.LogNormal(bWriteLog and "OnReceiveMessage", msgId)
  local utility = require("common.utility")
  xpcall(DispatchMessage, utility.ErrorMessageHandler, useLuaArchiver, packetInfo.messageName, packetInfo.moduleName, packetInfo.pbFileName, packetInfo.funcName, content, additionParam)
end
function ds_net.InitReceiveDelegate()
  log(bWriteLog and "ds_net.InitReceiveDelegate")
  local delegates = {}
  ds_net._  local PlayerCtrl = import("UAEPlayerController")
  if PlayerCtrl == nil then
    sandbox.LogError("InitReceiveDelegate Fail")
  end
  if Client then
    local GameInstance
    if slua_GameFrontendHUD then
      GameInstance = slua_GameFrontendHUD:GetGameInstance()
    end
    local OnClientMsgReceiveDelegate = slua.createDelegate(function(msgId, content)
      sandbox.LogNormal(bWriteLog and "OnDSMessageReceiveDelegate", msgId, #content)
      OnReceiveMessage(msgId, content, nil)
    end)
    table.insert(delegates, OnClientMsgReceiveDelegate)
    PlayerCtrl.SetClientMsgReceiveDelegate(GameInstance, OnClientMsgReceiveDelegate)
    local OnClientTargetReceiveDelegate = slua.createDelegate(function(Obj, msgId, content)
      OnReceiveMessage(msgId, content, Obj)
    end)
    table.insert(delegates, OnClientTargetReceiveDelegate)
    PlayerCtrl.SetTargetMsgReceiveDelegate(GameInstance, OnClientTargetReceiveDelegate)
  else
    local OnDSMsgReceiveDelegate = slua.createDelegate(function(UID, msgId, content)
      sandbox.LogNormal(bWriteLog and "OnDSMessageReceiveDelegate", msgId, #content)
      OnReceiveMessage(msgId, content, UID)
    end)
    table.insert(delegates, OnDSMsgReceiveDelegate)
    PlayerCtrl.SetDSMsgReceiveDelegate(OnDSMsgReceiveDelegate)
  end
end
function ds_net.Init(routeModuleName)
  local ds_route = require(routeModuleName)
  for _, v in pairs(ds_route) do
    local moduleName = v.moduleName
    local pbFileName = v.pbFileName
    for messageName, funcName in pairs(v.routes) do
      local hash = HashFunc(messageName, HASH_MOD)
      if packetMap[hash] then
        sandbox.LogError(string.format("Hash [%s] conflict with [%s] ", messageName, packetMap[hash].messageName))
      end
      packetMap[hash] = {
        messageName = messageName,
        pbFileName = pbFileName,
        moduleName = moduleName,
              }
    end
  end
  ds_net.InitReceiveDelegate()
end
function ds_net.InitRoute(RouteTable)
  packetMap = {}
  for _, v in pairs(RouteTable) do
    local moduleName = v.moduleName
    local pbFileName = v.pbFileName
    for messageName, funcName in pairs(v.routes) do
      local hash = HashFunc(messageName, HASH_MOD)
      if packetMap[hash] then
        sandbox.LogError(string.format("Hash [%s] conflict with [%s] ", messageName, packetMap[hash].messageName))
      end
      packetMap[hash] = {
        messageName = messageName,
        pbFileName = pbFileName,
        moduleName = moduleName,
              }
    end
  end
  ds_net.InitReceiveDelegate()
end
function ds_net.SetSendMessageCallback(sendMessageFunc)
  SendMessageFunc = sendMessageFunc
end
function ds_net.DeepCopy(tOrigin)
  local tCopy = {}
  for key, value in pairs(tOrigin) do
    if type(value) == "table" then
      value = ds_net.DeepCopy(value)
    end
    tCopy[key] = value
  end
  return tCopy
end
local IsMessage = function(sType)
  local _, __, sDataType = pb.type(sType)
  if sDataType == "message" then
    return true
  end
  return false
end
function ds_net.EncodeObjects(sMessageName, tMessage)
  for sName, nNumber, sType, default, sLabel in pb.fields(sMessageName) do
    if IsMessage(sType) then
      if sLabel == "repeated" then
        local tSubMessageList = tMessage[sName]
        for _, tSubMessage in ipairs(tSubMessageList) do
          ds_net.EncodeObjects(sType, tSubMessage)
        end
      elseif sType == ".ds_client.Object" then
        if sLabel == "repeated" then
          local tObjectList = tMessage[sName]
          for index, uObject in ipairs(tObjectList) do
            if slua.isValid(uObject) then
              local nGUID = slua.GetNetGUID(uObject)
              tObjectList[index] = {GUID = nGUID}
            end
          end
        else
          local uObject = tMessage[sName]
          if slua.isValid(uObject) then
            local nGUID = slua.GetNetGUID(uObject)
            tMessage[sName] = {GUID = nGUID}
          elseif uObject ~= nil then
            sandbox.LogError("EncodeObject failed! uObject is invalid!")
          end
        end
      else
        local tSubMessage = tMessage[sName]
        if tSubMessage then
          ds_net.EncodeObjects(sType, tSubMessage)
        end
      end
    end
  end
end
function ds_net.Encode(messageName, messageTable)
  local messageFullName = PackageName .. "." .. messageName
  local msgId = HashFunc(messageName, HASH_MOD)
  if not assert_format(packetMap[msgId], "Message[%s] config not found!", messageName) then
    return
  end
  local protoc = require("protoc")
  protoc.LoadFile(PackageName .. "/" .. packetMap[msgId].pbFileName)
  local content
  if USE_LUAARCHIVER then
    content = slua.LuaArchiverEncode(LuaStateWrapper, messageTable)
    msgId = msgId | MessageFlags.EUseArchiver << MESSAGE_BIT_NUM
  else
    local tCopyTable = ds_net.DeepCopy(messageTable)
    ds_net.EncodeObjects(messageFullName, tCopyTable)
    content = pb.encode(messageFullName, tCopyTable)
  end
  return msgId, content
end
function ds_net.DecodeObjects(sMessageName, tMessage)
  for sName, nNumber, sType, default, sLabel in pb.fields(sMessageName) do
    if IsMessage(sType) then
      if sLabel == "repeated" then
        local tSubMessageList = tMessage[sName]
        for _, tSubMessage in ipairs(tSubMessageList) do
          ds_net.DecodeObjects(sType, tSubMessage)
        end
      elseif sType == ".ds_client.Object" then
        if sLabel == "repeated" then
          local tObjectList = tMessage[sName]
          for index, tObject in ipairs(tObjectList) do
            tObjectList[index] = nil
            if tObject then
              local nGUID = tObject.GUID
              if nGUID and 0 < nGUID then
                local uObject = slua.GetObjectFromNetGUID(nGUID)
                if slua.isValid(uObject) then
                  tObjectList[index] = uObject
                end
              end
            end
          end
        else
          local tObject = tMessage[sName]
          tMessage[sName] = nil
          if tObject then
            local nGUID = tObject.GUID
            if nGUID and 0 < nGUID then
              local uObject = slua.GetObjectFromNetGUID(nGUID)
              if slua.isValid(uObject) then
                tMessage[sName] = uObject
              end
            end
          end
        end
      else
        local tSubMessage = tMessage[sName]
        if tSubMessage then
          ds_net.DecodeObjects(sType, tSubMessage)
        end
      end
    end
  end
end
function ds_net.Decode(MsgID, Content)
  local useLuaArchiver = MsgID & MessageFlags.EUseArchiver << MESSAGE_BIT_NUM ~= 0
  MsgID = MsgID & ~(MessageFlags.EUseArchiver << MESSAGE_BIT_NUM)
  local packetInfo = packetMap[MsgID]
  if packetInfo == nil then
    sandbox.LogError("OnReceiveMessage msgId[" .. MsgID .. "] config not found!")
    return
  end
  sandbox.LogNormal(bWriteLog and "OnReceiveMessage", MsgID)
  local m = require(packetInfo.moduleName)
  if not m then
    sandbox.LogError(string.format("OnReceiveMessage module[%s] not found ", packetInfo.moduleName))
    return
  end
  local protoc = require("protoc")
  protoc.LoadFile(PackageName .. "/" .. packetInfo.pbFileName)
  local message
  if useLuaArchiver then
    message = slua.LuaArchiverDecode(LuaStateWrapper, Content)
  else
    local messageFullName = PackageName .. "." .. packetInfo.messageName
    message = pb.decode(messageFullName, Content)
    ds_net.DecodeObjects(messageFullName, message)
  end
  return packetInfo.funcName, message
end
function ds_net.SendMsgToDS(MsgName, MsgTable)
  local UIUtil = require("client.common.ui_util")
  local WorldContextObject = UIUtil.GetGameInstance()
  local UGameplayStatics = import("GameplayStatics")
  local PlayerController = UGameplayStatics.GetPlayerController(WorldContextObject, 0)
  if PlayerController == nil then
    sandbox.LogError("PlayerController is nil")
    return false
  end
  if PlayerController.SendLuaClientToDS == nil then
    sandbox.LogError("PlayerController SendLuaClientToDS is nil")
    return false
  end
  local MsgId, Content = ds_net.Encode(MsgName, MsgTable)
  if MsgId == nil then
    sandbox.LogError("PlayerController SendLuaClientToDS MsgId == nil, MsgName = " .. MsgName)
    return false
  end
  if GameStatus.IsInMainCityConnectDs() then
    local msgLen = #Content
    if 1800 < msgLen then
      print(bWriteLog and "ds_net.SendMsgToDS reach limit with " .. tostring(MsgName))
      return
    end
  end
  local logic_ds_monitor = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ds_monitor)
  logic_ds_monitor:OnRecordMsg(MsgName, #Content, true)
  PlayerController:SendLuaClientToDS(MsgId, Content, false)
  return true
end
function ds_net.SendMsgToClient(TargetObj, MsgName, MsgTable)
  if TargetObj == nil or TargetObj.SendLuaClientToDS == nil then
    print(bWriteLog and "SendMsgToClient TargetObj == nil or TargetObj.SendLuaClientToDS == nil")
    return false
  end
  local MsgId, Content = ds_net.Encode(MsgName, MsgTable)
  if CGameState and CGameState.bMainCityGameMode then
    local msgLen = #Content
    if 1800 < msgLen then
      print(bWriteLog and "ds_net.SendMsgToClient reach limit with " .. tostring(MsgName))
      return
    end
  end
  local logic_ds_monitor = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ds_monitor)
  logic_ds_monitor:OnRecordMsg(MsgName, #Content, true)
  TargetObj:SendLuaDStoClient(MsgId, Content, false)
  return true
end
function ds_net.SendMessage(messageName, messageTable, uid)
  if Client then
    sandbox.LogNormal(bWriteLog and "SendMsgToDS", messageName)
    return ds_net.SendMsgToDS(messageName, messageTable)
  else
    sandbox.LogNormal(bWriteLog and "SendMsgToClient", messageName)
    local PlayerCtrl = Game:GetPlayerControllerByUID(uid or 0)
    if slua.isValid(PlayerCtrl) then
      return ds_net.SendMsgToClient(PlayerCtrl, messageName, messageTable)
    end
  end
end
function ds_net.HasMessage(messageName)
  local msgId = HashFunc(messageName, HASH_MOD)
  if packetMap[msgId] then
    return true
  else
    return false
  end
end
return ds_net