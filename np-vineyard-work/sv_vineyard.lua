-- Handle requests to the server from the client to start a vineyard job
-- Generates a random set of two fields for them to work
RegisterNetEvent(VineyardActivityName .. "-server:StartActivity")
AddEventHandler(
	VineyardActivityName .. "-server:StartActivity",
	function()
		local groupId = NoPixelGetNewGroupId()

		-- Generate the random fields to be selected
		local firstFieldId = GetRandom(1, #VineyardFieldLocations)
		while (not (VineyardFieldLocations[firstFieldId]["Enabled"])) do
			firstFieldId = GetRandom(1, #VineyardFieldLocations)
		end
		local secondFieldId = GetRandom(1, #VineyardFieldLocations)
		while (firstFieldId == secondFieldId or not (VineyardFieldLocations[secondFieldId]["Enabled"])) do
			secondFieldId = GetRandom(1, #VineyardFieldLocations)
		end

		TriggerClientEvent(VineyardActivityName .. "-client:StartJob", source, groupId, firstFieldId, secondFieldId)

		-- Populate the group information
		VineyardCurrentlyWorkingGroups[groupId] = {
			["Players"] = {[source] = true},
			["JobCompleted"] = false,
			["CurrentField"] = firstFieldId,
			["NextField"] = secondFieldId,
			["CurrentPicks"] = 0
		}
	end
)

-- Handles requests from the client to attempt picking at a certain location within a field
-- Validates that the areas has not already been picked and that the number of total picks
-- for a given group's field is not already over the limit
RegisterNetEvent(VineyardActivityName .. "-server:AttemptPick")
AddEventHandler(
	VineyardActivityName .. "-server:AttemptPick",
	function(groupId, fieldNumber, posX, posY)
		-- Determine which array index to add the new pick request at at
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

		-- Send a client event to inform them the pick will not be successful
		if (failToPick) then
			TriggerClientEvent(VineyardActivityName .. "-client:FailPickAtLocation", source)

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
		TriggerClientEvent(VineyardActivityName .. "-client:PickAtLocation", source, nextPickAreaIndex)
	end
)

-- In the event a player cancels the pick attempt themself, reset the in progress state
-- so it will not block at that location
RegisterNetEvent(VineyardActivityName .. "-server:CancelPick")
AddEventHandler(
	VineyardActivityName .. "-server:CancelPick",
	function(groupId, fieldNumber, pickedAreaIndex)
		VineyardWorkingFieldsStatus[fieldNumber][groupId][pickedAreaIndex]["InProgress"] = false
	end
)

-- When a client has finished an  allowed pick attempt, update the tracked pick attempt status and determine
-- if the next step of the job should be started
RegisterNetEvent(VineyardActivityName .. "-server:FinishPick")
AddEventHandler(
	VineyardActivityName .. "-server:FinishPick",
	function(groupId, fieldNumber, pickedAreaIndex)
		-- When a pick has finished
		VineyardWorkingFieldsStatus[fieldNumber][groupId][pickedAreaIndex]["InProgress"] = false
		VineyardWorkingFieldsStatus[fieldNumber][groupId][pickedAreaIndex]["Completed"] = true
		VineyardCurrentlyWorkingGroups[groupId]["CurrentPicks"] = VineyardCurrentlyWorkingGroups[groupId]["CurrentPicks"] + 1

		-- Send an ack back to the client and notify them
		TriggerClientEvent(VineyardActivityName .. "-client:FinishPickAttempt", source)

		-- Job progression logic
		if
			(VineyardCurrentlyWorkingGroups[groupId]["CurrentPicks"] >= VineyardRequiredPicksPerField and
				VineyardCurrentlyWorkingGroups[groupId]["NextField"] ~= nil)
		 then
			-- If the # picks required is met and they are on the first field, move to the second
			VineyardCurrentlyWorkingGroups[groupId]["CurrentPicks"] = 0

			-- Don't track this group's field metrics in memory anymore
			VineyardWorkingFieldsStatus[fieldNumber][groupId] = nil

			-- Send the client events to register task completion and start the task to
			-- move to the next field
			TriggerClientEvent(VineyardActivityName .. "-client:FinishPickAtField", source)
			TriggerClientEvent(
				VineyardActivityName .. "-client:MoveToField",
				source,
				VineyardCurrentlyWorkingGroups[groupId]["NextField"]
			)

			VineyardCurrentlyWorkingGroups[groupId]["NextField"] = nil
		elseif
			-- If the # of picks required is met and they are on the second field, move to job end
			(VineyardCurrentlyWorkingGroups[groupId]["CurrentPicks"] >= VineyardRequiredPicksPerField and
				VineyardCurrentlyWorkingGroups[groupId]["NextField"] == nil)
		 then
			VineyardCurrentlyWorkingGroups[groupId]["JobCompleted"] = true

			-- Send the client events to register task completion and start the task to
			-- return tools
			TriggerClientEvent(VineyardActivityName .. "-client:FinishPickAtField", source)
			TriggerClientEvent(VineyardActivityName .. "-client:FinishAllPicking", source)
		end
	end
)

-- Attempt to complete the job when the player has returned to the NPC and pressed Alt.
-- Validates the job is in a completed state and then issues rewards to the players in a group.
RegisterNetEvent(VineyardActivityName .. "-server:FinishJob")
AddEventHandler(
	VineyardActivityName .. "-server:FinishJob",
	function(groupId)
		if not (VineyardCurrentlyWorkingGroups[groupId]["JobCompleted"]) then
			TriggerClientEvent(VineyardActivityName .. "-client:JobFinishedPickingNotComplete", source)
			return
		end

		local materialsRewarded = GetRandom(VineyardMinWineReward, VineyardMaxWineReward)
		TriggerClientEvent(VineyardActivityName .. "-client:JobFinished", source, materialsRewarded)
	end
)

-- Disable the specified location on the server side so it will not be randomly assigned
RegisterNetEvent(VineyardActivityName .. "-server:SetLocationEnabled")
AddEventHandler(
	VineyardActivityName .. "-server:SetLocationEnabled",
	function(locationId, enabled)
		VineyardFieldLocations[locationId]["Enabled"] = enabled
	end
)

-- Add a disconnect check that will drop the player from any existing group
AddEventHandler(
	"playerDropped",
	function(reason)
		print("Player " .. GetPlayerName(source) .. " dropped (Reason: " .. reason .. ")")

		DropNoPixelPlayerFromAnyWorkingGroup(source)
	end
)
