local logic_chat_short_table_pool = {}
local table_pool = require("common.table_pool")
local tablePool = table_pool.Create()
function logic_chat_short_table_pool.Get()
  return tablePool:Get()
end
function logic_chat_short_table_pool.Recycle(element)
  tablePool:Recycle(element)
end
function logic_chat_short_table_pool.RecycleAll(elements)
  tablePool:RecycleAll(elements)
end
return logic_chat_short_table_pool