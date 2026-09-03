local NGConditionCheckGameGuideItem = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function NGConditionCheckGameGuideItem:ctor(selfType, Params)
end
function NGConditionCheckGameGuideItem:CheckConditionOK(...)
  local bSuperOk = NGConditionCheckGameGuideItem.__super.CheckConditionOK(self, ...)
  if not bSuperOk then
    return false
  end
  local Args = table.pack(...)
  local Pawn, uInWeapon = table.unpack(Args)
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not (Game:IsValid(PlayerCharacter) and Game:IsValid(Pawn)) or not Game:IsValid(uInWeapon) then
    return
  end
  if PlayerCharacter ~= Pawn then
    return
  end
  local GameGuideUIUtil = require("GameLua.Mod.BaseMod.Client.Map.GameGuideUI.GameGuideUIUtil")
  local TableUtil = require("common.table_util")
  local CheckDataList = GameGuideUIUtil.GetGuideCheckData()
  local DefineID = uInWeapon:GetItemDefineID()
  if TableUtil.Find(CheckDataList, DefineID.TypeSpecificID) ~= -1 then
    return true
  end
  return false
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Conditions.NewbieGuideConditionBase")
local CNGConditionCheckGameGuideItem = class(CObject, nil, NGConditionCheckGameGuideItem)
return CNGConditionCheckGameGuideItem