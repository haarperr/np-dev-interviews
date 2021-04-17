function CreateBlipWithText(
	blipPosVector,
	blipSprite,
	blipColor,
	blipAlpha,
	isShortRange,
	blipTextName,
	blipTextDescription)
	local createdBlip = AddBlipForCoord(blipPosVector.x, blipPosVector.y, blipPosVector.z)

	SetBlipSprite(createdBlip, blipSprite)
	SetBlipColour(createdBlip, blipColor)
	SetBlipAlpha(createdBlip, blipAlpha)
	SetBlipAsShortRange(createdBlip, isShortRange)

	AddTextEntry(blipTextName, blipTextDescription)
	BeginTextCommandSetBlipName(blipTextName)
	EndTextCommandSetBlipName(createdBlip)

	return createdBlip
end
