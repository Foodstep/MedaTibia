Spellbar = {}
SpellbarBox = nil
SpellButton = nil

local isIn = 'H' --[[ 'H' = horizontal; 'V' = vertical ]]--
local namesAtks = ''
local icons = {}

function Spellbar.init()
    connect(g_game, {onGameStart = Spellbar.run}) 

   SpellbarBox = g_ui.displayUI('game_spellbar', modules.game_interface.getRootPanel())
   SpellbarBox:setVisible(false)  
   SpellbarBox:move(250,50)
   
   SpellButton = modules.client_topmenu.addRightGameToggleButton('spellButton', tr('Attacks') .. ' (Ctrl+0)', '/images/topbuttons/skills', toggle) 

   connect(g_game, 'onTextMessage', getParams)
   connect(g_game, { onGameEnd = hide } )
   connect(LocalPlayer, { onLevelChange = onLevelChange })
  
   g_mouse.bindPress(SpellbarBox, function() createMenu() end, MouseRightButton)  

   createIcons() 
end

function Spellbar.terminate()
    disconnect(g_game, {onGameStart = Spellbar.run})
end

function Spellbar.run()
    --SpellbarBox = g_ui.displayUI('game_spellbar.otui')
end

function welcome() 
	show() 
end

function Spellbar.destroy()
		SpellbarBox:hide()
end

function onLevelChange(localPlayer, value, percent)
 
   g_game.talk("/reloadSpellBar")
end

function createIcons()
   local d = 38
   for i = 1, 12 do
      local icon = g_ui.createWidget('SpellIcon', SpellbarBox)
      local progress = g_ui.createWidget('SpellProgress', SpellbarBox) 
      icon:setId('Icon'..i)  
      progress:setId('Progress' ..i)
      icons['Icon'..i] = {icon = icon, progress = progress, dist = (i == 1 and 5 or i == 2 and 38 or d + ((i-2)*34)), event = nil}
      icon:setMarginTop(icons['Icon'..i].dist)
      icon:setMarginLeft(4)
      progress:fill(icon:getId())
      progress.onClick = function() g_game.talk('m'..i) end
   end
end

function toggle() 
	--if not SpellbarBox:isVisible() then return end 
  if not SpellbarBox:isVisible() then
	   SpellbarBox:setVisible(false)
	   if isIn == 'H' then
	      isIn = 'V'
	   else 
	      isIn = 'H'
	   end 
   FixTooltip()
   show() else hide() end
end

function hide() 
   SpellbarBox:setVisible(false)
end

function show() 
   SpellbarBox:setVisible(true)
end

function FixTooltip(text)  
   SpellbarBox:setHeight(isIn == 'H' and 416 or 40) 
   SpellbarBox:setWidth(isIn == 'H' and 40 or 416)
   if not text then text = namesAtks else namesAtks = text end 
   
   local t2 = text:explode(",")
   local count = 0
   for j = 2, 13 do
       local ic = icons['Icon'..(j-1)]
       ic.icon:setMarginLeft(isIn == 'H' and 4 or ic.dist)
       ic.icon:setMarginTop(isIn == 'H' and ic.dist or 4)
       if t2[j] == 'n/n' then    
          ic.icon:hide()      
          count = count+1
       else
          ic.icon:show()
          ic.progress:setTooltip(t2[j]) 
          ic.progress:setVisible(true)
       end
   end
   if count > 0 and count ~= 12 then
      if isIn == "H" then
         SpellbarBox:setHeight(416 - (count*34))
      else
         SpellbarBox:setWidth(416 - (count*34))
      end
   elseif count == 12 then
      SpellbarBox:setHeight(40)
      SpellbarBox:setWidth(40)
      local p = icons['Icon1'].progress
      p:setTooltip(false)
      p:setVisible(false)
   end                
end

function createMenu()
   local menu = g_ui.createWidget('PopupMenu')
   menu:addOption(tr("Set "..(isIn == 'H' and 'Vertical' or 'Horizontal')), function() toggle() end)
   menu:display()
end

function getParams(mode, text) 
   if not g_game.isOnline() then return end
   if mode == MessageModes.Failure then 
      if string.find(text, '12//,') then
         if string.find(text, 'hide') then hide() else show() end
      elseif string.find(text, '12|,') then
         atualizarCDs(text)
      elseif string.find(text, '12&,') then
         FixTooltip(text)
      end
   end
end
 
function atualizarCDs(text) 
	if not g_game.isOnline() then return end
	if not SpellbarBox:isVisible() then return end 
	   local t = text:explode(",")
	   table.remove(t, 1)   
	   for i = 1, 12 do
	       local t2 = t[i]:explode("|")
	       barChange(i, tonumber(t2[1]), tonumber(t2[2]), tonumber(t2[3]))
	   end 
end

function changePercent(progress, icon, perc, num, init)
   if not SpellbarBox:isVisible() then return end      
   if init then
      progress:setPercent(0)
   else
      progress:setPercent(progress:getPercent()+perc)
   end
   if progress:getPercent() >= 100 then 
      progress:setText("")
      return
   end
   progress:setText(num)
   icons[icon:getId()].event = scheduleEvent(function() changePercent(progress, icon, perc, num-1) end, 1000)
end

function barChange(ic, num, lvl, lvlPoke)
	if not g_game.isOnline() then return end
	if not SpellbarBox:isVisible() then return end 
	   local icon = icons['Icon'..ic].icon
	   local progress = icons['Icon'..ic].progress
	   
	   if not progress:getTooltip() then return end
	   local player = g_game.getLocalPlayer()
	   local pathOn = "moves_icon/"..progress:getTooltip().."_on.png"
	   
	   icon:setImageSource(pathOn)
	   
	   if num and num >= 1 then   
	      cleanEvents('Icon'..ic)
	      changePercent(progress, icon, 100/num, num, true)      
	   else   
	      if (lvlPoke and lvlPoke < lvl) or player:getLevel() < lvl then
	         progress:setPercent(0)
	         progress:setText('L.'.. lvl)
	         progress:setColor('#FF0000')
	      else
	         progress:setPercent(100)
	         progress:setText("") 
	      end
	   end    
end