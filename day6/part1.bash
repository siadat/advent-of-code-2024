root=/dev/shm/day6
rm -rf $root

guard_row=
guard_col=
guard_chr=
rows=
cols=

# Create an empty directory for each block, and find the guard's position
while std.read row line; do
	while std.read col char; do
		case "$char" in
			"#" )
				mkdir -p $root/blocks/$row/$col
				;;
			"^" | "v" | "<" | ">" )
				guard_col=$col
				guard_row=$row
				guard_chr=$char
				;;
		esac
		cols=$col
	done < <(echo "$line" | std.split "" | nl)
	rows=$row
done < <(cat day6/input | nl)

# Run the guard
total=1 # Include the starting block
while true; do
	# Find the closest block
	case "$guard_chr" in
		"^" )
			next_row=$(std.eval_math "$guard_row - 1")
			if [ -d $root/blocks/$next_row/$guard_col ]; then
				guard_chr=">"
			else
				guard_row=$next_row
				std.debug.log "l"
			fi ;;
		"v")
			next_row=$(std.eval_math "$guard_row + 1")
			if [ -d $root/blocks/$next_row/$guard_col ]; then
				guard_chr="<"
			else
				guard_row=$next_row
				std.debug.log "h"
			fi ;;
		"<")
			next_col=$(std.eval_math "$guard_col - 1")
			if [ -d $root/blocks/$guard_row/$next_col ]; then
				guard_chr="^"
			else
				guard_col=$next_col
				std.debug.log "k"
			fi ;;
		">")
			next_col=$(std.eval_math "$guard_col + 1")
			if [ -d $root/blocks/$guard_row/$next_col ]; then
				guard_chr="v"
			else
				guard_col=$next_col
				std.debug.log "j"
			fi ;;
	esac
	if [ $guard_col -lt 1 ] || [ $guard_col -gt $cols ] || [ $guard_row -lt 1 ] || [ $guard_row -gt $rows ]; then
		break
	fi

	if ! [ -d $root/visited/$guard_row/$guard_col ]; then
		total=$(std.eval_math "$total + 1")
		mkdir -p $root/visited/$guard_row/$guard_col
	fi
done
echo $total
