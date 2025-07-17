// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/CBX.sol";

contract CBXTest is Test {
    CBX public cbx;
    
    address public owner;
    address public user1;
    address public user2;
    
    uint256 constant INITIAL_FEE = 300; // 3% fee
    
    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        cbx = new CBX(INITIAL_FEE);
    }
    
    function testInitialState() public {
        assertEq(cbx.owner(), owner);
        assertEq(cbx.fee(), INITIAL_FEE);
        assertEq(cbx.reserves(), 0);
        assertEq(cbx.pricePerToken(), 0);
        assertEq(cbx.totalSupply(), 0);
    }
    
    function testMinting() public {
        uint256 amountToMint = 1000;
        uint256 pricePerCredit = 500; // $5.00 in cents
        
        cbx.mint(amountToMint, pricePerCredit);
        
        assertEq(cbx.totalSupply(), amountToMint);
        assertEq(cbx.reserves(), amountToMint);
        assertEq(cbx.pricePerToken(), pricePerCredit);
        assertEq(cbx.balanceOf(address(cbx)), amountToMint);
        
        uint256 priceWithFee = cbx.getPricePerTokenWithFee();
        assertEq(priceWithFee, 515); 
    }
    
    
    
    function testPriceCalculation() public {
        // Test weighted average price calculation
        cbx.mint(1000, 500); // 1000 CBX at $5.00
        assertEq(cbx.pricePerToken(), 500);
        
        cbx.mint(1000, 600); // Another 1000 CBX at $6.00
        // New price should be: (500*1000 + 600*1000) / 2000 = 550
        assertEq(cbx.pricePerToken(), 550);
        assertEq(cbx.reserves(), 2000);
    }
    
    function testFeeCalculation() public {
        cbx.mint(1000, 500);
        
        uint256 basePrice = cbx.pricePerToken(); // 500
        uint256 priceWithFee = cbx.getPricePerTokenWithFee();
        
        // 3% fee
        assertEq(priceWithFee, 515);
        
        // Test fee change
        cbx.setFee(500); // 5% fee
        uint256 newPriceWithFee = cbx.getPricePerTokenWithFee();
        assertEq(newPriceWithFee, 525); 
    }
    
    function testPurchaseWillFailWithoutUSDC() public {
        cbx.mint(100, 500);
        
        vm.startPrank(user1);
        
        // This will fail because user1 has no USDC
        vm.expectRevert();
        cbx.buyTokensWithUSDC(10);
        
        vm.stopPrank();
    }
    
    function testAccessControl() public { // a bit pointless imo but good for piece of mind
        // Non-owner cannot mint
        vm.startPrank(user1);
        vm.expectRevert();
        cbx.mint(100, 500);
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
    

    
    function testMathConsistency() public {
        // Test multiple mints affect price correctly
        cbx.mint(100, 400); // 100 CBX at $4.00
        cbx.mint(200, 500); // 200 CBX at $5.00  
        cbx.mint(300, 600); // 300 CBX at $6.00
        
        // Expected weighted average: (100*400 + 200*500 + 300*600) / 600
        // = (40000 + 100000 + 180000) / 600 = 320000 / 600 = 533 (integer division)
        uint256 totalCost = (100 * 400) + (200 * 500) + (300 * 600);
        uint256 totalTokens = 100 + 200 + 300;
        uint256 expectedPrice = totalCost / totalTokens;
        
        assertEq(cbx.pricePerToken(), expectedPrice);
        assertEq(cbx.reserves(), 600);
        assertEq(cbx.totalSupply(), 600);
    }
    
    function testZeroInitialReserves() public {
        // Test minting when reserves are zero
        cbx.mint(500, 300);
        assertEq(cbx.pricePerToken(), 300);
        assertEq(cbx.reserves(), 500);
    }
    
    function testFeeEdgeCases() public {
        // Test 0% fee
        cbx.setFee(0);
        cbx.mint(100, 500);
        assertEq(cbx.getPricePerTokenWithFee(), 500);
        
        // Test 10% fee
        cbx.setFee(1000); // 10% in basis points
        assertEq(cbx.getPricePerTokenWithFee(), 550); // 500 * 1.1 = 550
    }
    
    function testReservesUpdateCorrectly() public {
        cbx.mint(1000, 500);
        assertEq(cbx.reserves(), 1000);
        
        // Add more tokens
        cbx.mint(500, 600);
        assertEq(cbx.reserves(), 1500);
        assertEq(cbx.totalSupply(), 1500);
        assertEq(cbx.balanceOf(address(cbx)), 1500);
    }
    
    function testPriceCannotBeZero() public {
        // Cannot mint at price 0
        vm.expectRevert("THIS IS WAY TOO LOW, did you remember to enter the amount in cents not dollars?");
        cbx.mint(100, 0);
        
        // Cannot mint at very low price
        vm.expectRevert("THIS IS WAY TOO LOW, did you remember to enter the amount in cents not dollars?");
        cbx.mint(100, 50);
    }
}
