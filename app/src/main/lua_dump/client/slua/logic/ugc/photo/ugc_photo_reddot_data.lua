local ugc_photo_reddot_data = {}
local RedDot
local bIsInited = false
local RedDotType = {CustomPhoto = 1}
local bFinishClick = false
local GenerateData = function()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local Category = reddot_macro.Category
  local data = {
    newCount = 0,
    desc = reddot_macro.SystemName.UGCPhoto,
    types = {
      newCount = 0,
      [RedDotType.CustomPhoto] = {
        newCount = 0,
        category = Category.NewArrivals,
        subID = RedDotType.CustomPhoto
      }
    }
  }
  return data
end
function ugc_photo_reddot_data.InitData()
  if bIsInited then
    return
  end
  bIsInited = true
  local data = GenerateData()
  local super_data = require("common.super_data")
  if RedDot == nil then
    RedDot = super_data.CreateSuperData(data)
  end
  local RedDotManager = require("client.slua.logic.reddot.reddot_manager")
  RedDotManager:Regist(RedDot)
end
function ugc_photo_reddot_data.DestroyData()
  RedDot = nil
  bIsInited = false
  bFinishClick = false
end
function ugc_photo_reddot_data.GetData()
  return RedDot
end
function ugc_photo_reddot_data.OnLogin()
  log(bWriteLog and "ugc_photo_reddot_data OnLogin")
  ugc_photo_reddot_data.InitData()
end
function ugc_photo_reddot_data.OnLogout()
  log(bWriteLog and "ugc_photo_reddot_data OnLogout")
  ugc_photo_reddot_data.DestroyData()
end
function ugc_photo_reddot_data.GetCustomPhotoRedDotData()
  if RedDot then
    return RedDot.types[RedDotType.CustomPhoto]
  end
end
function ugc_photo_reddot_data.UpdateCustomPhotoRedDot()
  if RedDot then
    print(bWriteLog and "ugc_photo_reddot_data.UpdateCustomPhotoRedDot", bFinishClick, DataMgr.ugc_author_info.custom_pic_auth, RedDot.types[RedDotType.CustomPhoto].newCount)
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if not bFinishClick and DataMgr.ugc_author_info.custom_pic_auth and not PublishRegionMacros.IsBLUEHOLE() then
      local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      local Data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCCustomPhotoRedDot)
      if not Data then
        RedDot.types[RedDotType.CustomPhoto].newCount = 1
      else
        RedDot.types[RedDotType.CustomPhoto].newCount = 0
      end
    else
      RedDot.types[RedDotType.CustomPhoto].newCount = 0
    end
  end
end
function ugc_photo_reddot_data.ClearCustomPhotoRedDot()
  if RedDot and RedDot.types[RedDotType.CustomPhoto].newCount == 1 then
    print(bWriteLog and "ugc_photo_reddot_data.ClearCustomPhotoRedDot")
    bFinishClick = true
    RedDot.types[RedDotType.CustomPhoto].newCount = 0
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    PlayerPrefsSystem.SaveTableToFile_N({bFinish = true}, PlayerPrefsSystem.ePlayerPrefsType.eUGCCustomPhotoRedDot)
  end
end
return ugc_photo_reddot_data