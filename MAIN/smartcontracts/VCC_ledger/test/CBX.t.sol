// this one tests retirements as well:

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/CBX.sol";

contract CBXTest is Test {
    CBX public cbx;
    
    address public owner;
    address public user1;
    address public user2;
    address public user3;
    address public user4;
    address public user5;
    address public user6;
    
    // USDC address from your contract
    address constant USDC = 0x796Ea11Fa2dD751eD01b53C372fFDB4AAa8f00F9;
    uint256 constant INITIAL_FEE = 300; // 3% fee
    
    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");
        user4 = makeAddr("user4");
        user5 = makeAddr("user5");
        user6 = makeAddr("user6");
        
        cbx = new CBX(INITIAL_FEE);
        
        // Mock USDC balances
        vm.mockCall(
            USDC,
            abi.encodeWithSelector(IERC20.balanceOf.selector, user1),
            abi.encode(100000 * 10**6) // 100k USDC
        );
        vm.mockCall(
            USDC,
            abi.encodeWithSelector(IERC20.balanceOf.selector, user2),
            abi.encode(100000 * 10**6) // 100k USDC
        );
    }
    
    function testInitialState() public {
        assertEq(cbx.owner(), owner);
        assertEq(cbx.fee(), INITIAL_FEE);
        assertEq(cbx.reserves(), 0);
        assertEq(cbx.pricePerToken(), 0);
        assertEq(cbx.totalSupply(), 0);
    }
    
    function testMintingCredits() public {
        uint256 creditsToMint = 10; // 10 carbon credits
        uint256 pricePerCredit = 5 * 10**6; // $5.00 per credit in USDC
        
        cbx.mint(creditsToMint, pricePerCredit);
        
        // Check tokens minted (100 tokens per credit)
        assertEq(cbx.totalSupply(), creditsToMint * 100);
        assertEq(cbx.reserves(), creditsToMint * 100);
        assertEq(cbx.pricePerToken(), pricePerCredit / 100); // $0.05 per token
        assertEq(cbx.balanceOf(address(cbx)), creditsToMint * 100);
        
        // Check price with fee
        uint256 pricePerCreditWithFee = cbx.getUSDCPricePerCreditWithFee();
        assertEq(pricePerCreditWithFee, 5.15 * 10**6); // $5.15 with 3% fee
        
        uint256 pricePerTokenWithFee = cbx.getUSDCPricePerTokenWithFee();
        assertEq(pricePerTokenWithFee, 51500); // $0.0515 with 3% fee
    }
    
    function testWeightedAveragePrice() public {
        // First mint: 10 credits at $5
        cbx.mint(10, 5 * 10**6);
        assertEq(cbx.pricePerToken(), 50000); // $0.05 per token
        
        // Second mint: 20 credits at $8
        cbx.mint(20, 8 * 10**6);
        
        // Weighted average: (50000 * 1000 + 80000 * 2000) / 3000 = 70000
        assertEq(cbx.pricePerToken(), 70000); // $0.07 per token
        assertEq(cbx.reserves(), 3000); // 30 credits = 3000 tokens
        
        // Third mint: 30 credits at $6
        cbx.mint(30, 6 * 10**6);
        
        // New weighted average: (70000 * 3000 + 60000 * 3000) / 6000 = 65000
        assertEq(cbx.pricePerToken(), 65000); // $0.065 per token
        assertEq(cbx.reserves(), 6000); // 60 credits = 6000 tokens
    }
    
    function testBuyTokensWithUSDC() public {
        // Mint 10 credits at $5
        cbx.mint(10, 5 * 10**6);
        
        // User1 buys 200 tokens (2 credits)
        vm.startPrank(user1);
        uint256 tokensToBuy = 200;
        uint256 pricePerTokenWithFee = cbx.getUSDCPricePerTokenWithFee();
        uint256 totalCost = tokensToBuy * pricePerTokenWithFee;
        
        // User approves CBX contract to spend their USDC
        vm.mockCall(
            USDC,
            abi.encodeWithSelector(IERC20.approve.selector, address(cbx), totalCost),
            abi.encode(true)
        );
        IERC20(USDC).approve(address(cbx), totalCost);
        
        // Mock that the transferFrom will succeed when CBX contract calls it
        vm.mockCall(
            USDC,
            abi.encodeWithSelector(IERC20.transferFrom.selector, user1, address(cbx), totalCost),
            abi.encode(true)
        );
        
        // Buy tokens
        cbx.buyTokensWithUSDC(tokensToBuy);
        
        // Verify token transfer
        assertEq(cbx.balanceOf(user1), tokensToBuy);
        assertEq(cbx.reserves(), 800); // 1000 - 200
        vm.stopPrank();
    }
    
    function testPriceCalculationWithDifferentFees() public {
        cbx.mint(10, 5 * 10**6); // 10 credits at $5
        
        // Test with 3% fee
        uint256 basePrice = cbx.pricePerToken(); // 50000 ($0.05)
        uint256 priceWithFee = cbx.getUSDCPricePerTokenWithFee();
        assertEq(priceWithFee, 51500); // $0.0515 with 3% fee
        
        // Test with 0% fee
        cbx.setFee(0);
        assertEq(cbx.getUSDCPricePerTokenWithFee(), 50000);
        assertEq(cbx.getUSDCPricePerCreditWithFee(), 5 * 10**6);
        
        // Test with 10% fee
        cbx.setFee(1000);
        assertEq(cbx.getUSDCPricePerTokenWithFee(), 55000); // $0.055
        assertEq(cbx.getUSDCPricePerCreditWithFee(), 5.5 * 10**6); // $5.50
    }
    
    function testWithdrawUSDC() public {
        // Mock initial USDC balance of contract
        vm.mockCall(
            USDC,
            abi.encodeWithSelector(IERC20.balanceOf.selector, address(cbx)),
            abi.encode(1000 * 10**6) // 1000 USDC in contract
        );
        
        // Mock transfer to owner
        vm.mockCall(
            USDC,
            abi.encodeWithSelector(IERC20.transfer.selector, owner, 1000 * 10**6),
            abi.encode(true)
        );
        
        // Withdraw
        vm.expectEmit(true, true, true, true);
        emit CBX.withdrawnUSDC(1000 * 10**6);
        cbx.withDrawUSDC();
    }
    
    function testAccessControl() public {
        // Non-owner cannot mint
        vm.startPrank(user1);
        vm.expectRevert();
        cbx.mint(10, 5 * 10**6);
        vm.stopPrank();
        
        // Non-owner cannot set fee
        vm.startPrank(user1);
        vm.expectRevert();
        cbx.setFee(400);
        vm.stopPrank();
        
        // Non-owner cannot withdraw
        vm.startPrank(user1);
        vm.expectRevert();
        cbx.withDrawUSDC();
        vm.stopPrank();
    }
    
    function testEdgeCases() public {
        // Cannot mint at price too low
        vm.expectRevert("THIS IS WAY TOO LOW, did you remember to enter the amount in cents not dollars?");
        cbx.mint(10, 1 * 10**6); // $1 per credit
        
        // Cannot mint 0 credits
        vm.expectRevert("MUST ENTER  A NON ZERO AMOUNT OF NEW TOKENS");
        cbx.mint(0, 5 * 10**6);
        
        // Cannot buy more than reserves
        cbx.mint(5, 5 * 10**6); // Only 500 tokens available
        
        vm.startPrank(user1);
        vm.expectRevert("We don't have enough carbon credits in our pool");
        cbx.buyTokensWithUSDC(600); // Try to buy 600 tokens
        vm.stopPrank();
    }
    
    function testComplexScenario() public {
        // Initial mint: 100 credits at $5
        cbx.mint(100, 5 * 10**6);
        assertEq(cbx.reserves(), 10000);
        
        // User1 buys 2500 tokens (25 credits)
        vm.startPrank(user1);
        uint256 cost1 = 2500 * cbx.getUSDCPricePerTokenWithFee();
        vm.mockCall(
            USDC,
            abi.encodeWithSelector(IERC20.transferFrom.selector, user1, address(cbx), cost1),
            abi.encode(true)
        );
        cbx.buyTokensWithUSDC(2500);
        assertEq(cbx.balanceOf(user1), 2500);
        vm.stopPrank();
        
        // Mint more at different price: 50 credits at $7
        cbx.mint(50, 7 * 10**6);
        
        // Check new weighted average
        // Previous: 7500 tokens at $0.05 = $375
        // New: 5000 tokens at $0.07 = $350
        // Total: 12500 tokens worth $725
        // Average: $725 / 12500 = $0.058 per token = 58000
        assertEq(cbx.pricePerToken(), 58000);
        
        // User2 buys 1000 tokens (10 credits)
        vm.startPrank(user2);
        uint256 cost2 = 1000 * cbx.getUSDCPricePerTokenWithFee();
        vm.mockCall(
            USDC,
            abi.encodeWithSelector(IERC20.transferFrom.selector, user2, address(cbx), cost2),
            abi.encode(true)
        );
        cbx.buyTokensWithUSDC(1000);
        assertEq(cbx.balanceOf(user2), 1000);
        vm.stopPrank();
        
        // Final state check
        assertEq(cbx.reserves(), 11500); // 12500 - 2500 - 1000
        assertEq(cbx.totalSupply(), 15000); // All minted tokens
    }
    
    function testEventEmission() public {
        // Test mint events
        vm.expectEmit(true, true, true, true);
        emit CBX.newCreditsPurchased(10, 5 * 10**6);
        vm.expectEmit(true, true, true, true);
        emit CBX.priceUpdated(5.15 * 10**6);
        vm.expectEmit(true, true, true, true);
        emit CBX.reserveOfCBXChanged(1000);
        
        cbx.mint(10, 5 * 10**6);
        
        // Test purchase event
        vm.startPrank(user1);
        uint256 tokensToBuy = 100;
        uint256 cost = tokensToBuy * cbx.getUSDCPricePerTokenWithFee();
        
        vm.mockCall(
            USDC,
            abi.encodeWithSelector(IERC20.transferFrom.selector, user1, address(cbx), cost),
            abi.encode(true)
        );
        
        vm.expectEmit(true, true, true, true);
        emit CBX.TokensPurchasedWithUSDC(user1, tokensToBuy, cost);
        vm.expectEmit(true, true, true, true);
        emit CBX.reserveOfCBXChanged(900);
        
        cbx.buyTokensWithUSDC(tokensToBuy);
        vm.stopPrank();
    }

    // ============= RETIREMENT TESTS =============
    
    function _setupUsersWithTokens() internal {
        // Mint tokens first
        cbx.mint(100, 5 * 10**6); // 100 credits at $5
        
        // Give tokens to users by having them buy
        address[6] memory users = [user1, user2, user3, user4, user5, user6];
        uint256[6] memory amounts = [uint256(150), 75, 225, 50, 120, 80]; // Various amounts less than 100 except user3
        
        for (uint i = 0; i < users.length; i++) {
            vm.startPrank(users[i]);
            uint256 cost = amounts[i] * cbx.getUSDCPricePerTokenWithFee();
            vm.mockCall(
                USDC,
                abi.encodeWithSelector(IERC20.transferFrom.selector, users[i], address(cbx), cost),
                abi.encode(true)
            );
            cbx.buyTokensWithUSDC(amounts[i]);
            vm.stopPrank();
        }
    }
    
    function testBasicRetirement() public {
        _setupUsersWithTokens();
        
        // User1 retires 150 tokens
        vm.startPrank(user1);
        uint256 balanceBefore = cbx.balanceOf(user1);
        uint256 totalSupplyBefore = cbx.totalSupply();
        
        vm.expectEmit(true, true, true, true);
        emit CBX.TokensQueued(user1, 150);
        
        cbx.retire(150);
        
        // Check tokens were burned
        assertEq(cbx.balanceOf(user1), balanceBefore - 150);
        assertEq(cbx.totalSupply(), totalSupplyBefore - 150);
        
        // Check pending queue
        assertEq(cbx.getPendingCount(), 1);
        vm.stopPrank();
    }
    
    function testRetirementQueueBuildup() public {
        _setupUsersWithTokens();
        
        // Users retire one by one
        address[5] memory users = [user1, user2, user3, user4, user5];
        uint256[5] memory retireAmounts = [uint256(75), 50, 125, 30, 90];
        
        for (uint i = 0; i < users.length; i++) {
            vm.startPrank(users[i]);
            cbx.retire(retireAmounts[i]);
            assertEq(cbx.getPendingCount(), i + 1);
            vm.stopPrank();
        }
        
        // Should have 5 pending retirements now
        assertEq(cbx.getPendingCount(), 5);
    }
    
    function testProcessRetirementsWithoutResidue() public {
        _setupUsersWithTokens();
        
        // Set up retirements that sum to exactly 100
        // user1: 25, user2: 25, user3: 25, user4: 20, user5: 5 = 100 total
        vm.prank(user1); cbx.retire(25);
        vm.prank(user2); cbx.retire(25);
        vm.prank(user3); cbx.retire(25);
        vm.prank(user4); cbx.retire(20);
        vm.prank(user5); cbx.retire(5);
        
        assertEq(cbx.getPendingCount(), 5);
        
        // Process retirements
        vm.expectEmit(true, false, false, false);
        emit CBX.RetirementBundle(1, 100, ""); // bundleId=1, size=100, data doesn't matter for test
        
        cbx.processRetirements();
        
        // Queue should be empty
        assertEq(cbx.getPendingCount(), 0);
        assertEq(cbx.bundleCounter(), 1);
    }
    
    function testProcessRetirementsWithResidue() public {
        _setupUsersWithTokens();
        
        // Set up retirements that sum to 347 (residue = 47)
        // user1: 75, user2: 50, user3: 125, user4: 47, user5: 50 = 347 total
        vm.prank(user1); cbx.retire(75);
        vm.prank(user2); cbx.retire(50);
        vm.prank(user3); cbx.retire(125);
        vm.prank(user4); cbx.retire(47);
        vm.prank(user5); cbx.retire(50);
        
        assertEq(cbx.getPendingCount(), 5);
        
        // Process retirements - should create bundle of 300 and leave 47 in queue
        cbx.processRetirements();
        
        // Should have remainder in queue
        assertEq(cbx.getPendingCount(), 1); // The split remainder
        assertEq(cbx.bundleCounter(), 1);
    }
    
    function testProcessRetirementsWithComplexSplit() public {
        _setupUsersWithTokens();
        
        // Set up retirements that will require splitting the 5th entry
        vm.prank(user1); cbx.retire(30);
        vm.prank(user2); cbx.retire(40);
        vm.prank(user3); cbx.retire(50);
        vm.prank(user4); cbx.retire(50);
        vm.prank(user5); cbx.retire(60);
        
        assertEq(cbx.getPendingCount(), 5);
        
        // Process retirements
        cbx.processRetirements();
        
        assertEq(cbx.bundleCounter(), 1);
        assertEq(cbx.getPendingCount(), 1); // user4's remainder + user5
    }
    
    function testMultipleRetirementBundles() public {
        _setupUsersWithTokens();
        
        // First batch: 5 users with amounts that sum to exactly 200
        vm.prank(user1); cbx.retire(40);
        vm.prank(user2); cbx.retire(40);
        vm.prank(user3); cbx.retire(40);
        vm.prank(user4); cbx.retire(40);
        vm.prank(user5); cbx.retire(40);
        
        cbx.processRetirements();
        assertEq(cbx.bundleCounter(), 1);
        assertEq(cbx.getPendingCount(), 0); // 200 so should be no one in queue.
        
        // Second batch: 5 more users
        vm.prank(user1); cbx.retire(35);
        vm.prank(user2); cbx.retire(35);
        vm.prank(user3); cbx.retire(45); // this one should be split by our algorithm. to have 60 left.
        vm.prank(user4); cbx.retire(10);
        vm.prank(user5); cbx.retire(35);
        
        cbx.processRetirements();
        assertEq(cbx.bundleCounter(), 2);
        assertEq(cbx.getPendingCount(), 3);
    }

    
    function testMultipleComplexRetirementBundles() public {
        _setupUsersWithTokens();
        
        // First batch: 5 users with amounts that sum to exactly 200
        vm.prank(user1); cbx.retire(40);
        vm.prank(user2); cbx.retire(40);
        vm.prank(user3); cbx.retire(40);
        vm.prank(user4); cbx.retire(40);
        vm.prank(user5); cbx.retire(40);
        
        cbx.processRetirements();
        assertEq(cbx.bundleCounter(), 1);
        assertEq(cbx.getPendingCount(), 0); // 200 so should be no one in queue.
        
        // Second batch: 5 more users
        vm.prank(user1); cbx.retire(35);
        vm.prank(user2); cbx.retire(35);
        vm.prank(user3); cbx.retire(45); // this one should be split by our algorithm. to have 60 left.
        vm.prank(user4); cbx.retire(10);
        vm.prank(user5); cbx.retire(35);
        
        cbx.processRetirements();
        assertEq(cbx.bundleCounter(), 2);
        assertEq(cbx.getPendingCount(), 3); // so we should have a queue with 15, 10 and 35 as the only three entries


        
        vm.prank(user3); cbx.retire(139); 
        vm.prank(user1); cbx.retire(1);// brings the total in the queue up to 200
        cbx.processRetirements();
        assertEq(cbx.bundleCounter(), 3);
        assertEq(cbx.getPendingCount(), 0);

    }
    
    function testRetirementAccessControl() public {
        _setupUsersWithTokens();
        
        // Fill queue with 5 retirements
        vm.prank(user1); cbx.retire(30);
        vm.prank(user2); cbx.retire(30);
        vm.prank(user3); cbx.retire(30);
        vm.prank(user4); cbx.retire(30);
        vm.prank(user5); cbx.retire(30);
        
        // Non-owner cannot process retirements
        vm.startPrank(user1);
        vm.expectRevert();
        cbx.processRetirements();
        vm.stopPrank();
        
        // Owner can process
        cbx.processRetirements();
        assertEq(cbx.bundleCounter(), 1);
    }
    
    function testCannotRetireMoreThanBalance() public {
        _setupUsersWithTokens();
        
        // user1 has 150 tokens, try to retire 200
        vm.startPrank(user1);
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, user1, 150, 200));
        cbx.retire(200);
        vm.stopPrank();
    }
    
    function testProcessRetirementsWithInsufficientQueue() public {
        _setupUsersWithTokens();
        
        // Only 3 retirements (less than maxBundleLength=5)
        vm.prank(user1); cbx.retire(50);
        vm.prank(user2); cbx.retire(50);
        vm.prank(user3); cbx.retire(50);
        
        // Should not process anything
        cbx.processRetirements();
        assertEq(cbx.bundleCounter(), 0);
        assertEq(cbx.getPendingCount(), 3);
    }
    
    function testRetirementEventData() public {
        _setupUsersWithTokens();
        
        // Set up simple retirement that sums to 100
        vm.prank(user1); cbx.retire(20);
        vm.prank(user2); cbx.retire(20);
        vm.prank(user3); cbx.retire(20);
        vm.prank(user4); cbx.retire(20);
        vm.prank(user5); cbx.retire(20);
        
        // Process and check that event is emitted with correct data
        vm.recordLogs();
        cbx.processRetirements();
        
        Vm.Log[] memory logs = vm.getRecordedLogs();
        
        // Find the RetirementBundle event
        bool foundEvent = false;
        for (uint i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == keccak256("RetirementBundle(uint256,uint256,bytes)")) {
                foundEvent = true;
                
                // Decode the indexed parameters
                uint256 bundleId = abi.decode(abi.encodePacked(logs[i].topics[1]), (uint256));
                
                // Decode the non-indexed parameters
                (uint256 bundleSize, bytes memory retirementData) = abi.decode(logs[i].data, (uint256, bytes));
                
                assertEq(bundleId, 1);
                assertEq(bundleSize, 100); // Should be divisible by 100
                assertTrue(bundleSize % 100 == 0); // Verify divisibility
                assertTrue(retirementData.length > 0); // Should have data
                break;
            }
        }
        assertTrue(foundEvent, "RetirementBundle event not found");
    }
    
    function testLargeRetirementScenario() public {
        // Mint a lot more tokens for this test
        cbx.mint(500, 5 * 10**6); // 500 credits
        
        // Give users various amounts
        address[6] memory users = [user1, user2, user3, user4, user5, user6];
        uint256[6] memory buyAmounts = [uint256(500), 300, 800, 200, 600, 400];
        
        for (uint i = 0; i < users.length; i++) {
            vm.startPrank(users[i]);
            uint256 cost = buyAmounts[i] * cbx.getUSDCPricePerTokenWithFee();
            vm.mockCall(
                USDC,
                abi.encodeWithSelector(IERC20.transferFrom.selector, users[i], address(cbx), cost),
                abi.encode(true)
            );
            cbx.buyTokensWithUSDC(buyAmounts[i]);
            vm.stopPrank();
        }
        
        // Multiple retirement batches with various patterns
        // Batch 1: odd amounts that will require splitting
        vm.prank(user1); cbx.retire(123);
        vm.prank(user2); cbx.retire(87);
        vm.prank(user3); cbx.retire(156);
        vm.prank(user4); cbx.retire(94);
        vm.prank(user5); cbx.retire(67);
        // Total: 527, residue: 27
        
        cbx.processRetirements();
        assertEq(cbx.bundleCounter(), 1);
        assertTrue(cbx.getPendingCount() > 0); // Should have remainders
        
        // Batch 2: add more to complete another bundle
        vm.prank(user6); cbx.retire(234);
        vm.prank(user1); cbx.retire(145);
        vm.prank(user2); cbx.retire(89);
        vm.prank(user3); cbx.retire(178);
        
        cbx.processRetirements();
        assertEq(cbx.bundleCounter(), 2);
    }
}
