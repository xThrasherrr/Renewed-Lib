local Controller = require 'framework.server'

---Adds stress to a player by their source
---@param source number
---@param value number
exports('addStress', function(source, value)
    local Player = exports.qbx_core:GetPlayer(source)
    local stress = (Player.PlayerData.metadata.stress or 0) + value

    Player.Functions.SetMetaData('stress', lib.math.clamp(stress, 0, 100))
    exports.qbx_core:Notify(source, 'Stress Gained', 'error', 1500)
end)

---Relieves stress from a player by their source
---@param source number
---@param value number
exports('relieveStress', function(source, value)
    local Player = exports.qbx_core:GetPlayer(source)
    local stress = (Player.PlayerData.metadata.stress or 0) - value

    Player.Functions.SetMetaData('stress', lib.math.clamp(stress, 0, 100))
    exports.qbx_core:Notify(source, 'Stress Relieved', 'error', 1500)
end)

---Returns the amount of money a player has by their source
---@param source number
---@param moneyType 'cash' | 'bank'
---@return number?
exports('getMoney', function(source, moneyType)
    local Player = exports.qbx_core:GetPlayer(source)

    if Player then
        return Player.PlayerData.money[moneyType]
    end
end)

---Removes money from a player's account by their source
---@param src number
---@param amount number
---@param moneyType 'cash' | 'bank'
---@param reason string?
---@return boolean
exports('removeMoney', function(src, amount, moneyType, reason)
    local Player = exports.qbx_core:GetPlayer(src)

    if Player and Player.PlayerData.money[moneyType] >= amount then
        return Player.Functions.RemoveMoney(moneyType, amount, reason or "unknown")
    end

    return false
end)

---Adds money to a player's account by their source
---@param source number
---@param amount number
---@param moneyType 'cash' | 'bank'
---@param reason string?
---@return boolean
exports('addMoney', function(source, amount, moneyType, reason)
    local Player = exports.qbx_core:GetPlayer(source)

    if Player then
        return Player.Functions.AddMoney(moneyType, amount, reason or "unknown")
    end

    return false
end)

---Adds needs (hunger, thirst) to a player, returns true/false depending on success and reason why it failed
---@param source number
---@param needs { hunger: number, thirst: number }
---@return boolean
---@return string?
exports('addNeeds', function(source, needs)
    if type(needs) ~= 'table' then return false, 'NEEDS IS NOT A TABLE' end

    local Player = exports.qbx_core:GetPlayer(source)

    if not Player then return false, 'PLAYER NOT FOUND' end

    local hunger = Player.PlayerData.metadata.hunger + (needs.hunger or 0)
    local thirst = Player.PlayerData.metadata.thirst + (needs.thirst or 0)

    if hunger > 100 then hunger = 100 end
    if thirst > 100 then thirst = 100 end

    Player.Functions.SetMetaData('hunger', lib.math.clamp(hunger, 0, 100))
    Player.Functions.SetMetaData('thirst', lib.math.clamp(thirst, 0, 100))

    TriggerClientEvent('hud:client:UpdateNeeds', source, hunger, thirst)

    return true
end)


AddEventHandler('qbx_core:server:onGroupUpdate', function(source, groupName, groupGrade)
    local Player = Controller.getPlayer(source)

    if Player then
        Player.Groups[groupName] = not groupGrade and nil or groupGrade
    end
end)

AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    local groups = {}

    for groupName, grade in pairs(Player.PlayerData.jobs) do
        groups[groupName] = grade
    end

    for groupName, grade in pairs(Player.PlayerData.gangs) do
        groups[groupName] = grade
    end

    Controller.createPlayer({
        source = Player.PlayerData.source,
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        charId = Player.PlayerData.citizenid,
        Groups = groups,
    })
end)


AddEventHandler('QBCore:Server:OnPlayerUnload', Controller.removePlayer)

AddEventHandler('playerDropped', function()
    Controller.removePlayer(source)
end)


require 'framework.qbox.db'