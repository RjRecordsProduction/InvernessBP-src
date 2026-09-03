local ui_jump_manager = {}
local ui_show_manager = require("client.common.uibase.ui_show_manager")
local local local local local local local local table_insert = table.insert
local table_remove = table.remove
local _uiStack = {}
local _subUIMap = {}
local _isInit = false
local _jumpID2ModuleConfig
local _isHandling = false
local _handleList = {}
local MAX_HANDLE_NUM = 5
local _pandoraBackNode = {}
local _NextModuleDuplicationMap = {}
function ui_jump_manager.Init()
  log(bWriteLog and "[jonahwei]ui_jump_manager:Init")
  if _isInit then
    return
  end
  if not _jumpID2ModuleConfig then
    _jumpID2ModuleConfig = {}
    local JumpModuleConfig = require("client.module_framework.lobby.JumpModuleConfig")
    for _, config in pairs(JumpModuleConfig) do
      if config.jumpModuleID then
        _jumpID2ModuleConfig[config.jumpModuleID] = config
      end
    end
  end
  _isInit = true
end
function ui_jump_manager.Stop()
  log(bWriteLog and "[jonahwei]ui_jump_manager:Stop")
  _isInit = false
end
function ui_jump_manager.Clear()
  ui_jump_manager._ClearList()
  _NextModuleDuplicationMap = {}
  local oldStack = _uiStack
  local newStack = {}
  _pandoraBackNode = {}
  if not ui_jump_manager.IsInit() then
    _uiStack = newStack
    _subUIMap = {}
    log(bWriteLog and "[jonahwei]ui_jump_manager:Clear  force")
    return
  else
  end
  if not ui_jump_manager.IsEmpty() then
    local lobbyNode = {
      moduleID = BP_ENUM_MODULE_LOBBY,
      nodeList = {}
    }
    for _, v in ipairs(oldStack) do
      if v.moduleID == BP_ENUM_MODULE_LOBBY then
        if v.uiData and v.uiData._FrameSubUIList then
          lobbyNode.uiData = {
            _FrameSubUIList = {}
          }
          for _, subV in ipairs(v.uiData._FrameSubUIList) do
            if subV.config == UIManager.UI_Config.UGC_Hall_UIBP then
              table_insert(lobbyNode.uiData._FrameSubUIList, subV)
            end
          end
        end
        break
      end
    end
    table_insert(newStack, lobbyNode)
    table_remove(oldStack, 1)
  end
  local top = ui_jump_manager.GetTopNode()
  if top then
    table_insert(newStack, top)
    table_remove(oldStack)
  end
  _uiStack = newStack
  for _, v in ipairs(oldStack) do
    if _subUIMap[v.moduleID] then
      _subUIMap[v.moduleID] = nil
    end
    if v.isModuleNode then
      ui_jump_manager._OnModuleNodeClear(v)
    end
  end
  EventSystem:postEvent(EVENTTYPE_JUMP, EVENTID_JUMP_MODULE_CLEAR, oldStack)
  log(bWriteLog and "[jonahwei]ui_jump_manager:Clear")
end
function ui_jump_manager.RemoveModule(moduleID)
  local index
  for i, v in ipairs(_uiStack) do
    if v.moduleID == moduleID then
      index = i
      break
    end
  end
  if index == nil then
    log(bWriteLog and "[jonahwei]ui_jump_manager:RemoveModule not found " .. tostring(moduleID))
    return
  end
  if index == #_uiStack then
    log(bWriteLog and "[jonahwei]ui_jump_manager:RemoveModule can not remove top " .. tostring(moduleID))
    return
  end
  local newStack = {}
  local removeList = {}
  for k, v in ipairs(_uiStack) do
    if v.moduleID ~= moduleID then
      table_insert(newStack, v)
    else
      if _subUIMap[v.moduleID] then
        _subUIMap[v.moduleID] = nil
      end
      if _pandoraBackNode and _pandoraBackNode.preModule == v.moduleID then
        if _uiStack[k + 1] then
          _pandoraBackNode.preModule = _uiStack[k + 1].moduleID
        else
          ui_jump_manager:BanPandoraNode()
        end
      end
      if v.isModuleNode then
        ui_jump_manager._OnModuleNodeClear(v)
      end
      table_insert(removeList, v)
    end
  end
  log(bWriteLog and "[jonahwei]ui_jump_manager:RemoveModule")
  _uiStack = newStack
  EventSystem:postEvent(EVENTTYPE_JUMP, EVENTID_JUMP_MODULE_CLEAR, removeList)
