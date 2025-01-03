local slotMachine = {
    -- Configuração dos itens da roleta com ID único (uniqueid ou actionid)
    -- 7000: Roleta (máquina principal)
    -- 7001: Botão para jogar
    -- 7002, 7003, 7004: Linhas da roleta
    [7000] = { -- Roleta
        position = {x = 100, y = 150, z = 7}, -- Posição da roleta
        actionid = 18621, -- Identificador único
        effect = CONST_ME_GIFT_WRAPS, -- Efeito visual ao girar
        cost = 1000, -- Custo para jogar
    },
    [7001] = { -- Botão de jogar
        position = {x = 102, y = 150, z = 7}, -- Posição do botão
        actionid = 7001, -- Identificador único
    },
    [7002] = { -- Primeira linha da roleta
        position = {x = 91, y = 145, z = 7}, -- Posição da linha 1
        actionid = 7002, -- Identificador único
    },
    [7003] = { -- Segunda linha da roleta
        position = {x = 95, y = 145, z = 7}, -- Posição da linha 2
        actionid = 7003, -- Identificador único
    },
    [7004] = { -- Terceira linha da roleta
        position = {x = 99, y = 145, z = 7}, -- Posição da linha 3
        actionid = 7004, -- Identificador único
    }
}

-- Função para iniciar o jogo
function startSlotMachineGame(cid)
    local machine = slotMachine[7000]
    
    -- Verifica se o jogador tem dinheiro suficiente
    if not doPlayerRemoveMoney(cid, machine.cost) then
        return doPlayerSendTextMessage(cid, MESSAGE_STATUS_WARNING, 'Você precisa de ' .. machine.cost .. ' gp para jogar a Slot Machine.')
    end

    -- Ativa o efeito visual da roleta
    doSendMagicEffect(machine.position, machine.effect)
    
    -- Gira as frutas na roleta
    rotateSlotMachine(cid)
end

-- Função para girar a roleta e exibir as frutas
function rotateSlotMachine(cid)
    local fruits = {2674, 2675, 2676} -- IDs das frutas
    local randomFruit1 = fruits[math.random(#fruits)]
    local randomFruit2 = fruits[math.random(#fruits)]
    local randomFruit3 = fruits[math.random(#fruits)]

    -- Exibe as frutas nas linhas da roleta
    doCreateItem(randomFruit1, 1, slotMachine[7002].position)
    doCreateItem(randomFruit2, 1, slotMachine[7003].position)
    doCreateItem(randomFruit3, 1, slotMachine[7004].position)
    
    -- Verifica se o jogador ganhou
    checkSlotMachineWin(cid, randomFruit1, randomFruit2, randomFruit3)
end

-- Função para verificar se o jogador ganhou
function checkSlotMachineWin(cid, fruit1, fruit2, fruit3)
    if fruit1 == fruit2 and fruit2 == fruit3 then
        -- O jogador ganhou, entrega o prêmio
        local prize = 5000 -- Valor do prêmio
        doPlayerAddMoney(cid, prize)
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, 'Você ganhou ' .. prize .. ' gp!')
    else
        -- O jogador perdeu, mensagem de perda
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, 'Você perdeu! Tente novamente.')
    end
end

-- Função para lidar com a interação com a roleta
function onUse(cid, item, fromPosition, itemEx, toPosition)
    local machine = slotMachine[item.actionid]

    -- Identifica a parte da roleta que o jogador interagiu
    if machine then
        if item.actionid == 7000 then
            -- O jogador interagiu com a roleta (máquina principal)
            doSendMagicEffect(fromPosition, CONST_ME_POFF)
            return true
        elseif item.actionid == 7001 then
            -- O jogador clicou no botão para jogar
            startSlotMachineGame(cid)
        elseif item.actionid == 7002 or item.actionid == 7003 or item.actionid == 7004 then
            -- O jogador interagiu com as linhas da roleta (onde as frutas aparecem)
            -- Isso pode ser utilizado para qualquer ação extra que você queira aplicar
            return true
        end
    end

    return false
end
