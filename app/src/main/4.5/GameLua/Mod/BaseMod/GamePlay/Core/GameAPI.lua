local bUseNewEventSystem = require("client.common.event.EventProxy")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
Game = Game or {}
setmetatable(Game, {
  __index = function(t, k)
    local ret
    if CGame then
      ret = CGame[k]
    end
    if type(ret) == "function" then
      return function(self, ...)
        return ret(CGame, ...)
      end
    end
    return ret
  end
})
function Game:Wait(nTime)
  if bUseNewEventSystem then
    coroutine.yield(nTime)
  else
    coroutine.yield("wait", nTime)
  end
end
function Game:SetTimer(nTime, bLoop, fCallback)
  if not (nTime and CTimer) or not CTimer.SetTimer then
    return
  end
  return CTimer:SetTimer(nTime, bLoop, fCallback)
end
function Game:DelayExecFunc(nTime, fCallback)
  self:SetTimer(nTime, false, fCallback)
end
function Game:ClearTimer(nTimerID)
  if nTimerID == nil then
    log_error("Game:ClearTimer nTimerID is nil, need to be number!")
    return
  end
  if CTimer and CTimer.ClearTimer then
    CTimer:ClearTimer(nTimerID)
  else
    sandbox.LogError("Game:ClearTimer CTimer is nil")
  end
end
function Game:GetTimerRemaining(nTimerID)
  if nTimerID == nil then
    log_error("Game:ClearTimer nTimerID is nil, need to be number!")
    return
  end
  if CTimer then
    return CTimer:GetTimerRemaining(nTimerID)
  else
    sandbox.LogError("Game:GetTimerRemaining CTimer is nil")
  end
end
function Game:GetItemNumByResID(uPlayer, nResId)
  if not Game:IsValid(uPlayer) then
    return 0
  end
  local nNum = CGame:GetItemNumByResID(uPlayer, nResId)
  return nNum
end
function Game:GetItemNumByResIDFromController(uPlayerController, nResId)
  if not Game:IsValid(uPlayerController) then
    return 0
  end
  local nNum = CGame:GetItemNumByResIDFromController(uPlayerController, nResId)
  return nNum
end
function Game:HasBuff(nId, uTargetPawn)
  local isAdd = CGame:HasBuff(nId, uTargetPawn)
  return isAdd
end
function Game:GetRandomPosForTeleport(TargetPawn, MinRadius, MaxRadius, InMaxTryNum)
  CGame:GetRandomPosForTeleport(TargetPawn, MinRadius, MaxRadius, InMaxTryNum)
end
function Game:AttachToActor(ParentActor, ChildActor)
  CGame:AttachToActor(ParentActor, ChildActor)
end
function Game:GetAttachParentActor(uActor)
  local parentActor = CGame:GetAttachParentActor(uActor)
  return parentActor
end
function Game:GetPlayersOnVehicle(uVehicle)
  return CGame:GetPlayersOnVehicle(uVehicle)
end
function Game:GetAllPlayerPawns()
  return CGame:GetAllPlayerPawns()
