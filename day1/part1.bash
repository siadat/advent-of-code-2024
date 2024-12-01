cat input | awk '{print $1}' | sort -n > /tmp/sorted1
cat input | awk '{print $2}' | sort -n > /tmp/sorted2

paste -d- /tmp/sorted1 /tmp/sorted2 | while read -r line; do
	echo "$line" | bc | perl -pe 's/^-//'
done | paste -sd+ | bc
