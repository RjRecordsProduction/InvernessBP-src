json = json or {}
local local CJSON_DEFAULT_PRECISION = 14
local CJSON_HIGH_PRECISION = 17
if cjson then
  local cjson_decode = cjson.decode
  local cjson_encode = cjson.encode
  function json.SetHighPrecision(enable)
    if not cjson.encode_number_precision then
      return false
    end
    local precision = enable and CJSON_HIGH_PRECISION or CJSON_DEFAULT_PRECISION
    local ok, err = pcall(cjson.encode_number_precision, precision)
    return ok
  end
  if IsWoWEditor then
    json.SetHighPrecision(true)
  end
  function json.decode(str)
    local retError, retTable = pcall(cjson_decode, str)
    if not retError then
      local dkjson = require("common.dkjson")
      return dkjson.decode(str)
    end
    return retTable
  end
  function json.encode(value)
    local retError, retStr = pcall(cjson_encode, value)
    if not retError then
      local dkjson = require("common.dkjson")
      return dkjson.encode(value)
    end
    return retStr
  end
  function json.format(jsonStr, indent)
    if not jsonStr or type(jsonStr) ~= "string" then
      return jsonStr
    end
    indent = indent or 2
    local indentStr = ""
    for i = 1, indent do
      indentStr = indentStr .. " "
    end
    local result = {}
    local level = 0
    local inString = false
    local escapeNext = false
    for i = 1, #jsonStr do
      local char = jsonStr:sub(i, i)
      if escapeNext then
        table.insert(result, char)
        escapeNext = false
      elseif char == "\\" and inString then
        table.insert(result, char)
        escapeNext = true
      elseif char == "\"" then
        table.insert(result, char)
        inString = not inString
      elseif not inString then
        if char == "{" or char == "[" then
          table.insert(result, char)
          level = level + 1
          table.insert(result, "\n")
          table.insert(result, string.rep(indentStr, level))
        elseif char == "}" or char == "]" then
          level = level - 1
          table.insert(result, "\n")
          table.insert(result, string.rep(indentStr, level))
          table.insert(result, char)
        elseif char == "," then
          table.insert(result, char)
          table.insert(result, "\n")
          table.insert(result, string.rep(indentStr, level))
        elseif char == ":" then
          table.insert(result, char)
          table.insert(result, " ")
        elseif char ~= " " and char ~= "\t" and char ~= "\n" and char ~= "\r" then
          table.insert(result, char)
        end
      else
        table.insert(result, char)
      end
    end
    return table.concat(result)
  end
end
return json