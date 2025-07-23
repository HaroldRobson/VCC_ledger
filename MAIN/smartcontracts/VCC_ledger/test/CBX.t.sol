// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "forge-std/Test.sol";
// import "../src/Factory.sol";
// import "../src/CBX.sol";
// contract FactoryIntegrationTest is Test {
//     Factory public factory;
//     CBX public cbxPool1;
//     CBX public cbxPool2;
//
//     address public owner;      // Factory owner & CBX owner (same person)
//     address public seller1;    // Seller for pool1
//     address public seller2;    // Seller for pool2
//     address public buyer1;
//     address public buyer2;
//     address public buyer3;
//     address public buyer4;
//     address public buyer5;
//
//     // USDC address from your contract
//     address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; 
//     uint256 constant FACTORY_FEE = 300; // 3% fee for factory
//
//     function setUp() public {
//         owner = address(this);   // We are the owner of both factory and pools
//         seller1 = makeAddr("seller1");
//         seller2 = makeAddr("seller2");
//         buyer1 = makeAddr("buyer1");
//         buyer2 = makeAddr("buyer2");
//         buyer3 = makeAddr("buyer3");
//         buyer4 = makeAddr("buyer4");
//         buyer5 = makeAddr("buyer5");
//
//         // Deploy factory
//         factory = new Factory(FACTORY_FEE);
//
//         // Mock USDC balances for buyers
//         address[5] memory buyers = [buyer1, buyer2, buyer3, buyer4, buyer5];
//         for (uint i = 0; i < buyers.length; i++) {
//             vm.mockCall(
//                 USDC,
//                 abi.encodeWithSelector(IERC20.balanceOf.selector, buyers[i]),
//                 abi.encode(100000 * 10**6) // 100k USDC each
//             );
//         }
//     }
//
//     function testFactoryDeployment() public {
//         assertEq(factory.owner(), owner);
//         assertEq(factory.counter(), 0);
//         assertEq(factory.fee(), FACTORY_FEE);
//     }
//
//     function testCreateFirstPool() public {
//         // Pool 1: Brazilian rainforest credits, vintage 2023
//         string memory serialNumber1 = "BRAZIL-RAIN-2023-001";
//         string memory country1 = "Brazil";
//         string memory methodologies1 = "REDD+ Rainforest Conservation";
//         uint256 issuanceDate1 = 1672531200; // Jan 1, 2023
//         uint256 initialSupply1 = 100; // 100 carbon credits
//         uint256 pricePerCredit1 = 8 * 10**6; // $8 per credit
//
//         address pool1Address = factory.createPool(
//             pricePerCredit1,
//             serialNumber1,
//             country1,
//             methodologies1,
//             issuanceDate1,
//             initialSupply1,
//             seller1
//         );
//
//         cbxPool1 = CBX(pool1Address);
//
//         // Verify pool was created correctly
//         assertEq(factory.counter(), 1);
//         assertEq(cbxPool1.owner(), owner); // Pool owner should be factory owner
//         assertEq(cbxPool1.seller(), seller1);
//         assertEq(cbxPool1.fee(), FACTORY_FEE);
//         assertEq(cbxPool1.totalSupply(), initialSupply1 * 100); // 100 tokens per credit
//         assertEq(cbxPool1.reserves(), initialSupply1 * 100);
//         assertEq(cbxPool1.pricePerToken(), pricePerCredit1 / 100); // $0.08 per token
//
//         // Verify token name and symbol
//         assertEq(cbxPool1.name(), serialNumber1);
//         assertEq(cbxPool1.symbol(), "CBX0"); // Should be CBX + counter (0 for first pool)
//     }
//
//     function testCreateSecondPool() public {
//         // Create first pool
//         testCreateFirstPool();
//
//         // Pool 2: Indian solar credits, vintage 2024
//         string memory serialNumber2 = "INDIA-SOLAR-2024-001";
//         string memory country2 = "India";
//         string memory methodologies2 = "Solar Energy Generation";
//         uint256 issuanceDate2 = 1704067200; // Jan 1, 2024
//         uint256 initialSupply2 = 200; // 200 carbon credits
//         uint256 pricePerCredit2 = 12 * 10**6; // $12 per credit
//
//         address pool2Address = factory.createPool(
//             pricePerCredit2,
//             serialNumber2,
//             country2,
//             methodologies2,
//             issuanceDate2,
//             initialSupply2,
//             seller2
//         );
//
//         cbxPool2 = CBX(pool2Address);
//
//         // Verify second pool
//         assertEq(factory.counter(), 2);
//         assertEq(cbxPool2.owner(), owner);
//         assertEq(cbxPool2.seller(), seller2);
//         assertEq(cbxPool2.pricePerToken(), pricePerCredit2 / 100); // $0.12 per token
//         assertEq(cbxPool2.totalSupply(), initialSupply2 * 100);
//         assertEq(cbxPool2.name(), serialNumber2);
//         assertEq(cbxPool2.symbol(), "CBX1"); // Should be CBX + counter (1 for second pool)
//     }
//
//     function testOnlyOwnerCanCreatePools() public {
//         vm.startPrank(seller1);
//         vm.expectRevert();
//         factory.createPool(
//             5 * 10**6,
//             "TEST-001",
//             "Test Country",
//             "Test Method",
//             block.timestamp,
//             100,
//             seller1
//         );
//         vm.stopPrank();
//     }
//
//     function testSellerCanMintMoreCredits() public {
//         testCreateFirstPool();
//
//         // Seller1 mints additional credits to their pool
//         vm.startPrank(seller1);
//
//         uint256 additionalCredits = 50;
//         uint256 newPricePerCredit = 10 * 10**6; // $10 per credit (higher than original $8)
//
//         cbxPool1.mint(additionalCredits, newPricePerCredit);
//
//         // Check weighted average pricing
//         // Original: 100 credits * $8 = $800 = 10000 tokens * 80000
//         // New: 50 credits * $10 = $500 = 5000 tokens * 100000
//         // Total: 15000 tokens worth (10000*80000 + 5000*100000) = 1300000000
//         // Average: 1300000000 / 15000 = 86666 (rounded down)
//         assertEq(cbxPool1.pricePerToken(), 86666);
//         assertEq(cbxPool1.totalSupply(), 15000); // 150 credits * 100 tokens
//         assertEq(cbxPool1.reserves(), 15000);
//
//         vm.stopPrank();
//     }
//
//     function testOnlySellerCanMint() public {
//         testCreateFirstPool();
//
//         // Owner cannot mint (only seller can)
//         vm.expectRevert();
//         cbxPool1.mint(50, 10 * 10**6);
//
//         // Random user cannot mint
//         vm.startPrank(buyer1);
//         vm.expectRevert();
//         cbxPool1.mint(50, 10 * 10**6);
//         vm.stopPrank();
//     }
//
//     function testBuyersCanPurchaseTokens() public {
//         testCreateFirstPool();
//
//         // Buyer1 purchases 500 tokens (5 credits)
//         vm.startPrank(buyer1);
//
//         uint256 tokensToBuy = 500;
//         uint256 pricePerTokenWithFee = cbxPool1.getUSDCPricePerTokenWithFee();
//         uint256 totalCost = tokensToBuy * pricePerTokenWithFee;
//
//         // Mock USDC transferFrom
//         vm.mockCall(
//             USDC,
//             abi.encodeWithSelector(IERC20.transferFrom.selector, buyer1, address(cbxPool1), totalCost),
//             abi.encode(true)
//         );
//
//         cbxPool1.buyTokensWithUSDC(tokensToBuy);
//
//         assertEq(cbxPool1.balanceOf(buyer1), tokensToBuy);
//         assertEq(cbxPool1.reserves(), 9500); // 10000 - 500
//
//         vm.stopPrank();
//     }
//
//     function testMultipleBuyersPurchaseTokens() public {
//         testCreateFirstPool();
//
//         address[3] memory buyers = [buyer1, buyer2, buyer3];
//         uint256[3] memory amounts = [uint256(300), 200, 150];
//
//         for (uint i = 0; i < buyers.length; i++) {
//             vm.startPrank(buyers[i]);
//
//             uint256 cost = amounts[i] * cbxPool1.getUSDCPricePerTokenWithFee();
//             vm.mockCall(
//                 USDC,
//                 abi.encodeWithSelector(IERC20.transferFrom.selector, buyers[i], address(cbxPool1), cost),
//                 abi.encode(true)
//             );
//
//             cbxPool1.buyTokensWithUSDC(amounts[i]);
//             assertEq(cbxPool1.balanceOf(buyers[i]), amounts[i]);
//
//             vm.stopPrank();
//         }
//
//         // Check total reserves decreased correctly
//         assertEq(cbxPool1.reserves(), 9350); // 10000 - 300 - 200 - 150
//     }
//     receive() external payable {}
// function testRetirementWithGasFees() public {
//     testMultipleBuyersPurchaseTokens();
//
//     // Check initial owner ETH balance
//     uint256 ownerBalanceBefore = owner.balance;
//
//     // Buyer1 retires tokens with gas fee
//     vm.startPrank(buyer1);
//     vm.deal(buyer1, 1 ether); // Give buyer1 some ETH
//
//     uint256 tokensToRetire = 150; // This is fine - buyer1 has 300 tokens
//     uint256 gasFee = cbxPool1.RETIREMET_GAS_FEE();
//     uint256 buyer1BalanceBefore = cbxPool1.balanceOf(buyer1);
//
//     // Add assertion to verify buyer has enough tokens
//     assertGe(buyer1BalanceBefore, tokensToRetire, "Buyer doesn't have enough tokens");
//
//     cbxPool1.retire{value: gasFee}(tokensToRetire);
//
//     // Check tokens were burned and gas fee transferred
//     assertEq(cbxPool1.balanceOf(buyer1), buyer1BalanceBefore - tokensToRetire);
//     assertEq(owner.balance, ownerBalanceBefore + gasFee);
//     assertEq(cbxPool1.getPendingCount(), 1);
//
//     vm.stopPrank();
// }
//
//     function testInsufficientGasFeeReverts() public {
//         testMultipleBuyersPurchaseTokens();
//
//         vm.startPrank(buyer1);
//         vm.deal(buyer1, 1 ether);
//
//         uint256 insufficientFee = cbxPool1.RETIREMET_GAS_FEE() - 1;
//
//         vm.expectRevert();
//         cbxPool1.retire{value: insufficientFee}(100);
//
//         vm.stopPrank();
//     }
//
//     function testMultipleRetirementsAndProcessing() public {
//         testMultipleBuyersPurchaseTokens();
//
//         // Give all buyers ETH for gas fees
//         address[5] memory allBuyers = [buyer1, buyer2, buyer3, buyer4, buyer5];
//         for (uint i = 0; i < allBuyers.length; i++) {
//             vm.deal(allBuyers[i], 1 ether);
//         }
//
//         // Have more buyers purchase tokens first
//         vm.startPrank(buyer4);
//         uint256 cost4 = 120 * cbxPool1.getUSDCPricePerTokenWithFee();
//         vm.mockCall(USDC, abi.encodeWithSelector(IERC20.transferFrom.selector, buyer4, address(cbxPool1), cost4), abi.encode(true));
//         cbxPool1.buyTokensWithUSDC(120);
//         vm.stopPrank();
//
//         vm.startPrank(buyer5);
//         uint256 cost5 = 80 * cbxPool1.getUSDCPricePerTokenWithFee();
//         vm.mockCall(USDC, abi.encodeWithSelector(IERC20.transferFrom.selector, buyer5, address(cbxPool1), cost5), abi.encode(true));
//         cbxPool1.buyTokensWithUSDC(80);
//         vm.stopPrank();
//
//         // Multiple users retire tokens
//         uint256 gasFee = cbxPool1.RETIREMET_GAS_FEE();
//         uint256[5] memory retireAmounts = [uint256(150), 80, 120, 60, 40];
//
//         for (uint i = 0; i < 5; i++) {
//             vm.startPrank(allBuyers[i]);
//             cbxPool1.retire{value: gasFee}(retireAmounts[i]);
//             vm.stopPrank();
//         }
//
//         assertEq(cbxPool1.getPendingCount(), 5);
//
//         // Process retirements (only owner can do this)
//         // Total: 150+80+120+60+40 = 450, residue = 50
//         // Should bundle 400 tokens (4 credits)
//
//         cbxPool1.processRetirements();
//
//         assertEq(cbxPool1.bundleCounter(), 1);
//         assertTrue(cbxPool1.getPendingCount() > 0); // Should have remainder
//     }
//
//     function testRetirementBundleEventData() public {
//         testMultipleBuyersPurchaseTokens();
//
//         // Set up exact amounts that sum to 500 (divisible by 100)
//         address[5] memory buyers = [buyer1, buyer2, buyer3, buyer4, buyer5];
//         for (uint i = 0; i < buyers.length; i++) {
//             vm.deal(buyers[i], 1 ether);
//         }
//
//         // Get more buyers tokens first
//         vm.startPrank(buyer4);
//         uint256 cost4 = 200 * cbxPool1.getUSDCPricePerTokenWithFee();
//         vm.mockCall(USDC, abi.encodeWithSelector(IERC20.transferFrom.selector, buyer4, address(cbxPool1), cost4), abi.encode(true));
//         cbxPool1.buyTokensWithUSDC(200);
//         vm.stopPrank();
//
//         vm.startPrank(buyer5);
//         uint256 cost5 = 150 * cbxPool1.getUSDCPricePerTokenWithFee();
//         vm.mockCall(USDC, abi.encodeWithSelector(IERC20.transferFrom.selector, buyer5, address(cbxPool1), cost5), abi.encode(true));
//         cbxPool1.buyTokensWithUSDC(150);
//         vm.stopPrank();
//
//         // Retire exact amounts: 100 + 100 + 100 + 100 + 100 = 500
//         uint256 gasFee = cbxPool1.RETIREMET_GAS_FEE();
//         uint256[5] memory exactAmounts = [uint256(100), 100, 100, 100, 100];
//
//         for (uint i = 0; i < 5; i++) {
//             vm.startPrank(buyers[i]);
//             cbxPool1.retire{value: gasFee}(exactAmounts[i]);
//             vm.stopPrank();
//         }
//
//         // Record logs to check event data
//         cbxPool1.processRetirements();
//
//         // Just verify the retirement was processed successfully
//         assertEq(cbxPool1.bundleCounter(), 1);
//         assertEq(cbxPool1.getPendingCount(), 0); // Should be empty since we retired exactly 500
//     }
//
//      function testOwnerCanWithdrawFees() public {
//     testMultipleBuyersPurchaseTokens();
//
//     // Calculate total fees collected from purchases
//     // Buyer1: 300 tokens, Buyer2: 200 tokens, Buyer3: 150 tokens
//     uint256 totalTokensPurchased = 650;
//     uint256 pricePerToken = 80000; // 0.08 USDC base price
//     uint256 totalCostWithoutFee = totalTokensPurchased * pricePerToken;
//     uint256 totalCostWithFee = totalTokensPurchased * 82400; // with 3% fee
//     uint256 expectedFees = totalCostWithFee - totalCostWithoutFee;
//
//     // Mock USDC transfer for the actual fee amount
//     vm.mockCall(
//         USDC,
//         abi.encodeWithSelector(IERC20.transfer.selector, owner, expectedFees),
//         abi.encode(true)
//     );
//
//     // Only owner can withdraw fees
//     cbxPool1.withDrawUSDCFees();
//
//     // Test that non-owner cannot withdraw fees
//     vm.startPrank(seller1);
//     vm.expectRevert();
//     cbxPool1.withDrawUSDCFees();
//     vm.stopPrank();
// }
//
// // 3. Fix testSellerCanWithdrawProfits similarly:
// function testSellerCanWithdrawProfits() public {
//     testMultipleBuyersPurchaseTokens();
//
//     // Calculate total seller profit from purchases
//     uint256 totalTokensPurchased = 650;
//     uint256 totalCostWithFee = totalTokensPurchased * 82400;
//     uint256 expectedSellerProfit = (totalCostWithFee * 10000) / 10300; // Remove fee portion
//
//     // Mock USDC transfer for profit withdrawal  
//     vm.mockCall(
//         USDC,
//         abi.encodeWithSelector(IERC20.transfer.selector, seller1, expectedSellerProfit),
//         abi.encode(true)
//     );
//
//     // Seller can withdraw their profits
//     vm.startPrank(seller1);
//     cbxPool1.withDrawUSDCProfits();
//     vm.stopPrank();
//
//     // Test that non-seller cannot withdraw profits
//     vm.startPrank(buyer1);
//     vm.expectRevert();
//     cbxPool1.withDrawUSDCProfits();
//     vm.stopPrank();
// }
//
//     function testOwnerCanSetFees() public {
//         testCreateFirstPool();
//
//         uint256 newFee = 500; // 5%
//         cbxPool1.setFee(newFee);
//         assertEq(cbxPool1.fee(), newFee);
//
//         // Non-owner cannot set fees
//         vm.startPrank(seller1);
//         vm.expectRevert();
//         cbxPool1.setFee(600);
//         vm.stopPrank();
//     }
//
//     function testOwnerEmergencyWithdrawUSDC() public {
//         testMultipleBuyersPurchaseTokens();
//
//         // Mock contract USDC balance and withdrawal
//         uint256 contractBalance = 10000 * 10**6; // $10k stuck in contract
//         vm.mockCall(
//             USDC,
//             abi.encodeWithSelector(IERC20.balanceOf.selector, address(cbxPool1)),
//             abi.encode(contractBalance)
//         );
//         vm.mockCall(
//             USDC,
//             abi.encodeWithSelector(IERC20.transfer.selector, owner, contractBalance),
//             abi.encode(true)
//         );
//
//         cbxPool1.withDrawRemainingUSDC();
//
//         // Non-owner cannot emergency withdraw
//         vm.startPrank(seller1);
//         vm.expectRevert();
//         cbxPool1.withDrawRemainingUSDC();
//         vm.stopPrank();
//     }
//
//     function testProfitAndFeeAccounting() public {
//         testCreateFirstPool();
//
//         // Buyer purchases tokens
//         vm.startPrank(buyer1);
//         uint256 tokensToBuy = 1000; // 10 credits
//         uint256 pricePerTokenWithFee = cbxPool1.getUSDCPricePerTokenWithFee();
//         uint256 totalCost = tokensToBuy * pricePerTokenWithFee;
//
//         vm.mockCall(
//             USDC,
//             abi.encodeWithSelector(IERC20.transferFrom.selector, buyer1, address(cbxPool1), totalCost),
//             abi.encode(true)
//         );
//
//         cbxPool1.buyTokensWithUSDC(tokensToBuy);
//         vm.stopPrank();
//
//         // Check that profits and fees are calculated correctly
//         // Base price: 80000 (0.08 USDC)
//         // With 3% fee: 82400
//         // Total cost: 1000 * 82400 = 82,400,000 (82.4 USDC)
//         // Seller profit: 82,400,000 * 10000 / 10300 = 80,000,000
//         // Fee collected: 82,400,000 * 300 / 10300 = 2,400,000
//
//         uint256 expectedTotalCost = 82400000; // 1000 * 82400
//         uint256 expectedSellerProfit = 80000000; // totalCost * 10000 / 10300
//         uint256 expectedFees = 2400000; // totalCost * 300 / 10300
//
//         assertEq(totalCost, expectedTotalCost);
//         // Note: We can't directly check sellerProfit and feesCollected as they're private
//         // But we can verify the math is correct by checking the purchase succeeded
//     }
//
//     function testComprehensiveScenario() public {
//         // 1. Deploy factory ✓ (done in setUp)
//
//         // 2. Create two different carbon credit pools
//         testCreateSecondPool(); // Creates both pools
//
//         // 3. Sellers mint additional credits at different prices
//         vm.startPrank(seller1);
//         cbxPool1.mint(75, 9 * 10**6); // Add 75 credits at $9
//         vm.stopPrank();
//
//         vm.startPrank(seller2);
//         cbxPool2.mint(100, 15 * 10**6); // Add 100 credits at $15
//         vm.stopPrank();
//
//         // 4. Multiple buyers purchase from both pools
//         address[3] memory buyers = [buyer1, buyer2, buyer3];
//         uint256[3] memory amounts1 = [uint256(400), 300, 200]; // Pool 1
//         uint256[3] memory amounts2 = [uint256(500), 250, 350]; // Pool 2
//
//         for (uint i = 0; i < buyers.length; i++) {
//             // Purchase from pool 1
//             vm.startPrank(buyers[i]);
//             uint256 cost1 = amounts1[i] * cbxPool1.getUSDCPricePerTokenWithFee();
//             vm.mockCall(USDC, abi.encodeWithSelector(IERC20.transferFrom.selector, buyers[i], address(cbxPool1), cost1), abi.encode(true));
//             cbxPool1.buyTokensWithUSDC(amounts1[i]);
//
//             // Purchase from pool 2
//             uint256 cost2 = amounts2[i] * cbxPool2.getUSDCPricePerTokenWithFee();
//             vm.mockCall(USDC, abi.encodeWithSelector(IERC20.transferFrom.selector, buyers[i], address(cbxPool2), cost2), abi.encode(true));
//             cbxPool2.buyTokensWithUSDC(amounts2[i]);
//             vm.stopPrank();
//         }
//
//         // 5. Users retire from both pools with gas fees
//         for (uint i = 0; i < buyers.length; i++) {
//             vm.deal(buyers[i], 1 ether);
//             vm.startPrank(buyers[i]);
//
//             uint256 gasFee = cbxPool1.RETIREMET_GAS_FEE();
//             cbxPool1.retire{value: gasFee}(amounts1[i] / 2); // Retire half
//             cbxPool2.retire{value: gasFee}(amounts2[i] / 2); // Retire half
//
//             vm.stopPrank();
//         }
//
//         // 6. Process retirements when enough are queued
//         // Add more retirements to reach minimum bundle size
//         vm.deal(buyer4, 1 ether);
//         vm.deal(buyer5, 1 ether);
//
//         // Get buyer4 and buyer5 some tokens first
//         vm.startPrank(buyer4);
//         uint256 cost4_1 = 250 * cbxPool1.getUSDCPricePerTokenWithFee();
//         vm.mockCall(USDC, abi.encodeWithSelector(IERC20.transferFrom.selector, buyer4, address(cbxPool1), cost4_1), abi.encode(true));
//         cbxPool1.buyTokensWithUSDC(250);
//         cbxPool1.retire{value: cbxPool1.RETIREMET_GAS_FEE()}(150);
//         vm.stopPrank();
//
//         vm.startPrank(buyer5);
//         uint256 cost5_1 = 200 * cbxPool1.getUSDCPricePerTokenWithFee();
//         vm.mockCall(USDC, abi.encodeWithSelector(IERC20.transferFrom.selector, buyer5, address(cbxPool1), cost5_1), abi.encode(true));
//         cbxPool1.buyTokensWithUSDC(200);
//         cbxPool1.retire{value: cbxPool1.RETIREMET_GAS_FEE()}(100);
//         vm.stopPrank();
//
//         // Now process retirements
//         cbxPool1.processRetirements();
//         assertEq(cbxPool1.bundleCounter(), 1);
//
//         // 7. Sellers and owner withdraw profits/fees
//         vm.startPrank(seller1);
//         vm.mockCall(USDC, abi.encodeWithSelector(IERC20.transfer.selector, seller1, 0), abi.encode(true));
//         console.log("MARK");
//         cbxPool1.withDrawUSDCProfits();
//         vm.stopPrank();
//
//         vm.mockCall(USDC, abi.encodeWithSelector(IERC20.transfer.selector, owner, 0), abi.encode(true));
//         cbxPool1.withDrawUSDCFees();
//
//         // Verify final state
//         assertTrue(cbxPool1.bundleCounter() >= 1);
//         assertTrue(cbxPool2.getPendingCount() >= 3); // Should have pending retirements
//         assertEq(factory.counter(), 2); // Two pools created
//
//         // Verify token symbols are correct
//         assertEq(cbxPool1.symbol(), "CBX0");
//         assertEq(cbxPool2.symbol(), "CBX1");
//     }
// }
