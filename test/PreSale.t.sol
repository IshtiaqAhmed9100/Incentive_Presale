// // SPDX-License-Identifier: UNLICENSED
// pragma solidity 0.8.25;

// import "lib/forge-std/src/Test.sol";

// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
// import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

// import "../contracts/Common.sol";

// import {AggregatorV3Interface, TokenRegistry} from "../contracts/TokenRegistry.sol";
// import {PreSale} from "../contracts/PreSale.sol";
// import {Rounds} from "../contracts/Rounds.sol";

// contract PreSaleTest is Test {
//     using MessageHashUtils for bytes32;
//     using SafeERC20 for IERC20;

//     error OwnableUnauthorizedAccount(address);

//     string code = "12345";
//     uint32 round = 7;
//     uint256 minAmount = 1;
//     address usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
//     address usdt = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
//     // address ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

//     uint256 roundPrice = 10000000000000000;
//     IERC20 USDT;
//     IERC20 USDC;
//     address fundwallet;
//     address claim;
//     address owner;
//     uint256 privateKey;
//     address signer;
//     uint32 lastround;
//     uint256 initMaxCap;
//     PreSale public preSale;
//     address caller;
//     uint256 investment;
//     PreSale.TokenInfo info;

//     /// @dev Invoked before each test.
//     function setUp() public {
//         USDC = IERC20(usdc);
//         USDT = IERC20(usdt);

//         fundwallet = 0x395bFD879A3AE7eC4E469e26c8C1d7BB2F9d77B9;
//         claim = 0x2cb197409ae65b344a611E2ab99A0E864EF28d4c;
//         owner = 0x19A865ab3A6E9DD7ac716891B0080b2cB3ffb9fa;
//         privateKey = vm.envUint("PRIVATE_KEY");
//         signer = vm.addr(privateKey);
//         caller = 0x12eF0F1C99D8FD50fFd37cCd12B09Ef7f1213269;
//         deal(caller, 100000000000000000000000e18);
//         investment = 100000000000000000; // 0.01
//         lastround = 6;
//         initMaxCap =1500000000000000000000000000;

//         preSale = new PreSale(
//             fundwallet,
//             signer,
//             claim,
//             owner,
//             lastround,
//             initMaxCap
//         );

//         vm.startPrank(owner);
//         preSale.createNewRound(
//             block.timestamp,
//             block.timestamp + 86400,
//             roundPrice
//         );
//         IERC20[] memory tokenss = new IERC20[](3);
//         tokenss[0] = IERC20(ETH);
//         tokenss[1] = USDT;
//         tokenss[2] = USDC;

//         bool[] memory accesses = new bool[](3);
//         accesses[0] = true;
//         accesses[1] = true;
//         accesses[2] = true;

//         uint256[] memory cp = new uint256[](3);
//         cp[0] = 0;
//         cp[1] = 0;
//         cp[2] = 0.001 ether;

//         preSale.updateAllowedTokens(7, tokenss, accesses, cp);

//         TokenRegistry.PriceFeedData[] memory priceFeedData = new TokenRegistry.PriceFeedData[](1);
//         priceFeedData[0] = TokenRegistry.PriceFeedData({
//             priceFeed: AggregatorV3Interface( 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419 ),
//             normalizationFactorForToken: 10,
//             tolerance:3600
//         });

//         IERC20[] memory tok = new IERC20[](1);
//         tok[0] = IERC20(ETH);

//         preSale.setTokenPriceFeed(tok, priceFeedData);

//         info = preSale.getLatestPrice(IERC20(ETH));
//         vm.stopPrank();

//         vm.startPrank(0x3fe705e2FFcaEe8d7287de047DeF35Db3e794C76);
//         USDT.safeTransfer(caller, 0);
//         vm.stopPrank();

//         vm.startPrank(0x8F56c644F2B54a478c0986807b0E05d48387bADC);
//         USDC.safeTransfer(caller, 0);
//         vm.stopPrank();
//     }

//     function test_enableBuy() public {
//         bytes4 selector = bytes4(
//             keccak256("OwnableUnauthorizedAccount(address)")
//         );
//         vm.expectRevert(abi.encodeWithSelector(selector, address(this)));
//         preSale.enableBuy(false);

//         vm.startPrank(owner);
//         preSale.enableBuy(false);
//         assertFalse(preSale.buyEnable());

//         preSale.enableBuy(true);
//         assertTrue(preSale.buyEnable());

