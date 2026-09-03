local SocialIslandAddsManager = {}
function SocialIslandAddsManager.InitData(adds_table)
  log_tree("SocialIslandAddsManager.InitData", adds_table)
  if not adds_table then
    return
  end
  SocialIslandAddsManager.adds_info = {}
  for k, v in pairs(adds_table) do
    local config = v
    local StringUtil = require("common.string_util")
    local adds_set = StringUtil.Split(config, "|")
    if 1 < #adds_set then
      SocialIslandAddsManager.adds_info = adds_set
      break
    end
  end
end
function SocialIslandAddsManager.GetAddsConfig()
  return SocialIslandAddsManager.adds_info
end
return SocialIslandAddsManager