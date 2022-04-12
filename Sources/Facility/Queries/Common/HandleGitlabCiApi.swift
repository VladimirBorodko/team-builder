import Foundation
import Facility
import FacilityAutomates
public protocol ProcessGitlabCiApi: ProcessHandler {}
extension ProcessGitlabCiApi where Reply: Decodable {
  public func handle(data: Data) throws -> Reply {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(Reply.self, from: data)
  }
}
public extension GitlabCI.Review {
  struct GetState: ProcessGitlabCiApi {
    public var tasks: [PipeTask]
    public init(review: GitlabCI.Review) {
      self.tasks = [.makeCurl(
        url: "\(review.baseUrl)?include_rebase_in_progress=true",
        headers: [review.gitlabci.auth]
      )]
    }
    public typealias Reply = Json.GitlabReviewState
  }
  struct GetAwarders: ProcessGitlabCiApi {
    public var tasks: [PipeTask]
    public init(review: GitlabCI.Review) {
      self.tasks = [.makeCurl(
        url: "\(review.baseUrl)?include_rebase_in_progress=true",
        headers: [review.gitlabci.auth]
      )]
    }
    public typealias Reply = [Json.GitlabAward]
  }
  struct PostAward: ProcessGitlabCiApi {
    public var tasks: [PipeTask]
    public init(review: GitlabCI.Review, award: String) {
      self.tasks = [.makeCurl(
        url: "\(review.baseUrl)/award_emoji?name=\(award)",
        method: "POST",
        headers: [review.gitlabci.auth]
      )]
    }
    public typealias Reply = Json.GitlabAward
  }
  struct PutAccept: ProcessGitlabCiApi {
    public var tasks: [PipeTask]
    public init(review: GitlabCI.Review, sha: Git.Sha) {
      self.tasks = [.makeCurl(
        url: "\(review.baseUrl)/merge",
        method: "PUT",
        checkHttp: false,
        data: "{\"sha\":\"\(sha.ref)\"}",
        headers: [review.gitlabci.auth, "Content-Type: application/json"]
      )]
    }
    public typealias Reply = Json.GitlabReviewState
  }
  struct PutRebase: ProcessGitlabCiApi {
    public var tasks: [PipeTask]
    public init(review: GitlabCI.Review) {
      self.tasks = [.makeCurl(
        url: "\(review.baseUrl)/rebase",
        method: "PUT",
        headers: [review.gitlabci.auth]
      )]
    }
    public typealias Reply = Json.GitlabRebase
  }
}
