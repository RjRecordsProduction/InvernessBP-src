local style_one = {}
local StringUtil = require("common.string_util")
local GetCharLen = function(char)
  local byte = string.byte(char, 1)
  local isEnglish = StringUtil.IsEnglish(byte)
  local isSpace = StringUtil.IsSpace(byte)
  local isNumeric = StringUtil.IsNumber(byte)
  if isEnglish or isSpace or isNumeric or char == "(" or char == ")" or char == "[" or char == "]" then
    return 1
  else
    return 2
  end
end
local GetTextLen = function(text)
  local textLen = 0
  local kismet_string_library = require("common.kismet_string_library")
  local charArray = kismet_string_library.GetCharacterArrayFromString(text)
  for index = 1, #charArray do
    local char = charArray[index]
    textLen = textLen + GetCharLen(char)
  end
  return textLen
end
function style_one:ShowItemName(item, ItemName)
  if ItemName then
    item.TextBlock_ItemName:SetText(ItemName)
    item.ItemName:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  else
    item.ItemName:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function style_one:SetNameColor(item, Color)
  item.TextBlock_ItemName:SetColorAndOpacity(Color)
end
function style_one:SetIsNew(item, isNew)
  if item then
    item = item.Common_Item_All_UIBP
    if item and item.Text_New2 then
      self:_SetWidgetVisible(item.Text_New2, isNew)
    end
  end
end
function style_one:SetIsTryOn(item, isTryOn)
  self:_SetWidgetVisible(item.TextBlock_TryOn, isTryOn)
end
function style_one:SetNameAddStr(item, extendName, haveLimitTime)
  if item and item.TextBlock_LimiteTime then
    item.TextBlock_LimiteTime:SetText(extendName)
    self:_SetWidgetVisible(item.TextBlock_LimiteTime, true)
    self:_UpdateItemName(item, haveLimitTime)
  end
end
function style_one:HideNameAddrStr(item)
  self:_SetWidgetVisible(item.TextBlock_LimiteTime, false)
end
function style_one:_UpdateItemName(item, haveLimitTime)
  local oldName = item.TextBlock_ItemName:GetText()
  local nameLen = GetTextLen(oldName)
  local itemNameAdd = item.TextBlock_LimiteTime
  local addLen = 0
  if haveLimitTime then
    if itemNameAdd:isVisible() then
      addLen = GetTextLen(itemNameAdd:GetText())
    end
  else
    self._SetWidgetVisible(itemNameAdd, false)
  end
  if 14 < nameLen + addLen then
    local newName = ""
    local newLen = 0
    local leftNameLen = 10 - addLen
    local kismet_string_library = require("common.kismet_string_library")
    local nameArray = kismet_string_library.GetCharacterArrayFromString(oldName)
    local arrayNum = #nameArray
    for i = 1, arrayNum do
      local char = nameArray[i]
      if newLen > leftNameLen then
        break
      end
      newName = newName .. char
      newLen = newLen + GetCharLen(char)
    end
    newName = newName .. "...."
    item.TextBlock_ItemName:SetText(newName)
  end
end
function style_one:ClearName(item)
  if item then
    item.ItemName:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function style_one:ResetIcon(item)
  self:SetCombatReadinessIcon(item, false)
end
function style_one:SetCombatReadinessIcon(item, visibility)
  item = item and item.Common_Item_All_UIBP
  if item and item.box then
    self:_SetWidgetVisible(item.box, visibility)
  end
end
function style_one:SetEveryPackIcon(item, isSpecailIconSwitch)
  if not isSpecailIconSwitch or isSpecailIconSwitch == 0 then
    item.WidgetSwitcher_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  item.WidgetSwitcher_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if tonumber(isSpecailIconSwitch) == 1 then
    item.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  elseif tonumber(isSpecailIconSwitch) == 2 then
    item.WidgetSwitcher_0:SetActiveWidgetIndex(1)
  end
end
function style_one:SetIsHavePVEAffix(item, ishave)
  if item and item.Common_Item_All_UIBP and item.Common_Item_All_UIBP.SizeBox_4 then
    self:_SetWidgetVisible(item.Common_Item_All_UIBP.SizeBox_4, ishave)
  end
end
local class = require("class")
local BaseStyle = require("client.slua.component.item.base_style")
local CStyleOne = class(BaseStyle, nil, style_one)
return CStyleOne