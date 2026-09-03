local ClientTLogUtil = require("GameLua.Mod.BaseMod.Client.ClientTLog.ClientTLogUtil")
local ClientTLogConfig = require("GameLua.Mod.BaseMod.Client.ClientTLog.ClientTLogConfig")
local ClientTLogManager = {}
function ClientTLogManager:ctor()
  self.ClientTlogData = {}
  self.TempCacheData = {}
  self.bHasSent = false
end
function ClientTLogManager:OnInit()
  printf("ClientTLogManager:OnInit")
  self.bHasSent = false
  self:AddCommonEvent(EVENTTYPE_CLIENT_TLOG, EVENTID_ADD_VALUE_TLOG, self.AddValTLog, self)
  self:AddCommonEvent(EVENTTYPE_CLIENT_TLOG, EVENTID_SET_VALUE_TLOG, self.SetValTLog, self)
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT, self.OnReceiveBattleResults, self)
  if NetUtil.EnterBattleLoadingTime and NetUtil.EnterBattleLoadingTime > 0 then
    self:SetValTLog("EnterBattleLoadingTime", NetUtil.EnterBattleLoadingTime)
  end
  printf("ClientTLogManager:OnInit Ok")
end
function ClientTLogManager:OnRelease()
  print(bWriteLog and "ClientTLogManager:OnRelease")
  ClientTLogManager.__super.OnRelease(self)
end
function ClientTLogManager:OnReceiveBattleResults(_, _)
  if self.bHasSent then
    return
  end
  local ClientTlogHandler = require("client.network.Protocol.ClientTlogHandler")
  for sTableName, tContent in pairs(self.ClientTlogData) do
    local sSendRet = self:ConvertDataToString(sTableName)
    print(bWriteLog and string.format("ClientTLogManager Send %s Ret = %s", sTableName, sSendRet))
    if sSendRet and sSendRet ~= "" then
      ClientTlogHandler.send_report_lobby_common_tlog(sTableName, sSendRet)
    end
  end
  self.bHasSent = true
end
function ClientTLogManager:SendReportLobby(sTableName, tData, bKeyNum)
  local ClientTlogHandler = require("client.network.Protocol.ClientTlogHandler")
  local sSendRet = ""
  local TlogConfig = ClientTLogConfig[sTableName]
  if bKeyNum then
    sSendRet = ClientTLogUtil.ConvertArrayDataContentToString(tData)
  elseif TlogConfig and TlogConfig.KeysOrder then
    sSendRet = ClientTLogUtil.ConvertMapDataContentToString(tData, TlogConfig.KeysOrder)
  else
    print(bWriteLog and "ClientTLogManager:SendReportLobby Error C", sTableName)
  end
  print(bWriteLog and string.format("ClientTLogManager:SendReportLobby %s Ret = %s", sTableName, sSendRet))
  ClientTlogHandler.send_report_lobby_common_tlog(sTableName, sSendRet)
end
function ClientTLogManager:GetTableByName(sTableName)
  if not self.ClientTlogData[sTableName] then
    self.ClientTlogData[sTableName] = {
      KeyType = nil,
      DataContent = {}
    }
  end
  return self.ClientTlogData[sTableName]
end
function ClientTLogManager:ConvertDataToString(sTableName)
  if sTableName == nil or type(sTableName) ~= "string" then
    print(bWriteLog and "ClientTLogManager:ConvertDataToString Error A", sTableName)
    return nil
  end
  local tData = self:GetTableByName(sTableName)
  if tData.KeyType == nil or tData.KeyType ~= 0 and tData.KeyType ~= 1 then
    print(bWriteLog and "ClientTLogManager:ConvertDataToString Error B", tData.KeyType)
    return nil
  end
  local TlogConfig = ClientTLogConfig[sTableName]
  if TlogConfig and TlogConfig.ToString then
    return TlogConfig.ToString(self, sTableName)
  end
  if tData.KeyType == 0 then
    return ClientTLogUtil.ConvertArrayDataContentToString(tData.DataContent)
  elseif tData.KeyType == 1 then
    if TlogConfig and TlogConfig.KeysOrder then
      return ClientTLogUtil.ConvertMapDataContentToString(tData.DataContent, TlogConfig.KeysOrder)
    else
      print(bWriteLog and "ClientTLogManager:ConvertDataToString Error C", sTableName)
    end
  end
  return nil
end
function ClientTLogManager:SetValueByIndex(sTableName, nIndex, Value)
  if sTableName == nil or type(sTableName) ~= "string" then
    print(bWriteLog and "ClientTLogManager:SetValueByIndex Error A", sTableName)
    return
  end
  if nIndex == nil or type(nIndex) ~= "number" then
    print(bWriteLog and "ClientTLogManager:SetValueByIndex Error B", sTableName, nIndex)
    return
  end
  local tData = self:GetTableByName(sTableName)
  if tData.KeyType == nil then
    tData.KeyType = 0
  elseif tData.KeyType ~= 0 then
    print(bWriteLog and "ClientTLogManager:SetValueByIndex Error C", sTableName, tData.KeyType, nIndex)
    return
  end
  tData.DataContent[nIndex] = Value
