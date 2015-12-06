list = []

File.readlines("words.txt").each do |line|
	list << line.chomp if line.length > 5 && line.length < 12
end

File.open("words.txt", "w") do |file|
	file.puts(list)
end