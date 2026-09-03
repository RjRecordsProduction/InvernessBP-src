local logic_lobby_expression = {}
function logic_lobby_expression.GetTauntRandSoundID(emoteId, sex)
  local cfg = CDataTable.GetTableData("ChaoFengSoundConfig", emoteId)
  if cfg == nil then
    return 0
  end
  local xrandom = require("client.common.uibase.xrandom")
  if sex == 1 then
    if 0 >= cfg.soundNumNan then
      return 0
    end
    local id = xrandom.Random2(0, cfg.soundNumNan) + 1
    return id
  else
    if 0 >= cfg.soundNumNv then
      return 0
    end
    local id = xrandom.Random2(0, cfg.soundNumNv) + 1
    return id
  end
end
function logic_lobby_expression.GetExtraInfo(emoteId)
  if emoteId == 12220605 then
    math.randomseed(os.time())
    local randomNumber = math.random(0, 99)
    log(bWriteLog and "logic_lobby_expression.GetExtraInfo " .. tostring(randomNumber))
    return tostring(randomNumber)
  end
  local logic_card_collection = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_card_collection)
  if emoteId == logic_card_collection:GetActionItemID() then
    local version = logic_card_collection:GetSelectActionVersion(DataMgr.roleData.uid)
    log(bWriteLog and "logic_lobby_expression.GetExtraInfo version=" .. tostring(version))
    return version
  end
  return nil
end
return logic_lobby_expression