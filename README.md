# SoundChain


WARNING: Not yet well tested!


ERC23Interface.sol is simple ERC23 interface used on this contract.

ReceiverInterface.sol is ERC23 compatible receiver interface.

SOCH-Token.sol is SOCH token contract.

SoundToken.sol is contract that will be deployed on Soundtrack token creation.

MasterContract.sol is contract that will calculate payments, manage token deployment and licenses.


## How it will work

Soundtrack copyrights owner can create a license that will help him to redistribute copyrights by tokens.
When license is created by MasterContract it will also deploy SoundToken token contract with choosen token supply/monetary policy.

Soundtrack must be assigned to this license with a choosen Per Play price.

This license can also support different soundtracks with different prices but connected with each other by mutual SoundToken that will redistribute dividends from Per Play payments to rights holders.

When user will listen a track contract call may happend with given probability (for example one call per 100 listens).

It means that there will be 1% chance that call will occur when user will listen this track. Contract call will contain a number of listens of this track, that need to be added (100 in this variant). It will help to optimize contract calls (one call for 100 listens instead of 100 calls to add 100 listens).

When MasterContract is called by track listening it will send SOCH to token contract associated with listened track where token holders can claim their SOCH.

I'm also thinking about scheme where mastercontract will calculate listens without immediately paying SOCH to token contracts. It will allow to trigger payments to licensed token contracts manually (once a month/ week/ day) and also optimize gas usage.
