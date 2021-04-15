local CurrentStep = 1
local CurrentJobSteps = {}

-- For simplicity, track the job states as a title and whether step is completed
function SetNoPixelJobSteps(firstFieldName, secondFieldName)
	CurrentStep = 1
	CurrentJobSteps = {
		[1] = {
			["Step"] = "Talk to the supervisor",
			["Completed"] = false
		},
		[2] = {
			["Step"] = "Move to the next field: " .. firstFieldName,
			["Completed"] = false
		},
		[3] = {
			["Step"] = "Pick " .. VineyardRequiredPicksPerField .. " times",
			["Completed"] = false
		},
		[4] = {
			["Step"] = "Move to the next field: " .. secondFieldName,
			["Completed"] = false
		},
		[5] = {
			["Step"] = "Pick " .. VineyardRequiredPicksPerField .. " times",
			["Completed"] = false
		},
		[6] = {
			["Step"] = "Return to the supervisor",
			["Completed"] = false
		}
	}
end

function IncrementNoPixelJobUiStatus()
	CurrentJobSteps[CurrentStep]["Completed"] = true
	CurrentStep = CurrentStep + 1
end

function SendNoPixelUiMessage(message)
	TriggerEvent(
		"chat:addMessage",
		{
			color = {255, 0, 0},
			multiline = true,
			args = {"Vineyard", message}
		}
	)
end

-- Functionality of alt third eye tracking for the job ped
-- Only a very basic implementation as I assume the library for this is well established
function StartJobPedEyeTrackingThread()
	Citizen.CreateThread(
		function()
			print('StartJobPedEyeTrackingThread' .. tostring(IsPlayerAtJobPed))

			while IsPlayerAtJobPed do
				if (IsControlJustPressed(0, 19)) then
					if (IsAllPickingFinished) then
						TriggerServerEvent("np-vineyard-work-server:FinishJob", CurrentGroupId)
					elseif not (IsWorkingJob) then
						TriggerServerEvent("np-vineyard-work-server:GetJob")
					end
				end

				Citizen.Wait(0)
			end
		end
	)
end

-- Functionality of alt third eye tracking during field work
-- Only a very basic implementation as I assume the library for this is well established
function StartFieldEyeTrackingThread()
	Citizen.CreateThread(
		function()
			print('StartFieldEyeTrackingThread')

			while IsPlayerAtCorrectField do
				if (IsControlJustPressed(0, 19) and not IsPendingPickAction and not IsCurrentlyPicking) then
					IsPendingPickAction = true

					local playerCoords = GetEntityCoords(PlayerPedId())
					TriggerServerEvent(
						"np-vineyard-work-server:AttemptPick",
						CurrentGroupId,
						CurrentFieldId,
						playerCoords.x,
						playerCoords.y
					)
				end

				Citizen.Wait(0)
			end
		end
	)
end
