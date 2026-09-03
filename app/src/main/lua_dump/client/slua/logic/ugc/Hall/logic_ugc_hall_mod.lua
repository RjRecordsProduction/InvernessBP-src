local logic_ugc_hall_mod = {}
function logic_ugc_hall_mod:DefineAndResetData()
end
function logic_ugc_hall_mod:OnInitialize()
  self.bIsSkipChangeTeamUI = false
  self.bReEnterUGCHall = false
end
function logic_ugc_hall_mod:RegistEvents()
end
function logic_ugc_hall_mod:SetIsSkipChangeTeamUI(bIsSkipChangeTeamUI)
  log(bWriteLog and "logic_ugc_hall_mod:SetIsSkipChangeTeamUI self.bIsSkipChangeTeamUI = " .. tostring(self.bIsSkipChangeTeamUI) .. " bIsSkipChangeTeamUI = " .. tostring(bIsSkipChangeTeamUI))
  self.end
function logic_ugc_hall_mod:GetIsSkipChangeTeamUI()
  log(bWriteLog and "logic_ugc_hall_mod:GetIsSkipChangeTeamUI self.bIsSkipChangeTeamUI = " .. tostring(self.bIsSkipChangeTeamUI))
  return self.bIsSkipChangeTeamUI
end
function logic_ugc_hall_mod:SetIsReEnterUGCHall(bReEnterUGCHall)
  log(bWriteLog and "logic_ugc_hall_mod:SetIsReEnterUGCHall self.bReEnterUGCHall = " .. tostring(self.bReEnterUGCHall) .. " bReEnterUGCHall = " .. tostring(bReEnterUGCHall))
  self.end
function logic_ugc_hall_mod:GetIsReEnterUGCHall()
  log(bWriteLog and "logic_ugc_hall_mod:GetIsReEnterUGCHall self.bReEnterUGCHall = " .. tostring(self.bReEnterUGCHall))
  return self.bReEnterUGCHall
end
function logic_ugc_hall_mod:OnJoinTeamEventInModeSelection()
  log(bWriteLog and "logic_ugc_hall_mod:OnJoinTeamEventInModeSelection")
  self:AddTimerOnce(0.1, function()
    log(bWriteLog and "logic_ugc_hall_mod:OnJoinTeamEventInModeSelection 0.1")
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.ugc_mod_id then
      log(bWriteLog and "logic_ugc_hall_mod:OnJoinTeamEventInModeSelection TeamUpNewSystem.teamInfo.ugc_mod_id: " .. tostring(TeamUpNewSystem.teamInfo.ugc_mod_id))
      local logic_lobby_main_page_jump = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_main_page_jump)
      logic_lobby_main_page_jump:JumpToPage(ENUM_LobbyPageType.Right, nil, {bUGC = true})
    end
  end)
end
function logic_ugc_hall_mod:OnJoinTeamEventInUGCFindHall()
  log(bWriteLog and "logic_ugc_hall_mod:OnJoinTeamEventInUGCFindHall")
  self:AddTimerOnce(0.1, function()
    log(bWriteLog and "logic_ugc_hall_mod:OnJoinTeamEventInUGCFindHall 0.1")
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.ugc_mod_id then
      log(bWriteLog and "logic_ugc_hall_mod:OnJoinTeamEventInUGCFindHall TeamUpNewSystem.teamInfo.ugc_mod_id: " .. tostring(TeamUpNewSystem.teamInfo.ugc_mod_id))
      local logic_lobby_main_page_jump = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_main_page_jump)
      local callback = function(bSuccess)
        log(bWriteLog and "logic_ugc_hall_mod:OnJoinTeamEventInUGCFindHall callback bSuccess: " .. tostring(bSuccess))
        self:AddTimerOnce(0, function()
          if not bSuccess then
            UIManager.ShowUI(UIManager.UI_Config.UGC_Hall_UIBP, false)
          end
        end)
      end
      logic_lobby_main_page_jump:JumpToPage(ENUM_LobbyPageType.Right, callback, {bUGC = true})
    end
  end)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_ugc_hall_mod = class(CModuleBase, nil, logic_ugc_hall_mod)
return Clogic_ugc_hall_mod