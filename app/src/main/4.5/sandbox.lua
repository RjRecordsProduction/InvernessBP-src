sandbox = sandbox or {}
local var2string = function(var)
  local text = tostring(var)
  return text
end
local function tab2string(visited, path, base, tab)
  local pre = visited[tab]
  if pre then
    return pre
  end
  visited[tab] = path
  local size = 0
  for k, v in pairs(tab) do
    size = size + 1
  end
  if size == 0 then
    return "{ }"
  end
  local lines = {}
  local idx = 1
  for k, v in pairs(tab) do
    local vtype = type(v)
    local header = string.format("%s%s%s", base, size > idx and "\226\148\156\226\148\128 " or "\226\148\148\226\148\128 ", tostring(k))
    if vtype == "table" then
      local vpath = visited[v]
      if vpath then
        lines[#lines + 1] = string.format("%s: %s", header, vpath)
      else
        local out = tab2string(visited, string.format("%s/%s", path, tostring(k)), string.format("%s%s", base, size > idx and "\226\148\130  " or "   "), v)
        if type(out) == "string" then
          lines[#lines + 1] = string.format("%s: %s", header, out)
        else
          lines[#lines + 1] = header
          for _, one in ipairs(out) do
            table.insert(lines, one)
          end
        end
      end
    else
      local txt = var2string(v)
      if vtype == "string" then
        txt = string.format("\"%s\"", txt)
      end
      lines[#lines + 1] = header .. ": " .. txt
    end
    idx = idx + 1
  end
  return lines
end
function _G.dump(object)
  if Client and not bWriteLog then
    return
  end
  if type(object) == "table" then
    local s = "{ "
    local first = true
    for k, v in pairs(object) do
      local nextStr = k .. ":" .. dump(v)
      if not first then
        nextStr = ", " .. nextStr
      end
      s = s .. nextStr
      first = false
    end
    return s .. " }"
  end
  return tostring(object)
end
function _G.DeepCopy(src)
  local InTable = {}
  local function Func(obj)
    if type(obj) ~= "table" then
      return obj
    end
    local NewTable = {}
    InTable[obj] = NewTable
    for k, v in pairs(obj) do
      NewTable[Func(k)] = Func(v)
    end
    return setmetatable(NewTable, getmetatable(obj))
  end
  return Func(src)
end
function _G.Table2String(tab)
  if tab then
    local visited = {}
    local out = tab2string(visited, "", "", tab)
    if type(out) == "string" then
      return out
    end
    local str = ""
    for i, line in ipairs(out) do
      str = str .. line .. "\n"
    end
    return str
  else
    return "null"
  end
end