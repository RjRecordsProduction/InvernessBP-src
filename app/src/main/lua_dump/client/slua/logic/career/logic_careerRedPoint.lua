local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
local ConstCareer = require("client.slua.logic.career.const_career")
local logic_careerRedPoint = {}
local E_RedPointType = ConstCareer.E_RedPointType
local E_CareerModule = ConstCareer.E_CareerModule
local E_PersonalizeType = ConstCareer.E_PersonalizeType
local E_EditBaseTabType = ConstCareer.E_EditBaseTabType
local _tRedData
local _bIsInited = false
function logic_careerRedPoint.Init()
  if _bIsInited then
    return
  end
  _bIsInited = true
  EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_SEASON_CHANGE, logic_careerRedPoint.UpdateNewSeasonRedPointCount)
  if _tRedData then
    return
  end
  local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
  local super_data = require("common.super_data")
  local sDescName = reddot_macro.SystemName.Career
  local tBaseData = {
    newCount = 0,
    desc = sDescName,
    pages = {
      newCount = 0,
      [E_RedPointType.NewSeason] = {
        newCount = 0,
        subID = 17,
        category = reddot_macro.Category.Other
      },
      [E_RedPointType.NewItem] = {
        newCount = 0,
        subID = 17,
        category = reddot_macro.Category.NewArrivals,
        [E_EditBaseTabType.Medals] = {
          newCount = 0,
          subID = 17,
          category = reddot_macro.Category.NewArrivals,
          [E_CareerModule.Weapon] = {
            newCount = 0,
            subID = 17,
            category = reddot_macro.Category.NewArrivals,
            instanceId = {_isLeaf = true}
          },
          [E_CareerModule.Mode] = {
            newCount = 0,
            subID = 17,
            category = reddot_macro.Category.NewArrivals,
            instanceId = {_isLeaf = true}
          },
          [E_CareerModule.Vehicle] = {
            newCount = 0,
            subID = 17,
            category = reddot_macro.Category.NewArrivals,
            instanceId = {_isLeaf = true}
          }
        },
        [E_EditBaseTabType.Personalize] = {
          newCount = 0,
          subID = 17,
          category = reddot_macro.Category.NewArrivals,
          [E_PersonalizeType.Frame] = {
            newCount = 0,
            subID = 17,
            category = reddot_macro.Category.NewArrivals,
            instanceId = {_isLeaf = true}
          },
          [E_PersonalizeType.Material] = {
            newCount = 0,
            subID = 17,
            category = reddot_macro.Category.NewArrivals,
            instanceId = {_isLeaf = true}
          },
          [E_PersonalizeType.Posture] = {
            newCount = 0,
            subID = 17,
            category = reddot_macro.Category.NewArrivals,
            instanceId = {_isLeaf = true}
          }
        }
      }
    }
  }
  if not reddot_manager:IsRegist(sDescName) then
    _tRedData = super_data.CreateSuperData(tBaseData)
    reddot_manager:Regist(_tRedData)
  end
  logic_careerRedPoint.UpdateNewSeasonRedPointCount()
end
function logic_careerRedPoint.InitSubMedalsRedData(tCurRedData, nSubTab, tTempRedData)
  if not (tCurRedData and tCurRedData[nSubTab]) or not tTempRedData then
    return
  end
  local tCurSubRedData = tCurRedData[nSubTab]
  for k, _ in pairs(tTempRedData) do
    tCurSubRedData.instanceId[k] = true
  end
end
function logic_careerRedPoint.InitMedalsRedData(tTempRedData)
  if not tTempRedData then
    return
  end
  logic_careerRedPoint.Init()
  local nRedPointType = E_RedPointType.NewItem
  local nBaseTab = E_EditBaseTabType.Medals
  local tAllData = _tRedData and _tRedData.pages
  if not (tAllData and tAllData[nRedPointType]) or not tAllData[nRedPointType][nBaseTab] then
    return
  end
  local tMedalsRedData = tAllData[nRedPointType][nBaseTab]
  if tTempRedData.weapon then
    logic_careerRedPoint.InitSubMedalsRedData(tMedalsRedData, E_CareerModule.Weapon, tTempRedData.weapon)
  end
  if tTempRedData.mode then
    logic_careerRedPoint.InitSubMedalsRedData(tMedalsRedData, E_CareerModule.Mode, tTempRedData.mode)
  end
  if tTempRedData.vehicle then
    logic_careerRedPoint.InitSubMedalsRedData(tMedalsRedData, E_CareerModule.Vehicle, tTempRedData.vehicle)
  end