end
function Game:GetAllPlayerDeadGhosts()
  local UGameplayStatics = import("GameplayStatics")
  local ActorClass = import("DeadGhostCharacter")
  local uActor = import("/Script/Engine.Actor")
  local ResultArray = UGameplayStatics.GetAllActorsOfClass(CGameState, ActorClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
  if ResultArray ~= nil then
    return ResultArray
  else
    print(bWriteLog and "Game:GetAllPlayerDeadGhosts, ResultArray = nil")
    return nil
  end
end
function Game:ConstructFVectorByLuaTable(LuaTable)
  return FVector(LuaTable.X, LuaTable.Y, LuaTable.Z)
end
function Game:GetAllPlayerStates()
  return CGame:GetAllPlayerStates()
end
function Game:GetAllPlayerAndFakePlayerAIStates(bOnlyFromLobby)
  return CGame:GetAllPlayerAndFakePlayerAIStates(bOnlyFromLobby)
end
function Game:GetAllVehicles()
  return CGame:GetAllVehicles()
end
function Game:PlayVideoInMatch(bPlay, VideoPath, BeforeEffect, DelayPlayTime, AfterEffect, DelayCloseTime)
  print(bWriteLog and "Game:PlayVideoInMatch, bPlay = " .. tostring(bPlay))
  local UI = UIManager.GetUI(UIManager.UI_Config_InGame.InMatchVideoPlayerUI)
  if UI ~= nil then
    UIManager.CloseUI(UIManager.UI_Config_InGame.InMatchVideoPlayerUI)
  end
  if bPlay then
    UIManager.ShowUI(UIManager.UI_Config_InGame.InMatchVideoPlayerUI, VideoPath, BeforeEffect, DelayPlayTime, AfterEffect, DelayCloseTime)
  end
end
function Game:UObjectToString(uobj)
  if not uobj then
    return "nil"
  end
  if not slua.isValid(uobj) then
    return "nil"
  end
  if uobj.GetPlayerNameSafety and uobj.GetPlayerKey and uobj:GetPlayerKey() ~= "0" then
    return string.format("<%s(%s)>", uobj:GetPlayerNameSafety(), uobj:GetPlayerKey())
  end
  return string.format("<%s>", tostring(uobj))
end
function Game:GetPlayerKey(uPlayer)
  if not uPlayer then
    return nil
  end
  if not slua.isValid(uPlayer) then
    return nil
  end
  local ToPlayer = CGame:CastToPlayer(uPlayer)
  if not Game:IsValid(ToPlayer) then
    local ToPlayerState = CGame:CastToPlayerState(uPlayer)
    if Game:IsValid(ToPlayerState) then
      return ToPlayerState:GetPlayerKey()
    else
      return nil
    end
  end
  local PlayerStr = ToPlayer:GetPlayerKey()
  if not PlayerStr then
    return nil
  end
  return tonumber(PlayerStr)
end
function Game:GetPlayerUID(uPlayer)
  if not uPlayer or not slua.isValid(uPlayer) then
    return nil
  end
  local ToPlayer = CGame:CastToPlayer(uPlayer)
  if not Game:IsValid(ToPlayer) then
    local ToPlayerState = CGame:CastToPlayerState(uPlayer)
    if Game:IsValid(ToPlayerState) then
      local str = ToPlayerState:GetUIDString()
      if str then
        return tonumber(str)
      else
        return nil
      end
    else
      return nil
    end
  end
  local PlayerStr = ToPlayer.PlayerUID
  if not PlayerStr then
    return nil
  end
  return tonumber(PlayerStr)
end
function Game:IsInArea(uPosition, nAreaId)
  return CGame:IsInArea(uPosition, nAreaId)
end
function Game:CastToPlayer(uActor)
  if not Game:IsValid(uActor) then
    return nil
  end
  return CGame:CastToPlayer(uActor)
end
function Game:CastToVehicle(uActor)
  if not uActor then
    return nil
  end
  if not slua.isValid(uActor) then
    return nil
  end
  return CGame:CastToVehicle(uActor)
end
function Game:GetActorResId(uActor)
  if not Game:IsValid(uActor) then
    return 0
  end
  return CGame:GetActorResId(uActor)
end
function Game:IsPlayerAlive(nPlayerKey)
  if nPlayerKey <= 0 then
    return false
  end
  return CGame:IsPlayerAlive(nPlayerKey)
end
function Game:IsAlive(uCharacter)
  if Game:IsValid(uCharacter) then
    return uCharacter:IsAlive()
  end
  return false
end
function Game:IsClassOf(uObject, uClass)
  if not slua.isValid(uObject) then
    return false
  end
  local GameLuaAPI = import("/Script/ShadowTrackerExtra.GameLuaAPI")
  return GameLuaAPI.IsClassOf(uObject, uClass)
end
function Game:IsChildOf(uClassA, uClassB)
  local GameLuaAPI = import("/Script/ShadowTrackerExtra.GameLuaAPI")
  return GameLuaAPI.IsChildOf(uClassA, uClassB)
end
function Game:IsHuman(uActor)
  if Game:IsValid(uActor) then
    local ASTExtraPlayerCharacter = import("STExtraPlayerCharacter")
    if Game:IsClassOf(uActor, ASTExtraPlayerCharacter) then
      return true
    end
  end
  return false
end
function Game:IsBaseCharacter(uActor)
  if Game:IsValid(uActor) then
    local STExtraBaseCharacter = import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")
    if Game:IsClassOf(uActor, STExtraBaseCharacter) then
      return true
    end
  end
  return false
end
function Game:IsMonster(uPawn)
  if Game:IsValid(uPawn) then
    local ASTExtraSimpleCharacter = import("STExtraSimpleCharacter")
    if Game:IsClassOf(uPawn, ASTExtraSimpleCharacter) then
      return true
    end
  end
  return false
end
function Game:IsDestructibleActor(uActor)
  if Game:IsValid(uActor) then
    local ADecoratorActor = import("DecoratorActor")
    if Game:IsClassOf(uActor, ADecoratorActor) then
      return true
    end
  end
  return false
end
function Game:GetMonsterName(MonsterID)
  local sMonsterName = ""
  local MonsterTableRow = CDataTable.GetTableData("MonsterTable", MonsterID)
  if MonsterTableRow then
    local MonsterNameID = MonsterTableRow.MonsterNameID
    if MonsterNameID and tonumber(MonsterNameID) then
      sMonsterName = LocUtil.GetLocalizeResStr(tonumber(MonsterNameID))
    elseif MonsterTableRow.MonsterName then
      sMonsterName = MonsterTableRow.MonsterName
    end
  end
  return sMonsterName
end
function Game:UISetWidgetVisibility(nPlayerKey, sWidget, nVisibility)
  local bToAll = false
  if nPlayerKey == -1 then
    bToAll = true
    nPlayerKey = 0
  end
  CGame:UISetWidgetVisibility(nPlayerKey, sWidget, nVisibility, bToAll)
end
function Game:UISetWidgetText(nPlayerKey, sWidget, sText, nTextId, tParam)
  local bToAll = false
  if nPlayerKey == -1 then
    bToAll = true
    nPlayerKey = 0
  end
  local ParamStr = ""
  if tParam ~= nil and type(tParam) == "table" and next(tParam) ~= nil then
    for key, value in ipairs(tParam) do
      if 0 < #ParamStr then
        ParamStr = ParamStr .. "|"
      end
      if type(value) == "number" then
        ParamStr = ParamStr .. "Str_" .. tostring(value)
      elseif type(value) == "string" then
        ParamStr = ParamStr .. "Str_" .. value
      elseif type(value) == "table" and next(value) ~= nil then
        for k, v in ipairs(value) do
          ParamStr = ParamStr .. "Tran_" .. tostring(v)
        end
      end
    end
  end
  if nTextId == nil then
    nTextId = 0
  end
  CGame:UISetWidgetText(nPlayerKey, sWidget, sText, nTextId, ParamStr, bToAll)
end
function Game:UIShowImageTips(nPlayerKey, nTipID, tParam1, tParam2)
  local bToAll = false
  if nPlayerKey == -1 then
    bToAll = true
    nPlayerKey = 0
  end
  CGame:UIShowTips("BattleGeneralTip", nPlayerKey, nTipID, tParam1 or "", tParam2 or "", bToAll)
end
function Game:UIShowTips(nPlayerKey, nTextID, tParam1, tParam2)
  local bToAll = false
  if nPlayerKey == -1 then
    bToAll = true
    nPlayerKey = 0
  end
  CGame:UIShowTips("BattleNormalTipsByTextID", nPlayerKey, nTextID, tParam1 or "", tParam2 or "", bToAll)
end
function Game:UIShowImageSAPTips(nPlayerKey, nTipID, tParam1, tParam2)
  local bToAll = false
  if nPlayerKey == -1 then
    bToAll = true
    nPlayerKey = 0
  end
  CGame:UIShowTips("BattleGeneralSAPTip", nPlayerKey, nTipID, tParam1 or "", tParam2 or "", bToAll)
end
function Game:GetOnePlayer()
  return CGame:GetOnePlayer()
end
function Game:GetOneRealPlayer()
  return CGame:GetOneRealPlayer()
end
function Game:GetOneRandomRealPlayer()
  return CGame:GetOneRandomRealPlayer()
end
function Game:ShowMessage(sMessage)
  CGame:ShowMessage(sMessage)
end
function Game:GetActorLocation(uActor)
  if Game:IsValid(uActor) then
    return uActor:K2_GetActorLocation()
  else
    print(bWriteLog and "GetActorLocation uActor is not valid ")
  end
  return FVector(0, 0, 0)
end
function Game:GetActorRotation(uActor)
  if Game:IsValid(uActor) then
    return uActor:K2_GetActorRotation()
  else
    print(bWriteLog and "GetActorRotation uActor is not valid ")
  end
  return FRotator(0, 0, 0)
end
function Game:GetActorScale(uActor)
  if Game:IsValid(uActor) then
    return uActor:GetActorScale3D()
  else
    print(bWriteLog and "GetActorRotation uActor is not valid ")
  end
  return FVector(1, 1, 1)
end
function Game:SetActorLocationAndRotation(uActor, uLocation, uRotation)
  if Game:IsValid(uActor) then
    uActor:K2_SetActorLocationAndRotation(uLocation, uRotation, false, nil, false)
  else
    print(bWriteLog and "SetActorLocationAndRotation uActor is not valid")
  end
end
function Game:IsValid(uObject)
  if uObject == nil then
    return false
  elseif type(uObject) == "table" then
    return true
  elseif type(uObject) == "userdata" then
    if slua.isValid(uObject) then
      if CGame and not CGame:IsValid(uObject) then
        sandbox.LogShippingDS(string.format("uObject is not CGame valid error"))
        return false
      end
      return true
    else
      return false
    end
  elseif type(uObject) == "boolean" then
    return uObject
  end
  return true
end
function Game:RandomFromTable(tTable, bPop)
  local ret
  if #tTable == 0 then
    ret = nil
  elseif #tTable == 1 then
    ret = tTable[1]
    if bPop then
      tTable[1] = nil
    end
  else
    local i = math.random(1, #tTable)
    ret = tTable[i]
    if bPop then
      table.remove(tTable, i)
    end
  end
  return ret
end
function Game:RandomMultiFromTable(tTable, nCount)
  if nCount >= #tTable then
    return Game:Shuffle(tTable)
  end
  local tTemp = {}
  for index, value in ipairs(tTable) do
    tTemp[index] = value
  end
  local tResult = {}
  for i = 1, nCount do
    local r = math.random(1, #tTemp)
    tResult[#tResult + 1] = tTemp[r]
    tTemp[r] = tTemp[#tTemp]
    tTemp[#tTemp] = nil
  end
  return tResult
end
function Game:RandomMultiFromTableWithCondition(tTable, nCount, Condition)
  Game:Shuffle(tTable)
  local tTemp = {}
  for index, value in ipairs(tTable) do
    tTemp[index] = value
  end
  local tResult = {}
  local nSucceedCount = 0
  local TotalCount = #tTable
  for i = 1, TotalCount do
    local r = math.random(1, #tTemp)
    if Condition(tTemp[r]) then
      tResult[#tResult + 1] = tTemp[r]
      tTemp[r] = tTemp[#tTemp]
      tTemp[#tTemp] = nil
      nSucceedCount = nSucceedCount + 1
    end
    if nSucceedCount == nCount then
      break
    end
  end
  return tResult
end
function Game:RandomByWeight(tTable, nCount, tResult)
  local tResult = tResult or {}
  local nTableLen = 0
  for key, value in pairs(tTable) do
    nTableLen = nTableLen + 1
  end
  if nCount <= 0 then
    return {}
  elseif nCount >= nTableLen then
    for key, value in pairs(tTable) do
      tResult[#tResult + 1] = key
    end
    return tResult
  elseif nCount == 1 then
    local nSum = 0
    for key, nWeight in pairs(tTable) do
      nSum = nSum + nWeight
    end
    local nRandomSum = math.random() * nSum
    for key, nWeight in pairs(tTable) do
      if nWeight > nRandomSum then
        tResult[#tResult + 1] = key
        return tResult
      else
        nRandomSum = nRandomSum - nWeight
      end
    end
  else
    local nSum = 0
    local tTableCopy = {}
    for key, nWeight in pairs(tTable) do
      nSum = nSum + nWeight
      tTableCopy[key] = nWeight
    end
    local nRandomSum = math.random() * nSum
    for key, nWeight in pairs(tTable) do
      if nWeight > nRandomSum then
        tResult[#tResult + 1] = key
        tTableCopy[key] = nil
        return Game:RandomByWeight(tTableCopy, nCount - 1, tResult)
      else
        nRandomSum = nRandomSum - nWeight
      end
    end
  end
end
function Game:GetTeamID(uActor)
  if Game:IsValid(uActor) and uActor.GetTeamId then
    return uActor:GetTeamId()
  end
  return 0
end
function Game:GetCampID(uActor)
  if Game:IsValid(uActor) and uActor.GetCampId then
    return uActor:GetCampId()
  end
  return 0
end
function Game:GetTeamOrCampID(uActor)
  local CampSubsystem = SubsystemMgr:Get("CampSubsystem")
  if CampSubsystem and CampSubsystem.IsEnabled then
    return Game:GetCampID(uActor)
  else
    return Game:GetTeamID(uActor)
  end
end
function Game:IsEnemy(PawnA, PawnB)
  if not Game:IsValid(PawnA) or not Game:IsValid(PawnB) then
    return false
  end
  local CampSubsystem = SubsystemMgr:Get("CampSubsystem")
  if CampSubsystem and CampSubsystem.IsEnabled then
    if PawnA.CampID == 0 and PawnB.CampID == 0 then
      return Game:GetTeamID(PawnA) ~= Game:GetTeamID(PawnB)
    else
      return PawnA.CampID ~= PawnB.CampID
    end
  else
    return Game:GetTeamID(PawnA) ~= Game:GetTeamID(PawnB)
  end
end
function Game:GetDecratorActors(ResID, uRegion)
  if not uRegion or not ResID then
    return nil
  end
  local DecratorActors = CGame:GetDecratorActors(ResID, uRegion)
  return DecratorActors
end
function Game:CreateAreaSphere(uPosition, Radius)
  if not uPosition or not Radius then
    return nil
  end
  return CGame:CreateAreaSphere(uPosition, Radius)
end
function Game:CreateAreaVolume(uPosition, uRotation, uVolume)
  if not (uPosition and uRotation) or not uVolume then
    return nil
  end
  return CGame:CreateAreaVolume(uPosition, uRotation, uVolume)
end
function Game:GetComponentLocation(uComponent)
  if Game:IsValid(uComponent) and uComponent.K2_GetComponentLocation then
    return uComponent:K2_GetComponentLocation()
  end
end
function Game:GetComponentRotation(uComponent)
  if Game:IsValid(uComponent) and uComponent.K2_GetComponentRotation then
    return uComponent:K2_GetComponentRotation()
  end
end
function Game:FindFakePlayer()
  return CGame:FindFakePlayer()
end
function Game:IsPlayer(uActor)
  local APlayerController = import("/Script/Engine.PlayerController")
  if Game:IsHuman(uActor) and Game:IsValid(uActor.GetPlayerControllerSafety) then
    local uPlayerController = uActor:GetPlayerControllerSafety()
    if Game:IsValid(uPlayerController) and not uPlayerController.UseBlackboard then
      return true
    end
  end
  return false
end
function Game:IsAI(uActor)
  if not slua.isValid(uActor) then
    return false
  end
  if uActor.GetEnsure and uActor:GetEnsure() then
    return true
  end
  return false
end
function Game:IsAIPlayer(uActor)
  if not slua.isValid(uActor) then
    return false
  end
  local EFakePlayerBornType = import("/Script/ShadowTrackerExtra.EFakePlayerBornType")
  if uActor.GetEnsure and uActor:GetEnsure() and uActor.GetControllerSafety then
    local uAIController = uActor:GetControllerSafety()
    if slua.isValid(uAIController) and uAIController.FakePlayerBornType and uAIController.FakePlayerBornType == EFakePlayerBornType.FromLobby then
      return true
    end
  end
  return false
end
function Game:IsMLAIPlayer(uActor)
  if not slua.isValid(uActor) then
    return false
  end
  if uActor.IsMLAIPlayerParam and uActor:IsMLAIPlayerParam() then
    return true
  end
  return false
end
function Game:IsAIController(uController)
  local AAIController = import("/Script/AIModule.AIController")
  if Game:IsValid(uController) and Game:IsClassOf(uController, AAIController) then
    return true
  end
  return false
end
function Game:SetAIParaIDWithController(uController, nParaID)
  if Game:IsValid(uController) and Game:IsValid(uController.InitAIFeatureInfo) then
    uController:InitAIFeatureInfo(nParaID)
  end
end
function Game:SetAIParaID(uPawn, nParaID)
  if Game:IsValid(uPawn) and Game:IsValid(uPawn.GetController) then
    Game:SetAIParaIDWithController(uPawn:GetController(), nParaID)
  end
end
function Game:SetAISingleParaWithController(uController, sParaName, Value)
  if Game:IsValid(uController) and uController.AIFeatureInfo and sParaName and Value then
    print(bWriteLog and string.format("[AI] Game:SetAISinglePara Before %s HP:%s DropID:%s %s:%s", tostring(uController.AIFeatureInfo), tostring(uController.AIFeatureInfo.HP), tostring(uController.AIFeatureInfo.DropID), sParaName, tostring(uController.AIFeatureInfo[sParaName])))
    uController.AIFeatureInfo[sParaName] = Value
    print(bWriteLog and string.format("[AI] Game:SetAISinglePara After %s HP:%s DropID:%s %s:%s", tostring(uController.AIFeatureInfo), tostring(uController.AIFeatureInfo.HP), tostring(uController.AIFeatureInfo.DropID), sParaName, tostring(uController.AIFeatureInfo[sParaName])))
  end
end
function Game:SetAISinglePara(uPawn, sParaName, Value)
  print(bWriteLog and "Game:SetAISinglePara: ", uPawn, sParaName, Value)
  if Game:IsValid(uPawn) and Game:IsValid(uPawn.GetController) and sParaName and Value then
    Game:SetAISingleParaWithController(uPawn:GetController(), sParaName, Value)
  end
end
function Game:GetEquipWeaponList(uPawn)
  if not Game:IsValid(uPawn) then
    return nil
  end
  return CGame:GetEquipWeaponList(uPawn)
end
function Game:GetCurrentUseWeapon(uPawn)
  if not Game:IsValid(uPawn) then
    return nil
  end
  return CGame:GetCurrentUseWeapon(uPawn)
end
function Game:GetWeaponBulletResId(uWeapon)
  if not Game:IsValid(uWeapon) then
    return nil
  end
  return CGame:GetWeaponBulletResId(uWeapon)
end
function Game:SplitString(str, splitChar)
  local sub_str_tab = {}
  while true do
    local pos = string.find(str, splitChar)
    if not pos then
      local size_t = #sub_str_tab
      table.insert(sub_str_tab, size_t + 1, str)
      break
    end
    local sub_str = string.sub(str, 1, pos - 1)
    local size_t = #sub_str_tab
    table.insert(sub_str_tab, size_t + 1, sub_str)
    local t = string.len(str)
    str = string.sub(str, pos + 1, t)
  end
  return sub_str_tab
end
function Game:CallWaitFunction(Func, ...)
  if not Func then
    return
  end
  local co = coroutine.create(function(...)
    Func(...)
  end)
  if bUseNewEventSystem then
    local bWait, nWaitTime = coroutine.resume(co, ...)
    if bWait and nWaitTime then
      Game:WaitCo(co, nWaitTime)
    elseif not bWait then
      local utility = require("common.utility")
      utility.ErrorMessageHandler(nWaitTime)
    end
    return
  end
  local bWait, sWaitTag, nWaitTime = coroutine.resume(co, ...)
  if bWait and sWaitTag == "wait" then
    Game:WaitCo(co, nWaitTime)
  elseif not bWait then
    local utility = require("common.utility")
    utility.ErrorMessageHandler(sWaitTag)
  end
end
function Game:IsTargetPosVisible(vPosSource, vPosTarget, tIgnoreActors)
  local uIgnoreActors = tIgnoreActors
  local CActor = import("/Script/Engine.Actor")
  if not tIgnoreActors then
    uIgnoreActors = slua.Array(UEnums.EPropertyClass.Object, CActor)
  elseif type(tIgnoreActors) == "table" then
    uIgnoreActors = slua.Array(UEnums.EPropertyClass.Object, CActor)
    for key, value in pairs(tIgnoreActors) do
      uIgnoreActors:Add(value)
    end
  end
  return CGame:IsTargetPosVisible(vPosSource, vPosTarget, uIgnoreActors)
end
function Game:IsLineTraceHitActor(vStart, vEnd, uActor)
  return CGame:IsLineTraceHitActor(vStart, vEnd, uActor)
end
function Game:IsLineTraceHitComponent(vStart, vEnd, uComponent)
  return CGame:IsLineTraceHitComponent(vStart, vEnd, uComponent)
end
function Game:GetPlayerVehicle(uPlayer)
  if Game:IsValid(uPlayer) then
    local uVechile = uPlayer:GetCurrentVehicle()
    if Game:IsValid(uVechile) then
      return uVechile
    end
  end
end
function Game:GetVehicleType(uVehicle)
  if Game:IsValid(uVehicle) then
    return uVehicle.VehicleType
  end
end
function Game:IsVehicle(uActor)
  if Game:IsValid(uActor) then
    return CGame:IsVehicle(uActor)
  end
  return false
end
function Game:IsBioVehicle(uActor)
  return Game:IsClassOf(uActor, import("BioVehicleBase"))
end
function Game:IsDriver(uPlayer)
  if Game:IsValid(uPlayer) then
    local USTExtraVehicleUtils = import("STExtraVehicleUtils")
    return USTExtraVehicleUtils.IsDriver(uPlayer)
  end
  return false
end
function Game:QueryMobCharacters(uCenter, nRange)
  return CGame:QueryMobCharacters(uCenter, nRange)
end
function Game:IsMobCharacterAround(uCenter, nRange)
  return CGame:IsMobCharacterAround(uCenter, nRange)
end
function Game:QueryCharacters(uCenter, nRange)
  return CGame:QueryCharacters(uCenter, nRange)
end
function Game:QueryRingCharacters(uCenter, nRangeMin, nRangeMax)
  return CGame:QueryRingCharacters(uCenter, nRangeMin, nRangeMax)
end
function Game:QueryRingMobCharacters(uCenter, nRangeMin, nRangeMax)
  return CGame:QueryRingMobCharacters(uCenter, nRangeMin, nRangeMax)
end
function Game:QueryPickUpWrappers(uCenter, nRange, ItemIDs, bDebug, MaxNeedNum)
  return CGame:QueryPickUpWrappers(uCenter, nRange, ItemIDs, bDebug, MaxNeedNum)
end
function Game:QueryPickUpWrappersByItemTypes(uCenter, nRange, ItemTypes, bDebug, MaxNeedNum)
  return CGame:QueryPickUpWrappersByItemTypes(uCenter, nRange, ItemTypes, bDebug, MaxNeedNum)
end
function Game:QueryUsefulPickUpWrappers(uCenter, nRange, ItemIDs, bDebug, uCharacter, MaxNeedNum)
  return CGame:QueryUsefulPickUpWrappers(uCenter, nRange, ItemIDs, bDebug, uCharacter, MaxNeedNum)
end
function Game:QueryGrenades(uCenter, nRange)
  return CGame:QueryGrenades(uCenter, nRange)
end
function Game:QueryDeathBoxs(uCenter, nRange)
  return CGame:QueryDeathBoxs(uCenter, nRange)
end
function Game:QueryAirDropBoxs(uCenter, nRange)
  return CGame:QueryAirDropBoxs(uCenter, nRange)
end
function Game:QueryDoors(uCenter, nRange)
  return CGame:QueryDoors(uCenter, nRange)
end
function Game:QueryVehicles(uCenter, nRange)
  return CGame:QueryVehicles(uCenter, nRange)
end
function Game:AddTreasureChestToCell(uInTreasureChest, nInType)
  if uInTreasureChest and Game:IsValid(uInTreasureChest) then
    CGame:AddTreasureChestToCell(uInTreasureChest, nInType)
  end
end
function Game:RemoveTreasureChestToCell(uInTreasureChest)
  if not Client and uInTreasureChest and Game:IsValid(uInTreasureChest) then
    CGame:RemoveTreasureChestToCell(uInTreasureChest)
  end
end
function Game:QueryCanBeScannedActors(uCenter, nRange, ScannedActorTag, MarkNum, MaxNum)
  return CGame:QueryCanBeScannedActors(uCenter, nRange, ScannedActorTag, MarkNum, MaxNum)
end
function Game:Shuffle(tTable)
  local tShuffled = {}
  for i, v in ipairs(tTable) do
    local pos = math.random(1, #tShuffled + 1)
    table.insert(tShuffled, pos, v)
  end
  return tShuffled
end
function Game:ArrayToTable(uArray)
  local tResult = {}
  for _, value in pairs(uArray) do
    table.insert(tResult, value)
  end
  return tResult
end
function Game:AddComponent(uClass, uActor, sName)
  if not uActor or not uClass then
    return nil
  end
  local uComponent = uClass(uActor, sName)
  if Game:IsValid(uComponent) then
    CGame:RegisterComponent(uComponent)
    return uComponent
  end
end
function Game:IsTable(tTable)
  local tResult = {}
  if type(tTable) ~= "table" then
    tTable = {}
  end
  tResult = tTable
  return tResult
end
function Game:TableNum(tTable)
  local count = 0
  local t = Game:IsTable(tTable)
  for k, v in pairs(t) do
    count = count + 1
  end
  return count
end
function Game:WaitCo(Co, WaitTime)
  if bUseNewEventSystem then
    if WaitTime <= 0 then
      local bSuccess, NewWaitTime = coroutine.resume(Co)
      if bSuccess then
        Game:WaitCo(Co, NewWaitTime)
      elseif NewWaitTime then
        local utility = require("common.utility")
        utility.ErrorMessageHandler(NewWaitTime)
      end
    end
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimer(WaitTime, function()
      local bSuccess, NewWaitTime = coroutine.resume(Co)
      if bSuccess and NewWaitTime then
        Game:WaitCo(Co, NewWaitTime)
      elseif NewWaitTime then
        local utility = require("common.utility")
        utility.ErrorMessageHandler(NewWaitTime)
      end
    end)
    return
  end
  if WaitTime <= 0 then
    local bSuccess, WaitTag, NewWaitTime = coroutine.resume(Co)
    if bSuccess and WaitTag == "wait" then
      Game:WaitCo(Co, NewWaitTime)
    elseif WaitTag and 0 < #WaitTag then
      local utility = require("common.utility")
      utility.ErrorMessageHandler(WaitTag)
    end
  end
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimer(WaitTime, function()
    local bSuccess, WaitTag, NewWaitTime = coroutine.resume(Co)
    if bSuccess and WaitTag == "wait" then
      Game:WaitCo(Co, NewWaitTime)
    elseif WaitTag and 0 < #WaitTag then
      local utility = require("common.utility")
      utility.ErrorMessageHandler(WaitTag)
    end
  end)
end
function Game:GetActorsByClass(uClass)
  if not uClass then
    return
  end
  return CGame:GetActorsByClass(uClass)
end
function Game:GetOneActorByClass(uClass)
  if not uClass then
    return
  end
  local Actors = CGame:GetActorsByClass(uClass)
  if slua.isValid(Actors) and Actors:Num() > 0 then
    return Actors:Get(0)
  end
  return
end
function Game:GetAllChildActors(uActor, bIncludeDescendants)
  if not Game:IsValid(uActor) then
    return nil
  end
  return CGame:GetAllChildActors(uActor, bIncludeDescendants)
end
function Game:ProjectPointToNavigation(uPoint, uOutProjectedLocation, uQueryExtent)
  uQueryExtent = uQueryExtent or FVector(50.0, 50.0, 100.0)
  return CGame:ProjectPointToNavigation(uPoint, uOutProjectedLocation, uQueryExtent)
end
function Game:GetPlayerMark3D(uPlayer)
  if not Game:IsValid(uPlayer) then
    return
  end
  local uPS = uPlayer:GetPlayerStateSafety()
  if not Game:IsValid(uPS) then
    return
  end
  if uPS.MapMark.Z == 0 then
    return
  end
  local USTExtraMapFunctionLibrary = import("STExtraMapFunctionLibrary")
  local nBounds = USTExtraMapFunctionLibrary.GetLevelLandscapeBounds(uPlayer)
  local vMidPoint2D = USTExtraMapFunctionLibrary.GetLandscapeMidPoint(uPlayer)
  local vLevelOrigin2D = vMidPoint2D
  local vMapMark2D = FVector2D(uPS.MapMark.X, uPS.MapMark.Y)
  local vWorld2D = vLevelOrigin2D + vMapMark2D * nBounds
  local KismetSystemLibrary = import("KismetSystemLibrary")
  local Actor_C = import("/Script/Engine.Actor")
  local uHitResult = import("/Script/Engine.HitResult")()
  local bHit, uHitResult = KismetSystemLibrary.LineTraceSingle(CGameWorld, FVector(vWorld2D.X, vWorld2D.Y, 999999), FVector(vWorld2D.X, vWorld2D.Y, -999999), 0, true, slua.Array(UEnums.EPropertyClass.Object, Actor_C), 0, uHitResult, true, FLinearColor.Red, FLinearColor.Green, 5)
  local vWorld = FVector(vWorld2D.X, vWorld2D.Y, 0)
  if bHit then
    vWorld.Z = uHitResult.ImpactPoint.Z
  end
  return vWorld
end
function Game:GetDistanceEnemies(uPlayer, nDistance)
  if not Game:IsValid(uPlayer) then
    return nil
  end
  return CGame:GetDistanceEnemies(uPlayer, nDistance)
end
function Game:GetGroundLocation(uPosition, nTraceLength)
  return CGame:GetGroundLocation(uPosition, -math.abs(nTraceLength))
end
function Game:GetActorsInSphere(uCenter, nRadius, uClass)
  return CGame:GetActorsInSphere(uCenter, nRadius, uClass)
end
function Game:GetPlainName(uObject)
  if CGame and Game:IsValid(uObject) then
    return CGame:GetPlainName(uObject)
  end
end
function Game:GetObjName(uObject)
  if not Game:IsValid(uObject) then
    return "none"
  end
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local sObjectName = UKismetSystemLibrary.GetObjectName(uObject)
  if uObject.GetPlayerNameSafety and uObject.GetPlayerKey and uObject:GetPlayerKey() ~= "0" then
    return string.format("%s N:%s(%s)", sObjectName, uObject:GetPlayerNameSafety(), uObject:GetPlayerKey())
  end
  return sObjectName
end
function Game:FindRealActorByActorNameAndLandId(sActorName, nLandId)
  if sActorName ~= nil then
    if nLandId ~= nil and GlobalDynamicActors ~= nil then
      for LevelName, LevelDynamicActors in pairs(GlobalDynamicActors) do
        if LevelDynamicActors and LevelDynamicActors[sActorName] then
          if string.find(LevelName, "_Copy_" .. tostring(nLandId - 1)) then
            return LevelDynamicActors[sActorName]
          elseif nLandId == 1 and not string.find(LevelName, "_Copy_") then
            return LevelDynamicActors[sActorName]
          end
        end
      end
    else
      return LevelActors[sActorName]
    end
  end
  return nil
end
function Game:StartAirdrop(uBoxClass, nDropID, uDropLocation, nFallingSpeed, nBoxID, nRotYaw, bUseGiftBoxType)
  uBoxClass = uBoxClass or slua.loadClass("/Game/BluePrints/Airborne/BP_AirDropBox_New.BP_AirDropBox_New")
  local UGameplayStatics = import("GameplayStatics")
  local UKismetMathLibrary = import("KismetMathLibrary")
  nRotYaw = nRotYaw or 0
  bUseGiftBoxType = bUseGiftBoxType or false
  local uTransform = UKismetMathLibrary.MakeTransform(uDropLocation, FRotator(0, nRotYaw, 0), FVector(1, 1, 1))
  local ESpawnActorCollisionHandlingMethod = import("ESpawnActorCollisionHandlingMethod")
  nBoxID = nBoxID or 100
  local uBox = UGameplayStatics.BeginDeferredActorSpawnFromClass(CGameWorld, uBoxClass, uTransform, ESpawnActorCollisionHandlingMethod.Undefined, nil)
  if Game:IsValid(uBox) then
    uBox.DroppingSpeed = nFallingSpeed
    uBox.bIsEmptyAirdrop = true
    uBox.DropId = nDropID
    uBox.AirDropBoxId = nBoxID
    uBox.    UGameplayStatics.FinishSpawningActor(uBox, uTransform)
    if 0 < nDropID then
      uBox:GenerateWrappersBoxByDropID(nDropID, false)
    end
  end
  return uBox
end
function Game:StartAirdropWithPlane(uBoxClass, nDropID, uDropLocation, nFallingSpeed, uPlaneClass, nDirection, nDropDelay, nFlyingSpeed, nSummonerKey)
  local FAirDropOrder = import("AirDropOrder")
  local AirDropOrder = FAirDropOrder()
  local nHeight = uDropLocation.Z
  AirDropOrder.BoxFallingPositionArray = {uDropLocation}
  AirDropOrder.AirDropStuffFallingSpeed = nFallingSpeed
  AirDropOrder.bIsEmptyAirdrop = true
  AirDropOrder.DropID = nDropID
  AirDropOrder.AirDropSummoner = nSummonerKey
  uBoxClass = uBoxClass or slua.loadClass("/Game/BluePrints/Airborne/BP_AirDropBox_New.BP_AirDropBox_New")
  AirDropOrder.AirdropBoxClass = uBoxClass
  uPlaneClass = uPlaneClass or slua.loadClass("/Game/BluePrints/Airborne/BP_AirDropPlane.BP_AirDropPlane")
  local UDropBoxStrategy = import("DropBoxStrategy")
  local nRad = math.rad(nDirection)
  local uForward = FVector(math.cos(nRad), math.sin(nRad), 0)
  local nDist = nDropDelay * nFlyingSpeed
  local uSpawnLocation = uDropLocation - uForward * nDist
  local uTransform = FTransform()
  uTransform:SetLocation(uSpawnLocation)
  local ESpawnActorCollisionHandlingMethod = import("ESpawnActorCollisionHandlingMethod")
  local UGameplayStatics = import("GameplayStatics")
  local uPlane = UGameplayStatics.BeginDeferredActorSpawnFromClass(CGameWorld, uPlaneClass, uTransform, ESpawnActorCollisionHandlingMethod.Undefined, nil)
  if Game:IsValid(uPlane) then
    uPlane:SetOrder(AirDropOrder)
    local FlyingParam = uPlane.FlyingParam
    FlyingParam.FlyingDirection = uForward
    FlyingParam.FlyingSpeed = nFlyingSpeed
    uPlane:SetFlyingParam(FlyingParam)
    uPlane:SetDropStrategy(UDropBoxStrategy())
  end
  UGameplayStatics.FinishSpawningActor(uPlane, uTransform)
  uPlane:K2_SetActorRotation(FRotator(0, nDirection, 0), false)
end
function Game:StartVehicleAirdropWithPlane(uDropLocation, uDropRotation, nDirection, nDropDelay, nFlyingSpeed, uVehicleClassPath, FuelPercent, uPlaneClass, nSummonerKey, HandleFunc)
  local nRad = math.rad(nDirection)
  local uForward = FVector(math.cos(nRad), math.sin(nRad), 0)
  local nDist = nDropDelay * nFlyingSpeed
  local uSpawnLocation = uDropLocation - uForward * nDist
  local uTransform = FTransform()
  uTransform:SetLocation(uSpawnLocation)
  local ESpawnActorCollisionHandlingMethod = import("ESpawnActorCollisionHandlingMethod")
  uPlaneClass = uPlaneClass or slua.loadClass("/Game/BluePrints/Airborne/BP_AirDropPlane.BP_AirDropPlane")
  local UGameplayStatics = import("GameplayStatics")
  local uPlane = UGameplayStatics.BeginDeferredActorSpawnFromClass(CGameWorld, uPlaneClass, uTransform, ESpawnActorCollisionHandlingMethod.Undefined, nil)
  if Game:IsValid(uPlane) then
    local FlyingParam = uPlane.FlyingParam
    FlyingParam.FlyingDirection = uForward
    FlyingParam.FlyingSpeed = nFlyingSpeed
    uPlane:SetFlyingParam(FlyingParam)
  end
  UGameplayStatics.FinishSpawningActor(uPlane, uTransform)
  uPlane:K2_SetActorRotation(FRotator(0, nDirection, 0), false)
  Game:SetTimer(nDropDelay, false, function()
    local VehicleGenerateRandomInfo = import("VehicleGenerateRandomInfo")
    local STExtraVehicleUtils = import("STExtraVehicleUtils")
    local RandomInfo = VehicleGenerateRandomInfo()
    RandomInfo.VehiclePath = uVehicleClassPath
    RandomInfo.    RandomInfo.SnapFloor = true
    RandomInfo.bActiveByStartVolume = false
    local uVehicle = STExtraVehicleUtils.AirDropVehicleWithRotation(CGameWorld, uDropLocation, uDropRotation, RandomInfo)
    if HandleFunc then
      HandleFunc(uVehicle, nSummonerKey)
    end
  end)
end
function Game:SetCustomFlight(uStartLoc, uTargetLoc, nCanJumpTime, nForceJumpTime, nPlaneSpeed, nPlaneHeight)
  if not nPlaneSpeed then
    local uPlaneRouteData = CGameMode:GetCurPlaneRouteData()
    nPlaneSpeed = uPlaneRouteData.PlaneSpeed
  end
  if not nPlaneHeight then
    local uPlaneRouteData = CGameMode:GetCurPlaneRouteData()
    nPlaneHeight = uPlaneRouteData.PlaneHeight
  end
  uStartLoc.Z = nPlaneHeight
  uTargetLoc.Z = nPlaneHeight
  local uDirection = uTargetLoc - uStartLoc
  uDirection:Normalize(1.0E-8)
  local uCanJumpLoc = uStartLoc + uDirection * nPlaneSpeed * nCanJumpTime
  local uCanJumpLoc2D = FVector2D(uCanJumpLoc.X, uCanJumpLoc.Y)
  local uForceJumpLoc = uStartLoc + uDirection * nPlaneSpeed * nForceJumpTime
  local uForceJumpLoc2D = FVector2D(uForceJumpLoc.X, uForceJumpLoc.Y)
  local uPlaneComponent = CGameMode.PlaneComp
  if Game:IsValid(uPlaneComponent) then
    return uPlaneComponent:SetCustomFlight(uStartLoc, uTargetLoc, uCanJumpLoc2D, uForceJumpLoc2D, nPlaneSpeed, nPlaneHeight)
  end
end
function Game:AddPlayerToFlight(uPlayerController, nFlightNo)
  local uPlaneComponent = CGameMode.PlaneComp
  if Game:IsValid(uPlaneComponent) then
    uPlaneComponent:AddPlayerToFlight(uPlayerController, nFlightNo)
  end
end
function Game:StartFlight(nFlightNo)
  local uPlaneComponent = CGameMode.PlaneComp
  if Game:IsValid(uPlaneComponent) then
    uPlaneComponent:StartFlight(nFlightNo)
  end
end
function Game:GetCurrentModPath()
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModName = GameMainConfig.GetModType()
  if ModName == nil or ModName == "" or ModName == "Default" then
    ModName = "BaseMod"
  end
  local ModPath = "GameLua.Mod." .. ModName
  return ModPath
end
function Game:GetActorDistance(uFromActor, uToActor)
  return CGame:GetActorDistance(uFromActor, uToActor)
end
function Game:GetActorDistance2D(uFromActor, uToActor)
  return CGame:GetActorDistance2D(uFromActor, uToActor)
end
function Game:GetPlayerRealSpeed(uPlayer)
  return CGame:GetPlayerRealSpeed(uPlayer)
end
function Game:GetActorUniqueID(uActor)
  if not Game:IsValid(uActor) then
    return nil
  end
  return CGame:GetActorUniqueID(uActor)
end
function Game:GetCurTimeMilliseconds()
  return CGame:GetCurTimeMilliseconds()
end
function Game:ConvertToTraceType(CollisionChannel)
  return CGame:ConvertToTraceType(CollisionChannel)
end
function Game:GetVector2DDistance(FromPos, ToPos)
  return CGame:GetVector2DDistance(FromPos, ToPos)
end
function Game:GetVector2DDistSquared(FromPos, ToPos)
  return CGame:GetVector2DDistSquared(FromPos, ToPos)
end
function Game:OutsideWorldBounds(uPlayerCharacter)
  if Game:IsValid(uPlayerCharacter) then
    CGame:OutsideWorldBounds(uPlayerCharacter)
  end
end
function Game:ShakeCamera(worldContext, path, scale, time, interval)
  print(bWriteLog and "Game:ShakeCamera, scale = " .. tostring(scale) .. ", time = " .. tostring(time) .. ", interval = " .. tostring(interval) .. ", path = " .. tostring(path))
  local ShakeScreen = slua.loadClass(path)
  if ShakeScreen then
    scale = tonumber(scale) or 15
    time = tonumber(time) or 5
    interval = tonumber(interval) or 0.5
    if 0 < scale and 0 < time and 0 < interval then
      local time_ticker = require("common.time_ticker")
      time_ticker.AddTimer(0, function()
        Game:ShakeCameraImpl(worldContext, ShakeScreen, scale, time, interval)
      end)
    end
  end
end
function Game:ShakeCameraImpl(worldContext, ShakeScreen, scale, time, interaval)
  local UGameplayStatics = import("GameplayStatics")
  local ENetRole = import("ENetRole")
  local character = UGameplayStatics.GetPlayerCharacter(worldContext, 0)
  if character and slua.isValid(character) and character.Role == ENetRole.ROLE_AutonomousProxy then
    local uPlayerController = character:GetController()
    if uPlayerController then
      if uPlayerController.PlayerCameraManager and slua.isValid(uPlayerController.PlayerCameraManager) then
        local ECameraAnimPlaySpace = import("ECameraAnimPlaySpace")
        while true do
          uPlayerController.PlayerCameraManager:PlayCameraShake(ShakeScreen, scale, ECameraAnimPlaySpace.CameraLocal, FRotator(0, 0, 0))
          time = time - interaval
          if time <= 0 then
            return
          else
            coroutine.yield(interaval)
          end
        end
      else
        print(bWriteLog and "Game:ShakeCameraImpl, failed because PlayerCameraManager is nil")
      end
    else
      print(bWriteLog and "Game:ShakeCameraImpl, failed because uPlayerController is nil")
    end
  else
    print(bWriteLog and "Game:ShakeCameraImpl, failed because character is not AutonomousProxy")
  end
end
function Game:EnablePlayerInput(character, enable)
  print(bWriteLog and "Game:EnablePlayerInput, character = " .. tostring(character) .. ", enable = " .. tostring(enable))
  local playerController = character:GetPlayerControllerSafety()
  if playerController then
    local ob = playerController:IsSpectator() or playerController:IsInPetSpectator()
    if enable == false then
      if not ob then
        playerController:SetIgnoreLookInput(true)
        playerController:SetIgnoreMoveInput(true)
        if character.EnableStanbyAnim then
          character:EnableStanbyAnim(false)
        end
      end
      local UIUtil = require("client.common.ui_util")
      local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
      local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
      if MainControlPanelTochButton then
        MainControlPanelTochButton:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        local PhoneStateUI = UIManager.GetUI(UIManager.UI_Config_InGame.PhoneStateUI)
        if PhoneStateUI then
          PhoneStateUI:Collapsed()
        end
        if not ob then
          playerController:SetAlwaysHideTouchInterface(true)
        else
          local watchGame = UIUtil.GetWidgetByName("watchgame", "WatchGame_UIBP")
          if watchGame then
            watchGame:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
          end
          local observeUI = UIUtil.GetWidgetByName("observe", "OBUI_UIBP")
          if observeUI then
            observeUI:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
          end
        end
      end
    else
      if not ob then
        playerController:ResetIgnoreMoveInput()
        playerController:ResetIgnoreLookInput()
        if character.EnableStanbyAnim then
          character:EnableStanbyAnim(true)
        end
      end
      local UIUtil = require("client.common.ui_util")
      local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
      local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
      if MainControlPanelTochButton then
        MainControlPanelTochButton:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        local PhoneStateUI = UIManager.GetUI(UIManager.UI_Config_InGame.PhoneStateUI)
        if PhoneStateUI then
          PhoneStateUI:SelfHitTestInvisible()
        end
        if not ob then
          playerController:SetAlwaysHideTouchInterface(false)
        else
          local watchGame = UIUtil.GetWidgetByName("watchgame", "WatchGame_UIBP")
          if watchGame then
            watchGame:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
          end
          local observeUI = UIUtil.GetWidgetByName("observe", "OBUI_UIBP")
          if observeUI then
            observeUI:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
          end
        end
      end
    end
  else
    print(bWriteLog and "Game:EnablePlayerInput, playerController = nil")
  end
end
function Game:RotatorToQuat(uRotator)
  local GameLuaAPI = import("/Script/ShadowTrackerExtra.GameLuaAPI")
  return GameLuaAPI.RotatorToQuat(uRotator)
end
function Game:TransFormSetRotator(trans, uRotator)
  local GameLuaAPI = import("/Script/ShadowTrackerExtra.GameLuaAPI")
  return GameLuaAPI.TransFormSetRotator(trans, uRotator)
end
function Game:QuatToRotator(uQuat)
  local GameLuaAPI = import("/Script/ShadowTrackerExtra.GameLuaAPI")
  return GameLuaAPI.QuatToRotator(uQuat)
end
function Game:GetRotationFromTwoDirection(uVectorA, uVectorB)
  local GameLuaAPI = import("/Script/ShadowTrackerExtra.GameLuaAPI")
  return GameLuaAPI.GetRotationFromTwoDirection(uVectorA, uVectorB)
end
function Game:PlayLevelSequence(uWorldContext, SequencePath, Transform, SequenceActorPath, bAutoPlay, BindingList, uOwner)
  if SequenceActorPath == nil then
    SequenceActorPath = "/Game/Mod/EvoBase/BluePrints/Actor/BP_UAELevelSequenceActor.BP_UAELevelSequenceActor_C"
  end
  local FSeqActorBindingData = import("SeqActorBindingData")
  local BindingListArray = slua.Array(UEnums.EPropertyClass.Struct, FSeqActorBindingData)
  if BindingList ~= nil then
    for sTrackName, uActor in pairs(BindingList) do
      local BindingData = FSeqActorBindingData()
      BindingData.TrackName = sTrackName
      BindingData.BindingActor = uActor
      BindingListArray:Add(BindingData)
    end
  end
  local USTExtraGameplayStatics = import("STExtraGameplayStatics")
  return USTExtraGameplayStatics.PlayLevelSequence(uWorldContext, SequencePath, Transform, SequenceActorPath, BindingListArray, bAutoPlay, uOwner)
end
function Game:CreatePawn(nTeamID, nResID, uPosition, uRotation)
  local pawn = CGame:CreatePawn(nTeamID, nResID, uPosition, uRotation)
  return pawn
end
function Game:SpawnVehicle(nResID, uPosition, uRotation)
  local FVehicleParams = import("VehicleParams")
  local VehicleParam = FVehicleParams()
  local vehicle = CGame:SpawnVehicle(nResID, uPosition, uRotation, VehicleParam)
  return vehicle
end
function Game:CreateActor(nTeamID, nResID, uPosition, uRotation)
  local actor = CGame:CreateActor(nTeamID, nResID, uPosition, uRotation)
  return actor
end
function Game:RemoveActor(uActor)
  if not Game:IsValid(uActor) then
    return false
  end
  return CGame:RemoveActor(uActor)
end
function Game:CreatePickup(nTeamID, nResID, uPosition, uRotation, nNum)
  local pickUp = CGame:CreatePickup(nTeamID, nResID, uPosition, uRotation, nNum)
  return pickUp
end
function Game:AddItemByResID(uPlayer, nResId, nNum, bWithTips, nInstanceId, nDurability, nPickupType, bAutoEquip)
  if not Game:IsValid(uPlayer) then
    return false
  end
  if not nResId then
    return false
  end
  if bWithTips == nil then
    bWithTips = true
  end
  nResId = math.tointeger(nResId)
  if not nResId then
    return false
  end
  nNum = math.tointeger(nNum)
  if not nNum then
    return false
  end
  nInstanceId = nInstanceId or 0
  nInstanceId = math.tointeger(nInstanceId) or 0
  if nInstanceId < 0 then
    nInstanceId = 0
  end
  nDurability = math.tointeger(nDurability) or -1
  local EBattleItemClientPickupType = import("EBattleItemClientPickupType")
  local enumPickupType = EBattleItemClientPickupType.Defalut
  if nPickupType == 1 then
    enumPickupType = EBattleItemClientPickupType.ForceIntoBackpack
  elseif nPickupType == 2 then
    enumPickupType = EBattleItemClientPickupType.PickupIntoSafetyBox
  end
  if bAutoEquip == nil then
    bAutoEquip = false
  end
  local isAdd = CGame:AddItemByResID(uPlayer, nResId, nNum, bWithTips, nInstanceId, nDurability, enumPickupType, bAutoEquip)
  return isAdd
end
function Game:AddItemByResIDWithReason(uPlayer, nResId, nNum, Reason, nInstanceId, nDurability, nPickupType, bAutoEquip)
  if not Game:IsValid(uPlayer) then
    return false
  end
  if not nResId then
    return false
  end
  if Reason == nil then
    return false
  end
  nResId = math.tointeger(nResId)
  if not nResId then
    return false
  end
  nNum = math.tointeger(nNum)
  if not nNum then
    return false
  end
  nInstanceId = nInstanceId or 0
  nInstanceId = math.tointeger(nInstanceId) or 0
  if nInstanceId < 0 then
    nInstanceId = 0
  end
  nDurability = math.tointeger(nDurability) or -1
  local EBattleItemClientPickupType = import("EBattleItemClientPickupType")
  local enumPickupType = EBattleItemClientPickupType.Defalut
  if nPickupType == 1 then
    enumPickupType = EBattleItemClientPickupType.ForceIntoBackpack
  elseif nPickupType == 2 then
    enumPickupType = EBattleItemClientPickupType.PickupIntoSafetyBox
  end
  if bAutoEquip == nil then
    bAutoEquip = false
  end
  local isAdd = CGame:AddItemByResIDWithReason(uPlayer, nResId, nNum, Reason, nInstanceId, nDurability, enumPickupType, bAutoEquip)
  return isAdd
end
function Game:ConsumeItem(uPlayer, nItemID, nNum)
  if not Game:IsValid(uPlayer) then
    return false
  end
  local OwnerController = uPlayer:GetControllerSafety()
  if not slua.isValid(OwnerController) then
    print(bWriteLog and "BaseTransformFeature:ClearBackPackData OwnerController nil")
    return
  end
  local uBackpackComponent = OwnerController.BackpackComponent
  if not Game:IsValid(uBackpackComponent) then
    return false
  end
  local BackpackUtils = import("BackpackUtils")
  local ItemMainType = BackpackUtils.GetItemType(nItemID)
  if ItemMainType == 0 then
    return false
  end
  if nNum == 0 then
    return true, 0
  end
  local tItemDefineID = {}
  tItemDefineID.TypeSpecificID = nItemID
  tItemDefineID.Type = ItemMainType
  local nConsume = uBackpackComponent:ConsumeItem(tItemDefineID, nNum)
  if 0 < nConsume then
    return true, nConsume
  end
end
function Game:ConsumeItemFromController(uPlayerController, nItemID, nNum)
  if not Game:IsValid(uPlayerController) then
    return false
  end
  local uBackpackComponent = uPlayerController.BackpackComponent
  if not Game:IsValid(uBackpackComponent) then
    return false
  end
  local BackpackUtils = import("BackpackUtils")
  local ItemMainType = BackpackUtils.GetItemType(nItemID)
  if ItemMainType == 0 then
    return false
  end
  local tItemDefineID = {}
  tItemDefineID.TypeSpecificID = nItemID
  tItemDefineID.Type = ItemMainType
  local nConsume = uBackpackComponent:ConsumeItem(tItemDefineID, nNum)
  if 0 <= nConsume then
    return true
  end
end
function Game:DropItem(PlayerKey, nItemID, nNum)
  if PlayerKey == nil or PlayerKey <= 0 then
    return false
  end
  if nNum == nil or nNum <= 0 then
    return true
  end
  local uPlayerController = GameplayData.GetPlayerController(PlayerKey)
  if not Game:IsValid(uPlayerController) then
    return false
  end
  local uBackpackComponent = uPlayerController.BackpackComponent
  if not Game:IsValid(uBackpackComponent) then
    return false
  end
  return Game:DropItemFromBackpackComponent(uBackpackComponent, nItemID, nNum)
end
function Game:DropItemFromBackpackComponent(uBackpackComponent, nItemID, nNum)
  if not Game:IsValid(uBackpackComponent) then
    return false
  end
  if nNum == nil or nNum <= 0 then
    return true
  end
  local BackpackUtils = import("BackpackUtils")
  local ItemMainType = BackpackUtils.GetItemType(nItemID)
  if ItemMainType == 0 then
    return false
  end
  local NeedDropItemNum = nNum
  local NeedDrop = 0 < NeedDropItemNum
  local EBattleItemDropReason = import("EBattleItemDropReason")
  while NeedDrop do
    local uItemDefineID = uBackpackComponent:GetFirstItemDefineBySpecificID(nItemID)
    if uItemDefineID.TypeSpecificID == nItemID then
      local ItemHandle = uBackpackComponent:GetItemHandleByDefineID(uItemDefineID)
      local ItemHandleCount = ItemHandle.Count
      local bDropSuc = uBackpackComponent:DropItem(uItemDefineID, nNum, EBattleItemDropReason.Force)
      if bDropSuc then
        NeedDropItemNum = NeedDropItemNum - (ItemHandleCount - ItemHandle.Count)
      else
        NeedDrop = false
      end
      if NeedDropItemNum <= 0 then
        NeedDrop = false
      end
    else
      NeedDrop = false
    end
  end
  return NeedDropItemNum ~= nNum
end
function Game:GetItemCount(PlayerKey, ItemID)
  if not PlayerKey or PlayerKey <= 0 then
    return 0
  end
  local uPlayerController = GameplayData.GetPlayerController(PlayerKey)
  if not Game:IsValid(uPlayerController) then
    return 0
  end
  local uBackpackComponent = uPlayerController.BackpackComponent
  if not Game:IsValid(uBackpackComponent) then
    return 0
  end
  local BackpackUtils = import("BackpackUtils")
  local ItemMainType = BackpackUtils.GetItemType(ItemID)
  if ItemMainType == 0 then
    return 0
  end
  local ItemDefineID = uBackpackComponent:GetFirstItemDefineBySpecificID(ItemID)
  if ItemDefineID and ItemDefineID.TypeSpecificID == ItemID then
    local ItemHandle = uBackpackComponent:GetItemHandleByDefineID(ItemDefineID)
    if ItemHandle then
      return ItemHandle.Count
    end
  end
  return 0
end
function Game:AddBuff(nId, uTargetPawn, uCauser)
  if not Game:IsValid(uTargetPawn) then
    return false
  end
  local isAdd = CGame:AddBuff(nId, uTargetPawn, uCauser)
  return isAdd
end
function Game:RemoveBuff(nId, uTargetPawn, uCauser)
  local isAdd = CGame:RemoveBuff(nId, uTargetPawn, uCauser)
  return isAdd
end
function Game:RevivePlayer(nPlayerKey, uPosition, uRotation, bKeepItems, bKeepClipBullet, RespawnTime, bRespawnShow, bAliveReset, bAI, bRecreateAvatar)
  local bTempSafeKeepItems = bKeepItems
  if bTempSafeKeepItems == nil then
    bTempSafeKeepItems = false
  end
  local bTempKeepClipBullet = bKeepClipBullet
  if bTempKeepClipBullet == nil then
    bTempKeepClipBullet = false
  end
  if RespawnTime == nil then
    RespawnTime = -1
  end
  local bTempRespawnShow = bRespawnShow
  if bTempRespawnShow == nil then
    bTempRespawnShow = true
  end
  if bAliveReset == nil then
    bAliveReset = false
  end
  if bRecreateAvatar == nil then
    bRecreateAvatar = false
  end
  local PlayerState = GameplayData.GetPlayerState(nPlayerKey)
  if slua.isValid(PlayerState) and RespawnTime == 0 then
    PlayerState.LuaSetIsRespawning = true
  end
  if uPosition == nil or uPosition == -1 then
    CGame:RevivePlayer(nPlayerKey, bTempSafeKeepItems, bTempKeepClipBullet, RespawnTime, bTempRespawnShow, bAliveReset, bRecreateAvatar)
  else
    CGame:RevivePlayerAtPosition(nPlayerKey, uPosition, uRotation, bTempSafeKeepItems, bTempKeepClipBullet, RespawnTime, bTempRespawnShow, bAliveReset, bAI or false, bRecreateAvatar)
  end
  if slua.isValid(PlayerState) and RespawnTime == 0 then
    PlayerState.LuaSetIsRespawning = false
  end
end
function Game:ReviveFakePlayer(nPlayerKey, uPosition, uRotation, bKeepItems, RespawnTime, bRespawnShow)
  local bTempRespawnShow = bRespawnShow
  if bTempRespawnShow == nil then
    bTempRespawnShow = true
  end
  if uPosition == nil then
    uPosition = FVector(0, 0, 0)
  end
  if uRotation == nil then
    uRotation = FRotator(0, 0, 0)
  end
  CGame:ReviveFakePlayer(nPlayerKey, uPosition, uRotation, bKeepItems or false, RespawnTime or -1, bTempRespawnShow, true, true)
end
function Game:ShowPlayer(uCharacter, bShow)
  local bTempShow = bShow
  if bTempShow == nil then
    bTempShow = true
  end
  if slua.isValid(uCharacter) and uCharacter.HasAuthority and uCharacter:HasAuthority() then
    local ECharacterHideMovementAcive = import("ECharacterHideMovementAcive")
    uCharacter:SetCharacterHideInGame(not bTempShow, true, true, 1, ECharacterHideMovementAcive.Normal)
  else
    print(bWriteLog and "ShowPlayer Only Call from DS")
  end
end
function Game:CheckSendBattleResult(uGameMode, uPlayerState, bCheckSendTeamResult)
  if slua.isValid(uGameMode) and slua.isValid(uPlayerState) then
    CGame:CheckSendBattleResult(uGameMode, uPlayerState, bCheckSendTeamResult)
  else
    print(bWriteLog and "Game:CheckSendBattleResult uGameMode or uPlayerState not valid")
  end
end
function Game:TeleportPlayerToVehicle(uPlayer, uVehicle, nSeatIdx)
  if not uPlayer then
    return
  end
  return CGame:TeleportPlayerToVehicle(uPlayer, uVehicle, nSeatIdx)
end
function Game:RemoteCreateActor(nPlayerKey, nTeamID, nResID, uPosition, uRotation)
  local bToAll = false
  if nPlayerKey == -1 then
    bToAll = true
    nPlayerKey = 0
  end
  return CGame:RemoteCreateActor(nPlayerKey, nTeamID, nResID, uPosition, uRotation, bToAll)
end
function Game:RemoteDestroyActor(nPlayerKey, nSingleId)
  local bToAll = false
  if nPlayerKey == -1 then
    bToAll = true
    nPlayerKey = 0
  end
  return CGame:RemoteDestroyActor(nPlayerKey, nSingleId, bToAll)
end
function Game:RemoteDestroyAllActor(nPlayerKey)
  local bToAll = false
  if nPlayerKey == -1 then
    bToAll = true
    nPlayerKey = 0
  end
  return CGame:RemoteDestroyAllActor(nPlayerKey, bToAll)
end
function Game:GetAllPlayerControllers()
  return CGame:GetAllPlayerControllers()
end
function Game:GetPlayerByPlayerKey(nPlayerKey)
  if not nPlayerKey then
    return nil
  end
  if type(nPlayerKey) == "string" then
    nPlayerKey = tonumber(nPlayerKey)
  end
  local uCharacter = GameplayData.GetPlayerCharacter(nPlayerKey)
  return slua.isValid(uCharacter) and uCharacter or CGame:GetPlayerByPlayerKey(nPlayerKey)
end
function Game:GetPlayerControllerByPlayerKey(nPlayerKey)
  if not nPlayerKey then
    return nil
  end
  return CGame:GetPlayerControllerByPlayerKey(nPlayerKey)
end
function Game:GetPlayerStateByPlayerKey(nPlayerKey)
  if not nPlayerKey then
    return nil
  end
  if type(nPlayerKey) == "string" then
    nPlayerKey = tonumber(nPlayerKey)
  end
  return GameplayData.GetPlayerState(nPlayerKey)
end
function Game:GetPlayerControllerByUID(nUID)
  if not nUID then
    return nil
  end
  return CGame:GetPlayerControllerByUID(nUID)
end
function Game:GetCharacterByUID(nUID)
  local uPC = Game:GetPlayerControllerByUID(nUID)
  if not Game:IsValid(uPC) then
    return nil
  end
  return uPC:GetCurPlayerCharacter()
end
function Game:GetPlayerStateByUID(nUID)
  local uPC = Game:GetCharacterByUID(nUID)
  if not Game:IsValid(uPC) then
    return nil
  end
  return uPC:GetPlayerStateSafety()
end
function Game:EndMatch(nTeamId, nReason)
  nTeamId = nTeamId or 0
  nReason = nReason or 0
  return CGame:EndMatch(nTeamId, nReason)
end
function Game:DamageTarget(uSource, uTarget, nDamage, nTypeId)
  CGame:DamageTarget(uSource, uTarget, nDamage, nTypeId)
end
function Game:TeleportPawn(uPawn, uPosition, uRotation, bParachute, bCallback, bIsATest, bNoCheck, TeleportPawnType, ParamID)
  if not uPawn then
    return false
  end
  if bCallback == nil then
    bCallback = false
  end
  if bIsATest == nil then
    bIsATest = false
  end
  if bNoCheck == nil then
    bNoCheck = false
  end
  local ETeleportPawnType = import("ETeleportPawnType")
  if TeleportPawnType == nil then
    TeleportPawnType = ETeleportPawnType.NormalTeleport
  end
  if ParamID == nil then
    ParamID = 0
  end
  local result = CGame:TeleportPawn(uPawn, uPosition, uRotation, bCallback, bIsATest, bNoCheck, TeleportPawnType, ParamID)
  local uController = uPawn:GetController()
  if slua.isValid(uController) then
    uController:ClientSetRotation(uRotation, true)
    uController:SetControlRotation(uRotation, "Game:TeleportPawn")
  end
  if bParachute then
    local uPlayerController = uPawn:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      local EStateType = import("EStateType")
      uPlayerController:ServerChangeStatePC(EStateType.State_ParachuteJump)
    else
      print(bWriteLog and "Game:TeleportPawn, bParachute = " .. tostring(bParachute) .. ", controller = " .. tostring(uPlayerController))
    end
  end
  return result
end
function Game:GetPointsOfIntersectionOfLineAndCircle(Point1, Point2, CircleCenter, Radius)
  local V1 = Point2 - Point1
  V1:Normalize(0.001)
  local V2 = CircleCenter - Point1
  local Length1 = FVector2D.DotProduct(V1, V2)
  local V3 = V2 - V1 * Length1
  local Dist = V3:Size()
  local Tolerate = 0.001
  if Tolerate > math.abs(Dist - Radius) then
    return Point1 + V1 * Length1
  elseif Radius > Dist then
    local Middle = Point1 + V1 * Length1
    local Length2 = math.sqrt(Radius * Radius - Dist * Dist)
    return Middle - V1 * Length2, Middle + V1 * Length2
  else
    return nil
  end
end
function Game:GetRouteDirectionFromTwoCircle(CircleCenter, Radius1, Radius2, bCrossCenter)
  local Rad1 = math.random(0, 360)
  local Rad2 = math.random(0, 360)
  local V1 = FVector2D(math.cos(Rad1), math.sin(Rad1))
  local StartPoint = CircleCenter + V1 * Radius1
  local EndPoint = FVector2D(0, 0)
  if bCrossCenter == true then
    EndPoint = CircleCenter - V1 * Radius1
  else
    local V2 = FVector2D(math.cos(Rad2), math.sin(Rad2))
    EndPoint = CircleCenter + V2 * Radius2
  end
  return StartPoint, EndPoint
end
function Game:CalcPointOfTangency(Center, Radius, Point)
  local Distance = FVector2D.Distance(Center, Point)
  local NormalPoint = Point - Center
  local PointAngleX = math.deg(math.acos(NormalPoint.X / Distance))
  if NormalPoint.Y < 0 then
    PointAngleX = 360 - PointAngleX
  end
  local PointOfTangencyAngle = math.deg(math.acos(Radius / Distance))
  local TotalAngle = PointAngleX + PointOfTangencyAngle
  while TotalAngle < 0 do
    TotalAngle = TotalAngle + 360
  end
  while 360 <= TotalAngle do
    TotalAngle = TotalAngle - 360
  end
  local V2 = FVector2D(math.cos(math.rad(TotalAngle)), math.sin(math.rad(TotalAngle))) * Radius
  local Result = Center + V2
  print(bWriteLog and "DSReviveSubsystem:CalcPointOfTangency, Result = " .. tostring(Result:ToString()))
  return Result
end
function Game:LineSegmentIntersection2D(SegmentStartA, SegmentEndA, SegmentStartB, SegmentEndB)
  local VectorA = SegmentEndA - SegmentStartA
  local VectorB = SegmentEndB - SegmentStartB
  local S = (-VectorA.Y * (SegmentStartA.X - SegmentStartB.X) + VectorA.X * (SegmentStartA.Y - SegmentStartB.Y)) / (-VectorB.X * VectorA.Y + VectorA.X * VectorB.Y)
  local T = (VectorB.X * (SegmentStartA.Y - SegmentStartB.Y) - VectorB.Y * (SegmentStartA.X - SegmentStartB.X)) / (-VectorB.X * VectorA.Y + VectorA.X * VectorB.Y)
  local bIntersects = 0 <= S and S <= 1 or 0 <= T and T <= 1
  local IntersectionPoint = FVector2D(0, 0)
  if bIntersects then
    IntersectionPoint.X = SegmentStartA.X + T * VectorA.X
    IntersectionPoint.Y = SegmentStartA.Y + T * VectorA.Y
  end
  return bIntersects, IntersectionPoint
end
function Game:SegmentIntersection2D(SegmentStartA, SegmentEndA, SegmentStartB, SegmentEndB)
  local VectorA = SegmentEndA - SegmentStartA
  local VectorB = SegmentEndB - SegmentStartB
  local S = (-VectorA.Y * (SegmentStartA.X - SegmentStartB.X) + VectorA.X * (SegmentStartA.Y - SegmentStartB.Y)) / (-VectorB.X * VectorA.Y + VectorA.X * VectorB.Y)
  local T = (VectorB.X * (SegmentStartA.Y - SegmentStartB.Y) - VectorB.Y * (SegmentStartA.X - SegmentStartB.X)) / (-VectorB.X * VectorA.Y + VectorA.X * VectorB.Y)
  local bIntersects = 0 <= S and S <= 1 and 0 <= T and T <= 1
  local IntersectionPoint = FVector2D(0, 0)
  if bIntersects then
    IntersectionPoint.X = SegmentStartA.X + T * VectorA.X
    IntersectionPoint.Y = SegmentStartA.Y + T * VectorA.Y
  end
  return bIntersects, IntersectionPoint
end
function Game:GetDistanceFormPointToLine(Point, LinePoint1, LinePoint2)
  if not (Point and LinePoint1) or not LinePoint2 then
    return nil
  end
  local A = LinePoint2.Y - LinePoint1.Y
  local B = LinePoint1.X - LinePoint2.X
  local C = LinePoint2.X * LinePoint1.Y - LinePoint1.X * LinePoint2.Y
  local Dis = math.abs(A * Point.X + B * Point.Y + C) / math.sqrt(A ^ 2 + B ^ 2)
  return Dis
end
function Game:UIShowCountDownTips(nPlayerKey, nTipType, sText, nTextId, nTime, tParam)
  if nTime == nil or nTime <= 0 then
    return
  end
  local bToAll = false
  if nPlayerKey == -1 then
    bToAll = true
    nPlayerKey = 0
  end
  if nTipType == nil or nTipType <= 0 then
    nTipType = 0
  end
  local ParamStr = ""
  if sText ~= nil and sText ~= "" then
    ParamStr = ParamStr .. "Str_" .. tostring(sText)
  end
  if nTextId ~= nil and nTextId ~= 0 then
    ParamStr = ParamStr .. "Tran_" .. tostring(nTextId)
  end
  if tParam ~= nil and type(tParam) == "table" and next(tParam) ~= nil then
    for key, value in ipairs(tParam) do
      if 0 < #ParamStr then
        ParamStr = ParamStr .. "|"
      end
      if type(value) == "number" then
        ParamStr = ParamStr .. "Str_" .. tostring(value)
      elseif type(value) == "string" then
        ParamStr = ParamStr .. "Str_" .. value
      elseif type(value) == "table" and next(value) ~= nil then
        for k, v in ipairs(value) do
          ParamStr = ParamStr .. "Tran_" .. tostring(v)
        end
      end
    end
  end
  if nTextId == nil then
    nTextId = 0
  end
  if 0 < #ParamStr then
    ParamStr = ParamStr .. "|"
  end
  ParamStr = ParamStr .. "Time_" .. tostring(nTime)
  CGame:UICustomBehavior(nPlayerKey, "UIShowCountDownTips", nTipType, ParamStr, bToAll)
end
function Game:SetProjectileVelocity(uActor, uVelocity)
  if Game:IsValid(uActor) then
    if uActor.SetVelocityMulticast then
      uActor:SetVelocityMulticast(uVelocity)
    else
      print(bWriteLog and "SetProjectileVelocity Error: Can only set velocity for ProjectileDecoratorActor")
    end
  else
    print(bWriteLog and "SetProjectileVelocity Error: Invalid Actor")
  end
end
function Game:SetTeamID(uActor, nTeamID)
  if Game:IsValid(uActor) and CGame.SetTeamID then
    return CGame:SetTeamID(uActor, nTeamID)
  end
end
function Game:SetTeamIDByPlayerKey(nPlayerKey, nTeamID)
  if not nPlayerKey then
    return
  end
  CGame:SetTeamIDByPlayerKey(nPlayerKey, nTeamID)
end
function Game:CreateFakePlayer(nTeamID, nResID, uPosition, uRotation, nParamsID, bUsePool, nCampId, bAddToAIActingManager)
  if not uPosition or not uRotation then
    return nil
  end
  local bRealUsePool = false
  if bUsePool ~= nil then
    bRealUsePool = bUsePool
  end
  if nParamsID == nil then
    nParamsID = 0
  end
  if nCampId == nil then
    nCampId = 0
  end
  if bAddToAIActingManager == nil then
    bAddToAIActingManager = false
  end
  return CGame:CreateFakePlayer(nTeamID, nResID, uPosition, uRotation, nParamsID, bRealUsePool, nCampId, bAddToAIActingManager)
end
function Game:CreateMonsterUnit(nResID, uPosition, uRotation, bForce, SourceType, SpawnCollisionHandlingMethod, CallPawnKey)
  if not (nResID and not (nResID <= 0) and uPosition) or not uRotation then
    return nil
  end
  if bForce == nil then
    bForce = false
  end
  local FMonsterParams = import("MonsterParams")
  local MobParam = FMonsterParams()
  MobParam.bForceSpawn = bForce
  if SourceType ~= nil then
    MobParam.  end
  if CallPawnKey then
    MobParam.  end
  if SpawnCollisionHandlingMethod ~= nil then
    MobParam.  end
  return CGame:CreateMonsterUnit(nResID, uPosition, uRotation, MobParam)
end
function Game:KillPawn(uPawn)
  if not Game:IsValid(uPawn) then
    return
  end
  CGame:KillPawn(uPawn)
end
function Game:AddHealth(uPlayer, nHealth)
  if not Game:IsValid(uPlayer) then
    return 0
  end
  return CGame:AddHealth(uPlayer, nHealth)
end
function Game:SetHealth(uPlayer, nHealth)
  if not Game:IsValid(uPlayer) then
    return 0
  end
  return CGame:SetHealth(uPlayer, nHealth)
end
function Game:IssueOrder(uPawn, tOrder, bClearFormer, fOnFinish, bPrependHead)
  if Game:IsValid(uPawn) and Game:IsValid(uPawn.GetController) then
    local uAIController = uPawn:GetController()
    if Game:IsValid(uAIController) then
      local uAIOrder = uAIController.AIOrder
      if Game:IsValid(uAIOrder) then
        if bClearFormer == nil then
          bClearFormer = true
        end
        if bClearFormer then
          uAIOrder:ClearOrderQueue()
        end
        local fOnFinishCo = function()
        end
        if fOnFinish then
          function fOnFinishCo(bRet)
            CallWithWait(fOnFinish, bRet)
          end
        end
        if bPrependHead then
          uAIOrder:PrependInNextEnqueue()
        end
        if tOrder.nType == UEnums.EAIOrderType.MoveTo then
          uAIOrder:IssueMoveTo(tOrder.vPosition, tOrder.nMaxTime, fOnFinishCo)
        elseif tOrder.nType == UEnums.EAIOrderType.MoveAttack then
          uAIOrder:IssueMoveAttack(tOrder.vPosition, tOrder.nMaxTime, fOnFinishCo)
        elseif tOrder.nType == UEnums.EAIOrderType.AttackMove then
          uAIOrder:IssueAttackMove(tOrder.vPosition, tOrder.nMaxTime, fOnFinishCo)
        elseif tOrder.nType == UEnums.EAIOrderType.MoveToTarget then
          if not Game:IsValid(tOrder.uTarget) then
            local utility = require("common.utility")
            utility.ErrorMessageHandler("IssueOrder failed, uTarget is invalid")
            return
          end
          uAIOrder:IssueMoveToTarget(tOrder.uTarget, tOrder.nRedirectTime, tOrder.nAcceptDist, tOrder.nMaxTime, fOnFinishCo)
        elseif tOrder.nType == UEnums.EAIOrderType.AttackTarget then
          if not Game:IsValid(tOrder.uTarget) then
            local utility = require("common.utility")
            utility.ErrorMessageHandler("IssueOrder failed, uTarget is invalid")
            return
          end
          uAIOrder:IssueAttackTarget(tOrder.uTarget, tOrder.nMaxTime, fOnFinishCo)
        elseif tOrder.nType == UEnums.EAIOrderType.GuardTarget then
          if not Game:IsValid(tOrder.uTarget) then
            local utility = require("common.utility")
            utility.ErrorMessageHandler("IssueOrder failed, uTarget is invalid")
            return
          end
          uAIOrder:IssueGuardTarget(tOrder.uTarget, tOrder.nRadius, tOrder.nMaxTime, fOnFinishCo)
        elseif tOrder.nType == UEnums.EAIOrderType.GuardArea then
          uAIOrder:IssueGuardArea(tOrder.vCenter, tOrder.nRadius, tOrder.nRandomMoveInterval, tOrder.bChase, tOrder.nMaxTime, fOnFinishCo)
        elseif tOrder.nType == UEnums.EAIOrderType.CastSkillNoneTarget then
          uAIOrder:IssueCastSkillNoneTarget(tOrder.nSkillIndex, fOnFinishCo)
        elseif tOrder.nType == UEnums.EAIOrderType.CastSkillOnTarget then
          if not Game:IsValid(tOrder.uTarget) then
            local utility = require("common.utility")
            utility.ErrorMessageHandler("IssueOrder failed, uTarget is invalid")
            return
          end
          local nLocalSkillRadius = 0
          if tOrder.nRadius ~= nil then
            nLocalSkillRadius = tOrder.nRadius
          end
          uAIOrder:IssueCastSkillOnTarget(tOrder.nSkillIndex, tOrder.uTarget, nLocalSkillRadius, fOnFinishCo)
        elseif tOrder.nType == UEnums.EAIOrderType.CastSkillOnLocation then
          local nLocalSkillRadius = 0
          if tOrder.nRadius ~= nil then
            nLocalSkillRadius = tOrder.nRadius
          end
          uAIOrder:IssueCastSkillOnLocation(tOrder.nSkillIndex, tOrder.vLocation, nLocalSkillRadius, fOnFinishCo)
        elseif tOrder.nType == UEnums.EAIOrderType.IdleShow then
          uAIOrder:IssueIdleShow(tOrder.nIdleTime, tOrder.nIdleIndex, tOrder.nMaxTime, fOnFinishCo)
        elseif tOrder.nType == UEnums.EAIOrderType.RotateTo then
          uAIOrder:IssueRotateTo(tOrder.vRotateTargetPosition, fOnFinishCo)
        elseif tOrder.nType == UEnums.EAIOrderType.Stop then
          uAIOrder:IssueStop(tOrder.nMaxTime, fOnFinishCo)
        else
          print(bWriteLog and "IssueOrder failed, wrong order type")
          if bPrependHead then
            uAIOrder:RevertPrependInNextEnqueue()
          end
        end
      end
    end
  end
end
function Game:GetAIBlackboardValue(uPawn, eType, sKey)
  if not slua.isValid(uPawn) then
    return
  end
  if uPawn.GetEnsure and not uPawn:GetEnsure() then
    return
  end
  local uController = uPawn:GetController()
  if Game:IsValid(uController) and Game:IsAIController(uController) then
    local uBlackboard = uController.Blackboard
    if Game:IsValid(uBlackboard) and Game:IsValid(uBlackboard.BlackboardAsset) then
      if eType == UEnums.EBlackBoardKeyType.Object then
        return uBlackboard:GetValueAsObject(sKey)
      elseif eType == UEnums.EBlackBoardKeyType.Class then
        return uBlackboard:GetValueAsClass(sKey)
      elseif eType == UEnums.EBlackBoardKeyType.Enum then
        return uBlackboard:GetValueAsEnum(sKey)
      elseif eType == UEnums.EBlackBoardKeyType.Int then
        return uBlackboard:GetValueAsInt(sKey)
      elseif eType == UEnums.EBlackBoardKeyType.Float then
        return uBlackboard:GetValueAsFloat(sKey)
      elseif eType == UEnums.EBlackBoardKeyType.Bool then
        return uBlackboard:GetValueAsBool(sKey)
      elseif eType == UEnums.EBlackBoardKeyType.String then
        return uBlackboard:GetValueAsString(sKey)
      elseif eType == UEnums.EBlackBoardKeyType.Name then
        return uBlackboard:GetValueAsName(sKey)
      elseif eType == UEnums.EBlackBoardKeyType.Vector then
        return uBlackboard:GetValueAsVector(sKey)
      elseif eType == UEnums.EBlackBoardKeyType.Rotator then
        return uBlackboard:GetValueAsRotator(sKey)
      end
    end
  end
end
function Game:SetAIBlackboardValue(uPawn, eType, sKey, aValue)
  if not slua.isValid(uPawn) then
    return
  end
  if uPawn.GetEnsure and not uPawn:GetEnsure() then
    return
  end
  local uController = uPawn:GetController()
  if Game:IsValid(uController) and Game:IsAIController(uController) then
    local uBlackboard = uController.Blackboard
    if Game:IsValid(uBlackboard) and Game:IsValid(uBlackboard.BlackboardAsset) then
      if eType == UEnums.EBlackBoardKeyType.Object then
        if slua.isValid(aValue) then
          uBlackboard:SetValueAsObject(sKey, aValue)
        end
      elseif eType == UEnums.EBlackBoardKeyType.Class then
        uBlackboard:SetValueAsClass(sKey, aValue)
      elseif eType == UEnums.EBlackBoardKeyType.Enum then
        uBlackboard:SetValueAsEnum(sKey, aValue)
      elseif eType == UEnums.EBlackBoardKeyType.Int then
        uBlackboard:SetValueAsInt(sKey, aValue)
      elseif eType == UEnums.EBlackBoardKeyType.Float then
        uBlackboard:SetValueAsFloat(sKey, aValue)
      elseif eType == UEnums.EBlackBoardKeyType.Bool then
        uBlackboard:SetValueAsBool(sKey, aValue)
      elseif eType == UEnums.EBlackBoardKeyType.String then
        uBlackboard:SetValueAsString(sKey, aValue)
      elseif eType == UEnums.EBlackBoardKeyType.Name then
        uBlackboard:SetValueAsName(sKey, aValue)
      elseif eType == UEnums.EBlackBoardKeyType.Vector then
        uBlackboard:SetValueAsVector(sKey, aValue)
      elseif eType == UEnums.EBlackBoardKeyType.Rotator then
        uBlackboard:SetValueAsRotator(sKey, aValue)
      end
    end
  end
end
function Game:ClearObjectBBValue(uPawn, eType, sKey)
  if not slua.isValid(uPawn) then
    return
  end
  if uPawn.GetEnsure and not uPawn:GetEnsure() then
    return
  end
  local uController = uPawn:GetController()
  if Game:IsValid(uController) and Game:IsAIController(uController) then
    local uBlackboard = uController.Blackboard
    if Game:IsValid(uBlackboard) and Game:IsValid(uBlackboard.BlackboardAsset) and eType == UEnums.EBlackBoardKeyType.Object then
      uBlackboard:SetValueAsObject(sKey, nil)
    end
  end
end
function Game:GetPlayerStatesByTeamID(nTeamID)
  if Game:IsValid(CGameMode.TeamModeComponent) then
    local uPlayerStates = CGameMode.TeamModeComponent:GetTeamates(nTeamID)
    return uPlayerStates
  end
  return slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.Actor"))
end
function Game:GetAllTeamIDs()
  if Game:IsValid(CGameMode.TeamModeComponent) then
    local TeamIDs = CGameMode.TeamModeComponent:GetTeamIDs()
    return TeamIDs
  end
  return slua.Array(UEnums.EPropertyClass.Int)
end
function Game:SetSkillActive(uPawn, nSkillID, bActive)
  if not Game:IsValid(uPawn) then
    return
  end
  local uSkillManager = uPawn.SkillManager
  if not Game:IsValid(uSkillManager) then
    return
  end
  if bActive then
    uSkillManager:TryAddOneSkill(nSkillID, bActive, 0)
  else
    uSkillManager:TryDeleteOneSkill(nSkillID, true, true)
  end
end
function Game:SendTipsToPlayerInSpecificArea(uArea, nTipsID, Param)
  local Actor_C = import("/Script/Engine.Actor")
  local PlayerPawn_C = import("STExtraPlayerCharacter")
  local AreaPlayerList
  if nTipsID and 0 < nTipsID and slua.isValid(uArea) and uArea.GetOverlappingActors then
    AreaPlayerList = uArea:GetOverlappingActors(slua.Array(UEnums.EPropertyClass.Object, Actor_C), PlayerPawn_C)
    if AreaPlayerList then
      for _, uCharacter in pairs(AreaPlayerList) do
        if slua.isValid(uCharacter) and Game:IsPlayer(uCharacter) then
          local sPlayerKey = uCharacter:GetPlayerKey()
          if sPlayerKey then
            Game:UIShowImageTips(tonumber(sPlayerKey), nTipsID, Param)
          end
        end
      end
    end
  end
end
function Game:SendTipsToPlayerInNeighborArea(Loc, Radius, nTipsID, Param)
  local AreaPlayerList
  if nTipsID and 0 < nTipsID then
    local AreaPlayerList = Game:QueryRealPlayers(Loc, Radius)
    if AreaPlayerList then
      for _, uCharacter in pairs(AreaPlayerList) do
        if slua.isValid(uCharacter) and Game:IsPlayer(uCharacter) then
          local sPlayerKey = uCharacter:GetPlayerKey()
          if sPlayerKey then
            Game:UIShowImageTips(tonumber(sPlayerKey), nTipsID, Param)
          end
        end
      end
    end
  end
end
function Game:SendTipsToPlayerTeam(nTeamID, nTipsID, Param)
  if nTipsID and 0 < nTipsID then
    local TeamStates = Game:GetPlayerStatesByTeamID(nTeamID)
    if TeamStates then
      for _, PlayerState in pairs(TeamStates) do
        if slua.isValid(PlayerState) then
          local sPlayerKey = PlayerState:GetPlayerKey()
          if sPlayerKey then
            Game:UIShowImageTips(tonumber(sPlayerKey), nTipsID, Param)
          end
        end
      end
    end
  end
end
function Game:AddItemToBackpackByResID(uPlayer, nResId, nNum, bWithTips, nInstanceId, nDurability)
  return Game:AddItemByResID(uPlayer, nResId, nNum, bWithTips, nInstanceId, nDurability, 1)
end
function Game:AddItemPack(uPlayer, uItemPackData, nPickupType)
  if not Game:IsValid(uPlayer) then
    return false
  end
  local EBattleItemClientPickupType = import("EBattleItemClientPickupType")
  local enumPickupType = EBattleItemClientPickupType.Defalut
  if nPickupType == 1 then
    enumPickupType = EBattleItemClientPickupType.ForceIntoBackpack
  elseif nPickupType == 2 then
    enumPickupType = EBattleItemClientPickupType.PickupIntoSafetyBox
  end
  local isAdd = CGame:AddItemPack(uPlayer, uItemPackData, enumPickupType)
  return isAdd
end
function Game:AddWeaponPack(uPlayer, uWeaponData)
  if not Game:IsValid(uPlayer) then
    return false
  end
  local isAdd = CGame:AddWeaponPack(uPlayer, uWeaponData)
  return isAdd
end
function Game:AddArmorPack(uPlayer, uArmorData)
  if not Game:IsValid(uPlayer) then
    return false
  end
  local isAdd = CGame:AddArmorPack(uPlayer, uArmorData)
  return isAdd
end
function Game:CheckDSSwitchOpen(nSwitchId)
  return CGame:CheckDSSwitchOpen(nSwitchId)
end
function Game:GetDSSwitchValue(nSwitchId, TryHud)
  local Result = CGame:GetDSSwitchValue(nSwitchId)
  if Result == "" and TryHud == true and Server and DSUtils then
    Result = Server.GetDSSwitchValue(DSUtils, nSwitchId)
  end
  return Result
end
function Game:LoadOjectFromPath(sInObjectPath)
  return CGame:LoadOjectFromPath(sInObjectPath)
end
function Game:LoadClassFromBPPath(sInBPPath, uObject)
  return CGame:LoadClassFromBPPath(sInBPPath, uObject)
end
function Game:LoadOjectFromBPPath(sInBPPath, uObject)
  return CGame:LoadOjectFromBPPath(sInBPPath, uObject)
end
function Game:DropItemsInBackpackWithTypes(uPlayer, tDropedTypes)
  if not Game:IsValid(uPlayer) then
    return false
  end
  return CGame:DropItemsInBackpackWithTypes(uPlayer, tDropedTypes)
end
function Game:TeleportPlayerToActor(Player, sTargetActorName)
  local uPlayer = Game:CastToPlayer(Player)
  if Game:IsValid(uPlayer) then
    local uSpawnLocActor = Game:FindRealActorByActorNameAndLandId(sTargetActorName)
    local Loc, Rot
    if Game:IsValid(uSpawnLocActor) and type(uSpawnLocActor) == "userdata" then
      Loc = Game:GetActorLocation(uSpawnLocActor)
      if Game:IsValid(uPlayer.CapsuleComponent) then
        Loc.Z = Loc.Z + uPlayer.CapsuleComponent:GetScaledCapsuleHalfHeight()
      end
      Rot = Game:GetActorRotation(uSpawnLocActor)
    else
      Loc = Game:GetActorLocation(uPlayer)
      Rot = Game:GetActorRotation(uPlayer)
    end
    Game:TeleportPawn(uPlayer, Loc, Rot)
    local uPlayerController = uPlayer:GetController()
    uPlayerController:ClientSetRotation(Rot, true)
  end
end
function Game:TeleportPlayerToActorGroup(Player, sTargetGroupActorName)
  local uPlayer = Game:CastToPlayer(Player)
  if Game:IsValid(uPlayer) then
    local SpawnLocGroupActor = Game:FindRealActorByActorNameAndLandId(sTargetGroupActorName)
    if Game:IsValid(SpawnLocGroupActor) and type(SpawnLocGroupActor) == "userdata" then
      local groupArray = slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.Actor"))
      groupArray = SpawnLocGroupActor:GetAttachedActors(groupArray)
      local groupArrayNum = groupArray:Num()
      if not groupArray or groupArrayNum == 0 then
        sandbox.LogError("TeleportPlayer groupArrayNum inValid!")
        return
      end
      local targetIndex = math.random(0, groupArrayNum - 1)
      local uSpawnLocActor = groupArray:Get(targetIndex)
      local Loc, Rot
      if Game:IsValid(uSpawnLocActor) and type(uSpawnLocActor) == "userdata" then
        Loc = Game:GetActorLocation(uSpawnLocActor)
        if Game:IsValid(uPlayer.CapsuleComponent) then
          Loc.Z = Loc.Z + uPlayer.CapsuleComponent:GetScaledCapsuleHalfHeight()
        end
        Rot = Game:GetActorRotation(uSpawnLocActor)
      else
        Loc = Game:GetActorLocation(uPlayer)
        Rot = Game:GetActorRotation(uPlayer)
      end
      Game:TeleportPawn(uPlayer, Loc, Rot)
      local uPlayerController = uPlayer:GetController()
      uPlayerController:ClientSetRotation(Rot, true)
      return uSpawnLocActor
    end
  end
end
function Game:TeleportAllPlayers(sTargetGroupActorName)
  local playerArray = Game:GetAllPlayerPawns()
  local playerArrayNum = playerArray:Num()
  if not playerArray or playerArrayNum == 0 then
    sandbox.LogError("TeleportAllPlayers playerArrayNum inValid!")
    return
  end
  local SpawnLocGroupActor = Game:FindRealActorByActorNameAndLandId(sTargetGroupActorName)
  if Game:IsValid(SpawnLocGroupActor) and type(SpawnLocGroupActor) == "userdata" then
    local groupArray = slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.Actor"))
    groupArray = SpawnLocGroupActor:GetAttachedActors(groupArray)
    local groupArrayNum = groupArray:Num()
    if not groupArray or groupArrayNum == 0 then
      sandbox.LogError("TeleportAllPlayers groupArrayNum inValid!")
      return
    end
    for index = 1, playerArray:Num() do
      local uPlayer = playerArray:Get(index - 1)
      local targetIndex = (index - 1) % groupArrayNum
      local uSpawnLocActor = groupArray:Get(targetIndex)
      local Loc, Rot
      if Game:IsValid(uSpawnLocActor) and type(uSpawnLocActor) == "userdata" then
        Loc = Game:GetActorLocation(uSpawnLocActor)
        if Game:IsValid(uPlayer.CapsuleComponent) then
          Loc.Z = Loc.Z + uPlayer.CapsuleComponent:GetScaledCapsuleHalfHeight()
        end
        Rot = Game:GetActorRotation(uSpawnLocActor)
      else
        Loc = Game:GetActorLocation(uPlayer)
        Rot = Game:GetActorRotation(uPlayer)
      end
      Game:TeleportPawn(uPlayer, Loc, Rot)
      local uPlayerController = uPlayer:GetController()
      uPlayerController:ClientSetRotation(Rot, true)
    end
  end
end
function Game:SetSkillBlackboardValue(uPawn, nSkillID, eType, sKey, aValue)
  if Game:IsValid(uPawn) and uPawn.GetSkillManager then
    local uSkillMgrComp = uPawn:GetSkillManager()
    if Game:IsValid(uSkillMgrComp) then
      if eType == UEnums.EBlackBoardKeyType.Object then
        if slua.isValid(aValue) then
          uSkillMgrComp:SetValueAsObject(nSkillID, sKey, aValue)
        end
      elseif eType == UEnums.EBlackBoardKeyType.Class then
        uSkillMgrComp:SetValueAsClass(nSkillID, sKey, aValue)
      elseif eType == UEnums.EBlackBoardKeyType.Enum then
        uSkillMgrComp:SetValueAsEnum(nSkillID, sKey, aValue)
      elseif eType == UEnums.EBlackBoardKeyType.Int then
        uSkillMgrComp:SetValueAsInt(nSkillID, sKey, aValue)
      elseif eType == UEnums.EBlackBoardKeyType.Float then
        uSkillMgrComp:SetValueAsFloat(nSkillID, sKey, aValue)
      elseif eType == UEnums.EBlackBoardKeyType.Bool then
        uSkillMgrComp:SetValueAsBool(nSkillID, sKey, aValue)
      elseif eType == UEnums.EBlackBoardKeyType.String then
        uSkillMgrComp:SetValueAsString(nSkillID, sKey, aValue)
      elseif eType == UEnums.EBlackBoardKeyType.Name then
        uSkillMgrComp:SetValueAsName(nSkillID, sKey, aValue)
      elseif eType == UEnums.EBlackBoardKeyType.Vector then
        uSkillMgrComp:SetValueAsVector(nSkillID, sKey, aValue)
      elseif eType == UEnums.EBlackBoardKeyType.Rotator then
        uSkillMgrComp:SetValueAsRotator(nSkillID, sKey, aValue)
      elseif eType == UEnums.EBlackBoardKeyType.WeakObject then
        uSkillMgrComp:SetValueAsWeakObject(nSkillID, sKey, aValue)
      end
    else
      sandbox.LogError("SetSkillBlackboardValue uSkillMgrComp inValid!")
    end
  else
    sandbox.LogError("SetSkillBlackboardValue uPlayerCharacter inValid!")
  end
end
function Game:GetSkillBlackboardValue(uPawn, nSkillID, eType, sKey)
  if Game:IsValid(uPawn) and uPawn.GetSkillManager then
    local uSkillMgrComp = uPawn:GetSkillManager()
    if Game:IsValid(uSkillMgrComp) then
      if eType == UEnums.EBlackBoardKeyType.Object then
        return uSkillMgrComp:GetValueAsObject(nSkillID, sKey)
      elseif eType == UEnums.EBlackBoardKeyType.Class then
        return uSkillMgrComp:GetValueAsClass(nSkillID, sKey)
      elseif eType == UEnums.EBlackBoardKeyType.Enum then
        return uSkillMgrComp:GetValueAsEnum(nSkillID, sKey)
      elseif eType == UEnums.EBlackBoardKeyType.Int then
        return uSkillMgrComp:GetValueAsInt(nSkillID, sKey)
      elseif eType == UEnums.EBlackBoardKeyType.Float then
        return uSkillMgrComp:GetValueAsFloat(nSkillID, sKey)
      elseif eType == UEnums.EBlackBoardKeyType.Bool then
        return uSkillMgrComp:GetValueAsBool(nSkillID, sKey)
      elseif eType == UEnums.EBlackBoardKeyType.String then
        return uSkillMgrComp:GetValueAsString(nSkillID, sKey)
      elseif eType == UEnums.EBlackBoardKeyType.Name then
        return uSkillMgrComp:GetValueAsName(nSkillID, sKey)
      elseif eType == UEnums.EBlackBoardKeyType.Vector then
        return uSkillMgrComp:GetValueAsVector(nSkillID, sKey)
      elseif eType == UEnums.EBlackBoardKeyType.Rotator then
        return uSkillMgrComp:GetValueAsRotator(nSkillID, sKey)
      elseif eType == UEnums.EBlackBoardKeyType.WeakObject then
        return uSkillMgrComp:GetValueAsWeakObject(nSkillID, sKey)
      end
    else
      sandbox.LogError("GetSkillBlackboardValue uSkillMgrComp inValid!")
    end
  else
    sandbox.LogError("GetSkillBlackboardValue uPlayerCharacter inValid!")
  end
  return nil
end
function Game:HasSkillBlackboardKey(uPawn, nSkillID, eType, sKey)
  if Game:IsValid(uPawn) and uPawn.GetSkillManager then
    local uSkillMgrComp = uPawn:GetSkillManager()
    if Game:IsValid(uSkillMgrComp) then
      if eType == UEnums.EBlackBoardKeyType.Object then
        return uSkillMgrComp:IsExistObject(nSkillID, sKey)
      elseif eType == UEnums.EBlackBoardKeyType.Class then
        return uSkillMgrComp:IsExistClass(nSkillID, sKey)
      elseif eType == UEnums.EBlackBoardKeyType.Enum then
        return uSkillMgrComp:IsExistEnum(nSkillID, sKey)
      elseif eType == UEnums.EBlackBoardKeyType.Int then
        return uSkillMgrComp:IsExistInt(nSkillID, sKey)
      elseif eType == UEnums.EBlackBoardKeyType.Float then
        return uSkillMgrComp:IsExistFloat(nSkillID, sKey)
      elseif eType == UEnums.EBlackBoardKeyType.Bool then
        return uSkillMgrComp:IsExistBool(nSkillID, sKey)
      elseif eType == UEnums.EBlackBoardKeyType.String then
        return uSkillMgrComp:IsExistString(nSkillID, sKey)
      elseif eType == UEnums.EBlackBoardKeyType.Name then
        return uSkillMgrComp:IsExistName(nSkillID, sKey)
      elseif eType == UEnums.EBlackBoardKeyType.Vector then
        return uSkillMgrComp:IsExistVector(nSkillID, sKey)
      elseif eType == UEnums.EBlackBoardKeyType.Rotator then
        return uSkillMgrComp:IsExistRotator(nSkillID, sKey)
      end
    else
      sandbox.LogError("HasSkillBlackboardKey uSkillMgrComp inValid!")
    end
  else
    sandbox.LogError("HasSkillBlackboardKey uPlayerCharacter inValid!")
  end
  return false
end
function Game:DynamicAddSkill(uCharacter, nSkillID)
  if Game:IsValid(uCharacter) then
    CGame:DynamicAddSkill(uCharacter, nSkillID)
  end
end
function Game:DynamicRemoveSkill(uCharacter, nSkillID)
  if Game:IsValid(uCharacter) then
    CGame:DynamicRemoveSkill(uCharacter, nSkillID)
  end
end
function Game:TryAddOneSkill(uCharacter, nSkillID, bActive, nButtonSlot)
  if Game:IsValid(uCharacter) then
    if bActive == nil then
      bActive = true
    end
    if nButtonSlot == nil then
      nButtonSlot = 0
    end
    CGame:TryAddOneSkill(uCharacter, nSkillID, bActive, nButtonSlot)
  end
end
function Game:TryDeleteOneSkill(uCharacter, nSkillID, bIsImmediately)
  if Game:IsValid(uCharacter) then
    if bIsImmediately == nil then
      bIsImmediately = true
    end
    CGame:TryDeleteOneSkill(uCharacter, nSkillID, bIsImmediately)
  end
end
function Game:GetSkillButtonSlot(uCharacter, nSkillID)
  if Game:IsValid(uCharacter) and uCharacter.GetSkillManager then
    local uSkillManager = uCharacter:GetSkillManager()
    if slua.isValid(uSkillManager) then
      return uSkillManager:GetSkillButtonSlot(nSkillID)
    end
  end
  return 0
end
function Game:GetButtonSlotSkillID(uCharacter, nButtonSlot)
  if Game:IsValid(uCharacter) and uCharacter.GetSkillManager then
    local uSkillManager = uCharacter:GetSkillManager()
    if 0 < nButtonSlot and slua.isValid(uSkillManager) then
      return uSkillManager:GetButtonSlotSkillID(nButtonSlot)
    end
  end
  return 0
end
function Game:GetValidAppearPos(uWorldContextObject, Origin, fNavigableRadius, fCapsuleRadius, fCapsuleHalfHeight, IgnoreActors, TraceStep)
  if Game:IsValid(uWorldContextObject) then
    return CGame:GetValidAppearPos(uWorldContextObject, Origin, fNavigableRadius, fCapsuleRadius, fCapsuleHalfHeight, IgnoreActors, TraceStep)
  end
  return nil
end
function Game:ExecuteAirAttack(ConfigTable)
  local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
  local AirAttackActor = ActorTools.SpawnActor(CGameMode, "/Game/BluePrints/Environment/AirAttackActor.AirAttackActor", FVector(1, 1, 1), FRotator(0, 0, 0), FVector(1, 1, 1))
  local AirAttackConfig = import("AirAttackOuterConfig")
  local FAirAttackConfig = AirAttackConfig()
  for k, v in pairs(ConfigTable) do
    FAirAttackConfig[k] = v
  end
  Game:SetTimer(0.0, false, function()
    Game:SetAirAttack(AirAttackActor, FAirAttackConfig)
  end)
  return AirAttackActor
end
function Game:GetAIPlayerBackpackItems(InController)
  return CGame:GetAIPlayerBackpackItems(InController)
end
function Game:SyncLoadNavData(InAreaID, InOffset, IsRandomLoc)
  local uMultiNavComp = CGameMode and CGameMode:FindOrCreateMultiNavComponent() or nil
  if Game:IsValid(uMultiNavComp) then
    return uMultiNavComp:SyncLoadNavData(InAreaID, InOffset, IsRandomLoc)
  end
  return false
end
function Game:SyncLoadNavDataWithParam(InParam)
  local uMultiNavComp = CGameMode and CGameMode:FindOrCreateMultiNavComponent() or nil
  if not Game:IsValid(uMultiNavComp) then
    return false
  end
  return uMultiNavComp:SyncLoadNavDataWithParam(InParam)
end
function Game:DestroyAIController(InController)
  return CGame:DestroyAIController(InController)
end
function Game:IsContainInTable(tTable, Element)
  if tTable and Element then
    for index, value in ipairs(tTable) do
      if value == Element then
        return true
      end
    end
  end
  return false
end
function Game:AddToRegionBasedNetConsideration(AUAENetActor, bAddToRegionManager, bStatic)
  if bStatic == nil then
    bStatic = true
  end
  return CGame:AddToRegionBasedNetConsideration(AUAENetActor, bAddToRegionManager, bStatic)
end
function Game:GetNetGUID(NetObject, UseDemoDriver)
  if UseDemoDriver == nil then
    UseDemoDriver = false
  end
  return CGame:GetNetGUID(NetObject, UseDemoDriver)
end
function Game:TriggerMovementComponentsTick(ParentActor, bEnable)
  if slua.isValid(ParentActor) then
    local MovementComonentClass = import("MovementComponent")
    local uComponentsArray = ParentActor:GetComponentsByClass(MovementComonentClass)
    if uComponentsArray then
      for i = 0, uComponentsArray:Num() - 1 do
        local Comp = uComponentsArray:Get(i)
        if self:IsValid(Comp) then
          Comp:SetComponentTickEnabled(bEnable)
        end
      end
    end
  end
end
function Game:HideOrDestroyAllAttach(uSceneComponent)
  if not slua.isValid(uSceneComponent) then
    return
  end
  local OwnerActor = uSceneComponent:GetOwner()
  if slua.isValid(OwnerActor) then
    local ActorComponentClass = import("ActorComponent")
    local ChildrenComps = uSceneComponent:GetChildrenComponents(false, slua.Array(UEnums.EPropertyClass.Object, ActorComponentClass))
    if OwnerActor:HasAuthority() then
      local PickUpWrapperClass = import("/Script/ShadowTrackerExtra.PickUpWrapperActor")
      local PlayerTombBoxClass = import("/Script/ShadowTrackerExtra.PlayerTombBox")
      local IdeaDecalActorClass = import("IdeaDecalActor")
      for _, uComp in pairs(ChildrenComps) do
        if slua.isValid(uComp) then
          local uActor = uComp:GetOwner()
          if slua.isValid(uActor) and (Game:IsClassOf(uActor, PickUpWrapperClass) or Game:IsClassOf(uActor, PlayerTombBoxClass) or Game:IsClassOf(uActor, IdeaDecalActorClass) or uActor.bDestroyWithParent == true) then
            uActor:K2_DestroyActor()
          end
        end
      end
    else
      local IdeaDecalActorClass = import("IdeaDecalActor")
      local ParticleSystemComponentClass = import("/Script/Engine.ParticleSystemComponent")
      for _, uComp in pairs(ChildrenComps) do
        if slua.isValid(uComp) then
          if Game:IsClassOf(uComp, ParticleSystemComponentClass) and uComp:ComponentHasTag("ImpactFX") then
            uComp:SetHiddenInGame(true, false)
          end
          local uActor = uComp:GetOwner()
          if slua.isValid(uActor) and Game:IsClassOf(uActor, IdeaDecalActorClass) then
            uActor:StopPlayEvent()
          end
        end
      end
    end
  end
end
function Game:TryAttachToMoveablePlatForm(uSceneComponent, TraceLength)
  if not slua.isValid(uSceneComponent) then
    return false
  end
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local ECollisionChannel = import("ECollisionChannel")
  local TraceStart = uSceneComponent:K2_GetComponentLocation()
  local bHit, TraceResult = UKismetSystemLibrary.LineTraceSingleForObjects(uSceneComponent, TraceStart, TraceStart + FVector(0, 0, -TraceLength), {
    Game:ConvertToObjectType(ECollisionChannel.ECC_WorldStatic)
  }, true, {
    uSceneComponent:GetOwner()
  }, 0, nil, true, FLinearColor.Red, FLinearColor.Green, 1)
  if bHit then
    local uHitComponent = TraceResult.Component
    if slua.isValid(uHitComponent) and uHitComponent:ComponentHasTag("MoveablePlatform") then
      print(bWriteLog and string.format("Game:TryAttachToMoveablePlatForm Attach %s,%s to %s,%s", uSceneComponent, uSceneComponent:GetOwner(), uHitComponent, TraceResult.Actor))
      local EAttachmentRule = import("EAttachmentRule")
      uSceneComponent:K2_AttachToComponent(uHitComponent, "None", EAttachmentRule.KeepWorld, EAttachmentRule.KeepWorld, EAttachmentRule.KeepWorld, true)
      return true
    end
  end
  return false
end
function Game:IsFightingState()
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) and uGameState.GetGameModeState then
    return uGameState:GetGameModeState() == "FightingState"
  end
  return false
end
function Game:PointIsInSpecifiedArea(Point, AreaAnchors)
  return CGame:PointIsInSpecifiedArea(Point, AreaAnchors)
end
function Game:GenerateItemOnGround(PlayerCharacter, ItemID, ItemCount)
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local ItemDropMgrComponentClass = import("ItemDropMgrComponent")
  local uItemDropMgrComp = CGameMode:GetComponentByClass(ItemDropMgrComponentClass)
  if not slua.isValid(uItemDropMgrComp) then
    return
  end
  uItemDropMgrComp:GenerateItemOnGround(PlayerCharacter, ItemID, ItemCount)
  print(bWriteLog and string.format("Game:GenerateItemOnGround Item:%d Count:%d", ItemID, ItemCount))
end
function Game:DropToTargetOrGround(PlayerCharacter, ItemID, ItemCount)
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local ItemDropMgrComponentClass = import("ItemDropMgrComponent")
  local uItemDropMgrComp = CGameMode:GetComponentByClass(ItemDropMgrComponentClass)
  if not slua.isValid(uItemDropMgrComp) then
    return
  end
  uItemDropMgrComp:DropToTargetOrGround(PlayerCharacter, ItemID, ItemCount)
  print(bWriteLog and string.format("Game:DropToTargetOrGround Item:%d Count:%d", ItemID, ItemCount))
end
function Game:GetnerateItemAtTrans(ItemID, ItemCount, Trans)
  if not CGameMode then
    print(bWriteLog and "Game:GetnerateItemAtLoc invaild CGameMode")
    return
  end
  local ItemDropMgrComponentClass = import("ItemDropMgrComponent")
  local uItemDropMgrComp = CGameMode:GetComponentByClass(ItemDropMgrComponentClass)
  if not slua.isValid(uItemDropMgrComp) then
    return
  end
  uItemDropMgrComp:GenerateItemAtTrans(ItemID, ItemCount, Trans)
  print(bWriteLog and string.format("Game:GetnerateItemAtTrans Item:%d Count:%d", ItemID, ItemCount))
end
function Game:Contains(Array, ItemToFind)
  if not Array or not ItemToFind then
    return nil
  end
  for i = 0, Array:Num() - 1 do
    if Array:Get(i) == ItemToFind then
      return i
    end
  end
  return nil
end
function Game:IsNearlyZero(fValue, fTolerance)
  if fTolerance == nil then
    fTolerance = 1.0E-4
  end
  return fTolerance >= math.abs(fValue)
end
function Game:GetReadyTimeBeforePlane()
  local ReadyTime = 0
  if CGameMode then
    ReadyTime = CGameMode.GameModeStateReady.StateTime
    local ActualTime = CGameMode.GameModeStateReady.ExitStateTime - CGameMode.GameModeStateReady.EnterStateTime
    if 0 < ActualTime and ReadyTime > ActualTime then
      ReadyTime = ActualTime
    end
    if CGameMode.GameModeStateActive and 0 <= CGameMode.GameModeStateActive.EnterStateTime and 0 < CGameMode.GameModeStateReady.EnterStateTime then
      ReadyTime = ReadyTime + CGameMode.GameModeStateReady.EnterStateTime - CGameMode.GameModeStateActive.EnterStateTime
    end
  else
    print(bWriteLog and "Game:GetReadyTimeBeforePlane, CGameMode = nil")
  end
  print(bWriteLog and "Game:GetReadyTimeBeforePlane, ReadyTime = " .. tostring(ReadyTime))
  return ReadyTime
end
function Game:CompareVersion(TargetVersion, LowOrHigh)
  local CurVersion
  if Server and Server.GetDSAppVersion then
    CurVersion = Server.GetDSAppVersion()
  else
    CurVersion = "2.8.0.12345"
    print(bWriteLog and "Game:CompareVersion, with hard code version = " .. tostring(CurVersion))
  end
  if CurVersion and CurVersion ~= "" then
    local CompareStr = ""
    local Count = 0
    for str in string.gmatch(CurVersion, "%d+") do
      CompareStr = CompareStr .. str
      Count = Count + 1
      if Count < 3 then
        CompareStr = CompareStr .. "."
      else
        break
      end
    end
    local StrSplit = function(str, sep)
      local result = {}
      if str == nil or sep == nil or type(str) ~= "string" or type(sep) ~= "string" then
        return result
      end
      if #str == 0 or #sep == 0 then
        return result
      end
      local pattern = string.format("[^%s]*", sep)
      string.gsub(str, pattern, function(c)
        result[#result + 1] = tonumber(c)
      end)
      return result
    end
    local VerTable1 = StrSplit(CompareStr, ".")
    local VerTable2 = StrSplit(TargetVersion, ".")
    local CompareByIndex = function(index)
      local ver1 = VerTable1[index]
      local ver2 = VerTable2[index]
      if ver1 == nil and ver2 == nil then
        return 0
      end
      if ver1 == nil then
        return -1
      end
      if ver2 == nil then
        return 1
      end
      if ver1 == ver2 then
        return 0
      else
        return ver1 > ver2 and 1 or -1
      end
    end
    local Ver1Result = CompareByIndex(1)
    local Ver2Result = CompareByIndex(2)
    local Ver3Result = CompareByIndex(3)
    local GetCompareResult = function()
      if Ver1Result ~= 0 then
        return Ver1Result
      elseif Ver2Result ~= 0 then
        return Ver2Result
      elseif Ver3Result ~= 0 then
        return Ver3Result
      end
      return 0
    end
    if LowOrHigh == false then
      local Result = GetCompareResult()
      if 0 <= Result then
        return true
      else
        return false
      end
    else
      do
        local Result = GetCompareResult()
        if Result <= 0 then
          return true
        else
          return false
        end
      end
    end
  end
  return false
end
function Game:NeedReport(ActionType, Param1, Param2, Param3)
  local AbstractEvents = CDataTable.GetTable("AbstractEvents")
  for ID, Config in pairs(AbstractEvents) do
    if ActionType == Config.ActionType and Param1 == Config.Param1 and Param2 == Config.Param2 and Param3 == Config.Param3 then
      local EnabledByModeId = true
      if Config.SubModeId and Config.SubModeId ~= "" then
        EnabledByModeId = false
        local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
        local CurSubModeId = GameMainConfig.GetModeID()
        if CurSubModeId then
          local TableString = "return " .. Config.SubModeId
          local SubModeIdTable = load(TableString)()
          for k, v in pairs(SubModeIdTable) do
            if CurSubModeId == tonumber(v) then
              EnabledByModeId = true
              break
            end
          end
        end
      end
      local EnabledByLowVersion = true
      if Config.LowVersion and Config.LowVersion ~= "" then
        EnabledByLowVersion = false
        if self:CompareVersion(Config.LowVersion, false) then
          EnabledByLowVersion = true
        end
      end
      local EnabledByHighVersion = true
      if Config.HighVersion and Config.HighVersion ~= "" then
        EnabledByHighVersion = false
        if self:CompareVersion(Config.HighVersion, true) then
          EnabledByHighVersion = true
        end
      end
      local Result = EnabledByModeId and EnabledByLowVersion and EnabledByHighVersion
      if Result == false then
        print(bWriteLog and "Game:NeedReport, ActionType = " .. tostring(ActionType) .. ", Param1 = " .. tostring(Param1) .. ", Param2 = " .. tostring(Param2) .. ", Param3 = " .. tostring(Param3) .. ", SubModeId = " .. tostring(Config.SubModeId) .. ", LowVersion = " .. tostring(Config.LowVersion) .. ", HighVersion = " .. tostring(Config.HighVersion) .. ", Return false")
      end
      return Result, Config.EventsID
    end
  end
  print(bWriteLog and "Game:NeedReport, ActionType = " .. tostring(ActionType) .. ", Param1 = " .. tostring(Param1) .. ", Param2 = " .. tostring(Param2) .. ", Param3 = " .. tostring(Param3) .. ", Return false")
  return false
end
function Game:IsEnableUIStateRefreshFlag()
  return true
end
function Game:MakeStrPrivate(str, head, tail)
  if not head or head < 0 then
    head = 1
  end
  if not tail or tail < 0 then
    tail = 1
  end
  local strLen = #str
  if strLen <= head + tail then
    return str
  end
  return string.format("%s%s%s", head == 0 and "" or string.sub(str, 1, head), string.rep("*", strLen - head - tail), tail == 0 and "" or string.sub(str, -tail))
end
function Game:GetActorGridGenerator()
  if Client or not CGameMode then
    return nil
  end
  print(bWriteLog and "Game:GetActorGridGenerator ")
  local ActorGridGeneratorClass = import("ActorGridGeneratorComponent")
  local uActorGridGenerator = CGameMode:GetComponentByClass(ActorGridGeneratorClass)
  if not slua.isValid(uActorGridGenerator) then
    if CGameMode.ActorGridGeneratorClassPath and CGameMode.ActorGridGeneratorClassPath ~= "" then
      print(bWriteLog and "Game:GetActorGridGenerator use CGameMode.ActorGridGeneratorClassPath:" .. CGameMode.ActorGridGeneratorClassPath)
      ActorGridGeneratorClass = import(CGameMode.ActorGridGeneratorClassPath)
    else
      local DefaultPath = "/Game/Mod/EvoBase/BluePrints/Component/BP_ActorGridGenerator.BP_ActorGridGenerator_C"
      print(bWriteLog and "Game:GetActorGridGenerator use DefaultPath:" .. DefaultPath)
      ActorGridGeneratorClass = import(DefaultPath)
    end
    uActorGridGenerator = Game:AddComponent(ActorGridGeneratorClass, CGameMode, "BP_ActorGridGenerator")
  end
  return uActorGridGenerator
end
function Game:TryGetValidLocation(WorldObj, SpawnLocation, HalfSize, bNotTraceGround, TryTimes, TryDir, TraceChannel, TryRotation, StartOffectVec, EndOffsetVec)
  if not (slua.isValid(WorldObj) and SpawnLocation) or not HalfSize then
    print(bWriteLog and "Game:TryGetValidLocation WorldObj:", slua.isValid(WorldObj), " SpawnLocation:", SpawnLocation == nil, " HalfSize:", HalfSize == nil)
    return nil
  end
  TryTimes = TryTimes or 9
  bNotTraceGround = bNotTraceGround or false
  TraceChannel = TraceChannel or 3
  TryRotation = TryRotation or FRotator(0, 0, 0)
  StartOffectVec = StartOffectVec or FVector(0, 0, 0)
  EndOffsetVec = EndOffsetVec or FVector(0, 0, 0)
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local Pawn_C = import("/Script/Engine.Pawn")
  local TryLocation = FVector(SpawnLocation.X, SpawnLocation.Y, SpawnLocation.Z)
  local bHit, uHitResults, RayStart, RayEnd
  for index = 1, TryTimes do
    if not bNotTraceGround then
      TryLocation = Game:GetGroundLocation(TryLocation + StartOffectVec, EndOffsetVec.Z - StartOffectVec.Z) + FVector(0, 0, HalfSize.Z)
    else
      TryLocation = TryLocation + FVector(0, 0, HalfSize.Z)
    end
    RayStart = TryLocation + StartOffectVec
    RayEnd = TryLocation + EndOffsetVec
    bHit, uHitResults = UKismetSystemLibrary.BoxTraceMulti(WorldObj, RayStart, RayEnd, HalfSize, TryRotation, TraceChannel, true, nil, 0, uHitResults, true, FLinearColor.Red, FLinearColor.Green, 1)
    local ValidPoint = true
    if bHit and uHitResults then
      for key, value in pairs(uHitResults) do
        if value and value.Actor and Game:IsClassOf(value.Actor, Pawn_C) then
          ValidPoint = false
          break
        end
      end
    end
    print(bWriteLog and "Game:TryGetValidLocation bHit = ", bHit, " index =", index, " ValidPoint = ", ValidPoint, " TryLocation = ", TryLocation:ToString())
    if ValidPoint then
      return TryLocation - FVector(0, 0, HalfSize.Z)
    elseif not TryDir then
      local row = math.floor(index / 3) - 1
      local col = index % 3 - 1
      TryLocation = SpawnLocation + FVector(HalfSize.X * row * 2, HalfSize.Y * col * 2, 0)
    else
      TryLocation = TryLocation + TryDir
    end
  end
  return nil
end
function Game:TryGetValidLocationWithFullCollision(WorldObj, SpawnLocation, BoxExtent, TryTimes, TryDir, BlockingChannels, bNotTraceGround, TryRotation, IgnoreActors)
  if not (slua.isValid(WorldObj) and SpawnLocation) or not BoxExtent then
    print(bWriteLog and "Game:TryGetValidLocationWithFullCollision - Invalid parameters: WorldObj:", slua.isValid(WorldObj), " SpawnLocation:", SpawnLocation == nil, " BoxExtent:", BoxExtent == nil)
    return nil
  end
  TryTimes = TryTimes or 9
  bNotTraceGround = bNotTraceGround or false
  TryRotation = TryRotation or FRotator(0, 0, 0)
  IgnoreActors = IgnoreActors or {}
  if not BlockingChannels or #BlockingChannels == 0 then
    local ECollisionChannel = import("ECollisionChannel")
    BlockingChannels = {
      Game:ConvertToObjectType(ECollisionChannel.ECC_Pawn),
      Game:ConvertToObjectType(ECollisionChannel.ECC_Vehicle),
      Game:ConvertToObjectType(ECollisionChannel.ECC_WorldStatic),
      Game:ConvertToObjectType(ECollisionChannel.ECC_WorldDynamic)
    }
  end
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local TryLocation = FVector(SpawnLocation.X, SpawnLocation.Y, SpawnLocation.Z)
  for index = 1, TryTimes do
    if not bNotTraceGround then
      TryLocation = Game:GetGroundLocation(TryLocation, 1000) + FVector(0, 0, BoxExtent.Z + 100)
    else
      TryLocation = TryLocation + FVector(0, 0, BoxExtent.Z + 100)
    end
    local bOverlap, OverlapResults = UKismetSystemLibrary.BoxOverlapActors(WorldObj, TryLocation, BoxExtent, BlockingChannels, nil, IgnoreActors, OverlapResults)
    local ValidPoint = not bOverlap
    if bOverlap then
      print(bWriteLog and "Game:TryGetValidLocationWithFullCollision - Location blocked, found %d overlapping objects")
    end
    print(bWriteLog and string.format("Game:TryGetValidLocationWithFullCollision - index: %d, ValidPoint: %s, Location: %s", index, tostring(ValidPoint), TryLocation:ToString()))
    if ValidPoint then
      return TryLocation - FVector(0, 0, BoxExtent.Z)
    elseif not TryDir then
      local row = math.floor(index / 3) - 1
      local col = index % 3 - 1
      TryLocation = SpawnLocation + FVector(BoxExtent.X * row / 2, BoxExtent.Y * col / 2, 0)
    else
      TryLocation = TryLocation + TryDir
    end
  end
  print(bWriteLog and "Game:TryGetValidLocationWithFullCollision - Failed to find valid location after all attempts")
  return nil
end
function Game:IsPerformanceLimitedStat()
  if not Client then
    return false
  end
  return Client.IsPerformanceLimitedStat()
end
function Game:IsSupportVerySmooth()
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local devicegrade = Client.GetTCDeviceLevel()
  local STExtraGameInstance = import("STExtraGameInstance")
  local gameInstance = STExtraGameInstance.GetInstance()
  local VerySmoothDeviceWhiteList = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("r.GDeviceSupportVerySmooth")
  local deviceLevel = gameInstance:GetExactDeviceLevel() or 0
  print(bWriteLog and "IsSupportVerySmooth: deviceLevel = " .. tostring(deviceLevel), " VerySmoothDeviceWhiteList = ", tostring(VerySmoothDeviceWhiteList))
  if 0 < VerySmoothDeviceWhiteList then
    return true
  end
  return true
end
function Game:UpdatePickupActorLocation(uLoc, nRange, nDistance, nNewTraceEndOffsetZ)
  if slua.isValid(CGameState) and uLoc then
    if nRange == nil then
      nRange = 0
    end
    local nDistSquared = 0
    if nDistance then
      nDistSquared = nDistance * nDistance
    end
    local AreadyHandleMap = {}
    local PickUpWrapperClass = import("/Script/ShadowTrackerExtra.PickUpWrapperActor")
    local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    local PickUpActorList = USTExtraBlueprintFunctionLibrary.LuaGetStaticObjectsInRegion(CGameState, PickUpWrapperClass, uLoc, 0, nRange)
    local HandleNum = 0
    local UpdateLocation = function(PickUpActorList)
      for _, PickUpActor in pairs(PickUpActorList) do
        if slua.isValid(PickUpActor) and PickUpActor.UpdateLocation and not AreadyHandleMap[PickUpActor] then
          local CachedTraceEndOffsetZ = PickUpActor.TraceEndOffsetZ
          if nNewTraceEndOffsetZ and type(nNewTraceEndOffsetZ) == "number" then
            PickUpActor.TraceEndOffsetZ = nNewTraceEndOffsetZ
          end
          if nDistance then
            local nTmpDist = FVector.DistSquared(uLoc, PickUpActor:K2_GetActorLocation())
            if nTmpDist <= nDistSquared then
              PickUpActor:UpdateLocation(false)
            end
          else
            PickUpActor:UpdateLocation(false)
          end
          PickUpActor.TraceEndOffsetZ = CachedTraceEndOffsetZ
          AreadyHandleMap[PickUpActor] = true
          HandleNum = HandleNum + 1
        end
      end
    end
    printf("Game:UpdatePickupActorLocation at %s, nRange = %d, nDistance = %d, nNewTraceEndOffsetZ = %s", uLoc:ToString(), nRange, nDistance, nNewTraceEndOffsetZ)
    local NetDriverNum = 0
    local GlobalPickupMgrNum = 0
    if PickUpActorList then
      NetDriverNum = PickUpActorList:Num()
      UpdateLocation(PickUpActorList)
    end
    if slua.isValid(CGameState.GlobalPickupManagerComponent) and CGameState.GlobalPickupManagerComponent.GetServerPickupsInRange then
      local NotReplicatePickUps = {}
      NotReplicatePickUps = CGameState.GlobalPickupManagerComponent:GetServerPickupsInRange(uLoc, nRange, NotReplicatePickUps)
      if NotReplicatePickUps and 0 < NotReplicatePickUps:Num() then
        GlobalPickupMgrNum = NotReplicatePickUps:Num()
        UpdateLocation(NotReplicatePickUps)
      end
    end
    printf("Game:UpdatePickupActorLocation NetDriverNum = %d, GlobalPickupMgrNum = %d, HandleNum = %d", NetDriverNum, GlobalPickupMgrNum, HandleNum)
  end
end
function Game:UpdateDeadBoxLocation(uLoc, nRange, nDistance, nNewTraceEndOffsetZ)
  if slua.isValid(CGameState) and uLoc then
    if nRange == nil then
      nRange = 0
    end
    local nDistSquared = 0
    if nDistance then
      nDistSquared = nDistance * nDistance
    end
    local PlayerTombBoxClass = import("/Script/ShadowTrackerExtra.PlayerTombBox")
    local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    local PlayerTombBoxList = USTExtraBlueprintFunctionLibrary.LuaGetStaticObjectsInRegion(CGameState, PlayerTombBoxClass, uLoc, 1, nRange)
    if PlayerTombBoxList then
      for _, uPlayerTombBox in pairs(PlayerTombBoxList) do
        if slua.isValid(uPlayerTombBox) and uPlayerTombBox.UpdateLocation then
          local CachedTraceEndOffsetZ = uPlayerTombBox.TraceEndOffsetZ
          if nNewTraceEndOffsetZ and type(nNewTraceEndOffsetZ) == "number" then
            uPlayerTombBox.TraceEndOffsetZ = nNewTraceEndOffsetZ
          end
          if nDistance then
            local nTmpDist = FVector.DistSquared(uLoc, uPlayerTombBox:K2_GetActorLocation())
            if nDistSquared >= nTmpDist then
              uPlayerTombBox:UpdateLocation(false)
            end
          else
            uPlayerTombBox:UpdateLocation(false)
          end
          uPlayerTombBox.TraceEndOffsetZ = CachedTraceEndOffsetZ
        end
      end
    end
  end
end
function Game:SetShowPawnAvatarFromPlayerKey(uShowPawn, nPlayerKey, AllMeshLoadedBack, tCopyOption)
  local uPawn = GameplayData.GetPlayerCharacter(nPlayerKey)
  local bHideHelmet = false
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if SettingConfig and SettingConfig.LocalHideHelmet == true then
    bHideHelmet = true
  end
  if slua.isValid(uPawn) and slua.isValid(uShowPawn) then
    uShowPawn.ForceUseDefaultIdle = true
    if slua.isValid(uShowPawn.Mesh) and slua.isValid(uShowPawn.Mesh:GetAnimInstance()) then
      uShowPawn.Mesh:GetAnimInstance():SetForceUseIdle(true)
    end
    local CharacterAvartarCom = uShowPawn.CharacterAvatarComp2_BP
    local AvatarComp = uPawn:getAvatarComponent2()
    if slua.isValid(AvatarComp) and slua.isValid(CharacterAvartarCom) then
      CharacterAvartarCom.bSyncAvatar = false
      local Gender = uPawn:GetGender()
      local uCurrentPlayer = GameplayData.GetPlayerCharacter()
      local bRealHideHelmet = slua.isValid(uCurrentPlayer) and uPawn == uCurrentPlayer and bHideHelmet
      local CopyOption = tCopyOption
      if CopyOption == nil then
        if not bRealHideHelmet then
          CopyOption = {9}
        end
      elseif type(CopyOption) == "table" and bRealHideHelmet then
        local FilteredOption = {}
        for _, SlotID in ipairs(CopyOption) do
          if SlotID ~= 9 then
            FilteredOption[#FilteredOption + 1] = SlotID
          end
        end
        CopyOption = FilteredOption
      end
      CharacterAvartarCom.NetAvatarData = Game:CopyNetAvatarDataToLobbyPawn(AvatarComp, CopyOption)
      CharacterAvartarCom:SetAvatarGender(Gender)
      CharacterAvartarCom:OnRep_BodySlotStateChanged()
    end
    local CharacterAvartarComp = uShowPawn.CharacterAvatarComp2_BP
    if slua.isValid(CharacterAvartarComp) then
      uShowPawn:AddControlEvent(CharacterAvartarComp, "OnAvatarAllMeshLoaded", function()
        if slua.isValid(CharacterAvartarComp) then
          local ClothMesh = CharacterAvartarComp:GetMeshCompBySlotID(5)
          if slua.isValid(ClothMesh) then
            local AnimInstance = ClothMesh:GetAnimInstance()
            if slua.isValid(AnimInstance) and AnimInstance.SetForceIgnoreBoneRetarget then
              AnimInstance:SetForceIgnoreBoneRetarget(true)
              print(bWriteLog and "Game:SetShowPawnAvatarFromPlayerKey ForceIgnoreBoneRetarget")
            end
          end
          uShowPawn:RemoveControlEvent(CharacterAvartarComp, "OnAvatarAllMeshLoaded")
          if AllMeshLoadedBack then
            AllMeshLoadedBack(nPlayerKey)
          end
        end
      end)
    end
  end
end
function Game:CopyNetAvatarDataToLobbyPawn(uCharacterAvatarComponent, tCopyOption)
  local KeepSlotIDs
  if type(tCopyOption) == "table" then
    KeepSlotIDs = {}
    for _, SlotID in ipairs(tCopyOption) do
      KeepSlotIDs[SlotID] = true
    end
  end
  if slua.isValid(uCharacterAvatarComponent) then
    local TemData = uCharacterAvatarComponent.NetAvatarData:clone()
    for Index, SlotData in pairs(TemData.SlotSyncData) do
      if SlotData and SlotData.ItemID ~= 0 then
        if SlotData.SlotID > 16 and SlotData.SlotID <= 21 or SlotData.SlotID == 15 or SlotData.SlotID == 11 or SlotData.SlotID == 8 or SlotData.SlotID == 9 or SlotData.SlotID == 10 then
          if not KeepSlotIDs or not KeepSlotIDs[SlotData.SlotID] then
            local TempSingle = SlotData:clone()
            TempSingle.ItemID = 0
            TemData.SlotSyncData:Set(Index, TempSingle)
          end
        elseif 0 < SlotData.ForceHideState and (SlotData.SlotID == 2 or SlotData.SlotID == 3 or SlotData.SlotID == 5) then
          local TempSingle = SlotData:clone()
          TempSingle.ForceHideState = 0
          TemData.SlotSyncData:Set(Index, TempSingle)
        end
      end
    end
    return TemData
  end
  return import("NetAvatarSyncData")()
end
function Game:IsInReplayBack()
  if not CGameState then
    print(bWriteLog and "Game:IsInReplayBack, return false because CGameState is nil")
    return false
  end
  local GameplayStatics = import("GameplayStatics")
  local uGameInstance = GameplayStatics.GetGameInstance(CGameState)
  if uGameInstance then
    local uWonderfulPlayback = uGameInstance:GetWonderfulPlayback()
    if slua.isValid(uWonderfulPlayback) and uWonderfulPlayback:IsInPlayState() then
      print(bWriteLog and "Game:IsInReplayBack, In WonderfulPlayback")
      return true
    end
    local uDeathPlayback = uGameInstance:GetDeathPlayback()
    if slua.isValid(uDeathPlayback) and uDeathPlayback:IsInPlayState() then
      print(bWriteLog and "Game:IsInReplayBack, In DeathPlayback")
      return true
    end
  end
  return false
end
function Game:CGameDuplicateActor(SourceObj, AimObj, AimName, NeedRegisterAllComponents)
  local uObject = CGame:CGameDuplicateActor(SourceObj, AimObj, AimName, NeedRegisterAllComponents)
  return uObject
end
function Game:GetTeammatePlayerStateByOpenID(sOpenID)
  local uPlayerState = GameplayData.GetPlayerState()
  if slua.isValid(uPlayerState) then
    local uTeammatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, false)
    for _, uTeammatePlayerState in pairs(uTeammatePlayerStateList) do
      if slua.isValid(uTeammatePlayerState) and uTeammatePlayerState.OpenID == sOpenID then
        print(bWriteLog and "Game:GetTeammatePlayerStateByOpenID, uTeammatePlayerState.OpenID = ", uTeammatePlayerState.OpenID)
        return uTeammatePlayerState
      end
    end
  end
  return nil
end
function Game:ChangeCharacterTPPAvatar(uPlayer, bEnable)
  if not Client then
    return
  end
  if not slua.isValid(uPlayer) then
    return
  end
  print(bWriteLog and "ChangeCharacterTPPAvatar:bEnable")
  if not bEnable then
    uPlayer:SetPawnStateDisabled(EPawnState.SwitchPP, bEnable)
  end
  local EPhysBodyOp = import("EPhysBodyOp")
  local EAvatarSlotType = import("EAvatarSlotType")
  if bEnable and uPlayer:GetIsFPP() then
    uPlayer:SetCurrentPersonPerspective(false, true)
    if slua.isValid(uPlayer.Mesh) then
      uPlayer.Mesh:UnHideBoneByName("neck_01")
      local AvatarComp = uPlayer:getAvatarComponent2()
      if slua.isValid(AvatarComp) then
        AvatarComp:SetAvatarVisibility(EAvatarSlotType.EAvatarSlotType_HairEquipemtSlot, true, true)
        AvatarComp:SetAvatarVisibility(EAvatarSlotType.EAvatarSlotType_HatEquipemtSlot, true, true)
        AvatarComp:SetAvatarVisibility(EAvatarSlotType.EAvatarSlotType_FaceEquipemtSlot, true, true)
        AvatarComp:SetAvatarVisibility(EAvatarSlotType.EAvatarSlotType_BeardEquipemtSlot, true, true)
        AvatarComp:SetAvatarVisibility(EAvatarSlotType.EAvatarSlotType_HelmetEquipemtSlot, true, true)
        AvatarComp:SetAvatarVisibility(EAvatarSlotType.EAvatarSlotType_BackpackEquipemtSlot, true, true)
        AvatarComp:SetAvatarVisibility(EAvatarSlotType.EAvatarSlotType_ArmorEquipemtSlot, true, true)
        AvatarComp:SetAvatarVisibility(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot, true, true)
        AvatarComp:SetAvatarVisibility(EAvatarSlotType.EAvatarSlotType_GlassEquipemtSlot, true, true)
        AvatarComp:SetAvatarVisibility(EAvatarSlotType.EAvatarSlotType_NightVisionEquipemtSlot, true, true)
        local ClothMesh = AvatarComp:GetMeshCompBySlot(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
        if ClothMesh and slua.isValid(ClothMesh) then
          ClothMesh:UnHideBoneByName("neck_01")
        end
      end
    end
    self.bChangedPP = true
  end
  if not bEnable then
    if self.bChangedPP then
      if slua.isValid(uPlayer.Mesh) then
        uPlayer.Mesh:HideBoneByName("neck_01", EPhysBodyOp.PBO_None)
        local AvatarComp = uPlayer:getAvatarComponent2()
        if slua.isValid(AvatarComp) then
          AvatarComp:SetAvatarVisibility(EAvatarSlotType.EAvatarSlotType_HairEquipemtSlot, false, true)
          AvatarComp:SetAvatarVisibility(EAvatarSlotType.EAvatarSlotType_HatEquipemtSlot, false, true)
          AvatarComp:SetAvatarVisibility(EAvatarSlotType.EAvatarSlotType_FaceEquipemtSlot, false, true)
          AvatarComp:SetAvatarVisibility(EAvatarSlotType.EAvatarSlotType_BeardEquipemtSlot, false, true)
          AvatarComp:SetAvatarVisibility(EAvatarSlotType.EAvatarSlotType_HelmetEquipemtSlot, false, true)
          AvatarComp:SetAvatarVisibility(EAvatarSlotType.EAvatarSlotType_BackpackEquipemtSlot, false, true)
          AvatarComp:SetAvatarVisibility(EAvatarSlotType.EAvatarSlotType_ArmorEquipemtSlot, true, true)
          AvatarComp:SetAvatarVisibility(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot, true, true)
          AvatarComp:SetAvatarVisibility(EAvatarSlotType.EAvatarSlotType_GlassEquipemtSlot, false, true)
          AvatarComp:SetAvatarVisibility(EAvatarSlotType.EAvatarSlotType_NightVisionEquipemtSlot, false, true)
          local ClothMesh = AvatarComp:GetMeshCompBySlot(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
          if ClothMesh and slua.isValid(ClothMesh) then
            ClothMesh:HideBoneByName("neck_01", EPhysBodyOp.PBO_None)
          end
        end
      end
      uPlayer:SetCurrentPersonPerspective(true, false)
    end
    self.bChangedPP = false
  end
  if bEnable then
    uPlayer:SetPawnStateDisabled(EPawnState.SwitchPP, bEnable)
  end
end