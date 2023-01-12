// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "./utility/interface/CheatCodes.sol";
import "../src/Task.sol";
import {MockERC20} from "./mocks/MockERC20.sol";

import {Sig} from "./utility/Sig.sol";
import {Timestamp} from "./utility/Timestamp.sol";

contract BaseTaskSignTest is Test {
    CheatCodes constant cheatCodes =
        CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    // https://github.com/foundry-rs/foundry/blob/master/forge/README.md#cheat-codes
    string name = "A";
    Timestamp public timestamp;
    Task public task;
    MockERC20 public _0_mockERC20;
    Sig public sig;

    bytes32 public DOMAIN_SEPARATOR; //=
    // keccak256(
    //     abi.encode(
    //         keccak256(
    //             "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    //         ),
    //         keccak256(bytes("A")),
    //         keccak256(bytes("1")),
    //         1,
    //         address(task)
    //     )
    // );

    address internal userA;
    address internal userB;

    uint256 internal amountToMint = 20e18;

    MockERC20 public _0_Erc20Contract;
    uint256 internal keyA;
    uint256 internal keyB = 2800;

    function setUp() public virtual {
        keyA = 0x2023;
        userA = vm.addr(keyA);
        vm.chainId(1);

        cheatCodes.label(userA, "userA");

        userB = cheatCodes.addr(keyB);

        cheatCodes.label(userB, "userB");
        cheatCodes.prank(userA);
        task = new Task();
        timestamp = new Timestamp();
        _0_mockERC20 = new MockERC20(name, "a");
        _0_Erc20Contract = MockERC20(address(_0_mockERC20));
        sig = new Sig(_0_Erc20Contract.DOMAIN_SEPARATOR());
    }
}

contract Signed is BaseTaskSignTest {
    function setUp() public virtual override {
        BaseTaskSignTest.setUp();
    }

    function sign() public {
        Sig.Permit memory permit = Sig.Permit({
            owner: userA,
            spender: address(task),
            value: amountToMint,
            nonce: 0,
            deadline: 9 days
        });

        bytes32 dataHash = sig.getDataHash(permit);
        // bytes32 h = keccak256(abi.encodePacked(dataHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(keyA, dataHash);
        // address _signer = sig.run(h, v, r, s);
        // require(_signer == userA, "Invalid Signature");
        // console.log("Test result", _signer == _signer);
        // console.log("Test _signeA", _signer);
        // console.log("Test signerB", userA);

        _0_Erc20Contract.permit(
            permit.owner,
            permit.spender,
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );

        emit log_named_uint(
            "allows ",
            _0_Erc20Contract.allowance(userA, address(task))
        );
        assertEq(
            _0_Erc20Contract.allowance(userA, address(task)),
            amountToMint
        );
    }

    function testUSign() public {
        sign();
    }
}

contract SignedExpiredDeadline is BaseTaskSignTest {
    function setUp() public virtual override {
        BaseTaskSignTest.setUp();
    }

    function expiredSignature() public {
        Sig.Permit memory permit = Sig.Permit({
            owner: userA,
            spender: address(task),
            value: amountToMint,
            nonce: 0,
            deadline: 11 days
        });

        bytes32 dataHash = sig.getDataHash(permit);
        // bytes32 h = keccak256(abi.encodePacked(dataHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(keyA, dataHash);

        // after a month run the tx
        timestamp.dayForward(30);
        vm.expectRevert("ERC20Permit: expired deadline");
        _0_Erc20Contract.permit(
            permit.owner,
            permit.spender,
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );

        emit log_named_uint(
            "allows ",
            _0_Erc20Contract.allowance(userA, address(task))
        );
        assertLe(
            _0_Erc20Contract.allowance(userA, address(task)),
            amountToMint
        );
    }

    function testExpiredDeadline() public {
        expiredSignature();
    }
}
