local local cacheTabConfig, cacheModuleConfig, tabModuleIndex, moduleTapIndex, checkModuleReq, requestUID
local custom_presentation_util = {}
function custom_presentation_util.GetShowTabData()
  local tableData = CDataTable.GetTable("CustomPresentationTab")
  if cacheTabConfig == nil then
    cacheTabConfig = {}
    for _, v in pairs(tableData) do
      table.insert(cacheTabConfig, v)
    end
    table.sort(cacheTabConfig, function(a, b)
      return a.ID < b.ID
    end)
  end
  return cacheTabConfig
end
function custom_presentation_util.GetShowModuleByTabID(tabID, getConfig)
  if cacheModuleConfig == nil then
    cacheModuleConfig = {}
  end
  if tabModuleIndex == nil then
    tabModuleIndex = {}
  end
  if moduleTapIndex == nil then
    moduleTapIndex = {}
  end
  if cacheModuleConfig[tabID] == nil then
    cacheModuleConfig[tabID] = {}
    tabModuleIndex[tabID] = {}
    local list = {}
    local custom_presentation_config = require("client.slua.logic.person_space.custom_presentation_config")
    if tabID == custom_presentation_config.TabID.All then
      list = CDataTable.GetTable("CustomPresentationModule")
    else
      list = CDataTable.GetTableByFilter("CustomPresentationModule", "TabID", tabID)
    end
    for _, v in pairs(list) do
      table.insert(cacheModuleConfig[tabID], v)
      tabModuleIndex[tabID][v.ID] = true
      moduleTapIndex[v.ID] = tabID
    end
    table.sort(cacheModuleConfig[tabID], function(a, b)
      return a.ID < b.ID
    end)
  end
  if #cacheModuleConfig[tabID] == 0 then
    log_warning(bWriteLog and "GetShowModuleByTabID:GetShowModuleByTabID tabID =" .. tabID .. " no data")
  end
  if getConfig then
    return cacheModuleConfig[tabID]
  else
    return tabModuleIndex[tabID]
  end
end
function custom_presentation_util.GetShowModuleListByUIDNew(uid, moduleConfigList)
  local custom_presentation_config = require("client.slua.logic.person_space.custom_presentation_config")
  local TableUtil = require("common.table_util")
  local list = {}
  for i = 1, #moduleConfigList do
    local moduleConfig = moduleConfigList[i]
    local moduleId = moduleConfig.ID
    local specFunc = custom_presentation_config.GetShowModuleDataFunc[moduleId]
    local checkCanShowFunc = custom_presentation_config.EditCheckCanShowModuleNew[moduleId]
    local canAdd = checkCanShowFunc == nil or checkCanShowFunc and checkCanShowFunc(uid)
    if canAdd then
      if specFunc then
        local tempList = specFunc(uid)
        for j = 1, #tempList do
          local insertData = {configData = moduleConfig}
          local showData = TableUtil.CopyTable(custom_presentation_config.EmptyModuleData)
          showData.mId = moduleId
          showData.mData = tempList[j]
          insertData.moduleData = showData
          table.insert(list, insertData)
        end
      else
        local insertData = {configData = moduleConfig}
        local showData = TableUtil.CopyTable(custom_presentation_config.EmptyModuleData)
        showData.mId = moduleId
        insertData.moduleData = showData
        table.insert(list, insertData)
      end
    end
  end
  return list
end
function custom_presentation_util.GetShowModuleListByUID(uid, moduleConfigList)
  local custom_presentation_config = require("client.slua.logic.person_space.custom_presentation_config")
  local TableUtil = require("common.table_util")
  local list = {}
  for i = 1, #moduleConfigList do
    local moduleConfig = moduleConfigList[i]
    local moduleId = moduleConfig.ID
    local specFunc = custom_presentation_config.GetShowModuleDataFunc[moduleId]
    local checkCanShowFunc = custom_presentation_config.EditCheckCanShowModule[moduleId]
    local canAdd = checkCanShowFunc == nil or checkCanShowFunc and checkCanShowFunc(uid)
    if canAdd then
      if specFunc then
        local tempList = specFunc(uid)
        for j = 1, #tempList do
          local insertData = {configData = moduleConfig}
          local showData = TableUtil.CopyTable(custom_presentation_config.EmptyModuleData)
          showData.mId = moduleId
          showData.mData = tempList[j]
          insertData.moduleData = showData
          table.insert(list, insertData)
        end
      else
        local insertData = {configData = moduleConfig}
        local showData = TableUtil.CopyTable(custom_presentation_config.EmptyModuleData)
        showData.mId = moduleId
        insertData.moduleData = showData
        table.insert(list, insertData)
      end
    end
  end
  return list
