import Foundation
import Facility
//public struct Conformism: Decodable {
//  var module: String
//  var name: String
//  var available: Available
//  var arguments: [Argument]?
//  var methods: [Method]
//  public static func makeContext(tree: Interpreter.Tree) throws -> [String: Any] {
//    let this = try Interpreter(tree: tree)
//      .decode(Self.self)
//    return try [
//      "module": this.module,
//      "name": this.name,
//      "available": this.available.dictionary(),
//      "methods": this.methods.map { try $0.dictionary(parent: this) },
//    ]
//  }
//  struct Method: Decodable {
//    var name: String
//    var selector: String
//    var result: String?
//    var available: Available?
//    var arguments: [Argument]?
//    var definitions: [Definition]?
//    func dictionary(parent: Conformism) throws -> [String: Any] { try [
//      "name": name,
//      "selector": selector,
//      "result": result.or("Void"),
//      "available": available.or(.init()).dictionary(parent: parent),
//      "arguments": (parent.arguments.or([]) + arguments.or([]))
//        .map { try $0.dictionary() },
//      "definitions": definitions
//        .or([])
//        .map { try $0.dictionary() },
//    ]}
//  }
//  struct Definition: Decodable {
//    var name: String
//    var arguments: [Argument]
//    func dictionary() throws -> [String: Any] { try [
//      "name": name,
//      "arguments": arguments.map { try $0.dictionary() },
//    ]}
//  }
//  struct Available: Decodable {
//    var macOS: String?
//    var iOS: String?
//    var tvOS: String?
//    var watchOS: String?
//    func dictionary(parent: Conformism? = nil) throws -> [String: String] { try [
//      "macOS": macOS
//        .flatMapNil(parent?.available.macOS)
//        .or { throw Thrown("No macOS version") },
//      "iOS": iOS
//        .flatMapNil(parent?.available.iOS)
//        .or { throw Thrown("No iOS version") },
//      "tvOS": tvOS
//        .flatMapNil(parent?.available.tvOS)
//        .or { throw Thrown("No tvOS version") },
//      "watchOS": watchOS
//        .flatMapNil(parent?.available.watchOS)
//        .or { throw Thrown("No watchOS version") },
//    ]}
//  }
//  struct Argument: Decodable {
//    var name: String
//    var type: String?
//    var async: String?
//    func dictionary() throws -> [String: String] {
//      guard let async = async else { return try [
//        "name": name,
//        "type": type.or { throw Thrown("No type or async") },
//      ]}
//      guard type == nil else { throw Thrown("Must be either type or async") }
//      return [
//        "name": name,
//        "async": async,
//      ]
//    }
//  }
//}
