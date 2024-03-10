// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @title Dynamic ERC1155 NFT Contract
/// @author Yuren Jin
/// @dev This contract implements an ERC1155 token with dynamic evolution capabilities.
///      Token evolution can change the token's attributes or utilities, representing
///      user loyalty or achievements.

contract MyDynamicNFT is Initializable, ERC1155Upgradeable, AccessControlUpgradeable, ERC1155SupplyUpgradeable, UUPSUpgradeable {
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant EVOLVER_ROLE = keccak256("EVOLVER_ROLE"); 

    /// @notice Mapping from token ID to its evolution stage
    mapping(uint256 => uint256) private _evolutionStages;

    /// @notice Mapping of token IDs to their evolution URIs
    mapping(uint256 => string) private _evolutionURIs;

    /// @notice Mapping of token IDs to their associated rewards
    mapping(uint256 => uint256) private _tokenRewards;

    /// Event emitted when a token's evolution stage is updated
    event TokenEvolved(uint256 indexed tokenId, uint256 newStage, string newURI);

    /// Event emitted when a token's reward is increased
    event RewardIncreased(uint256 indexed tokenId, uint256 newReward);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the contract with roles and ERC1155 settings
    /// @param defaultAdmin Address to grant the default admin role
    /// @param minter Address to grant the minter role
    /// @param upgrader Address to grant the upgrader role

    function initialize(address defaultAdmin, address minter, address upgrader)
        public initializer
    {
        __ERC1155_init("");
        __AccessControl_init();
        __ERC1155Supply_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
        _grantRole(UPGRADER_ROLE, upgrader);
        _grantRole(EVOLVER_ROLE, defaultAdmin); // Grant the evolver role to the default admin for initial setup
    }

    /// @notice Sets the URI for all tokens
    /// @dev Requires URI_SETTER_ROLE
    /// @param newuri New base URI for token metadata

    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
    }

    /// @notice Mints a specific amount of tokens to an address
    /// @dev Requires MINTER_ROLE
    /// @param account The address receiving the tokens
    /// @param id The token ID to mint
    /// @param amount The amount of tokens to mint
    /// @param data Additional data with no specified format, sent in call to `_mint`

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyRole(MINTER_ROLE)
    {
        _mint(account, id, amount, data);
    }

    /// @notice Mints multiple tokens to an address
    /// @dev Requires MINTER_ROLE
    /// @param to The address receiving the tokens
    /// @param ids An array of token IDs to mint
    /// @param amounts An array of amounts of tokens to mint per ID
    /// @param data Additional data with no specified format, sent in call to `_mintBatch`

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyRole(MINTER_ROLE)
    {
        _mintBatch(to, ids, amounts, data);
    }

    /// @notice Evolves a token to a new stage, potentially updating its URI and increasing its reward
    /// @dev Requires EVOLVER_ROLE
    /// @param tokenId The ID of the token to evolve
    /// @param newStage The new evolution stage for the token

    function evolve(uint256 tokenId, uint256 newStage) public onlyRole(EVOLVER_ROLE) {
        require(exists(tokenId), "Token does not exist");
        _evolutionStages[tokenId] = newStage;

        uint256 newReward = calculateReward(newStage);
        _tokenRewards[tokenId] = newReward;

        emit RewardIncreased(tokenId, newReward);
    }

    /// @notice Calculates the reward for a token based on its evolution stage
    /// @param stage The evolution stage of the token
    /// @return The calculated reward

    function calculateReward(uint256 stage) private pure returns (uint256) {

    return stage * 1; // Increase reward by 1 for each stage
    }

    /// @notice Gets the evolution stage of a token
    /// @param tokenId The ID of the token
    /// @return The evolution stage of the token

    function getEvolutionStage(uint256 tokenId) public view returns (uint256) {
        require(exists(tokenId), "Token does not exist");
        return _evolutionStages[tokenId];
    }

    /// @dev Authorizes a contract upgrade
    /// @param newImplementation The address of the new contract implementation

    function _authorizeUpgrade(address newImplementation) internal onlyRole(UPGRADER_ROLE)
        override
    {}

    /// @dev Overrides required by Solidity for internal consistency

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values) internal
        override(ERC1155Upgradeable, ERC1155SupplyUpgradeable)
    {
        super._update(from, to, ids, values);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
