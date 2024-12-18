# grid_rows=70
# grid_cols=70
# first_n=1024
# input=day18/input

grid_rows=6
grid_cols=6
first_n=12
input=day18/example

declare -A corrupts
declare -A cost_past
declare -A open_set
declare -A came_from
declare -A path_taken

open_set["0,0"]=true
cost_past["0,0"]=$(( 0 ))

function get_cost_next() {
	local x y
	IFS=, read x y <<< $1
	echo $(( grid_cols + grid_rows - x - y ))
}

function get_cost() {
	local x y
	IFS=, read x y <<< $1
	local past=${cost_past["$x,$y"]}
	local next=$(get_cost_next "$x,$y")
	echo $(( past + next ))
}

function draw() {
	for y in $(seq 0 $grid_rows); do
		for x in $(seq 0 $grid_cols); do
			if [[ -n ${corrupts["$x,$y"]:-} ]]; then
				echo -n "#"
			elif [[ -n ${path_taken["$x,$y"]:-} ]]; then
				echo -n "O"
			else
				echo -n "."
			fi
		done
		echo
	done
}

while IFS=, read x y; do
	corrupts["$x,$y"]=1
done < <( cat $input | head -n $first_n )

while true; do
	current=$(for key in ${!open_set[@]}; do
		echo $(get_cost $key) $key
	done | sort -n | col2 | head -n 1)
	if [[ -z $current ]]; then
		break
	fi
	IFS=, read -r x y <<< $current
	unset open_set["$x,$y"]
	if [[ $x -eq $grid_cols && $y -eq $grid_rows ]]; then
		break
	fi
	current_past_cost=${cost_past["$x,$y"]}
	for dx in -1 0 1; do
		for dy in -1 0 1; do
			if [[ $dx -eq 0 && $dy -eq 0 ]]; then
				continue
			fi
			if [[ $dx -ne 0 && $dy -ne 0 ]]; then
				continue
			fi
			local_x=$(( x + dx ))
			local_y=$(( y + dy ))
			if [[ $local_x -lt 0 || $local_x -gt $grid_cols ]]; then
				continue
			fi
			if [[ $local_y -lt 0 || $local_y -gt $grid_rows ]]; then
				continue
			fi
			if [[ -n ${corrupts["$local_x,$local_y"]:-} ]]; then
				continue
			fi
			past_cost=$(( current_past_cost + 1 ))
			next_cost=$(get_cost_next "$local_x,$local_y")
			this_past_cost=${cost_past["$local_x,$local_y"]:-}
			if [[ -z $this_past_cost || $past_cost -lt $this_past_cost ]]; then
				cost_past["$local_x,$local_y"]=$past_cost
				if [[ -z ${open_set["$local_x,$local_y"]:-} ]]; then
					open_set["$local_x,$local_y"]=true
				fi
				came_from["$local_x,$local_y"]=$x,$y
			fi
		done
	done
done

x=$grid_cols
y=$grid_rows
path_taken_length=0
while [[ $x -ne 0 || $y -ne 0 ]]; do
	IFS=, read x y <<< ${came_from["$x,$y"]}
	path_taken["$x,$y"]=1
	path_taken_length=$(( path_taken_length + 1 ))
done

draw
echo "Path taken length: $path_taken_length"
