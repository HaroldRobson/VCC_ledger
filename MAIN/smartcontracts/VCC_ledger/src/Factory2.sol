
pragma solidity ^0.8.0;

import "./CBX2.sol";
// ADDED SOME MORE DATA TO THE POOL STRUCTS AND BETTER VIEW FUNCTIONS COMPARED TO factory.sol
contract Factory {
    event poolsChanged(bytes currentPools); 

    uint256 public counter; // increments each time a new pool is made.
    uint256 public fee; // basis points
    address public owner;

    struct Pool { // <--NOTE--> all bytes32 here are converted from strings and must be converted back in the frontend. 
        bytes32 name;
        bytes32 serialNumber;
        address poolAddress;
        uint8 countryOfOrigin; //ISO code
        bytes32 methodologies;
        bytes32 Registry;
        bytes32 URL;
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
        uint8 countryOfOrigin,
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
            name: stringToBytes32(name),
            serialNumber: stringToBytes32(serialNumber),
            poolAddress: address(poolContract),
            countryOfOrigin: countryOfOrigin,
            methodologies: stringToBytes32(methodologies),
            Registry: stringToBytes32(registry),
            URL: stringToBytes32(url),
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


function stringToBytes32(string memory source) public pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
        return 0x0;
    }

    assembly {
        result := mload(add(source, 32))
    }
}


}
