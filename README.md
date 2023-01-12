Portfolio_Deposit

- User is able to:
  1- deposit a token,
  2- withdraw a token,
  3- emergency withdraw all tokens,
  4- show list of his tokens with their balances

- Be able to
  1- transfer his deposited tokens for another user on the contract.
  2- support compliant tokens for single transaction deposits using EIP-2612

  - Let's assume that only the owner is able to withdraw,
    so no one has a permission to withdraw it for him to the owner wallet.

  - It is better to reset the set of the token addresses when a user withdraw all their tokens
