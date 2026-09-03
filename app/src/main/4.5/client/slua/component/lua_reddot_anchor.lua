local lua_reddot_anchor = {}
local StringUtil = require("common.string_util")
function lua_reddot_anchor:RegistEvents()
  self:_RegistEvents()
end
function lua_reddot_anchor:OnClose()
  self:_Reset()
end
function lua_reddot_anchor:_Reset()
  if self._childUI then
    self._childUI:Close()
    self._childUI = nil
    self.styleUIPath = nil
  end
  self.isRegisted = false
end
function lua_reddot_anchor:Bind(dataNode, dataKey, handleFunc, ...)
  if not dataNode then
    log_error(bWriteLog and "lua_reddot_anchor:Bind dataNode == nil")
    return
  end
  if self.dataNode == dataNode and self.dataKey == dataKey then
    return
  end
  self:UnBind()
  if self.CanvasPanel_Anchor and not self:_CheckIsRegistedToLimitationLogic() then
    local UIUtil = require("client.common.ui_util")
    UIUtil.SetWidgetVisible(self.CanvasPanel_Anchor, true)
  end
  self.  if handleFunc then
    local common = require("client.slua_ui_framework.common")
    local args = table.pack(...)
    function self.callBack(...)
      return common.CallCombinationArgs(handleFunc, args, ...)
    end
  end
  if dataNode == nil then
    return
  end
  local rootNode = dataNode
  local depth = 0
  if not rootNode or rootNode.GetParent == nil then
    return
  end
  while rootNode:GetParent() or rootNode.desc == nil do
    rootNode = rootNode:GetParent()
    depth = depth + 1
  end
  self.  self.systemName = rootNode.desc
  self.depth = dataNode.depth or depth
  self.num = 0
  self.  self:_RegistEvents()
end
function lua_reddot_anchor:_RegistEvents()
  local dataNode = self.dataNode
  if dataNode == nil or type(dataNode) ~= "table" or self.isRegisted then
    return
  end
  self.isRegisted = true
  local dataKey = self.dataKey
  self:AddDataListener(dataNode, dataKey and dataKey .. ".subID" or "subID", self._LoadStyle, self)
  if self.rootNode == dataNode then
    self:AddDataListener(dataNode, dataKey and dataKey .. ".desc" or "desc", self._SystemNameChange, self)
    self:AddDataListener(dataNode, dataKey and dataKey .. ".realCount" or "realCount", self._ShowReddot, self)
  else
    self:AddDataListener(dataNode, dataKey and dataKey .. ".newCount" or "newCount", self._ShowReddot, self)
  end
end
function lua_reddot_anchor:UnBind()
  local UIUtil = require("client.common.ui_util")
  self:SetWidgetVisibility(UIUtil.BoolToVisible(false))
  self:Dispose()
  self.isRegisted = false
  self.rootNode = nil
  self.dataNode = nil
  self.dataKey = nil
  self.systemName = ""
  self.depth = 0
  self.num = 0
  self.callBack = nil
  self.styleUIPath = nil
end
function lua_reddot_anchor:_LoadStyle(oldValue, value)
  self.subID = value
  if self.systemName == "" or value == nil then
    return
  end
  local isLeaf = self.dataNode.isLeafNode
  local reddot_config = require("client.slua.logic.reddot.reddot_config")
  local styleNo, text = reddot_config:GetReddotStyle(self.systemName, self.subID, self.depth, isLeaf)
  if not styleNo then
    return
  end
  if not self.CanvasPanel_Anchor then
    return
  end
  local styleUIPath = reddot_config:GetReddotStylePath(self.systemName, self.subID, self.depth, isLeaf)
  if self.styleUIPath ~= styleUIPath then
    if self._childUI then
      self._childUI:Close()
      self._childUI = nil
      self.styleUIPath = nil
    end
    self.    self:_CreateItem(styleUIPath, styleNo)
  end
  if text then
    self._childUI:SetTextTips(text)
  end
  self:_SetTextNum(self.num)
end
function lua_reddot_anchor:_SystemNameChange(_, systemName)
  self.  self:_LoadStyle(self.subID, self.subID)
end
function lua_reddot_anchor:_SetTextNum(num)
  if not self._childUI then
    return
  end
  if not self.styleUIPath then
    return
  end
  if not StringUtil.StrFind(self.styleUIPath, "Reddot_Anchor_Item02") then
    return
  end
  self._childUI:SetTextNum(num)
end
function lua_reddot_anchor:_ShowReddot(oldValue, value)
  local isShow = value ~= 0
  log(bWriteLog and string.format("lua_reddot_anchor:_ShowReddot systemName[%s] isShow[%s] key[%s]", self.systemName, isShow, self.dataKey))
  self.num = value
  if self.callBack then
    self.callBack(oldValue, value)
  else
    local UIUtil = require("client.common.ui_util")
    self:SetWidgetVisibility(UIUtil.BoolToVisible(isShow))
    local logic_reddot_limitation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_reddot_limitation)
    if self:_CheckIsRegistedToLimitationLogic() then
      logic_reddot_limitation:ToggleReddotActivation(self.Object, isShow)
    end
  end
  self:_SetTextNum(value)
end
function lua_reddot_anchor:_CheckIsRegistedToLimitationLogic()
  local logic_reddot_limitation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_reddot_limitation)
  if logic_reddot_limitation:CheckWidgetRegistered(self.Object) then
    return true
  end
  return false
end
function lua_reddot_anchor:ToggleReddotVisibilityByLimitation(bShouldShow)
  local UIUtil = require("client.common.ui_util")
  log(bWriteLog and string.format("lua_reddot_anchor:ToggleReddotVisibilityByLimitation systemName [%s], bShouldShow [%s]", tostring(self.systemName), tostring(bShouldShow)))
  UIUtil.SetWidgetVisible(self.CanvasPanel_Anchor, bShouldShow)
end
function lua_reddot_anchor:ShowRedPointByPath(path, styleNo)
  if self.styleUIPath == path then
    return
  end
  if self._childUI then
    self._childUI:Close()
    self._childUI = nil
    self.styleUIPath = nil
  end
  self.styleUIPath = path
  if path == nil or path == "" then
    return
  end
  self:_CreateItem(path, styleNo)
end
function lua_reddot_anchor:_CreateItem(path, styleNo)
  if self.__childUI then
    return
  end
  self._childUI = self:CreateChildWindowWithBpPath(self.CanvasPanel_Anchor, UIManager.UI_Config.Reddot_Anchor_Item, path)
  styleNo = styleNo or 0
  local reddot_slot_config = require("client.slua.logic.reddot.reddot_slot_config")
  local style = reddot_slot_config[styleNo]
  self._childUI:SetAnchorsOne(style.Anchors)
  self._childUI:SetOffsetsOne(style.Offsets)
end
local class = require("class")
local OverrideUIBase = require("client.slua_ui_framework.OverrideUIBase")
return class(OverrideUIBase, nil, lua_reddot_anchor)