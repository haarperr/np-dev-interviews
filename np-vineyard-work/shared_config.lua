-- Activity and task name configuration
VineyardActivityName = "np-vineyard-work"
VineyardActivityEnabledByDefault = true

VineyardGetToolsTaskName = "np-vineyard-work-get-tools"
VineyardGetToolsTaskDescription = "Retrieve tools from the supervisor."

VineyardMoveFieldTaskName = "np-vineyard-work-move-field"
VineyardMoveFieldTaskDescription = "Move to the assigned field."

VineyardPickFieldTaskName = "np-vineyard-work-pick-field"
VineyardPickFieldTaskDescription = "Pick at the assigned field."

VineyardReturnToolsTaskName = "np-vineyard-work-return-tools"
VineyardReturnTaskDescription = "Return tools to the supervisor."

-- Inventory item configuration
VineyardPickingKnifeName = "Picking Knife"
VineyardRewardWineName = "Wine Bottle"

-- Prop configuration
VineyardPickingKnifePropName = "prop_knife"
VineyardPickingKnifeHandBoneIndex = 57005
VineyardPickingKnifeOffset = vector3(0.12, 0.13, 0.08)
VineyardPickingKnifeRotation = vector3(40.0, 0.0, 0.0)

-- Define the configuration for spawning the job ped and its icon
VineyardJobPosVector = vector3(-1910.75, 2072.67, 139.38)
VineyardJobPedModel = "a_m_y_busicas_01"
VineyardJobPedHeading = 140.1

-- Animation settings
VineyardPickAnimDict = "amb@world_human_gardener_plant@male@base"
VineyardPickAnimName = "base"
VineyardPickAnimFlags = 17

-- Activity time limit settings
VineyardActivityTimeMinMs = 300000
VineyardActivityTimeMaxMs = 1800000
VineyardRandomizeActivityTime = true

-- Basic configuration of vineyard job picking task
VineyardRequiredPickTimeMs = 5000
VineyardRequiredPicksPerField = 5 -- This is intentionally a low amount for testing
VineyardLocationPickDistance = 5.0

-- Item reward configuration
VineyardMinWineReward = 10
VineyardMaxWineReward = 20
