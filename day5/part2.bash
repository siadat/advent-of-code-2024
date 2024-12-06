root=/dev/shm/day5
rm -rf $root

# Read the rules
cat day5/input | grep --fixed-strings '|' | while IFS='|' read -r prev next; do
	mkdir -p $root/forward/{$next,$prev}
	touch $root/forward/{$next,$prev}/direct
	echo "$next" >> $root/forward/$prev/direct
done

# Check and correct the sequences
cat day5/input | grep , | nl | while read -r seqIdx sequence; do
	echo "Checking sequence$seqIdx $sequence..." > /dev/stderr
	sequence_regex="$(echo "$sequence" | sed 's/,/|/g')"

	# Sort items in sequence by the number of dependencies in the sequence
	echo "$sequence" | grep -Po '\d+' | while read -r page; do
		dependency_count="$(grep -P "$sequence_regex" -R $root/forward/$page/direct | wc -l)"
		echo "$dependency_count $page"
	done | sort -k1 -nr | col2 | paste -sd, > $root/sorted_sequence 

	if [ "$sequence" == "$(cat $root/sorted_sequence)" ]; then
		# already good
		continue
	fi

	sequence="$(cat $root/sorted_sequence)"
	echo "Corrected: $sequence" > /dev/stderr
	length="$(echo "$sequence" | grep -Po '\d+' | wc -l)"
	middle_idx=$"$(( (length+1) / 2))"
	echo "$sequence" | grep -Po '\d+' | sed -n "$middle_idx"p
done | paste -sd+ | bc
