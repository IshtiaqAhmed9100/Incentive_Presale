import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as/assembly/index"
import { Address, BigInt, Bytes } from "@graphprotocol/graph-ts"
import { ClaimSet } from "../generated/schema"
import { ClaimSet as ClaimSetEvent } from "../generated/Claims/Claims"
import { handleClaimSet } from "../src/claims"
import { createClaimSetEvent } from "./claims-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

describe("Describe entity assertions", () => {
  beforeAll(() => {
    let to = Address.fromString("0x0000000000000000000000000000000000000001")
    let round = BigInt.fromI32(234)
    let claimInfo = "ethereum.Tuple Not implemented"
    let newClaimSetEvent = createClaimSetEvent(to, round, claimInfo)
    handleClaimSet(newClaimSetEvent)
  })

  afterAll(() => {
    clearStore()
  })

  // For more test scenarios, see:
  // https://thegraph.com/docs/en/developer/matchstick/#write-a-unit-test

  test("ClaimSet created and stored", () => {
    assert.entityCount("ClaimSet", 1)

    // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
    assert.fieldEquals(
      "ClaimSet",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "to",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "ClaimSet",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "round",
      "234"
    )
    assert.fieldEquals(
      "ClaimSet",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "claimInfo",
      "ethereum.Tuple Not implemented"
    )

    // More assert options:
    // https://thegraph.com/docs/en/developer/matchstick/#asserts
  })
})
