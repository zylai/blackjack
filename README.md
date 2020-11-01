# Bash Blackjack

A simple blackjack game written in Bash. Tested with Ubuntu 18. Download, create `temp` directory, and execute game.sh.

```
mkdir temp
chmod +x game.sh
./game.sh
```

### Rules

- Whoever gets closest to 21 without going bust wins the round
- No doubling down
- Cards are shuffled at the beginning of each round (no house or player advantage)
- If the player or dealer draws 21 in the initial distribution, they win the round automatically
- If both the player and dealer draw 21 in the initial distribution, the dealer wins
- Ace will take the value of 11 unless that value causes a hand to go bust, then ace will take the value of 1
- The dealer will always draw if their cards' value is 15 or under and will never draw if their cards' value is 20 or over
- At values 16 to 19, the dealer will randomly decide whether or not to draw another card (explained in more detail below)
- If the player goes bust, the player loses the round, regardless of the dealer's hand
- If both the player and dealer ends with the same value, the game is tied ("push")

### Functionality

A standard 52-card deck is used and the deck is shuffled at the beginning of each round (sorry, no house or player advantage here). 12 cards are then assigned to the dealer and the player's pool to draw from, each. This is the maximum theoretical number of cards needed in a round (best case scenario: four aces, four 2s, and three 3s, plus another 3 to go bust). The dealer and player's pool of cards can be seen in `temp/dealer` and `temp/player`, respectively. Two cards are then dealt to the dealer and player. The player can see their own two cards plus one of the dealer's cards. The player will then be prompted on whether they would like to draw another card. They can do this as many times as they like until going bust. 

Meanwhile, a simple algorithm determines whether the dealer will draw another card:

The dealer will always draw if their cards are 15 or under and will never draw if their cards are 20 or over. Outside that range, a random number between 0 and 9 will be generated to determine the dealer's risk level. At values 16 and 17, the dealer will draw if the risk level is 0 or 1 (20% chance). At 18 and 19, the dealer will only draw if the risk level is 0 (10% chance). This risk level is re-generated on every draw. The chances that the dealer will draw two cards in a row when their hand is above 15 is extremely low.
