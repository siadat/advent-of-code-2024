root=/dev/shm/day6
rm -rf $root

declare -A blocks
declare -A visits
guard_row=
guard_col=
guard_chr=
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
				guard_col=$col
				guard_row=$row
				guard_chr=$char
				;;
		esac
		cols=$col
	done
	rows=$row
done < <(cat day6/input | nl)

# Run the guard
total=1 # Include the starting block
while true; do
	local next_row=$(( guard_row + row_moves["$guard_chr"] ))
	local next_col=$(( guard_col + col_moves["$guard_chr"] ))
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

	if ! [ -v visits["$guard_row,$guard_col"] ]; then
		total="$(( total +1 ))"
		visits["$guard_row,$guard_col"]=1
	fi
done
echo $total
