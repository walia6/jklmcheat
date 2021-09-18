local alpha = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v"}

local path = "/home/ubuntu/jklmcheat/"
local used_words = {}

ct=0

function bool_to_text(bool)
	if bool then return "true" end
	return "false"
end
function copy(obj, seen)
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
	return res
end



local alpha_pos = {
	["q"] = {1, 3},
	["w"] = {2, 3},
	["e"] = {3, 3},
	["r"] = {4, 3},
	["t"] = {5, 3},
	["y"] = {6, 3},
	["u"] = {7, 3},
	["i"] = {8, 3},
	["o"] = {9, 3},
	["p"] = {10, 3},
	["a"] = {1, 2},
	["s"] = {2, 2},
	["d"] = {3, 2},
	["f"] = {4, 2},
	["g"] = {5, 2},
	["h"] = {6, 2},
	["j"] = {7, 2},
	["k"] = {8, 2},
	["l"] = {9, 2},
	["z"] = {1, 1},
	["x"] = {2, 1},
	["c"] = {3, 1},
	["v"] = {4, 1},
	["b"] = {5, 1},
	["m"] = {6, 1},
	["n"] = {7, 1}
}

local function calculate_difficulty(word)
	local distance = 0
	local current_letter, prev_letter
	for i = 2, #word do
		current_letter = string.sub(word, i, i)
		prev_letter = string.sub(word, i - 1, i - 1)
		distance = distance + math.sqrt((alpha_pos[current_letter][1] - alpha_pos[prev_letter][1]) ^ 2 + (alpha_pos[current_letter][2] - alpha_pos[prev_letter][2]) ^ 2)
	end

	return distance
end

function calculate_diversity(word, working_alpha)
	current_alpha = copy(working_alpha)
	local diversity = 0
	local used_letters = {}
	for i = 1, #word do
		letter = string.lower(string.sub(word, i, i))
		for _, v in pairs(working_alpha) do
			if current_alpha[letter] then
				diversity = diversity + 1
				ct=ct+1
				current_alpha[letter] = false
			end
		end
	end

	return diversity, current_alpha
end
function best_word(pattern, tAlpha)
	constanttest=copy(tAlpha)
	os.execute("cat " .. path .. "words.txt | grep " .. pattern .. " > " .. path .. ".words.txt")
	local f = io.open(path .. ".words.txt", "r")
	local word = f:read()
	local best = ""
	local best_diversity = -1
	local best_difficulty = 999999
	local diversity, best_alpha, working_alpha, difficulty
	while word do
		for _, v in pairs(used_words) do
			if v == word then
				goto read_line
			end
		end

		diversity, working_alpha = calculate_diversity(word, constanttest)
		difficulty = calculate_difficulty(word)
		if diversity > best_diversity or (diversity == best_diversity and difficulty < best_difficulty)then

			best = word
			best_diversity = diversity
			best_alpha = working_alpha
			best_difficulty = difficulty
			--print("new best: ".. best.. "\t" .. best_diversity .. "\t" .. best_difficulty)
		end

		::read_line::
		word = f:read()
	end
	used_words[#used_words + 1] = best

	--print("<"..best_diversity..">")
	return best, best_alpha
end



local reset_alpha, pattern, word, working_alpha
local current_alpha = {}

function main()
	for _, v in pairs(alpha) do
		current_alpha[v] = true
	end

	while true do
		reset_alpha = false
		for _, v in pairs(current_alpha) do
			reset_alpha = reset_alpha or v
			if v then break end
		end
		if not reset_alpha then
			for _, v in pairs(alpha) do
				current_alpha[v] = true
			end
			print("gained health")
		end
		io.write("Pattern: ")
		pattern = io.read()
		word, working_alpha = best_word(pattern, current_alpha)
		local diversity, _ = calculate_diversity(word, current_alpha)

		print(word .. " \t" .. diversity)
		io.write("did you die? (y/n) ")
		if string.lower(io.read()) ~= "y" then
			current_alpha = working_alpha
		end
	end
end

main()

