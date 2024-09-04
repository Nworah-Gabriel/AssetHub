// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title AssetTokenizer
 * @dev Contract for tokenizing tangible assets and allowing fractional ownership.
 */
contract AssetTokenizer is ERC1155, Ownable, ReentrancyGuard {
    uint256 public assetIdCounter;

    struct FractionalOwnership {
        uint256 totalSupply;
        mapping(address => uint256) ownership;
    }

    mapping(uint256 => FractionalOwnership) public assetOwnership;

    event AssetTokenized(uint256 indexed assetId, uint256 amount);
    event AssetSharePurchased(uint256 indexed assetId, address indexed buyer, uint256 amount);

    /**
     * @notice Constructor to initialize the AssetTokenizer contract.
     * @param uri The base URI for the asset metadata.
     */
    constructor(string memory uri) ERC1155(uri) Ownable(msg.sender) {}

    /**
     * @notice Tokenize a new tangible asset.
     * @param amount The total number of shares for the asset.
     * @return The asset ID of the newly tokenized asset.
     */
    function tokenizeAsset(uint256 amount) public onlyOwner nonReentrant returns (uint256) {
        require(amount > 0, "Amount must be greater than 0");

        assetIdCounter++;
        _mint(msg.sender, assetIdCounter, amount, "");
        assetOwnership[assetIdCounter].totalSupply = amount;
        assetOwnership[assetIdCounter].ownership[msg.sender] = amount;

        emit AssetTokenized(assetIdCounter, amount);

        return assetIdCounter;
    }

    /**
     * @notice Purchase a share of a tokenized asset.
     * @param assetId The ID of the asset to purchase.
     * @param amount The number of shares to purchase.
     */
    function purchaseAssetShare(uint256 assetId, uint256 amount) public nonReentrant {
        require(amount > 0, "Amount must be greater than 0");

        FractionalOwnership storage ownership = assetOwnership[assetId];
        require(balanceOf(owner(), assetId) >= amount, "Not enough shares available");

        safeTransferFrom(owner(), msg.sender, assetId, amount, "");
        ownership.ownership[msg.sender] += amount;
        ownership.ownership[owner()] -= amount;

        emit AssetSharePurchased(assetId, msg.sender, amount);
    }

    /**
     * @notice Get the ownership percentage of a tokenized asset.
     * @param assetId The ID of the asset.
     * @param owner The address of the asset owner.
     * @return The ownership percentage.
     */
    function getOwnershipPercentage(uint256 assetId, address owner) public view returns (uint256) {
        FractionalOwnership storage ownership = assetOwnership[assetId];
        require(ownership.totalSupply > 0, "Total supply must be greater than 0");

        return (ownership.ownership[owner] * 100) / ownership.totalSupply;
    }
}
