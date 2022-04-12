import Foundation
import Facility
public enum Json {
  public struct GitlabRebase: Decodable {
    public var rebaseInProgress: Bool
  }
  public struct GitlabReviewState: Decodable {
    public var title: String
    public var state: String
    public var targetBranch: String
    public var sourceBranch: String
    public var author: GitlabUser
    public var draft: Bool
    public var workInProgress: Bool
    public var mergeStatus: String
    public var mergeError: String?
    public var pipeline: Pipeline
    public var rebaseInProgress: Bool?
    public var hasConflicts: Bool
    public var blockingDiscussionsResolved: Bool
    public struct Pipeline: Decodable {
      public var id: Int
      public var sha: String
    }
  }
  public struct GitlabAward: Decodable {
    public var id: Int
    public var name: String
    public var user: GitlabUser
  }
  public struct GitlabUser: Decodable {
    public var username: String
  }
}
