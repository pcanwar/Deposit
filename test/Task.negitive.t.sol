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

    address internal userA;
    address internal userB;
    address internal userC;

    uint256 internal maxAmountToMint = 20e18;

    MockERC20 public _0_Erc20Contract;

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

        _0_Erc20Contract = MockERC20(address(_0_mockERC20));

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

    function hasItDepositedCorrectly(address user, uint256 amount)
        internal
        returns (bool res)
    {
        mint(_0_Erc20Contract, user, amount);
        assertEq(_0_Erc20Contract.balanceOf(user), amount);
        console.log(user, " minting  ", amount);
        approve(_0_Erc20Contract, user, address(task), amount);
        res = task.deposit(address(_0_Erc20Contract), user, amount);
    }

    function hasItWithdrawedCorrectly(
        address caller,
        address user,
        uint256 amountToDeposit,
        uint256 amountToWithdraw
    ) internal returns (bool res) {
        bool _res = hasItDepositedCorrectly(user, amountToDeposit);
        assertTrue(_res);
        vm.prank(caller);
        vm.expectRevert("Ownable: caller is not the owner");
        res = task.withdraw(address(_0_Erc20Contract), amountToWithdraw);
        if (!res) {
            assertTrue(!res, "Caller is not the owner ");
        }
    }
}

contract HasNotEnoughInBlalancetoWithdrawToken is Mock20Token0 {
    uint256 private amountToWithdraw = 7e18;
    uint256 private withdrawedAmount = 10e18;

    function setUp() public override {
        Mock20Token0.setUp();

        hasItDepositedCorrectly(userA, withdrawedAmount);
        console.log("User has no enough to withdraw");
    }

    function hasReversted(
        address _caller,
        address _user,
        uint256 _amountToDeposit,
        uint256 _amountToWithdraw,
        string memory _expRevert
    ) internal {
        vm.expectRevert(abi.encodePacked(_expRevert));
        bool res = hasItWithdrawedCorrectly(
            _caller,
            _user,
            _amountToDeposit,
            _amountToWithdraw
        );
        assertTrue(res);
    }

    function testFailedWithdrawMoreThanBalance() public {
        hasReversted({
            _caller: userA,
            _user: userA,
            _amountToDeposit: withdrawedAmount,
            _amountToWithdraw: amountToWithdraw,
            _expRevert: "Transfer amount exceeds balance"
        });
    }
}

contract HasNoOwnershipToWithdraw is Mock20Token0 {
    uint256 private amountToWithdraw = 7e18;
    uint256 private withdrawedAmount = 10e18;

    function setUp() public override {
        Mock20Token0.setUp();

        hasItDepositedCorrectly(userA, withdrawedAmount);
        console.log("User has no enough to withdraw");
    }

    function testWithdrawWithNoOwnership() public {
        bool res = hasItWithdrawedCorrectly({
            caller: userB,
            user: userA,
            amountToDeposit: maxAmountToMint,
            amountToWithdraw: withdrawedAmount
        });
        assertTrue(!res, "Error: caller is not the owner");
    }
}
