local SocialBottomAliasSystem = {
  AchievementOwnItems = {},
  AchievementUsedItems = {},
  IsEnterAchievement = false,
  IsEnterAlias = false,
  AliasList = {}
}
function SocialBottomAliasSystem.EnterAchievement()
  if SocialBottomAliasSystem.IsEnterAchievement then
    EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_ACHIEVEMENT_UPDATE)
  else
    SocialBottomAliasSystem.IsEnterAchievement = true
    local AchieveHandler = require("client.network.Protocol.AchieveHandler")
    AchieveHandler.send_get_achieve_rewards_list_req()
  end
end
function SocialBottomAliasSystem.LeaveAchievement()
  SocialBottomAliasSystem.IsEnterAchievement = false
end
function SocialBottomAliasSystem.EnterAlias()
  local RoleInfoAliasSystem = require("client.slua.logic.roleInfo.logic_roleinfo_title")
  if SocialBottomAliasSystem.IsEnterAlias then
    EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_ALIAS_UPDATE)
  else
    SocialBottomAliasSystem.IsEnterAlias = true
    RoleInfoAliasSystem.Enter()
  end
end
function SocialBottomAliasSystem.LeaveAlias()
  local RoleInfoAliasSystem = require("client.slua.logic.roleInfo.logic_roleinfo_title")
  SocialBottomAliasSystem.IsEnterAlias = false
  RoleInfoAliasSystem.Release()
end
function SocialBottomAliasSystem.InitAlias(list)
  if not SocialBottomAliasSystem.IsEnterAlias then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local RoleInfoSystem = require("client.slua.logic.roleInfo.logic_roleinfo_title")
  SocialBottomAliasSystem.AliasList = {}
  for k, v in pairs(list) do
    local cfg = CDataTable.GetTableData("AliasCfg", k)
    if cfg ~= nil and (v.state == RoleInfoSystem.enum_Alias_State_Type.have or v.state == RoleInfoSystem.enum_Alias_State_Type.use) then
      local myItem = {}
      myItem.title = FuncUtil.Gen_title(k, v.rank, v.ext_info, v.rank_id)
      myItem.id = k
      myItem.aliasState = v.state
      myItem.aliasQuality = cfg.AliasQuality
      myItem.aliasDesc = cfg.AliasDesc
      myItem.aliasGetDesc = cfg.AliasGetDesc
      myItem.aliasType = tonumber(cfg.AliasType)
      myItem.aliasIconUrl = cfg.AliasIconPath
      myItem.aliasIconUrlBig = cfg.AliasIconPathBig
      myItem.aliasSortWeight = cfg.AliasSortWeight
      myItem.pageType = 2
      myItem.rank_id = v.rank_id
      myItem.aliasReceiveTime = LocUtil.LocalizeResFormat("6422", TimeUtil.FormatTime_YMD(v.receive_time, true))
      if v.expire_ts == 0 then
        myItem.aliasExpireTime = LocUtil.GetLocalizeResStr(301300)
      else
        myItem.aliasExpireTime = TimeUtil.FormatTime_YMD(v.expire_ts, true)
      end
      myItem.aliasTitle = v.title
      myItem.aliasReceiveTimeCompare = v.receive_time or 0
      myItem.aliasIsHaveUse = v.have_used
      myItem.aliasNation = v.nation
      table.insert(SocialBottomAliasSystem.AliasList, myItem)
    end
  end
  table.sort(SocialBottomAliasSystem.AliasList, function(a, b)
    if a.aliasQuality == b.aliasQuality then
      return a.aliasReceiveTimeCompare > b.aliasReceiveTimeCompare
    else
      return a.aliasQuality > b.aliasQuality
    end
  end)
  EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_ALIAS_UPDATE)
end
function SocialBottomAliasSystem.InitAchievement(res)
  local achievement_cfg_helper = require("client.slua.logic.achievement.achievement_cfg_helper")
  if not SocialBottomAliasSystem.IsEnterAchievement then
    return
  end
  SocialBottomAliasSystem.AchievementOwnItems = {}
  for ID, FinishTime in pairs(res) do
    local data = CDataTable.GetTableData("AchievementCfg", ID)
    if data and achievement_cfg_helper.IsValidAchievementID(ID, data) and (not data.UGCFlag or data.UGCFlag == 0) then
      local dat = {
        id = ID,
        group = data.GroupID,
        star = data.MultiLvGroupNum,
        icon = data.BigImgUrl,
        name = data.Name,
        state = "none",
        time = FinishTime,
        score = data.Score,
        pageType = 1
      }
      if 0 < dat.time then
        dat.state = "has"
        for i, s in ipairs(SocialBottomAliasSystem.AchievementUsedItems) do
          if s == dat.id then
            dat.state = "use"
            break
          end
        end
        table.insert(SocialBottomAliasSystem.AchievementOwnItems, dat)
      end
    end
  end
  local funcSort = function(a, b)
    if a.score == b.score then
      local rem_a = a.id % 10
      local rem_b = b.id % 10
      if rem_a == rem_b then
        return a.time > b.time
      else
        return rem_a > rem_b
      end
    else
      return a.score > b.score
    end
  end
  table.sort(SocialBottomAliasSystem.AchievementOwnItems, funcSort)
  EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_ACHIEVEMENT_UPDATE)
end
return SocialBottomAliasSystem