-- Visual Novel System Functions by dionednd
--
-- v1.0.0

-- thanks to jay_ts & m14 for some of the functions used here from their color edit module. it made making this module easier.

local t = {}

function t.expandStoryboardVariables(text)
	if type(text) ~= "string" then
		return text
	end

	local result = text:gsub("%$(.-)%$", function(expr)
		local value = visualnovel.data.private[expr]
		if value == nil then
			return "nil"
		end
		return tostring(value)
	end)

	return result
end

local function trim(s)
	return s:match("^%s*(.-)%s*$")
end

local function parseValue(v)
	v = trim(v)

	if v == "true" then return true end
	if v == "false" then return false end

	local n = tonumber(v)
	if n then return n end

	if v:match('^".*"$') then
		return v:sub(2, -2)
	end

	if v:find(",") then
		local t = {}
		for part in v:gmatch("[^,]+") do
			table.insert(t, parseValue(trim(part)))
		end
		return t
	end

	return v
end

function t.cond(condition,if_,else_)
	if condition then
		return if_
	else
		return else_
	end
end

function t.parseTextArgs(text)
	if type(text) ~= "string" then
		return text, {}
	end

	local text_args = {}
	local modified_text = text
	local letter_position = 1

	local i = 1
	while i <= #modified_text do
		local char = modified_text:sub(i, i)

		if char == "@" then
			local end_pos = modified_text:find("@", i + 1)
			if end_pos then
				local command = modified_text:sub(i + 1, end_pos - 1)
				local type, value = command:match("^(%a+)=%s*(.+)$")
				if type and value then
					value = parseValue(value)

					table.insert(text_args, {
						type = type,
						value = value,
						letter = t.cond(type ~= "sleep" and type ~= "textspeed", -1, letter_position)
					})
				end

				i = end_pos + 1
			else
				break
			end
		else
			letter_position = letter_position + 1
			i = i + 1
		end
	end

	modified_text = modified_text:gsub("@.-@", "")

	return modified_text, text_args
end

function t.clamp(lo, val, hi)
	if val < lo then return lo end
	if val > hi then return hi end
	return val
end

function t.backwards(_t)
	return function(t2, i)
		i=i-1
		if i~=0 then
			return i, t2[i]
		end
	end, _t, #_t+1
end

function t.normpath(path)
	local components = {}
	for comp in path:gmatch("([^/\\]+)") do
		table.insert(components, comp)
	end
	for k,v in t.backwards(components) do
		if v == "." then
			table.remove(components, k)
		end
	end
	for k,v in t.backwards(components) do
		if v == ".." then
			table.remove(components, k)
			table.remove(components, k-1)
		end
	end
	return table.concat(components, "/")
end

function t.loadMotifExtensions(default, path)
	local t_base = loadIni(default)

	for k,_ in pairs(t_base) do
		if motif[k] == nil then motif[k] = t_base[k] end
		motif[k] = main.f_tableMerge(t_base[k], motif[k])
	end

	local extension_path = t.normpath(path)

	local extension = loadIni(extension_path)

	for k,_ in pairs(extension) do
		local locale = extension[gameOption("Config.Language"):lower() .. "." .. k]
		if locale then
			extension[k] = main.f_tableMerge(extension[k], locale)
		end
	end

	for k, v in pairs(extension) do
		motif[k] = motif[k] or {}
		motif[k] = main.f_tableMerge(motif[k], v)
		local bgdef = k:lower():match("(.*)def")
		local ref = motif[k]
		if bgdef then
			if not ref["Sff"] then
				if type(ref["spr"]) == "string" and main.f_fileExists(ref["spr"]) then
					ref["Sff"] = sffNew(ref["spr"])
				else
					ref["Sff"] = motif.Sff
				end
			end
			if not ref["BGDef"] then
				ref["BGDef"] = bgNew(
					motif.Sff,
					extension_path,
					bgdef,
					nil
				)
			end
		end
	end

	return extension
end

function t.loadMotifAnim(section)
	local data = "-1,0, 0,0, -1"
	local anim

	if section.spr then
		local group, item = section.spr[1], section.spr[2]
		group = group or -1
		item = item or 0
		data = string.format("%s,%s, 0,0, -1", group, item)
	end
	if section.anim then
		local action = tonumber(section.anim)
		if action then
			if motif.AnimTable[action] then
				-- thanks k4thos for adding this for me :)
				action = motif.AnimTable[action]
				data = action or data
			end
		end
	end

	anim = animNew(motif.Sff, data)
	t.updateMotifAnim(anim, section)
	return anim
end

