useOTClient = true
useKpdoDlls = true 

function getNewMoveTable(table, n)
if table == nil or not n then return false end

local moves = {table.move1, table.move2, table.move3, table.move4, table.move5, table.move6, table.move7, table.move8, table.move9,
table.move10, table.move11, table.move12}

return moves[n] or false
end

function isTransformed(cid)
return isCreature(cid) and not isInArray({-1, "Ditto", "Shiny Ditto"}, getPlayerStorageValue(cid, 1010))  --alterado v1.9
end

function doUpdateMoves(cid)
if not isCreature(cid) then return true end
local summon = getCreatureSummons(cid)[1]
local ret = {}
table.insert(ret, "12&,")
if not summon then
   for a = 1, 12 do
       table.insert(ret, "n/n,")
   end
   doPlayerSendCancel(cid, table.concat(ret))
   addEvent(doUpdateCooldowns, 100, cid)
return true
end
if isTransformed(summon) then  --alterado v1.9
   moves = movestable[getPlayerStorageValue(summon, 1010)]
else                                                       
   moves = movestable[getCreatureName(summon)]
end
for a = 1, 12 do
    local b = getNewMoveTable(moves, a)
    if b then
       table.insert(ret, b.name..",")
    else
       table.insert(ret, "n/n,")
    end
end
doPlayerSendCancel(cid, table.concat(ret))
addEvent(doUpdateCooldowns, 100, cid)
end

function doUpdateCooldowns(cid)
if not isCreature(cid) then return true end
doPlayerSendCancel(cid, '12|,'..getPokemonCooldown(cid, 1)..'|0,'..getPokemonCooldown(cid, 2)..'|0,'..getPokemonCooldown(cid, 3)..'|0,'..getPokemonCooldown(cid, 4)..'|0,'..getPokemonCooldown(cid, 5)..'|0,'..getPokemonCooldown(cid, 6)..'|0,'..getPokemonCooldown(cid, 7)..'|0,'..getPokemonCooldown(cid, 8)..'|0,'..getPokemonCooldown(cid, 9)..'|0,'..getPokemonCooldown(cid, 10)..'|0,'..getPokemonCooldown(cid, 11)..'|0,'..getPokemonCooldown(cid, 12))                                             
end


function getPokemonCooldown(cid, move) -- Checa o cooldown do move prédefinido  
	return getItemAttribute(getPlayerSlotItem(cid, 8).uid, "cooldown"..move.."") or 0
end
------------------------- Por slot ------------------------- 
function getPokemonCooldownn(slot, move) -- Checa o cooldown do move prédefinido
	return getItemAttribute(slot, "cooldown"..move) or 0
end
------------------------- Por slot -------------------------
 
function setPokemonCooldown(uidd, move, time) -- Troca o cooldown do move prédefinido
	if getPlayerSlotItem(uidd, 8).uid > 0 then
		doItemSetAttribute(getPlayerSlotItem(uidd, 8).uid, "cooldown"..move, tostring(time))
	end
end
 
function setPokemonCooldownn(uid, move, time) -- Troca o cooldown do move prédefinido
   doItemSetAttribute(uid, "cooldown"..move, tostring(time))
end
 
function doPokemonDropCooldown(cid, move) -- Faz abaixar o cooldown prédefinedo, (3,2,1).
	if not isPlayer(cid) then return false end
	if getPlayerSlotItem(cid,8).uid == 0 then return false end
	if getPokemonCooldown(cid, move) == "Don't have this move." then return false end
 
	if getPokemonCooldown(cid, move) > 0 then
		doItemSetAttribute(getPlayerSlotItem(cid, 8).uid, "cooldown"..move, tostring(math.floor(getPokemonCooldownn(getPlayerSlotItem(cid,8).uid, move)-1))) 
		addEvent(doPokemonDropCooldown, 1300, cid, move)
	end
end
 
function getMoveLevel(cid, move, level) -- Checa o level do move usado.
   return doItemSetAttribute(getPlayerSlotItem(cid, 8).uid, "move"..move.."Level", tostring(level))
end
 
function getMoveName(cid, move, name) -- Checa o nome do move usado.
   return doItemSetAttribute(getPlayerSlotItem(cid, 8).uid, "move"..move.."Name", tostring(name))
end
 
function setHealCooldown(slot, move, time)
	doItemSetAttribute(slot, "cooldown"..move, tostring(time)) 
end
----------------------------------
function getMoveLevell(cid, move)
   return getItemAttribute(getPlayerSlotItem(cid, 8).uid, "move"..move.."Level") 
end
 
function getMoveNamee(cid, move)
   return getItemAttribute(getPlayerSlotItem(cid, 8).uid, "move"..move.."Name") 
end 
----------------------------------
 
function doGoBackSetCooldown(cid, moves)
	local pokeball = getPlayerSlotItem(cid, 8).uid
	local pokeName = getCreatureName(getCreatureSummons(cid)[1])
	
	for move = 1, 12 do
		if isInArray(_G["poke"..move], pokeName) then
			if getMoveNamee(cid, move) then
				local _move = movestable[pokeName][string.format("move%d", move)]
				doItemSetAttribute(pokeball, "move"..move.."Name", _move.name)
				doItemSetAttribute(pokeball, "move"..move.."Level", tostring(_move.level))
				doItemSetAttribute(pokeball, "cooldown"..move, tostring(_move.cd))
				doPokemonDropCooldown(cid, move)
			end
		else
			setPokemonCooldown(cid, move, "Don't have this move.")
		end
	end
end   
------------------------------------------------------------------------------------
 
function doGoBackSetCooldownInCatch(uid, name)
	for move = 1, 12 do
		local _move = movestable[name]["move"..move]
		if _move then
			doItemSetAttribute(uid, "move"..move.."Name", _move.name)
			doItemSetAttribute(uid, "move"..move.."Level", tostring(_move.level))
			doItemSetAttribute(uid, "cooldown"..move, tostring(_move.cd))
		else
			setPokemonCooldownn(uid, move, "Don't have this move.")
		end
	end
end   
---------------------------------------------------------------------------------
function doCureAllStatus(slot)
	for move = 1, 12 do
		if getPokemonCooldownn(slot, move) == "Don't have this move." or not getPokemonCooldownn(slot, move) then
			doItemSetAttribute(slot, "cooldown"..move, "Don't have this move.")
		else
			doItemSetAttribute(slot, "cooldown"..move, 0)
		end
	end
end 