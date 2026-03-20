-- Visual Novel System by dionednd
--
-- v1.0.0

-- Thanks to jay_ts & m14 for sharing the color edit module publicly. i couldn't have done any of this without it.

-- TO DO:
-- a new function has to be made: visualnovel.registerCampaign(lua_path, campaign_name, unlock)
-- all registered campaigns will be checked each time the mode is selected to check if a new campaign has been unlocked.

commandAdd("holdup", "/$U", 1, 1)
commandAdd("holddown", "/$D", 1, 1)

local scrollTimer = 0

-- dumped all the complex stuff. i couldn't simplify a lot of things for the end user.

visualnovel = {}
visualnovel.storyboard_choices = {}
visualnovel.campaigns = {}
visualnovel.current_campaign = nil

-- contains all the save data you need.
visualnovel.data = {}

-- private data is data for the specific save files. this will be reset whenever you start a new game and/or load a save file.
-- we save the private data table with the save file.
-- we initialize the private data table with nothing since you don't really need to have any value for it unless we're loading a save file.
visualnovel.data.private = {}
visualnovel.data.private.progress = 0
visualnovel.data.private.backlog = {}

-- global data is data that persists through all saves (mostly used for unlocking stuff, for example you unlock a choice for the second playthrough)
-- we save the global data as a file that we load everytime the engine is run.
-- we initialize the global data table from the save file or set it to an empty table if global.sav doesn't exist yet. this is done so we always have the global data ready.
-- good design tip: always remember to use visualnovel.saveGlobalData() after making changes to the global data table.

visualnovel.data.global = {}
visualnovel.data.global.maxprogress = 1000
visualnovel.data.global.textspeed = 1.0

local functions = require("external.mods.visual_novel.visual_novel_functions")
functions.loadMotifExtensions("external/mods/visual_novel/visual_novel.def", "external/mods/visual_novel/visual_novel.def")

local tsSpeaker = functions.loadMotifFont(motif.visualnovel_info.speaker)

local aInputBg		= functions.loadMotifAnim(motif.visualnovel_info.input.bg)
local tsInput = functions.loadMotifFont(motif.visualnovel_info.input.text)
local tsInputCursor = functions.loadMotifFont(motif.visualnovel_info.input.text)

local aChoiceBg		= functions.loadMotifAnim(motif.visualnovel_info.choice.inactive.bg)
local tsChoice = functions.loadMotifFont(motif.visualnovel_info.choice.inactive.text)
local aChoiceBgActive		= functions.loadMotifAnim(motif.visualnovel_info.choice.active.bg)
local tsChoiceActive = functions.loadMotifFont(motif.visualnovel_info.choice.active.text)

local rectOverlay = functions.rectNew(motif.visualnovel_pause_menu.overlay)
local tsTitle = functions.loadMotifFont(motif.visualnovel_pause_menu.title)

local rectOverlayBacklog = functions.rectNew(motif.backlog_info.overlay)
local tsBacklog = functions.loadMotifFont(motif.backlog_info.backlog.text)
local tsTitleBacklog = functions.loadMotifFont(motif.backlog_info.title)

local boxCursor = functions.cursorNew(motif.visualnovel_pause_menu.menu.boxcursor)

local boxCursor2 = functions.cursorNew(motif.backlog_info.backlog.boxcursor)

local cursorPulse = {
	t = 0,
	speed = 0.08, -- pulse speed
	min = 0,
	max = 255
}

local _cursorPulse = {
	t = 0,
	speed = 0.08, -- pulse speed
	min = 0,
	max = 255
}

local tsItem = functions.loadMotifFont(motif.visualnovel_pause_menu.menu.item.inactive)
local tsItemActive = functions.loadMotifFont(motif.visualnovel_pause_menu.menu.item.active)

local tsItemLocked = functions.loadMotifFont(motif.visualnovel_pause_menu.menu.item.locked)
local tsItemLockedActive = functions.loadMotifFont(motif.visualnovel_pause_menu.menu.item.lockedactive)

local tsItemValue = functions.loadMotifFont(motif.visualnovel_pause_menu.menu.item.value)
local tsItemValueActive = functions.loadMotifFont(motif.visualnovel_pause_menu.menu.item.valueactive)

function visualnovel.loadSlot(slot)
	local path = "save/visualnovel/slot" .. slot .. "_" .. visualnovel.current_campaign .. ".sav"
	if not main.f_fileExists(path) then return false end

	saveData = jsonDecode(path)

	visualnovel.data.private = saveData.private or {}
	visualnovel.resume = {
	scene = saveData.scene,
	storyboard = saveData.storyboard,
	choices = saveData.choices or {},
	luaPath = saveData.luaPath
	}

	return true
end

function visualnovel.saveSlot(slot, storyboardPath, luaPath, choices)
	local path = "save/visualnovel/slot" .. slot .. "_" .. visualnovel.current_campaign .. ".sav"
	local continue_path = "save/visualnovel/continue_" .. visualnovel.current_campaign .. ".sav"

	local saveTable = {
		scene = getStoryboardScene(),
		storyboard = storyboardPath,
		luaPath = luaPath,
		choices = choices or {},
		private = visualnovel.data.private or {}
	}

	jsonEncode(saveTable, path)
	if slot <= 9 then
		jsonEncode(saveTable, continue_path)
	end
	return true
end

function visualnovel.quickLoad()
	local path = "save/visualnovel/slot10_" .. visualnovel.current_campaign .. ".sav"
	if not main.f_fileExists(path) then return false end

	saveData = jsonDecode(path)

	visualnovel.data.private = saveData.private or {}
	visualnovel.resume = {
	scene = saveData.scene,
	storyboard = saveData.storyboard,
	choices = saveData.choices or {},
	luaPath = saveData.luaPath
	}

	return true
end

function visualnovel.quickSave(storyboardPath, luaPath, choices)
	local path = "save/visualnovel/slot10_" .. visualnovel.current_campaign .. ".sav"
	local continue_path = "save/visualnovel/continue_" .. visualnovel.current_campaign .. ".sav"

	local saveTable = {
		scene = getStoryboardScene(),
		storyboard = storyboardPath,
		luaPath = luaPath,
		choices = choices or {},
		private = visualnovel.data.private or {}
	}

	jsonEncode(saveTable, path)
	jsonEncode(saveTable, continue_path)
	return true
end

function visualnovel.loadGlobalData()
	local path = "save/visualnovel/global.sav"
	if not main.f_fileExists(path) then
		visualnovel.data.global = { textspeed = 1.0 }
		return false
	end

	local data = jsonDecode(path)

	visualnovel.data.global = data
	return true
end

function visualnovel.saveGlobalData()
	local path = "save/visualnovel/global.sav"

	jsonEncode(visualnovel.data.global, path)
	return true
end

