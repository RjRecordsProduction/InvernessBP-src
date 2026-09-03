local reddot_node_base = {}
function reddot_node_base:ctor(_, _, parentNode, data)
  self.  self.data = data or {}
  self.childList = {}
  self.reddotRoot = nil
end
function reddot_node_base:InitNode()
  self:CreateReddotNodeWithParentTabId()
  if self.parentNode then
    self.parentNode:InsertChildNode(self)
  end
  self:InitReddotData()
end
function reddot_node_base:InitReddotData()
end
function reddot_node_base:CreateReddotNodeWithParentTabId()
end
function reddot_node_base:SetReddotRoot(reddotRoot)
  self.end
function reddot_node_base:GetReddotRoot()
  return self.reddotRoot
end
function reddot_node_base:GetReddotData()
  return self.data
end
function reddot_node_base:ReSetReddotData(data)
  self.end
function reddot_node_base:InsertChildNode(childNode)
  table.insert(self.childList, childNode)
end
function reddot_node_base:GetChildNodeCount()
  return #self.childList
end
function reddot_node_base:SetParentNode(parentNode)
  self.end
function reddot_node_base:GetParentNode()
  return self.parentNode
end
function reddot_node_base:PushReddotToParent(diffCount)
  if self.parentNode then
    self.parentNode:PushReddotCount(diffCount)
    self.parentNode:PushReddotToParent(diffCount)
  end
end
function reddot_node_base:PushReddotCount(diffCount)
  self.data.count = self.data.count + diffCount
  self.data.count = self.data.count >= 0 and self.data.count or 0
  if self.data.count <= 0 then
    self:HideReddot()
  end
end
function reddot_node_base:AddOrSubTotalReddotCount(diffCount)
end
function reddot_node_base:HideReddot()
  if self.data and self.data.tabId and self.reddotRoot then
    local pool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.reddot_pool)
    self.reddotRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    pool:Release(self.reddotRoot)
    self:SetReddotRoot(nil)
  end
end
function reddot_node_base:HideAllChildReddot()
  if self.childList and next(self.childList) then
    for _, childNode in pairs(self.childList) do
      childNode:HideReddot()
      childNode:HideAllChildReddot()
    end
  end
end
function reddot_node_base:GetAllNodeData(datas)
  datas = datas or {}
  datas[self.data.tabId] = self.data
  if self.childList and next(self.childList) then
    for _, childNode in pairs(self.childList) do
      childNode:GetAllNodeData(datas)
    end
  end
end
function reddot_node_base:GetOneReddotNode(tabId)
  if self.data.tabId == tabId then
    return self.data.tabId, self
  end
  if self.childList and next(self.childList) then
    for _, childNode in pairs(self.childList) do
      local id, node = childNode:GetOneReddotNode(tabId)
      if id == tabId then
        return id, node
      end
    end
  end
end
local class = require("class")
local object = require("object")
local Creddot_node_base = class(object, nil, reddot_node_base)
return Creddot_node_base