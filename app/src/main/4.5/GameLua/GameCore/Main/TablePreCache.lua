local TablePreCache = {}
function TablePreCache.Init(gameStatus)
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  print(bWriteLog and "OnUIModePreSwitch MatchModeMgrSystem nInGameModeID", MatchModeMgrSystem.nInGameModeID)
  local TableModName = ""
  local DataTableInheritanceMods
  if gameStatus == "Training" or gameStatus == "Fighting" then
    local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
    local ModType = GameMainConfig.GetModType()
    if ModType == "BaseMod" or ModType == "Default" then
      TableModName = "EvoBase"
    elseif ModType then
      TableModName = ModType
    end
    DataTableInheritanceMods = GameMainConfig.GetTableInheritanceExtraModules()
  end
  CDataTable.SetModName(TableModName, DataTableInheritanceMods)
  print(bWriteLog and "SetModName: ", TableModName)
  if DataTableInheritanceMods then
    for i = 1, #DataTableInheritanceMods do
      print(bWriteLog and "SetModName InheritanceMod: ", i, DataTableInheritanceMods[i])
    end
  end
end
return TablePreCache