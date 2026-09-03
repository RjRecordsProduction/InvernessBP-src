local BasicDataDropTable = {}
function BasicDataDropTable:DefineAndResetData()
  BasicDataDropTable.__super.DefineAndResetData(self)
  self._noRepeatMap = nil
end
function BasicDataDropTable:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    self:DefineAndResetData()
  end
end
function BasicDataDropTable:GetCacheData(key)
  key = tonumber(key)
  return BasicDataDropTable.__super.GetCacheData(self, key)
end
function BasicDataDropTable:GetOrReqData(key, callback, extraParams, ...)
  key = tonumber(key)
  return BasicDataDropTable.__super.GetOrReqData(self, key, callback, extraParams, ...)
end
function BasicDataDropTable:OnSendBatchReqMsg(keyMap, reqKey)
  if not keyMap or not next(keyMap) then
    return
  end
  local DropBoxHandler = require("client.network.Protocol.DropBoxHandler")
  DropBoxHandler.send_get_content_by_dropids(keyMap, reqKey)
end
function BasicDataDropTable:OnMergeReqMsg(key, bNoRepeat, bBoxDetail)
  BasicDataDropTable.__super.OnMergeReqMsg(self, key, bNoRepeat, bBoxDetail)
  self._noRepeatMap = self._noRepeatMap or {}
  self._noRepeatMap[key] = bNoRepeat
end
function BasicDataDropTable:on_get_content_by_dropids_rsp(key, drop_list)
  local infoMap = self:_ProcessRspData(drop_list, key)
  self:OnHandleBatchMsgDataAndCallback(infoMap, key)
end
function BasicDataDropTable:_RemoveRepeat(dropInfo)
  if not dropInfo or not next(dropInfo) then
    return nil
  end
  local result = {}
  for _, v in pairs(dropInfo) do
    local add = true
    for _, item in pairs(result) do
      if v.DropItemID == item.DropItemID and v.DropItemNum == item.DropItemNum and v.DropItemTime == item.DropItemTime then
        add = false
        break
      end
    end
    if add then
      table.insert(result, v)
    end
  end
  return result
end
function BasicDataDropTable:_ProcessRspData(item_list, key)
  local sortDataListComp = function(a, b)
    return a.DropItemSort > b.DropItemSort
  end
  for i, v in pairs(item_list) do
    if self._noRepeatMap and self._noRepeatMap[key] then
      self:_RemoveRepeat(v)
      self._noRepeatMap[key] = nil
    end
    table.sort(v, sortDataListComp)
  end
  return item_list
end
local class = require("class")
local CModuleBase = require("client.slua.data.BasicData.BaseClass.BasicDataBatchClass")
local CBasicDataDropTable = class(CModuleBase, nil, BasicDataDropTable)
return CBasicDataDropTable