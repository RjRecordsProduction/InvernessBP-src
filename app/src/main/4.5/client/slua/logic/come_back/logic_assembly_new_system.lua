local logic_assembly_new_system = {}
local assembly_new_macro = require("client.slua.logic.come_back.assembly_new_macro")
local assembly_macro = require("client.slua.logic.come_back.assembly_macro")
function logic_assembly_new_system:DefineAndResetData()
  self.legacyRecallCount = 0
  self.legacyRecallFriends = {}
  self.legacyRewardClaimed = {}
end
function logic_assembly_new_system:OnInitialize()
end
function logic_assembly_new_system:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_ASSEMBLY, self._OnJumpToAssembly, self)
end
function logic_assembly_new_system:OnLogin(bReLogin)
  if not bReLogin then
    self:MigrateLegacyData()
  end
end
function logic_assembly_new_system:OnLogOut()
  self:DefineAndResetData()
end
function logic_assembly_new_system:OnPreSwitchGameStatus(preState, nextState)
end
function logic_assembly_new_system:OnPostSwitchGameStatus(preState, nextState)
end
function logic_assembly_new_system:_OnJumpToAssembly(_, _, params)
  self:ShowMainUI(params and params.tabType, params and params.isFromExceptTask, params and params.selectItemId)
end
function logic_assembly_new_system:_MapLegacyTabToNew(tabType)
  if not tabType then
    return nil
  end
  return ({
    [assembly_macro.ENUM_TAB_TYPE.Friend] = assembly_new_macro.ENUM_TAB_TYPE.Rally,
    [assembly_macro.ENUM_TAB_TYPE.Teamup] = assembly_new_macro.ENUM_TAB_TYPE.TeamUp,
    [assembly_macro.ENUM_TAB_TYPE.JKWeekTask] = assembly_new_macro.ENUM_TAB_TYPE.JKWeekTask,
    [assembly_macro.ENUM_TAB_TYPE.Exchange] = assembly_new_macro.ENUM_TAB_TYPE.Exchange
  })[tabType] or tabType
end
function logic_assembly_new_system:ShowMainUI(tabType, isFromExceptTask, selectItemId)
  local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
  local activityData = AssemblyActivitySystem.GetActivityData()
  local NEW_SYSTEM_ACTIVITY_ID = 345086001
  local isActivityOpen = activityData ~= nil and tonumber(activityData.ID) == NEW_SYSTEM_ACTIVITY_ID
  log(bWriteLog and string.format("logic_assembly_new_system:ShowMainUI, isActivityOpen:%s, tabType:%s, isFromExceptTask:%s, selectItemId:%s", tostring(isActivityOpen), tostring(tabType), tostring(isFromExceptTask), tostring(selectItemId)))
  if isActivityOpen then
    self:RequestAssemblyData()
    local LobbyModUtils = require("GameLua.Mod.Lobby.Base.Common.LobbyModUtils")
    if not LobbyModUtils.IsModDownloaded(LobbyModUtils.Enum_Mod_Name.AssemblyComeBack) then
      LobbyModUtils.DownloadMod(LobbyModUtils.Enum_Mod_Name.AssemblyComeBack)
      local str = LocUtil.LocalizeResFormat(511044)
      ShowNotice(str)
      return
    end
    local newTabType = self:_MapLegacyTabToNew(tabType)
    UIManager.ShowUI(UIManager.UI_Config.Assembly_New_Main_UIBP, tonumber(newTabType))
    return
  end
  local LobbyModUtils = require("GameLua.Mod.Lobby.Base.Common.LobbyModUtils")
  if not LobbyModUtils.IsModDownloaded(LobbyModUtils.Enum_Mod_Name.AssemblyComeBack) then
    LobbyModUtils.DownloadMod(LobbyModUtils.Enum_Mod_Name.AssemblyComeBack)
    local str = LocUtil.LocalizeResFormat(511044)
    ShowNotice(str)
    return
  end
  if tonumber(tabType) == assembly_macro.ENUM_TAB_TYPE.Exchange then
    UIManager.ShowUI(UIManager.UI_Config.Lobby_Integration_Assembly_Exchange_Main_UIBP, isFromExceptTask, selectItemId)
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Assembly_Main_UIBP, tonumber(tabType) or assembly_macro.ENUM_TAB_TYPE.Friend, isFromExceptTask, selectItemId)
end
function logic_assembly_new_system:ShowLegacyMainUI(tabType, isFromExceptTask, selectItemId)
  self:RequestAssemblyData()
  local LobbyModUtils = require("GameLua.Mod.Lobby.Base.Common.LobbyModUtils")
  if not LobbyModUtils.IsModDownloaded(LobbyModUtils.Enum_Mod_Name.AssemblyComeBack) then
    LobbyModUtils.DownloadMod(LobbyModUtils.Enum_Mod_Name.AssemblyComeBack)
    local str = LocUtil.LocalizeResFormat(511044)
    ShowNotice(str)
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Assembly_Main_UIBP, tonumber(tabType), isFromExceptTask, selectItemId)
end
function logic_assembly_new_system:RequestAssemblyData()
  local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
  AssemblyActivitySystem.ReqAssemblyInfo()
end
function logic_assembly_new_system:MigrateLegacyData()
  local oldSystem = require("client.slua.logic.come_back.logic_assembly_activity")
  if oldSystem then
    if oldSystem.GetRecalledFriendCount then
      self.legacyRecallCount = oldSystem.GetRecalledFriendCount() or 0
    end
    if oldSystem.GetRecalledFriends then
      self.legacyRecallFriends = oldSystem.GetRecalledFriends() or {}
    end
    if oldSystem.GetClaimedRewards then
      self.legacyRewardClaimed = oldSystem.GetClaimedRewards() or {}
    end
  end
end
function logic_assembly_new_system:GetTotalRecalledCount()
  return self.legacyRecallCount
end
function logic_assembly_new_system:IsNewSystemEnabled()
  return true
end
function logic_assembly_new_system:OnBindAssembInvitersRsp(errCode)
  local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
  if errCode ~= 0 then
    if errCode == 720000 or errCode == 720013 then
      if AssemblyActivitySystem.AssemblyBindInfo then
        AssemblyActivitySystem.AssemblyBindInfo.invite_bound_flag = true
      end
      if AssemblyActivitySystem.AssemblyData then
        AssemblyActivitySystem.AssemblyData.invite_bound_flag = true
      end
      AssemblyActivitySystem.ExchangeData()
    else
      ShowNotice(errCode)
    end
    return
  end
  if AssemblyActivitySystem.AssemblyBindInfo then
    AssemblyActivitySystem.AssemblyBindInfo.invite_bound_flag = true
    AssemblyActivitySystem.AssemblyBindInfo.invite_request_uids = {}
  end
  if AssemblyActivitySystem.AssemblyData then
    AssemblyActivitySystem.AssemblyData.invite_bound_flag = true
    AssemblyActivitySystem.AssemblyData.invite_request_uids = {}
  end
  AssemblyActivitySystem.ExchangeData()
end
function logic_assembly_new_system:OnTakeAssembBattleRewardRsp(errCode, teamBattleProgress)
  if errCode ~= 0 then
    ShowNotice(errCode)
    return
  end
  local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
  if AssemblyActivitySystem.AssemblyData == nil then
    AssemblyActivitySystem.AssemblyData = {}
  end
  AssemblyActivitySystem.AssemblyData.team_battle_progress = teamBattleProgress
  AssemblyActivitySystem.ExchangeData()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_assembly_new_system = class(CModuleBase, nil, logic_assembly_new_system)
return Clogic_assembly_new_system