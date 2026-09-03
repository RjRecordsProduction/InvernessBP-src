local MainCity_Client_GameState_Manager = {bInit = false, bOpen = false}
function MainCity_Client_GameState_Manager.Init()
  print(bWriteLog and "MainCity_Client_GameState_Manager.Init")
  if MainCity_Client_GameState_Manager.bInit then
    return
  end
  MainCity_Client_GameState_Manager.bInit = true
  MainCity_Client_GameState_Manager.mainCityGameStateArray = {}
end
function MainCity_Client_GameState_Manager.Destroy()
  print(bWriteLog and "MainCity_Client_GameState_Manager.Destroy")
  if not MainCity_Client_GameState_Manager.bInit then
    return
  end
  MainCity_Client_GameState_Manager.bInit = false
end
function MainCity_Client_GameState_Manager.AddGameState(gameState)
  log(bWriteLog and "MainCity_Client_GameState_Manager.AddGameState")
  if not MainCity_Client_GameState_Manager.bOpen then
    return
  end
  MainCity_Client_GameState_Manager.Init()
  if gameState then
    log(bWriteLog and "MainCity_Client_GameState_Manager.AddGameState success")
    table.insert(MainCity_Client_GameState_Manager.mainCityGameStateArray, gameState)
  end
end
function MainCity_Client_GameState_Manager.RemoveGameState(gameState)
  log(bWriteLog and "MainCity_Client_GameState_Manager.RemoveGameState")
  if not MainCity_Client_GameState_Manager.bOpen then
    return
  end
  if gameState then
    for i, v in ipairs(MainCity_Client_GameState_Manager.mainCityGameStateArray or {}) do
      if v == gameState then
        log(bWriteLog and "MainCity_Client_GameState_Manager.RemoveGameState success")
        table.remove(MainCity_Client_GameState_Manager.mainCityGameStateArray, i)
        break
      end
    end
  end
end
function MainCity_Client_GameState_Manager.GetGameState()
  log(bWriteLog and "MainCity_Client_GameState_Manager.GetGameState")
  if not MainCity_Client_GameState_Manager.bOpen then
    return nil
  end
  if MainCity_Client_GameState_Manager.mainCityGameStateArray == nil or not next(MainCity_Client_GameState_Manager.mainCityGameStateArray) then
    return nil
  end
  for i, gameState in ipairs(MainCity_Client_GameState_Manager.mainCityGameStateArray or {}) do
    if gameState then
      return gameState
    end
  end
  return nil
end
return MainCity_Client_GameState_Manager