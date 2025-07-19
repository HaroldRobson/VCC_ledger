pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CBX is ERC20 {

    address public owner;
    uint256 public reserves; //This is in 100 times the total amount of tokens. IE 1 reserver = 0.01 token.
    uint256 public pricePerToken; // IN 10^6 of a USD!!
    address USDC;
    uint256 public fee; // in basis points eg 300 = 3% fee
    IERC20 USDCtokens; 

    event newCreditsPurchased(uint256 amountOfNewTokens, uint256 pricePayedPerNewToken);
    event tokensMinted(uint256 amountOfNewTokens);
    event priceUpdated(uint256 newPrice);
    event feesUpdated(uint256 fee);
    event withdrawnUSDC(uint256 amount);
    event TokensPurchasedWithUSDC(address indexed buyer, uint256 amount, uint256 cost);
    event reserveOfCBXChanged(uint256 newReserve);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

          constructor(uint256 _fee) ERC20("CBX carbon credit", "CBX"){
              owner = msg.sender;  
              USDC = 0x796Ea11Fa2dD751eD01b53C372fFDB4AAa8f00F9; // ETHERLINK address of USDC - NOT!!!!! mainnet
              fee = _fee;
              USDCtokens = IERC20(USDC);
          }

    function decimals() public view virtual override returns (uint8) {
    return 2;
}
  function mint(uint256 amountOfCreditsIn, uint256 pricePayedPerNewCredit) public onlyOwner {
      // pricePayedPerNewCredit is in USDC. Ie if we paid 10 dollars per credit it would be 10e6
      // amount is the number of credits we purchased (Ie the number of Tonnes of CO2)
      uint256 amountOfCBXIn = amountOfCreditsIn * 1e2;
      require(pricePayedPerNewCredit > 2e6, "THIS IS WAY TOO LOW, did you remember to enter the amount in cents not dollars?");
      require(amountOfCBXIn > 0, "MUST ENTER  A NON ZERO AMOUNT OF NEW TOKENS");
      emit newCreditsPurchased(amountOfCreditsIn, pricePayedPerNewCredit); 

      uint256 newPrice;
      if (reserves == 0) {
        newPrice = pricePayedPerNewCredit / 1e2;
      } else {
        newPrice = ((pricePerToken * reserves) + (pricePayedPerNewCredit * amountOfCBXIn / 1e2)) / (reserves + (amountOfCBXIn)); // update the new price of tokens in the pool to always be whatever they cost usjj
      }
      pricePerToken = newPrice;
      uint256 newPricePerTokenWithFee = getUSDCPricePerCreditWithFee();
      emit priceUpdated(newPricePerTokenWithFee);
      _mint(address(this),amountOfCBXIn); 
      reserves += amountOfCBXIn;
      emit reserveOfCBXChanged(reserves);
  }


  function getUSDCPricePerCreditWithFee() public view returns (uint256) {
    return (pricePerToken * (1e4 + fee)) / 1e2; // 100 times price per token
  }
  function getUSDCPricePerTokenWithFee() public view returns (uint256) {
      return (pricePerToken * (1e4 + fee)) / 1e4;
  }

  function withDrawUSDC() public onlyOwner { // only withdraw to the deployment contract.
      uint amount = USDCtokens.balanceOf(address(this));
      USDCtokens.transfer(owner, amount);
      emit withdrawnUSDC(uint256(amount));
  }

  function buyTokensWithUSDC(uint256 amountOfCBXOut) external {// should be 100 times the tota number of credits the user wants
        require(amountOfCBXOut <= reserves, "We don't have enough carbon credits in our pool");
        uint256 pricePerTokenWithFee = getUSDCPricePerTokenWithFee();
        uint256 costInUSDC = amountOfCBXOut * pricePerTokenWithFee;
        require(USDCtokens.transferFrom(msg.sender, address(this), costInUSDC), "ALERT: TRANSFERFAILED"); // this requires the customer to call (IERC20(USDC_ADDRESS)).approve(address(this), amountOfCBXOut * getPricePerTokenWithFee())
        _transfer(address(this), msg.sender, amountOfCBXOut); 
        emit TokensPurchasedWithUSDC(msg.sender, amountOfCBXOut, costInUSDC);
        //update our State:
        reserves -= amountOfCBXOut;
        emit reserveOfCBXChanged(reserves);
  }

  function setFee(uint256 _fee) onlyOwner external { // in basis point
      fee = _fee;
  }









  ///////////THE REMAINING CODE IS FOR RETIREMENT


struct PendingRetirement {
    uint256 tokens; 
    address user; // can have one user or many
    uint256 timestamp;
}

    PendingRetirement[] memory pendingRetirementQueue;
    PendingRetirement[] memory retirementBundle;
    function split(uint256 index, uint256 sizeOfAmountToRemove) {
           PendingRetirement retirementToSplit = PendingRetirementQueue[i];  
           PendingRetirement stayForNextBatch = PendingRetirement({
               tokens: retirementToSplit.tokens - sizeOfAmountToRemove,
               user: retirementToSplit.user,
               timestamp: retirementToSplit.timestamp
           });
           PendingRetirement addToBundle = PendingRetirement({
               tokens: sizeOfAmountToRemove,
               user: retirementToSplit.user,
               timestamp: retirementToSplit.timestamp
           });
            
           pendingRetirementQueue[index] = stayForNextBatch;
           retirementBundle[0] = addToBundle; 
    }
// Events
event TokensQueued(address indexed user, uint256 tokens);
event RetirementBundle(uint256 indexed bundleId, uint256 bundleSize, address[] users, uint256[] contributions);

uint256 public bundleCounter;

// User queues credits for retirement
function retire(uint256 amountOfTokens) external {
    
    
    // Burn the tokens immediately
    _burn(msg.sender, amountOfTokens);
    
    // Add to pending queue
    pendingRetirements.push(PendingRetirement({
        tokens: amountOfTokens,
        user: msg.sender,
        timestamp: block.timestamp
    }));
    
    emit CreditsQueued(msg.sender, amountOfTokens);
}

// Process retirements into bundles (call periodically)
function processRetirements() external onlyOwner {
    if (pendingRetirements.length == 0) return;
    
    // First, try to make bundles of 20
    _processBundles(20);
    
    // Then, combine remaining into bundles of 100
    _processBundles(100);
}

function _processBundles(uint256 targetSize) private {
    uint256 currentBundleSize = 0;
    address[] memory bundleUsers = new address[](pendingRetirements.length);
    uint256[] memory bundleContributions = new uint256[](pendingRetirements.length);
    uint256 bundleUserCount = 0;
    
    uint256 i = 0;
    while (i < pendingRetirements.length) {
        PendingRetirement memory pending = pendingRetirements[i];
        
        if (currentBundleSize + pending.credits <= targetSize) {
            // Add to current bundle
            bundleUsers[bundleUserCount] = pending.user;
            bundleContributions[bundleUserCount] = pending.credits;
            bundleUserCount++;
            currentBundleSize += pending.credits;
            
            // Remove from pending by swapping with last element
            pendingRetirements[i] = pendingRetirements[pendingRetirements.length - 1];
            pendingRetirements.pop();
            
            // Check if bundle is complete
            if (currentBundleSize == targetSize) {
                _emitBundle(targetSize, bundleUsers, bundleContributions, bundleUserCount);
                currentBundleSize = 0;
                bundleUserCount = 0;
            }
        } else {
            i++;
        }
    }
}


function 

function _emitBundle(
    uint256 size,
    address[] memory users,
    uint256[] memory contributions,
    uint256 count
) private {
    // Create properly sized arrays
    address[] memory finalUsers = new address[](count);
    uint256[] memory finalContributions = new uint256[](count);
    
    for (uint256 i = 0; i < count; i++) {
        finalUsers[i] = users[i];
        finalContributions[i] = contributions[i];
        userPendingCredits[finalUsers[i]] -= finalContributions[i];
    }
    
    bundleCounter++;
    emit RetirementBundle(bundleCounter, size, finalUsers, finalContributions);
}

// View pending retirements
function getPendingCount() external view returns (uint256) {
    return pendingRetirements.length;
}


}
