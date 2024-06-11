import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt } from "@graphprotocol/graph-ts"
import {
  BlacklistUpdated,
  BuyEnableUpdated,
  FundsWalletUpdated,
  OwnershipTransferred,
  PricingUpdated,
  PurchasedWithClaimAmount,
  PurchasedWithETH,
  PurchasedWithToken,
  RoundCreated,
  RoundUpdated,
  SignerUpdated,
  TokenDataAdded,
  TokensAccessUpdated
} from "../generated/PreSale/PreSale"

export function createBlacklistUpdatedEvent(
  which: Address,
  accessNow: boolean
): BlacklistUpdated {
  let blacklistUpdatedEvent = changetype<BlacklistUpdated>(newMockEvent())

  blacklistUpdatedEvent.parameters = new Array()

  blacklistUpdatedEvent.parameters.push(
    new ethereum.EventParam("which", ethereum.Value.fromAddress(which))
  )
  blacklistUpdatedEvent.parameters.push(
    new ethereum.EventParam("accessNow", ethereum.Value.fromBoolean(accessNow))
  )

  return blacklistUpdatedEvent
}

export function createBuyEnableUpdatedEvent(
  oldAccess: boolean,
  newAccess: boolean
): BuyEnableUpdated {
  let buyEnableUpdatedEvent = changetype<BuyEnableUpdated>(newMockEvent())

  buyEnableUpdatedEvent.parameters = new Array()

  buyEnableUpdatedEvent.parameters.push(
    new ethereum.EventParam("oldAccess", ethereum.Value.fromBoolean(oldAccess))
  )
  buyEnableUpdatedEvent.parameters.push(
    new ethereum.EventParam("newAccess", ethereum.Value.fromBoolean(newAccess))
  )

  return buyEnableUpdatedEvent
}

export function createFundsWalletUpdatedEvent(
  oldAddress: Address,
  newAddress: Address
): FundsWalletUpdated {
  let fundsWalletUpdatedEvent = changetype<FundsWalletUpdated>(newMockEvent())

  fundsWalletUpdatedEvent.parameters = new Array()

  fundsWalletUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "oldAddress",
      ethereum.Value.fromAddress(oldAddress)
    )
  )
  fundsWalletUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "newAddress",
      ethereum.Value.fromAddress(newAddress)
    )
  )

  return fundsWalletUpdatedEvent
}

export function createOwnershipTransferredEvent(
  previousOwner: Address,
  newOwner: Address
): OwnershipTransferred {
  let ownershipTransferredEvent = changetype<OwnershipTransferred>(
    newMockEvent()
  )

  ownershipTransferredEvent.parameters = new Array()

  ownershipTransferredEvent.parameters.push(
    new ethereum.EventParam(
      "previousOwner",
      ethereum.Value.fromAddress(previousOwner)
    )
  )
  ownershipTransferredEvent.parameters.push(
    new ethereum.EventParam("newOwner", ethereum.Value.fromAddress(newOwner))
  )

  return ownershipTransferredEvent
}

export function createPricingUpdatedEvent(
  oldPrice: BigInt,
  newPrice: BigInt
): PricingUpdated {
  let pricingUpdatedEvent = changetype<PricingUpdated>(newMockEvent())

  pricingUpdatedEvent.parameters = new Array()

  pricingUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "oldPrice",
      ethereum.Value.fromUnsignedBigInt(oldPrice)
    )
  )
  pricingUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "newPrice",
      ethereum.Value.fromUnsignedBigInt(newPrice)
    )
  )

  return pricingUpdatedEvent
}

export function createPurchasedWithClaimAmountEvent(
  by: Address,
  amount: BigInt,
  token: Address,
  round: BigInt,
  tokenPrice: BigInt,
  tokenPurchased: BigInt
): PurchasedWithClaimAmount {
  let purchasedWithClaimAmountEvent = changetype<PurchasedWithClaimAmount>(
    newMockEvent()
  )

  purchasedWithClaimAmountEvent.parameters = new Array()

  purchasedWithClaimAmountEvent.parameters.push(
    new ethereum.EventParam("by", ethereum.Value.fromAddress(by))
  )
  purchasedWithClaimAmountEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )
  purchasedWithClaimAmountEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  purchasedWithClaimAmountEvent.parameters.push(
    new ethereum.EventParam("round", ethereum.Value.fromUnsignedBigInt(round))
  )
  purchasedWithClaimAmountEvent.parameters.push(
    new ethereum.EventParam(
      "tokenPrice",
      ethereum.Value.fromUnsignedBigInt(tokenPrice)
    )
  )
  purchasedWithClaimAmountEvent.parameters.push(
    new ethereum.EventParam(
      "tokenPurchased",
      ethereum.Value.fromUnsignedBigInt(tokenPurchased)
    )
  )

  return purchasedWithClaimAmountEvent
}

