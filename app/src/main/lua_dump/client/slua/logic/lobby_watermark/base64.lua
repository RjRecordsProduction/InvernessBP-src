local base64 = {}
local _
function base64.enc(data)
  local BusinessHelper = import("BusinessHelper")
  return BusinessHelper.SpecialBase64Encode(data)
end
function base64.dec(data)
  local BusinessHelper = import("BusinessHelper")
  return BusinessHelper.SpecialBase64Decode(data)
end
function base64.decode(data)
  local BusinessHelper = import("BusinessHelper")
  return BusinessHelper.Base64Decode(data)
end
function base64.encode(data)
  local BusinessHelper = import("BusinessHelper")
  return BusinessHelper.Base64Encode(data)
end
function base64.EncodeBase64(source_str)
  local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  local s64 = ""
  local str = source_str
  while 0 < #str do
    local bytes_num = 0
    local buf = 0
    for _ = 1, 3 do
      buf = buf * 256
      if 0 < #str then
        buf = buf + _string.byte(str, 1, 1)
        str = _string.sub(str, 2)
        bytes_num = bytes_num + 1
      end
    end
    for _ = 1, bytes_num + 1 do
      local b64char = math.fmod(math.floor(buf / 262144), 64) + 1
      s64 = s64 .. _string.sub(b64chars, b64char, b64char)
      buf = buf * 64
    end
    for _ = 1, 3 - bytes_num do
      s64 = s64 .. "="
    end
  end
  return s64
end
local default_base64_table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
function base64.DecodeBase64(data, base64_key)
  local base64_table = base64_key or default_base64_table
  data = _string.gsub(data, "[^" .. base64_table .. "=]", "")
  return (data:gsub(".", function(x)
    if x == "=" then
      return ""
    end
    local r, f = "", base64_table:find(x) - 1
    for i = 6, 1, -1 do
      r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0")
    end
    return r
  end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
    if #x ~= 8 then
      return ""
    end
    local c = 0
    for i = 1, 8 do
      c = c + (x:sub(i, i) == "1" and 2 ^ (8 - i) or 0)
    end
    return _string.char(c)
  end))
end
return base64