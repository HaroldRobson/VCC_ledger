// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Factory.sol";
import "../src/CBX.sol";

contract MegaStressTest is Test {
    Factory public factory;
    CBX public cbxPool1;
    CBX public cbxPool2;

    address public owner;
    address public seller1;
    address public seller2;
    address[] public users;

    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    IERC20 public usdcToken = IERC20(USDC);
    uint256 constant FACTORY_FEE = 300; // 3%
    uint256 constant NUM_USERS = 100;

    function setUp() public {
        // Fork mainnet for realistic interaction with USDC
        vm.createSelectFork(vm.rpcUrl("mainnet"), 22969797);

        owner = makeAddr("owner");
        seller1 = makeAddr("seller1");
        seller2 = makeAddr("seller2");
        
        // Create and fund a large number of users
        for (uint i = 0; i < NUM_USERS; i++) {
            address user = makeAddr(string(abi.encodePacked("user", Strings.toString(i))));
            users.push(user);
        }

        vm.prank(owner); // Set the deployer as owner
        factory = new Factory(FACTORY_FEE);

        // Fund all participants with ample USDC and some ETH for gas
        deal(USDC, owner, 5_000_000 * 10**6);
        deal(USDC, seller1, 5_000_000 * 10**6);
        deal(USDC, seller2, 5_000_000 * 10**6);
        vm.deal(owner, 100 ether); // Give owner plenty of ETH for processing

        for (uint i = 0; i < users.length; i++) {
            deal(USDC, users[i], 2_000_000 * 10**6);
            vm.deal(users[i], 2 ether);
        }
    }

    function _createPools() internal {
        vm.prank(owner);
        address pool1Address = factory.createPool(
            8 * 10**6, "BRAZIL-RAIN-2023-001", "Brazil", "REDD+", 1672531200, 5000, seller1
        );
        cbxPool1 = CBX(pool1Address);

        vm.prank(owner);
        address pool2Address = factory.createPool(
            12 * 10**6, "INDIA-SOLAR-2024-001", "India", "Solar", 1704067200, 8000, seller2
        );
        cbxPool2 = CBX(pool2Address);
    }
    
    function _buyerBuysTokens(address buyer, CBX pool, uint256 amount) internal {
        vm.startPrank(buyer);
        uint256 cost = amount * pool.getUSDCPricePerTokenWithFee();
        usdcToken.approve(address(pool), cost);
        pool.buyTokensWithUSDC(amount);
        vm.stopPrank();
    }

    function test_MegaStressScenario() public {
        // --- PHASE 1: Initial Setup and Market Frenzy ---
        console.log("--- PHASE 1: Initial Setup and Market Frenzy ---");
        _createPools();

        // Sellers add non-round amounts of new credits
        vm.prank(seller1);
        cbxPool1.mint(137, 7 * 10**6 + 870000); // $7.87
        vm.prank(seller2);
        cbxPool2.mint(284, 11 * 10**6 + 430000); // $11.43

      // 50 users buy "weird" amounts of tokens from both pools
        for (uint i = 0; i < 90; i++) {
            uint256 buyAmount1 = (i % 70) + 13; // e.g., 13, 14, ... 82
            uint256 buyAmount2 = (i % 50) + 21; // e.g., 21, 22, ... 70
            _buyerBuysTokens(users[i], cbxPool1, buyAmount1);
            _buyerBuysTokens(users[i], cbxPool2, buyAmount2);
        }
        console.log("Initial market activity complete. 150 users bought tokens.");

        // --- PHASE 2: Mid-Stream Withdrawals ---
        console.log("\n--- PHASE 2: Mid-Stream Withdrawals ---");
        uint256 seller1ProfitBefore = usdcToken.balanceOf(seller1);
        vm.prank(seller1);
        cbxPool1.withDrawUSDCProfits();
        uint256 seller1ProfitAfter = usdcToken.balanceOf(seller1);
        assertTrue(seller1ProfitAfter > seller1ProfitBefore, "Seller 1 should have withdrawn profits");
        console.log("Seller 1 withdrew profits.");

        uint256 ownerFeesBefore = usdcToken.balanceOf(owner);
        vm.prank(owner);
        cbxPool1.withDrawUSDCFees();
        uint256 ownerFeesAfter = usdcToken.balanceOf(owner);
        assertTrue(ownerFeesAfter > ownerFeesBefore, "Owner should have withdrawn fees");
        console.log("Owner withdrew fees from Pool 1.");

        // --- PHASE 3: Build Massive Retirement Queue ---
        console.log("\n--- PHASE 3: Building a Massive Retirement Queue ---");
        uint numRetirers = 43;
        uint256 totalGasFeesPaidToOwner = 0;
        for (uint i = 0; i < numRetirers; i++) {
            uint256 retireAmount = (i % 43) + 1; // Retire amounts from 1 to 43
            vm.startPrank(users[i]); // We use the first 67 users who already bought tokens
            cbxPool1.retire{value: cbxPool1.RETIREMET_GAS_FEE()}(retireAmount);
            vm.stopPrank();
            totalGasFeesPaidToOwner += cbxPool1.RETIREMET_GAS_FEE();
        }
        assertEq(cbxPool1.getPendingCount(), numRetirers, "Retirement queue should have 67 entries");
        console.log("Users who queued for retirement:", numRetirers);
        console.logString(string(abi.encodePacked("Total ETH paid by retirers to owner: ", Strings.toString(totalGasFeesPaidToOwner / 1e18), " ether")));

        // --- PHASE 4: Process the Massive Queue in Batches & Check Gas ---
        console.log("\n--- PHASE 4: Processing the Queue & Gas Analysis ---");
        uint256 ownerEthBeforeProcessing = owner.balance;
        uint256 totalGasCostForProcessing = 0;
        uint256 bundlesCreated = 0;

        // Loop until the queue is too small to form a full bundle
        uint256 oldPendingCount = 0;
        while(cbxPool1.getPendingCount() > oldPendingCount) {
            oldPendingCount = cbxPool1.getPendingCount();
            uint256 pendingBefore = cbxPool1.getPendingCount();
            uint256 ownerEthBeforeCall = owner.balance;
            uint256 gasBefore = gasleft(); 
            vm.prank(owner);
            cbxPool1.processRetirements();
            uint256 gasAfter = gasleft();
            uint256 gasCostOfCall = gasBefore - gasAfter;
            totalGasCostForProcessing += gasCostOfCall;

            // CORRECTED CONSOLE LOGS
            console.log("--- Processed a Bundle ---");
            console.log("Bundle number:", bundlesCreated);
            console.log("Queue size before:", pendingBefore);
            console.log("Queue size after:", cbxPool1.getPendingCount());
            console.log("Gas cost for this call (gwei):", gasCostOfCall / 1e9);

        }
        
        console.log("\n--- Gas Accounting Summary ---");
        console.log("Total ETH collected from retirers (wei):", totalGasFeesPaidToOwner);
        console.log("Total Gas Cost for processing (wei):", totalGasCostForProcessing);
        assertTrue(totalGasFeesPaidToOwner >= totalGasCostForProcessing, "Owner's collected fees should cover processing gas cost");
        console.logString(string(abi.encodePacked("Owner's ETH balance after all processing: ", Strings.toString(owner.balance / 1e18), " ether")));
        assertTrue(owner.balance > ownerEthBeforeProcessing - totalGasCostForProcessing, "Owner's balance should not decrease after accounting for collected fees");

        // --- PHASE 5: More Market Activity During Retirement Processing ---
        console.log("\n--- PHASE 5: Concurrent Market Activity ---");
        for (uint i = 150; i < NUM_USERS; i++) {
            _buyerBuysTokens(users[i], cbxPool2, (i % 100) + 50);
        }
        console.log("Remaining 50 users purchased tokens from Pool 2.");

        // --- PHASE 6: Final Withdrawals and State Verification ---
        console.log("\n--- PHASE 6: Final Withdrawals and System Verification ---");
        
        // Seller 1 and Owner withdraw again from Pool 1
        vm.prank(seller1);
        cbxPool1.withDrawUSDCProfits();
        vm.prank(owner);
        cbxPool1.withDrawUSDCFees();

        // Seller 2 and Owner withdraw everything from Pool 2
        uint256 seller2ProfitBefore = usdcToken.balanceOf(seller2);
        vm.prank(seller2);
        cbxPool2.withDrawUSDCProfits();
        uint256 seller2ProfitAfter = usdcToken.balanceOf(seller2);
        assertTrue(seller2ProfitAfter > seller2ProfitBefore, "Seller 2 should have withdrawn profits");

        uint256 ownerFeesBefore2 = usdcToken.balanceOf(owner);
        vm.prank(owner);
        cbxPool2.withDrawUSDCFees();
        uint256 ownerFeesAfter2 = usdcToken.balanceOf(owner);
        assertTrue(ownerFeesAfter2 > ownerFeesBefore2, "Owner should have withdrawn fees from Pool 2");
        console.log("All remaining profits and fees withdrawn.");

        // Verify final state
        uint256 remainingQueue = cbxPool1.getPendingCount();
        assertTrue(remainingQueue < 10, "Remaining queue should be smaller than a full bundle");
        console.log("Final pending retirement queue size:", remainingQueue);
        
        // Final check that contracts are empty of USDC (allowing for tiny dust amounts from rounding)
        uint256 dustLimit = 1000; // Allow up to 0.001 USDC dust
        assertLt(usdcToken.balanceOf(address(cbxPool1)), dustLimit, "Pool 1 should be empty of USDC");
        assertLt(usdcToken.balanceOf(address(cbxPool2)), dustLimit, "Pool 2 should be empty of USDC");
        console.log("Final check complete: Contracts have been drained of value as expected.");
    }
}
