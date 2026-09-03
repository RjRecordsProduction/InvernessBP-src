local Logic_UGC_Social = {collectList = nil, likeList = nil}
function Logic_UGC_Social:ClearData()
  self.collectList = nil
end
local C_CollectionSort_PlayCount = 10
function Logic_UGC_Social:GetCollectList()
  if self.collectList then
    return self:SelectedCollectList()
  end
  self:InitCollectList()
  return self:SelectedCollectList()
end
function Logic_UGC_Social:GetCollectMetaCnt(collectModIDList)
  local CollectionIDList = {}
  if collectModIDList then
    CollectionIDList = collectModIDList
  else
    local CollectionList = self:GetCollectList()
    if CollectionList then
      for i, v in ipairs(CollectionList) do
        table.insert(CollectionIDList, v.mod_id)
      end
    end
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local ModInfoList = LogicUGC:BatchGetModInfo(CollectionIDList, nil, nil, {bExportArray = true}) or {}
  local TableUtil = require("common.table_util")
  local cnt = TableUtil.CountTable(ModInfoList)
  log(bWriteLog and "Logic_UGC_Social:GetCollectMetaCnt cnt : " .. cnt)
  if cnt == 0 then
    return TableUtil.CountTable(CollectionIDList)
  else
    return cnt
  end
end
function Logic_UGC_Social:InitCollectList()
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local collectServerList = LogicUGC:GetOriginalCollectKeyInfoList()
  if not collectServerList then
    return {}
  end
  local list = {}
  for id, info in pairs(collectServerList) do
    table.insert(list, {
      mod_id = id,
      collect_time = info.collect_time,
      lately_look_time = info.lately_look_time,
      play_cnt = info.play_cnt,
      wow_pass_shielded = info.wow_pass_shielded
    })
  end
  self.collectList = list
end
function Logic_UGC_Social:InitHistoryPlayList(history_play_list)
  if not history_play_list then
    log(bWriteLog and "Logic_UGC_Social:InitHistoryPlayList not list")
    return
  end
  self.historyPlayList = history_play_list
end
function Logic_UGC_Social:GetHistoryPlayList()
  log_tree(bWriteLog and "Logic_UGC_Social:GetHistoryPlayList : ", self.historyPlayList)
  return self.historyPlayList
end
function Logic_UGC_Social:IsCurModPlayed(modID, playTime)
  local playTimes = playTime or 1
  local result = false
  if not modID then
    log(bWriteLog and "Logic_UGC_Social:IsCurModPlayPlayed not modID")
    return result
  end
  if not self.historyPlayList or not next(self.historyPlayList) then
    log(bWriteLog and "Logic_UGC_Social:IsCurModPlayPlayed not history data")
    return result
  end
  for id, data in pairs(self.historyPlayList) do
    if id == modID then
      data.total_play_count = data.total_play_count or 0
      if playTimes <= data.total_play_count then
        result = true
        break
      end
    end
  end
  log(bWriteLog and "Logic_UGC_Social:IsCurModPlayPlayed modID : " .. modID .. " playTime : " .. playTimes .. " result: " .. tostring(result))
  return result
end
function Logic_UGC_Social:SortCollectList(list)
  table.sort(list, function(a, b)
    if a.play_cnt > C_CollectionSort_PlayCount and b.play_cnt > C_CollectionSort_PlayCount then
      if a.play_cnt == b.play_cnt then
        if a.collect_time == b.collect_time then
          return a.mod_id > b.mod_id
        else
          return a.collect_time > b.collect_time
        end
      else
        return a.play_cnt > b.play_cnt
      end
    elseif a.play_cnt > C_CollectionSort_PlayCount and b.play_cnt <= C_CollectionSort_PlayCount then
      return true
    elseif a.play_cnt <= C_CollectionSort_PlayCount and b.play_cnt > C_CollectionSort_PlayCount then
      return false
    elseif a.collect_time == b.collect_time then
      return a.mod_id > b.mod_id
    else
      return a.collect_time > b.collect_time
    end
  end)
end
function Logic_UGC_Social:GetCollectInfo(modID)
  local result
  if not self.collectList then
    return result
  end
  for i, v in ipairs(self.collectList) do
    if v.mod_id == modID then
      result = v
      break
    end
  end
  return result
end
function Logic_UGC_Social:GetCollectModCache(modID)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  return LogicUGC:GetModByAllCache(modID)
end
function Logic_UGC_Social:IsCollect(modID)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local collectList = LogicUGC:GetCollectKeyInfoList()
  if not collectList then
    if not LogicUGC.modKeyInfoList then
      local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
      LogicUGC:ReqGetAllMetaKey()
    end
    return false
  end
  return collectList[modID] and true or false
