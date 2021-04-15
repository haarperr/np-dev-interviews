-- Define variables used for tracking current job state
IsWorkingJob = false
IsPlayerAtJobPed = false
IsPlayerAtCorrectField = false
IsPendingPickAction = false
IsCurrentlyPicking = false
IsAllPickingFinished = false
CurrentGroupId = 0
CurrentFieldId = 0

local JobBlip = 0
local CurrentFieldBlip = 0
local BasketEntityId = 0

-- Basic thread at startup for spawning the Vineyard NPC
Citizen.CreateThread(
	function()
		local jobPedHash = GetHashKey(VineyardJobPedModel)
		RequestModel(jobPedHash)

		while not HasModelLoaded(jobPedHash) do
			Citizen.Wait(0)
		end

		local jobPed =
			CreatePed(0, jobPedHash, VineyardJobPos.x, VineyardJobPos.y, VineyardJobPos.z, VineyardJobPedHeading, false, false)
		FreezeEntityPosition(jobPed, true)
		SetEntityInvincible(jobPed, true)
		SetBlockingOfNonTemporaryEvents(jobPed, true)
		SetPedCanBeTargetted(jobPed, false)

		-- Generate a blip for the job and name it
		JobBlip = AddBlipForCoord(VineyardJobPos.x, VineyardJobPos.y, VineyardJobPos.z)
		SetBlipSprite(JobBlip, 469)
		SetBlipColour(JobBlip, 7)
		AddTextEntry("VineyardJobBlip", "Vineyard Job")
		BeginTextCommandSetBlipName("VineyardJobBlip")
		EndTextCommandSetBlipName(JobBlip)
	end
)

-- Handle starting the job. Occurs after a player has pressed Alt at Vineyard NPC
-- and server declares the job can be started
RegisterNetEvent("np-vineyard-work-client:StartJob")
AddEventHandler(
	"np-vineyard-work-client:StartJob",
	function(groupId, firstField, secondField)
		Citizen.CreateThread(
			function()
				IsWorkingJob = true
				IsAllPickingFinished = false
				CurrentGroupId = groupId

				SendNoPixelUiMessage("Starting job...")
				SetNoPixelJobSteps(
					VineyardFieldLocations[firstField]["FieldName"],
					VineyardFieldLocations[secondField]["FieldName"]
				)
			end
		)
	end
)

-- Handle the task of giving a player a field to move to. Sent by the server
-- after job has been started and after a field has had the required number of
-- picks performed
RegisterNetEvent("np-vineyard-work-client:MoveToField")
AddEventHandler(
	"np-vineyard-work-client:MoveToField",
	function(fieldNumber)
		Citizen.CreateThread(
			function()
				CurrentFieldId = fieldNumber
				IsPlayerAtCorrectField = false

				-- If a field blip already exists, remove it
				if (CurrentFieldBlip ~= 0) then
					RemoveBlip(CurrentFieldBlip)
				end

				-- Add a blip and store its ID
				CurrentFieldBlip =
					AddBlipForCoord(
					VineyardFieldLocations[fieldNumber]["FieldCenterX"],
					VineyardFieldLocations[fieldNumber]["FieldCenterY"],
					VineyardFieldLocations[fieldNumber]["FieldCenterZ"]
				)
				SetBlipSprite(CurrentFieldBlip, 469)
				SetBlipColour(CurrentFieldBlip, 7)
				SetBlipAsShortRange(CurrentFieldBlip, true)
				SetBlipAlpha(CurrentFieldBlip, 65)

				-- Name the blip
				local blipText = "Vineyard " .. VineyardFieldLocations[fieldNumber]["FieldName"]
				AddTextEntry("VineyardBlip" .. fieldNumber, blipText)
				BeginTextCommandSetBlipName("VineyardBlip" .. fieldNumber)
				EndTextCommandSetBlipName(CurrentFieldBlip)

				-- Add a minimap route
				ClearAllBlipRoutes()
				SetBlipRoute(CurrentFieldBlip, true)
				SetBlipRouteColour(CurrentFieldBlip, 7)

				-- Send the player a message saying to move and update the tracked future UI status
				SendNoPixelUiMessage("Please move to the next field: " .. VineyardFieldLocations[fieldNumber]["FieldName"])
				IncrementNoPixelJobUiStatus()
			end
		)
	end
)

