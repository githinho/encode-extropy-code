# Homework 13 - Audit

## BrokenSea Instructions

⛽🏌️This is a gas-golfed version of Zora v3's Offers module! 🤩
A bidder can call createBid to bid on the NFT of their dreams.
💰 The NFT owner can call acceptBid to accept one of these on-chain bids.
🤝 Assets exchange hands. 😤 What could possibly go wrong?

### Audit for BrokenSea

There is problem with line [73 `transferFrom`](https://github.com/githinho/encode-extropy-code/blob/a1300b4e18b516a57e77aaa05810c11ea2cafec3/audit/homework13/BrokenSea.sol#L73). It's recommended to use [`safeTransferFrom`](https://github.com/transmissions11/solmate/blob/d155ee8d58f96426f57c015b34dee8a410c1eacc/src/tokens/ERC721.sol#L126) Which will check if the receiving address is EoA or a contract that can handle ERC721 tokens. Without this check for `IERC721Receiver`, tokens will be locked forever in the contract.

## DogCoinGame Instructions

"DogCoinGame is a game where players are added to the contract via the addPlayer function, they need to send 1 ETH to play.
Once 200 players have entered, the UI will be notified by the startPayout event, and will pick 100 winners which will be added to the winners array, the UI will then call the payout function to pay each of the winners.
The remaining balance will be kept as profit for the developers."

Write out the main points that you would include in an audit.

### Audit for DogCoinGame

This audit is completed on only one file and one contract without checking the imported files: [https://github.com/githinho/encode-extropy-code/blob/a1300b4e18b516a57e77aaa05810c11ea2cafec3/audit/homework13/DogCoinGame.sol](https://github.com/githinho/encode-extropy-code/blob/a1300b4e18b516a57e77aaa05810c11ea2cafec3/audit/homework13/DogCoinGame.sol).

#### Critical

- Function [`addWinner`](https://github.com/githinho/encode-extropy-code/blob/a1300b4e18b516a57e77aaa05810c11ea2cafec3/audit/homework13/DogCoinGame.sol#L25) is public so anybody can call it and the address to winners list. Contract should implement [`Ownable`](https://docs.openzeppelin.com/contracts/2.x/api/ownership). This function should modifier `onlyOwner` to limit scope to owner.
- Also, function [`addWinner`](https://github.com/githinho/encode-extropy-code/blob/a1300b4e18b516a57e77aaa05810c11ea2cafec3/audit/homework13/DogCoinGame.sol#L25) allows adding any arbitrary address as winner even if the address didn't send the required amount to participate in the game. This enables easy way of stealing the funds from the rest of the players that participated in the game. Suggestion is to use index of the player in the array `players` for adding the address to `winners`.

```solidity
    function addWinner(uint256 playerIndex) public {
        winners.push(players[playerIndex]);
    }
```

- Function [`payWinners`](https://github.com/githinho/encode-extropy-code/blob/a1300b4e18b516a57e77aaa05810c11ea2cafec3/audit/homework13/DogCoinGame.sol#L36) should be private. With the current implementation, anybody can call it with desired `_amount` value and payout all address in winners list multiple times.
- At line [37 for loop](https://github.com/githinho/encode-extropy-code/blob/a1300b4e18b516a57e77aaa05810c11ea2cafec3/audit/homework13/DogCoinGame.sol#L37) should have exit condition like this: `i < winners.length`. Current implementation would cause an error index out of bounds for the last case: `i = winners.length`.

#### Major

- Function [`addPlayer`](https://github.com/githinho/encode-extropy-code/blob/a1300b4e18b516a57e77aaa05810c11ea2cafec3/audit/homework13/DogCoinGame.sol#L15) has incorrect logic. Variable `numberPlayers` is incremented even if the player is not added to game.

- [Sending Ether](https://github.com/githinho/encode-extropy-code/blob/a1300b4e18b516a57e77aaa05810c11ea2cafec3/audit/homework13/DogCoinGame.sol#L38) to winner is not done in the safe manner. There should be a check if the send action was successful. Some winners could be skipped if the call has failed. Suggestion for checking send return value:

```solidity
    bool sent = winner.send(_amount);
    require(sent, "Failed to send Ether");
```

#### Informal

- [`event stratPayout`](https://github.com/githinho/encode-extropy-code/blob/a1300b4e18b516a57e77aaa05810c11ea2cafec3/audit/homework13/DogCoinGame.sol#L11) should be named using the CapWords style, see [guidelines](https://docs.soliditylang.org/en/v0.8.15/style-guide.html#event-names).
- This contract should not implement `ERC20` because it is not using any functionality provided by it. Also, remove the import of the same.
- Lock the version of Solidity to fix version.
- Scenario what to do after the payout is not defined. It would be nice to cleanup variables if they won't be used anymore.
- [Loop for paying winner](https://github.com/githinho/encode-extropy-code/blob/a1300b4e18b516a57e77aaa05810c11ea2cafec3/audit/homework13/DogCoinGame.sol#L37) could be problematic if the array of winners gets big. Think about redefining the solution and using pull pattern. This can be done by adding function `claim` where user is going to claim only his reward. Change like this would require a change to restrict the users from claiming the reward multiple times, for example remove from winners array after the reward is claimed.
