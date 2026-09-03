local ugc_playlevel_reddot_data = {}
local RedDot
local bIsInited = false
local RedDotType = {
  WOW = 1,
  Play = 1,
  AuthorHome = 2,
  Skin = 3,
  Honor = 4
}
local config_ugc_authorhome = require("client.slua.umg.ugc.AuthorHome.config_ugc_authorhome")
local GenerateData = function()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local Category = reddot_macro.Category
  local data = {
    newCount = 0,
    desc = reddot_macro.SystemName.UGCWOWPlay,
    types = {
      newCount = 0,
      [RedDotType.WOW] = {
        newCount = 0,
        category = Category.Receive,
        subID = RedDotType.WOW,
        pages = {
          newCount = 0,
          [RedDotType.Play] = {
            newCount = 0,
            subID = RedDotType.Play,
            category = Category.Receive
          },
          [RedDotType.AuthorHome] = {
            newCount = 0,
            subID = RedDotType.AuthorHome,
            category = Category.Receive,
            pages = {
              newCount = 0,
              [RedDotType.Honor] = {
                newCount = 0,
                subID = RedDotType.AuthorHome,
                category = Category.Receive,
                pages = {
                  newCount = 0,
                  [config_ugc_authorhome.C_HonorGroupID.All] = {
                    newCount = 0,
                    subID = RedDotType.AuthorHome,
                    category = Category.Receive,
                    pages = {
                      newCount = 0,
                      category = Category.Receive,
                      isDynamic = true
                    }
                  },
                  [config_ugc_authorhome.C_HonorGroupID.HonorCreate] = {
                    newCount = 0,
                    subID = RedDotType.AuthorHome,
                    category = Category.Receive,
                    pages = {
                      newCount = 0,
                      category = Category.Receive,
                      isDynamic = true
                    }
                  },
                  [config_ugc_authorhome.C_HonorGroupID.HonorSeason] = {
                    newCount = 0,
                    subID = RedDotType.AuthorHome,
                    category = Category.Receive,
                    pages = {
                      newCount = 0,
                      category = Category.Receive,
                      isDynamic = true
                    }
                  }
                }
              },
              [RedDotType.Skin] = {
                newCount = 0,
                subID = RedDotType.Skin,
                category = Category.Receive
              }
            }
          }
        }
      }
    }
  }
  return data
end
function ugc_playlevel_reddot_data.InitData()
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
function ugc_playlevel_reddot_data.DestroyData()
  RedDot = nil
  bIsInited = false
end
function ugc_playlevel_reddot_data.GetData()
  if not RedDot then
    RedDot = ugc_playlevel_reddot_data.InitData()
  end
  return RedDot
end
function ugc_playlevel_reddot_data.GetPlayData()
  if RedDot then
    return RedDot.types[RedDotType.WOW].pages[RedDotType.Play]
  end
end
function ugc_playlevel_reddot_data.UpdateWOWCount(count)
  if RedDot then
    RedDot.groupShow = true
    RedDot.types[RedDotType.WOW].newCount = count
  end
end
function ugc_playlevel_reddot_data.UpdatePlayDataCount(count)
  if RedDot then
    RedDot.groupShow = true
    RedDot.types[RedDotType.WOW].pages[RedDotType.Play].newCount = count
  end
end
function ugc_playlevel_reddot_data.GetAuthorHomeData()
  if RedDot then
    return RedDot.types[RedDotType.WOW].pages[RedDotType.AuthorHome]
  end
end
function ugc_playlevel_reddot_data.GetAuthorHomeSubTabRedDot(tabID)
  if RedDot then
    return RedDot.types[RedDotType.WOW].pages[RedDotType.AuthorHome].pages[RedDotType.Honor].pages[tabID]
  end
end
function ugc_playlevel_reddot_data.GetAuthorHomeSubRedDotData(tabID, HonorID)
  if RedDot then
    if RedDot.types[RedDotType.WOW].pages[RedDotType.AuthorHome].pages[RedDotType.Honor].pages[tabID] then
      return RedDot.types[RedDotType.WOW].pages[RedDotType.AuthorHome].pages[RedDotType.Honor].pages[tabID].pages[HonorID]
    else
      log(bWriteLog and "ugc_playlevel_reddot_data GetAuthorHomeSubRedDotData tabID not found  tabID = " .. tostring(tabID) .. "  honorID = " .. tostring(HonorID))
      return nil
    end
  end