end
function custom_presentation_util.GetModuleConfig(moduleID)
  local configData
  if not moduleTapIndex or not moduleTapIndex[moduleID] then
    configData = CDataTable.GetTableData("CustomPresentationModule", moduleID)
    custom_presentation_util.GetShowModuleByTabID(configData.TabID)
  else
    local tabID = moduleTapIndex[moduleID]
    local configDataList = tabID and cacheModuleConfig[tabID]
    if configDataList then
      for k, v in pairs(configDataList) do
        if v.ID == moduleID then
          configData = v
          break
        end
      end
    end
  end
  if not configData then
    log_warning(bWriteLog and "GetModuleConfig:GetModuleConfig moduleID = " .. moduleID .. " no data")
  end
  return configData
end
function custom_presentation_util.GetSmallItemTipsPrefix(moduleID, args)
  local custom_presentation_config = require("client.slua.logic.person_space.custom_presentation_config")
  local prefixData = custom_presentation_config.SmallItemTipsPrefix[moduleID]
  if not prefixData then
    return ""
  elseif type(prefixData) == "number" then
    return LocUtil.GetLocalizeResStr(prefixData)
  elseif type(prefixData) == "function" then
    return prefixData(args)
  end
  return ""
end
function custom_presentation_util.CheckModuleDataIsEqual(moduleData1, moduleData2)
  if not moduleData1 or not moduleData2 then
    return
  end
  local checkMId = moduleData1.mId == moduleData2.mId
  if not checkMId then
    return false
  end
  local custom_presentation_config = require("client.slua.logic.person_space.custom_presentation_config")
  local specFunc = custom_presentation_config.GetCheckModuleDataFunc[moduleData1.mId]
  if specFunc then
    return specFunc(moduleData1.mData, moduleData2.mData)
  end
  local mData1 = moduleData1.mData
  local mData2 = moduleData2.mData
  local count1 = 0
  for _ in pairs(mData1) do
    count1 = count1 + 1
  end
  local count2 = 0
  for _ in pairs(mData1) do
    count2 = count2 + 1
    if count1 < count2 then
      return false
    end
  end
  if count1 ~= count2 then
    return false
  end
  for k, v in pairs(mData1) do
    if v ~= mData2[k] then
      return false
    end
  end
  return true
end
function custom_presentation_util.GetShowItem(parentUI, targetRoot, checkHideModule)
  local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
  local ShowItem = UIComponentModule:InitWithParentComponent(parentUI, UIComponentModule.Config.Lobby_RoleInfo_CustomPresentation_Item_UIBP, targetRoot)
  ShowItem:OnInitUIParam(checkHideModule)
  return ShowItem
end
function custom_presentation_util.GetDataByUID(uid)
  local returnData
  local isSelfRole = tonumber(uid) == tonumber(DataMgr.roleData.uid)
  if isSelfRole then
    local logic_custom_presentation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_custom_presentation)
    returnData = logic_custom_presentation:GetData()
  else
    local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
    local profile = LobbySocialSystem.GetProfileByUID(uid)
    if profile then
      local custom_presentation_config = require("client.slua.logic.person_space.custom_presentation_config")
      returnData = profile.custom_presentation or custom_presentation_config.DefaultPresentationData
    end
  end
  returnData = returnData or {}
  local custom_presentation_config = require("client.slua.logic.person_space.custom_presentation_config")
  for i = 1, custom_presentation_config.SlotNum do
    if not returnData[i] then
      if not isSelfRole then
        local TableUtil = require("common.table_util")
        returnData[i] = TableUtil.CopyTable(custom_presentation_config.EmptyModuleData)
      else
        returnData[i] = custom_presentation_util.GetSupplementModuleData(i, returnData)
      end
    end
  end
  return returnData