end
function logic_careerRedPoint.InitEditItemRedData(tTempRedData)
  if not tTempRedData then
    return
  end
  logic_careerRedPoint.Init()
  local nRedPointType = E_RedPointType.NewItem
  local nBaseTab = E_EditBaseTabType.Personalize
  local tAllData = _tRedData and _tRedData.pages
  if not (tAllData and tAllData[nRedPointType]) or not tAllData[nRedPointType][nBaseTab] then
    return
  end
  local tEditItemRedData = tAllData[nRedPointType][nBaseTab]
  for k, _ in pairs(tTempRedData) do
    local tEditItemCfg = CDataTable.GetTableData("CareerEditPersonalizeItem", k)
    if tEditItemCfg then
      local nSubTab = tEditItemCfg.editItemType
      if tEditItemRedData[nSubTab] then
        tEditItemRedData[nSubTab].instanceId[tEditItemCfg.itemId] = true
      end
    end
  end
end
function logic_careerRedPoint.OnLogin()
  local CareerSystem = require("client.slua.logic.career.logic_career")
  if not CareerSystem.IsOpen() then
    return
  end
  logic_careerRedPoint.Init()
end
function logic_careerRedPoint.OnLogout()
  logic_careerRedPoint.DestroyData()
end
function logic_careerRedPoint.DestroyData()
  _tRedData = nil
  _bIsInited = false
  EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_SEASON_CHANGE, logic_careerRedPoint.UpdateNewSeasonRedPointCount)
end
function logic_careerRedPoint.IsExistRedPoint()
  if not _tRedData then
    return false
  end
  return _tRedData.newCount > 0
end
function logic_careerRedPoint.IsExistEditPanelRedPoint()
  if _tRedData and _tRedData.pages and _tRedData.pages[E_RedPointType.NewItem] and _tRedData.pages[E_RedPointType.NewItem].newCount then
    return _tRedData.pages[E_RedPointType.NewItem].newCount > 0
  end
  return false
end
function logic_careerRedPoint.GetMedalsBaseTabRedData()
  if not _tRedData then
    return {}
  end
  local nRedPointType = E_RedPointType.NewItem
  return _tRedData.pages[nRedPointType][E_EditBaseTabType.Medals]
end
function logic_careerRedPoint.GetMedalsSubTabRedData(nSubTab)
  if not _tRedData then
    return {}
  end
  local nRedPointType = E_RedPointType.NewItem
  local nBaseTab = E_EditBaseTabType.Medals
  return _tRedData.pages[nRedPointType][nBaseTab][nSubTab] or {}
end
function logic_careerRedPoint.GetEditItemBaseTabRedData()
  if not _tRedData then
    return {}
  end
  local nRedPointType = E_RedPointType.NewItem
  local nBaseTab = E_EditBaseTabType.Personalize
  return _tRedData.pages[nRedPointType][nBaseTab]
end
function logic_careerRedPoint.GetEditItemSubTabRedData(nSubTab)
  if not _tRedData then
    return {}
  end
  local nRedPointType = E_RedPointType.NewItem
  local nBaseTab = E_EditBaseTabType.Personalize
  return _tRedData.pages[nRedPointType][nBaseTab][nSubTab] or {}
end
function logic_careerRedPoint.GetItemRedData(nBaseTab, nSubTab, nItemId)
  if not _tRedData then
    return false
  end
  local nRedType = E_RedPointType.NewItem
  local tAllPageData = _tRedData and _tRedData.pages
  if tAllPageData[nRedType] and tAllPageData[nRedType][nBaseTab] and tAllPageData[nRedType][nBaseTab][nSubTab] then
    local tAllRedData = tAllPageData[nRedType][nBaseTab][nSubTab]
    return tAllRedData.instanceId[nItemId]
  end
  return false
end
function logic_careerRedPoint.ClearItemRedData(nBaseTab, nSubTab, nItemId)
  if not _tRedData then
    return
  end
  local nRedType = E_RedPointType.NewItem
  local tAllPageData = _tRedData and _tRedData.pages
  if tAllPageData[nRedType] and tAllPageData[nRedType][nBaseTab] and tAllPageData[nRedType][nBaseTab][nSubTab] then
    local tAllRedData = _tRedData.pages[nRedType][nBaseTab][nSubTab]
    tAllRedData.instanceId[nItemId] = nil
  end
  EventSystem:postEvent(EVENTTYPE_CAREER, EVENTID_CAREER_REFRESH_EDIT_ITEM_LIST)
end
function logic_careerRedPoint.UpdateNewSeasonRedPointCount()
  if not _tRedData then
    return
  end
  local nRedPointType = E_RedPointType.NewSeason
  local tAllData = _tRedData and _tRedData.pages
  if not tAllData or not tAllData[nRedPointType] then
    return
  end
  local Logic_Career = require("client.slua.logic.career.logic_career")
  if Logic_Career.IsFirst() or Logic_Career.GetIsExistSeasonData() and Logic_Career.IsNewSeason() then
    tAllData[nRedPointType].newCount = 1
  else
    tAllData[nRedPointType].newCount = 0
  end
  EventSystem:postEvent(EVENTTYPE_CAREER, EVENTID_CAREER_RED_DOT_DATA)