//         vm.expectRevert(IdenticalValue.selector);
//         preSale.enableBuy(true);
//         assertTrue(preSale.buyEnable());

//         vm.stopPrank();
//     }

//     function test_changeSigner() public {
//         bytes4 selector = bytes4(
//             keccak256("OwnableUnauthorizedAccount(address)")
//         );
//         vm.expectRevert(abi.encodeWithSelector(selector, address(this)));
//         preSale.changeSigner(fundwallet);

//         vm.startPrank(owner);
//         preSale.changeSigner(fundwallet);
//         assertEq(preSale.signerWallet(), fundwallet);

//         vm.expectRevert();
//         preSale.changeSigner(fundwallet);

//         vm.expectRevert();
//         preSale.changeSigner(address(0));

//         vm.stopPrank();
//     }

//     function test_changeFundsWallet() public {
//         bytes4 selector = bytes4(
//             keccak256("OwnableUnauthorizedAccount(address)")
//         );
//         vm.expectRevert(abi.encodeWithSelector(selector, address(this)));
//         preSale.changeFundsWallet(signer);

//         vm.startPrank(owner);
//         preSale.changeFundsWallet(signer);
//         assertEq(preSale.fundsWallet(), signer);

//         vm.expectRevert();
//         preSale.changeFundsWallet(signer);

//         vm.expectRevert();
//         preSale.changeFundsWallet(address(0));

//         vm.stopPrank();
//     }

//     function test_updateBlackListedUser() public {
//         bytes4 selector = bytes4(
//             keccak256("OwnableUnauthorizedAccount(address)")
//         );
//         vm.expectRevert(abi.encodeWithSelector(selector, address(this)));
//         preSale.updateBlackListedUser(signer, true);

//         vm.startPrank(owner);
//         preSale.updateBlackListedUser(signer, true);
//         assertTrue(preSale.blacklistAddress(signer));

//         vm.expectRevert();
//         preSale.updateBlackListedUser(signer, true);

//         vm.expectRevert();
//         preSale.updateBlackListedUser(address(0), true);

//         vm.stopPrank();
//     }

//     function _signWithETH() internal returns (uint8, bytes32, bytes32) {
//         vm.startPrank(signer);

//         uint256 deadline = block.timestamp + 2 minutes;
//         bytes32 mhash = keccak256(abi.encodePacked(caller, code, deadline));
//         bytes32 msgHash = mhash.toEthSignedMessageHash();
//         (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);
//         vm.stopPrank();
//         return (v, r, s);
//     }

//     function test_PurchaseTokenWithEth() public {
//         (uint8 v, bytes32 r, bytes32 s) = _signWithETH();
//         uint256 deadline = block.timestamp + 2 minutes;
//         vm.startPrank(caller);
//         preSale.purchaseTokenWithETH{value: investment}(
//             code,
//             round,
//             deadline,
//             minAmount,
//             v,
//             r,
//             s
//         );
//         uint256 toClaim = preSale.claims(caller, round);
//         uint256 expectedResult = (investment *
//             info.latestPrice *
//             (10 ** info.normalizationFactorForToken)) / roundPrice;
//         assertEq(toClaim, expectedResult);
//         vm.stopPrank();
//     }

//     function test_PurchaseTokenWithEth_RevertOn_BuyDisable() public {
//         uint256 deadline = block.timestamp + 2 minutes;
//         (uint8 v, bytes32 r, bytes32 s) = _signWithETH();
//         vm.startPrank(owner);
//         preSale.enableBuy(false);
//         vm.expectRevert(PreSale.BuyNotEnable.selector);
//         preSale.purchaseTokenWithETH{value: investment}(
//             code,
//             round,
//             deadline,
//             minAmount,
//             v,
//             r,
//             s
//         ); // buy is not enabled
//     }

//     function test_PurchaseTokenWithEth_RevertOn_BlacklistedUser() public {
//         uint256 deadline = block.timestamp + 2 minutes;
//         (uint8 v, bytes32 r, bytes32 s) = _signWithETH();
//         vm.startPrank(owner);
//         preSale.updateBlackListedUser(owner, true);
//         vm.expectRevert(PreSale.Blacklisted.selector);
//         preSale.purchaseTokenWithETH{value: investment}(
//             code,
//             round,
//             deadline,
//             minAmount,
//             v,
//             r,
//             s
//         );
//         vm.stopPrank();
//     }