-- Handle the task of giving a player a field to move to. Sent by the server
-- after Alt has been pressed at the correct field and pick is allowed
RegisterNetEvent("np-vineyard-work-client:PickAtLocation")
AddEventHandler(
	"np-vineyard-work-client:PickAtLocation",
	function(pickedAreaIndex)
		Citizen.CreateThread(
			function()
				IsPendingPickAction = false
				IsCurrentlyPicking = true

				SendNoPixelUiMessage("Picking...")

				-- Request the picking animation and play it on the player
				RequestAnimDict(VineyardJobAnimDict)
				while (not HasAnimDictLoaded(VineyardJobAnimDict)) do
					Citizen.Wait(50)
				end
				TaskPlayAnim(
					PlayerPedId(),
					VineyardJobAnimDict,
					VineyardJobAnim,
					1.0,
					1.0,
					VineyardJobPickTimeMs,
					0,
					0.5,
					true,
					true,
					true
				)

				-- Check for cancellation of the task over the defined interval
				for i = 1, VineyardJobPickTimeMs / 100 do
					if (IsControlPressed(0, 23)) then
						TriggerServerEvent("np-vineyard-work-server:CancelPick", CurrentGroupId, CurrentFieldId, pickedAreaIndex)

						SendNoPixelUiMessage("Cancelled pick attempt.")

						ClearPedTasksImmediately(PlayerPedId())
						IsCurrentlyPicking = false

						return
					end

					Citizen.Wait(100)
				end

				-- Send a request to the server to finish picking at the current pick location
				-- Increments the current count of picks for this field
				TriggerServerEvent("np-vineyard-work-server:FinishPick", CurrentGroupId, CurrentFieldId, pickedAreaIndex)
			end
		)
	end
)

-- In the event that a pick attempt is not allowed by the server, reset the local tracking variables
RegisterNetEvent("np-vineyard-work-client:FailPickAtLocation")
AddEventHandler(
	"np-vineyard-work-client:FailPickAtLocation",
	function()
		IsPendingPickAction = false
		IsCurrentlyPicking = false
	end
)

-- In the event that a pick attempt is allowed by the server, set the local tracking variables
RegisterNetEvent("np-vineyard-work-client:FinishPickAtLocation")
AddEventHandler(
	"np-vineyard-work-client:FinishPickAtLocation",
	function()
		IsCurrentlyPicking = false

		SendNoPixelUiMessage("Picking complete.")
	end
)

-- In the event that the server has counted all required pick attempts for both fields, set
-- the local tracking variables and update necessary UI elements
RegisterNetEvent("np-vineyard-work-client:FinishAllPicking")
AddEventHandler(
	"np-vineyard-work-client:FinishAllPicking",
	function(groupId)
		IsPlayerAtCorrectField = false
		IsAllPickingFinished = true

		RemoveBlip(CurrentFieldBlip)
		CurrentFieldBlip = 0
		ClearAllBlipRoutes()
		SetBlipRoute(JobBlip, true)
		SetBlipRouteColour(JobBlip, 7)

		SendNoPixelUiMessage("Finished picking all fields. Return for processing.")
		IncrementNoPixelJobUiStatus()
	end
)

-- Once the server has declared a job finished, reset the local tracking variables
RegisterNetEvent("np-vineyard-work-client:JobFinished")
AddEventHandler(
	"np-vineyard-work-client:JobFinished",
	function()
		-- Reset local job tracking variables
		IsWorkingJob = false
		CurrentGroupId = 0
		CurrentFieldId = 0
		IsPendingPickAction = false
		IsCurrentlyPicking = false
		IsAllPickingFinished = false
		ClearAllBlipRoutes()
	end
)

-- Handlers for entering the Vineyard job ped and field zones
-- TODO: Replace with np-polyzone enter event name
RegisterNetEvent("bt-polyzone:enter")
AddEventHandler(
	"bt-polyzone:enter",
	function(name)
		if (name ~= "Vineyard.VinesJobPed") then
			return
		end

		IsPlayerAtJobPed = true

		StartJobPedEyeTrackingThread()
	end
)
AddEventHandler(
	"bt-polyzone:enter",
	function(name)
		if (not IsWorkingJob or string.find(name, "Vineyard.Vines") == nil) then
			return
		end

		if (name ~= VineyardFieldLocations[CurrentFieldId]["FieldZone"]) then
			print("Incorrect field")
			return
		end

		IsPlayerAtCorrectField = true

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

		IsPlayerAtJobPed = false
		IsPlayerAtCorrectField = false
	end
)
