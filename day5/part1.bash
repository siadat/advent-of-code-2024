#!./mash
root=/dev/shm/day5
rm -rf $root

# Example of storing the rules:
#
#     /dev/shm/day5/forward/53/direct
#     /dev/shm/day5/forward/47/direct
#     /dev/shm/day5/forward/13/direct
#     /dev/shm/day5/forward/97/direct
#     /dev/shm/day5/forward/61/direct
#     /dev/shm/day5/forward/29/direct
#     /dev/shm/day5/forward/75/direct
#
# Example of storing a sequence 61,13,29:
#
#     /dev/shm/day5/sequence1/
#     └── 61
#         ├── 13
#         │   ├── 29
#         │   │   └── nexts -> /dev/shm/day5/forward/29
#         │   └── nexts -> /dev/shm/day5/forward/13
#         └── nexts -> /dev/shm/day5/forward/61

# Read the rules
cat day5/input | std.filter_literal '|' | while IFS='|' std.read prev next; do
	mkdir -p $root/forward/{$next,$prev}
	std.create $root/forward/{$next,$prev}/direct
	echo "$next" >> $root/forward/$prev/direct
done

# Check the sequences
cat day5/input | std.filter_literal , | nl | while std.read idx sequence; do
	dir=$root/sequence$idx
	while std.read page; do
		dir=$dir/$page
		mkdir -p $dir
		ln -s $root/forward/$page $dir/nexts
	done < <(echo "$sequence" | std.split ,)

	dir=$root/sequence$idx
	while std.read page; do
		dir=$dir/$page
		if std.find_whole $page $dir | std.any; then
			std.debug.log "Bad: sequence$idx $sequence"
			continue 2
		fi
	done < <(echo "$sequence" | std.split ,)

	std.debug.log "Good: sequence$idx $sequence"
	length="$(echo "$sequence" | std.split , | std.count_lines)"
	middle_idx=$(std.eval_math "($length+1) / 2")
	echo "$sequence" | std.split , | std.filter_line_number $middle_idx
done | std.join + | std.eval_math