function t.updateMotifAnim(anim, section)
	local pair
	pair = section.scale or {1.0, 1.0}
	animSetScale(anim, pair[1], pair[2])
	animSetLocalcoord(anim, motif.info.localcoord[1], motif.info.localcoord[2])
	animSetFacing(anim, section.facing or 0)
	animSetAngle(anim, section.angle or 0)
	animSetXAngle(anim, section.xangle or 0)
	animSetYAngle(anim, section.yangle or 0)
	animSetLayerno(anim, section.layerno or 0)
	pair = section.window or {0, 0, motif.info.localcoord[1], motif.info.localcoord[2]}
	animSetWindow(anim, pair[1], pair[2], pair[3], pair[4])
	animSetFocalLength(anim, section.focallength or 2048)
	animSetProjection(anim, section.projection or "orthographic")
	return anim
end

function t.loadMotifFont(section)
	local text = textImgNew()
	t.updateMotifFont(text, section)
	return text
end

function t.updateMotifFont(text, section)
	local pair
	local font
	pair = section.font or {-1, 0, 0, 255, 255, 255, -1}
	font = pair[1] or -1
	font = motif.Fnt[tonumber(font)]
	if font then
		textImgSetFont(text, font)
	end
	textImgSetBank(text, pair[2] or 0)
	textImgSetAlign(text, pair[3] or 0)
	textImgSetColor(text,
		pair[4] or 255,
		pair[5] or 255,
		pair[6] or 255)
	local concat = section.text
	if type(concat) == "table" then
		concat = table.concat(concat, ", ")
	end
	textImgSetText(text, concat or "")
	textImgSetLocalcoord(text, motif.info.localcoord[1], motif.info.localcoord[2])
	pair = section.offset or {0, 0}
	textImgSetPos(text,
		pair[1] or 0,
		pair[2] or 0)
	pair = section.scale or {1, 1}
	textImgSetScale(text,
		pair[1] or 1,
		pair[2] or 1)
	textImgSetAngle(text, section.angle or 0)
	textImgSetXShear(text, section.xshear or 0)
	textImgSetProjection(text, section.projection or "orthographic")
	textImgSetFocalLength(text, section.focallength or 2048)
	pair = section.window or {0, 0, motif.info.localcoord[1], motif.info.localcoord[2]}
	textImgSetWindow(text,
		pair[1] or 0,
		pair[2] or 0,
		pair[3] or motif.info.localcoord[1],
		pair[4] or motif.info.localcoord[2])
	return text
end

