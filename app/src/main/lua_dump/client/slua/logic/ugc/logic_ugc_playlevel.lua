local logic_ugc_playlevel = {
  CurLevel = nil,
  CurExp = nil,
  Award = {},
  Items = {},
  PrivacyMap = {},
  reddot = nil
}
function logic_ugc_playlevel:OnInitialize()
  self.PrivacyMap = {}
end
function logic_ugc_playlevel:OnLogOut()
  self.CurLevel = nil
  self.CurExp = nil
  self.Award = nil
  self.Items = nil
  self.reddot = nil
  self.PrivacyMap = nil
end
function logic_ugc_playlevel:PreEnter()
  print(bWriteLog and "[v_yibxu] logic_ugc_playlevel:PreEnter")
  if not next(self.Award) then
    local UGCAuthorHandler = require("client.network.Protocol.UGCAuthorHandler")
    UGCAuthorHandler.send_ugc_play_level_get_award_info_req()
  end
end
function logic_ugc_playlevel:GetMaxLevel()
  local MaxLevel = 1
  local UGCPlayLevelData = CDataTable.GetTable("UGCPlayLevelData")
  for index, value in ipairs(UGCPlayLevelData) do
    if MaxLevel < value.Level then
      MaxLevel = value.Level
    end
  end
  return MaxLevel
end
function logic_ugc_playlevel:RspGetPlayLevelAwardInfo(level, exp, award)
  self.CurLevel = level
  self.CurExp = exp
  self.Award = award
  self:UpdateRedDot()
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_PERSON_UGC_PLAY_LEVEL_DATA_RSP)
  local rank_data = require("client.slua.logic.rank.rank_data")
  local rank_data_converter = require("client.slua.logic.rank.rank_data_converter")
  rank_data.SetSelfRankData({
    uid = tonumber(DataMgr.roleData.uid),
    ugc_play_level = self.CurLevel,
    ugc_play_exp = self.CurExp
  }, rank_data_converter.ConvertWoWPlayProfileRsp)
  EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_SELF)
end
function logic_ugc_playlevel:RspGetPlayLevelAward(level, exp, items, award)
  self.CurLevel = level
  self.CurExp = exp
  self.Award = award
  self.Items = items
  self:UpdateRedDot()
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_PERSON_UGC_PLAY_LEVEL_AWARD_RSP)
end
function logic_ugc_playlevel:PlayLevelNtf(level, exp, award)
  self.CurLevel = level
  self.CurExp = exp
  if award then
    self.Award = award
    self:UpdateRedDot()
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_PERSON_UGC_PLAY_LEVEL_NTF)
end
function logic_ugc_playlevel:ReqGetPrivacy(UID)
  UID = tonumber(UID) or 0
  if UID == 0 then
    return
  end
  if UID ~= tonumber(DataMgr.roleData.uid) and self.PrivacyMap and self.PrivacyMap[UID] then
    return
  end
  local UGCAuthorHandler = require("client.network.Protocol.UGCAuthorHandler")
  UGCAuthorHandler.send_ugc_get_other_all_meta_key_req(UID)
end
function logic_ugc_playlevel:RspGetPrivacy(UID, PlayData, PrivacyData)
  if not self.PrivacyMap[UID] then
    self.PrivacyMap[UID] = {}
  end
  self.PrivacyMap[UID] = {PlayData = PlayData, PrivacyData = PrivacyData}
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_PERSON_UGC_PLAY_DATA_RSP, UID, PlayData, PrivacyData)
end
function logic_ugc_playlevel:GetTitle(level)
  local data = CDataTable.GetTableData("UGCPlayLevelData", level)
  if not data then
    return ""
  end
  local NumStr = data.Title_Name
  local LocId = data.LocID
  local Str = LocUtil.LocalizeResFormat(LocId, NumStr)
  return Str
end
function logic_ugc_playlevel:GetTitleBg(level)
  local data = CDataTable.GetTableData("UGCPlayLevelData", level)
  if not data then
    return ""
  end
  return data.BgPath
end
function logic_ugc_playlevel:GetEXPPercentStr(level, exp)
  local data = CDataTable.GetTableData("UGCPlayLevelData", level)
  if not data then
    return ""
  end
  return LocUtil.LocalizeResFormat(6830, exp, data.Exp)
end
function logic_ugc_playlevel:GetEXPPercent(level, exp)
  local data = CDataTable.GetTableData("UGCPlayLevelData", level)
  if not data then
    return 0
  end
  local MaxLevel = self:GetMaxLevel()
  if level == MaxLevel then
    return 1
  elseif data.Exp ~= 0 then
    return exp / data.Exp
  else
    log(bWriteLog and "logic_ugc_playlevel:GetEXPPercent()    \233\129\191\229\133\141\229\188\130\229\184\184\239\188\140\231\187\153\228\184\128\228\184\170\233\187\152\232\174\164\229\128\188")
    return 0
  end
end
function logic_ugc_playlevel:GetScrollIndex()
  for key, value in pairs(self.Award) do
    if value == 1 then
      return key
    end
  end
  return self.CurLevel or 0
end
function logic_ugc_playlevel:HasRedpoint()
  local ugc_playlevel_reddot_data = require("client.slua.logic.ugc.playlevel.ugc_playlevel_reddot_data")
  if not self.reddot then
    self.reddot = ugc_playlevel_reddot_data.GetData()
  end
  return self.reddot.newCount > 0
end
function logic_ugc_playlevel:UpdateRedDot()
  if not self.Award then
    return
  end
  local RedDotCount = 0
  local E_  for Lv, AwardState in pairs(self.Award) do
    if 0 < Lv and AwardState == E_ActivityProgressStatus.Done then
      RedDotCount = RedDotCount + 1
      break
    end
  end
  local UGCWOWPlayRedDotData = require("client.slua.logic.ugc.playlevel.ugc_playlevel_reddot_data")
  UGCWOWPlayRedDotData.UpdatePlayDataCount(RedDotCount)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local logic_ugc_playlevel = class(CModuleBase, nil, logic_ugc_playlevel)
return logic_ugc_playlevel