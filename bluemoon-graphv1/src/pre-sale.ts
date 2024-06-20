import {
  BlacklistUpdated as BlacklistUpdatedEvent,
  BuyEnableUpdated as BuyEnableUpdatedEvent,
  FundsWalletUpdated as FundsWalletUpdatedEvent,
  OwnershipTransferred as OwnershipTransferredEvent,
  PurchasedWithClaimAmount as PurchasedWithClaimAmountEvent,
  PurchasedWithETH as PurchasedWithETHEvent,
  PurchasedWithToken as PurchasedWithTokenEvent,
  RoundCreated as RoundCreatedEvent,
  RoundUpdated as RoundUpdatedEvent,
  SignerUpdated as SignerUpdatedEvent,
  TokenDataAdded as TokenDataAddedEvent,
  TokensAccessUpdated as TokensAccessUpdatedEvent,
} from "../generated/PreSale/PreSale"
import {
  BlacklistUpdated,
  BuyEnableUpdated,
  FundsWalletUpdated,
  OwnershipTransferred,
  PurchasedWithClaimAmount,
  PurchasedWithETH,
  PurchasedWithToken,
  RoundCreated,
  RoundUpdated,
  SignerUpdated,
  TokenDataAdded,
  TokensAccessUpdated,
} from "../generated/schema"

export function handleBlacklistUpdated(event: BlacklistUpdatedEvent): void {
  let entity = new BlacklistUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.which = event.params.which
  entity.accessNow = event.params.accessNow

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleBuyEnableUpdated(event: BuyEnableUpdatedEvent): void {
  let entity = new BuyEnableUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.oldAccess = event.params.oldAccess
  entity.newAccess = event.params.newAccess

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleFundsWalletUpdated(event: FundsWalletUpdatedEvent): void {
  let entity = new FundsWalletUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.oldAddress = event.params.oldAddress
  entity.newAddress = event.params.newAddress

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleOwnershipTransferred(
  event: OwnershipTransferredEvent,
): void {
  let entity = new OwnershipTransferred(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.previousOwner = event.params.previousOwner
  entity.newOwner = event.params.newOwner

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handlePurchasedWithClaimAmount(
  event: PurchasedWithClaimAmountEvent,
): void {
  let entity = new PurchasedWithClaimAmount(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.by = event.params.by
  entity.amount = event.params.amount
  entity.token = event.params.token
  entity.round = event.params.round
  entity.tokenPrice = event.params.tokenPrice
  entity.tokenPurchased = event.params.tokenPurchased

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handlePurchasedWithETH(event: PurchasedWithETHEvent): void {
  let entity = new PurchasedWithETH(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.by = event.params.by
  entity.code = event.params.code
  entity.amountPurchasedETH = event.params.amountPurchasedETH
  entity.round = event.params.round
  entity.roundPrice = event.params.roundPrice
  entity.tokenPurchased = event.params.tokenPurchased

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handlePurchasedWithToken(event: PurchasedWithTokenEvent): void {
  let entity = new PurchasedWithToken(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.token = event.params.token
  entity.tokenPrice = event.params.tokenPrice
  entity.by = event.params.by
  entity.code = event.params.code
  entity.amountPurchased = event.params.amountPurchased
  entity.tokenPurchased = event.params.tokenPurchased
  entity.round = event.params.round

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleRoundCreated(event: RoundCreatedEvent): void {
  let entity = new RoundCreated(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.newRound = event.params.newRound
  entity.roundData_startTime = event.params.roundData.startTime
  entity.roundData_endTime = event.params.roundData.endTime
  entity.roundData_price = event.params.roundData.price

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleRoundUpdated(event: RoundUpdatedEvent): void {
  let entity = new RoundUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.round = event.params.round
  entity.roundData_startTime = event.params.roundData.startTime
  entity.roundData_endTime = event.params.roundData.endTime
  entity.roundData_price = event.params.roundData.price

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleSignerUpdated(event: SignerUpdatedEvent): void {
  let entity = new SignerUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.oldSigner = event.params.oldSigner
  entity.newSigner = event.params.newSigner

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleTokenDataAdded(event: TokenDataAddedEvent): void {
  let entity = new TokenDataAdded(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.token = event.params.token
  entity.data_priceFeed = event.params.data.priceFeed
  entity.data_normalizationFactorForToken =
    event.params.data.normalizationFactorForToken
  entity.data_tolerance = event.params.data.tolerance

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleTokensAccessUpdated(
  event: TokensAccessUpdatedEvent,
): void {
  let entity = new TokensAccessUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.round = event.params.round
  entity.token = event.params.token
  entity.access = event.params.access
  entity.customPrice = event.params.customPrice

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}
