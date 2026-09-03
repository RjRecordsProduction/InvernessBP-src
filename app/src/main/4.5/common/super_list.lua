local SuperList = {
  Operation = {
    RefreshAll = "RefreshAll",
    RefreshItem = "RefreshItem",
    InsertItem = "InsertItem",
    RemoveItem = "RemoveItem",
    ChangeData = "ChangeData"
  }
}
local SuperItem = {}
function SuperList:__index(k)
  if SuperList[k] then
    return SuperList[k]
  end
  return self._data[k]
end
function SuperList:__newindex(k, v)
  self._data[k] = v
  self:_PostEvents(SuperList.Operation.RefreshItem, k, v)
end
function SuperList:_PostEvents(operation, ...)
  for _, callback in pairs(self._listeners) do
    callback(operation, ...)
  end
end
function SuperList:AddListener(callback)
  table.insert(self._listeners, callback)
  callback(SuperList.Operation.RefreshAll, self._data)
end
function SuperList:RemoveListener(callback)
  local listeners = self._listeners
  for i, v in pairs(listeners) do
    if v == callback then
      table.remove(listeners, i)
      break
    end
  end
end
function SuperList:InsertItem(index, item)
  local data = self._data
  if self._bIsSuperItem then
    item = SuperList._CreateSuperItem(item, self._itemListeners, index)
    table.insert(data, index, item)
    for idx = index + 1, #data do
      data[idx]:_SetIndex(idx)
    end
  else
    table.insert(data, index, item)
  end
  self:_PostEvents(SuperList.Operation.InsertItem, index, item)
end
function SuperList:AppendItem(item)
  local data = self._data
  if self._bIsSuperItem then
    item = SuperList._CreateSuperItem(item, self._itemListeners, #data + 1)
  end
  table.insert(data, item)
  self:_PostEvents(SuperList.Operation.InsertItem, #data, item)
end
function SuperList:RemoveItem(index)
  local data = self._data
  table.remove(data, index)
  if self._bIsSuperItem then
    for idx = index, #data do
      data[idx]:_SetIndex(idx)
    end
  end
  self:_PostEvents(SuperList.Operation.RemoveItem, index)
end
function SuperList:RemoveItemByItem(item)
  local data = self._data
  for index, it in pairs(data) do
    if it == item then
      self:RemoveItem(index)
      return true
    end
  end
  return false
end
function SuperList:SetData(data, bSkipRefresh)
  self._data = SuperList.CreateData(data, self._bIsSuperItem, self._itemListeners)
  if bSkipRefresh then
    return
  end
  self:_PostEvents(SuperList.Operation.RefreshAll, data)
end
function SuperList:ClearData()
  self:SetData({})
end
function SuperList:Sort(compFuc, bSkipRefresh)
  table.sort(self._data, compFuc)
  if bSkipRefresh then
    return
  end
  self:_PostEvents(SuperList.Operation.RefreshAll, self._data)
end
function SuperList:__pairs()
  local custom_next = function(self, k)
    local v
    k, v = next(self._data, k)
    if v ~= nil then
      return k, v
    end
  end
  return custom_next, self, nil
end
function SuperList:__len()
  return #self._data
end
function SuperList:AddItemListener(key, callback)
  self._itemListeners[key] = callback
end
function SuperList:RemoveItemListener(key)
  self._itemListeners[key] = nil
end
function SuperList:RemoveAllItemListener()
  for k, _ in pairs(self._itemListeners) do
    self._itemListeners[k] = nil
  end
end
function SuperList._CreateSuperItem(itemData, itemListeners, index)
  local callback = function(key, idx, data)
    if not itemListeners[key] then
      return
    end
    local func = itemListeners[key]
    func(SuperList.Operation.ChangeData, idx, data, key)
  end
  return SuperItem._CreateSuperItem(itemData, callback, index)
end
function SuperList.CreateData(data, bIsSuperChild, itemListeners)
  if bIsSuperChild then
    local dataT = {}
    for index, value in pairs(data) do
      local itemData = SuperList._CreateSuperItem(value, itemListeners, index)
      table.insert(dataT, itemData)
    end
    return dataT
  else
    return data or {}
  end
end
function SuperList.Create(data, bIsSuperChild)
  local itemListeners = {}
  local dataT = SuperList.CreateData(data, bIsSuperChild, itemListeners)
  local superList = setmetatable({
    _data = dataT,
    _listeners = {},
    _itemListeners = itemListeners,
    _bIsSuperItem = bIsSuperChild
  }, SuperList)
  return superList
end
function SuperItem._CreateSuperItem(data, callback, index)
  local item = {
    _data = data,
    _callback = callback or nil,
    _  }
  setmetatable(item, SuperItem)
  return item
end
function SuperItem:__index(k)
  if SuperItem[k] then
    return SuperItem[k]
  end
  return self._data[k]
end
function SuperItem:__newindex(k, v)
  self._data[k] = v
  if self._callback then
    self._callback(k, self._index, self)
  end
end
function SuperItem:_SetIndex(index)
  rawset(self, "_index", index)
end
return SuperList