end
function ui_jump_manager.ModuleInStack(moduleID)
  if not moduleID then
    return false
  end
  for _, v in ipairs(_uiStack) do
    if v.moduleID == moduleID then
      return true
    end
  end
  return false
end
function ui_jump_manager.EnableNextModuleDuplication(moduleID, keyWord)
  log(bWriteLog and "ui_jump_manager.EnableNextModuleDuplication moduleID=" .. tostring(moduleID) .. ", keyWord=" .. tostring(keyWord))
  if not moduleID then
    return
  end
  if keyWord == nil then
    keyWord = true
  end
  _NextModuleDuplicationMap[moduleID] = keyWord
end
function ui_jump_manager.AttachPandoraNode(backModule)
  local preModule
  local top = ui_jump_manager.GetTopNode()
  if top then
    preModule = top.moduleID
  else
    log(bWriteLog and "ui_jump_manager.AttachPandoraNode not top")
    return
  end
  if not _pandoraBackNode then
    log(bWriteLog and "ui_jump_manager.AttachPandoraNode not pandoraBackNode")
    return
  end
  log(bWriteLog and "ui_jump_manager.AttachPandoraNode " .. tostring(preModule) .. " " .. tostring(backModule))
  _pandoraBackNode = {preModule = preModule, backModule = backModule}
end
function ui_jump_manager:BanPandoraNode()
  log(bWriteLog and "ui_jump_manager:BanPandoraNode")
  _pandoraBackNode = nil
end
function ui_jump_manager.IsEmpty()
  local isEmpty = #_uiStack == 0
  log(bWriteLog and "[jonahwei]ui_jump_manager:IsEmpty " .. tostring(isEmpty))
  return isEmpty
end
function ui_jump_manager.IsHandling()
  return _isHandling
end
function ui_jump_manager.OpenJumpModule(jumpModuleID, ctorData)
  log(bWriteLog and "[jonahwei]ui_jump_manager:OpenJumpModule: " .. tostring(jumpModuleID))
  if not jumpModuleID then
    return
  end
  if not ui_jump_manager.IsInit() then
    log(bWriteLog and "[jonahwei]ui_jump_manager:OpenJumpModule not init! ")
    return
  end
  local jumpModuleConfig = _jumpID2ModuleConfig[jumpModuleID]
  if not jumpModuleConfig then
    log(bWriteLog and "[jonahwei]ui_jump_manager:OpenJumpModule jumpModuleConfig not found : " .. tostring(jumpModuleID))
    return
  end
  local JumpModuleBase = ModuleManager.GetModule(jumpModuleConfig)
  if not JumpModuleBase then
    log(bWriteLog and "[jonahwei]ui_jump_manager:OpenJumpModule JumpModuleBase not found : " .. tostring(jumpModuleID))
    return
  end
  if JumpModuleBase:JumpCheck(ctorData) then
    ui_jump_manager.OnModuleOpen(jumpModuleConfig, ctorData)
  end
