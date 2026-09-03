local logic_social_lobby_performance = {}
local GMDebug = false
function logic_social_lobby_performance:DefineAndResetData()
  self.lastSetTick = nil
end
function logic_social_lobby_performance:RegistEvents()
  log(bWriteLog and "logic_social_lobby_performance:RegistEvents")
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_ENTER, self.OnCloseSocialModelTick, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_RETURN_TO_LOBBY, self.OnOpenSocialModelTick, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_START, self.OnSwitchToPageStart, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_ENTER, self.OnOpenSocialModelTick, self)
end
function logic_social_lobby_performance:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_social_lobby_performance:OnPostSwitchGameStatus pre = " .. tostring(preState) .. " nextState = " .. tostring(nextState))
  if nextState ~= GameStatus.Fighting then
    return
  end
  local isInMainCity = GameStatus.IsInMainCity()
  log(bWriteLog and "logic_social_lobby_performance:OnPostSwitchGameStatus isInMainCity = " .. tostring(isInMainCity))
  if isInMainCity then
    return
  end
  self:DefineAndResetData()
end
function logic_social_lobby_performance:OnCloseSocialModelTick()
  log(bWriteLog and "logic_social_lobby_performance:OnCloseSocialModelTick")
  self:SetSocialModelTick(false)
end
function logic_social_lobby_performance:OnOpenSocialModelTick()
  log(bWriteLog and "logic_social_lobby_performance:OnOpenSocialModelTick")
  self:SetSocialModelTick(true)
end
function logic_social_lobby_performance:OnSwitchToPageStart(_, _, toPage)
  log(bWriteLog and "logic_social_lobby_performance:OnSwitchToPageStart toPage = " .. toPage)
  if toPage == ENUM_LobbyPageType.Left then
    self:SetSocialModelTick(true)
  end
end
function logic_social_lobby_performance:SetSocialModelTick(bTick)
  log(bWriteLog and "logic_social_lobby_performance:SetSocialModelTick bTick = " .. tostring(bTick) .. " self.lastSetTick = " .. tostring(self.lastSetTick))
  if self.lastSetTick == bTick then
    return
  end
  self.lastSetTick = bTick
  local TimeUtil, startTime
  if GMDebug then
    TimeUtil = require("client.common.time_util")
    startTime = TimeUtil.GetMicroseconds()
  end
  local CoupleAvatarSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CoupleAvatarSystem)
  local CoupleAvatar = CoupleAvatarSystem:GetCoupleAvatar(CoupleAvatarSystem.ESceneType.Social)
  if CoupleAvatar then
    local CoupleAvatarConfig = require("client.slua.logic.lobby.Left.CoupleAvatarConfig")
    local selfAvatar = CoupleAvatar:GetAvatar(CoupleAvatarConfig.AvatarType.Self)
    local performance_util = require("client.slua.logic.performance.performance_util")
    performance_util:SetAvatarTick(selfAvatar, bTick)
    local friendAvatar = CoupleAvatar:GetAvatar(CoupleAvatarConfig.AvatarType.Friend)
    performance_util:SetAvatarTick(friendAvatar, bTick)
  end
  if GMDebug then
    log(bWriteLog and string.format("logic_social_lobby_performance:SetSocialModelTick time:[%.3fms]", (TimeUtil.GetMicroseconds() - startTime) / 1000))
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_main_city_social_performance = class(CModuleBase, nil, logic_social_lobby_performance)
return Clogic_main_city_social_performance