local logic_maincity_performance = {}
local USkeletalMeshComponent = import("/Script/Engine.SkeletalMeshComponent")
function logic_maincity_performance:OnInitialize()
  log(bWriteLog and "logic_maincity_performance:OnInitialize")
  self.bTimeTest = true
  self.curTick = true
end
function logic_maincity_performance:OnDestroy()
  log(bWriteLog and "logic_maincity_performance:OnDestroy")
end
function logic_maincity_performance:RegistEvents()
  log(bWriteLog and "logic_maincity_performance:RegistEvents")
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_ENTER, self.OnEnterMainCity, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_RETURN_TO_LOBBY, self.OnLeaveMainCity, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAINCITY_PLAYER_CHARACTER_ADD_LOBBY, self.OnAddChar, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAINCITY_PLAYER_CHARACTER_REMOVE_LOBBY, self.OnRemoveChar, self)
end
function logic_maincity_performance:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_maincity_performance:OnPostSwitchGameStatus pre = " .. tostring(preState) .. " nextState = " .. tostring(nextState))
end
function logic_maincity_performance:OnEnterMainCity()
  log(bWriteLog and "logic_maincity_performance:OnEnterMainCity")
  self.curTick = true
  self:SetModelTick()
end
function logic_maincity_performance:OnLeaveMainCity()
  log(bWriteLog and "logic_maincity_performance:OnLeaveMainCity")
  self.curTick = false
  self:SetModelTick()
end
function logic_maincity_performance:OnAddChar()
  log(bWriteLog and "logic_maincity_performance:OnAddChar")
  self:SetModelTick()
end
function logic_maincity_performance:OnRemoveChar()
  log(bWriteLog and "logic_maincity_performance:OnRemoveChar")
  self:SetModelTick()
end
function logic_maincity_performance:SetModelTick()
  log(bWriteLog and "logic_maincity_performance:SetModelTick")
  local time_util = require("client.common.time_util")
  local startTime = 0
  if self.bTimeTest then
    startTime = time_util.GetMicroseconds()
  end
  self:SetFightCharTick()
  EventSystem:postEvent(EVENTTYPE_MAINCITY, EVENTID_MAINCITY_TICK_SWITCH, self.curTick)
  if self.bTimeTest then
    local endTime = time_util.GetMicroseconds()
    log(bWriteLog and "logic_maincity_performance:SetModelTick time = " .. (endTime - startTime) / 1000 .. "ms")
  end
end
function logic_maincity_performance:SetFightCharTick()
  log(bWriteLog and "logic_maincity_performance:SetFightCharTick")
  local performance_util = require("client.slua.logic.performance.performance_util")
  local MainCity_PlayerCharacter_Manager = require("GameLua.Mod.MainCity.Gameplay.Core.MainCity_PlayerCharacter_Manager")
  if MainCity_PlayerCharacter_Manager.playerCharacterMap then
    for k, playerChar in pairs(MainCity_PlayerCharacter_Manager.playerCharacterMap) do
      performance_util:SetActorTickRecursively(playerChar.Object, self.curTick)
      performance_util:SetComponentTickRecursivelyWithClass(playerChar.Mesh, USkeletalMeshComponent, self.curTick)
    end
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_maincity_performance)