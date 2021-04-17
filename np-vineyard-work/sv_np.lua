function NoPixelGetNewGroupId()
	return #VineyardCurrentlyWorkingGroups + 1
end

function DropNoPixelPlayerFromAnyWorkingGroup(player)
	for i, group in pairs(VineyardCurrentlyWorkingGroups) do
		if (group["Players"][player] ~= nil) then
			group["Players"][player] = nil
			break
		end
	end
end
