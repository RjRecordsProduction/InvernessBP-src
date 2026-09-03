local multi_state_manager = {}
local emoteList, clothList, newClothMap, stateChangeActionMap
local LoadEmoteData = function()
  emoteList = {}
  local cfg = CDataTable.GetTable("EmoteStateConfig")
  if cfg then
    for _, v in pairs(cfg) do
      if not emoteList[v.OriginEmoteID] then
        emoteList[v.OriginEmoteID] = {
          [v.State] = v.NewEmoteID
        }
      else
        emoteList[v.OriginEmoteID][v.State] = v.NewEmoteID
      end
    end
  end
end
local LoadClothData = function()
  clothList = {}
  newClothMap = {}
  local cfg = CDataTable.GetTable("ClothingStateConfig")
  if cfg then
    for _, v in pairs(cfg) do
      if not clothList[v.OriginClothID] then
        clothList[v.OriginClothID] = {
          [v.State] = {
            newCloth = v.NewClothID,
            stateName = v.StateName,
            wardrobeIcon = v.WardrobeIcon,
            detailIcon = v.DetailIcon
          }
        }
      else
        clothList[v.OriginClothID][v.State] = {
          newCloth = v.NewClothID,
          stateName = v.StateName,
          wardrobeIcon = v.WardrobeIcon,
          detailIcon = v.DetailIcon
        }
      end
      newClothMap[v.NewClothID] = {
        originCloth = v.OriginClothID,
        state = v.State
      }
    end
  end
end
local LoadStateChangeActionData = function()
  stateChangeActionMap = {}
  local cfg = CDataTable.GetTable("StateChangeActionConfig")
  if cfg then
    for _, v in pairs(cfg) do
      if not stateChangeActionMap[v.AfterClothID] then
        stateChangeActionMap[v.AfterClothID] = {}
      end
      stateChangeActionMap[v.AfterClothID][v.BeforeClothID] = v.ActionID
    end
  end
end
function multi_state_manager:OnInitialize()
  multi_state_manager.__super.OnInitialize(self)
  LoadEmoteData()
  LoadClothData()
  LoadStateChangeActionData()
end
function multi_state_manager:OnLogin(bReLogin)
end
function multi_state_manager:OnLogOut()
end
function multi_state_manager:OnPreSwitchGameStatus(preState, nextState)
end
function multi_state_manager:OnPostSwitchGameStatus(preState, nextState)
end
function multi_state_manager:ChangeEmoteByState(emoteID, state)
  if not emoteID or not emoteList[emoteID] then
    return emoteID
  end
  if not state or not emoteList[emoteID][state] then
    return emoteID
  end
  return emoteList[emoteID][state]
end
function multi_state_manager:IsMultiStateCloth(clothID)
  return clothID and clothList[clothID] ~= nil
end
function multi_state_manager:GetAllDisplayClothIDByOriginID(clothID)
  if not clothID or not clothList[clothID] then
    return nil
  end
  local allDisplayID = {}
  for _, v in pairs(clothList[clothID]) do
    table.insert(allDisplayID, v.newCloth)
  end
  return allDisplayID
end
function multi_state_manager:ChangeClothByState(clothID, state)
  if not (clothID and clothList[clothID] and state) or not clothList[clothID][state] then
    return clothID
  end
  return clothList[clothID][state].newCloth
end
function multi_state_manager:GetStateName(clothID, state)
  if not (clothID and clothList[clothID] and state) or not clothList[clothID][state] then
    return nil
  end
  return clothList[clothID][state].stateName
end
function multi_state_manager:GetWardrobeIcon(clothID, state)
  if not (clothID and clothList[clothID] and state) or not clothList[clothID][state] then
    return nil
  end
  if clothList[clothID][state].wardrobeIcon == "" then
    return nil
  end
  return clothList[clothID][state].wardrobeIcon
end
function multi_state_manager:GetDetailIcon(clothID, state)
  if not (clothID and clothList[clothID] and state) or not clothList[clothID][state] then
    return nil
  end
  if clothList[clothID][state].detailIcon == "" then
    return nil
  end
  return clothList[clothID][state].detailIcon
end
function multi_state_manager:GetOriginClothIDAndState(displayClothID)
  if displayClothID and newClothMap[displayClothID] then
    return newClothMap[displayClothID].originCloth, newClothMap[displayClothID].state
  end
  return nil, nil
end
function multi_state_manager:GetStateChangeAction(afterCloth)
  if not afterCloth or not stateChangeActionMap[afterCloth] then
    return nil
  end
  return stateChangeActionMap[afterCloth]
end
function multi_state_manager:GetOtherStateClothID(clothID)
  local config = CDataTable.GetTableData("put_on_or_off_multi", clothID)
  if config then
    return config.origin_cloth
  end
  config = CDataTable.GetTableDataByFilter("put_on_or_off_multi", "origin_cloth", clothID)
  if config then
    return config.cloth
  end
  return nil
end
function multi_state_manager:GetAllMultiClothID(clothID)
  local multiCloth = {}
  local config = CDataTable.GetTableData("put_on_or_off_multi", clothID)
  if config and config.put_on_or_off_sync == 1 then
    multiCloth[config.origin_cloth] = true
    multiCloth[config.cloth] = true
  end
  local configs = CDataTable.GetTableByFilter("put_on_or_off_multi", "origin_cloth", clothID)
  for key, _config in pairs(configs or {}) do
    if _config.put_on_or_off_sync == 1 then
      multiCloth[_config.origin_cloth] = true
      multiCloth[_config.cloth] = true
    end
  end
  return multiCloth
end
function multi_state_manager:GetDefaultClothID(skin_id)
  local config = CDataTable.GetTableData("put_on_or_off_skin", skin_id)
  if config then
    return config.default_skin
  end
  return nil
end
function multi_state_manager:GetShowItemIdByOriginItemIdAndState(nItemId, nState)
  local nOriItemId = self:GetOriginClothIDAndState(nItemId)
  if not nOriItemId then
    return nItemId
  end
  if clothList[nOriItemId][tonumber(nState)] then
    return clothList[nOriItemId][tonumber(nState)].newCloth
  end
  return nItemId
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CMultiStateManager = class(CModuleBase, nil, multi_state_manager)
return CMultiStateManager