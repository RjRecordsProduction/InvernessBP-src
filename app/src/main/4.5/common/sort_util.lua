local sort_util = {}
local local local local max = math.maxinteger
function sort_util.SortByNumber(tb, low, ...)
  local fields = table.pack(...)
  local allNum = fields.n
  local sortFunc = function(a, b)
    for index = 1, allNum do
      local field = fields[index]
      local aValue = a[field] or max
      local bValue = b[field] or max
      if index == allNum or aValue ~= bValue then
        if low then
          return aValue > bValue
        else
          return aValue < bValue
        end
      end
    end
  end
  table.sort(tb, sortFunc)
end
function sort_util.SortByRule(tb, RuleTb, ...)
  local fields = table.pack(...)
  local allNum = fields.n
  local sortFunc = function(a, b)
    for index = 1, allNum do
      local field = fields[index]
      local aValue = a[field] or max
      local bValue = b[field] or max
      local rule = RuleTb[field]
      if rule then
        aValue = rule[aValue] or max
        bValue = rule[bValue] or max
      end
      if index == allNum or aValue ~= bValue then
        return aValue < bValue
      end
    end
  end
  table.sort(tb, sortFunc)
end
return sort_util