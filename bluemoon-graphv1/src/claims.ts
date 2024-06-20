import {
  ClaimSet as ClaimSetEvent,
  FundsClaimed as FundsClaimedEvent,
  PresaleUpdated as PresaleUpdatedEvent,
  RoleAdminChanged as RoleAdminChangedEvent,
  RoleGranted as RoleGrantedEvent,
  RoleRevoked as RoleRevokedEvent,
  RoundEnableUpdated as RoundEnableUpdatedEvent,
  SignerUpdated as SignerUpdatedEvent
} from "../generated/Claims/Claims"
import {
  ClaimSet,
  FundsClaimed,
  PresaleUpdated,
  RoleAdminChanged,
  RoleGranted,
  RoleRevoked,
  RoundEnableUpdated,
  SignerUpdated
} from "../generated/schema"

export function handleClaimSet(event: ClaimSetEvent): void {
  let entity = new ClaimSet(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.to = event.params.to
  entity.round = event.params.round
  entity.claimInfo_token = event.params.claimInfo.token
  entity.claimInfo_amount = event.params.claimInfo.amount

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleFundsClaimed(event: FundsClaimedEvent): void {
  let entity = new FundsClaimed(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.by = event.params.by
  entity.round = event.params.round
  entity.token = event.params.token
  entity.amount = event.params.amount

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handlePresaleUpdated(event: PresaleUpdatedEvent): void {
  let entity = new PresaleUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.prevAddress = event.params.prevAddress
  entity.newAddress = event.params.newAddress

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleRoleAdminChanged(event: RoleAdminChangedEvent): void {
  let entity = new RoleAdminChanged(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.role = event.params.role
  entity.previousAdminRole = event.params.previousAdminRole
  entity.newAdminRole = event.params.newAdminRole

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleRoleGranted(event: RoleGrantedEvent): void {
  let entity = new RoleGranted(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.role = event.params.role
  entity.account = event.params.account
  entity.sender = event.params.sender

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleRoleRevoked(event: RoleRevokedEvent): void {
  let entity = new RoleRevoked(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.role = event.params.role
  entity.account = event.params.account
  entity.sender = event.params.sender

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleRoundEnableUpdated(event: RoundEnableUpdatedEvent): void {
  let entity = new RoundEnableUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.oldAccess = event.params.oldAccess
  entity.newAccess = event.params.newAccess

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleSignerUpdated(event: SignerUpdatedEvent): void {
  let entity = new SignerUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.oldSigner = event.params.oldSigner
  entity.newSigner = event.params.newSigner

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}
