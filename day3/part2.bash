cat day3/input \
	| grep --line-buffered -Po -e "mul\(\d{1,3},\d{1,3}\)|do\(\)|don't\(\)" \
	| sed -u "/don't()/,/do()/d" \
	| grep --line-buffered -vw -P "do\(\)|don't\(\)" \
	| perl -pe 'BEGIN { $| = 1 } s#mul\((\d{1,3}),(\d{1,3})\)#\1 * \2#' \
	| bc \
	| paste -sd+ \
	| bc
