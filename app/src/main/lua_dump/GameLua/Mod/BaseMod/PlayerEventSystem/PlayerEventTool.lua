local PlayerEventTool = {}
function PlayerEventTool.GetAttrInputParamContent(modifyAttrContent, tParam)
  if tParam == nil then
    return modifyAttrContent
  end
  local attrStrLen = string.len(modifyAttrContent)
  local inputParamTagIndex = string.find(modifyAttrContent, "@", 1, attrStrLen)
  if inputParamTagIndex == nil then
    return modifyAttrContent
  else
    local paramIndex = string.sub(modifyAttrContent, inputParamTagIndex + 2, attrStrLen)
    local needParam = tParam[tonumber(paramIndex)]
    if needParam == nil then
      assert(needParam ~= nil, string.format("GetAttrInputParamContent modifyAttrContent:%s paramIndex:%s @ param index is null!!!", modifyAttrContent, paramIndex))
      return modifyAttrContent
    end
    local needReplaceStr = string.sub(modifyAttrContent, inputParamTagIndex, inputParamTagIndex + 2)
    local InputModifyAttrContent = string.gsub(modifyAttrContent, needReplaceStr, tostring(needParam))
    return InputModifyAttrContent
  end
end
function PlayerEventTool.GetModifyAttrAction(attrStr)
  if PlayerEventTool.IsStringEmpty(attrStr) then
    return nil
  end
  local semicolonStartIdx, semicolonEndIdx = string.find(attrStr, ";", 1, true)
  local dotStartIdx, dotEndIdx = string.find(attrStr, ".", 1, true)
  local equalStartIdx, equalEndIdx = string.find(attrStr, "=", dotEndIdx, true)
  local attrStrLen = string.len(attrStr)
  local newAttrName = string.sub(attrStr, 1, dotStartIdx - 1)
  local useOldModfiy = false
  local AttrPawnIndx
  if semicolonStartIdx and semicolonEndIdx then
    newAttrName = string.sub(attrStr, semicolonStartIdx + 1, dotStartIdx - 1)
    local semicolonStr = string.sub(attrStr, 1, semicolonStartIdx - 1)
    if semicolonStr == "old" then
      useOldModfiy = true
    else
      local StartIndex, EndIndex = string.find(semicolonStr, "AttrPawnIndx", 1, true)
      if StartIndex and EndIndex then
        local StringLen = string.len(semicolonStr)
        if StringLen >= EndIndex + 2 then
          local ParamDesc = string.sub(semicolonStr, EndIndex + 2, StringLen)
          local index = tonumber(ParamDesc)
          AttrPawnIndx = index
        end
      end
    end
  end
  local newOpr = string.sub(attrStr, dotStartIdx + 1, equalStartIdx - 1)
  local newValue = tonumber(string.sub(attrStr, equalEndIdx + 1, attrStrLen))
  local newTypeValue = 0
  if newOpr == "per" then
    newTypeValue = 1
  elseif newOpr == "abs" then
    newTypeValue = 2
  elseif newOpr == "set" then
    newTypeValue = 3
  end
  local DynamicModifyItem = {
    AttrName = newAttrName,
    Type = newTypeValue,
    Value = newValue,
    Enabled = true,
    UseOldModfiy = useOldModfiy,
      }
  return DynamicModifyItem
end
function PlayerEventTool.DecodeModifyActionData(ModifyActionStr, tParam)
  if not PlayerEventTool.IsStringEmpty(ModifyActionStr) then
    local modifyActionData = {}
    local startIndex = 1
    local splitIndex = string.find(ModifyActionStr, "|", startIndex, true)
    local AttrStrLen = string.len(ModifyActionStr)
    while splitIndex ~= nil do
      local modifyAttrStr = string.sub(ModifyActionStr, startIndex, splitIndex - 1)
      if not PlayerEventTool.IsStringEmpty(modifyAttrStr) then
        local attrActionData = PlayerEventTool.GetModifyAttrAction(PlayerEventTool.GetAttrInputParamContent(modifyAttrStr, tParam))
        if attrActionData then
          modifyActionData[#modifyActionData + 1] = attrActionData
        end
      end
      startIndex = splitIndex + 1
      splitIndex = string.find(ModifyActionStr, "|", startIndex, true)
    end
    local tailModifyAttrStr = string.sub(ModifyActionStr, startIndex, AttrStrLen)
    if not PlayerEventTool.IsStringEmpty(tailModifyAttrStr) then
      local tailAttrActionData = PlayerEventTool.GetModifyAttrAction(PlayerEventTool.GetAttrInputParamContent(tailModifyAttrStr, tParam))
      if tailAttrActionData then
        modifyActionData[#modifyActionData + 1] = tailAttrActionData
      end
    end
    return modifyActionData
  end
end
function PlayerEventTool.IsStringEmpty(Str)
  if Str == nil or Str == "" then
    return true
  end
  return false
end
return PlayerEventTool