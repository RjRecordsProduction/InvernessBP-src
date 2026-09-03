local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
local flash_team_data_handler = require("client.slua.logic.friend.flash_team.flash_team_data_handler")
local FlashTeamHandler = require("client.network.Protocol.FlashTeamHandler")
return function(ModeSelection_Main_UIBP)
  function ModeSelection_Main_UIBP:InitRecommendTips(tabId)
    self.curSelectTabId = tabId
    self:SetWidgetVisible(self.UIRoot.TeamQuick_AITips_U, false)
    self:SetWidgetVisible(self.UIRoot.TeamQuick_AITips_D, false)
    local isTrigger = flash_team_data_handler:CheckTriggerModeSelectTip(self.curSelectTabId)
    if not isTrigger then
      log(bWriteLog and "ModeSelection_Main_UIBP_FlashTeam:InitRecommendTips Not isTrigger")
      return
    end
    local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
    local logic_teamquick_join = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_teamquick_join)
    local preferMainId = logic_teamquick_join:GetPreferModesOver60Percent(0.4) or flash_team_data_handler:GMGetMainMode()
    if not preferMainId then
      return
    end
    self.recommendMainIds = {}
    self.recommendModeMap = {}
    self.recommendMainIds[#self.recommendMainIds + 1] = preferMainId
    if self.curSelectTabId == mode_selection_macro.Enum_TabID.RankArena then
      self.recommendModeMap[UEnums.GameMode.Rank_Competition] = true
    else
      local gameModeIds = logic_flash_match_team:GetModesByID(preferMainId)
      for idx, modeId in ipairs(gameModeIds) do
        self.recommendModeMap[modeId] = true
      end
    end
    local myTeams = logic_flash_match_team:getMyTeams()
    local RQTList = logic_flash_match_team:GetRQTList()
    if #myTeams == 0 and RQTList then
      for idx, info in ipairs(RQTList) do
        if self.recommendModeMap[info.modeId] then
          logic_flash_match_team:SetRQTTeamIdx(idx)
          self.showCreateTeam = info
          self:ShowTeamList()
          return
        end
      end
      log(bWriteLog and "ModeSelection_Main_UIBP_FlashTeam:InitRecommendTips \230\178\161\230\156\137\229\175\185\229\186\148\230\168\161\229\188\143\231\154\132\230\142\168\232\141\144\229\187\186\233\152\159")
    end
    local TimeUtil = require("client.common.time_util")
    local now = TimeUtil.GetServerTimeInSec()
    if not self._lastRecommendReqTime or now - self._lastRecommendReqTime > 3 then
      log_tree(bWriteLog and "ModeSelection_Main_UIBP_FlashTeam:InitRecommendTips reqMode \231\173\155\233\128\137\231\154\132\230\168\161\229\188\143:", self.recommendMainIds)
      FlashTeamHandler.send_get_flash_squad_recommend_req(10)
      self._lastRecommendReqTime = now
    end
  end
  function ModeSelection_Main_UIBP:OnRecomInfoRsp()
    local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
    local recommendSquads = logic_flash_match_team:getRecomSquad()
    self.curRecommends = {}
    if self.recommendMainIds and next(self.recommendMainIds) then
      self.curRecommends = logic_flash_match_team:getRecomSquadByFilter(self.recommendMainIds)
      self.recommendMainIds = nil
    end
    local rcmdCount = #self.curRecommends
    if not (self.curSelectTabId and self.curRecommends) or #self.curRecommends == 0 then
      return
    end
    self.recommendIds = {}
    if rcmdCount == 1 then
      self.recommendIds = {
        self.curRecommends[1].squad_id
      }
      self:ShowTeamList()
      return
    else
      table.sort(self.curRecommends, function(a, b)
        if a.pre_team_count ~= b.pre_team_count then
          return a.pre_team_count > b.pre_team_count
        end
        if a.online_count ~= b.online_count then
          return a.online_count > b.online_count
        end
        return a.display_score < b.display_score
      end)
    end
    local myTeams = logic_flash_match_team:getMyTeams()
    if #myTeams == 0 then
      table.insert(self.recommendIds, self.curRecommends[1].squad_id)
    else
      if rcmdCount == 2 then
        table.insert(self.recommendIds, self.curRecommends[1].squad_id)
        table.insert(self.recommendIds, self.curRecommends[2].squad_id)
        self:ShowTeamList()
        return
      end
      if #myTeams <= 2 then
        local existingSlots = {}
        for _, team in ipairs(myTeams) do
          if team.active_slots and #team.active_slots == 2 then
            local slotKey = string.format("%d_%d", team.active_slots[1] or 0, team.active_slots[2] or 0)
            existingSlots[slotKey] = true
          end
        end
        local differentTeams = {}
        for idx, info in ipairs(self.curRecommends) do
          if info.active_slots and #info.active_slots == 2 then
            local slotKey = string.format("%d_%d", info.active_slots[1] or 0, info.active_slots[2] or 0)
            if not existingSlots[slotKey] then
              table.insert(differentTeams, info)
            end
          end
        end
        if 2 <= #differentTeams then
          table.insert(self.recommendIds, differentTeams[1].squad_id)
          table.insert(self.recommendIds, differentTeams[2].squad_id)
        elseif #differentTeams == 1 then
          table.insert(self.recommendIds, differentTeams[1].squad_id)
          if #self.curRecommends >= 2 then
            table.insert(self.recommendIds, self.curRecommends[1].squad_id)
          end
        elseif #self.curRecommends >= 2 then
          table.insert(self.recommendIds, self.curRecommends[1].squad_id)
          table.insert(self.recommendIds, self.curRecommends[2].squad_id)
        elseif #self.curRecommends == 1 then
          table.insert(self.recommendIds, self.curRecommends[1].squad_id)
        end
        self:ShowTeamList()
        return
      else
        local squad_ids = {}
        for idx, team in ipairs(self.curRecommends) do
          table.insert(squad_ids, team.squad_id)
        end
        FlashTeamHandler.send_batch_get_flash_squad_members_brief_req(squad_ids)
      end
    end
  end
  function ModeSelection_Main_UIBP:OnRecomMemberRsp()
    local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
    if not self.curRecommends or #self.curRecommends == 0 then
      log(bWriteLog and "ModeSelection_Main_UIBP_FlashTeam:OnRecomMemberRsp no recommends")
      return
    end
    self.recommendIds = {}
    local highlyTeams = {}
    local normalTeams = {}
    for _, team in ipairs(self.curRecommends) do
      local memberInfo = logic_flash_match_team:GetFlashTeamMembersById(team.squad_id)
      local memberList = memberInfo and memberInfo.list or nil
      if flash_team_data_handler:JudgeTeamIsHighlyRecommend(team, memberList) then
        table.insert(highlyTeams, team)
      else
        table.insert(normalTeams, team)
      end
      if 0 < #highlyTeams and 0 < #normalTeams then
        self.recommendIds[1] = highlyTeams[1].squad_id
        self.recommendIds[2] = normalTeams[1].squad_id
        break
      end
    end
    if #highlyTeams == 0 then
      self.recommendIds[1] = normalTeams[1] and normalTeams[1].squad_id
      self.recommendIds[2] = normalTeams[2] and normalTeams[2].squad_id
    elseif #normalTeams == 0 then
      self.recommendIds[1] = highlyTeams[1] and highlyTeams[1].squad_id
      self.recommendIds[2] = highlyTeams[2] and highlyTeams[2].squad_id
    end
    self:ShowTeamList()
  end
  function ModeSelection_Main_UIBP:ShowTeamList()
    if (not self.recommendIds or not next(self.recommendIds)) and not self.showCreateTeam then
      return
    end
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local TWO_WEEKS_DAYS = 14
    local canTrigger = PlayerPrefsSystem.CheckAndSaveCurrentDate_DynamicPath(flash_team_data_handler.triggerRemindKey, tostring(self.curSelectTabId), false, TWO_WEEKS_DAYS)
    local isLeftRcmd = self.curSelectTabId and self.curSelectTabId == mode_selection_macro.Enum_TabID.MatchArena or self.curSelectTabId == mode_selection_macro.Enum_TabID.RankArena or self.curSelectTabId == mode_selection_macro.Enum_TabID.MatchTxMission
    local isBottomRcmd = self.curSelectTabId and self.curSelectTabId == mode_selection_macro.Enum_TabID.UGC
    self:SetWidgetVisible(self.UIRoot.TeamQuick_AITips_U, isLeftRcmd)
    self:SetWidgetVisible(self.UIRoot.TeamQuick_AITips_D, isBottomRcmd)
    local param = {
      tabId = self.curSelectTabId,
      recommendIds = self.recommendIds,
      showRQTTeam = self.showCreateTeam,
      curSelectModesMap = self.recommendModeMap
    }
    local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
    if isLeftRcmd then
      if not self.TeamQuick_AITips_U then
        self.TeamQuick_AITips_U = UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.ModeSelection_TeamQuick_AITips, self.UIRoot.TeamQuick_AITips_U, param)
        self.TeamQuick_AITips_U:SetBotPos(0)
      else
        self.TeamQuick_AITips_U:UpdateUI()
      end
    elseif isBottomRcmd then
      if not self.TeamQuick_AITips_D then
        self.TeamQuick_AITips_D = UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.ModeSelection_TeamQuick_AITips, self.UIRoot.TeamQuick_AITips_D, param)
        self.TeamQuick_AITips_D:SetBotPos(1)
      else
        self.TeamQuick_AITips_D:UpdateUI()
      end
    end
  end
end