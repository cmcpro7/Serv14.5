local ferumbrasAscendantLeverSecond = Action()
function ferumbrasAscendantLeverSecond.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U10_90.FerumbrasAscension.Elements.Active) < 1 then
		return false
	end
	if item.itemid == 9110 then
		if player:getStorageValue(Storage.Quest.U10_90.FerumbrasAscension.Elements.Done) < 2 then
			local spectators = player:getSpectators(item:getPosition(), false, false, 9, 9, 6, 6)
			for i = 1, #spectators do
				if spectators[i]:isPlayer() then
					local spec = spectators[i]
					spec:teleportTo(Position(33646, 32654, 14))
					spec:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
					spec:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Something clicked at same time a booming sound almost deafens you.")
				end
			end
			revertStorages()
			return true
		end
		if player:getStorageValue(Storage.Quest.U10_90.FerumbrasAscension.Elements.Done) >= 2 then
			player:setStorageValue(Storage.Quest.U10_90.FerumbrasAscension.Elements.Done, 3)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Something clicked.")
		end
		item:transform(9111)
	elseif item.itemid == 9111 then
		item:transform(9110)
	end
	return true
end

ferumbrasAscendantLeverSecond:aid(53822)
ferumbrasAscendantLeverSecond:register()