end
function ClientTLogManager:GetValueByIndex(sTableName, nIndex)
  if sTableName == nil or type(sTableName) ~= "string" then
    print(bWriteLog and "ClientTLogManager:GetValueByIndex Error A", sTableName)
    return nil
  end
  if nIndex == nil or type(nIndex) ~= "number" then
    print(bWriteLog and "ClientTLogManager:GetValueByIndex Error B", sTableName, nIndex)
    return nil
  end
  local tData = self:GetTableByName(sTableName)
  if tData.KeyType == nil or tData.KeyType ~= 0 then
    return nil
  end
  return tData.DataContent[nIndex]
end
function ClientTLogManager:AddValueByIndex(sTableName, nIndex, nAddValue)
  if sTableName == nil or type(sTableName) ~= "string" then
    print(bWriteLog and "ClientTLogManager:AddValueByIndex Error A", sTableName)
    return
  end
  if nIndex == nil or type(nIndex) ~= "number" then
    print(bWriteLog and "ClientTLogManager:AddValueByIndex Error B", sTableName, nIndex)
    return
  end
  if nAddValue == nil or type(nAddValue) ~= "number" then
    print(bWriteLog and "ClientTLogManager:AddValueByIndex Error C", sTableName, nAddValue)
    return
  end
  local OldValue = self:GetValueByIndex(sTableName, nIndex)
  if OldValue == nil then
    OldValue = 0
  elseif type(OldValue) ~= "number" then
    print(bWriteLog and "ClientTLogManager:AddValueByIndex Error D", sTableName, OldValue)
    return
  end
  self:SetValueByIndex(sTableName, nIndex, OldValue + nAddValue)
end
function ClientTLogManager:SetValueByKey(sTableName, Key, Value)
  if sTableName == nil or type(sTableName) ~= "string" then
    print(bWriteLog and "ClientTLogManager:SetValueByKey Error A", sTableName)
    return
  end
  if Key == nil then
    print(bWriteLog and "ClientTLogManager:SetValueByKey Error B", sTableName, Key)
    return
  end
  local tData = self:GetTableByName(sTableName)
  if tData.KeyType == nil then
    tData.KeyType = 1
  elseif tData.KeyType ~= 1 then
    print(bWriteLog and "ClientTLogManager:SetValueByKey Error C", sTableName, tData.KeyType, Key)
    return
  end
  tData.DataContent[Key] = Value
end
function ClientTLogManager:GetValueByKey(sTableName, Key)
  if sTableName == nil or type(sTableName) ~= "string" then
    print(bWriteLog and "ClientTLogManager:GetValueByKey Error A", sTableName)
    return nil
  end
  if Key == nil then
    print(bWriteLog and "ClientTLogManager:GetValueByKey Error B", sTableName, Key)
    return nil
  end
  local tData = self:GetTableByName(sTableName)
  if tData.KeyType == nil or tData.KeyType ~= 1 then
    return nil
  end
  return tData.DataContent[Key]
end
function ClientTLogManager:AddValueByKey(sTableName, Key, nAddValue)
  if sTableName == nil or type(sTableName) ~= "string" then
    print(bWriteLog and "ClientTLogManager:AddValueByKey Error A", sTableName)
    return
  end
  if Key == nil then
    print(bWriteLog and "ClientTLogManager:AddValueByKey Error B", sTableName, Key)
    return
  end
  if nAddValue == nil or type(nAddValue) ~= "number" then
    print(bWriteLog and "ClientTLogManager:AddValueByKey Error C", sTableName, nAddValue)
    return
  end
  local OldValue = self:GetValueByKey(sTableName, Key)
  if OldValue == nil then
    OldValue = 0
  elseif type(OldValue) ~= "number" then
    print(bWriteLog and "ClientTLogManager:AddValueByKey Error D", sTableName, OldValue)
    return
  end
  self:SetValueByKey(sTableName, Key, OldValue + nAddValue)
end
function ClientTLogManager:GetTempFieldByName(sTableName, FieldName)
  if not self.TempCacheData[sTableName] then
    self.TempCacheData[sTableName] = {}
  end
  if not self.TempCacheData[sTableName][FieldName] then
    self.TempCacheData[sTableName][FieldName] = {}
  end
  return self.TempCacheData[sTableName][FieldName]
end
function ClientTLogManager:AddValTLog(_, _, sFieldName, nVal)
  print(bWriteLog and "ClientTLogManager:AddValTLog", sFieldName, nVal)
  local ds_net = require("ds_net")
  local msg = {FieldName = sFieldName, Val = nVal}
  local utility = require("common.utility")
  xpcall(function()
    ds_net.SendMessage("ingame_add_value_tlog", msg)
  end, utility.ErrorMessageHandler)
end
function ClientTLogManager:SetValTLog(_, _, sFieldName, nVal)
  print(bWriteLog and "ClientTLogManager:SetValTLog", sFieldName, nVal)
  local ds_net = require("ds_net")
  local msg = {FieldName = sFieldName, Val = nVal}
  local utility = require("common.utility")
  xpcall(function()
    ds_net.SendMessage("ingame_set_value_tlog", msg)
  end, utility.ErrorMessageHandler)
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, ClientTLogManager)