export function createPurchasedWithETHEvent(
  by: Address,
  code: string,
  amountPurchasedETH: BigInt,
  round: BigInt,
  roundPrice: BigInt,
  tokenPurchased: BigInt
): PurchasedWithETH {
  let purchasedWithEthEvent = changetype<PurchasedWithETH>(newMockEvent())

  purchasedWithEthEvent.parameters = new Array()

  purchasedWithEthEvent.parameters.push(
    new ethereum.EventParam("by", ethereum.Value.fromAddress(by))
  )
  purchasedWithEthEvent.parameters.push(
    new ethereum.EventParam("code", ethereum.Value.fromString(code))
  )
  purchasedWithEthEvent.parameters.push(
    new ethereum.EventParam(
      "amountPurchasedETH",
      ethereum.Value.fromUnsignedBigInt(amountPurchasedETH)
    )
  )
  purchasedWithEthEvent.parameters.push(
    new ethereum.EventParam("round", ethereum.Value.fromUnsignedBigInt(round))
  )
  purchasedWithEthEvent.parameters.push(
    new ethereum.EventParam(
      "roundPrice",
      ethereum.Value.fromUnsignedBigInt(roundPrice)
    )
  )
  purchasedWithEthEvent.parameters.push(
    new ethereum.EventParam(
      "tokenPurchased",
      ethereum.Value.fromUnsignedBigInt(tokenPurchased)
    )
  )

  return purchasedWithEthEvent
}

export function createPurchasedWithTokenEvent(
  token: Address,
  tokenPrice: BigInt,
  by: Address,
  code: string,
  amountPurchased: BigInt,
  tokenPurchased: BigInt,
  round: BigInt
): PurchasedWithToken {
  let purchasedWithTokenEvent = changetype<PurchasedWithToken>(newMockEvent())

  purchasedWithTokenEvent.parameters = new Array()

  purchasedWithTokenEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  purchasedWithTokenEvent.parameters.push(
    new ethereum.EventParam(
      "tokenPrice",
      ethereum.Value.fromUnsignedBigInt(tokenPrice)
    )
  )
  purchasedWithTokenEvent.parameters.push(
    new ethereum.EventParam("by", ethereum.Value.fromAddress(by))
  )
  purchasedWithTokenEvent.parameters.push(
    new ethereum.EventParam("code", ethereum.Value.fromString(code))
  )
  purchasedWithTokenEvent.parameters.push(
    new ethereum.EventParam(
      "amountPurchased",
      ethereum.Value.fromUnsignedBigInt(amountPurchased)
    )
  )
  purchasedWithTokenEvent.parameters.push(
    new ethereum.EventParam(
      "tokenPurchased",
      ethereum.Value.fromUnsignedBigInt(tokenPurchased)
    )
  )
  purchasedWithTokenEvent.parameters.push(
    new ethereum.EventParam("round", ethereum.Value.fromUnsignedBigInt(round))
  )

  return purchasedWithTokenEvent
}

export function createRoundCreatedEvent(
  newRound: BigInt,
  roundData: ethereum.Tuple
): RoundCreated {
  let roundCreatedEvent = changetype<RoundCreated>(newMockEvent())

  roundCreatedEvent.parameters = new Array()

  roundCreatedEvent.parameters.push(
    new ethereum.EventParam(
      "newRound",
      ethereum.Value.fromUnsignedBigInt(newRound)
    )
  )
  roundCreatedEvent.parameters.push(
    new ethereum.EventParam("roundData", ethereum.Value.fromTuple(roundData))
  )

  return roundCreatedEvent
}

export function createRoundUpdatedEvent(
  round: BigInt,
  roundData: ethereum.Tuple
): RoundUpdated {
  let roundUpdatedEvent = changetype<RoundUpdated>(newMockEvent())

  roundUpdatedEvent.parameters = new Array()

  roundUpdatedEvent.parameters.push(
    new ethereum.EventParam("round", ethereum.Value.fromUnsignedBigInt(round))
  )
  roundUpdatedEvent.parameters.push(
    new ethereum.EventParam("roundData", ethereum.Value.fromTuple(roundData))
  )

  return roundUpdatedEvent
}

export function createSignerUpdatedEvent(
  oldSigner: Address,
  newSigner: Address
): SignerUpdated {
  let signerUpdatedEvent = changetype<SignerUpdated>(newMockEvent())

  signerUpdatedEvent.parameters = new Array()

  signerUpdatedEvent.parameters.push(
    new ethereum.EventParam("oldSigner", ethereum.Value.fromAddress(oldSigner))
  )
  signerUpdatedEvent.parameters.push(
    new ethereum.EventParam("newSigner", ethereum.Value.fromAddress(newSigner))
  )

  return signerUpdatedEvent
}

export function createTokenDataAddedEvent(
  token: Address,
  data: ethereum.Tuple
): TokenDataAdded {
  let tokenDataAddedEvent = changetype<TokenDataAdded>(newMockEvent())

  tokenDataAddedEvent.parameters = new Array()

  tokenDataAddedEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  tokenDataAddedEvent.parameters.push(
    new ethereum.EventParam("data", ethereum.Value.fromTuple(data))
  )

  return tokenDataAddedEvent
}

export function createTokensAccessUpdatedEvent(
  round: BigInt,
  token: Address,
  access: boolean,
  customPrice: BigInt
): TokensAccessUpdated {
  let tokensAccessUpdatedEvent = changetype<TokensAccessUpdated>(newMockEvent())

  tokensAccessUpdatedEvent.parameters = new Array()

  tokensAccessUpdatedEvent.parameters.push(
    new ethereum.EventParam("round", ethereum.Value.fromUnsignedBigInt(round))
  )
  tokensAccessUpdatedEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  tokensAccessUpdatedEvent.parameters.push(
    new ethereum.EventParam("access", ethereum.Value.fromBoolean(access))
  )
  tokensAccessUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "customPrice",
      ethereum.Value.fromUnsignedBigInt(customPrice)
    )
  )

  return tokensAccessUpdatedEvent
}
