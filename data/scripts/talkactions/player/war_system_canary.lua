-- !war invite, enemyGuild, frags(x), money(x) [0] // -- !war invite, enemyGuild, frags(x), money(x), timeDays(x) [status 0]
-- !war accept, enemyGuild (aceita um convite recebido [status 1])
-- !war reject,enemyGuild (cancela um convite recebido [status 2])
-- !war cancel, enemyGuild (cancela um convite enviado [status 3])
-- !war end, enemyGuild (se voce for quem enviouo convite encerra a guerra [status 5] ou se for quem recebeu o convite ela muda para pedido de encerramento [status 4])
-- !war finish, enemyGuild (se voce for o lider e tiver pedido de encerramento da outra guild encerra a guerra [status 5])
-- !war balance
-- !war deposity, money
-- !war withdraw, money

local config = {
	frags = {min = 20, max = 100, standard = 20},
	daysMaxToInviteWar = 30,
}

local warSystem = TalkAction("!war")

function warSystem.onSay(player, words, param)

	--[[local exhaustion = player:getExhaustion("talkactions")
	if exhaustion > 0 then
		player:sendCancelMessage("You're exhausted and must wait " .. exhaustion .. " " .. (exhaustion > 1 and "seconds" or "second") .. " to use the command again.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	player:setExhaustion("talkactions", 5)]]--

	local guild = player:getGuild()
	if not guild then
		player:sendCancelMessage("[GUILD WAR] You need to be in a guild in order to execute this command.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local guildId = guild:getId()
	if not guildId then
		player:sendCancelMessage("[GUILD WAR] You need to be in a guild in order to execute this command.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if guildId == 0 then
		player:sendCancelMessage("[GUILD WAR] You need to be in a guild in order to execute this command.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if player:getGuildLevel() < 3 then
		player:sendCancelMessage("[GUILD WAR] You need to be the guild leader to execute this command.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local split = param:splitTrimmed(",")
	if not split[1] then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "[GUILD WAR] Insufficient parameters. Guild War commands:" .. "\n"
			.. "!war invite, enemyGuild, frags, money, timeDays" .. "\n"
			.. "!war accept, enemyGuild" .. "\n"
			.. "!war reject,enemyGuild" .. "\n"
			.. "!war cancel, enemyGuild" .. "\n"
			.. "!war end, enemyGuild" .. "\n"
			.. "!war finish, enemyGuild" .. "\n"
			.. "!war balance" .. "\n"
			.. "!war deposity, money" .. "\n"
			.. "!war withdraw, money")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if not table.contains({"balance", "withdraw", "deposity", "invite", "accept", "reject", "cancel", "end", "finish"}, split[1]) then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "[GUILD WAR] Invalid parameters. Guild War commands:" .. "\n"
			.. "!war invite, enemyGuild, frags, money, timeDays" .. "\n"
			.. "!war accept, enemyGuild" .. "\n"
			.. "!war reject,enemyGuild" .. "\n"
			.. "!war cancel, enemyGuild" .. "\n"
			.. "!war end, enemyGuild" .. "\n"
			.. "!war finish, enemyGuild" .. "\n"
			.. "!war balance" .. "\n"
			.. "!war deposity, money" .. "\n"
			.. "!war withdraw, money")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if split[1] == "balance" then

		local resultId = db.storeQuery("SELECT `balance` FROM `guilds` WHERE `id` = " .. guildId)
		if not resultId then
			logger.warn("[war_system] function db.storeQuery error in 'not resultId' - balance (guild id: {}).", guildId)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "[GUILD WAR] Current balance of guild " .. guild:getName() .. " is: " .. Result.getNumber(resultId, "balance") .. " golds coins.")
		Result.free(resultId)

		--player:setExhaustion("talkactions", 10)

		return true
	end

	if not split[2] then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "[GUILD WAR] Insufficient parameters. Guild War commands:" .. "\n"
			.. "!war invite, enemyGuild, frags, money, timeDays" .. "\n"
			.. "!war accept, enemyGuild" .. "\n"
			.. "!war reject,enemyGuild" .. "\n"
			.. "!war cancel, enemyGuild" .. "\n"
			.. "!war end, enemyGuild" .. "\n"
			.. "!war finish, enemyGuild" .. "\n"
			.. "!war balance" .. "\n"
			.. "!war deposity, money" .. "\n"
			.. "!war withdraw, money")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local money = 0
	if table.contains({"withdraw", "deposity"}, split[1]) then

		local money = tonumber(split[2])
		if not money then
			player:sendCancelMessage("[GUILD WAR] Invalid amount of money specified.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local function isValidMoneyGuild(value)
			if not value then
				logger.warn("[war_system] function isValidMoneyGuild( error in 'not value' (value: {}).", value)
				return false
			end
			return isNumber(value) and value > 0 and value < 4294967296
		end

		if not isValidMoneyGuild(money) then
			player:sendCancelMessage("[GUILD WAR] Invalid amount of money specified.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if split[1] == "withdraw" then

			local resultId = db.storeQuery("SELECT `balance` FROM `guilds` WHERE `id` = " .. guildId)
			if not resultId then
				logger.warn("[war_system] function db.storeQuery error in 'not resultId' - withdraw (guild id: {}).", guildId)
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			local balance = Result.getNumber(resultId, "balance")
			Result.free(resultId)

			--player:setExhaustion("talkactions", 10)

			if money > balance then
				player:sendCancelMessage("[GUILD WAR] The balance is too low for such amount.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if not db.query("UPDATE `guilds` SET `balance` = `balance` - " .. money .. " WHERE `id` = " .. guildId .. " LIMIT 1;") then
				logger.warn("[war_system] function db.query error in 'SET balance' - withdraw (guild id: {}).", guildId)
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if player:addMoney(money) then
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "[GUILD WAR] You have just picked " .. money .. " gold coins from your guild balance.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return true
			end

		elseif split[1] == "deposity" then

			if not player:removeMoneyBank(money) then
				player:sendCancelMessage("[GUILD WAR] You don't have enough money.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if not db.query("UPDATE `guilds` SET `balance` = `balance` + " .. money .. " WHERE `id` = " .. guildId .. " LIMIT 1;") then
				logger.warn("[war_system] function db.query error in 'SET balance' - deposity (guild id: {}).", guildId)
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			--player:setExhaustion("talkactions", 10)

			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "[GUILD WAR] You have deposited " .. money .. " gold coins to your guild balance.")
			return true
		end

		return false
	end

	local function getEnemyId(enemyName)
		local resultId = db.storeQuery("SELECT `id` FROM `guilds` WHERE `name` = " .. db.escapeString(enemyName))
		if not resultId then
			logger.warn("[war_system] function getEnemyId error in 'not resultId' (enemy name: {}).", enemyName)
			return false
		end

		local enemyId = Result.getNumber(resultId, "id")
		Result.free(resultId)
		return enemyId
	end

	local enemyGuildId = getEnemyId(split[2])
	if not enemyGuildId then
		--player:setExhaustion("talkactions", 10)
		player:sendCancelMessage("[GUILD WAR] Guild \"" .. split[2] .. "\" does not exists.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local function getEnemyName(enemyId)
		local resultId = db.storeQuery("SELECT `name` FROM `guilds` WHERE `id` = " .. enemyId)
		if not resultId then
			logger.warn("[war_system] function getEnemyName error in 'not resultId' (enemy id: {}).", enemyId)
			return false
		end

		local enemyName = Result.getString(resultId, "name")
		Result.free(resultId)

		return enemyName
	end

	local enemyName = getEnemyName(enemyGuildId)
	if not enemyName then
		--player:setExhaustion("talkactions", 10)
		player:sendCancelMessage("[GUILD WAR] Guild \"" .. split[2] .. "\" does not exists.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local guildName = guild:getName()

	if enemyGuildId == guildId or enemyName == guildName then
		player:sendCancelMessage("[GUILD WAR] You cannot perform war action on your own guild.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if table.contains({"accept", "reject", "cancel"}, split[1]) then
		local query = "`guild1` = " .. enemyGuildId .. " AND `guild2` = " .. guildId
		if split[1] == "cancel" then
			query = "`guild1` = " .. guildId .. " AND `guild2` = " .. enemyGuildId
		end

		local resultId = db.storeQuery("SELECT `id`, `started`, `ended`, `payment` FROM `guild_wars` WHERE " .. query .. " AND `status` = 0")
		if not resultId then
			--player:setExhaustion("talkactions", 10)
			player:sendCancelMessage("[GUILD WAR] Currently there's no pending invitation for a war with " .. enemyName .. ".")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if split[1] == "accept" then
			local selectBalance = db.storeQuery("SELECT `balance` FROM `guilds` WHERE `id` = " .. guildId)
			local state = Result.getNumber(selectBalance, "balance") < Result.getNumber(resultId, "payment")
			Result.free(selectBalance)

			if state then
				--player:setExhaustion("talkactions", 10)
				player:sendCancelMessage("[GUILD WAR] Your guild balance is too low to accept this invitation.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			db.query("UPDATE `guilds` SET `balance` = `balance` - " .. Result.getNumber(resultId, "payment") .. " WHERE `id` = " .. guildId)

		elseif split[1] == "reject" then
			db.query("UPDATE `guilds` SET `balance` = `balance` + " .. Result.getNumber(resultId, "payment") .. " WHERE `id` = " .. enemyGuildId)
		elseif split[1] == "cancel" then
			db.query("UPDATE `guilds` SET `balance` = `balance` + " .. Result.getNumber(resultId, "payment") .. " WHERE `id` = " .. guildId)
		end

		query = "UPDATE `guild_wars` SET "

		local message = "accepted " .. enemyName .. " invitation to war."
		if split[1] == "reject" then
			query = query .. "`ended` = " .. os.time() .. ", `status` = 2"
			message = "rejected " .. enemyName .. " invitation to war."
		elseif split[1] == "cancel" then
			query = query .. "`ended` = " .. os.time() .. ", `status` = 3"
			message = "canceled invitation to a war with " .. enemyName .. "."
		else
			query = query .. "`started` = " .. os.time() .. ", `ended` = " .. (Result.getNumber(resultId, "ended") > 0 and (os.time() + ((Result.getNumber(resultId, "started") - Result.getNumber(resultId, "ended")) / 86400)) or 0) .. ", `status` = 1"
		end

		query = query .. " WHERE `id` = " .. Result.getNumber(resultId, "id")
		Result.free(resultId)
		db.query(query)

		--player:setExhaustion("talkactions", 20)

		Game.broadcastMessage(guildName .. " has " .. message)
		logger.info("Broadcasted War System: {} has {}", guildName, message)

		if split[1] == "accept" then
			for _, guildPlayer in ipairs(guild:getMembersOnline()) do
				guildPlayer:sendTextMessage(MESSAGE_EVENT_ADVANCE, "[GUILD WAR] War started. You must relog in to upgrade shields and emblems.")
			end

			for _, guildPlayer in ipairs(Guild(enemyGuildId):getMembersOnline()) do
				guildPlayer:sendTextMessage(MESSAGE_EVENT_ADVANCE, "[GUILD WAR] War started. You must relog in to upgrade shields and emblems.")
			end
		end

		return true

	elseif split[1] == "invite" then
		local invitationDenied = ""
		local resultId = db.storeQuery("SELECT `guild1`, `status` FROM `guild_wars` WHERE `guild1` IN (" .. guildId .. "," .. enemyGuildId .. ") AND `guild2` IN (" .. enemyGuildId .. "," .. guildId .. ") AND `status` IN (0, 1)")
		if resultId then
			if Result.getNumber(resultId, "status") == 0 then
				if Result.getNumber(resultId, "guild1") == guildId then
					invitationDenied = "You have already invited " .. enemyName .. " to war."
				else
					invitationDenied = enemyName .. " have already invited you to war."
				end
			else
				invitationDenied = "You are already on a war with " .. enemyName .. "."
			end
			Result.free(resultId)
			--player:setExhaustion("talkactions", 10)
		end

		if invitationDenied ~= "" then
			player:sendCancelMessage("[GUILD WAR] " .. invitationDenied)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local fragLimit = 0
		local fragsSplit = tonumber(split[3])
		local frags = config.frags
		if not fragsSplit then
			fragLimit = frags.standard
		else
			fragLimit = math.max(frags.min, math.min(frags.max, fragsSplit))
		end

		local payment = 0
		payment = tonumber(split[4])
		if payment then
			payment = math.floor(payment)
			if not isValidMoney(payment) then
				player:sendCancelMessage("[GUILD WAR] Invalid amount of money specified.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			local resultId = db.storeQuery("SELECT `balance` FROM `guilds` WHERE `id` = " .. guildId)
			local state = Result.getNumber(resultId, "balance") < payment
			Result.free(resultId)

			--player:setExhaustion("talkactions", 10)

			if state then
				player:sendCancelMessage("[GUILD WAR] Your guild balance is too low for such payment.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end
			db.query("UPDATE `guilds` SET `balance` = `balance` - " .. payment .. " WHERE `id` = " .. guildId)
		else
			payment = 0
		end

		local begining, ending, days = os.time(), 0, 0 -- local begining, ending, days = os.time(), tonumber(split[5]), 0
		if ending and ending ~= 0 then
			local timeDaysMax = config.daysMaxToInviteWar
			if ending > timeDaysMax then
				player:sendCancelMessage("[GUILD WAR] Invalid amount of days specified. The maximum value for days of war is " .. timeDaysMax .. " days.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end
			days = ending
			ending = begining + (ending * 86400)
		else
			ending = 0
		end

		db.query("INSERT INTO `guild_wars` (`guild1`, `guild2`, `name1`, `name2`, `started`, `ended`, `frags_limit`, `payment`) VALUES (" .. guildId .. ", " .. enemyGuildId .. ", " .. db.escapeString(guildName) .. ", " .. db.escapeString(enemyName) .. ", " .. begining .. ", " .. ending .. ", " .. fragLimit .. ", " .. payment .. ");")

		--player:setExhaustion("talkactions", 20)

		local msgPayment = ""
		if payment > 0 then
			msgPayment = " betting " .. payment .. " golds"
		end

		local msgDays = ""
		if days > 0 then
			msgDays = " with a duration of " .. days .. " " .. (days > 1 and "days" or "day") .. ""
		end

		Game.broadcastMessage(guildName .. " has invited " .. enemyName .. " to war till " .. fragLimit .. " frags" .. msgPayment .. "" .. msgDays .. ".")
		logger.info("Broadcasted War System: {} has invited {} to war till {} frags {}{}.", guildName, enemyName, fragLimit, msgPayment, msgDays)

		return true

	elseif table.contains({"end", "finish"}, split[1]) then
		local status = (split[1] == "end" and 1 or 4)
		local resultId = db.storeQuery("SELECT `id`, `payment` FROM `guild_wars` WHERE `guild1` = " .. guildId .. " AND `guild2` = " .. enemyGuildId .. " AND `status` = " .. status .. "")
		if resultId then
			--player:setExhaustion("talkactions", 20)
			local query = "UPDATE `guild_wars` SET `ended` = " .. os.time() .. ", `status` = 5 WHERE `id` = " .. Result.getNumber(resultId, "id")
			local payment = Result.getNumber(resultId, "payment")
			Result.free(resultId)
			db.query(query)

			if status == 1 then
				db.query("UPDATE `guilds` SET `balance` = `balance` + " .. (payment * 2) .. " WHERE `id` = " .. enemyGuildId)
			elseif status == 4 then
				db.query("UPDATE `guilds` SET `balance` = `balance` + " .. (payment * 2) .. " WHERE `id` = " .. guildId)
			end

			Game.broadcastMessage(guildName .. " has " .. (status == 4 and "mend fences" or "ended up a war") .. " with " .. enemyName .. ".")
			logger.info("Broadcasted War System: {} has {} with {}.", guildName, (status == 4 and "mend fences" or "ended up a war"), enemyName)

			return true
		end

		if status == 4 then
			player:sendCancelMessage("[GUILD WAR] Currently there's no pending war truce from " .. enemyName .. ".")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local resultId = db.storeQuery("SELECT `id`, `ended` FROM `guild_wars` WHERE `guild1` = " .. enemyGuildId .. " AND `guild2` = " .. guildId .. " AND `status` = 1")
		if resultId then
			--player:setExhaustion("talkactions", 20)

			if Result.getNumber(resultId, "ended") > 0 then
				Result.free(resultId)
				player:sendCancelMessage("[GUILD WAR] You cannot request ending for war with " .. enemyName .. ".")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			local query = "UPDATE `guild_wars` SET `status` = 4, `ended` = " .. os.time() .. " WHERE `id` = " .. Result.getNumber(resultId, "id")
			Result.free(resultId)
			db.query(query)

			Game.broadcastMessage(guildName .. " has signed an armstice declaration on a war with " .. enemyName .. ".")
			logger.info("Broadcasted War System: {} has signed an armstice declaration on a war with {}.", guildName, enemyName)

			return true
		end

		player:sendCancelMessage("[GUILD WAR] Currently there's no active war with " .. enemyName .. ".")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
	end

	return false
end

warSystem:separator(" ")
warSystem:groupType("normal")
warSystem:register()