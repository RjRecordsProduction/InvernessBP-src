local xmission_redpoint_data = {}
local redpoint
local isInited = false
local delegateContainer
local guideIDConfig = {BAGEXTEND = 1000001}
local GenDefaultTabData = function()
  return {
    newCount = 0,
    instanceId = {_isLeaf = true}
  }
end
local GenDefaultData = function()
  return {newCount = 0}
end
local GenerateData = function()
  local data = {
    newCount = 0,
    pages = {}
  }
  local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
  local config = require("client.slua.umg.TxMission.xMission.wardrobe.xmission_wardrobe_config")
  for _, pageConfig in pairs(config.PageTab_Config) do
    if pageConfig.pageId ~= xMission_macro.ENUM_WardrobePage.ENUM_WardrobePage_All then
      data.pages[pageConfig.pageId] = GenDefaultTabData()
    end
  end
  for _, id in pairs(guideIDConfig) do
    data.pages[id] = GenDefaultData()
  end
  return data
end
local ClearListeners = function()
  if delegateContainer then
    delegateContainer:Dispose()
    delegateContainer = nil
  end
end
local InitData = function()
  if isInited then
    return
  end
  isInited = true
  ClearListeners()
  local delegate_container = require("common.delegate_container")
  delegateContainer = delegate_container()
  local data = GenerateData()
  local super_data = require("common.super_data")
  if redpoint == nil then
    redpoint = super_data.CreateSuperData(data)
  else
    for k, v in pairs(data) do
      redpoint[k] = v
    end
  end
  for pageId, page in pairs(redpoint.pages) do
    local callback = function(oldValue, value)
      if oldValue == 0 and 0 < value then
        redpoint.newCount = redpoint.newCount + 1
      elseif 0 < oldValue and value == 0 then
        redpoint.newCount = math.max(0, redpoint.newCount - 1)
      end
    end
    delegateContainer:AddDataListener(page, "newCount", callback)
  end
  local xmission_wardrobe_data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
  local pageData = xmission_wardrobe_data:GetCurrentPageData()
  delegateContainer:AddDataListener(pageData, "pageId", function(oldValue, value)
    local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
    if value > xMission_macro.ENUM_WardrobePage.ENUM_WardrobePage_All then
      xmission_redpoint_data.OnSelectPage(value)
    end
  end)
end
local ClearData = function()
  ClearListeners()
  redpoint = nil
  isInited = false
end
function xmission_redpoint_data.OnXMissionWardrobeDataInit(eventID, eventType, items)
  log(bWriteLog and "xmission_redpoint_data.OnXMissionWardrobeDataInit")
  InitData()
  for _, v in pairs(items) do
    local resId = v.item_id
    local insID = v.inst_id
    local page = xmission_redpoint_data.GetPageByResId(resId)
    if page and v.new == true and not page.instanceId[insID] then
      page.instanceId[insID] = true
      page.newCount = page.newCount + 1
    end
  end
end
function xmission_redpoint_data.OnItemChange(eventID, eventType, item)
  log(bWriteLog and "xmission_redpoint_data.OnItemChange")
  if not item then
    return
  end
  local insID = item.inst_id
  local resId = item.item_id
  local page = xmission_redpoint_data.GetPageByResId(resId)
  if not page then
    log_error("xmission_redpoint_data OnItemChange get nil " .. tostring(resId))
  elseif item.new == true and not page.instanceId[insID] then
    page.instanceId[insID] = true
    page.newCount = page.newCount + 1
    log(bWriteLog and "xmission_redpoint_data.OnItemChange +1")
  elseif item.new == false and page.instanceId[insID] then
    page.newCount = math.max(0, page.newCount - 1)
    page.instanceId[insID] = nil
    log(bWriteLog and "xmission_redpoint_data.OnItemChange -1")
  end
end
function xmission_redpoint_data.OnGameStateChange(eventType, eventID, gameState)
  if gameState.current == GameStatus.Lobby then
    InitData()
  elseif gameState.current == GameStatus.Login then
    ClearData()
  end
end
function xmission_redpoint_data.OnSeasonChange(eventType, eventID)
  if redpoint then
    for _, v in pairs(redpoint.pages) do
      v.newCount = 0
    end
  end
  ClearData()
end
function xmission_redpoint_data.OnBagExtendGuideChange(eventType, eventID, guideValue)
  local logic_xmission_bag_extend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_bag_extend)
  local page = xmission_redpoint_data.GetPage(guideIDConfig.BAGEXTEND)
  if not page then
    return
  end
  if guideValue == 1 and page.newCount == 0 then
    page.newCount = page.newCount + 1
  elseif guideValue == 2 and 1 <= page.newCount then
    page.newCount = math.max(0, page.newCount - 1)
  end
end
function xmission_redpoint_data.GetPage(pageId)
  if redpoint then
    return redpoint.pages[pageId]
  end
  return nil
end
function xmission_redpoint_data.GetData()
  return redpoint
end
function xmission_redpoint_data.GetPageIdByResId(resId)
  local xmission_wardrobe_data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
  local itemCfg = xmission_wardrobe_data.FastGetItemData(resId)
  if not itemCfg then
    return
  end
  return itemCfg.WardrobeTab
end
function xmission_redpoint_data.GetPageByResId(resId)
  local pageId = xmission_redpoint_data.GetPageIdByResId(resId)
  return xmission_redpoint_data.GetPage(pageId)
end
function xmission_redpoint_data.IsItemNew(insId)
  local xmission_wardrobe_data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
  local item = xmission_wardrobe_data.GetItemByInstID(insId)
  if item then
    local page = xmission_redpoint_data.GetPageByResId(item.item_id)
    if page == nil then
      return false
    end
    return page.instanceId[insId] ~= nil
  end
  return false
end
function xmission_redpoint_data.OnSelectPage(pageId)
  local page = xmission_redpoint_data.GetPage(pageId)
  if not page then
    log_error("xmission_redpoint_data can't select pageId: " .. tostring(pageId))
    return
  end
  local instIds = {}
  for instId, _ in pairs(page.instanceId) do
    table.insert(instIds, instId)
  end
  page.instanceId = {}
  local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
  TxMissionHandler.send_metro_wipe_new_req(instIds)
  page.newCount = 0
end
function xmission_redpoint_data.TouchItem(insId)
  log(bWriteLog and "xmission_redpoint_data.TouchItem insId = " .. insId)
  local xmission_wardrobe_data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
  local item = xmission_wardrobe_data.GetItemByInstID(insId)
  if item then
    log(bWriteLog and "xmission_redpoint_data.TouchItem 2")
    if item.insured then
      log(bWriteLog and "xmission_redpoint_data.TouchItem 3")
      local instIds = {}
      table.insert(instIds, insId)
      local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
      TxMissionHandler.send_metro_wipe_insure_req(instIds)
    end
    local page = xmission_redpoint_data.GetPageByResId(item.item_id)
    if page then
      log(bWriteLog and "xmission_redpoint_data.TouchItem 4")
      if page.instanceId[insId] then
        page.newCount = math.max(0, page.newCount - 1)
        page.instanceId[insId] = nil
      end
      if item.new == true then
        log(bWriteLog and "xmission_redpoint_data.TouchItem 5")
        local instIds = {}
        table.insert(instIds, insId)
        local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
        TxMissionHandler.send_metro_wipe_new_req(instIds)
      end
    end
  end
end
return xmission_redpoint_data