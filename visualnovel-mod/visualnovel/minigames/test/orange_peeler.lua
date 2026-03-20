-- Orange Peeler Minigame by dionednd
-- Sample Minigame for Visual Novel Mode

-- TO DO:
-- Damage Drain life drain K.O
-- actual background

-- because i'm too lazy to color index my custom sprites
local bilinear_filter = gameOption("Video.RGBSpriteBilinearFilter")
modifyGameOption("Video.RGBSpriteBilinearFilter", 0)

-- load all external resources we need first
local sffOrangePeeler = sffNew("visualnovel/minigames/test/orange_peeler.sff")
local animTableOrangePeeler = loadAnimTable("visualnovel/minigames/test/orange_peeler.air", sffOrangePeeler)
local sndOrangePeeler = sndNew("visualnovel/minigames/test/orange_peeler.snd")

local animKungFuMan = animNew(sffOrangePeeler, animTableOrangePeeler[0])

animSetLocalcoord(animKungFuMan, 1280, 720)
animSetAngle(animKungFuMan, 0)
animSetXShear(animKungFuMan, 0)
animSetProjection(animKungFuMan, "orthographic")
animSetFocalLength(animKungFuMan, 2048)

animSetPos(animKungFuMan, 150,610)
animSetScale(animKungFuMan, 4, 4)
animSetLayerno(animKungFuMan, 0)

local animOrange = animNew(sffOrangePeeler, animTableOrangePeeler[10])

animSetLocalcoord(animOrange, 1280, 720)
animSetAngle(animOrange, 0)
animSetXShear(animOrange, 0)
animSetProjection(animOrange, "orthographic")
animSetFocalLength(animOrange, 2048)

animSetPos(animOrange, 1280,720)
animSetScale(animOrange, 4, 4)
animSetLayerno(animOrange, 1)

local animLime = animNew(sffOrangePeeler, animTableOrangePeeler[20])

animSetLocalcoord(animLime, 1280, 720)
animSetAngle(animLime, 0)
animSetXShear(animLime, 0)
animSetProjection(animLime, "orthographic")
animSetFocalLength(animLime, 2048)

animSetPos(animLime, 1280,720)
animSetScale(animLime, 4, 4)
animSetLayerno(animLime, 1)

local animOrangeHit = animNew(sffOrangePeeler, animTableOrangePeeler[11])

animSetLocalcoord(animOrangeHit, 1280, 720)
animSetAngle(animOrangeHit, 0)
animSetXShear(animOrangeHit, 0)
animSetProjection(animOrangeHit, "orthographic")
animSetFocalLength(animOrangeHit, 2048)

animSetPos(animOrangeHit, 400,305)
animSetScale(animOrangeHit, 4, 4)
animSetLayerno(animOrangeHit, 1)

local animLimeHit = animNew(sffOrangePeeler, animTableOrangePeeler[21])

animSetLocalcoord(animLimeHit, 1280, 720)
animSetAngle(animLimeHit, 0)
animSetXShear(animLimeHit, 0)
animSetProjection(animLimeHit, "orthographic")
animSetFocalLength(animLimeHit, 2048)

animSetPos(animLimeHit, 400,305)
animSetScale(animLimeHit, 4, 4)
animSetLayerno(animLimeHit, 1)

local animOutline = animNew(sffOrangePeeler, animTableOrangePeeler[30])

animSetLocalcoord(animOutline, 1280, 720)
animSetAngle(animOutline, 0)
animSetXShear(animOutline, 0)
animSetProjection(animOutline, "orthographic")
animSetFocalLength(animOutline, 2048)

animSetPos(animOutline, 400,305)
animSetScale(animOutline, 4, 4)
animSetLayerno(animOutline, 1)

-- we have the animations now

local fntScore = fontNew("visualnovel/minigames/test/orange.def", -1)

local tsScore = textImgNew()

textImgSetLocalcoord(tsScore, 1280, 720)
textImgSetAngle(tsScore, 0)
textImgSetXShear(tsScore, 0)
textImgSetProjection(tsScore, "orthographic")
textImgSetFocalLength(tsScore, 2048)

