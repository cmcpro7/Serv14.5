--local actionId = 8000
local itemDollId = 49718
local outfits = {
    {136, 128, "Citizen"},
    {137, 129, "Hunter"},
    {138, 130, "Mage"},
    {139, 131, "Knight"},
    {140, 132, "Noblewoman"},
	{141, 133, "Summoner"},
	{142, 134, "Warrior"},
	{147, 143, "Barbarian"},
	{148, 144, "Druid"},
	{149, 145, "Wizard"},
	{150, 146, "Oriental"},
	{155, 151, "Pirate"},
	{156, 152, "Assassin"},
	{157, 153, "Beggar"},	
	{158, 154, "Shaman"},	
	{252, 251, "Norsewoman"},
	{269, 268, "Nightmare"},
	{270, 273, "Jester"},
	{279, 278, "Brotherhood"},
	{288, 289, "Demon Hunter"},
	{324, 325, "Yalaharian"},
	{329, 328, "Newly Wed"},
	{336, 335, "Warmaster"},
	{366, 367, "Wayfarer"},
}

local randOutfit = Action("RandomOutfitForNewPlayers")

function randOutfit.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local outfit = outfits[math.random(1, #outfits)]
    local addon = math.random(1, 2)
    if player:hasOutfit(outfit[1], addon) and player:hasOutfit(outfit[2], addon) then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You already have this outfit.")
        return true
    end

    player:addOutfitAddon(outfit[1], addon)
    player:addOutfitAddon(outfit[2], addon)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("You obtained the %s outfit with addon %d.", outfit[3], addon))
    item:remove(1)
    return true
end

randOutfit:id(itemDollId)
--randOutfit:aid(actionId)
randOutfit:register()