local kismet_string_library = {}
local ESearchCase = {CaseSensitive = 1, IgnoreCase = 2}
local ESearchDir = {FromStart = 1, FromEnd = 2}
kismet_string_library.kismet_string_library.local split_utf8_chars = function(utf8_str)
  local result = {}
  local i = 1
  local len = #utf8_str
  while i <= len do
    local s_byte = string.byte(utf8_str, i)
    local char_len = 1
    if s_byte < 128 then
      char_len = 1
    elseif 192 <= s_byte and s_byte < 224 then
      char_len = 2
    elseif 224 <= s_byte and s_byte < 240 then
      char_len = 3
    elseif 240 <= s_byte and s_byte < 248 then
      char_len = 4
    elseif 248 <= s_byte and s_byte < 252 then
      char_len = 5
    elseif 252 <= s_byte then
      char_len = 6
    end
    local char = utf8_str:sub(i, i + char_len - 1)
    result[#result + 1] = char
    i = i + char_len
  end
  return result
end
local utf8_char_count = function(utf8_str)
  if utf8_str == nil then
    return 0
  end
  local count = 0
  local i = 1
  local len = #utf8_str
  while i <= len do
    local byte = string.byte(utf8_str, i)
    if byte < 128 then
      i = i + 1
    elseif 192 <= byte and byte < 224 then
      i = i + 2
    elseif 224 <= byte and byte < 240 then
      i = i + 3
    elseif 240 <= byte and byte < 248 then
      i = i + 4
    elseif 248 <= byte and byte < 252 then
      i = i + 5
    elseif 252 <= byte then
      i = i + 6
    end
    count = count + 1
  end
  return count
end
local replace_str_ignore_case = function(str, form, to)
  local escape_pattern = function(text)
    local magic_chars = {
      "%",
      "^",
      "$",
      "(",
      ")",
      ".",
      "[",
      "]",
      "*",
      "+",
      "-",
      "?"
    }
    for _, char in ipairs(magic_chars) do
      text = text:gsub("%" .. char, "%%%1")
    end
    return text
  end
  local escaped_old_sub_str = escape_pattern(form)
  local pattern = escaped_old_sub_str:gsub("%a", function(c)
    return string.format("[%s%s]", c:lower(), c:upper())
  end)
  str = string.gsub(str, pattern, to)
  return str
end
local case_insensitive_split_first = function(str, delimiter, search_case, search_dir)
  local escape_pattern = function(text)
    local magic_chars = {
      "%",
      "^",
      "$",
      "(",
      ")",
      ".",
      "[",
      "]",
      "*",
      "+",
      "-",
      "?"
    }
    for _, char in ipairs(magic_chars) do
      text = text:gsub("%" .. char, "%%%1")
    end
    return text
  end
  local escaped_delimiter = escape_pattern(delimiter)
  local pattern
  if search_case == ESearchCase.CaseSensitive then
    pattern = string.format("(%s)", escaped_delimiter)
  else
    pattern = string.format("(%s)", escaped_delimiter:gsub("%a", function(c)
      return string.format("[%s%s]", c:lower(), c:upper())
    end))
  end
  local start_pos, end_pos
  if search_dir == ESearchDir.FromEnd then
    local start_p, end_p = string.find(str, pattern)
    while start_p do
      start_pos, end_pos = start_p, end_p
      start_p, end_p = string.find(str, pattern, end_p + 1)
    end
  else
    start_pos, end_pos = string.find(str, pattern)
  end
  if start_pos then
    local first_part = string.sub(str, 1, start_pos - 1)
    local second_part = string.sub(str, end_pos + 1)
    return true, first_part, second_part
  else
    return false, "", ""
  end
end
local function matches_wildcard_recursive(target_str, wildcard_str)
  local t_front_i = 1
  local w_front_i = 1
  local w_length = #wildcard_str
  local t_length = #target_str
  while true do
    if w_length == 0 then
      return t_length == 0
    end
    local w_c = string.sub(wildcard_str, w_front_i, w_front_i)
    if w_c == "*" or w_c == "?" then
      break
    end
    local t_c = string.sub(target_str, t_front_i, t_front_i)
    if w_c ~= t_c then
      return false
    end
    t_front_i = t_front_i + 1
    w_front_i = w_front_i + 1
    t_length = t_length - 1
    w_length = w_length - 1
  end
  local t_behind_i = #target_str
  local w_behind_i = #wildcard_str
  while true do
    local w_c = string.sub(wildcard_str, w_behind_i, w_behind_i)
    if w_c == "*" or w_c == "?" then
      break
    end
    local t_c = string.sub(target_str, t_behind_i, t_behind_i)
    if w_c ~= t_c then
      return false
    end
    t_length = t_length - 1
    w_length = w_length - 1
    if t_length == 0 then
      break
    end
    t_behind_i = t_behind_i - 1
    w_behind_i = w_behind_i - 1
  end
  local w_c = string.sub(wildcard_str, w_front_i, w_front_i)
  if w_length == 1 and (w_c == "*" or t_length < 2) then
    return true
  end
  w_front_i = w_front_i + 1
  w_length = w_length - 1
  local maxNum = t_length
  if w_c == "?" and 1 < maxNum then
    maxNum = 1
  end
  for i = 0, maxNum do
    if matches_wildcard_recursive(string.sub(target_str, t_front_i + i, t_front_i + t_length), string.sub(wildcard_str, w_front_i, w_front_i + w_length)) then
      return true
    end
  end
  return false
end
function kismet_string_library.GetCharacterArrayFromString(SourceString)
  if SourceString and SourceString ~= "" then
    return split_utf8_chars(SourceString)
  end
  return {}
end
function kismet_string_library.JoinStringArray(SourceArray, Separator)
  if SourceArray and next(SourceArray) then
    if Separator and Separator ~= "" then
      return table.concat(SourceArray, Separator)
    else
      return table.concat(SourceArray)
    end
  end
  return ""
end
function kismet_string_library.Len(Str)
  return utf8_char_count(Str)
end
function kismet_string_library.Replace(SourceString, From, To, SearchCase)
  if not SourceString or SourceString == "" then
    return ""
  end
  if not From or From == "" then
    return SourceString
  end
  To = To or ""
  if SearchCase == ESearchCase.CaseSensitive then
    SourceString = string.StrReplace(SourceString, From, To)
    return SourceString
  else
    return replace_str_ignore_case(SourceString, From, To)
  end
end
function kismet_string_library.Split(SourceString, InStr, SearchCase, SearchDir)
  if not SourceString or SourceString == "" then
    return false, "", ""
  end
  if not InStr or InStr == "" then
    return false, "", ""
  end
  return case_insensitive_split_first(SourceString, InStr, SearchCase, SearchDir)
end
function kismet_string_library.MatchesWildcard(SourceString, Wildcard, SearchCase)
  if SearchCase == ESearchCase.CaseSensitive then
    return matches_wildcard_recursive(SourceString, Wildcard)
  else
    SourceString = string.lower(SourceString)
    Wildcard = string.lower(Wildcard)
    return matches_wildcard_recursive(SourceString, Wildcard)
  end
end
function kismet_string_library.Left(SourceString, Count)
  if not SourceString or SourceString == "" then
    return ""
  end
  if not Count or Count <= 0 then
    return ""
  end
  local count = 0
  local i = 1
  local len = #SourceString
  while i <= len do
    local byte = string.byte(SourceString, i)
    if byte < 128 then
      i = i + 1
    elseif 192 <= byte and byte < 224 then
      i = i + 2
    elseif 224 <= byte and byte < 240 then
      i = i + 3
    elseif 240 <= byte and byte < 248 then
      i = i + 4
    elseif 248 <= byte and byte < 252 then
      i = i + 5
    elseif 252 <= byte then
      i = i + 6
    end
    count = count + 1
    if Count <= count then
      return string.sub(SourceString, 1, i - 1)
    end
  end
  return ""
end
function kismet_string_library.Conv_VectorToString(InVec)
  if InVec and type(InVec) == "userdata" then
    return string.format("X=%3.5f Y=%3.5f Z=%3.5f", InVec.X, InVec.Y, InVec.Z)
  end
  return ""
end
function kismet_string_library.Conv_FloatToString(InFloat)
  if InFloat and type(InFloat) == "number" then
    return tostring(InFloat)
  end
  return ""
end
function kismet_string_library.ParseIntoArray(SourceString, Delimiter, CullEmptyStrings)
  local StringUtil = require("common.string_util")
  local splits = StringUtil.Split(SourceString, Delimiter)
  if CullEmptyStrings then
    for i = #splits, 1, -1 do
      if splits[i] == "" then
        table.remove(splits, i)
      end
    end
  end
  return splits
end
function kismet_string_library.Contains(SourceString, Substring, bUseCase)
  if not SourceString or SourceString == "" then
    return false
  end
  if not Substring or Substring == "" then
    return false
  end
  if not bUseCase then
    SourceString = string.lower(SourceString)
    Substring = string.lower(Substring)
  end
  local start_pos = string.find(SourceString, Substring, 1, true)
  return start_pos ~= nil
end
function kismet_string_library.StartsWith(SourceString, InPrefix, SearchCase)
  if SearchCase ~= ESearchCase.CaseSensitive then
    SourceString = string.lower(SourceString)
    InPrefix = string.lower(InPrefix)
  end
  return SourceString:sub(1, #InPrefix) == InPrefix
end
return kismet_string_library