end
local GenSubAuthorHomeData = function(Desc)
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local data = {
    newCount = 0,
    category = reddot_macro.Category.Receive,
    desc = Desc,
    subID = RedDotType.AuthorHome,
    instanceId = {_isLeaf = true}
  }
  return data
end
function ugc_playlevel_reddot_data.AddAuthorHomeRedDotData(tabID, HonorID, Desc)
  if RedDot then
    RedDot.groupShow = true
    if not RedDot.types[RedDotType.WOW].pages[RedDotType.AuthorHome].pages[RedDotType.Honor].pages[tabID].pages[HonorID] then
      RedDot.types[RedDotType.WOW].pages[RedDotType.AuthorHome].pages[RedDotType.Honor].pages[tabID].pages[HonorID] = GenSubAuthorHomeData(Desc or tostring(HonorID))
    end
  end
end
function ugc_playlevel_reddot_data.UpdateAuthorHomeRedDotData(tabID, HonorID, bIsShow)
  if RedDot then
    RedDot.groupShow = true
    if RedDot.types[RedDotType.WOW].pages[RedDotType.AuthorHome].pages[RedDotType.Honor].pages[tabID].pages[HonorID] then
      RedDot.types[RedDotType.WOW].pages[RedDotType.AuthorHome].pages[RedDotType.Honor].pages[tabID].pages[HonorID].instanceId[HonorID] = bIsShow
    else
      log(bWriteLog and "ugc_playlevel_reddot_data UpdateAuthorHomeRedDotData honorID not found  tabID = " .. tabID .. "  honorID = " .. HonorID .. " bShow = " .. tostring(bIsShow) .. "")
    end
    if RedDot.types[RedDotType.WOW].pages[RedDotType.AuthorHome].pages[RedDotType.Honor].pages[config_ugc_authorhome.C_HonorGroupID.All].pages[HonorID] then
      RedDot.types[RedDotType.WOW].pages[RedDotType.AuthorHome].pages[RedDotType.Honor].pages[config_ugc_authorhome.C_HonorGroupID.All].pages[HonorID].instanceId[HonorID] = bIsShow
    else
      log(bWriteLog and "ugc_playlevel_reddot_data UpdateAuthorHomeRedDotData honorID not found  tabID = " .. tabID .. "  honorID = " .. HonorID .. " bShow = " .. tostring(bIsShow) .. "")
    end
  end
end
function ugc_playlevel_reddot_data.GetAuthorHomeRedDot(honorID)
  if RedDot then
    if RedDot.types[RedDotType.WOW].pages[RedDotType.AuthorHome].pages[RedDotType.Honor].pages[config_ugc_authorhome.C_HonorGroupID.All].pages[honorID] then
      return RedDot.types[RedDotType.WOW].pages[RedDotType.AuthorHome].pages[RedDotType.Honor].pages[config_ugc_authorhome.C_HonorGroupID.All].pages[honorID].instanceId[honorID] or false
    end
    log(bWriteLog and "ugc_playlevel_reddot_data GetAuthorHomeRedDot honorID not found")
    return false
  end
end
function ugc_playlevel_reddot_data.UpdateSkinRedDot(count)
  if RedDot then
    RedDot.types[RedDotType.WOW].pages[RedDotType.AuthorHome].pages[RedDotType.Skin].newCount = count
  end
end
function ugc_playlevel_reddot_data.GetHonorRedDot()
  if RedDot then
    return RedDot.types[RedDotType.WOW].pages[RedDotType.AuthorHome].pages[RedDotType.Honor]
  end
end
function ugc_playlevel_reddot_data.OnLogin()
  log(bWriteLog and "ugc_playlevel_reddot_data OnLogin")
  ugc_playlevel_reddot_data.InitData()
end
function ugc_playlevel_reddot_data.OnLogout()
  log(bWriteLog and "ugc_playlevel_reddot_data OnLogout")
  ugc_playlevel_reddot_data.DestroyData()
end
return ugc_playlevel_reddot_data