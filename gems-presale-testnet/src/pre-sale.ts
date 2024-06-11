import { BigInt,Bytes } from "@graphprotocol/graph-ts"
import {
  BlacklistUpdated as BlacklistUpdatedEvent,
  BuyEnableUpdated as BuyEnableUpdatedEvent,
  FundsWalletUpdated as FundsWalletUpdatedEvent,
  OwnershipTransferred as OwnershipTransferredEvent,
  PricingUpdated as PricingUpdatedEvent,
  PurchasedWithClaimAmount as PurchasedWithClaimAmountEvent,
  PurchasedWithETH as PurchasedWithETHEvent,
  PurchasedWithETHForNFT as PurchasedWithETHForNFTEvent,
  PurchasedWithToken as PurchasedWithTokenEvent,
  PurchasedWithTokenForNFT as PurchasedWithTokenForNFTEvent,
  RoundCreated as RoundCreatedEvent,
  RoundUpdated as RoundUpdatedEvent,
  SignerUpdated as SignerUpdatedEvent,
  TokenDataAdded as TokenDataAddedEvent,
  TokensAccessUpdated as TokensAccessUpdatedEvent,
} from "../generated/PreSale/PreSale"
import {
  Purchase,
  BlacklistUpdated,
  BuyEnableUpdated,
  FundsWalletUpdated,
  OwnershipTransferred,
  PricingUpdated,
  PurchasedWithClaimAmount,
  PurchasedWithETH,
  PurchasedWithETHForNFT,
  PurchasedWithToken,
  PurchasedWithTokenForNFT,
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

export function handlePricingUpdated(event: PricingUpdatedEvent): void {
  let entity = new PricingUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.oldPrice = event.params.oldPrice
  entity.newPrice = event.params.newPrice

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
  let _id = event.transaction.hash.concatI32(event.logIndex.toI32())
  let _purchased = new Purchase(_id);

  _purchased.by = event.params.by
  _purchased.code = ""
  _purchased.token = event.params.token
  _purchased.tokenSelected = "TOKEN"
  _purchased.type = "GEMS"
  _purchased.amountPurchased = event.params.amount
  _purchased.round = event.params.round
  _purchased.blockTimestamp = event.block.timestamp
  _purchased.tokenPurchased = event.params.tokenPurchased
  _purchased.nftAmounts = []
  let id = event.params.round.toString().concat(event.params.token.toHexString())

  let tokenaccess = TokensAccessUpdated.load(id)

  let id_ = event.params.round.toString()
  let rc = RoundCreated.load(id_)
  if (rc) {
    _purchased.roundPrice = rc.roundData_price
    rc.save()
  }

  if (tokenaccess) {
    if (tokenaccess.customPrice != BigInt.fromI32(0))
      _purchased.roundPrice = tokenaccess.customPrice
    tokenaccess.save()
  }
  _purchased.tokenPrice = event.params.tokenPrice

  _purchased.transactionHash = event.transaction.hash
  _purchased.save()
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


  let _id = event.transaction.hash.concatI32(event.logIndex.toI32())
  let _purchased = new Purchase(_id);

  _purchased.by = event.params.by
  _purchased.code = event.params.code
  _purchased.token = new Bytes(0)
  _purchased.tokenSelected = "ETH"
  _purchased.type = "GEMS"
  _purchased.amountPurchased = event.params.amountPurchasedETH
  _purchased.round = event.params.round
  _purchased.blockTimestamp = event.block.timestamp
  _purchased.tokenPurchased = event.params.tokenPurchased
  _purchased.nftAmounts = []
  let id = event.params.round.toString().concat((new Bytes(0)).toHexString())

  let tokenaccess = TokensAccessUpdated.load(id)

  let id_ = event.params.round.toString()
  let rc = RoundCreated.load(id_)
  if (rc) {
    _purchased.roundPrice = rc.roundData_price
    rc.save()
  }

  if (tokenaccess) {
    if (tokenaccess.customPrice != BigInt.fromI32(0))
      _purchased.roundPrice = tokenaccess.customPrice
    tokenaccess.save()
  }
  _purchased.tokenPrice = BigInt.fromI32(0)

  _purchased.transactionHash = event.transaction.hash
  _purchased.save()
}

export function handlePurchasedWithETHForNFT(
  event: PurchasedWithETHForNFTEvent,
): void {
  let entity = new PurchasedWithETHForNFT(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.by = event.params.by
  entity.code = event.params.code
  entity.amountInETH = event.params.amountInETH
  entity.ethPrice = event.params.ethPrice
  entity.round = event.params.round
  entity.roundPrice = event.params.roundPrice
  entity.nftAmounts = event.params.nftAmounts

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()

  let _id = event.transaction.hash.concatI32(event.logIndex.toI32())
  let _purchased = new Purchase(_id);

  _purchased.by = event.params.by
  _purchased.code = event.params.code
  _purchased.tokenSelected = "ETH"
  _purchased.type = "NFT"

  _purchased.amountPurchased = event.params.amountInETH
  _purchased.round = event.params.round
  _purchased.blockTimestamp = event.block.timestamp

  _purchased.tokenPurchased = BigInt.fromI32(0)

  _purchased.nftAmounts = event.params.nftAmounts
  _purchased.token = new Bytes(0)

  let id = event.params.round.toString().concat((new Bytes(0)).toHexString())

  let tokenaccess = TokensAccessUpdated.load(id)

  let id_ = event.params.round.toString()
  let rc = RoundCreated.load(id_)
  if (rc) {
    _purchased.roundPrice = rc.roundData_price
    rc.save()
  }

  if (tokenaccess) {
    if (tokenaccess.customPrice != BigInt.fromI32(0))
      _purchased.roundPrice = tokenaccess.customPrice
    tokenaccess.save()
  }
  _purchased.tokenPrice = event.params.ethPrice

  _purchased.transactionHash = event.transaction.hash
  _purchased.save()
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
  let _id = event.transaction.hash.concatI32(event.logIndex.toI32())
  let _purchased = new Purchase(_id);

  _purchased.by = event.params.by
  _purchased.code = event.params.code
  _purchased.token = event.params.token
  _purchased.tokenSelected = "TOKEN"
  _purchased.type = "GEMS"
  _purchased.amountPurchased = event.params.amountPurchased
  _purchased.round = event.params.round
  _purchased.blockTimestamp = event.block.timestamp
  _purchased.tokenPurchased = event.params.tokenPurchased
  _purchased.nftAmounts = []

  let id = event.params.round.toString().concat(event.params.token.toHexString())

  let tokenaccess = TokensAccessUpdated.load(id)

  let id_ = event.params.round.toString()
  let rc = RoundCreated.load(id_)
  if (rc) {
    _purchased.roundPrice = rc.roundData_price
    rc.save()
  }

  if (tokenaccess) {
    if (tokenaccess.customPrice != BigInt.fromI32(0))
      _purchased.roundPrice = tokenaccess.customPrice
    tokenaccess.save()
  }
  _purchased.tokenPrice = event.params.tokenPrice
  _purchased.transactionHash = event.transaction.hash
  _purchased.save()
}


export function handlePurchasedWithTokenForNFT(
  event: PurchasedWithTokenForNFTEvent,
): void {
  let entity = new PurchasedWithTokenForNFT(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.token = event.params.token
  entity.tokenPrice = event.params.tokenPrice
  entity.by = event.params.by
  entity.code = event.params.code
  entity.amountPurchased = event.params.amountPurchased
  entity.round = event.params.round
  entity.roundPrice = event.params.roundPrice
  entity.nftAmounts = event.params.nftAmounts

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()

  let _id = event.transaction.hash.concatI32(event.logIndex.toI32())
  let _purchased = new Purchase(_id);

  _purchased.by = event.params.by
  _purchased.code = event.params.code
  _purchased.token = event.params.token
  _purchased.tokenSelected = "TOKEN"
  _purchased.type = "NFT"

  _purchased.amountPurchased = event.params.amountPurchased
  _purchased.round = event.params.round
  _purchased.blockTimestamp = event.block.timestamp
  _purchased.tokenPurchased = BigInt.fromI32(0)
  _purchased.nftAmounts = event.params.nftAmounts

  let id = event.params.round.toString().concat(event.params.token.toHexString())

  let tokenaccess = TokensAccessUpdated.load(id)

  let id_ = event.params.round.toString()
  let rc = RoundCreated.load(id_)
  if (rc) {
    _purchased.roundPrice = rc.roundData_price
    rc.save()
  }

  if (tokenaccess) {
    if (tokenaccess.customPrice != BigInt.fromI32(0))
      _purchased.roundPrice = tokenaccess.customPrice
    tokenaccess.save()
  }
  _purchased.tokenPrice = event.params.tokenPrice

  _purchased.transactionHash = event.transaction.hash
  _purchased.save()
}

export function handleRoundCreated(event: RoundCreatedEvent): void {
  let entity = new RoundCreated(
    event.params.newRound.toString()
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
  entity.data_normalizationFactorForNFT =
    event.params.data.normalizationFactorForNFT
  entity.data_tolerance = event.params.data.tolerance

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}


export function handleTokensAccessUpdated(
  event: TokensAccessUpdatedEvent
): void {
  let _id = event.params.round.toString().concat(event.params.token.toHexString())

  let allowed = TokensAccessUpdated.load(_id)
  if (allowed) {
    allowed.access = event.params.access
    allowed.customPrice = event.params.customPrice
    allowed.save()
  } else {
    let entity = new TokensAccessUpdated(
      event.params.round.toString().concat(event.params.token.toHexString())
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
}
