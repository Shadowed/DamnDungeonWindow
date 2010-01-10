AlertFrame:UnregisterEvent("LFG_COMPLETION_REWARD")
-- Uncomment this if you don't want the chat message
--if( true == true ) then return end

local L = {
	["%d experience"] = "%d experience",
	["%s finished! Rewards: %s"] = "%s finished! Rewards: %s",
	[" and "] = " and ",
}

local GOLD_TEXT = "|cffffd700g|r"
local SILVER_TEXT = "|cffc7c7cfs|r"
local COPPER_TEXT = "|cffeda55fc|r"

local function formatMoney(money)
	local gold = math.floor(money / COPPER_PER_GOLD)
	local silver = math.floor((money - (gold * COPPER_PER_GOLD)) / COPPER_PER_SILVER)
	local copper = math.floor(math.fmod(money, COPPER_PER_SILVER))
	local text = ""

	if( gold > 0 ) then
		text = string.format("%d%s ", gold, GOLD_TEXT)
	end
	if( silver > 0 ) then
		text = string.format("%s%d%s ", text, silver, SILVER_TEXT)
	end
	if( copper > 0 ) then
		text = string.format("%s%d%s ", text, copper, COPPER_TEXT)
	end

	return string.trim(text)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("LFG_COMPLETION_REWARD")
frame:SetScript("OnEvent", function()
	PlaySound("LFG_Rewards")

	local name, typeID, textureFilename, goldBase, goldVar, xpBase, xpVar, numStrangers, numRewards = GetLFGCompletionReward()
	local goldEarned = goldBase + (goldVar * numStrangers)
	local xpEarned = xpBase + (xpVar * numStrangers)
	local msgList = {}

	for i=1, numRewards do
		GameTooltip:SetLFGCompletionReward(i)
		local icon, quantity = GetLFGCompletionRewardItem(i)
		local itemLink = select(2, GameTooltip:GetItem())

		-- I'm not sure if it's possible for this to fail, but just in case will do the icon if it does
		if( itemLink ) then
			table.insert(msgList, string.format("%sx%d", itemLink, quantity))
		else
			table.insert(msgList, string.format("|T%s:0:0|tx%d ", icon, quantity))
		end
	end

	if( goldEarned > 0 ) then
		table.insert(msgList, formatMoney(goldEarned))
	end
	if( xpEarned > 0 ) then
		table.insert(msgList, string.format(L["%d experience"], xpEarned))
	end

	local rewards
	if( #(msgList) == 2 ) then
		rewards = table.concat(msgList, L[" and "])
	else
		rewards = table.concat(msgList, ", ")
	end

	name = typeID == TYPEID_HEROIC_DIFFICULTY and string.format("|cff33ff99%s|r (%s)", name, PLAYER_DIFFICULTY2) or string.format("|cff33ff99%s|r", name)
	DEFAULT_CHAT_FRAME:AddMessage(string.format(L["%s finished! Rewards: %s"], name, rewards))
end)
frame:Hide()