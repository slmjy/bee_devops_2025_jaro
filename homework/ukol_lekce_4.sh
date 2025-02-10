DIRECTORY="$HOME/homework"
FILE="$DIRECTORY/answers.txt"

mkdir -p "$DIRECTORY"

if [ ! -d "$DIRECTORY" ]; then
    echo "Error: Directory was not created!"
    exit 1
fi

touch -f "$FILE"

PATH_SOFT="/tmp/answer_soft_hw"

if [ -e "${PATH_SOFT}" ]; then
	if [ -L ${PATH_SOFT} ]; then
		echo "Soft link is already exists."
	else
	echo "Soft link is already exists but it is not a link."
	rm -f "$PATH_SOFT"
	ln -s "$FILE" "$PATH_SOFT"
	fi
else
	ln -s "$FILE" "$PATH_SOFT"
	echo "Soft link was created: $PATH_SOFT"
fi

PATH_HARD="/tmp/answer_hard_hw"

if [ -e "${PATH_HARD}" ]; then
	echo "Hard link is already exists."
else
	ln "$FILE" "$PATH_HARD"
	echo "Hard link was created: $PATH_HARD"
fi


echo
echo "Hello human. Please sit down and answer the following questions."
echo

declare -a ANSWERS
read -p "Are you excited? " ANSWERS[0]
echo "---------------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------"

read -p "What is your name? " ANSWERS[1]
echo "---------------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------"

read -p "What is your goal in this course? " ANSWERS[2]
echo "---------------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------"

read -p "What is your the most favorite command in Linux? " ANSWERS[3]
echo "---------------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------"

read -p "What do you think about the Linux as a OS? Do you like it? " ANSWERS[4]
echo "---------------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------"

read -p "Would you like to do DevOps in future? " ANSWERS[5]
echo "---------------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------"

printf "%s\n" "${ANSWERS[@]}" >> "$FILE"
printf "\n" >>  "$FILE"
printf "\n" >>  "$FILE"

echo "---------------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------"
echo "Your answers have been saved to answers.txt."


