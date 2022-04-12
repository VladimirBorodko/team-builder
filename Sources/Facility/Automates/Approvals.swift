import Foundation
import Facility
public struct Approvals {
  public var branchApproval: [Approval] = []
  public var teamApproval: [Team] = []
  public var regularApprovers: [String: Group] = [:]
  public var reserveApprovers: Group? = nil
  public var emergencyApprovers: Group? = nil
  public init() {}
  public static func append(approvals: inout Self, yaml: Yaml.Approvals) throws {
//    try approvals.targetBranchCriteria += yaml.branchOwnage.or([:]).map(Approval.make(pair:))
//    approvals.teamReview += yaml.teamOwnage.or([:]).map(Team.make(pair:))
//    approvals.regularApprovers = yaml.regularApprovers.or([:]).mapValues(Group.make(yaml:))
//    approvals.reserveApprovers = yaml.reserveApprovers.map(Group.make(yaml:))
//    approvals.emergencyApprovers = yaml.emergencyApprovers.map(Group.make(yaml:))
  }
  public struct Group {
    public var award: String
    public var quote: Int
    public var requiredApprovers: Set<String>
    public var collectiveApprovers: Set<String>
    public static func make(
      yaml: Yaml.Approvers.Group
    ) -> Self {
      .init(
        award: yaml.award,
        quote: yaml.quote,
        requiredApprovers: .init(yaml.required.or([])),
        collectiveApprovers: .init(yaml.collective.or([]))
      )
    }
  }
  public struct Approval {
    public var approval: String
    public var criteria: Criteria
    public static func make(
      pair: Dictionary<String, Yaml.Criteria>.Element
    ) throws -> Self { try Id
      .make(pair.value)
      .map(Criteria.init(yaml:))
      .map(Criteria.ensureNotEmpty(criteria:))
      .reduce(pair.key, Self.init(approval:criteria:))
      .get()
    }
  }
  public struct Team {
    public var approval: String
    public var names: Set<String>
    public static func make(
      pair: Dictionary<String, [String]>.Element
    ) -> Self { Id
      .make(pair.value)
      .map(Set<String>.init(_:))
      .reduce(pair.key, Self.init(approval:names:))
      .get()
    }
  }
}
