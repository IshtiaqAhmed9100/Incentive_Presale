// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { Rounds, Ownable } from "./Rounds.sol";
import { IPreSale } from "./IPreSale.sol";

import "./Common.sol";

/// @title PreSale contract
/// @notice Implements preSale of the token
/// @dev The presale contract allows you to purchase presale token with allowed tokens,
/// and there will be certain rounds

contract PreSale is IPreSale, Rounds, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address payable;

    /// @notice Thrown when address is blacklisted
    error Blacklisted();

    /// @notice Thrown when buy is disabled
    error BuyNotEnable();

    /// @notice Thrown when sign deadline is expired
    error DeadlineExpired();

    /// @notice Thrown when Eth price suddenly drops while purchasing tokens
    error UnexpectedPriceDifference();

    /// @notice Thrown when value to transfer is zero
    error ZeroValue();

    /// @notice Thrown when price from price feed returns zero
    error PriceNotFound();

    /// @notice Thrown when caller is not claims contract
    error OnlyClaims();

    /// @notice Thrown when purchase amount is less than required
    error InvalidPurchase();

    /// @notice Thrown when both price feed and reference price are non zero
    error CodeSyncIssue();

    /// @notice Thrown if the price is not updated
    error PriceNotUpdated();

    /// @notice Thrown if the roundId of price is not updated
    error RoundIdNotUpdated();

    /// @notice Thrown when max cap is reached
    error MaxCapReached();

    /// @notice That buyEnable or not
    bool public buyEnable = true;

    /// @notice The address of signer wallet
    address public signerWallet;

    /// @notice The address of claims contract
    address public claimsContract;

    /// @notice The address of funds wallet
    address public fundsWallet;

    /// @notice The maximum number of tokens that will be sold in presale
    uint256 public immutable maxCap;

    /// @notice Sum of tokens purchased in presale
    uint256 public totalPurchases;

    /// @notice To achieve return value of required decimals while calculation
    uint256 private constant NORMALIZARION_FACTOR = 1e30;

    /// @notice Gives claim info of user in every round
    mapping(address => mapping(uint32 => uint256)) public claims;

    /// @notice Gives info about address's permission
    mapping(address => bool) public blacklistAddress;

    /// @member price The price of token from price feed
    /// @member normalizationFactorForToken The normalization factor to achieve return value of 18 decimals ,while calculating token purchases and always with different token decimals
    struct TokenInfo {
        uint256 latestPrice;
        uint8 normalizationFactorForToken;
    }

    /// @dev Emitted when token is purchased with ETH
    event PurchasedWithETH(
        address indexed by,
        string code,
        uint256 amountPurchasedETH,
        uint32 indexed round,
        uint256 indexed roundPrice,
        uint256 tokenPurchased
    );

    /// @dev Emitted when presale tokens are purchased with any token
    event PurchasedWithToken(
        IERC20 indexed token,
        uint256 tokenPrice,
        address indexed by,
        string code,
        uint256 amountPurchased,
        uint256 tokenPurchased,
        uint32 indexed round
    );

    /// @dev Emitted when tokens are purchased with claim amount
    event PurchasedWithClaimAmount(
        address indexed by,
        uint256 amount,
        IERC20 token,
        uint32 indexed round,
        uint256 indexed tokenPrice,
        uint256 tokenPurchased
    );

    /// @dev Emitted when address of signer is updated
    event SignerUpdated(address oldSigner, address newSigner);

    /// @dev Emitted when address of funds wallet is updated
    event FundsWalletUpdated(address oldAddress, address newAddress);

    /// @dev Emitted when blacklist access of address is updated
    event BlacklistUpdated(address which, bool accessNow);

    /// @dev Emitted when buying access changes
    event BuyEnableUpdated(bool oldAccess, bool newAccess);

    /// @notice Restricts when updating wallet/contract address with zero address
    modifier checkAddressZero(address which) {
        if (which == address(0)) {
            revert ZeroAddress();
        }
        _;
    }

    /// @notice Ensures that buy is enabled when buying
    modifier canBuy() {
        if (!buyEnable) {
            revert BuyNotEnable();
        }
        _;
    }

    /// @dev Constructor
    /// @param fundsWalletAddress The address of funds wallet
    /// @param signerAddress The address of signer wallet
    /// @param claimsContractAddress The address of claim contract
    /// @param owner The address of owner wallet
    /// @param lastRound The last round created
    /// @param initMaxCap The max cap of bluemoon token
    constructor(
        address fundsWalletAddress,
        address signerAddress,
        address claimsContractAddress,
        address owner,
        uint32 lastRound,
        uint256 initMaxCap
    ) Rounds(lastRound) Ownable(owner) {
        if (fundsWalletAddress == address(0) || signerAddress == address(0) || claimsContractAddress == address(0)) {
            revert ZeroAddress();
        }
        fundsWallet = fundsWalletAddress;
        signerWallet = signerAddress;
        claimsContract = claimsContractAddress;
        
        _checkValue(initMaxCap);
        maxCap = initMaxCap;
    }

    /// @notice The Chainlink inherited function, give us tokens live price
    function getLatestPrice(IERC20 token) public view returns (TokenInfo memory) {
        PriceFeedData memory data = tokenData[token];
        TokenInfo memory tokenInfo;
        if (address(data.priceFeed) == address(0)) {
            return tokenInfo;
        }
        (
            uint80 roundId,
            /*uint80 roundID*/ int price /*uint256 startedAt*/ /*uint80 answeredInRound*/,
            ,
            uint256 updatedAt,

        ) = /*uint256 timeStamp*/ data.priceFeed.latestRoundData();
        if (roundId == 0) {
            revert RoundIdNotUpdated();
        }
        if (updatedAt == 0 || block.timestamp - updatedAt > data.tolerance) {
            revert PriceNotUpdated();
        }
        return
            TokenInfo({
                latestPrice: uint256(price),
                normalizationFactorForToken: data.normalizationFactorForToken
            });
    }

    /// @notice Changes access of buying
    /// @param enabled The decision about buying
    function enableBuy(bool enabled) external onlyOwner {
        if (buyEnable == enabled) {
            revert IdenticalValue();
        }
        emit BuyEnableUpdated({ oldAccess: buyEnable, newAccess: enabled });
        buyEnable = enabled;
    }

    /// @notice Changes signer wallet address
    /// @param newSigner The address of the new signer wallet
    function changeSigner(address newSigner) external checkAddressZero(newSigner) onlyOwner {
        address oldSigner = signerWallet;
        if (oldSigner == newSigner) {
            revert IdenticalValue();
        }
        emit SignerUpdated({ oldSigner: oldSigner, newSigner: newSigner });
        signerWallet = newSigner;
    }

    /// @notice Changes funds wallet to a new address
    /// @param newFundsWallet The address of the new funds wallet
    function changeFundsWallet(address newFundsWallet) external checkAddressZero(newFundsWallet) onlyOwner {
        address oldWallet = fundsWallet;
        if (oldWallet == newFundsWallet) {
            revert IdenticalValue();
        }
        emit FundsWalletUpdated({ oldAddress: oldWallet, newAddress: newFundsWallet });
        fundsWallet = newFundsWallet;
    }

    /// @notice Changes the access of any address in contract interaction
    /// @param which The address for which access is updated
    /// @param access The access decision of `which` address
    function updateBlackListedUser(address which, bool access) external checkAddressZero(which) onlyOwner {
        bool oldAccess = blacklistAddress[which];
        if (oldAccess == access) {
            revert IdenticalValue();
        }
        emit BlacklistUpdated({ which: which, accessNow: access });
        blacklistAddress[which] = access;
    }

    /// @notice Purchases presale token with ETH
    /// @param code The code is used to verify signature of the user
    /// @param round The round in which user wants to purchase
    /// @param deadline The deadline is validity of the signature
    /// @param minAmountToken The minAmountToken user agrees to purchase
    /// @param v The `v` signature parameter
    /// @param r The `r` signature parameter
    /// @param s The `s` signature parameter
    function purchaseTokenWithETH(
        string memory code,
        uint32 round,
        uint256 deadline,
        uint256 minAmountToken,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable nonReentrant canBuy {
        // The input must have been signed by the presale signer
        _validatePurchaseWithETH(msg.value, round, deadline, code, v, r, s);
        uint256 roundPrice = _getRoundPriceForToken(round, ETH);
        TokenInfo memory tokenInfo = getLatestPrice(ETH);
        if (tokenInfo.latestPrice == 0) {
            revert PriceNotFound();
        }
        uint256 toReturn = _calculateAndUpdateTokenAmount(
            msg.value,
            tokenInfo.latestPrice,
            tokenInfo.normalizationFactorForToken,
            roundPrice
        );
        if (toReturn < minAmountToken) {
            revert UnexpectedPriceDifference();
        }
        claims[msg.sender][round] += toReturn;
        payable(fundsWallet).sendValue(msg.value);
        emit PurchasedWithETH({
            by: msg.sender,
            code: code,
            amountPurchasedETH: msg.value,
            round: round,
            roundPrice: roundPrice,
            tokenPurchased: toReturn
        });
    }

    /// @notice Purchases presale token with any token
    /// @param token The purchase token
    /// @param referenceNormalizationFactor The normalization factor
    /// @param referenceTokenPrice The current price of token in 10 decimals
    /// @param purchaseAmount The purchase amount
    /// @param minAmountToken The minAmountToken user agrees to purchase
    /// @param code The code is used to verify signature of the user
    /// @param round The round in which user wants to purchase
    /// @param deadline The deadline is validity of the signature
    /// @param v The `v` signature parameter
    /// @param r The `r` signature parameter
    /// @param s The `s` signature parameter
    function purchaseTokenWithToken(
        IERC20 token,
        uint8 referenceNormalizationFactor,
        uint256 referenceTokenPrice,
        uint256 purchaseAmount,
        uint256 minAmountToken,
        string memory code,
        uint32 round,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external canBuy nonReentrant {
        // The input must have been signed by the presale signer
        _validatePurchaseWithToken(
            token,
            round,
            deadline,
            code,
            referenceTokenPrice,
            referenceNormalizationFactor,
            v,
            r,
            s
        );
        _checkValue(purchaseAmount);

        uint256 roundPrice = _getRoundPriceForToken(round, token);

        (uint256 latestPrice, uint8 normalizationFactor) = _validatePrice(
            token,
            referenceTokenPrice,
            referenceNormalizationFactor
        );

        uint256 toReturn = _calculateAndUpdateTokenAmount(purchaseAmount, latestPrice, normalizationFactor, roundPrice);
        if (toReturn < minAmountToken) {
            revert UnexpectedPriceDifference();
        }
        claims[msg.sender][round] += toReturn;

        token.safeTransferFrom(msg.sender, fundsWallet, purchaseAmount);
        emit PurchasedWithToken({
            token: token,
            tokenPrice: latestPrice,
            by: msg.sender,
            code: code,
            amountPurchased: purchaseAmount,
            tokenPurchased: toReturn,
            round: round
        });
    }

    /// @inheritdoc IPreSale
    function purchaseWithClaim(
        IERC20 token,
        uint256 referenceTokenPrice,
        uint8 referenceNormalizationFactor,
        uint256 amount,
        uint256 minAmountToken,
        address recipient,
        uint32 round
    ) external payable canBuy nonReentrant {
        if (msg.sender != claimsContract) {
            revert OnlyClaims();
        }
        _checkBlacklist(recipient);
        if (!allowedTokens[round][token].access) {
            revert TokenDisallowed();
        }
        uint256 roundPrice = _getRoundPriceForToken(round, token);
        (uint256 latestPrice, uint8 normalizationFactor) = _validatePrice(
            token,
            referenceTokenPrice,
            referenceNormalizationFactor
        );

        uint256 toReturn = _calculateAndUpdateTokenAmount(amount, latestPrice, normalizationFactor, roundPrice);
        if (toReturn < minAmountToken) {
            revert UnexpectedPriceDifference();
        }
        claims[recipient][round] += toReturn;
        if (token == ETH) {
            payable(fundsWallet).sendValue(msg.value);
        } else {
            token.safeTransferFrom(claimsContract, fundsWallet, amount);
        }
        emit PurchasedWithClaimAmount({
            by: recipient,
            amount: amount,
            token: token,
            round: round,
            tokenPrice: latestPrice,
            tokenPurchased: toReturn
        });
    }

    /// @dev Checks value, if zero then reverts
    function _checkValue(uint256 value) private pure {
        if (value == 0) {
            revert ZeroValue();
        }
    }

    /// @dev Validates blacklist address, round and deadline
    function _validatePurchase(uint32 round, uint256 deadline, IERC20 token) private view {
        if (block.timestamp > deadline) {
            revert DeadlineExpired();
        }
        _checkBlacklist(msg.sender);
        if (!allowedTokens[round][token].access) {
            revert TokenDisallowed();
        }
        _verifyInRound(round);
    }

    /// @dev The helper function which verifies signature, signed by signerWallet, reverts if Invalid
    function _verifyCode(string memory code, uint256 deadline, uint8 v, bytes32 r, bytes32 s) private view {
        bytes32 encodedMessageHash = keccak256(abi.encodePacked(msg.sender, code, deadline));
        _verifyMessage(encodedMessageHash, v, r, s);
    }

    /// @dev The helper function which verifies signature, signed by signerWallet, reverts if Invalid
    function _verifyCodeWithPrice(
        string memory code,
        uint256 deadline,
        uint256 referenceTokenPrice,
        IERC20 token,
        uint256 normalizationFactor,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private view {
        bytes32 encodedMessageHash = keccak256(
            abi.encodePacked(msg.sender, code, referenceTokenPrice, deadline, token, normalizationFactor)
        );
        _verifyMessage(encodedMessageHash, v, r, s);
    }

    /// @dev Verifies the address that signed a hashed message (`hash`) with
    /// `signature`
    function _verifyMessage(bytes32 encodedMessageHash, uint8 v, bytes32 r, bytes32 s) private view {
        if (signerWallet != ECDSA.recover(MessageHashUtils.toEthSignedMessageHash(encodedMessageHash), v, r, s)) {
            revert InvalidSignature();
        }
    }

    /// @dev Checks that address is blacklisted or not
    function _checkBlacklist(address which) private view {
        if (blacklistAddress[which]) {
            revert Blacklisted();
        }
    }

    /// @dev Checks max cap and updates total purchases
    function _updateTokenPurchases(uint256 newPurchase) private {
        if (newPurchase + totalPurchases > maxCap) {
            revert MaxCapReached();
        }
        totalPurchases += newPurchase;
    }

    /// @dev Validates round, deadline and signature
    function _validatePurchaseWithETH(
        uint256 amount,
        uint32 round,
        uint256 deadline,
        string memory code,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private view {
        _checkValue(amount);
        _validatePurchase(round, deadline, ETH);
        _verifyCode(code, deadline, v, r, s);
    }

    /// @dev Validates round, deadline and signature
    function _validatePurchaseWithToken(
        IERC20 token,
        uint32 round,
        uint256 deadline,
        string memory code,
        uint256 referenceTokenPrice,
        uint256 normalizationFactor,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private view {
        _validatePurchase(round, deadline, token);
        _verifyCodeWithPrice(code, deadline, referenceTokenPrice, token, normalizationFactor, v, r, s);
    }

    /// @dev Validates round, deadline and signature
    function _getRoundPriceForToken(uint32 round, IERC20 token) private view returns (uint256) {
        uint256 customPrice = allowedTokens[round][token].customPrice;
        uint256 roundPrice = customPrice > 0 ? customPrice : rounds[round].price;
        return roundPrice;
    }

    /// @dev Calculates and update the token amount
    function _calculateAndUpdateTokenAmount(
        uint256 purchaseAmount,
        uint256 referenceTokenPrice,
        uint256 normalizationFactor,
        uint256 roundPrice
    ) private returns (uint256) {
        // toReturn= (10**11 * 10**10 +10**15) -10**18 = 18 decimals
        uint256 toReturn = (purchaseAmount * referenceTokenPrice * (10 ** normalizationFactor)) / roundPrice;
        _updateTokenPurchases(toReturn);
        return toReturn;
    }

    /// @dev Provides us live price of token from price feed or returns reference price and reverts if invalid
    function _validatePrice(
        IERC20 token,
        uint256 referenceTokenPrice,
        uint8 referenceNormalizationFactor
    ) private view returns (uint256, uint8) {
        TokenInfo memory tokenInfo = getLatestPrice(token);
        if (tokenInfo.latestPrice != 0) {
            if (referenceTokenPrice != 0 || referenceNormalizationFactor != 0) {
                revert CodeSyncIssue();
            }
        }
        //  If price feed isn't available,we fallback to the reference price
        if (tokenInfo.latestPrice == 0) {
            if (referenceTokenPrice == 0 || referenceNormalizationFactor == 0) {
                revert ZeroValue();
            }

            tokenInfo.latestPrice = referenceTokenPrice;
            tokenInfo.normalizationFactorForToken = referenceNormalizationFactor;
        }
        return (tokenInfo.latestPrice, tokenInfo.normalizationFactorForToken);
    }
}