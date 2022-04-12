import Foundation
import Facility
import FacilityAutomates
import FacilityQueries
//public final class ConformistGenerator {
//  private let wire: Wire
//  public init(wire: Wire) { self.wire = wire }
//  public func generate(directory: String = "", template: String? = nil) throws {
//    fatalError()
//    let template = (try? wire.readFile(.init(file: directory + "Template.stencil"))) ?? template
//    for file in try wire.listFileSystem(.init(path: directory, include: .files)) {
//      guard file.hasSuffix(".yml") else { continue }
//      guard let template = template else { throw Thrown("No template in hierarchy \(directory)") }
//      let config = try wire.readFile(.init(file: directory + file))
//      let tree = try wire.decodeYaml(.init(content: config))
//      let configuration = try Conformism.makeContext(tree: tree)
//      let result = try wire.renderStencil(.init(template: template, configuration: configuration))
//      let file = directory + file.replacingOccurrences(of: ".yml", with: ".swift")
//      try wire.createFile(.init(file: file, data: result))
//    }
//    for subdirectory in try wire.listFileSystem(.init(path: directory, include: .directories)) {
//      try generate(directory: directory + subdirectory + "/", template: template)
//    }
//  }
//  public struct Wire {
//    public var readFile: Try.Fetch<ReadFile>
//    public var createFile: Try.Fetch<CreateFile>
//    public var listFileSystem: Try.Fetch<ListFileSystem>
//    public var decodeYaml: Try.Fetch<DecodeYaml>
//    public var renderStencil: Try.Fetch<RenderStencil>
//    public init(
//      readFile: @escaping Try.Fetch<ReadFile>,
//      createFile: @escaping Try.Fetch<CreateFile>,
//      listFileSystem: @escaping Try.Fetch<ListFileSystem>,
//      decodeYaml: @escaping Try.Fetch<DecodeYaml>,
//      renderStencil: @escaping Try.Fetch<RenderStencil>
//    ) {
//      self.readFile = readFile
//      self.createFile = createFile
//      self.listFileSystem = listFileSystem
//      self.decodeYaml = decodeYaml
//      self.renderStencil = renderStencil
//    }
//  }
//}
