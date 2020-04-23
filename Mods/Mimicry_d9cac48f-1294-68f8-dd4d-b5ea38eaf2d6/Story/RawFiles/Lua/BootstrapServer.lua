function SaveFacingDirection(uuid)
	local character = Ext.GetCharacter(uuid)
	local rot = character.Stats.Rotation
	Ext.Print("Rotation: ", LeaderLib.Common.Dump(rot))
	Osi.DB_LLMIME_Skills_FacingDirection:Delete(uuid, nil)
	Osi.DB_LLMIME_Skills_FacingDirection(uuid, Ext.JsonStringify(rot))
end

function ApplyFacingDirection(uuid)
	local dbEntry = Osi.DB_LLMIME_Skills_FacingDirection:Get(uuid, nil)
	if dbEntry ~= nil and #dbEntry > 0 then
		local rot = nil
		rot = Ext.JsonParse(dbEntry[1][2])
		if rot ~= nil then
			local x,y,z = 0.0,0.0,0.0
			local character = Ext.GetCharacter(uuid)
			local pos = character.Stats.Position
			local distanceMult = 2.0
			local forwardVector = {
				-rot[7] * distanceMult,
				0,
				-rot[9] * distanceMult,
			}
			x = pos[1] + forwardVector[1]
			z = pos[3] + forwardVector[3]
			CharacterUseSkillAtPosition(uuid, "Target_LLMIME_ApplyFacingDirection", x, y, z, 0, 1)
			CharacterFlushQueue(uuid)
			Ext.Print("Facing direction: ", x, y, z)
			--local rot = character.Stats.Rotation
		else
			Ext.PrintError("[Mimicry:ApplyFacingDirection] Failed: Saved rotation is null:\n"..tostring(LeaderLib.Common.Dump(dbEntry)))
		end
	end
end