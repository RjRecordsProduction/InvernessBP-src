local logic_buffer_panel_for_act = {}
local ActLogic = {
  CrazyWeekendAct = {
    isModule = true,
    path = "logic_crazy_weekend_teamUp_activity",
    actName = "CrazyWeekendAct"
  },
  NewbieABTestAct = {
    isModule = true,
    path = "logic_newbie_task_segment_activity",
    actName = "NewbieABTestAct"
  }
}
local BufferPanelTitleLocID = {
  WorldCupAct = 44255,
  CrazyWeekendAct = -1,
  NewbieABTestAct = 75363
}
local BufferEntryConfig = {
  CrazyWeekendAct = {
    entryBG = "/Game/UMG/Texture_200/Lobby_NoAtlas/Lobby_Activity/CrazyWeeken/CrazyWeekend_Image_ItemBG.CrazyWeekend_Image_ItemBG",
    entryIcon = "",
    titleID = 85751,
    childBGWidgetPath = "/Game/UMG/UI_BP/CrazyWeekend/Item/CrazyWeekend_Tips_Item_UIBP.CrazyWeekend_Tips_Item_UIBP",
    queuePos = 1
  },
  NewbieABTestAct = {
    entryBG = "/Game/UMG/Texture_200/Lobby_NoAtlas/Lobby_Activity/NewbieActivity/NewbieActivity_Image_410ItemBG.NewbieActivity_Image_410ItemBG",
    entryIcon = "/Game/UMG/Texture_200/Lobby_NoAtlas/Lobby_Activity/NewbieActivity/NewbieActivity_Icon_410Role.NewbieActivity_Icon_410Role",
    titleID = 75363,
    queuePos = 2
  }
}
function logic_buffer_panel_for_act.CheckActIsOpen(actName)
  if not actName then
    log(bWriteLog and "logic_buffer_panel_for_act.CheckActIsOpen actName is nil")
    return false
  end
  local isOpen = false
  local cfg = ActLogic[actName]
  local logic = {}
  if not cfg then
    log(bWriteLog and "logic_buffer_panel_for_act.CheckActIsOpen cfg is nil")
    return false
  end
  if cfg.isModule then
    local tb = ModuleManager.LobbyModuleConfig[cfg.path]
    logic = ModuleManager.GetModule(tb)
    isOpen = logic:IsOpen()
  else
    logic = require(cfg.path)
    isOpen = logic.IsOpen()
  end
  log(bWriteLog and "logic_buffer_panel_for_act.CheckActIsOpen actName = " .. tostring(actName) .. " isOpen = " .. tostring(isOpen))
  return isOpen
end
function logic_buffer_panel_for_act.CheckValidActTypeInAct(actName)
  if not actName then
    log(bWriteLog and "logic_buffer_panel_for_act.CheckActIsOpen actName is nil")
    return false
  end
  local data
  local hasData = false
  local cfg = ActLogic[actName]
  local logic = {}
  if not cfg then
    log(bWriteLog and "logic_buffer_panel_for_act.CheckActIsOpen cfg is nil")
    return false
  end
  if cfg.isModule then
    local tb = ModuleManager.LobbyModuleConfig[cfg.path]
    logic = ModuleManager.GetModule(tb)
    hasData, data = logic:CheckValidActTypeInAct()
  else
    logic = require(cfg.path)
    hasData, data = logic.CheckValidActTypeInAct()
  end
  log(bWriteLog and "logic_buffer_panel_for_act.CheckActIsOpen actName = " .. tostring(actName) .. " hasData = " .. tostring(hasData))
  return data
end
function logic_buffer_panel_for_act.GoToActMainUI(actName)
  log(bWriteLog and "logic_buffer_panel_for_act.GoToActMainUI" .. tostring(actName))
  if not actName then
    log(bWriteLog and "logic_buffer_panel_for_act.CheckActIsOpen actName is nil")
    return false
  end
  local cfg = ActLogic[actName]
  local logic = {}
  if not cfg then
    log(bWriteLog and "logic_buffer_panel_for_act.CheckActIsOpen cfg is nil")
    return false
  end
  if cfg.isModule then
    local tb = ModuleManager.LobbyModuleConfig[cfg.path]
    logic = ModuleManager.GetModule(tb)
    logic:GoToActMainUI()
  else
    logic = require(cfg.path)
    logic.GoToActMainUI()
  end
end
function logic_buffer_panel_for_act.GetActListForSegmentBuffer()
  log(bWriteLog and "logic_buffer_panel_for_act.GetActListForSegmentBuffer")
  local actList = {}
  for actName, _ in pairs(BufferPanelTitleLocID) do
    local isOpen = logic_buffer_panel_for_act.CheckActIsOpen(actName)
    if isOpen then
      local data = logic_buffer_panel_for_act.CheckValidActTypeInAct(actName)
      if data then
        local entryCfg = BufferEntryConfig[actName]
        local dataList = {
          data = data,
          actName = actName,
          entryBG = entryCfg and entryCfg.entryBG,
          entryIcon = entryCfg and entryCfg.entryIcon,
          actDetailID = entryCfg and entryCfg.titleID,
          childBGWidgetPath = entryCfg and entryCfg.childBGWidgetPath
        }
        local queuePos = entryCfg and entryCfg.queuePos or 999
        actList[queuePos] = dataList
      end
    end
  end
  return actList
end
function logic_buffer_panel_for_act.GetBufferPanelTitle(curAct)
  log(bWriteLog and "logic_buffer_panel_for_act.GetBufferPanelTitle curAct = " .. tostring(curAct))
  local isOpen = logic_buffer_panel_for_act.CheckActIsOpen(curAct)
  if not isOpen then
    log(bWriteLog and "logic_buffer_panel_for_act.GetBufferPanelTitle isOpen is false")
    return false
  end
  if BufferPanelTitleLocID[curAct] then
    return LocUtil.GetLocalizeResStr(BufferPanelTitleLocID[curAct])
  end
end
return logic_buffer_panel_for_act