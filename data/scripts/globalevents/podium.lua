-- Definindo o GlobalStorage.Podium para evitar 'nil' value
GlobalStorage = GlobalStorage or {}
GlobalStorage.Podium = {
    One = 10001, -- IDs únicos para armazenar os NPCs no pódio
    Two = 10002,
    Three = 10003
}

local player1, player2, player3
local interval = 120 -- intervalo (em minutos)
local positions = { -- posição no mapa
    top1 = Position(32369, 32245, 7),
    top2 = Position(32367, 32247, 7),
    top3 = Position(32371, 32247, 7)
}

local function getTopPlayers()
    local topPlayersQuery = db.storeQuery("SELECT `name`, `level`, `lookbody`, `lookfeet`, `lookhead`, `looklegs`, `looktype`, `lookaddons` FROM `players` WHERE `group_id` != 6 ORDER BY `level` DESC LIMIT 3")
    local index = 1
    if topPlayersQuery then
        repeat
            if(index == 1) then
                player1 = {
                    name = result.getDataString(topPlayersQuery, "name"),
                    level = result.getDataInt(topPlayersQuery, "level"),
                    outfit = {
                        lookType = result.getDataInt(topPlayersQuery, "looktype"),
                        lookHead = result.getDataInt(topPlayersQuery, "lookhead"),
                        lookBody = result.getDataInt(topPlayersQuery, "lookbody"),
                        lookLegs = result.getDataInt(topPlayersQuery, "looklegs"),
                        lookFeet = result.getDataInt(topPlayersQuery, "lookfeet"),
                        lookAddons = result.getDataInt(topPlayersQuery, "lookaddons")
                    }
                }
            elseif(index == 2) then
                player2 = {
                    name = result.getDataString(topPlayersQuery, "name"),
                    level = result.getDataInt(topPlayersQuery, "level"),
                    outfit = {
                        lookType = result.getDataInt(topPlayersQuery, "looktype"),
                        lookHead = result.getDataInt(topPlayersQuery, "lookhead"),
                        lookBody = result.getDataInt(topPlayersQuery, "lookbody"),
                        lookLegs = result.getDataInt(topPlayersQuery, "looklegs"),
                        lookFeet = result.getDataInt(topPlayersQuery, "lookfeet"),
                        lookAddons = result.getDataInt(topPlayersQuery, "lookaddons")
                    }
                }
            elseif(index == 3) then
                player3 = {
                    name = result.getDataString(topPlayersQuery, "name"),
                    level = result.getDataInt(topPlayersQuery, "level"),
                    outfit = {
                        lookType = result.getDataInt(topPlayersQuery, "looktype"),
                        lookHead = result.getDataInt(topPlayersQuery, "lookhead"),
                        lookBody = result.getDataInt(topPlayersQuery, "lookbody"),
                        lookLegs = result.getDataInt(topPlayersQuery, "looklegs"),
                        lookFeet = result.getDataInt(topPlayersQuery, "lookfeet"),
                        lookAddons = result.getDataInt(topPlayersQuery, "lookaddons")
                    }
                }
            end
            index = index + 1
        until not result.next(topPlayersQuery)

        result.free(topPlayersQuery)
        index = 1
    else
        print("[PODIUM] Error: Could not retrieve top players.")
        return false
    end
end

local function spawnNpcs()
    getTopPlayers()

    -- NPC Top 1
    local npc1 = Game.createNpc("Top one", positions.top1)
    if npc1 and player1 then
        local npcName1 = string.format("%s [%d]", player1.name, player1.level)
        npc1:setMasterPos(positions.top1)
        npc1:setName(npcName1)
        npc1:setOutfit(player1.outfit)
        Game.setStorageValue(GlobalStorage.Podium.One, npcName1)
    end

    -- NPC Top 2
    local npc2 = Game.createNpc("Top two", positions.top2)
    if npc2 and player2 then
        local npcName2 = string.format("%s [%d]", player2.name, player2.level)
        npc2:setMasterPos(positions.top2)
        npc2:setName(npcName2)
        npc2:setOutfit(player2.outfit)
        Game.setStorageValue(GlobalStorage.Podium.Two, npcName2)
    end

    -- NPC Top 3
    local npc3 = Game.createNpc("Top three", positions.top3)
    if npc3 and player3 then
        local npcName3 = string.format("%s [%d]", player3.name, player3.level)
        npc3:setMasterPos(positions.top3)
        npc3:setName(npcName3)
        npc3:setOutfit(player3.outfit)
        Game.setStorageValue(GlobalStorage.Podium.Three, npcName3)
    end
end

local function updatePodium()
    getTopPlayers()

    local podiumOneStorage = Game.getStorageValue(GlobalStorage.Podium.One)
    local podiumTwoStorage = Game.getStorageValue(GlobalStorage.Podium.Two)
    local podiumThreeStorage = Game.getStorageValue(GlobalStorage.Podium.Three)

    -- Atualizando NPC 1
    if type(podiumOneStorage) == "string" and player1 then
        local npc1Name = string.format("%s [%d]", player1.name, player1.level)
        local npc1 = Npc(podiumOneStorage)
        if npc1 then
            npc1:setName(npc1Name)
            npc1:setOutfit(player1.outfit)
            Game.setStorageValue(GlobalStorage.Podium.One, npc1Name)
        end
    end

    -- Atualizando NPC 2
    if type(podiumTwoStorage) == "string" and player2 then
        local npc2Name = string.format("%s [%d]", player2.name, player2.level)
        local npc2 = Npc(podiumTwoStorage)
        if npc2 then
            npc2:setName(npc2Name)
            npc2:setOutfit(player2.outfit)
            Game.setStorageValue(GlobalStorage.Podium.Two, npc2Name)
        end
    end

    -- Atualizando NPC 3
    if type(podiumThreeStorage) == "string" and player3 then
        local npc3Name = string.format("%s [%d]", player3.name, player3.level)
        local npc3 = Npc(podiumThreeStorage)
        if npc3 then
            npc3:setName(npc3Name)
            npc3:setOutfit(player3.outfit)
            Game.setStorageValue(GlobalStorage.Podium.Three, npc3Name)
        end
    end
end

local initializePodium = GlobalEvent("initializePodium")
function initializePodium.onStartup()
    spawnNpcs()
end
initializePodium:register()

local podium = GlobalEvent("podium")
function podium.onThink(interval)
    updatePodium()
    return true
end

podium:interval(interval * 60000)
podium:register()