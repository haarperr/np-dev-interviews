-- Define variables used for tracking current job state
IsActivityEnabled = true
IsWorkingJob = false

IsPlayerAtVineyardPed = false
IsPlayerPendingTools = false

IsPlayerAtCorrectField = false
HasPlayerBeenAtCorrectField = false
IsPendingPickAction = false
IsCurrentlyPicking = false
IsAllPickingFinished = false

CurrentGroupId = 0
CurrentFieldId = 0

local JobBlip = 0
local JobPedEntity = 0
local CurrentDestinationBlip = 0

-- Accept this export call to enable / disable the activity completely
function setActivityStatus(enabled)
	Citizen.CreateThread(
		function()
			IsActivityEnabled = enabled

			if (enabled) then
				-- If the activity is being enabled, spawn the job ped and create the map blip
				JobPedEntity = NoPixelSpawnPed(VineyardJobPedModel, VineyardJobPosVector, VineyardJobPedHeading, false, true, true)

				-- Generate a blip for the job and name it
				JobBlip = CreateBlipWithText(VineyardJobPosVector, 469, 7, 255, false, "VineyardJobBlip", "Vineyard Job")
			else
				-- If the activity is being disabled, delete the blip and job ped if they already exist
				if (JobPedEntity ~= 0) then
					DeletePed(JobPedEntity)
				end

				if (JobBlip ~= 0) then
					RemoveBlip(jobBlip)
				end

				if (IsWorkingJob) then
					-- Fail the activity if it is currently in progress
					exports["np-activities"]:activityCompleted(
						VineyardActivityName,
						GetPlayerServerId(PlayerId()),
						false,
						"Failed job due to activity being disabled."
					)
				end
			end
		end
	)
end

-- Basic thread at startup for setting the activity status to its configured default
setActivityStatus(VineyardActivityEnabledByDefault)

-- To start an activity from a random location
function startActivity(playerServerId)
	if (not IsActivityEnabled or not exports["np-activities"]:canDoActivity(VineyardActivityName, playerServerId)) then
		exports["np-activities"]:notifyPlayer(playerServerId, "Unable to start activity.")
		return
	end

	IsWorkingJob = true
	TriggerServerEvent(VineyardActivityName .. "-server:StartActivity")
end

-- Enable or disable a field location
function setLocationStatus(locationId, enabled)
	VineyardFieldLocations[locationId]["Enabled"] = enabled
	TriggerServerEvent(VineyardActivityName .. "-server:SetLocationEnabled", locationId, enabled)
end

-- Update a player's job blips. In case the locationId is 0, use the default job blip
function setActivityDestination(locationId)
	-- Start by removing any existing destination
	removeActivityDestination(locationId)

	local blipId = JobBlip
	if (locationId ~= 0) then
		-- Add a blip and store its ID
		CurrentDestinationBlip =
			CreateBlipWithText(
			vector3(
				VineyardFieldLocations[locationId]["FieldCenterX"],
				VineyardFieldLocations[locationId]["FieldCenterY"],
				VineyardFieldLocations[locationId]["FieldCenterZ"]
			),
			469,
			7,
			65,
			true,
			"VineyardBlip" .. locationId,
			"Vineyard " .. VineyardFieldLocations[locationId]["FieldName"]
		)

		blipId = CurrentDestinationBlip
	end

	-- Add a minimap route
	SetBlipRoute(blipId, true)
	SetBlipRouteColour(blipId, 7)
end

-- This script only activates a single destination blip at once
-- So locationId is not needed, but it should be defined in the export
function removeActivityDestination(locationId)
	if (CurrentDestinationBlip ~= 0) then
		RemoveBlip(CurrentDestinationBlip)
		CurrentDestinationBlip = 0
	end

	ClearAllBlipRoutes()
end

-- Handle starting the job. Occurs after a player has requested the job and the server has initialized
-- new job parameters and triggered this event
RegisterNetEvent(VineyardActivityName .. "-client:StartJob")
AddEventHandler(
	VineyardActivityName .. "-client:StartJob",
	function(groupId, firstFieldId, secondFieldId)
		Citizen.CreateThread(
			function()
				IsWorkingJob = true
				IsPlayerPendingTools = true
				IsAllPickingFinished = false
				CurrentGroupId = groupId
				CurrentFieldId = firstFieldId

				-- Start the activity tracking in NoPixel code
				exports["np-activities"]:activityInProgress(VineyardActivityName, GetPlayerServerId(PlayerId()))

				-- Assume that the player can always do the initial task of picking up tools from the supervisor
				exports["np-activities"]:taskInProgress(
					VineyardActivityName,
					GetPlayerServerId(PlayerId()),
					VineyardGetToolsTaskName,
					VineyardGetToolsTaskDescription
				)

				-- Start the blip route to the job start point
				setActivityDestination(0)
			end
		)
	end
)

