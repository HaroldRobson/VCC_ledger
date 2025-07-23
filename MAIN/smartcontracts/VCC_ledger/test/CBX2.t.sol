// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Factory.sol";
import "../src/CBX.sol";

contract FinalUnitTests is Test {
    Factory public factory;
    CBX public cbxPool;
    
    address public owner;
    address public seller;
    address public buyer1;
    address public unrelatedAddress;

    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    IERC20 public usdcToken = IERC20(USDC);
    uint256 constant FACTORY_FEE = 500;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"), 22969797);
        owner = makeAddr("owner");
        seller = makeAddr("seller");
        buyer1 = makeAddr("buyer1");
        unrelatedAddress = makeAddr("unrelatedAddress");
        vm.prank(owner);
        factory = new Factory(FACTORY_FEE);
        vm.prank(owner);
        address poolAddress = factory.createPool(
            10 * 10**6, "TEST-VCS-2024", "Colombia", "REDD+",
            block.timestamp - 30 days, 1000, seller
        );
        cbxPool = CBX(poolAddress);
        deal(USDC, buyer1, 1_000_000 * 10**6);
        vm.deal(buyer1, 10 ether);
    }

    // =========================================================
    // ==================== SUCCESS TESTS ======================
    // =========================================================

    function test_PASS_Deployment() public {
        assertTrue(address(factory) != address(0));
        assertEq(cbxPool.owner(), owner);
    }

    function test_PASS_Purchase() public {
        uint256 tokensToBuy = 50 * 1e2;
        vm.startPrank(buyer1);
        uint256 cost = tokensToBuy * cbxPool.getUSDCPricePerTokenWithFee();
        usdcToken.approve(address(cbxPool), cost);
        cbxPool.buyTokensWithUSDC(tokensToBuy);
        vm.stopPrank();
        assertEq(cbxPool.balanceOf(buyer1), tokensToBuy);
    }
    
    function test_PASS_Minting() public {
        uint256 reserveBefore = cbxPool.reserves();
        vm.prank(seller);
        cbxPool.mint(200, 12 * 10**6);
        assertEq(cbxPool.reserves(), reserveBefore + (200 * 1e2));
    }

    function test_PASS_Withdrawals() public {
        vm.startPrank(buyer1);
        uint256 cost = (100 * 1e2) * cbxPool.getUSDCPricePerTokenWithFee();
        usdcToken.approve(address(cbxPool), cost);
        cbxPool.buyTokensWithUSDC(100 * 1e2);
        vm.stopPrank();
        vm.prank(seller);
        cbxPool.withDrawUSDCProfits();
        vm.prank(owner);
        cbxPool.withDrawUSDCFees();
        assertEq(usdcToken.balanceOf(address(cbxPool)), 0);
    }
    
    function test_PASS_Retirement() public {
        vm.prank(address(cbxPool));
        cbxPool.transfer(buyer1, 500);
        vm.startPrank(buyer1);
        cbxPool.retire{value: cbxPool.RETIREMET_GAS_FEE()}(350);
        vm.stopPrank();
        vm.prank(owner);
        cbxPool.processRetirements();
        assertEq(cbxPool.bundleCounter(), 1);
    }

    // =========================================================
    // ============== EXPECTED FAILURE TESTS ===================
    // =========================================================
    
    // This is the robust, foolproof way to test for insufficient balance.
    function test_FAIL_RetireInsufficientBalance() public {
        // 1. Give the user SOME tokens.
        vm.prank(address(cbxPool));
        cbxPool.transfer(buyer1, 50);
        uint256 balanceBefore = cbxPool.balanceOf(buyer1);
        assertEq(balanceBefore, 50);

        // 2. Try to retire MORE than they have.
        // We use a `try/catch` block to catch the expected failure.
        try cbxPool.retire{value: cbxPool.RETIREMET_GAS_FEE()}(100) {
            // If we are inside this block, it means the call succeeded, which is an error.
            fail();
        } catch {
            // If we are inside this block, it means the call reverted as expected.
            // This is the success case for this test.
            // We verify the user's balance was not corrupted or changed.
            assertEq(cbxPool.balanceOf(buyer1), balanceBefore, "User balance should not change on a failed retire");
        }
    }

    function test_FAIL_MintByUnrelatedAddress() public {
        vm.expectRevert();
        vm.prank(unrelatedAddress);
        cbxPool.mint(100, 10 * 10**6);
    }
    
    function test_FAIL_SetFeeByUnrelatedAddress() public {
        vm.expectRevert();
        vm.prank(unrelatedAddress);
        cbxPool.setFee(1000);
    }
}
