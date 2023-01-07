// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Task.sol";
import "forge-std/console.sol";

import {MockERC20} from "./mocks/MockERC20.sol";

contract BaseTaskTest is Test {
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
}

// contract ZeroAddressMintandTxtoTask {}

contract UserMintandDepositToTask is Mock20Token0 {
    function setUp() public override {
        Mock20Token0.setUp();
        console.log("Mock20Token is ready ");
    }

    function testMint() public {
        // user A mint tokens from _0_mockERC20
        MockERC20 _0_Erc20Contract = MockERC20(address(_0_mockERC20));
        mint(_0_Erc20Contract, userA, maxAmountToMint);
        assertEq(_0_Erc20Contract.balanceOf(userA), maxAmountToMint);
        console.log(userA, " minting  ", maxAmountToMint);
        // user A mint tokens from _1_mockERC20
        MockERC20 _1_Erc20Contract = MockERC20(address(_1_mockERC20));
        mint(_1_Erc20Contract, userA, maxAmountToMint);
        assertEq(_1_Erc20Contract.balanceOf(userA), maxAmountToMint);
        console.log(userA, " minting  ", maxAmountToMint);
    }

    function testDeposit() public {
        // user A mint tokens from _0_mockERC20
        MockERC20 _0_Erc20Contract = MockERC20(address(_0_mockERC20));
        mint(_0_Erc20Contract, userA, maxAmountToMint);
        approve(_0_Erc20Contract, userA, address(task), maxAmountToMint);

        bool _0_res = task.deposit(
            address(_0_Erc20Contract),
            userA,
            maxAmountToMint
        );
        uint256 _0_bal = task.balanceAt(0);
        assertEq(maxAmountToMint, _0_bal);
        assertTrue(_0_res);

        // user A mint tokens from _1_mockERC20
        MockERC20 _1_Erc20Contract = MockERC20(address(_1_mockERC20));
        mint(_1_Erc20Contract, userA, maxAmountToMint);
        approve(_1_Erc20Contract, userA, address(task), maxAmountToMint);
        bool _1_res = task.deposit(
            address(_1_Erc20Contract),
            userA,
            maxAmountToMint
        );
        assertTrue(_1_res);
        uint256 _1_bal = task.balanceAt(1);
        assertEq(maxAmountToMint, _1_bal);
    }

    function testDepositWithdraw() public {
        MockERC20 _0_Erc20Contract = MockERC20(address(_0_mockERC20));
        mint(_0_Erc20Contract, userA, maxAmountToMint);
        approve(_0_Erc20Contract, userA, address(task), maxAmountToMint);
        bool _0_res = task.deposit(
            address(_0_Erc20Contract),
            userA,
            maxAmountToMint
        );
        assertTrue(_0_res);
        address _0_tokenAddress = task.at(0);
        vm.prank(userA);
        bool resWith = task.withdraw(_0_tokenAddress);
        assertTrue(resWith);
        console.log("_0_tokenAddress", _0_tokenAddress);
    }

    function testDepositWithdrawAllFromOnlyHisDeposit() public {
        MockERC20 _0_Erc20Contract = MockERC20(address(_0_mockERC20));
        mint(_0_Erc20Contract, userA, maxAmountToMint);
        approve(_0_Erc20Contract, userA, address(task), maxAmountToMint);

        bool _0_res = task.deposit(
            address(_0_Erc20Contract),
            userA,
            maxAmountToMint
        );

        assertTrue(_0_res);
        address _0_tokenAddress = task.at(0);
        vm.prank(userA);
        bool _0_resWith = task.withdraw(_0_tokenAddress);
        assertTrue(_0_resWith);
        console.log("_0_tokenAddress", _0_tokenAddress);
        // user A mint tokens from _1_mockERC20
        MockERC20 _1_Erc20Contract = MockERC20(address(_1_mockERC20));
        mint(_1_Erc20Contract, userA, maxAmountToMint);
        approve(_1_Erc20Contract, userA, address(task), maxAmountToMint);
        bool _1_res = task.deposit(
            address(_1_Erc20Contract),
            userA,
            maxAmountToMint
        );
        // works as my logic of the Task contract
        //since User A withdrawed his _1_mockERC20 token, the set in contract would remove the address.
        address _1_tokenAddress = task.at(0);
        vm.prank(userA);
        bool _1_resWith = task.withdraw(_1_tokenAddress);
        assertTrue(_1_resWith);
        console.log("_1_tokenAddress", _1_tokenAddress);
    }

    function testDepositWithdrawAllFromAllDeposit() public {
        MockERC20 _0_Erc20Contract = MockERC20(address(_0_mockERC20));
        mint(_0_Erc20Contract, userA, maxAmountToMint);
        approve(_0_Erc20Contract, userA, address(task), maxAmountToMint);

        bool _0_res = task.deposit(
            address(_0_Erc20Contract),
            userA,
            maxAmountToMint
        );

        assertTrue(_0_res);
        address _0_tokenAddress = task.at(0);

        // user A mint tokens from _1_mockERC20
        MockERC20 _1_Erc20Contract = MockERC20(address(_1_mockERC20));
        mint(_1_Erc20Contract, userA, maxAmountToMint);
        approve(_1_Erc20Contract, userA, address(task), maxAmountToMint);
        bool _1_res = task.deposit(
            address(_1_Erc20Contract),
            userA,
            maxAmountToMint
        );
        // works as my logic of the Task contract
        //since User A withdrawed his _1_mockERC20 token, the set in contract would remove the address.
        // address _1_tokenAddress = task.at(0);
        vm.prank(userA);
        bool _1_resWith = task.withdrawAll();
        assertTrue(_1_resWith);
        // console.log("_1_tokenAddress", _1_tokenAddress);
    }
}