textImgSetFont(tsScore, fntScore)
textImgSetAlign(tsScore, -1)
textImgSetScale(tsScore,0.25,0.25)
textImgSetLayerno(tsScore, 2)
textImgSetPos(tsScore, 1230, 75)
textImgSetColor(tsScore, 255,255,255)
textImgSetBank(tsScore, 0)

local tsText = textImgNew()

textImgSetLocalcoord(tsText, 1280, 720)
textImgSetAngle(tsText, 0)
textImgSetXShear(tsText, 0)
textImgSetProjection(tsText, "orthographic")
textImgSetFocalLength(tsText, 2048)

textImgSetFont(tsText, fntScore)
textImgSetAlign(tsText, -1)
textImgSetScale(tsText,0.375,0.375)
textImgSetLayerno(tsText, 2)
textImgSetPos(tsText, 1230, 50)
textImgSetColor(tsText, 255,255,255)
textImgSetBank(tsText, 0)

textImgSetText(tsText, "SCORE")

local tsHits = textImgNew()

textImgSetLocalcoord(tsHits, 1280, 720)
textImgSetAngle(tsHits, 0)
textImgSetXShear(tsHits, 0)
textImgSetProjection(tsHits, "orthographic")
textImgSetFocalLength(tsHits, 2048)

textImgSetFont(tsHits, fntScore)
textImgSetAlign(tsHits, 1)
textImgSetScale(tsHits,0.375,0.375)
textImgSetLayerno(tsHits, 2)
textImgSetPos(tsHits, 200, 150)
textImgSetColor(tsHits, 255,255,255)
textImgSetBank(tsHits, 0)

textImgSetText(tsHits, "0 HITS!")

local tsHitType = textImgNew()

textImgSetLocalcoord(tsHitType, 1280, 720)
textImgSetAngle(tsHitType, 0)
textImgSetXShear(tsHitType, 0)
textImgSetProjection(tsHitType, "orthographic")
textImgSetFocalLength(tsHitType, 2048)

textImgSetFont(tsHitType, fntScore)
textImgSetAlign(tsHitType, 1)
textImgSetScale(tsHitType,0.375,0.375)
textImgSetLayerno(tsHitType, 2)
textImgSetPos(tsHitType, 250, 200)
textImgSetColor(tsHitType, 255,255,0)
textImgSetBank(tsHitType, 0)

textImgSetText(tsHitType, "PERFECT!")

local tsCountdown = textImgNew()

textImgSetLocalcoord(tsCountdown, 1280, 720)
textImgSetAngle(tsCountdown, 0)
textImgSetXShear(tsCountdown, 0)
textImgSetProjection(tsCountdown, "orthographic")
textImgSetFocalLength(tsCountdown, 2048)

textImgSetFont(tsCountdown, fntScore)
textImgSetAlign(tsCountdown, 0)
textImgSetScale(tsCountdown,0.375,0.375)
textImgSetLayerno(tsCountdown, 2)
textImgSetPos(tsCountdown, 640, 360)
textImgSetColor(tsCountdown, 255,255,255)
textImgSetBank(tsCountdown, 0)

textImgSetText(tsCountdown, "3")

function isOnBeat(currentSampleCount, bpm, sampleRate)

	local beatsPerSecond = bpm / 60
	local samplesPerBeat = sampleRate / beatsPerSecond
	
	-- Check if current sample count is approximately on a beat
	local mod = currentSampleCount % (samplesPerBeat + 1)
	return mod < (samplesPerBeat * 0.2)  -- 20% tolerance for being "on a beat"

end

-- osu file parser

