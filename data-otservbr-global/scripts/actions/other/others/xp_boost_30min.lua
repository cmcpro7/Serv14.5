local expscroll = Action()

-- Define o valor do XP Boost (100%)
local BOOST_XP_VALUE = 100

-- Define as chaves de armazenamento para rastrear o boost
GameStore = GameStore or {}
GameStore.Storages = GameStore.Storages or {}
GameStore.Storages.expBoostStart = 1000 -- Armazena o tempo de início do boost
GameStore.Storages.expBoostCount = 1001 -- Verifica se o boost está ativo

-- Função para aplicar o boost de 100% XP
local function applyXpBoost(player)
    -- Verifica se o boost já está ativo
    local currentBoost = player:getStorageValue(GameStore.Storages.expBoostCount) or 0

    -- Se o boost já está ativo, exibe o tempo restante
    if currentBoost == 1 then
        local remainingTime = player:getXpBoostTime()
        local minutes = math.floor(remainingTime / 60)
        local seconds = remainingTime % 60
        player:say("Voce ja tem um boost de 100% ativo. Tempo restante: " .. minutes .. " minutos e " .. seconds .. " segundos.", TALKTYPE_MONSTER_SAY)
        return false -- Sai se o boost já estiver ativo
    end

    -- Define o boost de XP diretamente para 100%
    player:setXpBoostPercent(BOOST_XP_VALUE) -- Configura para 100% XP Boost

    -- Define a duração do boost para 30 minutos (1800 segundos)
    player:setXpBoostTime(1800)

    -- Marca que o boost está ativo
    player:setStorageValue(GameStore.Storages.expBoostCount, 1)

    -- Define o tempo de início do boost
    player:setStorageValue(GameStore.Storages.expBoostStart, os.time())

    return true
end

-- Função para redefinir o XP Boost
local function resetXpBoost(player)
    -- Reseta o ganho de XP para o padrão (100%)
    player:setXpBoostPercent(100) -- Retorna ao XP normal

    -- Reseta o tempo e marca que o boost expirou
    player:setXpBoostTime(0)
    player:setStorageValue(GameStore.Storages.expBoostCount, 0)
    player:setStorageValue(GameStore.Storages.expBoostStart, -1)

    -- Informa ao jogador
    player:say("Seu boost de XP expirou. Voce voltou a sua taxa de experiencia anterior.", TALKTYPE_MONSTER_SAY)
end

-- Função para verificar se o XP Boost expirou
local function checkXpBoostExpiration(player)
    local boostStartTime = player:getStorageValue(GameStore.Storages.expBoostStart)

    -- Se nenhum boost foi iniciado, pula a verificação
    if boostStartTime == -1 or boostStartTime == nil then
        return
    end

    -- Calcula quanto tempo o boost está ativo
    local elapsedTime = os.time() - boostStartTime

    -- Se o tempo do boost passou (1800 segundos = 30 minutos), reseta o boost
    if elapsedTime >= 1800 then
        resetXpBoost(player)
    end
end

-- Função principal para usar o XP Scroll
function expscroll.onUse(player, item, fromPosition, itemEx, toPosition)
    -- Verifica se o boost deve ser resetado primeiro
    checkXpBoostExpiration(player)

    -- Aplica o boost se não houver outro ativo
    if applyXpBoost(player) then
        item:remove(1) -- Remove o scroll após o uso
    end

    return true -- XP Boost aplicado com sucesso
end

-- Registra a ação para o XP Scroll
expscroll:id(49720) -- Substitua pelo ID do item XP Scroll
expscroll:register()

-- Verifica e aplica o boost quando o jogador entra no jogo
local login = CreatureEvent("onLogin")
function login.onLogin(player)
    checkXpBoostExpiration(player) -- Verifica se o boost expirou no login
    return true
end
login:register()

-- Verifica periodicamente se o XP Boost expirou durante o jogo
function onThink(interval)
    local players = Game.getPlayers() -- Obtém todos os jogadores online
    for _, player in ipairs(players) do
        checkXpBoostExpiration(player) -- Verifica se o boost expirou para cada jogador
    end
    return true
end
