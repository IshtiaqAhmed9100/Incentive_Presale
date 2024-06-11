// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import { IPreSale } from "./IPreSale.sol";

import "./Common.sol";

/// @title Claims contract
/// @notice Implements the claiming of the leader's commissions

contract Claims is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address payable;

    /// @notice Thrown when input array length is zero
    error InvalidData();

    /// @notice Thrown when claiming before round ends
    error RoundNotEnded();

    /// @notice Thrown when round is not Enabled
    error RoundNotEnabled();

    /// @notice Thrown when commissions manager wants to set claim while claim enable
    error WaitForRoundDisable();

    /// @notice Returns the identifier of the COMMISSIONS_MANAGER role
    bytes32 public constant COMMISSIONS_MANAGER = keccak256("COMMISSIONS_MANAGER");

    /// @notice Returns the identifier of the ADMIN_ROLE role
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");

    /// @notice Returns the address of presale contract
    IPreSale public presale;

    /// @notice The address of signer wallet
    address public signerWallet;

    /// @member token The token address
    /// @member amount The token amount
    struct ClaimInfo {
        IERC20 token;
        uint256 amount;
    }

    /// @notice Stores the amount of token in a round of the user
    mapping(address => mapping(uint32 => mapping(IERC20 => uint256))) public pendingClaims;

    /// @notice Stores the enabled/disabled status of a round
    mapping(uint32 => bool) public isEnabled;

    /// @dev Emitted when claim amount is set for the addresses
    event ClaimSet(address indexed to, uint32 indexed round, ClaimInfo claimInfo);

    /// @dev Emitted when claim amount is claimed
    event FundsClaimed(address indexed by, uint32 indexed round, IERC20 token, uint256 amount);

    /// @dev Emitted when claim access changes for the round
    event RoundEnableUpdated(bool oldAccess, bool newAccess);

    /// @dev Emitted when token presale contract is updated
    event PresaleUpdated(address prevAddress, address newAddress);

    /// @dev Emitted when address of signer is updated
    event SignerUpdated(address oldSigner, address newSigner);

    /// @dev Constructor
    /// @param signerAddress The signer wallet
    constructor(address signerAddress) {
        if (signerAddress == address(0)) {
            revert ZeroAddress();
        }
        signerWallet = signerAddress;
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(COMMISSIONS_MANAGER, ADMIN_ROLE);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    /// @notice Updates token amounts to addresses in a given round
    /// @param to The array of claimants
    /// @param round The round number
    /// @param claims The tokens and amount to claim
    function setClaim(
        address[] calldata to,
        uint32 round,
        ClaimInfo[][] calldata claims
    ) external onlyRole(COMMISSIONS_MANAGER) {
        if (isEnabled[round]) {
            revert WaitForRoundDisable();
        }
        uint256 toLength = to.length;
        if (toLength == 0) {
            revert InvalidData();
        }
        if (toLength != claims.length) {
            revert ArrayLengthMismatch();
        }
        for (uint256 i; i < toLength; ++i) {
            if (to[i] == address(0)) {
                revert ZeroAddress();
            }
            mapping(IERC20 => uint256) storage claimInfo = pendingClaims[to[i]][round];
            ClaimInfo[] calldata toClaim = claims[i];
            for (uint256 j; j < toClaim.length; j++) {
                ClaimInfo calldata amount = toClaim[j];
                claimInfo[amount.token] = amount.amount;
                emit ClaimSet({ to: to[i], round: round, claimInfo: amount });
            }
        }
    }

    /// @notice Changes presale contract address
    /// @param newPresale The address of the new PreSale contract
    function updatePreSaleAddress(IPreSale newPresale) external onlyRole(ADMIN_ROLE) {
        if (address(newPresale) == address(0)) {
            revert ZeroAddress();
        }
        if (presale == newPresale) {
            revert IdenticalValue();
        }
        emit PresaleUpdated({ prevAddress: address(presale), newAddress: address(newPresale) });
        presale = newPresale;
    }

    /// @notice Changes the claim access of the contract
    /// @param round The round number of which access is changed
    /// @param status The access status of the round
    function enableClaims(uint32 round, bool status) external onlyRole(COMMISSIONS_MANAGER) {
        bool oldAccess = isEnabled[round];
        if (oldAccess == status) {
            revert IdenticalValue();
        }
        emit RoundEnableUpdated({ oldAccess: oldAccess, newAccess: status });
        isEnabled[round] = status;
    }

    /// @notice Gives max allowance of tokens to presale contract
    /// @param tokens List of tokens to approve
    function approveAllowance(IERC20[] calldata tokens) external onlyRole(ADMIN_ROLE) {
        uint256 tokensLength = tokens.length;
        for (uint256 i; i < tokensLength; ++i) {
            tokens[i].forceApprove(address(presale), type(uint256).max);
        }
    }

    /// @notice Claims the amount in a given round
    /// @param round The round in which you want to claim
    /// @param tokens The addresses of the token to be claimed
    function claim(uint32 round, IERC20[] calldata tokens) external nonReentrant {
        _checkRoundAndTime(round);
        mapping(IERC20 => uint256) storage claimInfo = pendingClaims[msg.sender][round];
        uint256 tokensLength = tokens.length;
        for (uint256 i; i < tokensLength; ++i) {
            IERC20 token = tokens[i];
            uint256 amount = claimInfo[token];
            if (amount == 0) {
                continue;
            }
            delete claimInfo[token];
            _processTokenTransfer(token, amount);
            emit FundsClaimed({ by: msg.sender, round: round, token: token, amount: amount });
        }
    }

    /// @notice Purchases presale token with claim amounts
    /// @param round The round in which user will purchase
    /// @param deadline The signature deadline
    /// @param normalizationFactors The values to handle decimals
    /// @param tokenPrices The current prices of the tokens in 10 decimals
    /// @param tokens The addresses of the tokens
    /// @param amounts The purchase amounts
    /// @param minAmountsToken The minimum amounts of tokens recipient will get
    /// @param v The `v` signature parameter
    /// @param r The `r` signature parameter
    /// @param s The `s` signature parameter
    function purchaseWithClaim(
        uint32 round,
        uint256 deadline,
        uint8[] calldata normalizationFactors,
        uint256[] calldata tokenPrices,
        IERC20[] calldata tokens,
        uint256[] calldata amounts,
        uint256[] calldata minAmountsToken,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant {
        _checkRoundAndTime(round);
        if (normalizationFactors.length == 0) {
            revert ZeroLengthArray();
        }
        uint256 tokensLength = tokens.length;
        if (
            normalizationFactors.length != tokenPrices.length ||
            tokenPrices.length != tokensLength ||
            tokensLength != amounts.length ||
            amounts.length != minAmountsToken.length
        ) {
            revert ArrayLengthMismatch();
        }
        _verifyPurchaseWithClaim(
            msg.sender,
            round,
            deadline,
            tokenPrices,
            normalizationFactors,
            tokens,
            amounts,
            v,
            r,
            s
        );

        mapping(IERC20 => uint256) storage claimInfo = pendingClaims[msg.sender][round];
        for (uint256 i; i < tokensLength; ++i) {
            IERC20 token = tokens[i];
            uint256 amountToPurchase = amounts[i];
            uint8 normalizationFactor = normalizationFactors[i];
            uint256 minAmountToken = minAmountsToken[i];
            uint256 amount = claimInfo[token];
            if (amount == 0) {
                continue;
            }
            if (amountToPurchase > amount) {
                continue;
            }
            delete claimInfo[token];
            uint256 remainingAmount = amount - amountToPurchase;
            IPreSale sale = presale;
            if (token == ETH) {
                sale.purchaseWithClaim{ value: amountToPurchase }(
                    ETH,
                    0,
                    normalizationFactor,
                    amountToPurchase,
                    minAmountToken,
                    msg.sender,
                    round
                );
            } else {
                uint256 allowance = token.allowance(address(this), address(sale));
                if (allowance < amountToPurchase) {
                    token.forceApprove(address(sale), type(uint256).max);
                }

                sale.purchaseWithClaim(
                    token,
                    tokenPrices[i],
                    normalizationFactor,
                    amountToPurchase,
                    minAmountToken,
                    msg.sender,
                    round
                );
            }
            if (remainingAmount > 0) {
                _processTokenTransfer(token, remainingAmount);
                emit FundsClaimed({ by: msg.sender, round: round, token: token, amount: remainingAmount });
            }
        }
    }

    /// @notice Changes signer wallet address
    /// @param newSigner The address of the new signer wallet
    function changeSigner(address newSigner) external onlyRole(ADMIN_ROLE) {
        address oldSigner = signerWallet;
        if (newSigner == address(0)) {
            revert ZeroAddress();
        }
        if (oldSigner == newSigner) {
            revert IdenticalValue();
        }
        emit SignerUpdated({ oldSigner: oldSigner, newSigner: newSigner });
        signerWallet = newSigner;
    }

    /// @dev Verifies round and time
    function _checkRoundAndTime(uint32 round) private view {
        if (!isEnabled[round]) {
            revert RoundNotEnabled();
        }
        (, uint256 endTime, ) = presale.rounds(round);
        if (block.timestamp < endTime) {
            revert RoundNotEnded();
        }
    }

    /// @dev Verifies the address that signed a hashed message (`hash`) with
    /// `signature`
    function _verifyMessage(bytes32 encodedMessageHash, uint8 v, bytes32 r, bytes32 s) private view {
        if (signerWallet != ECDSA.recover(MessageHashUtils.toEthSignedMessageHash(encodedMessageHash), v, r, s)) {
            revert InvalidSignature();
        }
    }

    /// @dev Checks token and transfer amount to user of that token
    function _processTokenTransfer(IERC20 token, uint256 amount) private {
        if (token == ETH) {
            payable(msg.sender).sendValue(amount);
        } else {
            token.safeTransfer(msg.sender, amount);
        }
    }

    /// @dev The tokenPrices,tokens are provided externally and therefore have to be verified by the trusted presale contract
    function _verifyPurchaseWithClaim(
        address by,
        uint32 round,
        uint256 deadline,
        uint256[] calldata tokenPrices,
        uint8[] calldata normalizationFactors,
        IERC20[] calldata tokens,
        uint256[] calldata amounts,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private view {
        bytes32 encodedMessageHash = keccak256(
            abi.encodePacked(by, round, tokenPrices, normalizationFactors, deadline, tokens, amounts)
        );
        _verifyMessage(encodedMessageHash, v, r, s);
    }

    receive() external payable {}
}