function visualnovel.storyboard(path, luaPath)

	-- mmm.. spaghetti..

	if visualnovel.resume then
		if visualnovel.resume.storyboard ~= path or visualnovel.resume.luaPath ~= debug.getinfo(2,'S').source then
			-- Skip entire storyboard
			return
		end
	end

	local vn = parseStoryboardDef(path)
	local s = loadStoryboard(path)
	
	if s == nil then
		return
	end

	local choices = {}
	table.insert(choices, false) -- exit code (false means the player didn't exit from the storyboard. true means the player left the storyboard without finishing it)
	visualnovel.choices = choices

	local choiceIndex = 1
	local choosing = false
	local temp = vn.startscene
	local current = vn.startscene
	local paused = false
	local _escHeld = false
	local select = false
	local pause_state = nil
	local prev_state = nil
	local pause_index = 1
	local pause_title = nil
	local backlog = false
	local backlog_index = 1
	local current_speaker = nil
	local backlog_viewing = false
	local new_textspeed = nil
	local new_textspeedvalue = nil
	local save = false
	local load = false
	local slot = 1
	local saveload_viewing = false
	local selectedSlot = nil
	local text = ""
	local cursorvisible = false
	local cursor = ""
	local skipAdvancesScene = false

	modifyStoryboard("scenedef.key.skip", motif.visualnovel_info.key.action)
	modifyStoryboard("scenedef.disablecancel", 1)

	local timer = 0

	if visualnovel.resume then
		modifyStoryboard("scenedef.startscene", visualnovel.resume.scene)
		temp = visualnovel.resume.scene
		current = visualnovel.resume.scene
		choices = visualnovel.resume.choices
		vn.startscene = visualnovel.resume.scene
		visualnovel.resume = nil
	end

	-- modify starting scene before running the storyboard because the first storyboard is very buggy if you try to modify it on the first frame or something.
	local realend = 0
	for i, layer in ipairs(vn.scenes[temp].layers) do
		if layer.text and layer.textdelay then
			local _text = functions.expandStoryboardVariables(layer.text)
			local _layer = {
				text = _text,
				speaker = layer.speaker or ""
			}
			if layer.speaker ~= nil and layer.speaker ~= "" then
				current_speaker = layer.speaker
			end

			if current_speaker ~= nil and current_speaker ~= "" then
				layer.speaker = current_speaker
			end
			if #visualnovel.data.private.backlog == 0 or( #visualnovel.data.private.backlog >= 1 and _text ~= visualnovel.data.private.backlog[1].text) then
				table.insert(visualnovel.data.private.backlog, 1, _layer)
			end

			-- after adding to the backlog, set their textdelay relative to the textspeed.
			-- these features break the text skipping feature.
			modifyStoryboard("scene_" .. temp .. ".layer" .. tostring(layer.index-1) .. ".textdelay", layer.textdelay * visualnovel.data.global.textspeed)
			modifyStoryboard("scene_" .. temp .. ".layer" .. tostring(layer.index-1) .. ".text", _text)

			if vn.scenes[temp].cutscene == 1 and realend < (layer.textdelay * visualnovel.data.global.textspeed) * string.len(_text) then
				modifyStoryboard("scene_" .. temp  .. ".end.time", (layer.textdelay * visualnovel.data.global.textspeed) * string.len(_text))
				realend = (layer.textdelay * visualnovel.data.global.textspeed) * string.len(_text)
			end
		end
	end
	
	while choices[1] == false do
		if getKey(motif.visualnovel_info.key.quicksave)  == true then
			resetKey()
			visualnovel.quickSave(path, luaPath, choices)
		elseif getKey(motif.visualnovel_info.key.quickload) == true then
			resetKey()
			visualnovel.quickLoad()
		end
		if visualnovel.resume then
			break
		end

		if not paused then
			if not runStoryboard() then
				break
			end

			if true then
				-- draw speaker text
				local _speaker = ""
				for i, layer in ipairs(vn.scenes[getStoryboardScene()].layers) do
					if layer.text ~= nil and layer.textdelay ~= nil and layer.speaker ~= nil and layer.speaker ~= "" then
						_speaker = layer.speaker
						break
					end
				end
				textImgSetText(tsSpeaker, _speaker)
				textImgSetPos(tsSpeaker, motif.visualnovel_info.speaker.offset[1], motif.visualnovel_info.speaker.offset[2])
				textImgDraw(tsSpeaker)

			end
		end

		if not paused then
			-- storyboard's step() is finished by this time so its counter is 1 by now.
			timer = timer + 1
		end

		temp = getStoryboardScene()
		if (temp ~= current) then
			if vn.scenes[temp].cutscene == 1 then
				skipAdvancesScene = true
			else
				skipAdvancesScene = false
			end
			choosing = false
			select = false
			-- scene has changed, so reset our timer to 1 since this is the first frame
			text = ""
			cursorvisible = false
			cursor = ""

			-- autosave
			if temp ~= current then
				visualnovel.saveSlot(11, path, luaPath, choices)
			end

			timer = 1

			-- also add text to backlog + modify textdelay relative to text speed
			local realend = 0
			for i, layer in ipairs(vn.scenes[temp].layers) do
				if layer.text and layer.textdelay then
					local _text = functions.expandStoryboardVariables(layer.text)
					local _layer = {
						text = _text,
						speaker = layer.speaker or ""
					}
					if layer.speaker ~= nil and layer.speaker ~= "" then
						current_speaker = layer.speaker
					end

					if current_speaker ~= nil and current_speaker ~= "" then
						layer.speaker = current_speaker
					end
					if #visualnovel.data.private.backlog == 0 or( #visualnovel.data.private.backlog >= 1 and _text ~= visualnovel.data.private.backlog[1].text) then
						table.insert(visualnovel.data.private.backlog, 1, _layer)
					end

					-- after adding to the backlog, set their textdelay relative to the textspeed.
					-- these features break the text skipping feature.
					modifyStoryboard("scene_" .. temp .. ".layer" .. tostring(layer.index-1) .. ".textdelay", layer.textdelay * visualnovel.data.global.textspeed)
					modifyStoryboard("scene_" .. temp .. ".layer" .. tostring(layer.index-1) .. ".text", _text)

					if vn.scenes[temp].cutscene == 1 and realend < (layer.textdelay * visualnovel.data.global.textspeed) * string.len(_text) then
						modifyStoryboard("scene_" .. temp  .. ".end.time", (layer.textdelay * visualnovel.data.global.textspeed) * string.len(_text))
						realend = (layer.textdelay * visualnovel.data.global.textspeed) * string.len(_text)
					end
				end
			end
			
			-- replace backlog with text from layers, but make sure that they have textdelay.
		end
		
		if not paused then

			-- Text Commands!
			for i, layer in ipairs(vn.scenes[temp].layers) do
				if layer.text and layer.textdelay and #layer.commands > 0 and timer < (layer.textdelay * visualnovel.data.global.textspeed) * string.len(functions.expandStoryboardVariables(layer.text)) then
					for i, command in ipairs(layer.commands) do
						local command_time = (layer.textdelay * visualnovel.data.global.textspeed) * (command.letter-2)
						if timer == command_time or (skipAdvancesScene or allFinished) or command.letter == -1 then
							if command.type == "sleep" and not (skipAdvancesScene or allFinished) and command.letter > 0 then
								local st = command.value * visualnovel.data.global.textspeed
								sleep(st)
							elseif command.type == "textspeed" and not (skipAdvancesScene or allFinished) and command.letter > 0 then
								modifyStoryboard("scene_" .. temp .. ".layer" .. tostring(layer.index-1) .. ".textdelay", command.value * visualnovel.data.global.textspeed)
							elseif command.type == "execute" and command.letter == -1 then
								assert(loadstring(command.value))()
							elseif command.letter == -1 then -- execute at the start of the scene instead of at the letter time
								if string.sub(command.type, 1, 7) == "global." then
									visualnovel.data.global[string.sub(command.type, 8, string.len(command.type))] = command.value
								elseif string.sub(command.type, 1, 6) == "local." then
									visualnovel.data.private[string.sub(command.type, 7, string.len(command.type))] = command.value
								else
									visualnovel.data.private[command.type] = command.value
								end
								modifyStoryboard("scene_" .. temp .. ".layer" .. tostring(layer.index-1) .. ".text", functions.expandStoryboardVariables(layer.text))
								table.remove(visualnovel.data.private.backlog, 1)
								local _layer = {
									text = functions.expandStoryboardVariables(layer.text),
									speaker = layer.speaker or ""
								}
								table.insert(visualnovel.data.private.backlog, 1, _layer)
							end
						end
					end
				end
			end
		end

		current = getStoryboardScene()
		local sceneData = vn.scenes[current]

		if sceneData and sceneData.cutscene ~= 1 then
			modifyStoryboard("scene_" .. current .. ".end.time", timer+sceneData.fadeout+2)
		end

		-- Pause Screen

		if (esc() or (getInput(-1, motif.visualnovel_info.key.pause) and (sceneData and sceneData.input ~= 1))) and backlog == false then
			esc(false)
			if (pause_state ~= motif.visualnovel_pause_menu.menutext.itemname and pause_state ~= motif.visualnovel_pause_menu.menuaudio.itemname and pause_state ~= motif.visualnovel_pause_menu.menusaveload.itemname) or pause_state == nil then
				local _paused = not paused
				sndPlay(motif.Snd, motif.visualnovel_info.cancel.snd[1], motif.visualnovel_info.cancel.snd[2])
				if _paused then
					paused = true
					playBgm({volume = gameOption('Sound.PauseMasterVolume'), interrupt = false})
					modifyStoryboard("scenedef.key.skip", "")
					bgReset(motif.visualnovelbgdef.BGDef)
					pause_state = motif.visualnovel_pause_menu.menu.itemname
					pause_index = 1
					cursorPulse.t = 0
					pause_title = motif.visualnovel_pause_menu.title.text
					choosing = false
				elseif not _paused then
					playBgm({volume = gameOption('Sound.MasterVolume'), interrupt = false})
					modifyStoryboard("scenedef.key.skip", motif.visualnovel_info.key.action)
					local realend = 0
					paused = false
				end
			elseif pause_state == motif.visualnovel_pause_menu.menutext.itemname or pause_state == motif.visualnovel_pause_menu.menuaudio.itemname or pause_state == motif.visualnovel_pause_menu.menusaveload.itemname then
				-- basically a repeat of the return function. spaghetti.
				sndPlay(motif.Snd, motif.visualnovel_info.cancel.snd[1], motif.visualnovel_info.cancel.snd[2])
				pause_state = prev_state
				pause_title = motif.visualnovel_pause_menu.title.text
				pause_index = 1
			end
		end

		if paused and backlog == false then
			-- Pause Menu

			-- rendering

			-- Background
			bgDraw(motif.visualnovelbgdef.BGDef, 0)

			-- Overlay
			rectDraw(rectOverlay)

			-- Title
			textImgSetText(tsTitle, pause_title)
			textImgSetPos(tsTitle, motif.visualnovel_pause_menu.title.offset[1], motif.visualnovel_pause_menu.title.offset[2])
			textImgDraw(tsTitle)

			-- Cursor

			cursorPulse.t = cursorPulse.t + cursorPulse.speed

			local a = (math.sin(cursorPulse.t) + 1) / 2
			local alpha = cursorPulse.min + a * (cursorPulse.max - cursorPulse.min)

			rectSetWindow(boxCursor,motif.visualnovel_pause_menu.menu.boxcursor.window[1] + (motif.visualnovel_pause_menu.menu.item.all.spacing[1] * (pause_index-1)), motif.visualnovel_pause_menu.menu.boxcursor.window[2] + (motif.visualnovel_pause_menu.menu.item.all.spacing[2] * (pause_index-1)), motif.visualnovel_pause_menu.menu.boxcursor.window[3] + (motif.visualnovel_pause_menu.menu.item.all.spacing[1] * (pause_index-1)), motif.visualnovel_pause_menu.menu.boxcursor.window[4] + (motif.visualnovel_pause_menu.menu.item.all.spacing[2] * (pause_index-1)))
			rectSetAlpha(boxCursor,motif.visualnovel_pause_menu.menu.boxcursor.alpha[1]*(alpha/255),motif.visualnovel_pause_menu.menu.boxcursor.alpha[2])
			rectDraw(boxCursor)

			-- Items
			local item_count = 0
			for key, label in pairs(pause_state) do
				local value_text = nil
				item_count = item_count + 1
				if label == "" then
					-- do nothing, spacer
				elseif type(label) == "string" then
					if pause_index == item_count then
						textImgSetText(tsItemActive, pause_state[key])
						textImgSetPos(tsItemActive, motif.visualnovel_pause_menu.menu.item.active.offset[1] + (motif.visualnovel_pause_menu.menu.item.all.spacing[1] * (item_count-1)), motif.visualnovel_pause_menu.menu.item.active.offset[2] + (motif.visualnovel_pause_menu.menu.item.all.spacing[2] * (item_count-1)))
						textImgDraw(tsItemActive)
					else
						textImgSetText(tsItem, pause_state[key])
						textImgSetPos(tsItem, motif.visualnovel_pause_menu.menu.item.inactive.offset[1] + (motif.visualnovel_pause_menu.menu.item.all.spacing[1] * (item_count-1)), motif.visualnovel_pause_menu.menu.item.inactive.offset[2] + (motif.visualnovel_pause_menu.menu.item.all.spacing[2] * (item_count-1)))
						textImgDraw(tsItem)
					end
					if tostring(key) == "textspeed" then
						value_text = new_textspeed
					elseif string.sub(tostring(key) , 1, string.len("slot"))== "slot" then
						if main.f_fileExists("save/visualnovel/slot" .. string.sub(tostring(key) , string.len("slot1"), string.len(tostring(key))) .. "_" .. visualnovel.current_campaign .. ".sav") then
							local slotNum = string.sub(tostring(key), string.len("slot1"), string.len(tostring(key)))
							local slotPath = "save/visualnovel/slot" .. slotNum .. "_" .. visualnovel.current_campaign .. ".sav"
							value_text = "N/A"
							local slotData = jsonDecode(slotPath)
							if type(slotData) == "table" and slotData.private and type(slotData.private) == "table" then
								local progress = slotData.private.progress
								if progress and visualnovel.data.global.maxprogress then
									local percent = (progress / visualnovel.data.global.maxprogress) * 100
									value_text = string.format("%.2f%%", percent)
								end
							end
						elseif not main.f_fileExists("save/visualnovel/slot" .. string.sub(tostring(key) , string.len("slot1"), string.len(tostring(key))) .. "_" .. visualnovel.current_campaign .. ".sav") then
							value_text = "Empty"
						end
					end
					if pause_index == item_count and value_text then
						textImgSetText(tsItemValueActive, value_text)
						textImgSetPos(tsItemValueActive, motif.visualnovel_pause_menu.menu.item.valueactive.offset[1] + (motif.visualnovel_pause_menu.menu.item.all.spacing[1] * (item_count-1)), motif.visualnovel_pause_menu.menu.item.valueactive.offset[2] + (motif.visualnovel_pause_menu.menu.item.all.spacing[2] * (item_count-1)))
						textImgDraw(tsItemValueActive)
					elseif value_text then
						textImgSetText(tsItemValue, value_text)
						textImgSetPos(tsItemValue, motif.visualnovel_pause_menu.menu.item.value.offset[1] + (motif.visualnovel_pause_menu.menu.item.all.spacing[1] * (item_count-1)), motif.visualnovel_pause_menu.menu.item.value.offset[2] + (motif.visualnovel_pause_menu.menu.item.all.spacing[2] * (item_count-1)))
						textImgDraw(tsItemValue)
					end
				end
			end

			-- input detection. doesn't need to have a 1 frame delay cause we're entering the pause menu though esc.
			-- we'll use the default main menu keys for actions instead of the visual novel mode's. but we'll keep the previous and next keys faithful to the visual novel mode's.

			local pause_keys = {}

			for k in pairs(pause_state) do
				table.insert(pause_keys, tostring(k))
			end

			-- table.sort(pause_keys)

			local function isSpacer(index)
				local key = pause_keys[index]
				return string.sub(key, 1, string.len("spacer")) == "spacer"
			end

			if getInput(-1, motif.visualnovel_info.key.next) then
				repeat
					pause_index = math.max(1, (pause_index + 1) % (item_count+1))
				until not isSpacer(pause_index)
				sndPlay(motif.Snd, motif[main.group].cursor.move.snd[1], motif[main.group].cursor.move.snd[2])
 
			elseif getInput(-1, motif.visualnovel_info.key.previous) then
				repeat
					if pause_index == 1 then
						pause_index = item_count
					else
						pause_index = (pause_index - 1)
					end
				until not isSpacer(pause_index)
				sndPlay(motif.Snd, motif[main.group].cursor.move.snd[1], motif[main.group].cursor.move.snd[2])
			elseif getInput(-1, motif[main.group].menu.done.key) then
				local key = pause_keys[pause_index]
				local actions = {
					["continue"] = function()
						playBgm({volume = gameOption('Sound.MasterVolume'), interrupt = false})
						sndPlay(motif.Snd, motif.visualnovel_info.cancel.snd[1], motif.visualnovel_info.cancel.snd[2])
						modifyStoryboard("scenedef.key.skip", motif.visualnovel_info.key.action)
						local realend = 0
						paused = false
					end,
					["backlog"]  = function()
						sndPlay(motif.Snd, motif[main.group].cursor.done.snd.default[1], motif[main.group].cursor.done.snd.default[2])
						bgReset(motif.backlogbgdef.BGDef)
						pause_title = motif.backlog_info.title.text
						backlog = true
						backlog_index = 1
						backlog_viewing = false
					end,
					["menutext"] = function()
						sndPlay(motif.Snd, motif[main.group].cursor.done.snd.default[1], motif[main.group].cursor.done.snd.default[2])
						pause_title = motif.visualnovel_pause_menu.menutext.title
						pause_index = 1
						prev_state = pause_state
						pause_state = motif.visualnovel_pause_menu.menutext.itemname
						if visualnovel.data.global.textspeed == 1.0 then
							new_textspeed = "1x"
							new_textspeedvalue = 1.0
						elseif visualnovel.data.global.textspeed == 0.5 then
							new_textspeed = "2x"
							new_textspeedvalue = 0.5
						elseif visualnovel.data.global.textspeed == 0.25 then
							new_textspeed = "4x"
							new_textspeedvalue = 0.25
						elseif visualnovel.data.global.textspeed == 0 then
							new_textspeed = "Instant"
							new_textspeedvalue = 0
						end
					end,
					["textspeed"] = function()
						sndPlay(motif.Snd, motif[main.group].cursor.done.snd.default[1], motif[main.group].cursor.done.snd.default[2])
						if new_textspeedvalue == 1.0 then
							new_textspeed = "2x"
							new_textspeedvalue = 0.5
						elseif new_textspeedvalue == 0.5 then
							new_textspeed = "4x"
							new_textspeedvalue = 0.25
						elseif new_textspeedvalue == 0.25 then
							new_textspeed = "Instant"
							new_textspeedvalue = 0
						elseif new_textspeedvalue == 0 then
							new_textspeed = "1x"
							new_textspeedvalue = 1.0
						end
					end,
					["savetext"] = function()
						sndPlay(motif.Snd, motif[main.group].cursor.done.snd.default[1], motif[main.group].cursor.done.snd.default[2])
						visualnovel.data.global.textspeed = new_textspeedvalue
						visualnovel.saveGlobalData()
						pause_title = motif.visualnovel_pause_menu.title.text
						pause_state = prev_state
						pause_index = 1
						for i, layer in ipairs(sceneData.layers) do
							if layer.text and layer.textdelay then
								modifyStoryboard("scene_" .. current .. ".layer" .. (layer.index - 1) .. ".textdelay", layer.textdelay * visualnovel.data.global.textspeed)
								local _text = functions.expandStoryboardVariables(layer.text)
								if sceneData.cutscene == 1 and realend < (layer.textdelay * visualnovel.data.global.textspeed) * string.len(_text) then
									modifyStoryboard("scene_" .. current .. ".end.time", (layer.textdelay * visualnovel.data.global.textspeed) * string.len(_text))
									realend = (layer.textdelay * visualnovel.data.global.textspeed) * string.len(_text)
								end
							end
						end
					end,
					["defaulttext"] = function()
						sndPlay(motif.Snd, motif[main.group].cursor.done.snd.default[1], motif[main.group].cursor.done.snd.default[2])
						new_textspeed = "1x"
						new_textspeedvalue = 1.0
					end,
					["menuaudio"] = function()
						sndPlay(motif.Snd, motif[main.group].cursor.done.snd.default[1], motif[main.group].cursor.done.snd.default[2])
						pause_title = motif.visualnovel_pause_menu.menuaudio.title
						pause_index = 1
						prev_state = pause_state
						pause_state = motif.visualnovel_pause_menu.menuaudio.itemname
					end,
					["save"] = function()
						-- save logic
						sndPlay(motif.Snd, motif[main.group].cursor.done.snd.default[1], motif[main.group].cursor.done.snd.default[2])
						save = true
						load = false
						pause_title = motif.saveload_info.save.text
						pause_index = 1
						prev_state = pause_state
						pause_state = motif.visualnovel_pause_menu.menusaveload.itemname
					end,
					["load"] = function()
						-- load logic
						sndPlay(motif.Snd, motif[main.group].cursor.done.snd.default[1], motif[main.group].cursor.done.snd.default[2])
						save= false
						load = true
						pause_title = motif.saveload_info.load.text
						pause_index = 1
						prev_state = pause_state
						pause_state = motif.visualnovel_pause_menu.menusaveload.itemname
					end,
					["slot1"] = function()
						-- slot 1
						sndPlay(motif.Snd, motif[main.group].cursor.done.snd.default[1], motif[main.group].cursor.done.snd.default[2])
						if save == true then
							visualnovel.saveSlot(1, path, luaPath, choices)
						elseif load == true then
							visualnovel.loadSlot(1)
						end
					end,
					["slot2"] = function()
						-- slot 2
						sndPlay(motif.Snd, motif[main.group].cursor.done.snd.default[1], motif[main.group].cursor.done.snd.default[2])
						if save == true then
							visualnovel.saveSlot(2, path, luaPath, choices)
						elseif load == true then
							visualnovel.loadSlot(2)
						end
					end,
					["slot3"] = function()
						-- slot 3
						sndPlay(motif.Snd, motif[main.group].cursor.done.snd.default[1], motif[main.group].cursor.done.snd.default[2])
						if save == true then
							visualnovel.saveSlot(3, path, luaPath, choices)
						elseif load == true then
							visualnovel.loadSlot(3)
						end
					end,
					["slot4"] = function()
						-- slot 4
						sndPlay(motif.Snd, motif[main.group].cursor.done.snd.default[1], motif[main.group].cursor.done.snd.default[2])
						if save == true then
							visualnovel.saveSlot(4, path, luaPath, choices)
						elseif load == true then
							visualnovel.loadSlot(4)
						end
					end,
					["slot5"] = function()
						-- slot 5
						sndPlay(motif.Snd, motif[main.group].cursor.done.snd.default[1], motif[main.group].cursor.done.snd.default[2])
						if save == true then
							visualnovel.saveSlot(5, path, luaPath, choices)
						elseif load == true then
							visualnovel.loadSlot(5)
						end
					end,
					["slot6"] = function()
						-- slot 6
						sndPlay(motif.Snd, motif[main.group].cursor.done.snd.default[1], motif[main.group].cursor.done.snd.default[2])
						if save == true then
							visualnovel.saveSlot(6, path, luaPath, choices)
						elseif load == true then
							visualnovel.loadSlot(6)
						end
					end,
					["slot7"] = function()
						-- slot 7
						sndPlay(motif.Snd, motif[main.group].cursor.done.snd.default[1], motif[main.group].cursor.done.snd.default[2])
						if save == true then
							visualnovel.saveSlot(7, path, luaPath, choices)
						elseif load == true then
							visualnovel.loadSlot(7)
						end
					end,
					["slot8"] = function()
						-- slot 8
						sndPlay(motif.Snd, motif[main.group].cursor.done.snd.default[1], motif[main.group].cursor.done.snd.default[2])
						if save == true then
							visualnovel.saveSlot(8, path, luaPath, choices)
						elseif load == true then
							visualnovel.loadSlot(8)
						end
					end,
					["slot9"] = function()
						-- slot 9
						sndPlay(motif.Snd, motif[main.group].cursor.done.snd.default[1], motif[main.group].cursor.done.snd.default[2])
						if save == true then
							visualnovel.saveSlot(9, path, luaPath, choices)
						elseif load == true then
							visualnovel.loadSlot(9)
						end
					end,
					["slot10"] = function()
						-- slot 10
						sndPlay(motif.Snd, motif[main.group].cursor.done.snd.default[1], motif[main.group].cursor.done.snd.default[2])
						if save == true then
							visualnovel.saveSlot(10, path, luaPath, choices)
						elseif load == true then
							visualnovel.loadSlot(10)
						end
					end,
					["slot11"] = function()
						-- slot 11
						sndPlay(motif.Snd, motif[main.group].cursor.done.snd.default[1], motif[main.group].cursor.done.snd.default[2])
						if save == true then
							visualnovel.saveSlot(11, path, luaPath, choices)
						elseif load == true then
							visualnovel.loadSlot(11)
						end
					end,
					["exit"] = function()
						sndPlay(motif.Snd, motif.visualnovel_info.cancel.snd[1], motif.visualnovel_info.cancel.snd[2])
						visualnovel.data.private = {}
						visualnovel.data.progress = 0
						visualnovel.data.backlog = {}
						modifyStoryboard("scene_" .. current .. ".jump", #vn.scenes+1)
						modifyStoryboard("scene_" .. current .. ".end.time", 0)
						choices[1] = true -- exited
					end,
					["return"] = function()
						sndPlay(motif.Snd, motif.visualnovel_info.cancel.snd[1], motif.visualnovel_info.cancel.snd[2])
						pause_title = motif.visualnovel_pause_menu.title.text
						pause_state = prev_state
						pause_index = 1
					end,
				}

				local fn = actions[key]
				if fn then fn() end
			end
		end

		-- Backlog
		if backlog == true and paused == true then
			-- Background
			bgDraw(motif.backlogbgdef.BGDef, 0)
			-- Overlay
			rectDraw(rectOverlayBacklog)
			-- Title
			textImgSetText(tsTitleBacklog, pause_title)
			textImgSetPos(tsTitleBacklog, motif.backlog_info.title.offset[1], motif.backlog_info.title.offset[2])
			textImgDraw(tsTitleBacklog)
			-- Text
			local _backlog = visualnovel.data.private.backlog
			local count = backlog_index+19
			local speakers = 0
			for i = 1, count, 1 do
				local entry = _backlog[i]
				if not entry then break end
				if entry.speaker and entry.speaker ~= "" then
					local nextEntry = _backlog[i + 1]
					if i == #_backlog or (nextEntry and nextEntry.speaker ~= entry.speaker) then
						speakers = speakers + 1
					end
				end
			end
			local idx = (count + speakers)

			-- Cursor

			_cursorPulse.t = _cursorPulse.t + _cursorPulse.speed

			local a = (math.sin(_cursorPulse.t) + 1) / 2
			local alpha = _cursorPulse.min + a * (_cursorPulse.max - _cursorPulse.min)

			rectSetWindow(boxCursor2,motif.backlog_info.backlog.boxcursor.window[1],motif.backlog_info.backlog.boxcursor.window[2],motif.backlog_info.backlog.boxcursor.window[3],motif.backlog_info.backlog.boxcursor.window[4])
			rectSetAlpha(boxCursor2,motif.backlog_info.backlog.boxcursor.alpha[1]*(alpha/255),motif.backlog_info.backlog.boxcursor.alpha[2])
			rectDraw(boxCursor2)

			-- iterate from oldest to newest so that bottom-to-top spacing works naturally
			for i = 1, count, 1 do
				if idx < 1 then break end
				local entry = _backlog[i]
				if not entry then break end

				local text = entry.text or ""
				local prefix = ""
				local speak_prefix = ""

				-- Determine if we should print the speaker line
				-- Speaker is printed if:
				-- 1) i == count (top of backlog, oldest entry)
				-- 2) speaker changed from next entry
				if entry.speaker and entry.speaker ~= "" then
					local nextEntry = _backlog[i + 1]
					if i == #_backlog or (nextEntry and nextEntry.speaker ~= entry.speaker) then
						speak_prefix = entry.speaker
					end
					-- indent dialogue lines
					prefix = "	" .. prefix
				end

				local _x = motif.backlog_info.backlog.text.offset[1] - (motif.backlog_info.backlog.text.spacing[1] * speakers)
				local _y = motif.backlog_info.backlog.text.offset[2] - (motif.backlog_info.backlog.text.spacing[2] * speakers)

				-- Draw dialogue line
				if idx < 1 then break end

				textImgSetText(tsBacklog, prefix .. text)
				textImgSetPos(
					tsBacklog,
					_x + motif.backlog_info.backlog.text.spacing[1] * idx,
					_y + motif.backlog_info.backlog.text.spacing[2] * idx
				)
				textImgDraw(tsBacklog)
				idx = idx - 1

				-- Draw speaker line first (if any)
				if speak_prefix ~= "" then
					if idx < 1 then break end
					textImgSetText(tsBacklog, speak_prefix)
					textImgSetPos(
						tsBacklog,
						_x + motif.backlog_info.backlog.text.spacing[1] * idx,
						_y + motif.backlog_info.backlog.text.spacing[2] * idx
					)
					textImgDraw(tsBacklog)
					idx = idx - 1
				end
			end

			-- input detection.

			if getInput(-1, motif.visualnovel_info.key.down) then
				if backlog_index == 1 then
					backlog_index = 1
				else
					backlog_index = (backlog_index - 1)
					sndPlay(motif.Snd, motif.visualnovel_info.move.snd[1], motif.visualnovel_info.move.snd[2])
				end
			elseif getInput(-1, motif.visualnovel_info.key.up) then
				if backlog_index == (#_backlog + speakers) then
					backlog_index = (#_backlog + speakers)
				else
					backlog_index = (backlog_index + 1)
					sndPlay(motif.Snd, motif.visualnovel_info.move.snd[1], motif.visualnovel_info.move.snd[2])
				end
			elseif (getInput(-1, motif.visualnovel_info.key.action) or esc()) and backlog_viewing == true then
				sndPlay(motif.Snd, motif.visualnovel_info.cancel.snd[1], motif.visualnovel_info.cancel.snd[2])
				bgReset(motif.visualnovelbgdef.BGDef)
				pause_title = motif.visualnovel_pause_menu.title.text
				esc(false)
				backlog = false
			end
			backlog_viewing = true

		end

		-- Input
		if sceneData and sceneData.input == 1 and not paused then
			modifyStoryboard("scenedef.key.skip", "")
			if getKey('RETURN') and #text >= sceneData.inputminchars then
				-- advance
				visualnovel.data.private[sceneData.inputdest] = text
				local _input = {
					text = text,
					speaker = functions.expandStoryboardVariables(motif.visualnovel_info.player.name)
				}
				table.insert(visualnovel.data.private.backlog, 1, _input)
				modifyStoryboard("scene_" .. current .. ".end.time", timer+sceneData.fadeout)
			elseif getKey('BACKSPACE') then
				text = text:match('^(.-).?$')
			elseif #text < sceneData.inputmaxchars then
				if getKeyText() == " " and sceneData.inputspaces == 1 then
					text = text .. getKeyText()
				elseif getKeyText():match("^%d$") and sceneData.inputnumbers == 1 then
					text = text .. getKeyText()
				elseif getKeyText():match("^%a$") and sceneData.inputletters == 1 then
					text = text .. getKeyText()
				elseif getKeyText():match("^%a$") and sceneData.inputletters == 1 then
					text = text .. getKeyText()
				elseif getKeyText() ~= "" and sceneData.inputspecial == 1 then
					text = text .. getKeyText()
				end
			end
			resetKey()
		
			if timer % (motif.visualnovel_info.input.text.cursorblink + 1) == 0 then
				cursorvisible = not cursorvisible
				if cursorvisible then
					cursor = motif.visualnovel_info.input.text.cursor
				elseif not cursorvisible then
					cursor = ""
				end
			end
			local cursorx = textImgGetTextWidth(tsInput, text or "")
			-- rendering
			animSetPos(aInputBg, motif.visualnovel_info.input.bg.offset[1], motif.visualnovel_info.input.bg.offset[2])
			animUpdate(aInputBg)
			animDraw(aInputBg)
			textImgSetText(tsInput, text or "")
			textImgSetPos(tsInput, motif.visualnovel_info.input.text.offset[1], motif.visualnovel_info.input.text.offset[2])
			textImgDraw(tsInput)

			textImgSetText(tsInputCursor, cursor)
			textImgSetPos(tsInputCursor, motif.visualnovel_info.input.text.offset[1] + (cursorx*0.55), motif.visualnovel_info.input.text.offset[2])
			textImgDraw(tsInputCursor)
		elseif sceneData and sceneData.input == nil and not paused then
			modifyStoryboard("scenedef.key.skip", motif.visualnovel_info.key.action)
		end

		-- Choices
		if sceneData and #sceneData.choices > 0 and not paused then
			modifyStoryboard("scenedef.key.skip", "")
			-- input detection. has to be behind the choosing = true statement or else the choice scene will be skipped automatically.
			if getInput(-1, motif.visualnovel_info.key.next) and choosing == true then
				choiceIndex = math.max(1, (choiceIndex + 1) % (#sceneData.choices+1))
				sndPlay(motif.Snd, motif.visualnovel_info.move.snd[1], motif.visualnovel_info.move.snd[2])
			elseif getInput(-1,motif.visualnovel_info.key.previous) and choosing == true then
				if choiceIndex == 1 then
					choiceIndex = #sceneData.choices
				else
					choiceIndex = (choiceIndex - 1)
				end
				sndPlay(motif.Snd, motif.visualnovel_info.move.snd[1], motif.visualnovel_info.move.snd[2])
			elseif getInput(-1, motif.visualnovel_info.key.action) and choosing == true then
				select = true
			end

			if choosing == false then
				choosing = true
				select = false
			end

			if select == true then
				-- has selected something

				for i, choice in ipairs(sceneData.choices) do
					if choiceIndex == choice.index and functions.f_unlockChoice(choice.unlock) then
						table.insert(choices, choice.value)
						visualnovel.data.private[choice.dest] = choice.value
						local _choice = {
							text = choice.text,
							speaker = functions.expandStoryboardVariables(motif.visualnovel_info.player.name)
						}
						table.insert(visualnovel.data.private.backlog, 1, _choice)
						visualnovel.choices = choices
						j = choice.jump
						break
					elseif choiceIndex == choice.index and not functions.f_unlockChoice(choice.unlock) then
						select = false
						break
					end
				end
				if select == true then
					sndPlay(motif.Snd, motif.visualnovel_info.done.snd[1], motif.visualnovel_info.done.snd[2])
					if j ~= nil then
						modifyStoryboard("scene_" .. current .. ".jump", j)
					end
					resetKey()
					modifyStoryboard("scenedef.key.skip", motif.visualnovel_info.key.action)
					modifyStoryboard("scene_" .. current .. ".end.time", timer+sceneData.fadeout)
					choosing = false
					select = false
					choiceIndex = 1
				elseif select == false then
					sndPlay(motif.Snd, motif.visualnovel_info.locked.snd[1], motif.visualnovel_info.locked.snd[2])
				end
			end
			-- rendering
			for i, choice in ipairs(sceneData.choices) do
				if i ~= choiceIndex then
					animSetPos(aChoiceBg, motif.visualnovel_info.choice.inactive.bg.offset[1], motif.visualnovel_info.choice.inactive.bg.offset[2] + (motif.visualnovel_info.choice.spacing * i-1))
					animUpdate(aChoiceBg)
					animDraw(aChoiceBg)
					textImgSetText(tsChoice, functions.cond(functions.f_unlockChoice(choice.unlock) or motif.visualnovel_info.choice.lockedtext == nil, choice.text, motif.visualnovel_info.choice.lockedtext))
					textImgSetPos(tsChoice, motif.visualnovel_info.choice.inactive.text.offset[1], motif.visualnovel_info.choice.inactive.text.offset[2] + (motif.visualnovel_info.choice.spacing * i-1))
					textImgDraw(tsChoice)
				else
					animSetPos(aChoiceBgActive, motif.visualnovel_info.choice.active.bg.offset[1], motif.visualnovel_info.choice.active.bg.offset[2] + (motif.visualnovel_info.choice.spacing * i-1))
					animUpdate(aChoiceBgActive)
					animDraw(aChoiceBgActive)
					textImgSetText(tsChoiceActive, functions.cond(functions.f_unlockChoice(choice.unlock) or motif.visualnovel_info.choice.lockedtext == nil, choice.text, motif.visualnovel_info.choice.lockedtext))
					textImgSetPos(tsChoiceActive, motif.visualnovel_info.choice.active.text.offset[1], motif.visualnovel_info.choice.active.text.offset[2] + (motif.visualnovel_info.choice.spacing * i-1))
					textImgDraw(tsChoiceActive)
				end
			end
		end
		refresh()
		if not paused then
			hook.run("visualnovel.loop") -- for hooking, mostly to be used for displaying UI for storyboards, maps and stuff
		end
	end
	return unpack(choices)
end

function visualnovel.launchFight(data)
	if visualnovel.resume then
		return
		-- skip this fight if we're loading a save.
	end

	local ok = launchFight(data)
	return ok
end

function visualnovel.loadCampaign()
	local path = "save/visualnovel/campaign.sav"
	local file = io.open(path, "r")
	if not file then return false end
	local result = jsonDecode(path)
	if type(result) ~= "string" or result == "" then
		return false
	end
	visualnovel.current_campaign = result
	return true
end

function visualnovel.saveCampaign()
	local path = "save/visualnovel/campaign.sav"

	jsonEncode(tostring(visualnovel.current_campaign), path)
	return true
end

function visualnovel.registerCampaign(luaPath, campaignName, campaignIndex, unlock, default)
	assert(type(luaPath) == "string", "registerCampaign: luaPath must be a string")
	assert(type(campaignName) == "string", "registerCampaign: campaignName must be a string")
	assert(type(campaignIndex) == "string", "registerCampaign: campaignIndex must be a string")

	assert(type(unlock) == "string", "registerCampaign: unlock must be a string")
	assert(type(default) == "boolean", "registerCampaign: default must be a boolean")

	-- Automate creation of menu functions for campaigns
	main.t_itemname[campaignIndex] = function()
		local doneSnd = motif[main.group].cursor.done.snd.serverhost or motif[main.group].cursor.done.snd.default
		sndPlay(motif.Snd, doneSnd[1], doneSnd[2])
		visualnovel.current_campaign = campaignIndex
		visualnovel.saveCampaign()
		hook.run("main.t_itemname")
		return nil
	end

	main.t_unlockLua.modes[campaignIndex] = unlock

	visualnovel.campaigns[campaignIndex] = {
		lua_path = luaPath,
		name = campaignName,
		unlock = unlock,
		default = default
	}
end

require("external.mods.visual_novel.visual_novel_campaigns")

if not main.f_fileExists('save/visualnovel/campaign.sav') then
	for campaignIndex, campaign in pairs(visualnovel.campaigns) do
		if campaign.default == true then
			visualnovel.current_campaign = campaignIndex
			visualnovel.saveCampaign()
			break
		end
	end
elseif main.f_fileExists('save/visualnovel/campaign.sav') then
	visualnovel.loadCampaign()
end

main.t_itemname.vncontinue = function()
	local doneSnd = motif[main.group].cursor.done.snd.serverhost or motif[main.group].cursor.done.snd.default
	sndPlay(motif.Snd, doneSnd[1], doneSnd[2])
	main.motif.continuescreen = true
	main.selectMenu[1] = false
	local path = "save/visualnovel/continue_" .. visualnovel.current_campaign .. ".sav"
	local saveData = jsonDecode(path)
	visualnovel.data.private = saveData.private or {}
	visualnovel.resume = {
		scene = saveData.scene,
		storyboard = saveData.storyboard,
		choices = saveData.choices or {},
		luaPath = saveData.luaPath
	}
	main.luaPath = saveData.luaPath
	remapInput(1, getLastInputController())
	remapInput(getLastInputController(), 1)
	setGameMode(visualnovel.current_campaign)
	hook.run("main.t_itemname")
	return start.f_selectMode
end
main.t_unlockLua.modes.vncontinue = 'main.f_fileExists("save/visualnovel/continue_" .. visualnovel.current_campaign .. ".sav")'

main.t_itemname.vnnewgame = function()
	local doneSnd = motif[main.group].cursor.done.snd.serverhost or motif[main.group].cursor.done.snd.default
	sndPlay(motif.Snd, doneSnd[1], doneSnd[2])
	main.motif.continuescreen = true
	main.selectMenu[1] = false
	main.luaPath = visualnovel.campaigns[visualnovel.current_campaign].lua_path
	visualnovel.data.private = {}
	visualnovel.data.private.progress = 0
	visualnovel.data.private.backlog = {}
	visualnovel.resume = nil
	remapInput(1, getLastInputController())
	remapInput(getLastInputController(), 1)
	setGameMode(visualnovel.current_campaign)
	hook.run("main.t_itemname")
	return start.f_selectMode
end

main.t_itemname.slot1 = function()
	local doneSnd = motif[main.group].cursor.done.snd.serverhost or motif[main.group].cursor.done.snd.default
	sndPlay(motif.Snd, doneSnd[1], doneSnd[2])
	main.motif.continuescreen = true
	main.selectMenu[1] = false
	local path = "save/visualnovel/slot1_" .. visualnovel.current_campaign .. ".sav"
	local saveData = jsonDecode(path)
	visualnovel.data.private = saveData.private or {}
	visualnovel.resume = {
		scene = saveData.scene,
		storyboard = saveData.storyboard,
		choices = saveData.choices or {},
		luaPath = saveData.luaPath
	}
	main.luaPath = saveData.luaPath
	remapInput(1, getLastInputController())
	remapInput(getLastInputController(), 1)
	setGameMode(visualnovel.current_campaign)
	hook.run("main.t_itemname")
	return start.f_selectMode
end
main.t_unlockLua.modes.slot1 = 'main.f_fileExists("save/visualnovel/slot1_" .. visualnovel.current_campaign .. ".sav")'

main.t_itemname.slot2 = function()
	local doneSnd = motif[main.group].cursor.done.snd.serverhost or motif[main.group].cursor.done.snd.default
	sndPlay(motif.Snd, doneSnd[1], doneSnd[2])
	main.motif.continuescreen = true
	main.selectMenu[1] = false
	local path = "save/visualnovel/slot2_" .. visualnovel.current_campaign .. ".sav"
	local saveData = jsonDecode(path)
	visualnovel.data.private = saveData.private or {}
	visualnovel.resume = {
		scene = saveData.scene,
		storyboard = saveData.storyboard,
		choices = saveData.choices or {},
		luaPath = saveData.luaPath
	}
	main.luaPath = saveData.luaPath
	remapInput(1, getLastInputController())
	remapInput(getLastInputController(), 1)
	setGameMode(visualnovel.current_campaign)
	hook.run("main.t_itemname")
	return start.f_selectMode
end
main.t_unlockLua.modes.slot2 = 'main.f_fileExists("save/visualnovel/slot2_" .. visualnovel.current_campaign .. ".sav")'

main.t_itemname.slot3 = function()
	local doneSnd = motif[main.group].cursor.done.snd.serverhost or motif[main.group].cursor.done.snd.default
	sndPlay(motif.Snd, doneSnd[1], doneSnd[2])
	main.motif.continuescreen = true
	main.selectMenu[1] = false
	local path = "save/visualnovel/slot3_" .. visualnovel.current_campaign .. ".sav"
	local saveData = jsonDecode(path)
	visualnovel.data.private = saveData.private or {}
	visualnovel.resume = {
		scene = saveData.scene,
		storyboard = saveData.storyboard,
		choices = saveData.choices or {},
		luaPath = saveData.luaPath
	}
	main.luaPath = saveData.luaPath
	remapInput(1, getLastInputController())
	remapInput(getLastInputController(), 1)
	setGameMode(visualnovel.current_campaign)
	hook.run("main.t_itemname")
	return start.f_selectMode
end
main.t_unlockLua.modes.slot3 = 'main.f_fileExists("save/visualnovel/slot3_" .. visualnovel.current_campaign .. ".sav")'

main.t_itemname.slot4 = function()
	local doneSnd = motif[main.group].cursor.done.snd.serverhost or motif[main.group].cursor.done.snd.default
	sndPlay(motif.Snd, doneSnd[1], doneSnd[2])
	main.motif.continuescreen = true
	main.selectMenu[1] = false
	local path = "save/visualnovel/slot4_" .. visualnovel.current_campaign .. ".sav"
	local saveData = jsonDecode(path)
	visualnovel.data.private = saveData.private or {}
	visualnovel.resume = {
		scene = saveData.scene,
		storyboard = saveData.storyboard,
		choices = saveData.choices or {},
		luaPath = saveData.luaPath
	}
	main.luaPath = saveData.luaPath
	remapInput(1, getLastInputController())
	remapInput(getLastInputController(), 1)
	setGameMode(visualnovel.current_campaign)
	hook.run("main.t_itemname")
	return start.f_selectMode
end
main.t_unlockLua.modes.slot4 = 'main.f_fileExists("save/visualnovel/slot4_" .. visualnovel.current_campaign .. ".sav")'

main.t_itemname.slot5 = function()
	local doneSnd = motif[main.group].cursor.done.snd.serverhost or motif[main.group].cursor.done.snd.default
	sndPlay(motif.Snd, doneSnd[1], doneSnd[2])
	main.motif.continuescreen = true
	main.selectMenu[1] = false
	local path = "save/visualnovel/slot5_" .. visualnovel.current_campaign .. ".sav"
	local saveData = jsonDecode(path)
	visualnovel.data.private = saveData.private or {}
	visualnovel.resume = {
		scene = saveData.scene,
		storyboard = saveData.storyboard,
		choices = saveData.choices or {},
		luaPath = saveData.luaPath
	}
	main.luaPath = saveData.luaPath
	remapInput(1, getLastInputController())
	remapInput(getLastInputController(), 1)
	setGameMode(visualnovel.current_campaign)
	hook.run("main.t_itemname")
	return start.f_selectMode
end
main.t_unlockLua.modes.slot5 = 'main.f_fileExists("save/visualnovel/slot5_" .. visualnovel.current_campaign .. ".sav")'

main.t_itemname.slot6 = function()
	local doneSnd = motif[main.group].cursor.done.snd.serverhost or motif[main.group].cursor.done.snd.default
	sndPlay(motif.Snd, doneSnd[1], doneSnd[2])
	main.motif.continuescreen = true
	main.selectMenu[1] = false
	local path = "save/visualnovel/slot6_" .. visualnovel.current_campaign .. ".sav"
	local saveData = jsonDecode(path)
	visualnovel.data.private = saveData.private or {}
	visualnovel.resume = {
		scene = saveData.scene,
		storyboard = saveData.storyboard,
		choices = saveData.choices or {},
		luaPath = saveData.luaPath
	}
	main.luaPath = saveData.luaPath
	remapInput(1, getLastInputController())
	remapInput(getLastInputController(), 1)
	setGameMode(visualnovel.current_campaign)
	hook.run("main.t_itemname")
	return start.f_selectMode
end
main.t_unlockLua.modes.slot6 = 'main.f_fileExists("save/visualnovel/slot6_" .. visualnovel.current_campaign .. ".sav")'

main.t_itemname.slot7 = function()
	local doneSnd = motif[main.group].cursor.done.snd.serverhost or motif[main.group].cursor.done.snd.default
	sndPlay(motif.Snd, doneSnd[1], doneSnd[2])
	main.motif.continuescreen = true
	main.selectMenu[1] = false
	local path = "save/visualnovel/slot7_" .. visualnovel.current_campaign .. ".sav"
	local saveData = jsonDecode(path)
	visualnovel.data.private = saveData.private or {}
	visualnovel.resume = {
		scene = saveData.scene,
		storyboard = saveData.storyboard,
		choices = saveData.choices or {},
		luaPath = saveData.luaPath
	}
	main.luaPath = saveData.luaPath
	remapInput(1, getLastInputController())
	remapInput(getLastInputController(), 1)
	setGameMode(visualnovel.current_campaign)
	hook.run("main.t_itemname")
	return start.f_selectMode
end
main.t_unlockLua.modes.slot7 = 'main.f_fileExists("save/visualnovel/slot7_" .. visualnovel.current_campaign .. ".sav")'

main.t_itemname.slot8 = function()
	local doneSnd = motif[main.group].cursor.done.snd.serverhost or motif[main.group].cursor.done.snd.default
	sndPlay(motif.Snd, doneSnd[1], doneSnd[2])
	main.motif.continuescreen = true
	main.selectMenu[1] = false
	local path = "save/visualnovel/slot8_" .. visualnovel.current_campaign .. ".sav"
	local saveData = jsonDecode(path)
	visualnovel.data.private = saveData.private or {}
	visualnovel.resume = {
		scene = saveData.scene,
		storyboard = saveData.storyboard,
		choices = saveData.choices or {},
		luaPath = saveData.luaPath
	}
	main.luaPath = saveData.luaPath
	remapInput(1, getLastInputController())
	remapInput(getLastInputController(), 1)
	setGameMode(visualnovel.current_campaign)
	hook.run("main.t_itemname")
	return start.f_selectMode
end
main.t_unlockLua.modes.slot8 = 'main.f_fileExists("save/visualnovel/slot8_" .. visualnovel.current_campaign .. ".sav")'

main.t_itemname.slot9 = function()
	local doneSnd = motif[main.group].cursor.done.snd.serverhost or motif[main.group].cursor.done.snd.default
	sndPlay(motif.Snd, doneSnd[1], doneSnd[2])
	main.motif.continuescreen = true
	main.selectMenu[1] = false
	local path = "save/visualnovel/slot9_" .. visualnovel.current_campaign .. ".sav"
	local saveData = jsonDecode(path)
	visualnovel.data.private = saveData.private or {}
	visualnovel.resume = {
		scene = saveData.scene,
		storyboard = saveData.storyboard,
		choices = saveData.choices or {},
		luaPath = saveData.luaPath
	}
	main.luaPath = saveData.luaPath
	remapInput(1, getLastInputController())
	remapInput(getLastInputController(), 1)
	setGameMode(visualnovel.current_campaign)
	hook.run("main.t_itemname")
	return start.f_selectMode
end
main.t_unlockLua.modes.slot9 = 'main.f_fileExists("save/visualnovel/slot9_" .. visualnovel.current_campaign .. ".sav")'

main.t_itemname.quicksave = function()
	local doneSnd = motif[main.group].cursor.done.snd.serverhost or motif[main.group].cursor.done.snd.default
	sndPlay(motif.Snd, doneSnd[1], doneSnd[2])
	main.motif.continuescreen = true
	main.selectMenu[1] = false
	local path = "save/visualnovel/slot10_" .. visualnovel.current_campaign .. ".sav"
	local saveData = jsonDecode(path)
	visualnovel.data.private = saveData.private or {}
	visualnovel.resume = {
		scene = saveData.scene,
		storyboard = saveData.storyboard,
		choices = saveData.choices or {},
		luaPath = saveData.luaPath
	}
	main.luaPath = saveData.luaPath
	remapInput(1, getLastInputController())
	remapInput(getLastInputController(), 1)
	setGameMode(visualnovel.current_campaign)
	hook.run("main.t_itemname")
	return start.f_selectMode
end
main.t_unlockLua.modes.quicksave = 'main.f_fileExists("save/visualnovel/slot10_" .. visualnovel.current_campaign .. ".sav")'

main.t_itemname.autosave = function()
	local doneSnd = motif[main.group].cursor.done.snd.serverhost or motif[main.group].cursor.done.snd.default
	sndPlay(motif.Snd, doneSnd[1], doneSnd[2])
	main.motif.continuescreen = true
	main.selectMenu[1] = false
	local path = "save/visualnovel/slot11_" .. visualnovel.current_campaign .. ".sav"
	local saveData = jsonDecode(path)
	visualnovel.data.private = saveData.private or {}
	visualnovel.resume = {
		scene = saveData.scene,
		storyboard = saveData.storyboard,
		choices = saveData.choices or {},
		luaPath = saveData.luaPath
	}
	main.luaPath = saveData.luaPath
	remapInput(1, getLastInputController())
	remapInput(getLastInputController(), 1)
	setGameMode(visualnovel.current_campaign)
	hook.run("main.t_itemname")
	return start.f_selectMode
end
main.t_unlockLua.modes.autosave = 'main.f_fileExists("save/visualnovel/slot11_" .. visualnovel.current_campaign .. ".sav")'

if main.f_fileExists("save/visualnovel/global.sav") then
	visualnovel.loadGlobalData() -- because we actually need the global data?
elseif not main.f_fileExists("save/visualnovel/global.sav") then
	visualnovel.saveGlobalData() -- create new global save file!
end