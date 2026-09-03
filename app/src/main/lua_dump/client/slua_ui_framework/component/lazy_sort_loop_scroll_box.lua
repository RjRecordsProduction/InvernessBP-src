local PriorityQueue = require("common.priority_queue")
local string_format = string.format
local lazy_sort_loop_scroll_box = {}
local configExp = {
  CmpFunc = function(a, b)
    return false
  end,
  GetCmpFunc = nil,
  isTickLoad = false,
  FirstSize = 20,
  Step = 20,
  TimeInterval = 0.2
}
function lazy_sort_loop_scroll_box:ctor(_, config, itemModuleName, ...)
  lazy_sort_loop_scroll_box.__super.ctor(self, _, itemModuleName, ...)
  self:_InitLazyLoadConfig(config)
end
function lazy_sort_loop_scroll_box:SetData(arrayData)
  log(bWriteLog and "lazy_sort_loop_scroll_box:SetData")
  if self._LazyInitTimer then
    self:RemoveTimer(self._LazyInitTimer)
    self._LazyInitTimer = nil
  end
  self._loadedSize = 0
  self._data = arrayData or {}
  self._selectIndex = 0
  self:_InitPriorityQueue()
  self:_LoadToIndex(self._LazyLoadConfig.FirstSize)
  if self._LazyLoadConfig.isTickLoad then
    self._LazyInitTimer = self:AddTimerLoop(self._LazyLoadConfig.TimeInterval, function()
      log(bWriteLog and "lazy_sort_loop_scroll_box\239\188\154Timer Load")
      self:_LoadToIndex(self._loadedSize + self._LazyLoadConfig.Step)
    end, 0, self._LazyLoadConfig.TimeInterval)
  end
  self:SetItemCount(#self._data)
  self:InvalidateLayoutCache()
end
function lazy_sort_loop_scroll_box:GetItemData(index)
  if index == nil then
    log_warning(string_format("lazy_sort_loop_scroll_box:GetItemData index is nil"))
    return nil
  end
  if index <= 0 or index > #self._data then
    log_warning(string_format("lazy_sort_loop_scroll_box:GetItemData index[%d] out of range[1..%d]", index, #self._data))
    return nil
  end
  if index > self._loadedSize then
    self:_LoadToIndex(self._loadedSize + self._LazyLoadConfig.Step)
  end
  if index > self._loadedSize then
    log_warning(string_format("lazy_sort_loop_scroll_box:GetItemData index[%d] out of _loadedSize[1..%d]", index, self._loadedSize))
    return nil
  end
  return self._data[index]
end
function lazy_sort_loop_scroll_box:_LoadToIndex(index)
  log(bWriteLog and "lazy_sort_loop_scroll_box\239\188\154_LoadToIndex " .. tostring(index))
  local loadCount = index - self._loadedSize
  if loadCount <= 0 then
    return
  end
  for i = self._loadedSize + 1, #self._data do
    if loadCount > self._PriorityQueue:Size() then
      self._PriorityQueue:Push(i)
    else
      local Top = self._PriorityQueue:Top()
      if not self.QueueCmpFunc(i, Top) then
        self._PriorityQueue:Pop()
        self._PriorityQueue:Push(i)
      end
    end
  end
  if loadCount > self._PriorityQueue:Size() then
    loadCount = self._PriorityQueue:Size()
    log(bWriteLog and "lazy_sort_loop_scroll_box\239\188\154_LoadToIndex finish")
    if self._LazyInitTimer then
      self:RemoveTimer(self._LazyInitTimer)
      self._LazyInitTimer = nil
    end
  end
  local indexList = {}
  for i = 1, loadCount do
    local Top = self._PriorityQueue:Pop()
    indexList[loadCount - i + 1] = Top
  end
  for i = 1, loadCount do
    local dataIndex = indexList[i]
    self._data[self._loadedSize + i], self._data[dataIndex] = self._data[dataIndex], self._data[self._loadedSize + i]
    for j = i + 1, loadCount do
      if indexList[j] == self._loadedSize + i then
        indexList[j] = dataIndex
      end
    end
  end
  self._loadedSize = self._loadedSize + loadCount
end
function lazy_sort_loop_scroll_box:_InitLazyLoadConfig(config)
  if config then
    for k, v in pairs(configExp) do
      if not config[k] then
        config[k] = v
      end
    end
    self._LazyLoadConfig = config
  else
    self._LazyLoadConfig = configExp
  end
end
function lazy_sort_loop_scroll_box:_InitPriorityQueue()
  self.DataCmpFunc = self._LazyLoadConfig.CmpFunc
  if self._LazyLoadConfig.GetCmpFunc then
    self.DataCmpFunc = self._LazyLoadConfig.GetCmpFunc()
  end
  function self.QueueCmpFunc(a, b)
    return self.DataCmpFunc(self._data[b], self._data[a])
  end
  self._PriorityQueue = PriorityQueue(self.QueueCmpFunc)
end
local class = require("class")
local Cloop_scroll_box = require("client.slua_ui_framework.component.loop_scroll_box")
local Clazy_sort_loop_scroll_box = class(Cloop_scroll_box, nil, lazy_sort_loop_scroll_box)
return Clazy_sort_loop_scroll_box