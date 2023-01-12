// SPDX-License-Identifier: UNLICENSED

/// @custom:test-contacts that works with time ipcanw@gmail.com
/// Forward block.timestamp forward by a given number

pragma solidity >=0.8.11;

import {DSTest, Vm} from "forge-std/Test.sol";

contract Timestamp is DSTest {
    Vm internal immutable vm = Vm(HEVM_ADDRESS);

    function dayForward(uint256 num) external returns (uint256 targetTime) {
        targetTime = (block.timestamp + 1 days) * num;
        vm.warp(targetTime);
    }

    function secondForward(uint256 num) external {
        uint256 targetTime = (block.timestamp + 1 seconds) * num;
        vm.warp(targetTime);
    }

    function minuteForward(uint256 num) external {
        uint256 targetTime = (block.timestamp + 1 minutes) * num;
        vm.warp(targetTime);
    }

    function hourForward(uint256 num) external {
        uint256 targetTime = (block.timestamp + 1 hours) * num;
        vm.warp(targetTime);
    }

    function weekForward(uint256 num) external {
        uint256 targetTime = (block.timestamp + 1 weeks) * num;
        vm.warp(targetTime);
    }

    function dayBackward(uint256 num) external {
        uint256 targetTime = (block.timestamp - 1 days) * num;
        vm.warp(targetTime);
    }

    function secondBackward(uint256 num) external {
        uint256 targetTime = (block.timestamp - 1 seconds) * num;
        vm.warp(targetTime);
    }

    function minuteBackward(uint256 num) external {
        uint256 targetTime = (block.timestamp - 1 minutes) * num;
        vm.warp(targetTime);
    }

    function hourBackward(uint256 num) external {
        uint256 targetTime = (block.timestamp - 1 hours) * num;
        vm.warp(targetTime);
    }

    function weekBackward(uint256 num) external {
        uint256 targetTime = (block.timestamp - 1 weeks) * num;
        vm.warp(targetTime);
    }
}
