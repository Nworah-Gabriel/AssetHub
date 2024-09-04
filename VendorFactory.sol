// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./VendorERC1155.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title VendorFactory
 * @dev Contract for creating and managing vendor shops.
 */
contract VendorFactory is ReentrancyGuard {
    mapping(address Vendor => address[] shop) public vendorShops;
    event createdShop(address shopAddress, address vendorAddress);

    constructor() payable {}

    /**
     * @notice Creates a new Vendor shop.
     * @param uri The base URI for all token types in the Vendor shop.
     * @return The address of the new VendorERC1155 contract.
     */
    function createVendor(string memory uri) public nonReentrant returns (address) {
        VendorERC1155 newVendor = new VendorERC1155(uri);
        newVendor.transferOwnership(msg.sender);
        vendorShops[msg.sender].push(address(newVendor));
        emit createdShop(msg.sender, address(newVendor));
        return address(newVendor);
    }

    /**
     * @notice Retrieves all shops owned by a specific owner.
     * @param owner The address of the owner.
     * @return The array of Vendor addresses.
     */
    function getVendors(address owner) public view returns (address[] memory) {
        return vendorShops[owner];
    }
}
