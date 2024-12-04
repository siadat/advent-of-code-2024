cat day3/input \
	| grep -Po -e "mul\(\d{1,3},\d{1,3}\)|do\(\)|don't\(\)" \
	| sed "/don't()/,/do()/d" \
	| grep -vw -P "do\(\)|don't\(\)" \
	| perl -pe 's#mul\((\d{1,3}),(\d{1,3})\)#\1 * \2#' \
	| bc | paste -sd+ | bc
