#!/bin/bash

########################################
# Shuffle deck of cards and store in temp/shuffled
# Distribute 12 cards each to player and dealer
# That's the theoretical max number of cards needed in a single round
########################################
shuffle()
{
	(ls -1 cards/[cdhs]* | cut -d'/' -f2 | sort -R) > temp/shuffled
	sed -n 1,12p temp/shuffled > temp/player
	sed -n 13,25p temp/shuffled > temp/dealer
}

########################################
# Deals 2 cards to player and show dealer's first card
# Variable to keep track of how many cards have been opened and current value
# Also calculate player and dealer's hand value and save in $player/dealer_value
########################################
deal()
{
	echo "Dealer's hand:"
	paste cards/`sed -n '1p' temp/dealer` cards/blank
	dealer_cards_shown=2
	dealer_value=0
	dealer_dynamic_ace=0

	convert_value `sed -n '1p' temp/dealer` $dealer_value dealer
	dealer_card1_value=`echo $value`

	convert_value `sed -n '2p' temp/dealer` $dealer_value dealer
	dealer_card2_value=`echo $value`

	dealer_value=$((dealer_card1_value + dealer_card2_value))

	printf "\n"

	echo "Your hand: "
	paste cards/`sed -n '1p' temp/player` cards/`sed -n '2p' temp/player`
	player_cards_shown=2
	player_value=0
	player_dynamic_ace=0

	convert_value `sed -n '1p' temp/player` $player_value player
	player_card1_value=`echo $value`

	convert_value `sed -n '2p' temp/player` $player_value player
	player_card2_value=`echo $value`

	player_value=$((player_card1_value + player_card2_value))
	echo "Value: $player_value"
}

########################################
# @param   who to hit? player or dealer
#
# @return  update player screen
# @return  update player/dealer value variable
########################################
hit()
{
	if [ "$1" == "player" ]
	then
		player_cards_shown=$((player_cards_shown+1))
		echo "Updated hand: "
		cd cards
		paste `cat ../temp/player | head -n $player_cards_shown | tr '\n' ' '`
		cd ..
		convert_value `sed -n $player_cards_shown'p' temp/player` $player_value player
		player_value=$((player_value + value))
		update_ace player
		echo "Value: $player_value"
	fi

	if [ "$1" == "dealer" ]
	then
		dealer_cards_shown=$((dealer_cards_shown+1))
		convert_value `sed -n $dealer_cards_shown'p' temp/dealer` $dealer_value dealer
		dealer_value=$((dealer_value + value))
		update_ace dealer
	fi
}

########################################
# @param   name of card
# @param   value of current hand - needed to determine if ace should be 1 or 11
# @param   player or dealer?
#
# @return  saves value of card in $value
########################################
convert_value()
{
	face=`echo $1 | cut -d'-' -f2`
	if [ "$face" == "j" ] || [ "$face" == "q" ] || [ "$face" == "k" ]
	then
		value=10
	elif [ "$face" == "a" ]
	then
		ace_test_value=`expr $2 + 11`
		if [ $ace_test_value -gt 21 ]
		then
			value=1
		else
			value=11
			if [ "$3" == "player" ]
			then
				player_dynamic_ace=$((player_dynamic_ace + 1))
			else
				dealer_dynamic_ace=$((dealer_dynamic_ace + 1))
			fi
		fi
	else
		value=`echo $1 | cut -d'-' -f2`
	fi
}

########################################
# @param   player or dealer?
#
# @return  updates $player/dealer_value
# @return  decrements $player/dealer_dynamic_ace
########################################
update_ace()
{
	if [ $1 == "player" ]
	then
		while [ $player_dynamic_ace -gt 0 ] && [ $player_value -gt 21 ]
		do
			player_value=$((player_value - 10))
			player_dynamic_ace=$((player_dynamic_ace - 1))
		done
	else
		while [ $dealer_dynamic_ace -gt 0 ] && [ $dealer_value -gt 21 ]
		do
			dealer_value=$((dealer_value - 10))
			dealer_dynamic_ace=$((dealer_dynamic_ace - 1))
		done
	fi
}

########################################
# Takes no input, automatically compares $player_value and $dealer_value
########################################
compare()
{
	if [ $dealer_value -eq $player_value ]
	then
		echo "Push. Dealer's hand: $dealer_value" && break
	fi

	if [ $dealer_value -lt $player_value ]
        then
                echo "You win! Dealer's hand: $dealer_value" && break
        fi

	if [ $dealer_value -gt $player_value ] && [ $dealer_value -gt 21 ]
        then
                echo "You win! Dealer's hand: $dealer_value" && break
        fi

	if [ $dealer_value -gt $player_value ]
        then
                echo "You lost. Dealer's hand: $dealer_value" && break
        fi
}

replay=yes

while [ "$replay" == "yes" ]
do
	shuffle

	deal

	if [ $dealer_value -eq 21 ]
	then
		echo "You lost. Dealer's hand: 21"
	fi

	if [ $player_value -eq 21 ]
	then
		echo "You win!"
	fi

	while [ $dealer_value -lt 16 ]
	do
		hit dealer
		update_ace dealer
	done

	while [ $dealer_value -eq 16 ] || [ $dealer_value -eq 17 ]
	do
		risklevel=`cat /dev/urandom | tr -dc '0-9' | fold -w 1 | head -n 1`
		if [ $risklevel -lt 2 ]
		then
			hit dealer
			update_ace dealer
		fi
	done

	while [ $dealer_value -eq 18 ] || [ $dealer_value -eq 19 ]
	do
        	risklevel=`cat /dev/urandom | tr -dc '0-9' | fold -w 1 | head -n 1`
        	if [ $risklevel -lt 1 ]
        	then
                	hit dealer
			update_ace dealer
        	fi
	done

	while [ $player_value -le 21 ]
	do
		printf "Hit? y|n: "
		read choice
		if [ "$choice" == "y" ]
		then
			hit player
			update_ace player
		else
			compare
		fi
	done

	if [ $player_value -gt 21 ]
	then
		echo "Bust! Dealer's hand: $dealer_value"
	fi

	printf "\nPlay again? y|n: "
	read choice
	if [ "$choice" == "y" ]
	then
		replay=yes
	else
		echo "Bye!"
		replay=no && exit
	fi
	done
