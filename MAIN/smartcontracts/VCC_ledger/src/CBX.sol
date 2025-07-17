pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CBX is ERC20 {

    address public owner;
    uint256 public reserves;
    uint256 public pricePerToken; // IN CENTS!!
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

  function mint(uint256 amountOfCBXIn, uint256 pricePayedPerNewCredit) public onlyOwner {
      // pricePayedPerNewCredit is in CENTS !!!! snd it is whatever we paid for the new tokens we are adding to the pool if we paid US dollars, NOT GBP!
      // amount is the number of credits we purchased (Ie the number of Tonnes of CO2)
      require(pricePayedPerNewCredit > 200, "THIS IS WAY TOO LOW, did you remember to enter the amount in cents not dollars?");
      require(amountOfCBXIn > 0, "MUST ENTER  A NON ZERO AMOUNT OF NEW TOKENS");
      
      emit newCreditsPurchased(amountOfCBXIn, pricePayedPerNewCredit); 

      uint256 newPrice;
      if (reserves == 0) {
        newPrice = pricePayedPerNewCredit;
      } else {
        newPrice = ((pricePerToken * reserves) + (pricePayedPerNewCredit * amountOfCBXIn)) / (reserves + amountOfCBXIn); // update the new price of tokens in the pool to always be whatever they cost us
      }
      pricePerToken = newPrice;
      uint256 newPricePerTokenWithFee = getPricePerTokenWithFee();
      emit priceUpdated(newPricePerTokenWithFee);
      
      _mint(address(this), amountOfCBXIn); 
      reserves += amountOfCBXIn;
      emit reserveOfCBXChanged(reserves);
  }


  function getPricePerTokenWithFee() public view returns (uint256) {
    return (pricePerToken * (10000 + fee)) / 10000;
  }


  function withDrawUSDC() public onlyOwner { // only withdraw to the deployment contract.
      uint amount = USDCtokens.balanceOf(address(this));
      USDCtokens.transfer(owner, amount);
      emit withdrawnUSDC(uint256(amount));
  }

  function buyTokensWithUSDC(uint256 amountOfCBXOut) external {
        require(amountOfCBXOut <= reserves, "We don't have enough carbon credits in our pool");
        uint256 pricePerTokenWithFee = getPricePerTokenWithFee();
        uint256 costInUSDC = amountOfCBXOut * pricePerTokenWithFee;
        require(USDCtokens.transferFrom(msg.sender, address(this), costInUSDC), "ALERT: TRANSFERFAILED"); // this requires the customer to call (IERC20(USDC_ADDRESS)).approve(address(this), amountOfCBXOut * getPricePerTokenWithFee())
        _transfer(address(this), msg.sender, amountOfCBXOut); 
        emit TokensPurchasedWithUSDC(msg.sender, amountOfCBXOut, costInUSDC);
        //update our State:
        reserves -= amountOfCBXOut;
        emit reserveOfCBXChanged(reserves);
  }

  function setFee(uint256 _fee) onlyOwner external {
      fee = _fee;
  }

}
