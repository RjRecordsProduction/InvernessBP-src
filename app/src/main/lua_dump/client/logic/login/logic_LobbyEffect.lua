local LobbyEffect = {maxShowEffectNum = 0}
local maxShowEffectNum = 2
local suplyTime = 259200
local aniIntervalTime = {
  [1] = 0,
  [2] = 0.5,
  [3] = 0.5,
  [4] = 0.5
}
local E_EffectPrior = {
  StartGame = 1,
  RP = 2,
  Supply = 3,
  Store = 4
}
local EffectUI = {
  [1] = {
    UI = "match_new_entry",
    AniName = "Anina_Permanent",
    component = "Effect_StartGame"
  },
  [2] = {
    UI = "Lobby_Mid_Shop_UIBP",
    AniName = "Anima_RP",
    component = "Effect_RP"
  },
  [3] = {
    UI = "Lobby_Mid_Shop_UIBP",
    AniName = "Anima_Supply",
    component = "Effect_Supply"
  },
  [4] = {
    UI = "Lobby_Mid_Shop_UIBP",
    AniName = "Anima_Shop",
    component = "Effect_Shop"
  }
}
function LobbyEffect.UpdateEffectUI()
  if not LobbySystem.CheckOpen(BP_REDUCE_LOBBY_EFFECT) then
    return
  end
  LobbyEffect.maxShowEffectNum = maxShowEffectNum or 2
  local EffectList = LobbyEffect.GetEffectList() or {}
  LobbyEffect.UpdateEffect(EffectList)
end
function LobbyEffect.GetEffectList()
  local EffectList = {}
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local isInTeam = TeamUpNewSystem.GetTeamNum() > 1
  if not isInTeam then
    EffectList[E_EffectPrior.StartGame] = true
  else
    local bIsLeader = TeamUpNewSystem.IsTeamLeader(DataMgr.roleData.uid)
    if bIsLeader then
      local haveEffect = true
      for uid, v in pairs(TeamUpNewSystem.teamInfo.members) do
        if DataMgr.roleData.uid ~= uid and v.status and v.status ~= ENUM_MatchStatus.Ready then
          haveEffect = false
          break
        end
      end
      if haveEffect then
        EffectList[E_EffectPrior.StartGame] = true
      end
    end
  end
  if not UnknowPassSystem.IsBuyElite and UnknowPassSystem.IsInCurSession then
    EffectList[E_EffectPrior.RP] = true
  end
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  local isShowSupplyEffect = store_supply_manager:IsSupplyNewTag()
  if isShowSupplyEffect then
    EffectList[E_EffectPrior.Supply] = true
  end
  EffectList[E_EffectPrior.Store] = true
  return EffectList
end
function LobbyEffect.UpdateEffect(EffectList)
  local ui
  local isShowEffect = false
  local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if not lobbyMain then
    return
  end
  for i, uiInfo in ipairs(EffectUI) do
    ui = lobbyMain:GetChildUI(UIManager.UI_Config[uiInfo.UI])
    if not ui then
      break
    end
    if uiInfo.AniName then
      if LobbyEffect.maxShowEffectNum > 0 and EffectList[i] then
        ui:PlayLobbyEffect(aniIntervalTime[i], uiInfo.AniName)
        isShowEffect = true
        LobbyEffect.maxShowEffectNum = LobbyEffect.maxShowEffectNum - 1
      else
        isShowEffect = false
        ui:StopLobbyEffect(uiInfo.AniName)
      end
    end
    local UIUtil = require("client.common.ui_util")
    if uiInfo.component and ui.UIRoot then
      ui.UIRoot[uiInfo.component]:SetWidgetVisibility(UIUtil.BoolToVisible(isShowEffect))
    end
  end
end
return LobbyEffect