-- Handle receiving tools from the vineyard supervisor. Received after a player presses a key at the 
-- supervisor after starting the job
RegisterNetEvent(VineyardActivityName .. "-client:ReceiveTools")
AddEventHandler(
	VineyardActivityName .. "-client:ReceiveTools",
	function()
		Citizen.CreateThread(
			function()
				IsPlayerPendingTools = false

				-- Only allow a single picking knife per person
				if not (exports["np-activities"]:hasInventoryItem(GetPlayerServerId(PlayerId()), VineyardPickingKnifeName)) then
					exports["np-activities"]:giveInventoryItem(GetPlayerServerId(PlayerId()), VineyardPickingKnifeName, 1)
				end

				-- Mark the tools task as completed
				exports["np-activities"]:taskCompleted(
					VineyardActivityName,
					GetPlayerServerId(PlayerId()),
					VineyardGetToolsTaskName,
					true,
					"Retrieved tools."
				)

				-- Trigger the task to move to the first field
				if
					(exports["np-activities"]:canDoTask(VineyardActivityName, GetPlayerServerId(PlayerId()), VineyardMoveFieldTaskName))
				 then
					TriggerEvent(VineyardActivityName .. "-client:MoveToField", CurrentFieldId)
				end
			end
		)
	end
)

-- Handle the task of giving a player a field to move to. Sent by the server
-- after job has been started and after a field has had the required number of
-- picks performed
RegisterNetEvent(VineyardActivityName .. "-client:MoveToField")
AddEventHandler(
	VineyardActivityName .. "-client:MoveToField",
	function(fieldNumber)
		Citizen.CreateThread(
			function()
				CurrentFieldId = fieldNumber
				IsPlayerAtCorrectField = false
				HasPlayerBeenAtCorrectField = false

				-- Update the blip routing
				setActivityDestination(fieldNumber)

				-- Start the task of moving to the first field
				exports["np-activities"]:taskInProgress(
					VineyardActivityName,
					GetPlayerServerId(PlayerId()),
					VineyardMoveFieldTaskName,
					VineyardMoveFieldTaskDescription
				)

				-- Send the player a message saying to move and update the tracked future UI status
				exports["np-activities"]:notifyPlayer(
					GetPlayerServerId(PlayerId()),
					"Please move to the next field " .. VineyardFieldLocations[fieldNumber]["FieldName"]
				)
			end
		)
	end
)

-- Handle a player having successfully moved to a field location. Sent by the client after arriving at the field
-- Completes the move task and starts the picking task
RegisterNetEvent(VineyardActivityName .. "-client:MovedToField")
AddEventHandler(
	VineyardActivityName .. "-client:MovedToField",
	function(fieldNumber)
		Citizen.CreateThread(
			function()
				HasPlayerBeenAtCorrectField = true

				-- Complete the assigned move to field task
				exports["np-activities"]:taskCompleted(
					VineyardActivityName,
					GetPlayerServerId(PlayerId()),
					VineyardMoveFieldTaskName,
					true,
					"Arrived at field."
				)

				if
					(not exports["np-activities"]:canDoTask(
						VineyardActivityName,
						GetPlayerServerId(PlayerId()),
						VineyardPickFieldTaskName
					))
				 then
					exports["np-activities"]:notifyPlayer(GetPlayerServerId(PlayerId()), "Unable to start picking at this field.")
					return
				end

				-- Start the task of picking at a certain field
				exports["np-activities"]:taskInProgress(
					VineyardActivityName,
					GetPlayerServerId(PlayerId()),
					VineyardPickFieldTaskName,
					VineyardPickFieldTaskDescription
				)
			end
		)
	end
)

