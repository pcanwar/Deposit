No files changed, compilation skipped

Running 1 test for test/Task.sig.t.sol:SignedExpiredDeadline
[32m[PASS][0m testExpiredDeadline() (gas: 39087)
Test result: [32mok[0m. 1 passed; 0 failed; finished in 2.07ms

Running 1 test for test/Task.sig.t.sol:Signed
[32m[PASS][0m testUSign() (gas: 81580)
Test result: [32mok[0m. 1 passed; 0 failed; finished in 1.72ms

Running 1 test for test/Task.t.sol:CheckFunctions
[32m[PASS][0m testFindBalanceAt() (gas: 317661)
Test result: [32mok[0m. 1 passed; 0 failed; finished in 5.71ms

Running 5 tests for test/Task.t.sol:UserMintandDepositToTask
[32m[PASS][0m testDepositWithdraw() (gas: 192477)
[32m[PASS][0m testDepositWithdrawAllFromAllDeposit() (gas: 353215)
[32m[PASS][0m testDepositWithdrawAllFromOnlyHisDeposit() (gas: 373386)
[32m[PASS][0m testMint() (gas: 117873)
[32m[PASS][0m testTwoDepositsAndBalanceAt() (gas: 333256)
Test result: [32mok[0m. 5 passed; 0 failed; finished in 3.61ms

Running 1 test for test/Task.negitive.t.sol:HasNotEnoughInBlalancetoWithdrawToken
[32m[PASS][0m testFailedWithdrawMoreThanBalance() (gas: 44967)
Test result: [32mok[0m. 1 passed; 0 failed; finished in 1.48ms

Running 1 test for test/Task.negitive.t.sol:HasNoOwnershipToWithdraw
[32m[PASS][0m testWithdrawWithNoOwnership() (gas: 81980)
Test result: [32mok[0m. 1 passed; 0 failed; finished in 50.58ms

Running 1 test for test/Task.fuzz.t.sol:UserHasNoEnoughToWithdrawWithFuzz
[32m[PASS][0m testFailedToWithdrawWithBoundFuzz(uint256,uint256) (runs: 256, μ: 167336, ~: 220920)
Test result: [32mok[0m. 1 passed; 0 failed; finished in 117.87ms

Running 4 tests for test/Task.fuzz.t.sol:UserMintandDeposWithFuzz
[32m[PASS][0m testFailedMintDepositWithFuzz(uint256) (runs: 256, μ: 183538, ~: 191704)
[32m[PASS][0m testFailedNotOwnerWithFuzz(address,uint256) (runs: 256, μ: 180815, ~: 181400)
[32m[PASS][0m testMintDepositWithBoundFuzz(uint256) (runs: 256, μ: 179267, ~: 179383)
[32m[PASS][0m testMintDepositWithFuzz(uint16) (runs: 256, μ: 176985, ~: 176985)
Test result: [32mok[0m. 4 passed; 0 failed; finished in 158.00ms

Running 1 test for test/Task.fuzz.t.sol:UserWithdrawWithFuzz
[32m[PASS][0m testMintWithdrawWithBoundFuzz(uint256,uint256) (runs: 256, μ: 212284, ~: 212473)
Test result: [32mok[0m. 1 passed; 0 failed; finished in 193.41ms
| src/Task.sol:Task contract | | | | | |
|---------------------------------|-----------------|-------|--------|--------|---------|
| Deployment Cost | Deployment Size | | | | |
| 1658856 | 8293 | | | | |
| Function Name | min | avg | median | max | # calls |
| at | 757 | 757 | 757 | 757 | 3 |
| balanceAt(address)(uint256) | 840 | 1125 | 840 | 2840 | 7 |
| balanceAt(uint256)(uint256) | 1798 | 1798 | 1798 | 1798 | 2 |
| deposit | 8544 | 87698 | 98272 | 122839 | 18 |
| owner | 318 | 318 | 318 | 318 | 14 |
| withdraw(address)(bool) | 22083 | 22083 | 22083 | 22083 | 3 |
| withdraw(address,uint256)(bool) | 649 | 9460 | 987 | 26746 | 3 |
| withdrawAll | 44187 | 44187 | 44187 | 44187 | 1 |

| test/mocks/MockERC20.sol:MockERC20 contract |                 |       |        |       |         |
| ------------------------------------------- | --------------- | ----- | ------ | ----- | ------- |
| Deployment Cost                             | Deployment Size |       |        |       |         |
| 1069799                                     | 6302            |       |        |       |         |
| Function Name                               | min             | avg   | median | max   | # calls |
| DOMAIN_SEPARATOR                            | 352             | 352   | 352    | 352   | 2       |
| allowance                                   | 778             | 868   | 778    | 2778  | 22      |
| approve                                     | 24603           | 24603 | 24603  | 24603 | 17      |
| balanceOf                                   | 539             | 539   | 539    | 539   | 11      |
| mint                                        | 2858            | 42943 | 46658  | 46658 | 21      |
| permit                                      | 720             | 26016 | 26016  | 51313 | 2       |
| transfer                                    | 18330           | 19093 | 18330  | 22912 | 6       |
| transferFrom                                | 4540            | 20633 | 22060  | 27575 | 18      |

| test/utility/Sig.sol:Sig contract |                 |      |        |      |         |
| --------------------------------- | --------------- | ---- | ------ | ---- | ------- |
| Deployment Cost                   | Deployment Size |      |        |      |         |
| 630696                            | 3179            |      |        |      |         |
| Function Name                     | min             | avg  | median | max  | # calls |
| getDataHash                       | 3344            | 3344 | 3344   | 3344 | 2       |

| test/utility/Timestamp.sol:Timestamp contract |                 |     |        |     |         |
| --------------------------------------------- | --------------- | --- | ------ | --- | ------- |
| Deployment Cost                               | Deployment Size |     |        |     |         |
| 357740                                        | 1764            |     |        |     |         |
| Function Name                                 | min             | avg | median | max | # calls |
| dayForward                                    | 826             | 826 | 826    | 826 | 1       |
