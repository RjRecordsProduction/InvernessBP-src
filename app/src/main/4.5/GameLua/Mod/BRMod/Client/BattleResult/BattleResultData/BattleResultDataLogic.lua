local BattleResultDataLogic = {}
local ResultUtil = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultUtil")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function BattleResultDataLogic:OnInit()
  print(bWriteLog and "BattleResultDataLogic:OnInit")
  self.Data = {}
  self.MedalConfig = {
    MedalIndexList = {}
  }
  local cfg = CDataTable.GetTable("ResultPraiseTitleConfig")
  for _, v in pairs(cfg) do
    if v.CenterIconPath and v.CenterIconPath ~= "" and v.DescID and v.DescID ~= "" then
      table.insert(self.MedalConfig.MedalIndexList, v.ID)
      self.MedalConfig[v.ID] = {
        Name = v.NameLocalizeID,
        ImgPath = v.CenterIconPath,
        Desc = v.DescID
      }
    end
  end
  self.Data.MedalConfig = self.MedalConfig
end
function BattleResultDataLogic:OnRelease()
  print(bWriteLog and "BattleResultDataLogic:OnRelease")
end
function BattleResultDataLogic:OnBattleResult(result)
  if self.Data == nil then
    self.Data = {}
  end
  self.Data.BP_STRUCT_RecordingUpload = {}
  self.Data.BP_STRUCT_RecordingUpload.platform = _G.BP_Platform == BP_ENUM_PLAYFORM_BGBG and FuncUtil.GetKeywordByID(3377007) or "WX"
  self.Data.BP_STRUCT_RecordingUpload.openUid = tostring(DataMgr.roleData.openID)
  self.Data.BP_STRUCT_RecordingUpload.roleUid = tostring(DataMgr.roleData.uid)
  self.Data.BP_STRUCT_RecordingUpload.battleUid = tostring(g_game_id)
  for _, TeammateInfo in pairs(result.TeammateList) do
    if DataMgr.roleData.uid and TeammateInfo.UID == tonumber(DataMgr.roleData.uid) then
      self.Data.BP_myname = TeammateInfo.Name
      break
    end
  end
  print(bWriteLog and "BattleResultDataLogic:OnBattleResult", self.Data.BP_myname, DataMgr.roleData.uid, BattleResultUI.UseTXTResultData)
  if BattleResultUI.UseTXTResultData then
    log_tree("UseTXTResultData", result)
    if result.BP_myname then
      self.Data.BP_myname = result.BP_myname
    else
      print(bWriteLog and "table.txt\231\154\132\231\187\147\231\174\151table\228\184\173\230\178\161\230\156\137BP_myname\239\188\140\232\175\183\230\137\139\229\138\168\232\161\165\229\133\133\239\188\129\239\188\129\239\188\129")
      self.Data.BP_myname = "jojo"
    end
    for _, TeammateInfo in pairs(result.TeammateList) do
      if TeammateInfo.Name == self.Data.BP_myname then
        DataMgr.roleData.uid = tostring(TeammateInfo.UID)
      end
    end
    print(bWriteLog and "UseTXTResultData", DataMgr.roleData.uid)
  end
  if self.USE_TEST then
    self.Data.BP_myname = "jojo"
    DataMgr.roleData.uid = "54300001779"
    self.Data.BP_STRUCT_RecordingUpload.roleUid = DataMgr.roleData.uid
  end
  if self.Data.BP_myname == nil or self.Data.BP_myname == "" then
    self.Data.BP_myname = DataMgr.roleData.nickName or BP_myname or ""
  end
  self.Data.BP_TeamModeName = ResultUtil.GetTeamModeName(result.battle_type, result.sub_mode)
  self.Data.BP_EnterSpectateMode = false
  log(bWriteLog and "BattleResultDataLogic:OnBattleResult Reason:" .. tostring(result.Reason) .. " IsSolo:" .. tostring(result.IsSolo) .. " is_last_survive:" .. tostring(result.is_last_survive) .. " is_team_result:" .. tostring(result.is_team_result))
  if result.IsSolo == false then
    if result.is_last_survive then
      log(bWriteLog and "BattleResultUI last survive!!!!!")
      self.Data.BP_EnterSpectateMode = false
    elseif result.is_team_result then
      self.Data.BP_EnterSpectateMode = false
    else
      self.Data.BP_EnterSpectateMode = true
    end
  else
    result.is_last_survive = true
    self.Data.BP_EnterSpectateMode = false
  end
  if result.terminator ~= nil then
    self.Data.BP_Terminator = result.terminator
  else
    self.Data.BP_Terminator = ""
  end
  log(bWriteLog and "BP_Terminator:" .. self.Data.BP_Terminator)
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  for k, v in pairs(result.TeammateList) do
    if v.Name == self.Data.BP_myname then
      self.Data.BP_mykill = v.Kill
      self.Data.BP_mystate = v.State
      if v.surviveTime ~= nil then
        self.Data.BP_MySurviveTime_f = v.surviveTime
      end
      self.Data.BP_STRUCT_RecordingUpload.killNum = v.Kill
      self.Data.BP_STRUCT_RecordingUpload.HeadShotNum = v.HeadShotNum
    end
    if v.wear_ext and v.wear_ext[3] and v.wear_ext[3][1] then
      local itemID = v.wear_ext[3][1]
      local period = XSuitUtil:GetPeriodByItemId(itemID)
      local source = v.wear_ext[3][ENUM_AVATAR_DATA_TYPE.Source]
      if period then
        local branchId = XSuitUtil:GetBranchIdByItemId(itemID)
        if result.gold_dress_level_set_info and source ~= 1 then
          local levelInfo = result.gold_dress_level_set_info[v.UID]
          if levelInfo and levelInfo.set_info and levelInfo.set_info[period] and levelInfo.set_info[period][branchId] then
            local newLevel = levelInfo.set_info[period][branchId]
            local newItemID = XSuitUtil:GetSwitchItemByItemAndSwitchLevel(itemID, newLevel)
            log(bWriteLog and "BattleResultDataLogic:OnBattleResult GoldenSuit level change " .. tostring(period) .. tostring(itemID) .. tostring(newItemID))
            v.wear_ext[3][1] = newItemID
            itemID = newItemID
          end
        end
        if result.gold_dress_state_info then
          local stateInfo = result.gold_dress_state_info[v.UID]
          if stateInfo and stateInfo[period] and stateInfo[period][branchId] then
            local newState = stateInfo[period][branchId]
            local newItemID = XSuitUtil:ChangeItemIDByState(itemID, newState.cur_state)
            log(bWriteLog and "BattleResultDataLogic:OnBattleResult GoldenSuit state change " .. tostring(period) .. tostring(itemID) .. tostring(newItemID))
            v.wear_ext[3][1] = newItemID
          end
        end
      end
    end
  end
  self.Data.BP_MyPVE_DEGREE = 0
  self.Data.BP_MyCurPVE_EXP = 0
  self.Data.BP_MyTotalPVE_EXP = 0
  if DataMgr.roleData.pve_exp ~= nil then
    self.Data.BP_MyCurPVE_EXP = DataMgr.roleData.pve_exp
  end
  if DataMgr.roleData.pve_level ~= nil then
    self.Data.BP_MyPVE_DEGREE = DataMgr.roleData.pve_level
  end
  if self.Data.BP_MyPVE_DEGREE ~= 0 then
    local tmpEXP = CDataTable.GetTableData("PveLevel", self.Data.BP_MyPVE_DEGREE).exp
    if tmpEXP ~= nil then
      self.Data.BP_MyTotalPVE_EXP = tmpEXP
    end
  end
  for _, TeammateInfo in pairs(result.TeammateList) do
    if TeammateInfo.Name == self.Data.BP_myname and TeammateInfo.Achievements and TeammateInfo.Achievements[43] then
      self.Data.IsSelfKingElimination = true
    end
    if TeammateInfo.Achievements then
      local BattleResultOtherConfig = GamePlayTools.GetCurrentConfig("BattleResultConfig").OtherConfig
      local MaxShowNum = 6
      local SortedAchievementsInfo = {}
      for _, i in pairs(self.MedalConfig.MedalIndexList) do
        if TeammateInfo.Achievements[i] then
          local medalCfg = CDataTable.GetTableData("ResultPraiseTitleConfig", i)
          table.insert(SortedAchievementsInfo, {
            Type = i,
            Priority = medalCfg and medalCfg.Priority or 999
          })
        end
      end
      table.sort(SortedAchievementsInfo, function(a, b)
        return a.Priority < b.Priority
      end)
      for idx, info in pairs(SortedAchievementsInfo) do
        if idx > MaxShowNum then
          TeammateInfo.Achievements[info.Type] = nil
        else
          TeammateInfo.Achievements[info.Type].Priority = info.Priority
        end
      end
      log_tree(bWriteLog and "BattleResultDataLogic:OnBattleResult SortedAchievementsInfo", SortedAchievementsInfo)
      log_tree(bWriteLog and "BattleResultDataLogic:OnBattleResult Achievements", TeammateInfo.Achievements)
    end
  end
end
function BattleResultDataLogic:GetBattleResultData()
  print(bWriteLog and "BattleResultDataLogic:GetBattleResultData")
  return self.Data
end
local class = require("class")
local BattleResultProcessBaseLogic = require("GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.BattleResultProcessBaseLogic")
local CBattleResultDataLogic = class(BattleResultProcessBaseLogic, nil, BattleResultDataLogic)
return CBattleResultDataLogic