-- Handle a player attempting to pick at the vines. Sent by the client after attempting to pick
-- at the correct field
RegisterNetEvent(VineyardActivityName .. "-client:AttemptPick")
AddEventHandler(
	VineyardActivityName .. "-client:AttemptPick",
	function()
		Citizen.CreateThread(
			function()
				-- Don't allow multiple pick attempts at once
				if (IsPendingPickAction or IsCurrentlyPicking) then
					exports["np-activities"]:notifyPlayer(GetPlayerServerId(PlayerId()), "Unable to pick right now.")
					return
				end

				-- Don't allow picking if they no longer have their picking knife
				if (exports["np-activities"]:hasInventoryItem(GetPlayerServerId(PlayerId()), VineyardPickingKnifeName)) then
					exports["np-activities"]:notifyPlayer(GetPlayerServerId(PlayerId()), "You need to have your tools to pick.")
					return
				end

				IsPendingPickAction = true

				-- Send a verification request to the server so the areas which have been picked can't be picked
				-- multiple times
				local playerCoords = GetEntityCoords(PlayerPedId())
				TriggerServerEvent(
					VineyardActivityName .. "-server:AttemptPick",
					CurrentGroupId,
					CurrentFieldId,
					playerCoords.x,
					playerCoords.y
				)
			end
		)
	end
)

-- Handle a valid pick. Sent by the server after verification that a pick attempt is valid. Triggers
-- the animation and cancellation threads
RegisterNetEvent(VineyardActivityName .. "-client:PickAtLocation")
AddEventHandler(
	VineyardActivityName .. "-client:PickAtLocation",
	function(pickedAreaIndex)
		Citizen.CreateThread(
			function()
				IsPendingPickAction = false
				IsCurrentlyPicking = true

				-- Play the picking animation
				exports["np-activities"]:notifyPlayer(GetPlayerServerId(PlayerId()), "Picking...")
				NoPixelPlayAnimationOnPlayerPed(
					VineyardPickAnimDict,
					VineyardPickAnimName,
					VineyardRequiredPickTimeMs,
					VineyardPickAnimFlags
				)

				-- Check for cancellation of the task over the defined interval
				for i = 1, VineyardRequiredPickTimeMs / 100 do
					if (IsControlPressed(0, 23)) then
						TriggerServerEvent(VineyardActivityName .. "-server:CancelPick", CurrentGroupId, CurrentFieldId, pickedAreaIndex)

						exports["np-activities"]:notifyPlayer(GetPlayerServerId(PlayerId()), "Cancelled pick attempt.")

						ClearPedTasksImmediately(PlayerPedId())
						IsCurrentlyPicking = false

						return
					end

					Citizen.Wait(100)
				end

				-- Send a request to the server to finish picking at the current pick location
				-- Increments the current count of picks for this field
				TriggerServerEvent(VineyardActivityName .. "-server:FinishPick", CurrentGroupId, CurrentFieldId, pickedAreaIndex)
			end
		)
	end
)

-- In the event that a pick attempt is not allowed by the server, reset the local tracking variables
RegisterNetEvent(VineyardActivityName .. "-client:FailPickAtLocation")
AddEventHandler(
	VineyardActivityName .. "-client:FailPickAtLocation",
	function()
		IsPendingPickAction = false
		IsCurrentlyPicking = false
		exports["np-activities"]:notifyPlayer(
			GetPlayerServerId(PlayerId()),
			"Area has already been picked. Move further down the vines."
		)
	end
)

-- In the event that a pick attempt is allowed by the server, set the local tracking variables
RegisterNetEvent(VineyardActivityName .. "-client:FinishPickAttempt")
AddEventHandler(
	VineyardActivityName .. "-client:FinishPickAttempt",
	function()
		IsCurrentlyPicking = false

		exports["np-activities"]:notifyPlayer(GetPlayerServerId(PlayerId()), "Picking complete.")
	end
)

-- In the event that a pick attempt is allowed by the server, set the local tracking variables
RegisterNetEvent(VineyardActivityName .. "-client:FinishPickAtField")
AddEventHandler(
	VineyardActivityName .. "-client:FinishPickAtField",
	function()
		IsCurrentlyPicking = false

		exports["np-activities"]:taskCompleted(
			VineyardActivityName,
			GetPlayerServerId(PlayerId()),
			VineyardPickFieldTaskName,
			true,
			"Finished picking at field."
		)
	end
)

