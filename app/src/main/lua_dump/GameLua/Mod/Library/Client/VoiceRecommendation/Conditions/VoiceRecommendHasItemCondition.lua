local VoiceRecommendHasItemCondition = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local UBackpackUtils = import("BackpackUtils")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
function VoiceRecommendHasItemCondition:ctor(SelfType, Params)
  self.Compareend
function VoiceRecommendHasItemCondition:DoCheckCondition()
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return false
  end
  local uBackpackComponent = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(uPlayerController)
  if not slua.isValid(uBackpackComponent) then
    return false
  end
  for Index, ParamValue in pairs(self.CompareParams) do
    local CurNum = 0
    if ParamValue.ItemIDList ~= nil and 0 < #ParamValue.ItemIDList then
      local FBattleItemDataArray = UBackpackUtils.GetBattleItemDataListByIDList(uBackpackComponent, ParamValue.ItemIDList)
      if FBattleItemDataArray:Num() ~= 0 then
        for ItemIndex, ItemValue in pairs(FBattleItemDataArray) do
          CurNum = CurNum + ItemValue.Count
        end
      end
    end
    if ParamValue.SubType ~= nil and 0 < #ParamValue.SubType then
      local SubTypeItemDataArray = UBackpackUtils.GetAllItemsInBackpackWithSubType(uBackpackComponent, ParamValue.SubType, 0)
      if SubTypeItemDataArray:Num() ~= 0 then
        for _, SubTypeItemValue in pairs(SubTypeItemDataArray) do
          CurNum = CurNum + SubTypeItemValue.Count
        end
      end
    end
    if ParamValue.ExcludeIDList ~= nil and 0 < #ParamValue.ExcludeIDList then
      local ExcludeItemDataArray = UBackpackUtils.GetBattleItemDataListByIDList(uBackpackComponent, ParamValue.ExcludeIDList)
      if ExcludeItemDataArray:Num() ~= 0 then
        for _, ExcludeItemValue in pairs(ExcludeItemDataArray) do
          CurNum = CurNum - ExcludeItemValue.Count
        end
      end
    end
    if not self:CompareNum(CurNum, ParamValue.TargetNum, ParamValue.CompareType) then
      return false
    end
  end
  return true
end
function VoiceRecommendHasItemCondition:CompareNum(Num, TargetNum, CompareType)
  if CompareType == UEnums.CompareType.Greater and TargetNum < Num then
    return true
  elseif CompareType == UEnums.CompareType.GreaterEqual and TargetNum <= Num then
    return true
  elseif CompareType == UEnums.CompareType.NotEqual and Num ~= TargetNum then
    return true
  elseif CompareType == UEnums.CompareType.Equal and Num == TargetNum then
    return true
  elseif CompareType == UEnums.CompareType.Less and Num < TargetNum then
    return true
  elseif CompareType == UEnums.CompareType.LessEqual and Num <= TargetNum then
    return true
  end
  return false
end
local class = require("class")
local CConditionBase = require("GameLua.Mod.Library.Client.VoiceRecommendation.Conditions.VoiceRecommendConditionBase")
local CVoiceRecommendHasPropertyCondition = class(CConditionBase, nil, VoiceRecommendHasItemCondition)
return CVoiceRecommendHasPropertyCondition