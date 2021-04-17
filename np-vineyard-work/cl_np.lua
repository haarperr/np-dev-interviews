local CurrentStep = 1
local CurrentJobSteps = {}

-- TESTING ONLY. Remove when external NoPixel startActivity call is added
RegisterCommand(
	"vineyard",
	function(source, args)
		startActivity(source)
	end,
	false
)
-- TESTING ONLY. Remove when external NoPixel setActivityStatus call is added
RegisterCommand(
	"vineyardtoggle",
	function(source, args)
		setActivityStatus(not IsActivityEnabled)
	end,
	false
)

-- For simplicity, implement a method of spawning peds that will be overwritten by NP code
function NoPixelSpawnPed(pedModel, positionVector, entityHeading, networkEntity, freezeEntity, invincibleEntity)
	local pedHash = GetHashKey(pedModel)
	RequestModel(pedHash)

	while not HasModelLoaded(pedHash) do
		Citizen.Wait(0)
	end

	local createdPed =
		CreatePed(0, pedHash, positionVector.x, positionVector.y, positionVector.z, entityHeading, networkEntity, false)
	FreezeEntityPosition(createdPed, freezeEntity)

	if (invincibleEntity) then
		SetEntityInvincible(createdPed, true)
		SetBlockingOfNonTemporaryEvents(createdPed, true)
		SetPedCanBeTargetted(createdPed, false)
	end

	return createdPed
end

-- Functionality of alt third eye tracking for the job ped
-- Only a very basic implementation as I assume the library for this is well established
function StartJobPedEyeTrackingThread()
	Citizen.CreateThread(
		function()
			print("StartJobPedEyeTrackingThread" .. tostring(IsPlayerAtVineyardPed))

			while IsPlayerAtVineyardPed do
				if (IsControlJustPressed(0, 19)) then
					if (IsPlayerPendingTools) then
						TriggerEvent(VineyardActivityName .. "-client:ReceiveTools")
					end
					if (IsAllPickingFinished) then
						TriggerServerEvent(VineyardActivityName .. "-server:FinishJob", CurrentGroupId)
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
			print("StartFieldEyeTrackingThread")

			while IsPlayerAtCorrectField do
				if (IsControlJustPressed(0, 19)) then
					TriggerEvent(VineyardActivityName .. "-client:AttemptPick")
				end

				Citizen.Wait(0)
			end
		end
	)
end

-- Request any animation and play it on the player with a specified time and flags
function NoPixelPlayAnimationOnPlayerPed(animDict, animName, animTimeMs, animFlags)
	RequestAnimDict(animDict)
	while (not HasAnimDictLoaded(animDict)) do
		Citizen.Wait(0)
	end

	TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, 1.0, animTimeMs, animFlags, 0.5, false, false, false)
end
