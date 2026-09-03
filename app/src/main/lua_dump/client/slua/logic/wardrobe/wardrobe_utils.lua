local WardrobeConfig = require("client.slua.umg.Wardrobe.wardrobe_config")
local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
local Weapon = wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Weapon
local Vehicle = wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Vehicle
local WardrobeUtils = {}
function WardrobeUtils.InitSubTabConfig()
  if WardrobeConfig.InitSubTabConfig then
    return
  end
  WardrobeConfig.InitSubTabConfig = true
  local weapon = {}
  local armoryTable = CDataTable.GetTable("ArmoryConfig")
  for _, v in pairs(armoryTable) do
    if not weapon[v.WeaponType] then
      weapon[v.WeaponType] = {}
    end
    weapon[v.WeaponType][v.WeaponID] = 1
    WardrobeUtils.AddSubTabs(Weapon, v.WeaponID)
  end
  WardrobeConfig.Tab_Structure[Weapon] = weapon
  local vehicle = {}
  local WardrobeVehiclesTaxonomy = CDataTable.GetTable("WardrobeVehiclesTaxonomy")
  for _, v in pairs(WardrobeVehiclesTaxonomy) do
    if v.VehicleDefualtSkinID ~= DataMgr.defaultWingmanSkinResID then
      if not vehicle[v.CategoryID] then
        vehicle[v.CategoryID] = {}
      end
      vehicle[v.CategoryID][v.WardrobeTab] = 1
      WardrobeUtils.AddSubTabs(Vehicle, v.WardrobeTab)
    end
  end
  WardrobeConfig.Tab_Structure[Vehicle] = vehicle
end
function WardrobeUtils.GetTabStructure(pageID)
  WardrobeUtils.InitSubTabConfig()
  return WardrobeConfig.Tab_Structure[pageID]
end
function WardrobeUtils.GetTabConfig()
  return WardrobeConfig.PageTab_Config
end
function WardrobeUtils.GetSubTabConfig()
  WardrobeUtils.InitSubTabConfig()
  return WardrobeConfig.SubTab_Config
end
function WardrobeUtils.GetSubTabConfigByPageID(pageID)
  WardrobeUtils.InitSubTabConfig()
  return WardrobeConfig.SubTab_Config[pageID].subTabs
end
function WardrobeUtils.AddSubTabs(pageID, subTabID)
  if not WardrobeConfig.SubTab_Config[pageID] then
    return
  end
  WardrobeConfig.SubTab_Config[pageID].subTabs = WardrobeConfig.SubTab_Config[pageID].subTabs or {}
  table.insert(WardrobeConfig.SubTab_Config[pageID].subTabs, {subTabID = subTabID})
end
function WardrobeUtils.ClearSubTabs()
  if WardrobeConfig.SubTab_Config[Weapon] then
    WardrobeConfig.SubTab_Config[Weapon].subTabs = {}
  end
  if WardrobeConfig.SubTab_Config[Vehicle] then
    WardrobeConfig.SubTab_Config[Vehicle].subTabs = {}
  end
  WardrobeConfig.PageID_To_SubTabDataList = {}
  WardrobeConfig.InitSubTabConfig = false
end
function WardrobeUtils.GetSuitAdditionalPart(additionalPart)
  local result = {}
  if not additionalPart or additionalPart == "" then
    return result
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local StringUtil = require("common.string_util")
  local parts = StringUtil.Split(additionalPart, "|")
  if 0 < #parts then
    for _, idGroup in pairs(parts) do
      if idGroup ~= "" then
        local group = StringUtil.Split(idGroup, ";")
        if 0 < #group then
          local def = group[1]
          for i = #group, 1, -1 do
            local itemList = wardrobe_data:GetHallDepotItemListByResID(tonumber(group[i]) or 0)
            if 0 < #itemList then
              def = group[i]
              break
            end
          end
          table.insert(result, def)
        end
      end
    end
  end
  log(bWriteLog and string.format("WardrobeUtils.GetSuitAdditionalPart additionalPart = %s", additionalPart))
  log_tree("WardrobeUtils.GetSuitAdditionalPart", result)
  return result
end
function WardrobeUtils.CanInitSubTab(subTabConfig)
  local region = Client.GetPublishRegion()
  if string.find(subTabConfig.shieldedRegion, region) ~= nil then
    return false
  end
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if subTabConfig.subTabId == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_MiniTVSuit then
    return WardrobeUtils.MiniTvCanShow()
  end
  if subTabConfig.subTabId == wardrobe_macro.ENUM_WardrobeSubTabString.Enum_WardrobeSubTabString_Beard then
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    if AvatarData.GetGameGender() == LobbyAvatarManager.Enum_Sex.Female then
      return false
    end
  end
  return true
end
function WardrobeUtils.MiniTvCanShow()
  local tvStatus = LobbySystem.CheckOpen(BP_ENUM_LOBBY_MINI_TV_CLOTHE)
  if not tvStatus then
    log(bWriteLog and "WardrobeUtils.MiniTvCanShow: BP_ENUM_LOBBY_MINI_TV_CLOTHE" .. tostring(tvStatus))
    return false
  end
  return true
end
return WardrobeUtils