function parseStoryboardDef(path)
	local file = io.open(path, "r")
	if not file then return nil end

	local vn = {
		localcoord = {1920,1080},
		path = path,
		startscene = 0,
		scenes = {}
	}

	local currentScene = nil

	for line in file:lines() do
		line = line:gsub(";.*$", "")
		line = trim(line)

		if line == "" then goto continue end

		local section = line:match("^%[(.+)%]$")
		if section then
			if section:lower() == "info" then
				currentScene = "info"
			end

			if section:lower() == "scenedef" then
				currentScene = "scenedef"
			else
				local sceneNum = section:match("^Scene%s+(%d+)$")
				if sceneNum then
					sceneNum = tonumber(sceneNum)
					vn.scenes[sceneNum] = vn.scenes[sceneNum] or {}
					vn.scenes[sceneNum].choices = {}
					vn.scenes[sceneNum].layers = {}
					currentScene = sceneNum
				end
			end
			goto continue
		end

		local key, value = line:match("^(.-)%s*=%s*(.+)$")
		if not key then goto continue end

		key = key:lower()

		if currentScene == "info" then
			if key == "localcoord" then
				vn.localcoord = parseValue(value)
			end
		end

		if currentScene == "scenedef" then
			if key == "startscene" then
				vn.startscene = tonumber(value) or 0
			end
		end

		if type(currentScene) == "number" then
			local scene = vn.scenes[currentScene]

			local fadeGroup, fadeProp = key:match("^(fadeout)%.(.+)$")
			if fadeGroup then
				if fadeProp == "time" then
					scene.fadeout = tonumber(value) or 0
				end
			end

			local endGroup, endProp = key:match("^(end)%.(.+)$")
			if endGroup then
				if endProp == "time" then
					scene.endtime = tonumber(value) or 0
				end
			end

			if key == "cutscene" then
				scene.cutscene = (tonumber(value) or 0)
			end

			if key == "bgm" then
				scene.bgmmusic = tostring(value) or nil
			end

			local bgmGroup, bgmProp = key:match("^(bgm)%.(.+)$")
			if bgmGroup then
				if bgmProp == "loop" then
					scene.bgmloop = tonumber(value) or 1
				end
				if bgmProp == "volume" then
					scene.bgmvolume = tonumber(value) or 100
				end
				if bgmProp == "loopstart" then
					scene.bgmloopstart = tonumber(value) or -1
				end
				if bgmProp == "loopend" then
					scene.bgmloopend = tonumber(value) or -1
				end
			end

			local layerallGroup, layerallProp = key:match("^(layerall)%.(.+)$")
			if layerallGroup then
				if layerallProp == "pos" then
					scene.layerallpos = parseValue(value) or {0,0}
				end
			end

			local idx, prop = key:match("^layer(%d+)%.(.+)$")
			if idx then
				idx = tonumber(idx) + 1

				scene.layers[idx] = scene.layers[idx] or {
					index = idx,
					text = nil,
					commands = {},
					textdelay = nil,
					speaker = "",
					scale = 1.0,
					starttime = 0,
					endtime = scene.endtime,
					textwindow = {0,0,motif.info.localcoord[1],motif.info.localcoord[2]},
					font = {-1, 0, 0, 255, 255, 255, -1},
					textspacing = {0,0},
					velocity = {0,0},
					offset = {0,0}
				}

				local layer = scene.layers[idx]

				if prop == "text" then
					layer.text, layer.commands = t.parseTextArgs(value) -- parseValue(value)
				elseif prop == "textdelay" then -- we only add text with textdelay to the backlog.
					layer.textdelay = tonumber(value)
				elseif prop == "speaker" then
					layer.speaker = parseValue(value)
				elseif prop == "scale" then
					layer.scale = tonumber(value)
				elseif prop == "starttime" then
					layer.starttime = tonumber(value)
				elseif prop == "endtime" then
					layer.endtime = tonumber(value)
				elseif prop == "textwindow" then
					layer.textwindow = parseValue(value)
				elseif prop == "font" then
					layer.font = parseValue(value)
				elseif prop == "textspacing" then
					layer.textspacing = parseValue(value)
				elseif prop == "velocity" then
					layer.velocity = parseValue(value)
				elseif prop == "offset" then
					layer.offset = parseValue(value)
				end

			end

			local idx, prop = key:match("^choice(%d+)%.(.+)$")
			if idx then
				idx = tonumber(idx) + 1

				scene.choices[idx] = scene.choices[idx] or {
					index = idx,
					text = "Choice " .. idx,
					value = true,
					jump = nil,
					dest = "choice",
					unlock = true
				}

				local choice = scene.choices[idx]

				if prop == "text" then
					choice.text = parseValue(value)
				elseif prop == "value" then
					choice.value = parseValue(value)
				elseif prop == "jump" then
					choice.jump = tonumber(parseValue(value))
				elseif prop == "dest" then
					choice.dest = tostring(value) or "choice"
				elseif prop == "unlock" then
					choice.unlock = parseValue(value)
				end

			end

			local inputGroup, inputProp = key:match("^(input)%.(.+)$")
			if inputGroup then
				scene.input = 1
				if inputProp == "numbers" then
					scene.inputnumbers = tonumber(value) or 1
				elseif inputProp == "spaces" then
					scene.inputspaces = tonumber(value) or 1
				elseif inputProp == "letters" then
					scene.inputletters = tonumber(value) or 1
				elseif inputProp == "special" then
					scene.inputspecial = tonumber(value) or 1
				elseif inputProp == "maxchars" then
					scene.inputmaxchars = tonumber(value) or 16
				elseif inputProp == "minchars" then
					scene.inputminchars = tonumber(value) or 1
				elseif inputProp == "dest" then
					scene.inputdest = tostring(value) or "input"
				end
			end
		end

		::continue::
	end

	file:close()

	for _, scene in pairs(vn.scenes) do
		local arr = {}
		for _, c in pairs(scene.choices) do
			table.insert(arr, c)
		end
		table.sort(arr, function(a, b) return a.index < b.index end)
		scene.choices = arr
	end

	return vn
end

function t.f_unlockChoice(unlock)
	local bool = assert(loadstring('return ' .. tostring(unlock)))()
	if type(bool) == 'boolean' then
		return bool
	else
		panicError("\nt.f_unlockChoice\nFollowing Lua code does not return boolean value: \n" .. unlock .. "\n")
	end
end

function t.rectNew(overlay)
	local rect = rectNew()
	rectSetLocalcoord(rect, motif.info.localcoord[1], motif.info.localcoord[2])
	rectSetWindow(rect,overlay.window[1], overlay.window[2], overlay.window[3] - overlay.window[1], overlay.window[4] - overlay.window[2])
	rectSetColor(rect, overlay.col[1],overlay.col[2],overlay.col[3])
	rectSetAlpha(rect, overlay.alpha[1], overlay.alpha[2])
	return rect
end

function t.cursorNew(overlay)
	local rect = rectNew()
	rectSetLocalcoord(rect, motif.info.localcoord[1], motif.info.localcoord[2])
	rectSetWindow(rect,overlay.window[1], overlay.window[2], overlay.window[3], overlay.window[4])
	rectSetColor(rect, overlay.col[1],overlay.col[2],overlay.col[3])
	rectSetAlpha(rect, overlay.alpha[1], overlay.alpha[2])
	return rect
end

return t