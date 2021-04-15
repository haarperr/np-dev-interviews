function SendNoPixelUiMessage(player, message)
	TriggerClientEvent(
		"chat:addMessage",
		player,
		{
			color = {255, 0, 0},
			multiline = true,
			args = {"Vineyard", message}
		}
	)
end

function GetNoPixelNewGroupId()
	return #VineyardCurrentlyWorkingGroups + 1
end

function DoesNoPixelGroupIdExist(groupId)
	return VineyardCurrentlyWorkingGroups[groupId] ~= nil
end

function InitNoPixelWorkingGroup(groupId, firstField, secondField)
	VineyardCurrentlyWorkingGroups[groupId] = {
		["Players"] = {},
		["JobCompleted"] = false,
		["CurrentField"] = firstField,
		["NextField"] = secondField,
		["CurrentPicks"] = 0
	}
end

function AddNoPixelPlayerToGroup(player, groupId)
	VineyardCurrentlyWorkingGroups[groupId]["Players"][player] = true
end

function GetNoPixelPlayersInGroup(groupId)
	return VineyardCurrentlyWorkingGroups[groupId]["Players"]
end

function DropNoPixelPlayerFromAnyWorkingGroup(player)
	for i, group in pairs(VineyardCurrentlyWorkingGroups) do
		if (group["Players"][player] ~= nil) then
			group["Players"][player] = nil
			break
		end
	end
end

function SetNoPixelPlayerIsWorkingJob(player, value)
	VineyardCurrentlyWorkingPlayers[player] = value
end

function GetIsNoPixelPlayerWorkingJob(player)
	return (VineyardCurrentlyWorkingPlayers[player] ~= nil and VineyardCurrentlyWorkingPlayers[player] == true)
end

function AddRewardItemsToPlayerInventory(player, materialsAdded)
	SendNoPixelUiMessage(player, "Received " .. tostring(materialsAdded) .. " for completion of the job.")
end

function MoveNoPixelGroupToNextFieldStage(groupId)
	for player, _ in pairs(GetNoPixelPlayersInGroup(groupId)) do
		TriggerClientEvent(
			"np-vineyard-work-client:MoveToField",
			player,
			VineyardCurrentlyWorkingGroups[groupId]["NextField"]
		)
	end
end