// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {StdUtils} from "forge-std/StdUtils.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../src/MockUSDC.sol"; // <<--- IMPORT MOCK USDC
import "../src/MockAaveLendingPool.sol";
import "../src/Treasury.sol";
import "../src/PrincipalToken.sol";
import "../src/YieldToken.sol";
import "../src/FundsVault.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();

        // Deploy mock USDC
        MockUSDC usdc = new MockUSDC(); 

        // Deploy dependencies
        MockAaveLendingPool aavePool = new MockAaveLendingPool(address(usdc));
        Treasury treasury = new Treasury(address(usdc));
        PrincipalToken principalToken = new PrincipalToken();
        YieldToken yieldToken = new YieldToken();

        // Deploy FundsVault
        FundsVault fundsVault = new FundsVault(
            msg.sender,
            address(usdc),
            address(aavePool),
            address(treasury),
            address(principalToken),
            address(yieldToken)
        );

        // Set FundsVault sebagai kontrak otorisasi untuk PrincipalToken/YieldToken
        principalToken.setFundsVault(address(fundsVault));
        yieldToken.setFundsVault(address(fundsVault));

        console.log("FundsVault deployed at:", address(fundsVault));

        vm.stopBroadcast();
    }
}