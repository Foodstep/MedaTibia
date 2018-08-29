function onSay(cid, words, param)

	if words == "!code64" then
	return 0
	end
	
	if words == "/reloadSpellBar" then
	   doUpdateCooldowns(cid)
	   return true
    end

return 0
end