end
function custom_presentation_util.GetSupplementModuleData(slotIndex, cpData)
  if not (cpData and slotIndex) or cpData[slotIndex] ~= nil then
    return
  end
  local custom_presentation_config = require("client.slua.logic.person_space.custom_presentation_config")
  local TableUtil = require("common.table_util")
  local defaultData = custom_presentation_config.DefaultPresentationData
  local defaultSlotData = defaultData[slotIndex]
  if not defaultSlotData then
    return TableUtil.CopyTable(custom_presentation_config.EmptyModuleData)
  end
  local defaultIsIn = false
  local inlayMId = {}
  for k, v in pairs(cpData) do
    if v.mId == defaultSlotData.mId then
      defaultIsIn = true
    end
    table.insert(inlayMId, v.mId)
  end
  if not defaultIsIn then
    return TableUtil.CopyTable(defaultSlotData)
  end
  local moduleConfigList = custom_presentation_util.GetShowModuleByTabID(custom_presentation_config.TabID.All, true)
  local moduleList = custom_presentation_util.GetShowModuleListByUID(DataMgr.roleData.uid, moduleConfigList)
  for i = 1, #moduleList do
    local mId = moduleList[i].configData.ID
    if not TableUtil.IsInTable(inlayMId, mId) then
      return moduleList[i].moduleData
    end
  end
end
function custom_presentation_util.GetServerData(moduleId, args, uid)
  if not moduleId or not uid then
    return
  end
  local custom_presentation_config = require("client.slua.logic.person_space.custom_presentation_config")
  local getFunc = custom_presentation_config.GetServerDataFunc[moduleId]
  if not getFunc then
    return
  end
  checkModuleReq = checkModuleReq or {}
  if not checkModuleReq[moduleId] then
    checkModuleReq[moduleId] = {}
  end
  if checkModuleReq[moduleId][uid] then
    return
  end
  getFunc(args)
  checkModuleReq[moduleId][uid] = true
end
function custom_presentation_util.ClearCheckModuleReq()
  checkModuleReq = {}
end
function custom_presentation_util.GetDefaultDataBySlotIndex(slotIndex)
  local custom_presentation_config = require("client.slua.logic.person_space.custom_presentation_config")
  local defaultData = custom_presentation_config.DefaultPresentationData[slotIndex]
  local TableUtil = require("common.table_util")
  return TableUtil.CopyTable(defaultData)
end
function custom_presentation_util.CheckCPDataIsValid(uid, cpData, showNotice)
  local custom_presentation_config = require("client.slua.logic.person_space.custom_presentation_config")
  local smallIsValid = false
  for k, v in pairs(cpData) do
    local moduleId = v.mId
    local checkFunc = custom_presentation_config.CheckModuleDataCanUse[moduleId]
    if checkFunc and not checkFunc.func(uid, v.mData) then
      v.mId = 0
      v.mData = {}
      if showNotice then
        ShowNotice(checkFunc.notice)
      end
      smallIsValid = smallIsValid or k ~= custom_presentation_config.LargeSlotIndex
    end
  end
  if smallIsValid then
    local nextIndex = -1
    for i = 2, custom_presentation_config.SlotNum do
      local mId = cpData[i].mId
      if mId == 0 then
        nextIndex = math.min(i + 1, custom_presentation_config.SlotNum)
        local current = cpData[i]
        cpData[i] = cpData[nextIndex]
        cpData[nextIndex] = current
      end
    end
  end
  return cpData
end
function custom_presentation_util.GetRelationFriendData(uid, callback)
  if not requestUID then
    requestUID = {}
  end
  if not requestUID[uid] then
    requestUID[uid] = true
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetFriendProfiles(Enum_PROFILE_REPORT_CFG.CUSTOM_PRESENTATION, {uid}, callback)
  end
end
return custom_presentation_util