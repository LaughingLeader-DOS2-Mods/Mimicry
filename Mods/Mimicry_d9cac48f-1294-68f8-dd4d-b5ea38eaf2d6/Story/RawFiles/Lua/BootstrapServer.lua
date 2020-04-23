function SaveFacingDirection(uuid)
	local character = Ext.GetCharacter(uuid)
	local rot = character.Stats.Rotation
	Ext.Print("Rotation: ", LeaderLib.Common.Dump(rot))
	Osi.LLMIME_Skills_SaveFacingTable(uuid, rot[7], rot[9])
	Ext.Print("[Mimicry:SaveFacingDirection] Saved facing direction for ", uuid)
end

function ApplyFacingDirection(uuid)
	Ext.Print("[Mimicry:ApplyFacingDirection] Applying facing direction for ", uuid)
	local dbEntry = Osi.DB_LLMIME_Skills_FacingDirection:Get(uuid, nil, nil)
	if dbEntry ~= nil and #dbEntry > 0 then
		local rotx = dbEntry[1][2]
		local rotz = dbEntry[1][3]
		local x,y,z = 0.0,0.0,0.0
		if rotx~= nil and rotz ~= nil then
			local character = Ext.GetCharacter(uuid)
			local pos = character.Stats.Position
			local distanceMult = 2.0
			local forwardVector = {
				-rotx * distanceMult,
				0,
				-rotz * distanceMult,
			}
			x = pos[1] + forwardVector[1]
			z = pos[3] + forwardVector[3]
			--CharacterUseSkillAtPosition(uuid, "Target_LLMIME_ApplyFacingDirection", x, y, z, 0, 1)
			local target = TemporaryCharacterCreateAtPosition(x, y, z, "LeaderLib_SkillDummy_94668062-11ea-4ecf-807c-4cc225cbb236", 0)
			CharacterLookAt(uuid, target, 0)
			RemoveTemporaryCharacter(target)
			--CharacterFlushQueue(uuid)
			--PlayEffectAtPosition("RS3_FX_Char_Creatures_Fire_Slug_BatteringRam_Impact_01",x,y,z)
			Ext.Print("[Mimicry:ApplyFacingDirection] Facing direction: ", x, y, z)
			--local rot = character.Stats.Rotation
		else
			Ext.PrintError("[Mimicry:ApplyFacingDirection] Failed: Saved rotation is null:\n"..tostring(LeaderLib.Common.Dump(dbEntry)))
		end
	else
		Ext.PrintError("[Mimicry:ApplyFacingDirection] No saved rotation for mime:\n"..tostring(LeaderLib.Common.Dump(dbEntry)))
	end
end