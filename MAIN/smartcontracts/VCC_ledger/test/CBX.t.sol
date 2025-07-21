// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/CBX.sol";

contract CBXTest is Test {
    CBX public cbx;
    
    address public owner;
    address public user1;
    address public user2;
    
    // USDC address from your contract
    address constant USDC = 0x796Ea11Fa2dD751eD01b53C372fFDB4AAa8f00F9;
    uint256 constant INITIAL_FEE = 300; // 3% fee
    
    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
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
}
