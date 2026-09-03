local logic_rank_combat = {}
local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
function logic_rank_combat:DefineAndResetData()
end
function logic_rank_combat:OnInitialize()
end
function logic_rank_combat:RegistEvents()
end
function logic_rank_combat:OnLogin(bReLogin)
end
function logic_rank_combat:OnLogOut()
end
function logic_rank_combat:OnPreSwitchGameStatus(preState, nextState)
end
function logic_rank_combat:OnPostSwitchGameStatus(preState, nextState)
end
function logic_rank_combat:GetRankBattleSeasonList()
  log(bWriteLog and "logic_rank_combat:GetRankBattleSeasonList")
  local seasonList = {}
  local cur_season_id = DataMgr.season_id
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  for _, v in pairs(RoleInfoSystem.AllSeasonIDList) do
    if v == cur_season_id then
      local curname = LocUtil.GetLocalizeResStr(105010)
      table.insert(seasonList, {text = curname, season_id = v})
    else
      local seasondata = CDataTable.GetTableData("SeasonInfo", v)
      if seasondata then
        table.insert(seasonList, {
          text = seasondata.SeasonName,
          season_id = v
        })
      end
    end
  end
  return seasonList
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, logic_rank_combat)
return CModuleTemplate