function parseOsuFile(filepath)
    local file = io.open(filepath, "r")
    if not file then return nil end

    local beatmap = {
        metadata = {}, timingPoints = {}, hitObjects = {}
    }
    local currentSection = ""

    local seenTimes = {}  -- Table to track hitObject times

    local function addHit(timeMs, x, y, hitType)
        -- Convert time to sample count and avoid duplicates
        if not seenTimes[timeMs] then
            seenTimes[timeMs] = true
		local obj = {
                time = timeMs,
                x = x,
                y = y,
                type = hitType
            }
            table.insert(beatmap.hitObjects, #beatmap.hitObjects+1, obj)
        end
    end

    local function hasBit(x, b)
        return x % (b * 2) >= b
    end

    local function currentBeatLength(timeMs)
        local beatLength = 0
        for i, timing in ipairs(beatmap.timingPoints) do
            if timeMs >= timing.time then
                beatLength = 240000 / timing.bpm
            end
        end
        return beatLength
    end

    for line in file:lines() do
        line = line:match("^%s*(.-)%s*$")

        if line == "" or line:sub(1, 2) == "//" then
        elseif line:sub(1, 1) == "[" and line:sub(-1, -1) == "]" then
            currentSection = line
        elseif currentSection == "[HitObjects]" then
            local values = {}
            for val in string.gmatch(line, "([^,]+)") do
                table.insert(values, val)
            end

            if #values >= 3 then
                local timeMs = tonumber(values[3])
                local typeFlag = tonumber(values[4])
                local isCircle = hasBit(typeFlag, 1)
                local isSlider = hasBit(typeFlag, 2)
                local isSpinner = hasBit(typeFlag, 8)

                local x = tonumber(values[1])
                local y = tonumber(values[2])

                local hitType = 1

                if isCircle and not isSlider and not isSpinner then
                    if seenTimes[timeMs] then
                        goto continue
                    end

                    addHit(timeMs, x, y, hitType)

                elseif isSlider and not isSpinner then
                    local repeatCount = tonumber(values[7]) or 2
                    local sliderLength = tonumber(values[8]) or 0
                    local beatLength = currentBeatLength(timeMs)

                    local duration = beatLength * repeatCount
                    local interval = beatLength

                    local t = timeMs
                    while t <= timeMs + duration do
                        -- Skip duplicate times
                        if not seenTimes[t] then
                            addHit(t, x, y, hitType)
                        end
                        t = t + interval
                    end

                elseif isSpinner then
                    local endTime = tonumber(values[6])
                    local interval = 100

                    local t = timeMs
                    while t <= endTime do
                        if not seenTimes[t] then
                            addHit(t, x, y, hitType)
                        end
                         t = t + interval
                    end
                end
            end
        elseif currentSection == "[General]" or currentSection == "[Metadata]" or currentSection == "[Difficulty]" then
            local key, val = line:match("^(.-):%s*(.*)$")
            if key then beatmap.metadata[key] = val end
        elseif currentSection == "[TimingPoints]" then
            local values = {}
            for val in string.gmatch(line, "([^,]+)") do
                table.insert(values, tonumber(val))  -- Store numeric values
            end
            if #values >= 2 then
                local timingPoint = {
                    time = values[1],  -- Time (in ms) of the timing point
                    bpm = values[2],   -- BPM at this timing point
                }
                table.insert(beatmap.timingPoints, timingPoint)
            end
        end

        ::continue::
    end

    file:close()
    return beatmap
end

function getHitObjectColor(hitObject, screenWidth)
	if hitObject.x < screenWidth / 2 then
		return "red"
	else
		return "blue"
	end
end

function isOnHitObject(timer, hitObject, sampleRate, hitWindow)
	local hitObjectSampleCount = (hitObject.time / 1000) * sampleRate

	if math.abs(timer - hitObjectSampleCount) <= hitWindow * 0.2 then
		return true
	end

	return false
end

function calculateHitScore(timer, hitObject, sampleRate, hitWindow, comboHits, defaultPoints)
	local hitObjectSampleCount = (hitObject.time / 1000) * sampleRate

	local timeDifference = math.abs(timer - hitObjectSampleCount)

	if timeDifference <= hitWindow then
		local timingScore = math.max(0, (1 - (timeDifference / hitWindow)))  -- Score between 0 and 1

		local comboMultiplier = comboHits
		local _score = defaultPoints * timingScore * comboMultiplier

		if timeDifference <= hitWindow * 0.05 then
			_score = _score * 1.5
		elseif timeDifference <= hitWindow * 0.1 then
			_score = _score * 1.2
		elseif timeDifference <= hitWindow * 0.2 then
			_score = _score * 1.0
		else
			_score = 0
		end

		return _score
	end

	return 0
end

function calculateHitType(timer, hitObject, sampleRate, hitWindow)
	local hitObjectSampleCount = (hitObject.time / 1000) * sampleRate
	local timeDifference = math.abs(timer - hitObjectSampleCount)

	if timeDifference <= hitWindow then
		if timeDifference <= hitWindow * 0.05 then
			hittype = "PERFECT!"
			clr =  {0,255,0}
		elseif timeDifference <= hitWindow * 0.1 then
			hittype = "GOOD!"
			clr = {255,255,0}
		elseif timeDifference <= hitWindow * 0.2 then
			hittype = "OKAY!"
			clr = {255,192,0}
		else
			hittype = "MISS!"
			clr = {255,0,0}
		end
		return hittype, clr
	end

	return "MISS!", {255,0,0}
end

function visualnovel.orange_peeler()
	
	local score = 0
	local comboHits = 0
	local sampleRate = 44100
	local beatmap = parseOsuFile("visualnovel/minigames/test/7!! - Orange (Kagamine Ren) [Orange].osu")
	local approachRate = beatmap.metadata["ApproachRate"] * 100
	stopBgm()
	local bpm = 86
	local bgColor = { r = 0, g = 0, b = 0 }
	local outlineColor = {255,255,255}
	local outlinecolortime = 0
	local animstuck = 0
	local sndVolume = 0.5
	local hitWindow = sampleRate
	local screenWidth = 720
	local orangeanimtime = 0
	local limeanimtime = 0
	local exit = false
	local hurt = 0
	local countdown_timer = (240/bpm) * sampleRate
	local timer = countdown_timer * -1
	local vibe = 0
	local hittype = ""
	local clr = {255,255,255}
	local hittypetimer = 0
	local countdowntimer = 0
	local countdown = 4
	local orangepeels = 0
	local ko = false

	-- countdown

	while timer < 0 do
		if esc() then
			exit = true
			break
		end
		
		if isOnBeat(timer, bpm, sampleRate) and animstuck == 0 and hurt == 0 and vibe == 0 then
			animSetAnimation(animKungFuMan, animTableOrangePeeler[0])
			vibe = 1
			bgColor = { r = 128, g = 128, b = 128 }
			if timer > ((countdown_timer * 0.26) * -1) then
				sndPlay(sndOrangePeeler, 0, 5)
			else
				sndPlay(sndOrangePeeler, 0, 6)
			end
			if countdown == 4 then
				countdowntimer = 30
				countdown = 3
				textImgSetText(tsCountdown, "3")
				textImgSetColor(tsCountdown, 255,255,0)
			elseif countdown == 3 then
				countdowntimer = 30
				countdown = 2
				textImgSetText(tsCountdown, "2")
				textImgSetColor(tsCountdown, 255,192,0)
			elseif countdown == 2 then
				countdowntimer = 30
				countdown = 1
				textImgSetText(tsCountdown, "1")
				textImgSetColor(tsCountdown, 255,0,0)
			elseif countdown == 1 then
				countdowntimer = 30
				countdown = 0
				textImgSetText(tsCountdown, "GO!")
				textImgSetColor(tsCountdown, 0,255,0)
			end
		elseif not isOnBeat(timer, bpm, sampleRate) then
			vibe = 0
		end

		if countdowntimer > 0 then
			textImgDraw(tsCountdown)
			countdowntimer = countdowntimer - 1
		end

		local press = { a = "a", b = "b" }
		local pressed = { a = getInput(-1, press.a), b = getInput(-1, press.b)}

		for i, hitObject in ipairs(beatmap.hitObjects) do

			if true then
				local color = getHitObjectColor(hitObject, screenWidth)

				if pressed.a then
					if color == "red" and isOnHitObject(timer, hitObject, sampleRate, hitWindow) then
						comboHits = comboHits + 1
						score = score + math.ceil(calculateHitScore(timer, hitObject, sampleRate, hitWindow, comboHits, 100))
						sndPlay(sndOrangePeeler, 0, 1)
						animSetAnimation(animOrangeHit, animTableOrangePeeler[11])
						orangeanimtime = 16
						table.remove(beatmap.hitObjects, i)
						animSetAnimation(animKungFuMan, animTableOrangePeeler[2])
						animstuck = 7
						outlineColor = {255,165,0}
						outlinecolortime = 12
						hittype, clr = calculateHitType(timer, hitObject, sampleRate, hitWindow)
						textImgSetColor(tsHitType, clr[1],clr[2],clr[3])
						textImgSetText(tsHitType, hittype)
						hittypetimer = 16
						orangepeels = orangepeels + 1
						break
					elseif i == #beatmap.hitObjects then
						sndPlay(sndOrangePeeler, 0, 0)
						animSetAnimation(animKungFuMan, animTableOrangePeeler[2])
						animstuck = 7
						outlineColor = {255,165,0}
						outlinecolortime = 12
						hittypetimer = 16
					end
				elseif pressed.b then
					if color == "blue" and isOnHitObject(timer, hitObject, sampleRate, hitWindow) then
						comboHits = comboHits + 1
						score = score + math.ceil(calculateHitScore(timer, hitObject, sampleRate, hitWindow, comboHits, 100))
						sndPlay(sndOrangePeeler, 0, 3)
						animSetAnimation(animLimeHit, animTableOrangePeeler[21])
						limeanimtime = 16
						table.remove(beatmap.hitObjects, i)
						animSetAnimation(animKungFuMan, animTableOrangePeeler[1])
						animstuck = 7
						outlineColor = {44,157,54}
						outlinecolortime = 12
						hittype, clr = calculateHitType(timer, hitObject, sampleRate, hitWindow)
						textImgSetColor(tsHitType, clr[1],clr[2],clr[3])
						textImgSetText(tsHitType, hittype)
						hittypetimer = 16
						break
					elseif i == #beatmap.hitObjects then
						comboHits = 0
						sndPlay(sndOrangePeeler, 0, 2)
						animSetAnimation(animKungFuMan, animTableOrangePeeler[1])
						animstuck = 7
						outlineColor = {44,157,54}
						outlinecolortime = 12
						textImgSetColor(tsHitType, 255,0,0)
						textImgSetText(tsHitType, "MISS!")
						hittypetimer = 16
					end
				end
			end
		end

		for i, hitObject in ipairs(beatmap.hitObjects) do
			local hitObjectSampleCount = hitObject.time * (sampleRate / 1000)
			local timeDifference = (timer - hitObjectSampleCount) * -1
			local hitWindow = sampleRate

			local xPos = 400 + (timeDifference / hitWindow) * approachRate/2

			if xPos > 1380 then
				xPos = 1380
			elseif xPos < -100 then
				xPos = -100
			end

			if xPos <= 170 then
				sndPlay(sndOrangePeeler, 0, 4)
				comboHits = 0
				table.remove(beatmap.hitObjects, i)
				if animstuck == 0 and hurt == 0 then
					animSetAnimation(animKungFuMan, animTableOrangePeeler[3])
					hurt = 5
					textImgSetColor(tsHitType, 255,0,0)
					textImgSetText(tsHitType, "MISS!")
					hittypetimer = 16
				end
			elseif animstuck > 0 and hurt > 0 then
				hurt = 0
			end

			local yPos = 305
	
			local color = getHitObjectColor(hitObject, screenWidth)
	
			if color == "red" and xPos < 1380 and xPos > 0 then
				animSetPos(animOrange, xPos, yPos)
				animDraw(animOrange)
				animUpdate(animOrange)
			elseif color == "blue" and xPos < 1380 and xPos > 0 then
				animSetPos(animLime, xPos, yPos)
				animDraw(animLime)
				animUpdate(animLime)
			end
		end

		if hurt > 0 then
			hurt = hurt - 1
		end

		if orangeanimtime > 0 then
			orangeanimtime = orangeanimtime - 1
		end

		if limeanimtime > 0 then
			limeanimtime = limeanimtime - 1
		end

		if orangeanimtime > 0 then
			animDraw(animOrangeHit)
			animUpdate(animOrangeHit)
		end
		if limeanimtime > 0 then
			animDraw(animLimeHit)
			animUpdate(animLimeHit)
		end

		if bgColor.r > 0 then
			bgColor.r = bgColor.r - 8
			bgColor.g = bgColor.g - 8
			bgColor.b = bgColor.b - 8
		end

		animDraw(animKungFuMan)
		animUpdate(animKungFuMan)

		local mulRStart = outlineColor[1]
		local mulGStart = outlineColor[2]
		local mulBStart = outlineColor[3]

		local progress = math.min(1, outlinecolortime / 8)

		local mulR = 255 - (255 - mulRStart) * progress
		local mulG = 255 - (255 - mulGStart) * progress
		local mulB = 255 - (255 - mulBStart) * progress

		animSetPalFX(animOutline, {mul = {mulR,mulG,mulB}})
		animDraw(animOutline)
		animUpdate(animOutline)

		if animstuck > 0 then
			animstuck = animstuck - 1
		end

		if outlinecolortime > 0 then
			outlinecolortime = outlinecolortime - 1
		end

		textImgSetText(tsScore, score)
		textImgDraw(tsScore)
		textImgDraw(tsText)

		refresh()
		timer = timer + sampleRate * (1/getGameFPS())
	end

	if exit == true then
		return true, 0
	end

	-- actual song playing
	playBgm({bgm = "visualnovel/minigames/test/" .. beatmap.metadata["AudioFilename"], loop = 0})

	timer = 0
	
	while tonumber(bgmVar('position')) < tonumber(bgmVar('length')) do

		if esc() then
			exit = true
			break
		end
		
		if isOnBeat(timer, bpm, sampleRate) and animstuck == 0 and hurt == 0 and vibe == 0 then
			animSetAnimation(animKungFuMan, animTableOrangePeeler[0])
			vibe = 1
			bgColor = { r = 128, g = 128, b = 128 }
		elseif not isOnBeat(timer, bpm, sampleRate) then
			vibe = 0
		end

		-- Press Buttons

		local press = { a = "a", b = "b" }
		local pressed = { a = getInput(-1, press.a), b = getInput(-1, press.b)}

		for i, hitObject in ipairs(beatmap.hitObjects) do

			if true then
				local color = getHitObjectColor(hitObject, screenWidth)

				if pressed.a then
					if color == "red" and isOnHitObject(timer, hitObject, sampleRate, hitWindow) then
						comboHits = comboHits + 1
						score = score + math.ceil(calculateHitScore(timer, hitObject, sampleRate, hitWindow, comboHits, 100))
						sndPlay(sndOrangePeeler, 0, 1)
						animSetAnimation(animOrangeHit, animTableOrangePeeler[11])
						orangeanimtime = 16
						table.remove(beatmap.hitObjects, i)
						animSetAnimation(animKungFuMan, animTableOrangePeeler[2])
						animstuck = 7
						outlineColor = {255,165,0}
						outlinecolortime = 12
						hittype, clr = calculateHitType(timer, hitObject, sampleRate, hitWindow)
						textImgSetColor(tsHitType, clr[1],clr[2],clr[3])
						textImgSetText(tsHitType, hittype)
						hittypetimer = 16
						orangepeels = orangepeels + 1
						break
					elseif i == #beatmap.hitObjects then
						comboHits = 0
						sndPlay(sndOrangePeeler, 0, 0)
						animSetAnimation(animKungFuMan, animTableOrangePeeler[2])
						animstuck = 7
						outlineColor = {255,165,0}
						outlinecolortime = 12
						textImgSetColor(tsHitType, 255,0,0)
						textImgSetText(tsHitType, "MISS!")
						hittypetimer = 16
					end
				elseif pressed.b then
					if color == "blue" and isOnHitObject(timer, hitObject, sampleRate, hitWindow) then
						comboHits = comboHits + 1
						score = score + math.ceil(calculateHitScore(timer, hitObject, sampleRate, hitWindow, comboHits, 100))
						sndPlay(sndOrangePeeler, 0, 3)
						animSetAnimation(animLimeHit, animTableOrangePeeler[21])
						limeanimtime = 16
						table.remove(beatmap.hitObjects, i)
						animSetAnimation(animKungFuMan, animTableOrangePeeler[1])
						animstuck = 7
						outlineColor = {44,157,54}
						outlinecolortime = 12
						hittype, clr = calculateHitType(timer, hitObject, sampleRate, hitWindow)
						textImgSetColor(tsHitType, clr[1],clr[2],clr[3])
						textImgSetText(tsHitType, hittype)
						hittypetimer = 16
						break
					elseif i == #beatmap.hitObjects then
						comboHits = 0
						sndPlay(sndOrangePeeler, 0, 2)
						animSetAnimation(animKungFuMan, animTableOrangePeeler[1])
						animstuck = 7
						outlineColor = {44,157,54}
						outlinecolortime = 12
						textImgSetColor(tsHitType, 255,0,0)
						textImgSetText(tsHitType, "MISS!")
						hittypetimer = 16
					end
				end
			end
		end

		for i, hitObject in ipairs(beatmap.hitObjects) do
			local hitObjectSampleCount = hitObject.time * (sampleRate / 1000)
			local timeDifference = (timer - hitObjectSampleCount) * -1
			local hitWindow = sampleRate

			local xPos = 400 + (timeDifference / hitWindow) * approachRate/2

			if xPos > 1380 then
				xPos = 1380
			elseif xPos < -100 then
				xPos = -100
			end

			if xPos <= 170 then
				sndPlay(sndOrangePeeler, 0, 4)
				comboHits = 0
				table.remove(beatmap.hitObjects, i)
				if animstuck == 0 and hurt == 0 then
					animSetAnimation(animKungFuMan, animTableOrangePeeler[3])
					hurt = 5
					textImgSetColor(tsHitType, 255,0,0)
					textImgSetText(tsHitType, "MISS!")
					hittypetimer = 16
				end
			elseif animstuck > 0 and hurt > 0 then
				hurt = 0
			end
	
			local yPos = 305
	
			local color = getHitObjectColor(hitObject, screenWidth)
	
			if color == "red" and xPos < 1380 and xPos > 0 then
				animSetPos(animOrange, xPos, yPos)
				animDraw(animOrange)
				animUpdate(animOrange)
			elseif color == "blue" and xPos < 1380 and xPos > 0 then
				animSetPos(animLime, xPos, yPos)
				animDraw(animLime)
				animUpdate(animLime)
			end
		end

		if hurt > 0 then
			hurt = hurt - 1
		end

		if orangeanimtime > 0 then
			orangeanimtime = orangeanimtime - 1
		end

		if limeanimtime > 0 then
			limeanimtime = limeanimtime - 1
		end

		if orangeanimtime > 0 then
			animDraw(animOrangeHit)
			animUpdate(animOrangeHit)
		end
		if limeanimtime > 0 then
			animDraw(animLimeHit)
			animUpdate(animLimeHit)
		end

		if bgColor.r > 0 then
			bgColor.r = bgColor.r - 8
			bgColor.g = bgColor.g - 8
			bgColor.b = bgColor.b - 8
		end

		animDraw(animKungFuMan)
		animUpdate(animKungFuMan)

		local mulRStart = outlineColor[1]
		local mulGStart = outlineColor[2]
		local mulBStart = outlineColor[3]

		local progress = math.min(1, outlinecolortime / 8)

		local mulR = 255 - (255 - mulRStart) * progress
		local mulG = 255 - (255 - mulGStart) * progress
		local mulB = 255 - (255 - mulBStart) * progress

		animSetPalFX(animOutline, {mul = {mulR,mulG,mulB}})
		animDraw(animOutline)
		animUpdate(animOutline)

		if animstuck > 0 then
			animstuck = animstuck - 1
		end

		if outlinecolortime > 0 then
			outlinecolortime = outlinecolortime - 1
		end

		textImgSetText(tsScore, score)
		textImgDraw(tsScore)
		textImgDraw(tsText)

		-- Combo Counter
		if comboHits > 1 then
			textImgSetText(tsHits, tostring(comboHits) .. " HITS!")
			textImgDraw(tsHits)
		end

		if hittypetimer > 0 then
			textImgDraw(tsHitType)
			hittypetimer = hittypetimer - 1
		end
		refresh()
		timer = tonumber(bgmVar('position'))
	end
	return exit, score, orangepeels
end

modifyGameOption("Video.RGBSpriteBilinearFilter", bilinear_filter)

local exit, score, orangepeel, ko = visualnovel.orange_peeler()

stopBgm()

return exit, score, orangepeel, ko