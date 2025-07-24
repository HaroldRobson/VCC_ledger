pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "forge-std/console.sol";

contract CBX is ERC20 {
    address public owner;
    address public seller;
    uint256 public reserves; //This is in 100 times the total amount of tokens. IE 1 reserver = 0.01 token.
    uint256 public pricePerToken; // IN 10^6 of a USD!!
    address USDC;
    uint256 public fee; // in basis points eg 300 = 3% fee. applied only to purchases
    uint256 public constant RETIREMET_GAS_FEE = 0.005 ether; // so retirers cover the cost of the owner the processRetirements() function
    uint256 sellerProfit;
    uint256 feesCollected;
    IERC20 USDCtokens;

    event newCreditsPurchased(uint256 amountOfNewTokens, uint256 pricePayedPerNewToken);
    event tokensMinted(uint256 amountOfNewTokens);
    event priceUpdated(uint256 newPrice);
    event feesUpdated(uint256 fee);
    event withdrawnUSDC(uint256 amount);
    event TokensPurchasedWithUSDC(address indexed buyer, uint256 amount, uint256 cost);
    event reserveOfCBXChanged(uint256 newReserve);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller);
        _;
    }

    constructor(
        uint256 _fee,
        uint256 amountOfCredits,
        uint256 pricePerCredit,
        address Owner,
        address Seller,
        string memory serialNumber,
        uint256 index
    ) ERC20(serialNumber,  string(abi.encodePacked("CBX", Strings.toString(index))))  {
        owner = Owner;
        seller = Seller;
        USDC = 0x4C2AA252BEe766D3399850569713b55178934849; // CHANGE BACK TO ETHERLINK address of USDC - NOT!!!!! ETHERERUM mainnet
        fee = _fee;
        USDCtokens = IERC20(USDC);
        initialMint(amountOfCredits, pricePerCredit);
    }

    function decimals() public view virtual override returns (uint8) {
        return 2;
    }

    function initialMint(uint256 amountOfCreditsIn, uint256 pricePayedPerNewCredit) private {
        // pricePayedPerNewCredit is in USDC. Ie if we paid 10 dollars per credit it would be 10e6
        // amount is the number of credits we purchased (Ie the number of Tonnes of CO2)
        uint256 amountOfCBXIn = amountOfCreditsIn * 1e2;
        require(
            pricePayedPerNewCredit > 2e6,
            "THIS IS WAY TOO LOW, did you remember to enter the amount in cents not dollars?"
        );
        require(amountOfCBXIn > 0, "MUST ENTER  A NON ZERO AMOUNT OF NEW TOKENS");
        emit newCreditsPurchased(amountOfCreditsIn, pricePayedPerNewCredit);

        uint256 newPrice;
        if (reserves == 0) {
            newPrice = pricePayedPerNewCredit / 1e2;
        } else {
            newPrice = ((pricePerToken * reserves) + (pricePayedPerNewCredit * amountOfCBXIn / 1e2))
                / (reserves + (amountOfCBXIn)); // update the new price of tokens in the pool to always be whatever they cost usjj
        }
        pricePerToken = newPrice;
        uint256 newPricePerTokenWithFee = getUSDCPricePerCreditWithFee();
        emit priceUpdated(newPricePerTokenWithFee);
        _mint(address(this), amountOfCBXIn);
        reserves += amountOfCBXIn;
        emit reserveOfCBXChanged(reserves);
    }

    function mint(uint256 amountOfCreditsIn, uint256 pricePayedPerNewCredit) public onlySeller {
        // pricePayedPerNewCredit is in USDC. Ie if we paid 10 dollars per credit it would be 10e6
        // amount is the number of credits we purchased (Ie the number of Tonnes of CO2)
        uint256 amountOfCBXIn = amountOfCreditsIn * 1e2;
        require(
            pricePayedPerNewCredit > 2e6,
            "THIS IS WAY TOO LOW, did you remember to enter the amount in cents not dollars?"
        );
        require(amountOfCBXIn > 0, "MUST ENTER  A NON ZERO AMOUNT OF NEW TOKENS");
        emit newCreditsPurchased(amountOfCreditsIn, pricePayedPerNewCredit);

        uint256 newPrice;
        if (reserves == 0) {
            newPrice = pricePayedPerNewCredit / 1e2;
        } else {
            newPrice = ((pricePerToken * reserves) + (pricePayedPerNewCredit * amountOfCBXIn / 1e2))
                / (reserves + (amountOfCBXIn)); // update the new price of tokens in the pool to always be whatever they cost usjj
        }
        pricePerToken = newPrice;
        uint256 newPricePerTokenWithFee = getUSDCPricePerCreditWithFee();
        emit priceUpdated(newPricePerTokenWithFee);
        _mint(address(this), amountOfCBXIn);
        reserves += amountOfCBXIn;
        emit reserveOfCBXChanged(reserves);
    }

    function getUSDCPricePerCreditWithFee() public view returns (uint256) {
        return (pricePerToken * (1e4 + fee)) / 1e2; // 100 times price per token
    }

    function getUSDCPricePerTokenWithFee() public view returns (uint256) {
        return (pricePerToken * (1e4 + fee)) / 1e4;
    }

    function withDrawRemainingUSDC() public onlyOwner {
        // in case there is some left over - this is no longer 0 trust since sellers would have to trust we do not call this before them.
        // But was this 0 trust to begin with?
        uint256 amount = USDCtokens.balanceOf(address(this));
        USDCtokens.transfer(owner, amount);
        emit withdrawnUSDC(uint256(amount)); // maybe remove this function entirely?
    }

    function withDrawUSDCFees() public onlyOwner {
        USDCtokens.transfer(owner, feesCollected);
        feesCollected = 0;
    }

    function withDrawUSDCProfits() public onlySeller {
        console.log("Verifying USDC token address:", address(USDCtokens));
        console.log("USDC TOTAL IN POOL:");
        console.logUint(USDCtokens.balanceOf(address(this)));
        console.log("SELLERS PROFITS");
        console.logUint(sellerProfit);
        console.log("FEES COLLECTED");
        console.logUint(feesCollected);
        // require(sellerProfit + feesCollected >= USDCtokens.balanceOf(address(this)), "not enough usdc in pool"); // was causing integer division issues sadly - literally the same numbers would return false.
        USDCtokens.transfer(seller, sellerProfit);
        sellerProfit = 0;
    }

    function buyTokensWithUSDC(uint256 amountOfCBXOut) external {
        // should be 100 times the tota number of credits the user wants
        require(amountOfCBXOut <= reserves, "We don't have enough carbon credits in our pool");
        uint256 pricePerTokenWithFee = getUSDCPricePerTokenWithFee();
        uint256 costInUSDC = amountOfCBXOut * pricePerTokenWithFee;
        require(USDCtokens.transferFrom(msg.sender, address(this), costInUSDC), "ALERT: TRANSFERFAILED"); // this requires the customer to call (IERC20(USDC_ADDRESS)).approve(address(this), amountOfCBXOut * getPricePerTokenWithFee())
        _transfer(address(this), msg.sender, amountOfCBXOut);
        sellerProfit += costInUSDC * 1e4 / (1e4 + fee);
        feesCollected += costInUSDC * fee / (1e4 + fee);
        emit TokensPurchasedWithUSDC(msg.sender, amountOfCBXOut, costInUSDC);
        //update our State:
        reserves -= amountOfCBXOut;
        emit reserveOfCBXChanged(reserves);
    }

    function setFee(uint256 _fee) external onlyOwner {
        // in basis point
        fee = _fee;
    }

    ///////////THE REMAINING CODE IS FOR RETIREMENT

    struct PendingRetirement {
        uint256 tokens;
        address user;
        uint256 timestamp;
    }

    PendingRetirement[] public pendingRetirementQueue;
    PendingRetirement[] public retirementBundle;

    function split(uint8 index, uint256 sizeOfAmountToRemove) internal {
        PendingRetirement memory retirementToSplit = pendingRetirementQueue[index];
        PendingRetirement memory stayForNextBatch = PendingRetirement({
            tokens: retirementToSplit.tokens - sizeOfAmountToRemove,
            user: retirementToSplit.user,
            timestamp: retirementToSplit.timestamp
        });
        PendingRetirement memory addToBundle = PendingRetirement({
            tokens: sizeOfAmountToRemove,
            user: retirementToSplit.user,
            timestamp: retirementToSplit.timestamp
        });

        pendingRetirementQueue[index] = stayForNextBatch

    // Process retirements into bundles (called by owner periodically)
    function processRetirements() public onlyOwner { 
        require(pendingRetirementQueue.length != 0, "QUEUE IS TOO SMALL");
        uint8 maxBundleLength = uint8(pendingRetirementQueue.length);
        if (pendingRetirementQueue.length < maxBundleLength) return;
        uint256 totalTokens = 0; // total tokens in our proposed bundle (will most likely NOT be divisble by 100)
        uint256 residue; // residue mod 100
        for (uint256 i = 0; i < maxBundleLength; i++) {
            totalTokens += pendingRetirementQueue[i].tokens;
        }

        residue = totalTokens % 100;
        uint256 totalToKeep = 0;
        uint8 indexToSplit;
        if (residue != 0) {
            indexToSplit = maxBundleLength;
            while (totalToKeep < residue) {
                if (indexToSplit == 0) {
                return;
            }
                indexToSplit -= 1;
                totalToKeep += pendingRetirementQueue[indexToSplit].tokens; // "totalToKeep" counts backwards until it overshoots the residue. We then split the PendingRetirement to account for this.
            }
            split(indexToSplit, totalToKeep - residue);
        } else {
            indexToSplit = maxBundleLength;
        }
        uint256 retirementTotal = 0;
        for (uint256 i = 0; i < indexToSplit; i++) {
            retirementTotal += pendingRetirementQueue[i].tokens;
            retirementBundle.push(pendingRetirementQueue[i]);
        }
        if (residue != 0) {
            retirementTotal += totalToKeep - residue; // if we did do a split, make sure it is accounted for.
        }
        require(totalTokens - residue == retirementTotal, "SOMETHING DOESNT ADD UP!");
        bundleCounter++;
        bytes memory retirementData = abi.encode(retirementBundle);
        emit RetirementBundle(bundleCounter, retirementTotal, retirementData, address(this)); // retirementTotal should be divisible by 100
        delete retirementBundle;
        for (uint256 i = 0; i < pendingRetirementQueue.length - indexToSplit; i++) {
            pendingRetirementQueue[i] = pendingRetirementQueue[i + indexToSplit]; // shift entire queue forward.
        }
        for (uint256 i = 0; i < indexToSplit; i++) {
            pendingRetirementQueue.pop(); // remove duplicates
        }
        return;
    }

    // View pending retirements
    function getPendingCount() external view returns (uint256) {
        return pendingRetirementQueue.length;
    }
}
