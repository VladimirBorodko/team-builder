import Facility
import Foundation
public struct GitlabCI {
  private var apiDomain: String
  private var projectId: String
  private var token: String
  public init(apiDomain: String, projectId: String, token: String) {
    self.apiDomain = apiDomain
    self.projectId = projectId
    self.token = token
  }
  public var baseUrl: String {
    "\(apiDomain)/projects/\(projectId)"
  }
  public var auth: String {
    "Authorization: Bearer \(token)"
  }
  public func makeReview(mergeIid: String) -> Review { .init(gitlabci: self, mergeIid: mergeIid) }
  public struct Review {
    public var gitlabci: GitlabCI
    public var mergeIid: String
    public var baseUrl: String {
      "\(gitlabci.baseUrl)/merge_requests/\(mergeIid)"
    }
  }
}