-- In the event that the server has counted all required pick attempts for both fields, set
-- the local tracking variables and update necessary UI elements
RegisterNetEvent(VineyardActivityName .. "-client:FinishAllPicking")
AddEventHandler(
	VineyardActivityName .. "-client:FinishAllPicking",
	function(groupId)
		IsPlayerAtCorrectField = false
		IsAllPickingFinished = true

		-- Set a blip task back at the job start
		setActivityDestination(0)

		exports["np-activities"]:taskInProgress(
			VineyardActivityName,
			GetPlayerServerId(PlayerId()),
			VineyardReturnToolsTaskName,
			VineyardReturnTaskDescription
		)
	end
)

-- Handle returning the tools for the supervisor. Sent by the client after arriving at the supervisor
-- after picking all assigned fields
RegisterNetEvent(VineyardActivityName .. "-client:ReturnTools")
AddEventHandler(
	VineyardActivityName .. "-client:ReturnTools",
	function()
		Citizen.CreateThread(
			function()
				IsPlayerPendingTools = false

				-- Remove the picking knife if they still have it on their person
				if (exports["np-activities"]:hasInventoryItem(GetPlayerServerId(PlayerId()), VineyardPickingKnifeName)) then
					exports["np-activities"]:removeInventoryItem(GetPlayerServerId(PlayerId()), VineyardPickingKnifeName, 1)
				end

				-- Complete the task of returning tools
				exports["np-activities"]:taskCompleted(
					VineyardActivityName,
					GetPlayerServerId(PlayerId()),
					VineyardReturnToolsTaskName,
					true,
					"Returned tools."
				)

				-- Send a request to the server which completes the job and will determine
				-- the number of rewards to receive
				TriggerServerEvent(VineyardActivityName .. "-server:FinishJob", CurrentGroupId)
			end
		)
	end
)

-- In the event the server received a completion request before picking was complete, sent
-- a failure notification
RegisterNetEvent(VineyardActivityName .. "-client:JobFinishedFailure")
AddEventHandler(
	VineyardActivityName .. "-client:JobFinishedFailure",
	function()
		exports["np-activities"]:notifyPlayer(
			GetPlayerServerId(PlayerId()),
			"Picking has not been completed. Unable to complete the job."
		)
	end
)

-- Once the server has declared a job finished, reset the local tracking variables
RegisterNetEvent(VineyardActivityName .. "-client:JobFinished")
AddEventHandler(
	VineyardActivityName .. "-client:JobFinished",
	function(materialsRewarded)
		-- Reset local job tracking variables
		IsWorkingJob = false
		CurrentGroupId = 0
		CurrentFieldId = 0
		IsPlayerPendingTools = false
		IsPendingPickAction = false
		IsCurrentlyPicking = false
		IsAllPickingFinished = false
		ClearAllBlipRoutes()

		exports["np-activities"]:activityCompleted(
			VineyardActivityName,
			GetPlayerServerId(PlayerId()),
			true,
			"Successfully completed the job and received " .. materialsRewarded .. " wine bottles."
		)

		exports["np-activities"]:giveInventoryItem(GetPlayerServerId(PlayerId()), VineyardRewardWineName, materialsRewarded)
	end
)

-- Handlers for entering the Vineyard job ped and field zones
-- TODO: Replace with np-polyzone enter event name
RegisterNetEvent("bt-polyzone:enter")
AddEventHandler(
	"bt-polyzone:enter",
	function(name)
		if (name ~= "Vineyard.JobPed") then
			return
		end

		IsPlayerAtVineyardPed = true

		StartJobPedEyeTrackingThread()
	end
)
AddEventHandler(
	"bt-polyzone:enter",
	function(name)
		-- This handles the field zones only. Exit out if not at that step or if the wrong zone is given
		if (not IsWorkingJob or string.find(name, "Vineyard.Vines") == nil) then
			return
		end

		if (name ~= VineyardFieldLocations[CurrentFieldId]["FieldZone"]) then
			return
		end

		IsPlayerAtCorrectField = true

		if (not HasPlayerBeenAtCorrectField) then
			TriggerEvent(VineyardActivityName .. "-client:MovedToField")
		end

		StartFieldEyeTrackingThread()
	end
)

-- Handlers for exiting the Vineyard zones
-- TODO: Replace with np-polyzone enter event name
RegisterNetEvent("bt-polyzone:exit")
AddEventHandler(
	"bt-polyzone:exit",
	function(name)
		if (string.find(name, "Vineyard") == nil) then
			return
		end

		IsPlayerAtVineyardPed = false
		IsPlayerAtCorrectField = false
	end
)