end
function ui_jump_manager.CloseJumpModule(jumpModuleID)
  log(bWriteLog and "[jonahwei]ui_jump_manager:CloseJumpModule: " .. tostring(jumpModuleID))
  if not jumpModuleID or not _jumpID2ModuleConfig then
    return
  end
  local jumpModuleConfig = _jumpID2ModuleConfig[jumpModuleID]
  if not jumpModuleConfig then
    log(bWriteLog and "[jonahwei]ui_jump_manager:CloseJumpModule jumpModuleConfig not found : " .. tostring(jumpModuleID))
    return
  end
  local JumpModuleBase = ModuleManager.GetModule(jumpModuleConfig)
  if not JumpModuleBase then
    log(bWriteLog and "[jonahwei]ui_jump_manager:CloseJumpModule JumpModuleBase not found : " .. tostring(jumpModuleID))
    return
  end
  ui_jump_manager.OnModuleClose(jumpModuleConfig)
end
function ui_jump_manager.OnModuleOpen(config, ctorData)
  if _isHandling then
    log(bWriteLog and "[jonahwei]ui_jump_manager:OnModuleOpen    isHandling")
    ui_jump_manager._AddHandleNode(true, config, ctorData)
    return
  end
  _isHandling = true
  local preTop = ui_jump_manager.GetTopNode()
  if preTop == nil then
    preTop = {
      moduleID = BP_ENUM_MODULE_LOBBY
    }
    log(bWriteLog and "[jonahwei]ui_jump_manager:_PushLobbyNode")
    table_insert(_uiStack, preTop)
  else
    local data
    if preTop.isModuleNode then
      local module = ModuleManager.GetModule(preTop.config)
      if module then
        data = module:GetDataForJumpBack()
      end
    else
      local ui = UIManager.GetUI(preTop.config)
      if ui then
        data = ui:GetDataForJumpBack()
      end
    end
    if data then
      preTop.uiData = data.uiData
      preTop.ctorData = data.ctorData
    else
      preTop.uiData = nil
    end
  end
  if _subUIMap[preTop.moduleID] then
    local _FrameSubUIList = {}
    for _, subConfig in ipairs(_subUIMap[preTop.moduleID]) do
      local subUINode = {config = subConfig}
      local ui = UIManager.GetUI(subConfig)
      if ui then
        if subConfig.handleJumpEvent == ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW then
          local subUIData = ui:GetDataForJumpBack()
          subUINode.ctorData = subUIData and subUIData.ctorData or nil
          subUINode.uiData = subUIData and subUIData.uiData or nil
        end
        table_insert(_FrameSubUIList, subUINode)
      end
    end
    if 0 < #_FrameSubUIList then
      if not preTop.uiData then
        preTop.uiData = {_FrameSubUIList = _FrameSubUIList}
      else
        preTop.uiData.      end
    end
    _subUIMap[preTop.moduleID] = nil
  end
  ui_show_manager.SetCloseWaitingInfo(preTop)
  ui_jump_manager._RemoveDuplicates(config)
  ui_jump_manager._PushNode(config, ctorData)
  return ui_show_manager.Handle(true, config)
end
function ui_jump_manager.OnModuleClose(config)
  if _isHandling then
    log(bWriteLog and "[jonahwei]ui_jump_manager:OnModuleClose    isHandling")
    ui_jump_manager._AddHandleNode(false, config)
    return
  end
  _isHandling = true
  if _pandoraBackNode and _pandoraBackNode.preModule == config.jumpModuleID then
    ui_jump_manager._ConsumePandoraNode()
  end
  local preTop = ui_jump_manager.GetTopNode()
  if not preTop or preTop.moduleID ~= config.jumpModuleID then
    log(bWriteLog and "[jonahwei]ui_jump_manager:OnModuleClose jumpModuleID not match top" .. tostring(config.jumpModuleID))
    ui_jump_manager.RemoveModule(config.jumpModuleID)
    ui_jump_manager.OnHandleFinish()
    return
  else
    ui_jump_manager._PopNode()
  end
  local top = ui_jump_manager._GetTopNodeForJumpBack()
  if top then
    if top.moduleID == BP_ENUM_MODULE_LOBBY then
      ui_jump_manager._PopLobbyNode(top)
    else
      ui_show_manager.SetShowWaitingInfo(top)
    end
  end
  ui_show_manager.Handle(false, config)
