// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title VendorERC1155
 * @dev ERC1155 contract representing a vendor's shop, with mintable products as NFTs.
 */
contract VendorERC1155 is ERC1155, Ownable {

    event NFTmint(address minter, uint amount);
    event BatchNFTmint(address minter, uint[] amount);

    /**
     * @dev Constructor to set the base URI for all tokens.
     * @param uri The base URI for all token types.
     */
    constructor(string memory uri) Ownable(msg.sender) ERC1155(uri) payable {}

    /**
     * @notice Mints new tokens representing a product in the shop.
     * @param to The address to mint the tokens to.
     * @param id The ID of the token type.
     * @param amount The amount of tokens to mint.
     * @param data Additional data with no specified format.
     */
    function mintProduct(address to, uint256 id, uint256 amount, bytes memory data) public onlyOwner {
        _mint(to, id, amount, data);
        emit NFTmint(to, amount);
    }

    /**
     * @notice Mints a batch of new tokens.
     * @param to The address to mint the tokens to.
     * @param ids The IDs of the token types.
     * @param amounts The amounts of each token type to mint.
     * @param data Additional data with no specified format.
     */
    function mintBatchProducts(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
        emit BatchNFTmint(to, amounts);
    }
}
