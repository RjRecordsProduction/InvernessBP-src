local logic_roleInfo_weaponstrength_title_select = {}
local Enum_Alias_State_Type = {
  notHave = 0,
  have = 1,
  use = 2
}
function logic_roleInfo_weaponstrength_title_select:DefineAndResetData()
  self.SaveSelectAliasList_Weapon = {}
end
function logic_roleInfo_weaponstrength_title_select:send_get_show_weapon_alias_req()
  log(bWriteLog and "logic_roleInfo_weaponstrength_title_select:send_set_show_weapon_alias_req")
  local CharacterHandler = require("client.network.Protocol.CharacterHandler")
  CharacterHandler.send_get_show_weapon_alias_req()
end
function logic_roleInfo_weaponstrength_title_select:proc_get_show_weapon_alias_rsp(orderList)
  log(bWriteLog and "logic_roleInfo_weaponstrength_title_select:proc_set_show_weapon_alias_rsp")
  if orderList then
    self.SaveSelectAliasList_Weapon = orderList
    EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_WEAPONSTRENGTH_ALIAS_GET_SELECT_ALIAS_LIST)
  end
end
function logic_roleInfo_weaponstrength_title_select:send_set_show_weapon_alias_req(weapon_alias_table)
  log(bWriteLog and "logic_roleInfo_weaponstrength_title_select:send_set_show_weapon_alias_req")
  local saveTable = {}
  for key, value in pairs(weapon_alias_table) do
    saveTable[value.order_id] = key
  end
  log_tree("logic_roleInfo_weaponstrength_title_select:send_set_show_weapon_alias_req  saveTable", saveTable)
  local CharacterHandler = require("client.network.Protocol.CharacterHandler")
  CharacterHandler.send_set_show_weapon_alias_req(saveTable)
end
function logic_roleInfo_weaponstrength_title_select:proc_set_show_weapon_alias_rsp()
  log(bWriteLog and "logic_roleInfo_weaponstrength_title_select:on_set_show_weapon_alias_rsp")
  self:send_get_show_weapon_alias_req()
end
function logic_roleInfo_weaponstrength_title_select:FindWeaponStrengthTitleInSvaeAliasIDList(AliasID)
  for k, v in pairs(self.SaveSelectAliasList_Weapon) do
    if AliasID == k then
      return true, v.order_id
    end
  end
  return false, -1
end
function logic_roleInfo_weaponstrength_title_select:FilterHavedAliasList()
  local logic_roleinfo_title = require("client.slua.logic.roleInfo.logic_roleinfo_title")
  local alias_list_info = logic_roleinfo_title.alias_list_info
  local haveAliasList = {}
  for k, v in pairs(alias_list_info) do
    local cfg = CDataTable.GetTableData("AliasCfg", k)
    if cfg ~= nil and v.state ~= Enum_Alias_State_Type.notHave then
      local item = {
        aliasTitle = FuncUtil.Gen_title(k, v.rank, v.ext_info, v.rank_id),
        aliasId = k,
        aliasType = cfg.AliasType,
        aliasNation = v.nation,
        aliasQuality = cfg.AliasQuality,
        aliasDesc = cfg.AliasDesc,
        aliasIconUrl = cfg.AliasIconPath,
        aliasIconUrlBig = cfg.AliasIconPathBig,
        expire_ts = v.expire_ts,
        rank = v.rank,
        rank_id = v.rank_id,
        ext_info = v.ext_info
      }
      table.insert(haveAliasList, item)
    end
  end
  self:SortHavedAliasList(haveAliasList)
  return haveAliasList
end
function logic_roleInfo_weaponstrength_title_select:SortHavedAliasList(haveAliasList)
  local SortHaveAliasListFunction = function(a, b)
    local aIsInList, aIndex = self:FindAliasInSvaeAliasIDList(a.aliasId)
    local bIsInList, bIndex = self:FindAliasInSvaeAliasIDList(b.aliasId)
    if aIsInList == bIsInList then
      if aIsInList then
        return aIndex < bIndex
      else
        if a.aliasQuality == b.aliasQuality then
          return a.aliasId > b.aliasId
        end
        return a.aliasQuality > b.aliasQuality
      end
    else
      return aIsInList
    end
  end
  table.sort(haveAliasList, SortHaveAliasListFunction)
end
function logic_roleInfo_weaponstrength_title_select:FindAliasInSvaeAliasIDList(AliasID)
  for k, v in pairs(self.SaveSelectAliasList_Weapon) do
    if AliasID == k then
      return true, v.order_id
    end
  end
  return false, -1
end
function logic_roleInfo_weaponstrength_title_select:GetHavedAliasList()
  return self:FilterHavedAliasList()
end
function logic_roleInfo_weaponstrength_title_select:GetSaveSelectAliasList_Weapon()
  return self.SaveSelectAliasList_Weapon
end
function logic_roleInfo_weaponstrength_title_select:GetSaveSelectListCount()
  local count = 0
  if self.SaveSelectAliasList_Weapon then
    for key, value in pairs(self.SaveSelectAliasList_Weapon) do
      count = count + 1
    end
  end
  return count
end
function logic_roleInfo_weaponstrength_title_select:ClearSelectAliasDataByIndex(index)
  for key, value in pairs(self.SaveSelectAliasList_Weapon) do
    if index == value.order_id then
      self.SaveSelectAliasList_Weapon[key] = nil
      return true
    end
  end
  return false
end
function logic_roleInfo_weaponstrength_title_select:SaveShowAliasData()
  self:send_set_show_weapon_alias_req(self.SaveSelectAliasList_Weapon)
end
function logic_roleInfo_weaponstrength_title_select:ChangeSelectAliasInList(AliasData, isAdd, index)
  if isAdd then
    if index == -1 then
      local count = 0
      for i = 1, 10 do
        for key, value in pairs(self.SaveSelectAliasList_Weapon) do
          count = count + 1
          if i == value.order_id then
            count = 0
            break
          end
        end
        if count == self:GetSaveSelectListCount() then
          index = i
          break
        end
      end
    else
      for key, value in pairs(self.SaveSelectAliasList_Weapon) do
        if index == value.order_id then
          local refIndex = self:GetRefIndex(key)
          self.SaveSelectAliasList_Weapon[key] = nil
          EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_HONOR_ALIAS_SELECT_ALIAS_UPDATE_LOOPITEM, refIndex)
          break
        end
      end
    end
    local item = {
      rank = AliasData.rank,
      rank_id = AliasData.rank_id,
      ext_info = AliasData.ext_info,
      nation = AliasData.aliasNation,
      order_id = index,
      expire_ts = AliasData.expire_ts
    }
    self.SaveSelectAliasList_Weapon[AliasData.aliasId] = item
  else
    if not self.SaveSelectAliasList_Weapon or not self.SaveSelectAliasList_Weapon[AliasData.aliasId] then
      log(bWriteLog and "[wzp] logic_roleInfo_weaponstrength_title_select:ChangeSelectAliasInList self.Svae_AliasID_List[index] = nil,delete no success")
      return
    end
    self.SaveSelectAliasList_Weapon[AliasData.aliasId] = nil
  end
end
function logic_roleInfo_weaponstrength_title_select:GetRefIndex(AliasID)
  local have_Alias_List = self:GetHavedAliasList()
  for i = 1, #have_Alias_List do
    if have_Alias_List[i].aliasId == AliasID then
      return i
    end
  end
  return -1
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_roleInfo_weaponstrength_title_select = class(CModuleBase, nil, logic_roleInfo_weaponstrength_title_select)
return Clogic_roleInfo_weaponstrength_title_select