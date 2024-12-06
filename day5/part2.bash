root=/dev/shm/day5
rm -rf $root

# Read the rules
cat day5/input | std.filter_literal '|' | while IFS='|' std.read prev next; do
	mkdir -p $root/forward/{$next,$prev}
	std.create $root/forward/{$next,$prev}/direct
	echo "$next" >> $root/forward/$prev/direct
done

# Check and correct the sequences
cat day5/input | std.filter_regex , | nl | while std.read seqIdx sequence; do
	std.debug.log "Checking sequence$seqIdx $sequence..."
	sequence_regex="$(echo "$sequence" | std.replace_all ',' '|')"

	# Sort items in sequence by the number of dependencies in the sequence
	echo "$sequence" | std.split , | while std.read page; do
		dependency_count="$(std.find "$sequence_regex" $root/forward/$page/direct | std.count_lines)"
		echo "$dependency_count $page"
	done | std.sort_numeric | std.reverse | col2 | std.join , > $root/sorted_sequence

	if [ "$sequence" == "$(cat $root/sorted_sequence)" ]; then
		# already good
		continue
	fi

	sequence="$(cat $root/sorted_sequence)"
	std.debug.log "Corrected: $sequence"
	length="$(echo "$sequence" | std.split , | std.count_lines)"
	middle_idx=$(std.eval_math "($length+1) / 2")
	echo "$sequence" | std.split , | std.filter_line_number $middle_idx
done | std.join + | std.eval_math
