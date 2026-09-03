local CountryAreaSystem = {
  SortedNations = {},
  IsInRoleinfo = false,
  OpenType = 0,
  LoginedNation = "G1",
  SearchRes = {},
  SearchIndex = {},
  IsSelectCurrNation = false,
  IsUseFlag = false,
  IsFlagJump = false,
  CountryAreaOpenType = {
    AvatarCreate = 0,
    RoleInfo = 1,
    FriendSearch = 2,
    CorpsCreate = 3,
    ModifyCorpsNation = 4,
    Guidon = 101,
    TeamNation = 102
  }
}
function CountryAreaSystem.GetConfigByType()
  return FuncUtil.GetRegionConfigTable()
end
function CountryAreaSystem.IsOverNationModifyCd(lastTime, nowTime)
  local time = CDataTable.GetTableData("IntlSystemConfig", "NationModifyCd").ConfigValue
  return nowTime - lastTime > tonumber(time)
end
function CountryAreaSystem.SortNationCode(nation_code)
  local regionConfig = CountryAreaSystem.GetConfigByType()
  table.sort(nation_code, function(code1, code2)
    return regionConfig[code1].sort_key:lower() < regionConfig[code2].sort_key:lower()
  end)
end
function CountryAreaSystem.MakeSortNationKey(SortedNations)
  local regionConfig = CountryAreaSystem.GetConfigByType()
  local n = 0
  for k, v in pairs(regionConfig) do
    n = n + 1
    SortedNations[n] = v.RegionCode
  end
  CountryAreaSystem.SortNationCode(SortedNations)
end
function CountryAreaSystem.IsOverNationModifyCd(lastTime, nowTime)
  local time = CDataTable.GetTableData("IntlSystemConfig", "NationModifyCd").ConfigValue
  return nowTime - lastTime > tonumber(time)
end
function CountryAreaSystem.UseFlagItemShow(isJumpFromFlagItem, isUseFlagItem)
  CountryAreaSystem.IsUseFlag = isUseFlagItem
  CountryAreaSystem.IsFlagJump = isJumpFromFlagItem
  log(bWriteLog and "  :isJumpFromFlagItem" .. tostring(isJumpFromFlagItem))
  log(bWriteLog and "  :UseFlagItemShow isUseFlagItem" .. tostring(isUseFlagItem))
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local PersonalizationConst = require("client.slua.umg.roleInfoNew.PersonalizationConst")
  RoleInfoMainSystem.Show(RoleInfoMainSystem.Personalize, RoleInfoMainSystem.RoleInfoOpenFromType.UseItem, DataMgr.roleData.uid, {
    personalInfo = {
      openTab = PersonalizationConst.ENUM_Type.CountryPage
    }
  })
end
function CountryAreaSystem.modify_nation_res(msg, param, use_item)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  log(bWriteLog and "NationSystem.on_modify_nation_res,msg " .. msg)
  log(bWriteLog and "NationSystem.on_modify_nation_res,use_item " .. tostring(use_item))
  local TimeUtil = require("client.common.time_util")
  if msg == NetErrorCode_NONE then
    RoleInfoSystem.PersonalBasicInfo.role_nation = param
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    RoleInfoMainSystem.UpdateRoleInfoNation(param)
    DataMgr.roleData.nation = param
    DataMgr.last_modify_nation_time = TimeUtil.GetServerTimeInSec()
    log(bWriteLog and "NationSystem.on_modify_nation_res:" .. tostring(use_item) .. "  " .. tostring(DataMgr.last_modify_nation_time))
    if use_item then
      DataMgr.last_modify_nation_item_time = TimeUtil.GetServerTimeInSec()
    end
    ShowNotice(301192)
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_NATIONAREA)
  elseif msg == "cd" then
    local text = LocUtil.GetLocalizeResStr(4359)
    local cd = CDataTable.GetTableData("IntlSystemConfig", "NationModifyCd").ConfigValue
    local leftDay = math.ceil((cd - (TimeUtil.GetServerTimeInSec() - param)) / 3600 / 24)
    local content = string.format(text, leftDay)
    ShowNotice(content)
  end
end
function CountryAreaSystem.modify_nation_req(nation, isUseFlagItem)
  log(bWriteLog and "modify_nation " .. tostring(nation) .. "   " .. tostring(isUseFlagItem))
  local CountryAreaHandler = require("client.network.Protocol.CountryAreaHandler")
  CountryAreaHandler.send_modify_nation_req(nation, isUseFlagItem)
end
return CountryAreaSystem