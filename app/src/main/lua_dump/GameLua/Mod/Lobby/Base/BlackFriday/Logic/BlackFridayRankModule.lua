local BlackFridayRankModule = {}
function BlackFridayRankModule:DefineAndResetData()
  self._nRankId = 79002
  self.UserCreditRankList = {}
  self.UserInfoList = {}
  self.UserUIdList = {}
  self.UserRankAwardList = {}
  self.PersonalRankInfo = {}
end
function BlackFridayRankModule:OnInitialize()
end
function BlackFridayRankModule:RegistEvents()
end
function BlackFridayRankModule:GetUserRankListData()
  local rank_util = require("client.slua.logic.rank.rank_util")
  local uObj_cfg = rank_util.GetRankRewardCfg(79002, false) or {}
  for _, v in pairs(uObj_cfg) do
    local tInfo = {}
    tInfo.awardID = v.RewardItemID1
    tInfo.startRank = v.RankCeilling
    tInfo.endRank = v.RankFloor
    table.insert(self.UserRankAwardList, tInfo)
  end
  local RankHandler = require("client.network.Protocol.RankHandler")
  RankHandler.send_get_topn_rank(0, 79002, 1)
  RankHandler.send_get_one_user_rank("BlackFridayPersonalRank", 0, tonumber(DataMgr.roleData.uid), 79002)
end
function BlackFridayRankModule:IsBlackFridayRank(score_type)
  return score_type == self._nRankId
end
function BlackFridayRankModule:HandleTopNRankResponse(ok, list)
  log(bWriteLog and "BlackFridayRankSystem.HandleTopNRankResponse: ok = " .. ok)
  if ok ~= 0 then
    log(bWriteLog and "BlackFridayRankSystem.HandleTopNRankResponse ok = " .. ok)
    return
  end
  if list and next(list) then
    self.UserUIdList = {}
    local tempUIdRank = {}
    self.UserCreditRankList = {}
    for _, v in pairs(list) do
      table.insert(self.UserUIdList, v.uid)
      tempUIdRank[tostring(v.uid)] = v.rank_no
      local info = {}
      info.rank = v.rank_no
      info.uid = v.uid
      info.score = v.score
      table.insert(self.UserCreditRankList, info)
    end
    local GetUserListInfo = function(userListInfo)
      self.UserInfoList = {}
      for _, v in pairs(userListInfo) do
        local rankIndex = tempUIdRank[tostring(v.uid)]
        if rankIndex ~= nil then
          self.UserInfoList[rankIndex] = v
        end
      end
      EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_TOPN_RANK_DATA)
    end
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(self.UserUIdList, GetUserListInfo, Enum_PROFILE_REPORT_CFG.BLACK_FRIDAY_USER_RANK)
  end
end
function BlackFridayRankModule:HandleOneUserRankResponse(client_data, ok, rank_info)
  log(bWriteLog and "BlackFridayRankSystem.HandleOneUserRankResponse: client_data = " .. client_data .. ", ok = " .. ok)
  if client_data ~= "BlackFridayPersonalRank" then
    return
  end
  if ok ~= 0 then
    log(bWriteLog and "BlackFridayRankSystem.HandleOneUserRankResponse ok = " .. ok)
    return
  end
  if rank_info and next(rank_info) then
    self.PersonalRankInfo = {
      rank = rank_info.rank_no,
      uid = rank_info.uid,
      score = rank_info.score
    }
  else
    local BlackFridayPassModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayPassModule)
    self.PersonalRankInfo = {
      rank = -1,
      uid = DataMgr.roleData.uid,
      score = BlackFridayPassModule:GetCyberScore()
    }
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_USER_RANK_DATA)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CBlackFridayRankModule = class(CModuleBase, nil, BlackFridayRankModule)
return CBlackFridayRankModule