end
function ui_jump_manager.OnSubUIOpen(config)
  local currentModule = ui_jump_manager._GetCurrentModule()
  if not _subUIMap[currentModule] then
    _subUIMap[currentModule] = {}
  end
  for i, subConfig in ipairs(_subUIMap[currentModule]) do
    if subConfig.keyName == config.keyName then
      log(bWriteLog and "ui_jump_manager: OnSubUIOpen duplicate!" .. tostring(currentModule) .. tostring(config.keyName))
      table_remove(_subUIMap[currentModule], i)
    end
  end
  table_insert(_subUIMap[currentModule], config)
end
function ui_jump_manager.OnSubUIClose(config)
  local currentModule = ui_jump_manager._GetCurrentModule()
  if _subUIMap[currentModule] then
    for i, subConfig in ipairs(_subUIMap[currentModule]) do
      if subConfig.keyName == config.keyName then
        log(bWriteLog and "ui_jump_manager: OnSubUIClose" .. tostring(currentModule) .. tostring(config.keyName))
        table_remove(_subUIMap[currentModule], i)
        return
      end
    end
  end
  log(bWriteLog and "ui_jump_manager: OnSubUIClose not found! " .. tostring(currentModule) .. tostring(config.keyName))
end
function ui_jump_manager.OnHandleFinish()
  _isHandling = false
  ui_jump_manager._ConsumeHandleNode()
end
function ui_jump_manager.IsInit()
  return _isInit == true
end
function ui_jump_manager.GetTopNode()
  local index = #_uiStack
  if index == 0 then
    return nil
  end
  return _uiStack[index]
end
function ui_jump_manager.GetUIStack()
  return _uiStack
end
function ui_jump_manager._AddHandleNode(isShow, config, ctorData)
  if #_handleList >= MAX_HANDLE_NUM then
    log(bWriteLog and "[jonahwei]ui_jump_manager:_AddHandleNode, OVERFLOW! jumpModuleID = " .. tostring(config.jumpModuleID))
  end
  local node = {
    config = config,
    isShow = isShow,
      }
  log(bWriteLog and "[jonahwei]ui_jump_manager:_AddHandleNode, jumpModuleID = " .. tostring(config.jumpModuleID))
  table_insert(_handleList, node)
end
function ui_jump_manager._ConsumeHandleNode()
  if not _handleList or #_handleList == 0 then
    return
  end
  local node = _handleList[1]
  table_remove(_handleList, 1)
  log(bWriteLog and "[jonahwei]ui_jump_manager:_ConsumeHandleNode, jumpModuleID = " .. tostring(node.config.jumpModuleID))
  if node.isShow then
    ui_jump_manager.OnModuleOpen(node.config, node.ctorData)
  else
    ui_jump_manager.OnModuleClose(node.config)
  end
end
function ui_jump_manager._ClearList()
  _handleList = {}
end
function ui_jump_manager._RemoveDuplicates(config)
  if not _pandoraBackNode then
    _pandoraBackNode = {}
  end
  if not config then
    return
  end
  local moduleID = config.jumpModuleID
  local removeKeyWorld = _NextModuleDuplicationMap[moduleID]
  local index
  for i, v in ipairs(_uiStack) do
    if v.moduleID == moduleID then
      if removeKeyWorld == true then
        log(bWriteLog and "ui_jump_manager._RemoveDuplicates removeKeyWorld true")
      elseif removeKeyWorld == nil or removeKeyWorld == v.removeKeyWorld then
        index = i
        break
      end
    end
  end
  if index == nil then
    return
  end
  local stackLength = #_uiStack
  if index < stackLength then
    local removeList = {}
    for i_remove = index + 1, stackLength do
      local removeNode = _uiStack[i_remove]
      if _subUIMap[removeNode.moduleID] then
        _subUIMap[removeNode.moduleID] = nil
      end
      if removeNode.isModuleNode then
        ui_jump_manager._OnModuleNodeClear(removeNode)
      end
      if _pandoraBackNode.preModule == removeNode.moduleID then
        ui_jump_manager.BanPandoraNode()
      end
      table_insert(removeList, removeNode)
    end
    EventSystem:postEvent(EVENTTYPE_JUMP, EVENTID_JUMP_MODULE_CLEAR, removeList)
  end
  for i_rare = stackLength, index, -1 do
    table_remove(_uiStack, i_rare)
  end
