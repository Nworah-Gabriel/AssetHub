// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./VendorERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title Marketplace
 * @dev Contract for buying and selling tokenized products.
 */
contract Marketplace is ReentrancyGuard {
    IERC20 public realixToken;

    /**
     * @notice Constructor to initialize the Marketplace contract.
     * @param _realixToken The address of the Realix ERC20 token.
     */
    constructor(IERC20 _realixToken) payable{
        realixToken = _realixToken;
    }

    /**
     * @notice Purchase a product from a vendor's shop using RLX tokens.
     * @param vendor The address of the vendor's shop.
     * @param id The unique identifier for the product NFT.
     * @param amount The quantity of the product NFT to purchase.
     * @param price The total price in RLX tokens.
     */
    function purchaseProduct(address vendor, uint256 id, uint256 amount, uint256 price) public nonReentrant {
        require(realixToken.transferFrom(msg.sender, vendor, price), "Payment failed");
        VendorERC1155(vendor).safeTransferFrom(vendor, msg.sender, id, amount, "");
    }
}
