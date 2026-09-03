local EPawnState = import("EPawnState")
local UGCCharacterAnimFeature = {}
function UGCCharacterAnimFeature:ctor()
  self.CreativeAnimParamsStr = ""
end
function UGCCharacterAnimFeature:_PostConstruct()
  UGCCharacterAnimFeature.__super._PostConstruct(self)
end
function UGCCharacterAnimFeature:ReceiveBeginPlay()
  print(bWriteLog and "UGCCharacterAnimFeature:ReceiveBeginPlay")
  UGCCharacterAnimFeature.__super.ReceiveBeginPlay(self)
  self.AllEPawnStates = self:_getAllEPawnStates()
end
function UGCCharacterAnimFeature:ReceiveEndPlay()
  print(bWriteLog and "UGCCharacterAnimFeature:ReceiveEndPlay")
  UGCCharacterAnimFeature.__super.ReceiveEndPlay(self)
end
function UGCCharacterAnimFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "CreativeAnimParamsStr",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Str
    }
  }
  if UGCCharacterAnimFeature.__super.GetLifetimeReplicatedProps then
    local BaseRepTable = UGCCharacterAnimFeature.__super.GetLifetimeReplicatedProps(self)
    table.move(BaseRepTable, 1, #BaseRepTable, #RepTable + 1, RepTable)
  end
  return RepTable
end
function UGCCharacterAnimFeature:OnRep_CreativeAnimParamsStr(OldLevel)
  printf(bWriteLog and "UGCCharacterAnimFeature:OnRep_CreativeAnimParamsStr ,CreativeAnimParamsStr = %s", self.CreativeAnimParamsStr)
  if self:HasAuthority() then
    return
  end
  if not (CGameState and CGameState.IsCreativeMode) or not CGameState:IsCreativeMode() then
    return
  end
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    print(bWriteLog and "UGCCharacterAnimFeature:OnRep_CreativeAnimParamsStr ,Owner or Object is nil")
    return
  end
  print(bWriteLog and "UGCCharacterAnimFeature:OnRep_CreativeAnimParamsStr ,CreativeAnimParamsStr = " .. self.CreativeAnimParamsStr .. ", PlayerKey = " .. tostring(self.Owner.Object.PlayerKey))
  self:HandleCreativeCharacterAnim(self.CreativeAnimParamsStr)
end
function UGCCharacterAnimFeature:HandleCreativeCharacterAnim(AnimParamsStr)
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    print(bWriteLog and "UGCCharacterAnimFeature:HandleCreativeCharacterAnim ,Owner or Object is nil")
    return
  end
  local uPlayerCharacter = self.Owner.Object
  print(bWriteLog and "UGCCharacterAnimFeature:HandleCreativeCharacterAnim, PlayerKey = " .. tostring(uPlayerCharacter.PlayerKey))
  local PBUtility = require("GameLua.Mod.CreativeBase.BinaryData.CreativeModePbUtility")
  if not PBUtility then
    print(bWriteLog and "UGCCharacterAnimFeature:HandleCreativeCharacterAnim PBUtility is nil")
    return
  end
  local AnimParams = PBUtility.StrToTable(AnimParamsStr)
  local CreativeModeCharacterAnimationUtility = require("GameLua.Mod.CreativeBase.Gameplay.Animation.CreativeModeCharacterAnimationUtility")
  if not CreativeModeCharacterAnimationUtility then
    print(bWriteLog and "UGCCharacterAnimFeature:HandleCreativeCharacterAnim CreativeModeCharacterAnimationUtility is nil")
    return
  end
  local CreativeAnimationSubsystem = SubsystemMgr:Get("CreativeAnimationSubsystem")
  if not CreativeAnimationSubsystem then
    print(bWriteLog and "UGCCharacterAnimFeature:HandleCreativeCharacterAnim CreativeAnimationSubsystem is nil")
    return
  end
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "UGCCharacterAnimFeature:HandleCreativeCharacterAnim Cant get uPlayerCharacter")
    return
  end
  local bWantToPlay = AnimParams.bWantToPlay
  if bWantToPlay ~= nil and bWantToPlay == false then
    self:StopAnimation(uPlayerCharacter, AnimParams)
    local uPlayEmoteComp = uPlayerCharacter:GetPlayEmoteComponent()
    if slua.isValid(uPlayEmoteComp) and uPlayEmoteComp.GetCurrentEmoteId then
      local nCurEmoteID = uPlayEmoteComp:GetCurrentEmoteId()
      if nCurEmoteID and 0 < nCurEmoteID then
        uPlayEmoteComp:LocalInteruptPlayEmote(nCurEmoteID)
      end
    end
    return
  end
  if bWantToPlay ~= nil and bWantToPlay == true then
    local OnStateChange = function(_, InCurStates, InPrevStates)
      local CurStatesBinary, CurStatesMap = self:_toBinary(InCurStates)
      local PrevStatesBinary, PrevStatesMap = self:_toBinary(InPrevStates)
      print(bWriteLog and "UGCCharacterAnimFeature:OnStateChange InCurStates(bin):" .. table.concat(CurStatesBinary) .. " InPrevStates(bin):" .. table.concat(PrevStatesBinary))
      local _findEPawnStates = function(InCurStatesMap, InPrevStatesMap, bFindNew)
        local arr = {}
        if not self.AllEPawnStates then
          return
        end
        for StateNum, PawnState in ipairs(self.AllEPawnStates) do
          if not bFindNew and InPrevStatesMap[StateNum] == 1 and (InCurStatesMap[StateNum] == 0 or InCurStatesMap[StateNum] == nil) then
            table.insert(arr, StateNum - 1)
          elseif bFindNew and (InPrevStatesMap[StateNum] == 0 or InCurStatesMap[StateNum] == nil) and InCurStatesMap[StateNum] == 1 then
          elseif InPrevStatesMap[StateNum] == nil and InCurStatesMap[StateNum] == nil then
            break
          end
        end
        return arr
      end
      local OldStateArr = _findEPawnStates(CurStatesMap, PrevStatesMap, false)
      local NewStateArr = _findEPawnStates(CurStatesMap, PrevStatesMap, true)
      if OldStateArr and NewStateArr then
        log_tree("UGCCharacterAnimFeature:OnStateChange OldStateArr", OldStateArr)
        log_tree("UGCCharacterAnimFeature:OnStateChange NewStateArr", NewStateArr)
      end
      local CreativeModeCharacterAnimationDefine = require("GameLua.Mod.CreativeBase.Gameplay.Animation.CreativeModeCharacterAnimationDefine")
      if CreativeModeCharacterAnimationDefine.CheckPawnStatesSkipBreakAnim(uPlayerCharacter, true) and AnimParams.SlotNodeName == "UpBody" then
        print(bWriteLog and "UGCCharacterAnimFeature:OnStateChange CheckPawnStatesSkipBreakAnim, Upbody")
      elseif CreativeModeCharacterAnimationDefine.CheckPawnStatesSkipBreakAnim(uPlayerCharacter, false) and AnimParams.SlotNodeName == "WholeBody" then
        print(bWriteLog and "UGCCharacterAnimFeature:OnStateChange CheckPawnStatesSkipBreakAnim, WholeBody")
      elseif CreativeModeCharacterAnimationDefine.CheckOldPawnStatesSkipBreakAnim(OldStateArr) then
        print(bWriteLog and "UGCCharacterAnimFeature:OnStateChange CheckOldPawnStatesSkipBreakAnim")
      elseif InCurStates == InPrevStates then
        print(bWriteLog and "UGCCharacterAnimFeature:OnStateChange InCurStates == InPrevStates")
      else
        self:StopAnimation(uPlayerCharacter, AnimParams)
      end
      uPlayerCharacter:RemoveControlEvent(uPlayerCharacter, "OnClientStatesChange")
    end
    self:AddControlEvent(uPlayerCharacter, "OnClientStatesChange", OnStateChange, self)
    local EmoteId = AnimParams.EmoteId
    local EmoteHandle = CreativeModeCharacterAnimationUtility.GetEmoteHandleFromEmoteID(EmoteId)
    local EmoteAnimPath = CreativeModeCharacterAnimationUtility.GetAnimPathFromEmoteHandle(EmoteId)
    if slua.isValid(EmoteHandle) then
      AnimParams.BlendInTime = EmoteHandle.BlendTime or AnimParams.BlendInTime
      AnimParams.BlendOutTime = EmoteHandle.BlendTime or AnimParams.BlendOutTime
    end
    if EmoteAnimPath and EmoteAnimPath ~= "" then
      AnimParams.AssetPath = EmoteAnimPath
    end
    if CreativeAnimationSubsystem:IsAIGCAnimId(AnimParams.AnimId) then
      CreativeAnimationSubsystem:PlayAIGCAnimWithId(uPlayerCharacter, AnimParams.AnimId, AnimParams.StartTimePercentage or 0, AnimParams.InPlayRate or 1, AnimParams.bIsLoop or false)
    else
      CreativeModeCharacterAnimationUtility.LocalPlayCreativeEmoteAnim(AnimParams.StartTimePercentage, AnimParams.InPlayRate, AnimParams.bIsLoop, AnimParams.SlotNodeName, AnimParams.BlendInTime, AnimParams.BlendOutTime, uPlayerCharacter, EmoteId, AnimParams.AssetPath, AnimParams.AnimId)
    end
  end
end
function UGCCharacterAnimFeature:_toBinary(num)
  print(bWriteLog and "UGCCharacterAnimFeature:_toBinary num = " .. tostring(num))
  local bits = {}
  local bitsMap = {}
  if type(num) ~= "number" then
    return "nil"
  end
  repeat
    table.insert(bits, 1, num % 2)
    bitsMap[#bits] = num % 2
    num = math.floor(num / 2)
  until num == 0
  return bits, bitsMap
end
function UGCCharacterAnimFeature:_getAllEPawnStates()
  print(bWriteLog and "UGCCharacterAnimFeature:_getAllEPawnStates")
  local AllPawnStates = {}
  for k, v in pairs(EPawnState) do
    if type(v) == "number" then
      AllPawnStates[v + 1] = k
    end
  end
  return AllPawnStates
end
function UGCCharacterAnimFeature:StopAnimation(uPlayerCharacter, AnimParams)
  print(bWriteLog and "UGCCharacterAnimFeature:StopAnimation")
  uPlayerCharacter:StopSlotAnim(nil, AnimParams.SlotNodeName, AnimParams.BlendOutTime)
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, UGCCharacterAnimFeature)