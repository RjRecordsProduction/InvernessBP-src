local logic_user_ctrl = {}
function logic_user_ctrl:OnInitialize()
  logic_user_ctrl.__super.OnInitialize(self)
end
function logic_user_ctrl:OnLogin(bReLogin)
end
function logic_user_ctrl:OnLogOut()
end
function logic_user_ctrl:OnPreSwitchGameStatus(preState, nextState)
end
function logic_user_ctrl:OnPostSwitchGameStatus(preState, nextState)
end
function logic_user_ctrl:IsNewUser()
  local config_user = require("client.slua.logic.user.config_user")
  if LobbySystem.roleData and LobbySystem.roleData.popui_type then
    return LobbySystem.roleData.popui_type == config_user.E_UserCtrl.Enum_Rookie
  end
  return false
end
function logic_user_ctrl:IsReturnUser()
  local config_user = require("client.slua.logic.user.config_user")
  if LobbySystem.roleData and LobbySystem.roleData.popui_type then
    return LobbySystem.roleData.popui_type == config_user.E_UserCtrl.Enum_LongReturn or LobbySystem.roleData.popui_type == config_user.E_UserCtrl.Enum_ShortReturn
  end
  return false
end
function logic_user_ctrl:GetUserType()
  if LobbySystem.roleData and LobbySystem.roleData.popui_type then
    return LobbySystem.roleData.popui_type
  end
  return nil
end
function logic_user_ctrl:ReportEventNewUserFirstInLobby()
  if not self:IsNewUser() then
    local StatManager = import("StatManager")
    local BusinessHelper = import("BusinessHelper")
    StatManager.GetInstance():ReportEventWithParam(92, {
      openId = BusinessHelper.GetOpenId(),
      nation = DataMgr.roleData.nation
    }, true)
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eNewUserFirstInLobby)
  if saveData then
    return
  end
  local StatManager = import("StatManager")
  local BusinessHelper = import("BusinessHelper")
  StatManager.GetInstance():ReportEventWithParam(74, {
    openId = BusinessHelper.GetOpenId(),
    nation = DataMgr.roleData.nation
  }, true)
  local cfg = {bFirstLogin = true}
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eNewUserFirstInLobby)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogic_User_Ctrl = class(CModuleBase, nil, logic_user_ctrl)
return CLogic_User_Ctrl