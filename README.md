# Bash Blackjack

Fairly standard but watered down version of Blackjack with a few special rules to keep it simple. Written in Bash and can be played in a terminal window. Tested with Ubuntu 18. Download, create `temp` directory (only on first run, this folder is needed to store the values of the shuffled deck and the dealer and player's pool of cards), and execute game.sh.

```
mkdir temp
chmod +x game.sh
./game.sh
```

### Deviation from normal rules

- One deck of cards is used and cards are shuffled at the beginning of each round (no house or player advantage)
- If either the player or dealer draws 21 in the initial distribution, they win the round automatically
- If both the player and dealer draw 21 in the initial distribution, the dealer wins
- The dealer will always draw if their cards' value is 15 or under and will never draw if their cards' value is 20 or over
- At values 16 to 19, the dealer will randomly decide whether or not to draw another card (explained in more detail below)
- If the player goes bust, the player loses the round, regardless of the dealer's hand

### Functionality

One standard 52-card deck is used and the deck is shuffled at the beginning of each round (sorry, no house or player advantage here). 12 cards are then assigned to the dealer and the player's pool to draw from, each. This is the maximum theoretical number of cards needed in a round (best case scenario: four aces, four 2s, and three 3s, plus another 3 to go bust). The dealer and player's pool of cards can be seen in `temp/dealer` and `temp/player`, respectively. Two cards are then dealt to the dealer and player. The player can see their own two cards plus one of the dealer's cards. The player will then be prompted on whether they would like to draw another card. They can do this as many times as they like until going bust. If the player goes bust, they automatically lose the round.

Meanwhile, a simple algorithm determines whether the dealer will draw another card:

The dealer will always draw if their cards are 15 or under and will never draw if their cards are 20 or over. Outside that range, a random number between 0 and 9 will be generated to determine the dealer's risk level. At values 16 and 17, the dealer will draw if the risk level is 0 or 1 (20% chance). At 18 and 19, the dealer will only draw if the risk level is 0 (10% chance). This risk level is re-generated on every draw. The chances that the dealer will draw two cards in a row when their hand is above 15 is extremely low. The dealer will not automatically lose the round after going bust.

A `dynamic_ace` function determines whether ace will take the value of 1 or 11. Ace will always take the value of 11 unless that value causes a hand to go bust. In that case, ace will take the value of 1. This is re-calculated after each additional card is drawn. A counter keeps track of how many aces a hand has and compares it to how many times the ace has turned from from "soft" to "hard". 

When the player declines to be hit with another card, the player and dealer's cards will be compared and whoever's hand is closest to 21 wins the round. The value of the dealer's hand will then be revealed to the player.

### Known Issues

- Round does not end properly if player gets dealt a 21 for their first two cards
	- Game will continue to ask whether the player would like to draw another card
- Dealer's card value not calculating correctly if hand contains an ace
	- This results in some rounds whether the dealer's hand is below 16. 
	- Seems to be a bug related to the `dynamic_ace` function

### Roadmap

- Add a bank to allow betting
- Show simple statistics at the end of game
- Allow double down
- Refactor code
	- Use return statements in functions instead of `echo`
		- I did not know that it is possible to return things in a Bash function when I originally wrote this in 2017
	- Draw cards within main `game.sh` script instead of `cat`ing from `./cards`

### Miscellaneous

Playing cards ASCII art from https://www.asciiart.eu/miscellaneous/playing-cards

```
 _____
|A .  | _____
| /.\ ||A ^  | _____
|(_._)|| / \ ||A _  | _____
|  |  || \ / || ( ) ||A_ _ |
|____A||  .  ||(_'_)||( v )|
       |____A||  |  || \ / |
              |____A||  .  |
                     |____A|
```
