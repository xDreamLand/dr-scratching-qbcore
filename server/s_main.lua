local players = {}
local totalSumChance = 0

local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
  for _,priceInfo in pairs(Config.Prices) do
    totalSumChance = totalSumChance + priceInfo['chance']
  end 
end)

QBCore.Functions.CreateUseableItem('scratch_ticket', function(source)
  local _source = source
  DebugPrint(('%s just used a scratching ticket.'):format(GetPlayerName(_source)))
  TriggerClientEvent("dr-scratching:isActiveCooldown", source)
end)

RegisterNetEvent("dr-scratching:handler", function(returncooldown, cooldown)
  local _source <const> = source
  local tempsrc <const> = tonumber(_source)
  local playerName, playerIdentifier = GetPlayerName(_source), GetPlayerIdentifier(_source, 0)
  local xPlayer <const> = QBCore.Functions.GetPlayer(_source)
  local count <const> = xPlayer.Functions.GetItemByName('scratch_ticket').amount
  local randomNumber <const> = math.random(1, totalSumChance)
  local add = 0
  if returncooldown then
    if Config.ShowCooldownNotifications then
      TriggerClientEvent('QBCore:Notify', _source, 'You scratched a scratching ticket too recently, active cooldown of ' .. cooldown .. ' more seconds', 'error', cooldown > 30 and 5000 or cooldown * 1000)
    end
    DebugPrint(("Active cooldown for %s (%s). Stopped. Cooldown: %s"):format(playerName, playerIdentifier, cooldown))
    return
  end

  if count >= 1 then
    xPlayer.Functions.RemoveItem('scratch_ticket', 1)
    DebugPrint(('Succesfully removed scratching ticket of %s (%s).'):format(playerName, playerIdentifier))
    TriggerClientEvent("dr-scratching:setCooldown", _source)
    if Config.ShowUsedTicketNotification then
      TriggerClientEvent('QBCore:Notify', _source, 'Succesfully used a scratching ticket', 'success')
    end
  else
    sendWebhook(playerName, playerIdentifier, "important", "Player triggered event without having said scratching ticket")
    Print(("%s (%s) somehow used a scratching ticket without having one. Possible cheating attempt."):format(playerName, playerIdentifier))
    return
  end

  TriggerClientEvent("dr-scratching:startScratchingEmote", _source)

  for key,priceInfo in pairs(Config.Prices) do
    local chance = priceInfo['chance']
    if randomNumber > add and randomNumber <= add + chance then
      local price_is_item = priceInfo['price']['item']['price_is_item']
      local amount = priceInfo['price']['item']['item_amount']
      local price_type, price = nil

      if not price_is_item then
        price = priceInfo['price']['price_money']
        price_type = 'money'
      else 
        price = priceInfo['price']['item']['item_name']
        price_type = 'item'
        price_label = priceInfo['price']['item']['item_label']
      end
      players[tempsrc] = tostring(price)
      TriggerClientEvent("dr-scratching:nuiOpenCard", _source, key, price, amount, price_type, price_label)
      return price
    end
    add = add + chance
  end
end)

RegisterNetEvent("dr-scratching:deposit", function(key, price, amount, type)
  local _source = source
  local playerName, playerIdentifier = GetPlayerName(_source), GetPlayerIdentifier(_source, 0)
  local xPlayer = QBCore.Functions.GetPlayer(_source)
  local tempsrc = tonumber(_source)
  local giveItem = false
  local giveMoney = false
  local priceAmount = nil

  if players[tempsrc] ~= tostring(price) then
    sendWebhook(playerName, playerIdentifier, "important", "Player triggered event with a non matching price assigned to name. Assigned price: " .. players[tempsrc] .. " Requested price: " .. tostring(price) .. ". Possible unauthorized event trigger")
    Print(("%s (%s) somehow managed to trigger the deposit event with a non-matching price matching to his/her name. Assigned price: %s - Requested price: %s Possible cheating attempt."):format(resourceName, playerName, playerIdentifier, players[tempsrc], tostring(price)))
    players[tempsrc] = nil
    return
  end

  if type == 'money' then
    local winningAmount = tonumber(price)

    if winningAmount == nil or winningAmount < 0 then
      sendWebhook(playerName, playerIdentifier, "important", "Invalid price provided, provided money price: " .. winningAmount)
      Print(("%s (%s) Invalid price provided. Possible cheating attempt. Provided price: %s"):format(playerName, playerIdentifier, winningAmount))
      players[tempsrc] = nil
      return
    end

    giveMoney = true
  else
    giveItem = true
  end

  for priceKey,priceInfo in pairs(Config.Prices) do
    if priceKey == key then
      priceAmount = priceInfo["price"]["item"]["item_amount"]

      if Config.ShowResultTicketNotification then
        TriggerClientEvent('QBCore:Notify', _source, priceInfo['message'])
      end

      if type == 'item' and giveItem then
        if tonumber(amount) == tonumber(priceAmount) then
          local priceCheck = priceInfo["price"]["item"]["item_name"]
          if priceCheck == price then
            DebugPrint(("Succesfully added price (item: %sx %s) to %s (%s)"):format(priceAmount, price, playerName, playerIdentifier))
            xPlayer.Functions.AddItem(price, priceAmount)
          else
            Print("??? Cheat")
          end
        end
      elseif type == 'money' and giveMoney then
        if tonumber(amount) == priceAmount then
          if tonumber(price) > 0 then
            DebugPrint(("Succesfully added price (money: %s) to %s (%s)"):format(price, playerName, playerIdentifier))
            xPlayer.Functions.AddMoney("cash", tonumber(price))
          else
            DebugPrint(("Succesfully added no price to %s (%s)"):format(playerName, playerIdentifier))
          end
        end
      else
        sendWebhook(playerName, playerIdentifier, "important", "Player managed to trigger deposit event with a non-matching money amount. Possible unauthorized event trigger")
        Print(("%s (%s) somehow managed to trigger the deposit event with a non-matching amount. Possible cheating attempt."):format(playerName, playerIdentifier))
        players[tempsrc] = nil
        return
      end
    end
  end
  sendWebhook(playerName, playerIdentifier, type, price, priceAmount)
  players[tempsrc] = nil
  return
end)

RegisterNetEvent("dr-scratching:stopScratching", function(price, amount, type)
  local _source = source
  local playerName, playerIdentifier = GetPlayerName(_source), GetPlayerIdentifier(_source, 0)
  local tempsrc = tonumber(_source)

  sendWebhook(playerName, playerIdentifier, type, price, amount, "early")
  players[tempsrc] = nil
  return
end)