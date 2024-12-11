root=/dev/shm/day6
rm -rf $root
mkdir -p "$root/directions"

declare -A blocks
guard_row_init=
guard_col_init=
guard_chr_init=
rows=
cols=

declare -A col_moves
declare -A row_moves
declare -A rotates
col_moves=( ["^"]=+0 ["v"]=+0 ["<"]=-1 [">"]=+1 )
row_moves=( ["^"]=-1 ["v"]=+1 ["<"]=+0 [">"]=+0 )
rotates=( ["^"]=">" [">"]="v" ["v"]="<" ["<"]="^" )

# Create an empty directory for each block, and find the guard's position
while std.read row line; do
	for ((col = 1; col <= ${#line}; col++)); do
		char="${line:col-1:1}"
		case "$char" in
			"#" )
				blocks["$row,$col"]=$char
				;;
			"^" | "v" | "<" | ">" )
				guard_col_init=$col
				guard_row_init=$row
				guard_chr_init=$char
				;;
		esac
		cols=$col
	done
	rows=$row
done < <(cat day6/input | nl)

# Run the guard
total=0 # Include the starting block
while read -r row line; do
	while read -r col char; do
		local candidate_row=
		local candidate_col=
		case "$char" in
			"#" | "^" | "v" | "<" | ">" ) continue ;;
			".")
				candidate_row=$row
				candidate_col=$col
				blocks["$candidate_row,$candidate_col"]="#"
				;;
		esac

		local guard_row=$guard_row_init
		local guard_col=$guard_col_init
		local guard_chr=$guard_chr_init
		std.debug.log "$(std.epoch) Trying blocked added to $candidate_row,$candidate_col with guard $guard_chr at $guard_row,$guard_col"
		declare -A directs
		directs=()

		while true; do
			next_row=$(( guard_row + row_moves["$guard_chr"] ))
			next_col=$(( guard_col + col_moves["$guard_chr"] ))
			if [ -v blocks["$next_row,$next_col"] ]; then
				guard_chr="${rotates["$guard_chr"]}"
				continue
			else
				guard_row=$next_row
				guard_col=$next_col
			fi
			if [ $guard_col -lt 1 ] || [ $guard_col -gt $cols ] || [ $guard_row -lt 1 ] || [ $guard_row -gt $rows ]; then
				break
			fi

			if [ -v directs["$guard_row,$guard_col"] ]; then
				if [[ "${directs["$guard_row,$guard_col"]}" == *"$guard_chr"* ]]; then
					total="$(( total +1 ))"
					break
				fi
				directs["$guard_row,$guard_col"]="${directs["$guard_row,$guard_col"]}$guard_chr"
			else
				directs["$guard_row,$guard_col"]="$guard_chr"
			fi

		done

		# Revert
		unset blocks["$candidate_row,$candidate_col"]
	done < <(echo "$line" | std.split "" | nl)
done < <(cat day6/input | nl)
echo $total
