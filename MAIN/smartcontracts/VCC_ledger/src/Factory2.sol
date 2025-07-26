
pragma solidity ^0.8.0;

import "./CBX2.sol";
// ADDED SOME MORE DATA TO THE POOL STRUCTS AND BETTER VIEW FUNCTIONS COMPARED TO factory.sol
contract Factory {
    event poolsChanged(bytes currentPools); 

    uint256 public counter; // increments each time a new pool is made.
    uint256 public fee; // basis points
    address public owner;

    struct Pool {
        string name;
        string serialNumber;
        address poolAddress;
        string countryOfOrigin;
        string methodologies;
        string Registry;
        string URL;
        uint256 issuanceDate; // in block.timestamp notation
        uint256 createdAt;
        bool isActive;
    }

    Pool[] public pools;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(uint256 _fee) {
        // our fee in basis points.
        owner = msg.sender;
        fee = _fee;
    }

    function emitPoolsChanged() internal {
        bytes memory poolsAsBytes = abi.encode(pools);
        emit poolsChanged(poolsAsBytes);
    }

    function createPool(
        uint256 pricePerCredit,
        string memory name,
        string memory serialNumber,
        string memory countryOfOrigin,
        string memory methodologies,
        string memory registry,
        string memory url,
        uint256 issuanceDate,
        uint256 initialSupply,
        address sellerAddress
    ) external onlyOwner returns (address) {
        CBX poolContract = new CBX(fee, initialSupply, pricePerCredit, msg.sender, sellerAddress, serialNumber, counter);
        counter++;
        Pool memory pool = Pool({
            name: name,
            serialNumber: serialNumber,
            poolAddress: address(poolContract),
            countryOfOrigin: countryOfOrigin,
            methodologies: methodologies,
            Registry: registry,
            URL: url,
            issuanceDate: issuanceDate,
            createdAt: block.timestamp,
            isActive: true
        });
        pools.push(pool);
        bytes memory poolsAsBytes = abi.encode(pools);
        emit poolsChanged(poolsAsBytes);
        return address(poolContract);
    }


    function getPools() external view returns (Pool[] memory) {
       return pools; 
    }
    
    function markPoolInactive(address addressToDeactivate) external onlyOwner {
        for (uint i = 0; i < pools.length; i++) {
            if (pools[i].poolAddress  == addressToDeactivate) {
              pools[i].isActive = false;
            }
        }
    }
}