end
function ui_jump_manager._GetTopNodeForJumpBack()
  while true do
    local top = ui_jump_manager.GetTopNode()
    if not top or not top.isModuleNode then
      return top
    end
    local module = ModuleManager.GetModule(top.config)
    if module and module:JumpCheck(top.ctorData, top.uiData) then
      return top
    end
    log(bWriteLog and "ui_jump_manager._GetTopNodeForJumpBack JumpCheck false " .. tostring(top.ModuleName))
    table_remove(_uiStack)
  end
  return nil
end
function ui_jump_manager._PushNode(config, ctorData)
  local node = {
    moduleID = config.jumpModuleID,
    config = config,
    uiData = nil,
    ctorData = ctorData,
    isModuleNode = false,
    removeKeyWorld = _NextModuleDuplicationMap[config.jumpModuleID]
  }
  _NextModuleDuplicationMap[config.jumpModuleID] = nil
  if config == _jumpID2ModuleConfig[config.jumpModuleID] then
    node.isModuleNode = true
    log(bWriteLog and "[jonahwei]ui_jump_manager:_PushNode, ModuleName = " .. tostring(config.ModuleName))
  else
    log(bWriteLog and "[jonahwei]ui_jump_manager:_PushNode, keyName = " .. tostring(config.keyName))
  end
  table_insert(_uiStack, node)
  ui_show_manager.SetShowWaitingInfo(node)
end
function ui_jump_manager._PopNode()
  local top = ui_jump_manager.GetTopNode()
  if top then
    if top.isModuleNode then
      log(bWriteLog and "[jonahwei]ui_jump_manager:_PopNode, ModuleName = " .. tostring(top.config.ModuleName))
    else
      log(bWriteLog and "[jonahwei]ui_jump_manager:_PopNode, keyName = " .. tostring(top.config.keyName))
    end
    table_remove(_uiStack)
    if _subUIMap[top.moduleID] then
      local _FrameSubUIList = {}
      for _, subConfig in ipairs(_subUIMap[top.moduleID]) do
        local ui = UIManager.GetUI(subConfig)
        if ui then
          local subUINode = {config = subConfig}
          table_insert(_FrameSubUIList, subUINode)
        end
      end
      if 0 < #_FrameSubUIList then
        if not top.uiData then
          top.uiData = {_FrameSubUIList = _FrameSubUIList}
        else
          top.uiData.        end
      end
      _subUIMap[top.moduleID] = nil
    end
    ui_show_manager.SetCloseWaitingInfo(top)
  end
  return top
end
function ui_jump_manager._PopLobbyNode(node)
  log(bWriteLog and "[jonahwei]ui_jump_manager:_PopLobbyNode")
  _uiStack = {}
  ui_show_manager.SetShowWaitingInfo(node)
end
function ui_jump_manager._OnModuleNodeClear(node)
  local module = ModuleManager.GetModule(node.config)
  if module then
    module:OnClearJump(node.ctorData, node.uiData)
  end
end
function ui_jump_manager._GetCurrentModule()
  local top = ui_jump_manager.GetTopNode()
  if top then
    return top.moduleID
  end
  return BP_ENUM_MODULE_LOBBY
end
function ui_jump_manager._ConsumePandoraNode()
  log(bWriteLog and "ui_jump_manager._ConsumePandoraNode " .. tostring(_pandoraBackNode.backModule) .. " " .. tostring(_pandoraBackNode.preModule))
  if _pandoraBackNode.backModule then
    local pandora_common_protocol = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.pandora_common_protocol)
    pandora_common_protocol:SendShow(_pandoraBackNode.backModule)
  end
  _pandoraBackNode = {}
end
return ui_jump_manager