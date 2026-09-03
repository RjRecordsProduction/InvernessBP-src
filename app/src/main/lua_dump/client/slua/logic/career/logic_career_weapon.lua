local Logic_Career = require("client.slua.logic.career.logic_career")
local ConstCareer = require("client.slua.logic.career.const_career")
local Logic_WardrobeGun = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
local Logic_Career_Weapon = {}
local _tWeaponShowList
local E_CareerModule = ConstCareer.E_CareerModule
local E_WeaponType = ConstCareer.E_WeaponType
function Logic_Career_Weapon.GetWeaponShowList()
  if not _tWeaponShowList then
    local tTempData = Logic_Career.GetConfig(Logic_Career.C_ServerConfigs.Weapon)
    if not tTempData then
      return
    end
    _tWeaponShowList = {}
    for k, v in pairs(tTempData) do
      if v.is_show == 1 then
        _tWeaponShowList[k] = 1
      end
    end
  end
  return _tWeaponShowList
end
function Logic_Career_Weapon.GetWeaponPro(nWeaponId)
  local tAllWeaponData = Logic_Career.GetModuleData(E_CareerModule.Weapon)
  if tAllWeaponData[nWeaponId] then
    return tAllWeaponData[nWeaponId].pro or 0
  end
  return 0
end
function Logic_Career_Weapon.GetWeaponMedal(nWeaponId)
  local tAllWeaponData = Logic_Career.GetModuleData(E_CareerModule.Weapon)
  if tAllWeaponData[nWeaponId] then
    return tAllWeaponData[nWeaponId].medal or 0
  end
  return 0
end
function Logic_Career_Weapon.GetAllWeaponDetailsData(nShowType)
  local nShowUserId = Logic_Career.GetShowUserId()
  if not nShowUserId then
    return
  end
  if not Logic_WardrobeGun:HasGunSkinList() then
    Logic_WardrobeGun:GetGunSkinListReq()
  end
  local nModuleId = E_CareerModule.Weapon
  local bIsSeason = Logic_Career.GetIsSeason(nModuleId, nShowType)
  local tDetailedData = Logic_Career.GetModuleDetailedData(nModuleId, bIsSeason)
  if not tDetailedData then
    Logic_Career.ReqModuleInfo(nModuleId, nShowType, nShowUserId, bIsSeason)
    return
  end
  local tShowData = Logic_Career.GetModuleSubTypeAllItem(nModuleId, nShowType, bIsSeason)
  if not tShowData then
    tShowData = {}
    local tTempData = Logic_Career_Weapon.GetWeaponShowList()
    if not tTempData then
      return
    end
    if nShowType == E_WeaponType.All then
      for k, _ in pairs(tTempData) do
        table.insert(tShowData, k)
      end
    else
      local tGunConfig = Logic_WardrobeGun:GetAllGun()
      for _, v in pairs(tGunConfig[nShowType]) do
        if tTempData[v.WeaponID] then
          table.insert(tShowData, v.WeaponID)
        end
      end
    end
    local tModuleData = Logic_Career.GetModuleData(nModuleId)
    table.sort(tShowData, function(a, b)
      local nProValue_A = tModuleData[a] and tModuleData[a].pro or 0
      local nProValue_B = tModuleData[b] and tModuleData[b].pro or 0
      return nProValue_A > nProValue_B
    end)
    Logic_Career.SetModuleSubTypeAllItem(E_CareerModule.Weapon, nShowType, tShowData, bIsSeason)
  end
  return tShowData
end
function Logic_Career_Weapon.SetWeaponIcon(Image_Icon, nWeaponId)
  if not Image_Icon then
    return
  end
  local util = require("client.slua_ui_framework.util")
  if Logic_Career.IsSelfCareer() then
    local logic_wardrobe_gun = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
    local nSkinInsID = logic_wardrobe_gun:GetSkinIdByWeaponID(nWeaponId)
    if not nSkinInsID or nSkinInsID == 0 then
      local UIUtil = require("client.common.ui_util")
      util.SetTexture(Image_Icon, UIUtil.GetItemBigIcon(nWeaponId))
    else
      do
        local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
        local tItemData = wardrobe_data:GetValidHallDepotItemDataByInsID(nSkinInsID)
        local nSkinItemId = tItemData and tItemData.resID or 0
        local logic_weapon_diy = require("client.slua.logic.weapon_diy.logic_weapon_diy")
        local nCurPlanId = logic_weapon_diy:GetCurUsePlanIdByWeaponId(nSkinItemId)
        if nCurPlanId and nCurPlanId ~= 0 and nSkinItemId ~= 0 then
          local callback = function(texturePath, planID)
            if not slua.isValid(Image_Icon) then
              return
            end
            local curUsePlanId = logic_weapon_diy:GetCurUsePlanIdByWeaponId(nSkinInsID)
            if curUsePlanId ~= nil and curUsePlanId ~= planID then
              return
            end
            local LoadTexture = import("LoadTexture")
            local Texture = LoadTexture.GetTexture2DFromDiskFile(texturePath)
            if Texture then
              Image_Icon:SetBrushFromTexture(Texture, false)
            end
          end
          local WeaponDiySystem = require("client.slua.logic.weapon_diy.logic_weapon_diy")
          local scheme = WeaponDiySystem:GetSchemeData(nSkinItemId, nCurPlanId)
          local WeaponDIYCapture = require("client.slua.logic.weapon_diy.logic_weapon_capture_weapon")
          WeaponDIYCapture:GetWeaponIconTexture(nSkinItemId, nCurPlanId, WeaponDIYCapture.scene.diy_main, scheme, false, callback)
        else
          do
            local UIUtil = require("client.common.ui_util")
            util.SetTexture(Image_Icon, UIUtil.GetItemBigIcon(nSkinItemId))
          end
        end
      end
    end
  else
    local UIUtil = require("client.common.ui_util")
    util.SetTexture(Image_Icon, UIUtil.GetItemBigIcon(nWeaponId))
  end
end
return Logic_Career_Weapon