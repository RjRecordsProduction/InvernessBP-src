local chat_message_procesor = {}
local table_pool = require("common.table_pool")
local tablePool = table_pool.Create()
local state = {
  normal = 1,
  ttopic = 2,
  ftopic = 3,
  atuser = 4
}
local code_at = utf8.codepoint("@")
local code_topic = utf8.codepoint("#")
local stop_atuser_string = " \n\t\v\f"
local stop_ttopic_string = " -/:\239\188\154;\239\188\155(\239\188\136)\239\188\137$&@\"\226\128\156\226\128\157.\227\128\130,\239\188\140?\239\188\159!\239\188\129][{}%^*+=_\\|~<>\226\130\172\194\163\194\165\226\128\162\227\128\129"
local stop_atuser_symbol = {}
local stop_ttopic_symbol = {}
for _, code in utf8.codes(stop_atuser_string) do
  stop_atuser_symbol[code] = true
end
for _, code in utf8.codes(stop_ttopic_string) do
  stop_ttopic_symbol[code] = true
end
local change = function(context, pos, old_state, new_state)
  if pos > context.pos then
    local element = tablePool:Get()
    element.state = old_state
    element.context_pos = context.pos
    element.pre_pos = pos - 1
    context.list[#context.list + 1] = element
    context.  end
  return new_state
end
local machine = {
  [state.normal] = function(context, pos, code)
    if code == code_at then
      return change(context, pos, state.normal, state.atuser)
    end
    if code == code_topic then
      return change(context, pos, state.normal, state.ttopic)
    end
  end,
  [state.ttopic] = function(context, pos, code)
    if code == code_at then
      return change(context, pos, state.ttopic, state.atuser)
    end
    if code == code_topic then
      return state.ftopic
    end
    if stop_ttopic_symbol[code] then
      return change(context, pos, state.ttopic, state.normal)
    end
  end,
  [state.ftopic] = function(context, pos, code)
    if code == code_at then
      return change(context, pos, state.ttopic, state.atuser)
    end
    if stop_ttopic_symbol[code] then
      return change(context, pos, state.ftopic, state.normal)
    end
  end,
  [state.atuser] = function(context, pos, code)
    if code == code_at then
      return change(context, pos, state.atuser, state.atuser)
    end
    if code == code_topic then
      return change(context, pos, state.atuser, state.ttopic)
    end
    if stop_atuser_symbol[code] then
      return change(context, pos, state.atuser, state.normal)
    end
  end
}
local extract_pos = function(input, b, e)
  local current = state.normal
  local context = tablePool:Get()
  context.list = tablePool:Get()
  context.pos = b or 1
  for pos, code in utf8.codes(input, b, e) do
    current = machine[current](context, pos, code) or current
  end
  change(context, string.len(input) + 1, current)
  return context
end
local extract_str
local callback = {
  [state.normal] = function(_, input, p1, p2)
    if #input == p2 and p1 == 1 then
      return input
    end
    return string.sub(input, p1, p2)
  end,
  [state.ttopic] = function(data, input, p1, p2)
    local topic = string.sub(input, p1 + 1, p2)
    data.topicList[topic] = true
    if p1 == p2 then
      return string.sub(input, p1, p2)
    else
      return string.format("<Topic_Name>%s</>", string.sub(input, p1, p2))
    end
  end,
  [state.ftopic] = function(_, input, p1, p2)
    return string.sub(input, p1, p2)
  end,
  [state.atuser] = function(_, input, p1, p2)
    return string.sub(input, p1, p2)
  end
}
function extract_str(input, data, b, e)
  local sublist = tablePool:Get()
  local context = extract_pos(input, b, e)
  for _, sub in pairs(context.list) do
    sublist[#sublist + 1] = callback[sub.state](data, input, sub.context_pos, sub.pre_pos)
  end
  tablePool:RecycleAll(context.list)
  tablePool:Recycle(context.list)
  tablePool:Recycle(context)
  local res
  if #sublist == 1 then
    res = sublist[1]
  else
    res = table.concat(sublist)
  end
  tablePool:Recycle(sublist)
  return res
end
function chat_message_procesor.GetResultChatMsg(msg)
  if string.find(msg, "#") then
    local data = tablePool:Get()
    data.topicList = tablePool:Get()
    local res = extract_str(msg, data)
    tablePool:Recycle(data.topicList)
    tablePool:Recycle(data)
    return res
  end
  return msg
end
return chat_message_procesor