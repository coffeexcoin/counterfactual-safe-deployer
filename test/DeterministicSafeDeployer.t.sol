// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {DeterministicSafeDeployer} from "../src/DeterministicSafeDeployer.sol";

contract DeterministicSafeDeployerTest is Test {
    DeterministicSafeDeployer public counter;

    function setUp() public {
        counter = new DeterministicSafeDeployer();
    }

    function test_KnownAddress() public {
        assertEq(
            DeterministicSafeDeployer(counter).getSafeAddress(
                0x86362a4C99d900D72d787Ef1BddA38Fd318aa5E9,
                1694992995200
            ),
            0x1ECd34F53c94aA805F321F947d35ADB63493512b
        );
    }
}
