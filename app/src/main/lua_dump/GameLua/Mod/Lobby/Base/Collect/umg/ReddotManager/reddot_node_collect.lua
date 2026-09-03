local reddot_node_collect = {}
local reddotPath = {
  reddotRoot = "/Game/UMG/UI_Logic/Reddot/Reddot_Anchor_Item05.Reddot_Anchor_Item05",
  boxReddotRoot = "/Game/UMG/UI_Logic/Reddot/Reddot_Anchor_Item03.Reddot_Anchor_Item03"
}
function reddot_node_collect:ctor(_, _, parentNode, data)
  self.boxReddotRoot = nil
  self.reddotMountRoot = nil
  self.curVersion = nil
end
function reddot_node_collect:SetBoxReddotRoot(boxReddotRoot)
  self.end
function reddot_node_collect:GetBoxReddotRoot()
  return self.boxReddotRoot
end
function reddot_node_collect:SetReddotMountRoot(reddotMountRoot)
  self.end
function reddot_node_collect:GetReddotMountRoot()
  return self.reddotMountRoot
end
function reddot_node_collect:SetCurVersion(curVersion)
  self.end
function reddot_node_collect:InitReddotData()
  local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
  local localDataCache = reddot_node_collect_manager:GetOneReddotLocalData(self.data.tabId)
  if self.data.beginVersion == 0 and self.data.endVersion == 0 then
    self.data.count = 0
  elseif localDataCache then
    local bUpdate = true
    if localDataCache.beginVersion == self.data.beginVersion and localDataCache.endVersion == self.data.endVersion then
      self:ReSetReddotData(localDataCache)
      bUpdate = false
    end
    local bOutEndVersion = self.data and self.data.endVersion and 0 < self.data.endVersion and self.data.endVersion < self.curVersion or false
    local bOutBeginVersion = self.data and self.data.beginVersion and self.data.beginVersion > self.curVersion or false
    if bOutEndVersion or bOutBeginVersion then
      self.data.count = 0
    elseif bUpdate then
      self.data.count = 1
    end
  else
    local bOutEndVersion = self.data and self.data.endVersion and 0 < self.data.endVersion and self.data.endVersion < self.curVersion or false
    local bOutBeginVersion = self.data and self.data.beginVersion and self.data.beginVersion > self.curVersion or false
    if bOutEndVersion or bOutBeginVersion then
      self.data.count = 0
    else
      self.data.count = 1
    end
  end
  self:PushReddotToParent(0 < self.data.count and 1 or 0)
  self:AddOrSubTotalReddotCount(0 < self.data.count and 1 or 0)
end
function reddot_node_collect:CreateReddotNodeWithParentTabId()
  local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
  if not self.parentNode and self.data.parentTabId and self.data.tabId ~= reddot_node_collect_manager:GetCollectTab().collect_lobby then
    local parentNode = reddot_node_collect_manager:CreateReddotNode(self.data.parentTabId)
    self:SetParentNode(parentNode)
  end
end
function reddot_node_collect:AddOrSubTotalReddotCount(diffCount)
  local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
  reddot_node_collect_manager:AddOrSubTotalReddotCount(diffCount)
end
function reddot_node_collect:CheckCanShowNewReddot(reddotMountRoot)
  if not reddotMountRoot then
    log(bWriteLog and "xcc reddot_node_collect:CheckCanShowNewReddot can't show new reddot with not reddotMountRoot " .. tostring(self.data.tabId))
    return false
  end
  local bCount = self.data and self.data.count and self.data.count <= 0 and tonumber(self.data.tabId or 0) ~= 8108
  if bCount then
    log(bWriteLog and "xcc reddot_node_collect:CheckCanShowNewReddot can't show new reddot with count or version error " .. tostring(self.data.tabId))
    return false
  end
  return true
end
function reddot_node_collect:ShowNewReddot(reddotMountRoot)
  if not self:CheckCanShowNewReddot(reddotMountRoot) then
    self:HideReddot()
    return false
  end
  self:AddReddot("reddotRoot", reddotMountRoot)
  log(bWriteLog and "xcc reddot_node_collect_manager:ShowNewReddot " .. tostring(self.data.tabId))
  self:HideBoxReddot()
  return true
end
function reddot_node_collect:ShowBoxReddot(reddotMountRoot, bShow)
  if bShow == false then
    self:HideBoxReddot()
    return false
  end
  if not reddotMountRoot then
    log(bWriteLog and "xcc reddot_node_collect:ShowBoxReddot can't show new reddot with not reddotMountRoot " .. tostring(self.data.tabId))
    self:HideBoxReddot()
    return false
  end
  self:AddReddot("boxReddotRoot", reddotMountRoot)
  log(bWriteLog and "xcc reddot_node_collect:ShowBoxReddot" .. tostring(self.data.tabId))
  self:HideReddot()
  return true
end
function reddot_node_collect:AddReddot(reddotName, reddotMountRoot)
  reddotMountRoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if not self[reddotName] then
    local pool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.reddot_pool)
    self[reddotName] = pool:Get(reddotPath[reddotName])
    self[reddotName]:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  reddotMountRoot.CanvasPanel_Anchor:AddChild(self[reddotName])
  self:SetReddotMountRoot(reddotMountRoot)
  local reddot_slot_config = require("client.slua.logic.reddot.reddot_slot_config")
  local style = reddot_slot_config[0]
  self[reddotName].Slot:SetAnchors(style.Anchors)
  self[reddotName].Slot:SetOffsets(style.Offsets)
end
function reddot_node_collect:HideReddot()
  if self.data and self.data.tabId and self.reddotRoot then
    local pool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.reddot_pool)
    self.reddotRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    pool:Release(self.reddotRoot)
    self:SetReddotRoot(nil)
    local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
    reddot_node_collect_manager:RemoveReddotWithMapp(self.data.tabId)
  end
end
function reddot_node_collect:HideBoxReddot(reddotMountRoot)
  if self.boxReddotRoot and (self.reddotMountRoot == reddotMountRoot or not reddotMountRoot) then
    local pool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.reddot_pool)
    self.boxReddotRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    pool:Release(self.boxReddotRoot)
    self:SetBoxReddotRoot(nil)
    self:SetReddotMountRoot(nil)
    local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
    reddot_node_collect_manager:RemoveReddotWithMapp(self.data.tabId)
  end
end
function reddot_node_collect:HideAllChildBoxReddot()
  if self.childList and next(self.childList) then
    for _, childNode in pairs(self.childList) do
      childNode:HideBoxReddot()
      childNode:HideAllChildBoxReddot()
    end
  end
end
local class = require("class")
local reddot_node_base = require("GameLua.Mod.Lobby.Base.Collect.umg.ReddotManager.reddot_node_base")
local Creddot_node_collect = class(reddot_node_base, nil, reddot_node_collect)
return Creddot_node_collect