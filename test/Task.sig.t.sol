// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "./utility/interface/CheatCodes.sol";
import "../src/Task.sol";
import {MockERC20solmate} from "./mocks/MockERC20solmate.sol";
import {Sig} from "./utility/Sig.sol";

contract BaseTaskSignTest is Test {
    CheatCodes constant cheatCodes =
        CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    // https://github.com/foundry-rs/foundry/blob/master/forge/README.md#cheat-codes
    Task public task;
    MockERC20solmate public _0_mockERC20;
    Sig public sig;

    address internal userA;
    address internal userB;

    uint256 internal amountToMint = 20e18;

    MockERC20solmate public _0_Erc20Contract;
    uint256 internal keyA = 0x981891;
    uint256 internal keyB = 2800;

    function setUp() public virtual {
        userA = cheatCodes.addr(keyA);

        cheatCodes.label(userA, "userA");

        userB = cheatCodes.addr(keyB);

        cheatCodes.label(userB, "userB");
        sig = new Sig();
        cheatCodes.prank(userA);
        task = new Task();

        _0_mockERC20 = new MockERC20solmate("A", "a");
        _0_Erc20Contract = MockERC20solmate(address(_0_mockERC20));
    }
}

contract Signed is BaseTaskSignTest {
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    function setUp() public virtual override {
        BaseTaskSignTest.setUp();
    }

    function testUSign() public {
        bytes32 structHash = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                userA,
                address(task),
                amountToMint,
                0,
                1 days
            )
        );
    }
}
