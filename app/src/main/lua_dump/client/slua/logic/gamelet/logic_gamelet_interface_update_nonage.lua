local logic_gamelet_interface_update_nonage = {}
function logic_gamelet_interface_update_nonage:ctor()
  self.timer = nil
  self.hasSet = false
  self.needUpdateRole = false
end
function logic_gamelet_interface_update_nonage:OnEnterLobby(needUpdateRole)
  log(bWriteLog and string.format("logic_gamelet_interface_update_nonage:OnEnterLobby self.hasSet = %s", tostring(self.hasSet)))
  log(bWriteLog and string.format("logic_gamelet_interface_update_nonage:OnEnterLobby needUpdateRole = %s", tostring(needUpdateRole)))
  if Client.IsEditor() then
    local gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
    gamelet_interface:SetUserDataNonage(1)
    self.hasSet = true
  end
  if self.hasSet then
    if self.timer then
      self:RemoveTimer(self.timer)
    end
    return
  end
  self.  self.timer = self:AddTimerLoop(0, self:LoopCheckAndSetNonage(), TIMER_INFINITE, 5)
end
function logic_gamelet_interface_update_nonage:LoopCheckAndSetNonage()
  local func = function()
    log(bWriteLog and string.format("logic_gamelet_interface_update_nonage:LoopCheckAndSetNonage self.hasSet = %s", tostring(self.hasSet)))
    if self.hasSet then
      if self.timer then
        self:RemoveTimer(self.timer)
      end
      return
    end
    if self.needUpdateRole and UIManager.IsUIShow(UIManager.UI_Config.Lobby_CreatRole) then
      log(bWriteLog and "logic_gamelet_interface_update_nonage:LoopCheckAndSetNonage UIManager.IsUIShow(UIManager.UI_Config.Lobby_CreatRole) == true")
      return
    end
    local gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
    if not gamelet_interface or not gamelet_interface.SetUserDataNonage then
      log(bWriteLog and "logic_gamelet_interface_update_nonage:LoopCheckAndSetNonage gamelet_interface or gamelet_interface.SetUserDataNonage is nil")
      return
    end
    local AntiaddctionSystem = require("client.logic.antiaddction.logic_antiaddction")
    local antiaddction_adult = AntiaddctionSystem.is_nonage
    log(bWriteLog and string.format("logic_gamelet_interface_update_nonage:LoopCheckAndSetNonage antiaddction_adult = %s", tostring(antiaddction_adult)))
    if AntiaddctionSystem.is_nonage ~= nil then
      gamelet_interface:SetUserDataNonage(antiaddction_adult)
      self.hasSet = true
      return
    end
    local gdpr_user_type = DataMgr.roleData.eugdpr and DataMgr.roleData.eugdpr.user_type or 1
    local gdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
    local bIsEUGDPRUser = gdprSystem.IsEUGDPRUser(gdpr_user_type)
    log(bWriteLog and string.format("logic_gamelet_interface_update_nonage:LoopCheckAndSetNonage bIsEUGDPRUser = %s", tostring(bIsEUGDPRUser)))
    if bIsEUGDPRUser == true then
      local gdpr_adult = gdprSystem.GetEUGDPR_IsAdult()
      log(bWriteLog and string.format("logic_gamelet_interface_update_nonage:LoopCheckAndSetNonage gdpr_adult = %s", tostring(gdpr_adult)))
      if gdpr_adult ~= nil then
        if gdpr_adult then
          gamelet_interface:SetUserDataNonage(0)
        else
          gamelet_interface:SetUserDataNonage(1)
        end
        self.hasSet = true
        return
      end
    end
    if bIsEUGDPRUser == false then
      local logic_compliance = require("client.slua.logic.gdpr.logic_compliance")
      if logic_compliance.IsEntryOpen() then
        log(bWriteLog and "logic_gamelet_interface_update_nonage:LoopCheckAndSetNonage SDKQueryUserStatus")
        logic_compliance.SDKSetUserProfile("")
        logic_compliance.SDKQueryUserStatus(function(jsonData)
          printf("logic_gamelet_interface_update_nonage:LoopCheckAndSetNonage SDKQueryUserStatus jsonData:%s", jsonData)
          local nonage = 1
          if jsonData and jsonData.adultStatus == 1 then
            nonage = 0
          else
            nonage = 1
          end
          gamelet_interface:SetUserDataNonage(nonage)
        end)
        self.hasSet = true
        return
      end
    end
  end
  return func
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_gamelet_interface_update_nonage = class(CModuleBase, nil, logic_gamelet_interface_update_nonage)
return Clogic_gamelet_interface_update_nonage