//     function test_PurchaseTokenWithEth_RevertOn_RoundNotStarted() public {
//         uint256 deadline = block.timestamp + 2 minutes;
//         (uint8 v, bytes32 r, bytes32 s) = _signWithETH();
//         vm.startPrank(caller);
//         vm.warp(block.timestamp - 60 minutes);
//         vm.expectRevert(Rounds.RoundNotStarted.selector);
//         preSale.purchaseTokenWithETH{value: investment}(
//             code,
//             round,
//             deadline,
//             minAmount,
//             v,
//             r,
//             s
//         );
//         vm.stopPrank();
//     }

//     function test_PurchaseTokenWithEth_RevertOn_RoundEnded() public {
//         (uint8 v, bytes32 r, bytes32 s) = _signWithETH();
//         vm.startPrank(caller);
//         vm.warp(block.timestamp + 86400 + 86400);
//         vm.expectRevert(Rounds.RoundEnded.selector);
//         uint256 deadline = block.timestamp + 2 minutes;
//         preSale.purchaseTokenWithETH{value: investment}(
//             code,
//             round,
//             deadline,
//             minAmount,
//             v,
//             r,
//             s
//         );
//         vm.stopPrank();
//     }

//     function test_PurchaseTokenWithEth_RevertOn_ZeroInvestment() public {
//         uint256 deadline = block.timestamp + 2 minutes;
//         (uint8 v, bytes32 r, bytes32 s) = _signWithETH();
//         vm.startPrank(caller);
//         vm.expectRevert(PreSale.ZeroValue.selector);
//         preSale.purchaseTokenWithETH{value: 0}(
//             code,
//             round,
//             deadline,
//             minAmount,
//             v,
//             r,
//             s
//         );
//         vm.stopPrank();
//     }

//     function _verifyCodeWithPrice(
//         IERC20 token,
//         uint256 referenceTokenPrice,
//         uint256 normalizationFactor
//     ) internal returns (uint8, bytes32, bytes32) {
//         vm.startPrank(signer);

//         uint256 deadline = block.timestamp + 2 minutes;
//         bytes32 mhash = keccak256(
//             abi.encodePacked(
//                 caller,
//                 code,
//                 referenceTokenPrice,
//                 deadline,
//                 token,
//                 normalizationFactor
//             )
//         );
//         bytes32 msgHash = mhash.toEthSignedMessageHash();
//         (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);
//         vm.stopPrank();
//         return (v, r, s);
//     }

//     function test_PurchaseTokenWithToken_WithUsdt() public {
//         uint256 USDTprice = 10000000000;
//         uint8 USDTNF = 20;
//         uint256 investUSDT = 1000000000;

//         uint256 deadline = block.timestamp + 2 minutes;
//         (uint8 v, bytes32 r, bytes32 s) = _verifyCodeWithPrice(
//             USDT,
//             USDTprice,
//             USDTNF
//         );

//         vm.startPrank(caller);

//         USDT.forceApprove(address(preSale), 1000000000e6);
//         preSale.purchaseTokenWithToken(
//             USDT,
//             USDTNF,
//             USDTprice,
//             investUSDT,
//             1,
//             code,
//             round,
//             deadline,
//             v,
//             r,
//             s
//         );
//         uint256 toClaim = preSale.claims(caller, round);
//         uint256 expectedResult = (investUSDT * USDTprice * (10 ** USDTNF)) /
//             roundPrice;
//         assertEq(toClaim, expectedResult);
//         vm.stopPrank();
//     }

//     function test_PurchaseTokenWithToken_Withusdc() public {
//         uint256 usdcPrice = 2.17 * 10 ** 10;
//         uint8 usdcNF = 8;
//         uint256 invest = 10 * 10 ** 18;

//         uint256 deadline = block.timestamp + 2 minutes;
//         (uint8 v, bytes32 r, bytes32 s) = _verifyCodeWithPrice(
//             USDC,
//             usdcPrice,
//             usdcNF
//         );

//         vm.startPrank(caller);

//         USDC.forceApprove(address(preSale), 1000000000e18);
//         preSale.purchaseTokenWithToken(
//             USDC,
//             usdcNF,
//             usdcPrice,
//             invest,
//             1,
//             code,
//             round,
//             deadline,
//             v,
//             r,
//             s
//         );
//         uint256 toClaim = preSale.claims(caller, round);
//         uint256 expectedResult = (invest * usdcPrice * (10 ** usdcNF)) /
//             0.001 ether; //usdc custom price
//         assertEq(toClaim, expectedResult);
//         vm.stopPrank();
//     }
// }
