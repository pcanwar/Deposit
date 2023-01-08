// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "./utility/interface/CheatCodes.sol";
import "../src/Task.sol";
import {MockERC20} from "./mocks/MockERC20.sol";
import {Sig} from "./utility/Sig.sol";

contract BaseTaskSignTest is Test {
    CheatCodes constant cheatCodes =
        CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    // https://github.com/foundry-rs/foundry/blob/master/forge/README.md#cheat-codes
    Task public task;
    MockERC20 public _0_mockERC20;
    Sig public sig;

    address internal userA;
    address internal userB;

    uint256 internal amountToMint = 20e18;

    MockERC20 public _0_Erc20Contract;
    uint256 internal keyA = 1800;
    uint256 internal keyB = 2800;

    function setUp() public virtual {
        userA = cheatCodes.addr(keyA);

        cheatCodes.label(userA, "userA");

        userB = cheatCodes.addr(keyB);

        cheatCodes.label(userB, "userB");
        sig = new Sig();
        cheatCodes.prank(userA);
        task = new Task();

        _0_mockERC20 = new MockERC20("A", "a");
        _0_Erc20Contract = MockERC20(address(_0_mockERC20));
    }
}

contract Sign is BaseTaskSignTest {
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    function setUp() public virtual override {
        BaseTaskSignTest.setUp();
    }

    function mint(
        MockERC20 erc20ContractAddress,
        address to,
        uint256 amount
    ) internal {
        cheatCodes.prank(to);
        erc20ContractAddress.mint(to, amount);
    }

    function sign() public returns (bool) {
        // value;

        bytes32 dataHash = sig._getDataHash(
            userA,
            address(task),
            amountToMint,
            0,
            1 days
        );
        // bytes32 hash = keccak256(abi.encodePacked(uint16(0x1901), dataHash));
        (uint8 v, bytes32 r, bytes32 s) = cheatCodes.sign(keyA, dataHash);
        address _signer = sig.run(dataHash, v, r, s);
        require(_signer == userA, "Invalid Signature");
        // console.log("Test result", _signer == signer);
        // console.log("Test _signer", _signer);
        // console.log("Test signer", signer);
        task.deposits(
            address(_0_Erc20Contract),
            userA,
            address(task),
            amountToMint,
            1 days,
            v,
            r,
            s
        );
        assertEq(
            _0_Erc20Contract.allowance(userA, address(task)),
            amountToMint
        );
        return _signer == userA;
    }

    function signForPermit(
        // MockERC20 erc20ContractAddress,
        uint256 privateKey,
        address signer,
        address spender,
        uint256 value,
        uint256 nonce,
        uint256 deadline
    ) public {
        bytes32 dataHash = sig.getDataHash(
            signer,
            spender,
            value,
            nonce,
            deadline
        );
        (uint8 v, bytes32 r, bytes32 s) = cheatCodes.sign(privateKey, dataHash);
        address _signer = sig.run(dataHash, v, r, s);
        require(_signer == signer, "Invalid Signature");
        _0_Erc20Contract.permit(
            userA,
            address(task),
            amountToMint,
            1 days,
            v,
            r,
            s
        );
        task.deposits(
            address(_0_Erc20Contract),
            userA,
            address(task),
            amountToMint,
            1 days,
            v,
            r,
            s
        );
    }

    function testSig() public {
        bool istu = sign();
        assertTrue(istu, "address are not the same");
    }

    function testSignForPermit() public {
        mint(_0_Erc20Contract, userA, amountToMint);
        // (uint8 v, bytes32 r, bytes32 s) = signForPermit(
        //     // _0_Erc20Contract,
        //     keyA,
        //     userA,
        //     address(task),
        //     amountToMint,
        //     0,
        //     1 days
        // );

        // _0_Erc20Contract.permit(
        //     userA,
        //     address(task),
        //     amountToMint,
        //     1 days,
        //     v,
        //     r,
        //     s
        // );
    }
}
