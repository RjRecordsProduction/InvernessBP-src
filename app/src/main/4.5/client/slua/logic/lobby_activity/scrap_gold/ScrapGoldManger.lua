local ScrapGoldManger = {}
function ScrapGoldManger:ReqActInfo(ActivityId)
  log(bWriteLog and "[SY]ScrapGoldManger:ReqActInfo." .. tostring(ActivityId))
  local logic_scrapgold_draw = require("client.slua.logic.lobby_activity.logic_scrapgold_draw")
  logic_scrapgold_draw.ReqActInfo(ActivityId)
end
function ScrapGoldManger:OnLogOut()
  log(bWriteLog and "[SY]ScrapGoldManger:OnLogOut")
  local logic_scrapgold_draw = require("client.slua.logic.lobby_activity.logic_scrapgold_draw")
  logic_scrapgold_draw.ClearPoolData()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLuckyModule = class(CModuleBase, nil, ScrapGoldManger)
return CLuckyModule