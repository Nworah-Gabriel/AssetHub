// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/proxy/Proxy.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";

/**
 * @title VendorProxy
 * @dev Proxy contract to delegate calls to an implementation contract.
 */
contract VendorProxy is Proxy {

    error InvalidImplementation(string message);
    /**
     * @dev Initializes the proxy with the initial implementation address.
     * @param _logic The address of the initial implementation.
     */
    constructor(address _logic) payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = _logic;
    }

    // Storage slot with the address of the current implementation.
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Returns the address of the current implementation.
     */
    function _implementation() internal view override returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @notice Upgrade the implementation of the proxy to a new address.
     * @param newImplementation The address of the new implementation.
     */
    function upgradeTo(address newImplementation) external {
        if (newImplementation.code.length != 0){
           revert InvalidImplementation("New implementation invalid");
        }
    StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
}

 receive() external payable { }
}