end
function logic_careerRedPoint.UpdateMedalsNewItemRedPoint(nSubTab, nMappingId, nMedalsLevel)
  if not _tRedData then
    return
  end
  local Logic_CareerEdit = require("client.slua.logic.career.logic_careerEdit")
  local nItemId = Logic_CareerEdit:GetMedalsItemId(nSubTab, nMappingId, nMedalsLevel)
  if nItemId then
    local nRedPointType = E_RedPointType.NewItem
    local nBaseTab = E_EditBaseTabType.Medals
    local tAllData = _tRedData and _tRedData.pages
    if tAllData and tAllData[nRedPointType] and tAllData[nRedPointType][nBaseTab] and tAllData[nRedPointType][nBaseTab][nSubTab] then
      local tCurTypeRedData = tAllData[nRedPointType][nBaseTab][nSubTab]
      tCurTypeRedData.instanceId[nItemId] = true
      for i = 1, nMedalsLevel - 1 do
        local nTempId = Logic_CareerEdit:GetMedalsItemId(nSubTab, nMappingId, i)
        if tCurTypeRedData.instanceId[nTempId] then
          tCurTypeRedData.instanceId[nTempId] = nil
        end
      end
    end
  end
end
function logic_careerRedPoint.UpdateEditItemRedPoint(nSubTab, nEditItem)
  if not _tRedData then
    return
  end
  local nRedPointType = E_RedPointType.NewItem
  local nBaseTab = E_EditBaseTabType.Personalize
  local tAllData = _tRedData and _tRedData.pages
  if tAllData and tAllData[nRedPointType] and tAllData[nRedPointType][nBaseTab] and tAllData[nRedPointType][nBaseTab][nSubTab] then
    local tCurTypeRedData = tAllData[nRedPointType][nBaseTab][nSubTab]
    tCurTypeRedData.instanceId[nEditItem] = true
  end
end
function logic_careerRedPoint.CareerClearMedalsRedDotReq(nSubTab, nMappingId)
  local nRedPointType = E_RedPointType.NewItem
  local nBaseTab = E_EditBaseTabType.Medals
  local tAllData = _tRedData and _tRedData.pages
  local Logic_CareerEdit = require("client.slua.logic.career.logic_careerEdit")
  if tAllData and tAllData[nRedPointType] and tAllData[nRedPointType][nBaseTab] and tAllData[nRedPointType][nBaseTab][nSubTab] then
    local tCurRedData = tAllData[nRedPointType][nBaseTab][nSubTab]
    for i = 1, ConstCareer.MEDALS_MAX_LEVEL do
      local nItemId = Logic_CareerEdit:GetMedalsItemId(nSubTab, nMappingId, i)
      if tCurRedData.instanceId[nItemId] then
        local CareerHandler = require("client.network.Protocol.CareerHandler")
        CareerHandler.send_career_clear_red_dot_req(nSubTab, nMappingId)
        break
      end
    end
  end
end
function logic_careerRedPoint.CareerClearMedalsRedDotRsp(nSubTab, nMappingId)
  local Logic_CareerEdit = require("client.slua.logic.career.logic_careerEdit")
  for i = 1, ConstCareer.MEDALS_MAX_LEVEL do
    local nItemId = Logic_CareerEdit:GetMedalsItemId(nSubTab, nMappingId, i)
    if nItemId then
      logic_careerRedPoint.ClearItemRedData(E_EditBaseTabType.Medals, nSubTab, nItemId)
    end
  end
end
function logic_careerRedPoint.CareerClearEditItemRedDotReq(nMappingId)
  local nRedPointType = E_RedPointType.NewItem
  local nBaseTab = E_EditBaseTabType.Personalize
  local tAllData = _tRedData and _tRedData.pages
  local tEditItemCfg = CDataTable.GetTableData("CareerEditPersonalizeItem", nMappingId)
  if tEditItemCfg and tAllData and tAllData[nRedPointType] and tAllData[nRedPointType][nBaseTab] and tAllData[nRedPointType][nBaseTab][tEditItemCfg.editItemType] then
    local tCurRedData = tAllData[nRedPointType][nBaseTab][tEditItemCfg.editItemType]
    if tCurRedData.instanceId[tEditItemCfg.itemId] then
      local CareerHandler = require("client.network.Protocol.CareerHandler")
      CareerHandler.send_career_banner_clear_red_dot_req(nMappingId)
    end
  end
end
function logic_careerRedPoint.CareerClearEditItemRedDotRsp(nMappingId)
  local tEditItemCfg = CDataTable.GetTableData("CareerEditPersonalizeItem", nMappingId)
  if tEditItemCfg then
    logic_careerRedPoint.ClearItemRedData(E_EditBaseTabType.Personalize, tEditItemCfg.editItemType, tEditItemCfg.itemId)
  end
end
return logic_careerRedPoint