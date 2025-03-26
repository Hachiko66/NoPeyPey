// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MockAaveLendingPool} from "../src/MockAaveLendingPool.sol";
import {Treasury} from "../src/Treasury.sol";
import {PrincipalToken} from "../src/PrincipalToken.sol";
import {YieldToken} from "../src/YieldToken.sol";
import {FundsVault} from "../src/FundsVault.sol";
import "../src/MockUSDC.sol";


contract NoPeyPeyTest is Test {
    MockUSDC usdc;
    MockAaveLendingPool aavePool;
    Treasury treasury;
    PrincipalToken principalToken;
    YieldToken yieldToken;
    FundsVault fundsVault;

    address user = makeAddr("user");

    function setUp() public {
        usdc = new MockUSDC(); // Deploy mock USDC
        aavePool = new MockAaveLendingPool(address(usdc));
        treasury = new Treasury(address(usdc));
        principalToken = new PrincipalToken();
        yieldToken = new YieldToken();

        fundsVault = new FundsVault(
            msg.sender,
            address(usdc),
            address(aavePool),
            address(treasury),
            address(principalToken),
            address(yieldToken)
        );

        principalToken.setFundsVault(address(fundsVault));
        yieldToken.setFundsVault(address(fundsVault));
    }

    function testDeposit() public {
        uint256 depositAmount = 100 ether;
        vm.startPrank(user);
        usdc.transfer(user, depositAmount);
        usdc.approve(address(fundsVault), depositAmount);
        fundsVault.deposit(depositAmount);
        vm.stopPrank();

        assertEq(principalToken.balanceOf(user), depositAmount);
        assertEq(yieldToken.balanceOf(user), depositAmount * 10 / 100);
    }
}