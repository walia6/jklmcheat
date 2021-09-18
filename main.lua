local alpha = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "o", "p", "q", "r", "s", "t", "u", "v"}

local path = "/home/ubuntu/jklmcheat/"
local used_words = {}



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


function calculate_diversity(word, working_alpha)
	current_alpha = copy(working_alpha)
	local diversity = 0
	local used_letters = {}
	for i = 1, #word do
		letter = string.lower(string.sub(word, i, i))
		for _, v in pairs(working_alpha) do
			if current_alpha[letter] then
				diversity = diversity + 1
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
	local diversity, best_alpha, working_alpha
	while word do
		for _, v in pairs(used_words) do
			if v == word then
				goto read_line
			end
		end

		diversity, working_alpha = calculate_diversity(word, constanttest)

		if diversity > best_diversity then

			best = word
			best_diversity = diversity
			best_alpha = working_alpha
			--print("new best: ".. best.. "\t" .. best_diversity)
		end

		::read_line::
		word = f:read()
	end
	used_words[#used_words + 1] = best

	--print("<"..best_diversity..">")
	return best, best_alpha
end



local current_alpha = {}
for _, v in pairs(alpha) do
	current_alpha[v] = true
end

local reset_alpha, pattern, word, working_alpha
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
