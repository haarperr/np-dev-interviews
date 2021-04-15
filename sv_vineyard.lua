-- Handle requests to the server from the client to start a vineyard job
-- Ensures the player is not already working and generates a random set of two fields for them to work
RegisterNetEvent("np-vineyard-work-server:GetJob")
AddEventHandler(
	"np-vineyard-work-server:GetJob",
	function()
		print("np-vineyard-work-server:GetJob " .. source)

		-- Don't let the player start the job twice
		if (GetIsNoPixelPlayerWorkingJob(source)) then
			SendNoPixelUiMessage(source, "Already working...")
			return
		end

		SetNoPixelPlayerIsWorkingJob(source, true)
		local groupId = GetNoPixelNewGroupId()

		-- Generate the random fields to be selected
		local firstField = GetRandom(1, #VineyardFieldLocations)
		local secondField = GetRandom(1, #VineyardFieldLocations)
		while (firstField == secondField) do
			secondField = GetRandom(1, #VineyardFieldLocations)
		end

		TriggerClientEvent("np-vineyard-work-client:StartJob", source, groupId, firstField, secondField)

		-- Populate the group information
		InitNoPixelWorkingGroup(groupId, firstField, secondField)
		AddNoPixelPlayerToGroup(source, groupId)

		TriggerClientEvent(
			"np-vineyard-work-client:MoveToField",
			source,
			VineyardCurrentlyWorkingGroups[groupId]["CurrentField"]
		)
	end
)

-- Handles requests for players to be added to a group
RegisterNetEvent("np-vineyard-work-server:AddToGroup")
AddEventHandler(
	"np-vineyard-work-server:AddToGroup",
	function(groupId)
		if not (DoesNoPixelGroupIdExist(groupId)) then
			-- Not handling this case as proper groups will be implemented with NP code
			return
		end

		AddNoPixelPlayerToGroup(source, groupId)

		-- Send the new group member the move instructions
		TriggerClientEvent(
			"np-vineyard-work-client:StartJob",
			source,
			VineyardCurrentlyWorkingGroups[groupId]["CurrentField"],
			VineyardCurrentlyWorkingGroups[groupId]["NextField"]
		)
		TriggerClientEvent(
			"np-vineyard-work-client:MoveToField",
			source,
			VineyardCurrentlyWorkingGroups[groupId]["CurrentField"]
		)
	end
)

-- Handles requests from the client to attempt picking at a certain location within a field
-- Validates that the areas has not already been picked and that the number of total picks
-- for a given group's field is not already over the limit
RegisterNetEvent("np-vineyard-work-server:AttemptPick")
AddEventHandler(
	"np-vineyard-work-server:AttemptPick",
	function(groupId, fieldNumber, posX, posY)
		print("np-vineyard-work-server:AttemptPick " .. source .. groupId .. fieldNumber .. posX .. posY)

		-- Determine which array index to add at
		local nextPickAreaIndex = 1
		if (VineyardWorkingFieldsStatus[fieldNumber][groupId] ~= nil) then
			nextPickAreaIndex = #VineyardWorkingFieldsStatus[fieldNumber][groupId] + 1
		else
			VineyardWorkingFieldsStatus[fieldNumber][groupId] = {}
		end

		-- If there are more picks than required or the distance between picks is not high enough, return a failure
		local failToPick = VineyardCurrentlyWorkingGroups[groupId]["CurrentPicks"] >= VineyardRequiredPicksPerField

		if (not failToPick and nextPickAreaIndex ~= 1) then
			for i, pickedArea in pairs(VineyardWorkingFieldsStatus[fieldNumber][groupId]) do
				if
					(math.sqrt((pickedArea["PosX"] - posX) ^ 2 + (pickedArea["PosY"] - posY) ^ 2) <= VineyardLocationPickDistance and
						(pickedArea["InProgress"] or pickedArea["Completed"]))
				 then
					failToPick = true
					break
				end
			end
		end

		if (failToPick) then
			TriggerClientEvent("np-vineyard-work-client:FailPickAtLocation", source)
			SendNoPixelUiMessage(source, "Area has already been picked. Move further down the vines.")

			return
		end

		-- If the pick attempt will be allowed, set it as in progress
		VineyardWorkingFieldsStatus[fieldNumber][groupId][nextPickAreaIndex] = {
			["Completed"] = false,
			["InProgress"] = true,
			["PosX"] = posX,
			["PosY"] = posY
		}

		-- Inform the client the pick attempt is allowed and start the animation and timer
		TriggerClientEvent("np-vineyard-work-client:PickAtLocation", source, nextPickAreaIndex)
	end
)

-- In the event a player cancels the pick attempt themself, reset the in progress state
RegisterNetEvent("np-vineyard-work-server:CancelPick")
AddEventHandler(
	"np-vineyard-work-server:CancelPick",
	function(groupId, fieldNumber, pickedAreaIndex)
		print("np-vineyard-work-server:CancelPick " .. source .. groupId .. fieldNumber .. pickedAreaIndex)

		VineyardWorkingFieldsStatus[fieldNumber][groupId][pickedAreaIndex]["InProgress"] = false
	end
)

-- When a client has finished an  allowed pick attempt, update the tracked pick attempt status and determine
-- if the next step of the job should be started
RegisterNetEvent("np-vineyard-work-server:FinishPick")
AddEventHandler(
	"np-vineyard-work-server:FinishPick",
	function(groupId, fieldNumber, pickedAreaIndex)
		print("np-vineyard-work-server:FinishPick " .. source .. groupId .. fieldNumber .. pickedAreaIndex)

		if not (GetIsNoPixelPlayerWorkingJob(source)) then
			-- Not handling this case as proper groups will be implemented with NP code
			return
		end

		VineyardWorkingFieldsStatus[fieldNumber][groupId][pickedAreaIndex]["InProgress"] = false
		VineyardWorkingFieldsStatus[fieldNumber][groupId][pickedAreaIndex]["Completed"] = true

		VineyardCurrentlyWorkingGroups[groupId]["CurrentPicks"] = VineyardCurrentlyWorkingGroups[groupId]["CurrentPicks"] + 1

		print("Finishing pick")
		TriggerClientEvent("np-vineyard-work-client:FinishPickAtLocation", source)

		print("Current picks " .. VineyardCurrentlyWorkingGroups[groupId]["CurrentPicks"])

		-- Job progression logic
		if
			(VineyardCurrentlyWorkingGroups[groupId]["CurrentPicks"] >= VineyardRequiredPicksPerField and
				VineyardCurrentlyWorkingGroups[groupId]["NextField"] ~= nil)
		 then
			-- If the # picks requried is met and they are on the first field, move to the second
			VineyardCurrentlyWorkingGroups[groupId]["CurrentPicks"] = 0

			-- Don't track this group's field metrics in memory anymore
			VineyardWorkingFieldsStatus[fieldNumber][groupId] = nil

			-- TODO: Replace this functionality with group based checkpoint to move to next field
			MoveNoPixelGroupToNextFieldStage(groupId)

			VineyardCurrentlyWorkingGroups[groupId]["NextField"] = nil
		elseif
			-- If the # of picks required is met and they are on the second field, move to job end
			(VineyardCurrentlyWorkingGroups[groupId]["CurrentPicks"] >= VineyardRequiredPicksPerField and
				VineyardCurrentlyWorkingGroups[groupId]["NextField"] == nil)
		 then
			VineyardCurrentlyWorkingGroups[groupId]["JobCompleted"] = true

			for player, _ in pairs(GetNoPixelPlayersInGroup(groupId)) do
				TriggerClientEvent("np-vineyard-work-client:FinishAllPicking", player)
			end
		end
	end
)

-- Attempt to complete the job when the player has returned to the NPC and pressed Alt.
-- Validates the job is in a completed state and then issues rewards to the players in a group.
RegisterNetEvent("np-vineyard-work-server:FinishJob")
AddEventHandler(
	"np-vineyard-work-server:FinishJob",
	function(groupId)
		print("np-vineyard-work-server:FinishJob " .. source .. groupId)

		if not (VineyardCurrentlyWorkingGroups[groupId]["JobCompleted"]) then
			SendNoPixelUiMessage("Picking has not been completed. Unable to complete the job.")
			return
		end

		for player, _ in pairs(GetNoPixelPlayersInGroup(groupId)) do
			local materialsRewarded = GetRandom(VineyardMinWineReward, VineyardMaxWineReward)

			TriggerClientEvent("np-vineyard-work-client:JobFinished", player)

			AddRewardItemsToPlayerInventory(player, materialsRewarded)

			SetNoPixelPlayerIsWorkingJob(player, false)
		end
	end
)

-- Add a disconnect check that will drop the player from any existing group
AddEventHandler(
	"playerDropped",
	function(reason)
		print("Player " .. GetPlayerName(source) .. " dropped (Reason: " .. reason .. ")")

		if (GetIsNoPixelPlayerWorkingJob(source)) then
			SetNoPixelPlayerIsWorkingJob(source, false)
			DropNoPixelPlayerFromAnyWorkingGroup(source)
		end
	end
)

-- Generate a random value between two numbers (inclusive)
local RandomInitialized = false
function GetRandom(minVal, maxVal)
	if not RandomInitialized then
		print("Initializing random")
		math.randomseed(GetGameTimer())
		RandomInitialized = true
	end

	return math.random(minVal, maxVal)
end
