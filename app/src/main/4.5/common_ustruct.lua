local sluaArray = slua.Array
local local local local local local Margin = import("/Script/SlateCore.Margin")
local Anchors = import("/Script/Slate.Anchors")
local minVec2D = FVector2D(0, 0)
local maxVec2D = FVector2D(0, 0)
local SlateColor = import("SlateColor")
local GameplayTag = import("/Script/GameplayTags.GameplayTag")
local SAbilitySystemBlueprintLibrary = import("SAbilitySystemBlueprintLibrary")
local RenderQualitySettings = import("/Script/ShadowTrackerExtra.RenderQualitySettings")
local ItemDefineID = import("/Script/Basic.ItemDefineID")
local AvatarCustom = import("AvatarCustom")
function FMargin(left, top, right, bottom)
  return Margin(left or 0, top or 0, right or 0, bottom or 0)
end
function FAnchors(minX, minY, maxX, maxY)
  minVec2D.X = minX or 0
  minVec2D.Y = minY or 0
  maxVec2D.X = maxX or 0
  maxVec2D.Y = maxY or 0
  return Anchors(minVec2D, maxVec2D)
end
function FSlateColor(linearColor)
  return SlateColor(linearColor)
end
function FRenderQualitySettings(RenderQualitySetting, RenderStyleSetting, RenderMSAASetting, RenderMSAAValue)
  return RenderQualitySettings(RenderQualitySetting, RenderStyleSetting, RenderMSAASetting, RenderMSAAValue)
end
function FGameplayTag(tag)
  tag = tag or ""
  return SAbilitySystemBlueprintLibrary.RequestGameplayTag(tag, true)
end
function TagEquals(taga, tagb)
  return taga.TagName == tagb.TagName
end
function FGameplayTagContainer(tags)
  if not tags or type(tags) ~= "table" or #tags == 0 then
    return nil
  end
  local tagArray = sluaArray(UEnums.EPropertyClass.Struct, GameplayTag)
  for i, tagStr in ipairs(tags) do
    local tag = FGameplayTag(tagStr)
    if tag then
      tagArray:Add(tag)
    end
  end
  if tagArray:Num() == 0 then
    return nil
  end
  return SAbilitySystemBlueprintLibrary.CreateGameplayTagContainer(tagArray)
end
function FItemDefineID(Type, TypeSpecificID, InstanceID)
  Type = Type or 0
  TypeSpecificID = TypeSpecificID or 0
  if InstanceID then
    return ItemDefineID(Type, TypeSpecificID, false, false, InstanceID)
  else
    return ItemDefineID(Type, TypeSpecificID)
  end
end
function FItemDefineIDDefault()
  return ItemDefineID()
end
function FAvatarCustom(CustomType, ColorID, PatternID, NumID, ParticleID)
  CustomType = CustomType or 0
  ColorID = ColorID or 0
  PatternID = PatternID or 0
  NumID = NumID or 0
  ParticleID = ParticleID or 0
  return AvatarCustom(CustomType, ColorID, PatternID, NumID, ParticleID)
end
function FAvatarCustomDefault()
  return AvatarCustom()
end