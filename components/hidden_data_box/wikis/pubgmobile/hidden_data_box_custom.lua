---
-- @Liquipedia
-- wiki=pubgmobile
-- page=Module:HiddenDataBox/Custom
--
-- Please see https://github.com/Liquipedia/Lua-Modules to contribute
--

local Class = require('Module:Class')
local Lua = require('Module:Lua')
local Variables = require('Module:Variables')

local BasicHiddenDataBox = Lua.import('Module:HiddenDataBox', {requireDevIfEnabled = true})

local CustomHiddenDataBox = {}

function CustomHiddenDataBox.run(args)
	BasicHiddenDataBox.addCustomVariables = CustomHiddenDataBox.addCustomVariables
	return BasicHiddenDataBox.run(args)
end

function CustomHiddenDataBox.addCustomVariables(args, queryResult)
	Variables.varDefine('tournament_edate', Variables.varDefault('tournament_enddate'))

	BasicHiddenDataBox.checkAndAssign('tournament_publishertier', args.pubgpremier, queryResult.publishertier)
end

return Class.export(CustomHiddenDataBox)
