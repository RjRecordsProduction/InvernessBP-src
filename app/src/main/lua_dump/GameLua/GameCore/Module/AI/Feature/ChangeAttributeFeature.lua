local FeatureUtil = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureUtil")
local UAIBlueprintHelperLibrary = import("AIBlueprintHelperLibrary")
local ChangeAttributeFeature = {}
function ChangeAttributeFeature:ctor()
end
function ChangeAttributeFeature:ReceiveBeginPlay()
  ChangeAttributeFeature.__super.ReceiveBeginPlay(self)
end
function ChangeAttributeFeature:_PostConstruct()
  ChangeAttributeFeature.__super._PostConstruct(self)
end
function ChangeAttributeFeature:ChangeAttrbute(InAttributeInfo)
  if not self.Owner then
    print(bWriteLog and "ChangeAttributeFeature ChangeAttrbute self.Owner is nil")
    return
  end
  if InAttributeInfo == nil then
    print(bWriteLog and "ChangeAttributeFeature ChangeAttrbute InAttributeInfo is nil")
    return
  end
  if not slua.isValid(self.Owner.AttrModifyComp) then
    print(bWriteLog and "ChangeAttributeFeature ChangeAttrbute self.Owner.AttrModifyComp is nil")
  end
  local uController = UAIBlueprintHelperLibrary.GetAIController(self.Owner)
  if not slua.isValid(uController) then
    print(bWriteLog and "ChangeAttributeFeature ChangeAttrbute uController is nil")
    return
  end
  if not uController.AIFeatureInfo then
    print(bWriteLog and "ChangeAttributeFeature ChangeAttrbute uController.AIFeatureInfo is nil")
    return
  end
  local uAttrModifyComp = self.Owner.AttrModifyComp
  if InAttributeInfo.Hp and uAttrModifyComp and slua.isValid(uAttrModifyComp) then
    local nHp = InAttributeInfo.Hp
    uAttrModifyComp:SetValueToAttributeSafety("HealthMax", nHp, 0)
    uAttrModifyComp:SetOrignalValueToAttribute("HealthMax", nHp)
    uAttrModifyComp:SetAttributeMaxValue("Health", nHp)
    uAttrModifyComp:SetValueToAttributeSafety("Health", nHp, 0)
    uAttrModifyComp:SetOrignalValueToAttribute("Health", nHp)
    uController.AIFeatureInfo.HP = nHp
    print(bWriteLog and "ChangeAttributeFeature ChangeAttrbute Hp:" .. tostring(nHp))
  end
  if InAttributeInfo.TakeDamageScale then
    uController.AIFeatureInfo.TakeDamageScale = InAttributeInfo.TakeDamageScale
    print(bWriteLog and "ChangeAttributeFeature ChangeAttrbute TakeDamageScale:" .. tostring(InAttributeInfo.TakeDamageScale))
  end
  if InAttributeInfo.DamageScale then
    uController.AIFeatureInfo.DamageScale = InAttributeInfo.DamageScale
    print(bWriteLog and "ChangeAttributeFeature ChangeAttrbute DamageScale:" .. tostring(InAttributeInfo.DamageScale))
  end
  if InAttributeInfo.SpeedRate and uAttrModifyComp and slua.isValid(uAttrModifyComp) and uAttrModifyComp.GetAttributeValue then
    local SpeedScaleKey = "SpeedRate"
    local AttrSpeedScale = uAttrModifyComp:GetAttributeValue(SpeedScaleKey)
    uAttrModifyComp:AddModifyItemAndCache(SpeedScaleKey, 0, InAttributeInfo.SpeedRate - AttrSpeedScale, true, self.Owner, true)
    print(bWriteLog and string.format("ChangeAttributeFeature ChangeAttrbute Old SpeedScale:%s  New SpeedScale:%s", tostring(AttrSpeedScale), tostring(InAttributeInfo.SpeedRate)))
  end
  if EVENTTYPE_CREATIVE and EVENTID_ON_PLAYER_KILL_AI then
    EventSystem:postEvent(EVENTTYPE_CREATIVE, EVENTID_AIPAWN_ATTR_CHANGED, self.Owner, InAttributeInfo)
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CChangeAttributeFeature = class(CFeatureBase, nil, ChangeAttributeFeature)
return CChangeAttributeFeature