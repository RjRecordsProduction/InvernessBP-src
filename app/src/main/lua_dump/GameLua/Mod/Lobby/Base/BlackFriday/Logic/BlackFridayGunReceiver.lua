local BlackFridayGunReceiver = {ext_info = nil}
function BlackFridayGunReceiver.OnGetDrawInfo(_, pool_info, price_info, ext_info)
  log(bWriteLog and "BlackFridayGunReceiver.OnGetDrawInfo.")
  log_tree("BlackFridayGunReceiver.OnGetDrawInfo. ext_info:", ext_info)
  BlackFridayGunReceiver.end
function BlackFridayGunReceiver.OnDoDrawActRsp(_, item_list, decompose_list, ext_info)
end
function BlackFridayGunReceiver.OnDrawSumRsp(_, award_list)
end
return BlackFridayGunReceiver