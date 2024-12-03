cat day2/input | while read -r report; do
	(
		echo "1 3"
		echo "-3 -1"
	) | while read -r min max; do
		transform="
			s/([0-9]+)/\1 \1/g;
			s/(^[0-9]+ | [0-9]+$)//g;
			s/([0-9]+) ([0-9]+)/((\2-\1)>=$min)\&\&((\2-\1)<=$max)/g;
			s/ / \&\& /g;
		"
		is_good="$(echo "$report" | sed -r "$transform" | bc)"
		if [ "$is_good" -eq 1 ]; then
			echo "good"
			break
		fi
	done
done | wc -l
