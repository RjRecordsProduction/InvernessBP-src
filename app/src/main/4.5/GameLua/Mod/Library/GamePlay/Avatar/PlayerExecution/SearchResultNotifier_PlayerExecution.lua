local SearchResultNotifier_PlayerExecution = {}
local EExecutionCondition = import("EExecutionCondition")
function SearchResultNotifier_PlayerExecution:LuaNotifyRule(SearchOtherComp, bIsAvailable, SearchTag, ExecutionCondition, bHasDifference, FinalResultsAsObj)
  printf("SearchResultNotifier_PlayerExecution:LuaNotifyRule")
  if ExecutionCondition ~= EExecutionCondition.Client then
    return
  end
  if not slua.isValid(SearchOtherComp) then
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local OwnerPawn = SearchOtherComp:GetOwner()
  if not slua.isValid(OwnerPawn) then
    return
  end
  if uPlayerController:GetPlayerCharacterSafety() ~= OwnerPawn then
    return
  end
  local uRescueComp = OwnerPawn.RescueOtherComponent
  if not slua.isValid(uRescueComp) then
    return
  end
  local Results = FinalResultsAsObj
  local len = Results:Num()
  if bIsAvailable and 0 < len then
    for i = 0, len - 1 do
      local Result = Results:Get(i)
      if Game:IsBaseCharacter(Result) then
        local uSTExtraDelegateMgr = import("STExtraDelegateMgr")
        local DelegateMgrInstance = uSTExtraDelegateMgr.STExtraDelegateMgrInstance(CGameState)
        if DelegateMgrInstance and DelegateMgrInstance.OnCanExecuteOtherChange then
          uRescueComp.ExecuteWho = Result
          DelegateMgrInstance.OnCanExecuteOtherChange:BroadCast(Result, OwnerPawn, true)
        end
        break
      end
    end
  elseif not bIsAvailable and len == 0 then
    local uSTExtraDelegateMgr = import("STExtraDelegateMgr")
    local DelegateMgrInstance = uSTExtraDelegateMgr.STExtraDelegateMgrInstance(CGameState)
    if DelegateMgrInstance and DelegateMgrInstance.OnCanExecuteOtherChange then
      uRescueComp.ExecuteWho = nil
      DelegateMgrInstance.OnCanExecuteOtherChange:BroadCast(nil, OwnerPawn, false)
    end
  end
end
local object = require("object")
local class = require("class")
return class(object, nil, SearchResultNotifier_PlayerExecution)