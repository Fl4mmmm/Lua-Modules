---
-- @Liquipedia
-- wiki=fortnite
-- page=Module:PrizePool/Legacy/Custom
--
-- Please see https://github.com/Liquipedia/Lua-Modules to contribute
--

local Array = require('Module:Array')
local Lua = require('Module:Lua')
local Table = require('Module:Table')

local LegacyPrizePool = Lua.import('Module:PrizePool/Legacy', {requireDevIfEnabled = true})

local Opponent = require('Module:OpponentLibraries').Opponent

local SPECIAL_PLACES = {dq = 'dq', dnf = 'dnf', dnp = 'dnp', w = 'w', d = 'd', l = 'l', q = 'q'}

local CustomLegacyPrizePool = {}

local _opponent_type
local TBD = 'TBD'

-- Template entry point
function CustomLegacyPrizePool.run()
	return LegacyPrizePool.run(CustomLegacyPrizePool)
end

function CustomLegacyPrizePool.customHeader(newArgs, CACHED_DATA, header)
	newArgs.prizesummary = false

	_opponent_type = header.opponentType or Opponent.solo
	CACHED_DATA.opponentType = _opponent_type
	newArgs.type = {type = _opponent_type}

	return newArgs
end

function CustomLegacyPrizePool.opponentsInSlot(slot)
	local slotInputSize
	if slot.place and not SPECIAL_PLACES[string.lower(slot.place)] then
		local placeRange = mw.text.split(slot.place, '-')
		slotInputSize = tonumber(placeRange[#placeRange]) - tonumber(placeRange[1]) + 1
	end

	local numberOfOpponentsFromInput
	if Opponent.typeIsParty(_opponent_type) then
		numberOfOpponentsFromInput = #slot / Opponent.partySize(_opponent_type)
	else
		numberOfOpponentsFromInput = #slot
	end

	return math.max(math.min(slotInputSize or math.huge, numberOfOpponentsFromInput), 1)
end

function CustomLegacyPrizePool.overwriteMapOpponents(slot, newData, mergeSlots)
	local mapOpponent = function (opponentIndex)
		local opponentData = CustomLegacyPrizePool._readOpponentArgs{
			slot = slot,
			opponentIndex = opponentIndex,
		}

		opponentData = opponentData or {}
		opponentData.date = slot['date' .. opponentIndex] or opponentData.date

		return Table.merge(newData, opponentData)
	end

	local opponents = Array.map(Array.range(1, slot.opponentsInSlot), function(opponentIndex)
		return mapOpponent(opponentIndex) or {} end)

	return opponents
end

function CustomLegacyPrizePool._readOpponentArgs(props)
	local slot = props.slot
	local opponentIndex = props.opponentIndex

	if _opponent_type == Opponent.team then
		return {
			type = _opponent_type,
			[1] = slot[opponentIndex] or slot['team' .. opponentIndex],
		}
	end

	-- solo, duo, trio, quad
	local opponentData = {type = _opponent_type}
	local previousOpponentArgsIndex = (opponentIndex - 1) * Opponent.partySize(_opponent_type)
	for playerIndex = 1, Opponent.partySize(_opponent_type) do
		local argsPlayerIndex = previousOpponentArgsIndex + playerIndex
		local nameInput = mw.text.split(slot[argsPlayerIndex] or TBD, '|')

		opponentData['p' .. playerIndex] = nameInput[#nameInput]
		opponentData['p' .. playerIndex .. 'link'] = slot['link' .. opponentIndex .. 'p' .. playerIndex] or nameInput[1]
		opponentData['p' .. playerIndex .. 'flag'] = slot['flag' .. opponentIndex .. 'p' .. playerIndex]
		opponentData['p' .. playerIndex .. 'team'] = slot['team' .. opponentIndex .. 'p' .. playerIndex]
	end

	return opponentData
end

return CustomLegacyPrizePool
