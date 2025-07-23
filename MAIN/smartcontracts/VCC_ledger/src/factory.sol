pragma solidity ^0.8.0;

import "./CBX.sol";

contract Factory {
    event poolsChanged(bytes currentPools);

    uint256 public counter; // increments each time a new pool is made.
    uint256 public fee; // basis points
    address public owner;

    struct Pool {
        uint256 pricePerCredit;
        string serialNumber;
        address poolAddress;
        string countryOfOrigin;
        string methodologies;
        uint256 issuanceDate; // in block.timestamp notation
        uint256 createdAt;
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
        string memory serialNumber,
        string memory countryOfOrigin,
        string memory methodologies,
        uint256 issuanceDate,
        uint256 initialSupply,
        address sellerAddress
    ) external onlyOwner returns (address) {
        CBX poolContract = new CBX(fee, initialSupply, pricePerCredit, msg.sender, sellerAddress, serialNumber, counter);
        counter++;
        Pool memory pool = Pool({
            pricePerCredit: pricePerCredit,
            serialNumber: serialNumber,
            poolAddress: address(poolContract),
            countryOfOrigin: countryOfOrigin,
            methodologies: methodologies,
            issuanceDate: issuanceDate,
            createdAt: block.timestamp
        });
        pools.push(pool);
        bytes memory poolsAsBytes = abi.encode(pools);
        emit poolsChanged(poolsAsBytes);
        return address(poolContract);
    }
}
