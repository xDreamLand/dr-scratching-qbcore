CreateThread(function(resourceName)
  local resourceName <const> = GetCurrentResourceName()
  PerformHttpRequest('https://raw.githubusercontent.com/xDreamLand/dream-versions/main/dr-scratching.json', function (errorCode, resultData, resultHeaders)
    if not resultData then return end
    local retData <const> = json.decode(resultData)
    local version <const> = retData["version"]
    local currentVersion <const> = GetResourceMetadata(resourceName, "version", 0)
    local upToDateMsg <const> = retData["up-to-date"]["message"]
    local updateMsg <const> = retData["requires-update"]["message"]
    if version ~= currentVersion then
      local updMessage <const> = "^3 - Update here: " .. GetResourceMetadata(resourceName, "repository", 0) .. " (current: v" .. currentVersion .. ", newest: v" .. version .. ")^0"
      if retData["requires-update"]["important"] and updateMsg ~= nil then
        print("")
        print("  ^1Important Message:^0")
        print("")
        print((updateMsg):format(resourceName))
        print(updMessage)
        print("")
        print("")
      elseif updateMsg ~= nil then
        print((updateMsg):format(resourceName) .. "^0")
        print(updMessage)
      end
    elseif upToDateMsg ~= nil then
      print((upToDateMsg):format(resourceName) .. "^0")
    end
  end, 'GET')
end)