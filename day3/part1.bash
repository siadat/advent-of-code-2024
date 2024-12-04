cat day3/input \
	| grep -Po 'mul\(\d{1,3},\d{1,3}\)' \
	| perl -pe 's#mul\((\d{1,3}),(\d{1,3})\)#\1 * \2#' \
	| bc | paste -sd+ | bc
