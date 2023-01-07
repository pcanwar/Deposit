// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Task.sol";
import "forge-std/console.sol";

import {MockERC20} from "./mocks/MockERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BaseTaskTest is Test {
    using SafeMath for uint256;

    Task public task;
    MockERC20 public _0_mockERC20;
    MockERC20 public _1_mockERC20;
    MockERC20 public _2_mockERC20;
    uint256 maxAmountToMint = 20e18;

    address internal userA;
    address internal userB;
    address internal userC;

    function setUp() public virtual {
        userA = address(uint160(uint256(keccak256(abi.encodePacked("userA")))));
        vm.label(userA, "userA");

        userB = address(uint160(uint256(keccak256(abi.encodePacked("userB")))));
        vm.label(userB, "userB");

        userC = address(uint160(uint256(keccak256(abi.encodePacked("userC")))));
        vm.label(userC, "userC");
        // userA deploys task contract
        // it can be dev more
        vm.prank(userA);
        task = new Task();

        _0_mockERC20 = new MockERC20("A", "a");
        _1_mockERC20 = new MockERC20("B", "b");
        _2_mockERC20 = new MockERC20("B", "b");

        console.log("userA", userA);
        console.log("userB", userB);
        console.log("userC", userC);
        console.log(" owner  ", task.owner());
        console.log(" task address  ", address(task));
    }
}

contract Mock20Token0 is BaseTaskTest {
    function setUp() public virtual override {
        BaseTaskTest.setUp();
        console.log("Test mint and check the balnce");
    }

    function mint(
        MockERC20 erc20ContractAddress,
        address to,
        uint256 amount
    ) internal {
        vm.prank(to);
        erc20ContractAddress.mint(to, amount);
    }

    function approve(
        MockERC20 erc20ContractAddress,
        address caller,
        address spender,
        uint256 amount
    ) internal {
        vm.prank(caller);
        erc20ContractAddress.approve(spender, amount);
    }

    function transfer(
        MockERC20 erc20ContractAddress,
        address from,
        address to,
        uint256 amount
    ) public returns (bool res) {
        vm.prank(from);
        res = erc20ContractAddress.transfer(to, amount);
    }

    function transferFromWithoutCaller(
        MockERC20 erc20ContractAddress,
        address from,
        address to,
        uint256 amount
    ) internal returns (bool res) {
        res = erc20ContractAddress.transferFrom(from, to, amount);
    }

    function transferFromCaller(
        MockERC20 erc20ContractAddress,
        address caller,
        address from,
        address to,
        uint256 amount
    ) internal returns (bool res) {
        vm.prank(caller);
        res = erc20ContractAddress.transferFrom(from, to, amount);
    }

    function itDepositedCorrectly(address user, uint256 amount)
        internal
        returns (bool res)
    {
        MockERC20 _0_Erc20Contract = MockERC20(address(_0_mockERC20));

        mint(_0_Erc20Contract, user, amount);
        assertEq(_0_Erc20Contract.balanceOf(user), amount);
        console.log(user, " minting  ", amount);
        approve(_0_Erc20Contract, user, address(task), amount);
        res = task.deposit(address(_0_Erc20Contract), user, amount);
    }
}

contract UserMintandDeposWithFuzz is Mock20Token0 {
    function setUp() public override {
        Mock20Token0.setUp();
        console.log("User mints and deposit with Fuzz");
    }

    function testMintDepositWithFuzz(uint16 _amountFuzz) public {
        vm.assume(_amountFuzz != 0);
        require(_amountFuzz != 0);
        MockERC20 _0_Erc20Contract = MockERC20(address(_0_mockERC20));

        bool res = itDepositedCorrectly(userA, _amountFuzz);
        assertTrue(res);
        assertEq(_amountFuzz, task.balanceAt(address(_0_Erc20Contract)));
    }

    // In this case assume is not a great fit, so you should bound inputs manually
    function testMintDepositWithBoundFuzz(uint256 _amountFuzz) public {
        _amountFuzz = bound(_amountFuzz, 200e18, 200e18);
        require(_amountFuzz >= 200e18 && _amountFuzz <= 200e18);

        MockERC20 _0_Erc20Contract = MockERC20(address(_0_mockERC20));

        bool res = itDepositedCorrectly(userA, _amountFuzz);
        assertTrue(res);
        assertEq(_amountFuzz, task.balanceAt(address(_0_Erc20Contract)));
    }

    function testFailedMintDepositWithBoundFuzz(uint256 _amountFuzz) public {
        MockERC20 _0_Erc20Contract = MockERC20(address(_0_mockERC20));

        bool res = itDepositedCorrectly(userA, _amountFuzz);
        assertTrue(!res);
        assertGt(_amountFuzz, task.balanceAt(address(_0_Erc20Contract)));
    }
}
