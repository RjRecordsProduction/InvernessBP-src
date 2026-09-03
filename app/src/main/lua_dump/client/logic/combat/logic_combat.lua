local logic_combat = {}
local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
function logic_combat:DefineAndResetData()
end
function logic_combat:OnInitialize()
end
function logic_combat:RegistEvents()
end
function logic_combat:OnLogin(bReLogin)
end
function logic_combat:OnLogOut()
end
function logic_combat:OnPreSwitchGameStatus(preState, nextState)
end
function logic_combat:OnPostSwitchGameStatus(preState, nextState)
end
function logic_combat:GetModeListCfg()
  log(bWriteLog and "logic_combat:GetModeListCfg")
  if LogicPeakGameUtil.IsPeakGameOpen() then
    log(bWriteLog and "LogicPeakGame:GetModeListCfg 1")
    local modeList = {
      {
        text = LocUtil.GetLocalizeResStr(602)
      },
      {
        text = LocUtil.GetLocalizeResStr(46063)
      },
      {
        text = LocUtil.GetLocalizeResStr(603)
      },
      {
        text = LocUtil.GetLocalizeResStr(641)
      }
    }
    return modeList
  end
  log(bWriteLog and "LogicPeakGame:GetModeListCfg 2")
  local modeList = {
    {
      text = LocUtil.GetLocalizeResStr(602)
    },
    {
      text = LocUtil.GetLocalizeResStr(603)
    },
    {
      text = LocUtil.GetLocalizeResStr(641)
    }
  }
  return modeList
end
function logic_combat:GetEnumModeType()
  log(bWriteLog and "logic_combat:GetEnumModeType")
  if LogicPeakGameUtil.IsPeakGameOpen() then
    log(bWriteLog and "LogicPeakGame:GetEnumModeType 1")
    local EnumModType = {
      Rank = 1,
      PeakGame = 2,
      Match = 3,
      Career = 4
    }
    return EnumModType
  end
  log(bWriteLog and "LogicPeakGame:GetEnumModeType 2")
  local EnumModType = {
    Rank = 1,
    Match = 2,
    Career = 3
  }
  return EnumModType
end
function logic_combat:GetZoneList(segmentInfo)
  log(bWriteLog and "logic_combat:GetZoneList")
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  RoleInfoSystem.UpdateShowRoleInfoOfZoneId()
  local minSeg = 105
  local segCfg = CDataTable.GetTableData("SystemConfig", "MultiServerRangID")
  if segCfg then
    minSeg = tonumber(segCfg.ConfigValue)
  end
  local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
  local zoneIdList = {}
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local showZoneId = RoleInfoMainSystem.GetShowRoleinfoOfZoneID()
  log(bWriteLog and "logic_combat:GetZoneList showZoneId = " .. tostring(showZoneId))
  table.insert(zoneIdList, {
    text = logic_multiple_area:GetDisplayNameByZoneID(showZoneId),
    zone_id = showZoneId
  })
  for zoneId, segmentList in pairs(segmentInfo) do
    if zoneId ~= showZoneId then
      for _, segment in pairs(segmentList) do
        if segment >= minSeg then
          table.insert(zoneIdList, {
            text = logic_multiple_area:GetDisplayNameByZoneID(zoneId),
            zone_id = zoneId
          })
          break
        end
      end
    end
  end
  log_tree("GetZoneIDList", zoneIdList)
  return zoneIdList
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, logic_combat)
return CModuleTemplate