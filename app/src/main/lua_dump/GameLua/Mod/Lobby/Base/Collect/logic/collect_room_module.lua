local collect_room_module = {}
function collect_room_module:DefineAndResetData()
  self.badgeTb = {}
end
function collect_room_module:SetBadgeData(badge_list)
  local TableUtil = require("common.table_util")
  self.badgeTb = TableUtil.CopyTable(badge_list or {})
  local badgeTb = self.badgeTb
  for id, v in pairs(badgeTb) do
    if not v.slot_ids then
      badgeTb[id] = nil
    end
  end
end
function collect_room_module:OnChangeBadgeData(badge_detail)
  log_tree("  collect_module:OnChangeBadgeData. badge_detail ", badge_detail)
  self.badgeTb = badge_detail
end
function collect_room_module:GetBadgeData()
  return self.badgeTb or {}
end
function collect_room_module:CheckStickerDetectionFlag()
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if collect_module.collect_data then
    log(bWriteLog and string.format("collect_room_module:CheckStickerDetectionFlag. self.collect_data.detection_flag: %s", collect_module.collect_data.detection_flag))
    return collect_module.collect_data.detection_flag
  end
  log(bWriteLog and string.format("collect_room_module:CheckStickerDetectionFlag. self.collect_data.detection_flag = false"))
  return false
end
function collect_room_module:SetStickerDetectionFlag(flag)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  log(bWriteLog and string.format("collect_room_module:SetStickerDetectionFlag flag = %s", flag))
  if collect_module.collect_data then
    collect_module.collect_data.detection_  end
end
function collect_room_module:OnChangeBg(bg_id)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  collect_module.collect_data.cur_sticker_bg = bg_id
end
function collect_room_module:OnChangeFrame(bg_id)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  collect_module.collect_data.cur_sticker_frame = bg_id
end
function collect_room_module:GetAllFrame(subType)
  local ScoreCfg = CDataTable.GetTableByFilter("Item", "ItemType", ENUM_ITEM_TYPE.Collect, "ItemSubType", subType)
  local result = prealloctable(4, 0)
  local len = 0
  if ScoreCfg then
    for id, _ in pairs(ScoreCfg) do
      len = len + 1
      result[len] = tonumber(id)
    end
  else
    log_warning(bWriteLog and "  Collect_Room_DressUp_UIBP:GetAllBg.  error no Data")
    ShowDevNotice("### \231\173\150\229\136\146\233\133\141\231\189\174\233\151\174\233\162\152,\230\159\165\231\137\169\229\147\129\232\161\168")
  end
  log_warning(bWriteLog and "   collect_module:GetAllFrame. len: " .. tostring(len))
  return result
end
function collect_room_module:OtherIsLight(level)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if collect_module:SeasonIsHide() then
    return false
  end
  local CollectLevelCfg = collect_module:GetSplitTableDataByFilter("NewCollectSeasonLevel", collect_module.E_ColCfgMode.JK, "SeasonID", tonumber(DataMgr.season_id), "Level", level)
  return CollectLevelCfg and CollectLevelCfg.ShowSpecial
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, collect_room_module)
return CModuleTemplate