end
function Logic_UGC_Social:RemoveCollection(modID)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local collectList = LogicUGC:GetCollectKeyInfoList()
  if not collectList then
    return
  end
  if not collectList[modID] then
    return
  end
  collectList[modID] = nil
  if self.collectList then
    for i, v in ipairs(self.collectList) do
      if v.mod_id == modID then
        table.remove(self.collectList, i)
        break
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_COLLECT, modID, false)
end
function Logic_UGC_Social:ReqCollectMod(modInfo)
  if not modInfo then
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if not Config_UGC.IsUGCReleased() then
    return
  end
  modInfo.collect_cnt = modInfo.collect_cnt + 1
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_collect_mod_req(modInfo.mod_id)
end
function Logic_UGC_Social:ReqCancelCollectMod(modInfo)
  if not modInfo then
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if not Config_UGC.IsUGCReleased() then
    return
  end
  modInfo.collect_cnt = modInfo.collect_cnt - 1
  modInfo.collect_cnt = modInfo.collect_cnt >= 0 and modInfo.collect_cnt or 0
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_cancel_collect_mod_req(modInfo.mod_id)
end
function Logic_UGC_Social:ReqLookMod(modID)
  if not modID then
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if not Config_UGC.IsUGCReleased() then
    return
  end
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_collect_look_req(modID)
end
function Logic_UGC_Social:OnCollectModRsp(modID, info)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  LogicUGC:UpdateCollectKeyInfoList(modID, info)
  if not self.collectList then
    self.collectList = {}
  end
  table.insert(self.collectList, {
    mod_id = modID,
    collect_time = info.collect_time,
    lately_look_time = info.lately_look_time,
    play_cnt = info.play_cnt
  })
  self:SortCollectList(self.collectList)
  ShowNotice(6797)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_COLLECT, modID, true)
end
function Logic_UGC_Social:OnCancelCollectModRsp(modID)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  LogicUGC:UpdateCollectKeyInfoList(modID)
  if not self.collectList then
    self.collectList = {}
  end
  for i, v in ipairs(self.collectList) do
    if v.mod_id == modID then
      table.remove(self.collectList, i)
      break
    end
  end
  ShowNotice(6798)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_COLLECT, modID, false)
end
function Logic_UGC_Social:OnLookModRsp(modID, info)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  LogicUGC:UpdateCollectKeyInfoList(modID, info)
  if not self.collectList then
    self.collectList = {}
  end
  for i, v in ipairs(self.collectList) do
    if v.mod_id == modID then
      v.lately_look_time = info.lately_look_time
      v.play_cnt = info.play_cnt
      break
    end
  end
  self:SortCollectList(self.collectList)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_COLLECT, modID, true)
end
function Logic_UGC_Social:IsLike(modID)
  if not self.likeList then
    self.likeList = {}
  end
  return self.likeList[modID]
end
function Logic_UGC_Social:ReqLikeMod(modID)
  if not modID then
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if not Config_UGC.IsUGCReleased() then
    return
  end
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_like_mod_req(modID)
end
function Logic_UGC_Social:ReqCancelLikeMod(modID)
  if not modID then
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if not Config_UGC.IsUGCReleased() then
    return
  end
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_cancel_like_mod_req(modID)
end
function Logic_UGC_Social:OnLikeModRsp(modID)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_LIKE, modID)
end
function Logic_UGC_Social:OnCancelLikeModRsp(modID)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_LIKE, modID)
end
function Logic_UGC_Social:SelectedCollectList()
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local maxCollectCount = Config_UGC.MaxModCollect
  local IsBuy = false
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  IsBuy = logic_ugc_WOWPass:IsBuyElite()
  if IsBuy then
    maxCollectCount = Config_UGC.MaxModCollectPassOn
  end
  if self.collectList ~= nil then
    local collectList = {}
    local count = 0
    for k, v in pairs(self.collectList) do
      if IsBuy or not v.wow_pass_shielded then
        table.insert(collectList, v)
        count = count + 1
      end
    end
    if maxCollectCount < count then
      table.sort(collectList, function(a, b)
        return a.collect_time > b.collect_time
      end)
      for i = #collectList, maxCollectCount + 1, -1 do
        collectList[i].wow_pass_shielded = true
        table.remove(collectList, i)
      end
    end
    self:SortCollectList(collectList)
    return collectList
  else
    return {}
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicUGCSocial = class(CModuleBase, nil, Logic_UGC_Social)
return CLogicUGCSocial