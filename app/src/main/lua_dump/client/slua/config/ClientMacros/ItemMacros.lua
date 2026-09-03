local ItemMacros = {
  QUALITY_Grey = 1,
  QUALITY_BLACK = 2,
  QUALITY_GREEN = 3,
  QUALITY_BLUE = 4,
  QUALITY_PURPLE = 5,
  QUALITY_PINK = 6,
  QUALITY_RED = 7,
  QUALITY_GOLDEN = 8,
  QUALITY_TGOLDEN = 10
}
ItemMacros.Enum_GetTagType = {
  None = 0,
  Must = 1,
  Random = 2,
  Luck = 5,
  CriticalHit = 8,
  SelectBox = 9
}
local carTypes = {
  [8] = 1,
  [9] = 1,
  [11] = 1
}
function ItemMacros.IsCar(itemType)
  if itemType then
    return carTypes[itemType]
  end
  return false
end
return ItemMacros