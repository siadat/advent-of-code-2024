cat day2/input | while read -r report; do
	report_len="$(echo "$report" | wc -w)"
	yes "$report" | head -n $report_len | nl --starting-line-number=0 | while read -r idx report; do
		report=($report)
		unset report[$idx]
		report="${report[@]}"
		while read -r min max; do
			transform="
				s/([0-9]+)/\1 \1/g;
				s/(^[0-9]+ | [0-9]+$)//g;
				s/([0-9]+) ([0-9]+)/((\2-\1)>=$min)\&\&((\2-\1)<=$max)/g;
				s/ / \&\& /g;
			"
			is_good="$(echo "$report" | sed -r "$transform" | bc)"
			if [ "$is_good" -eq 1 ]; then
				echo "good: $report"
				break 2
			fi
		done < <(
			echo "1 3"
			echo "-3 -1"
		)
	done
done | nl
