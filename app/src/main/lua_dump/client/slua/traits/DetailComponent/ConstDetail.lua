local ConstDetail = {
  DetailCompDefaultConfig = {
    name = true,
    quality = true,
    desc = true,
    limitTime = true,
    levelUp = true,
    stateChange = true,
    goResearch = true,
    petDetail = true,
    limitBuy = true,
    feature = true,
    featureButton = true,
    inventory = true,
    vehicleSpByJK = true,
    vehicle = true,
    superCarDoorSlot = true,
    disableStar = true,
    view = true,
    black5 = false,
    rp = false,
    characterTrans = true,
    boxDropList = false,
    boxDropRate = false,
    banJump = false,
    cavrioletBtnSlot = true,
    useDepotHideSetting = false,
    carCompose = false,
    noDefaultEquip = false,
    bVideoRestoreMusic = true,
    DetailViewCompDefaultConfig = {
      weapon = true,
      sex = true,
      recover = true,
      preview = false,
      pet = true,
      car = true,
      enlarge = true,
      DefaultEnlarge = true,
      videoBtn = false,
      superCarDoorSlot = true,
      kdpPreview = false,
      sportCarInstruction = true,
      closeDirectly = false,
      closePreview = true,
      changeHeadPreview = false,
      cavrioletBtnSlot = true,
      bVideoRestoreMusic = true,
      fullScreen = false
    },
    DetailDetailItemListConfig = {
      moreButton = true,
      selectProductName = true,
      showDefaultSelect = false,
      JKDontJumpH5Rate = false
    },
    DetailFeatureCompConfig = {
      skipAutoEnterEmotionFullScreen = true,
      sacredSuitAutoEnterEmotion = true,
      skipAutoPlayVideo = true,
      closeDirectly = false,
      bVideoRestoreMusic = true,
      fullScreen = false
    }
  },
  GeneralPreviewDefaultConfig = {
    limitTime = false,
    goResearch = false,
    petDetail = false,
    limitBuy = false,
    preview = false,
    inventory = false,
    enlarge = false,
    DefaultEnlarge = true,
    recover = false,
    car = false,
    black5 = false,
    boxDropList = false,
    boxDropRate = false,
    rp = false,
    carCompose = false,
    noDefaultEquip = false
  },
  GeneralPreviewDefaultCloseConfig = {
    detail = true,
    limitTime = false,
    goResearch = false,
    petDetail = false,
    limitBuy = false,
    preview = false,
    inventory = false,
    enlarge = false,
    recover = false,
    car = false,
    black5 = false,
    feature = false,
    name = false,
    quality = false,
    desc = false,
    levelUp = false,
    stateChange = false,
    vehicle = false,
    superCarDoorSlot = false,
    disableStar = false,
    sex = false,
    weapon = false,
    boxDropList = false,
    boxDropRate = false,
    cavrioletBtnSlot = false,
    useDepotHideSetting = false,
    carCompose = false
  },
  TabSwitchConfig = {
    [StoreConst.Page_New_ID_Weapon] = {
      switch = {
        preview = true,
        videoBtn = true,
        closeDirectly = true
      }
    },
    [StoreConst.Page_New_ID_Car] = {
      switch = {
        preview = true,
        videoBtn = true,
        closeDirectly = true
      }
    },
    [StoreConst.Page_New_ID_Other] = {
      [StoreConst.subtype_new_other_gli] = {
        switch = {goResearch = false}
      },
      [StoreConst.subtype_new_other_wow] = {
        switch = {}
      },
      switch = {preview = true}
    },
    [StoreConst.Page_New_ID_Treasure] = {
      switch = {videoBtn = true, closeDirectly = true}
    },
    [StoreConst.Page_New_ID_Recommend] = {
      [StoreConst.subtype_new_recommend_rec] = {
        switch = {
          videoBtn = true,
          kdpPreview = true,
          moreButton = false,
          selectProductName = false,
          closeDirectly = true,
          characterTrans = false
        }
      },
      [StoreConst.subtype_new_recommend_ucb] = {
        switch = {}
      },
      [StoreConst.subtype_new_recommend_col] = {
        switch = {
          videoBtn = true,
          skipAutoEnterEmotionFullScreen = false,
          sacredSuitAutoEnterEmotion = false,
          skipAutoPlayVideo = false,
          closeDirectly = true
        }
      },
      [StoreConst.subtype_new_recommend_lim] = {
        switch = {
          videoBtn = true,
          skipAutoEnterEmotionFullScreen = false,
          sacredSuitAutoEnterEmotion = false,
          skipAutoPlayVideo = false,
          closeDirectly = true
        }
      },
      [StoreConst.subtype_new_recommend_lim_In] = {
        switch = {
          videoBtn = true,
          skipAutoEnterEmotionFullScreen = false,
          sacredSuitAutoEnterEmotion = false,
          skipAutoPlayVideo = false,
          closeDirectly = true
        }
      },
      switch = {videoBtn = true, closeDirectly = true}
    },
    [StoreConst.Page_ID_Collect] = {
      switch = {
        videoBtn = true,
        skipAutoEnterEmotionFullScreen = false,
        sacredSuitAutoEnterEmotion = false,
        skipAutoPlayVideo = false,
        closeDirectly = true
      }
    }
  }
}
function ConstDetail.GetDefaultConfig()
  local config = {}
  for k, v in pairs(ConstDetail.GeneralPreviewDefaultConfig) do
    config[k] = v
  end
  return config
end
function ConstDetail.GetDefaultCloseConfig()
  local config = {}
  for k, v in pairs(ConstDetail.GeneralPreviewDefaultCloseConfig) do
    config[k] = v
  end
  return config
end
function ConstDetail.GetStoreTabSwitchConfig(tabId, subTabId)
  if ConstDetail.TabSwitchConfig[tabId] then
    if ConstDetail.TabSwitchConfig[tabId][subTabId] then
      return ConstDetail.TabSwitchConfig[tabId][subTabId].switch or {}
    end
    return ConstDetail.TabSwitchConfig[tabId].switch or {}
  end
  return {}
end
return ConstDetail