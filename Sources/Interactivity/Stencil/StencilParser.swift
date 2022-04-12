import Foundation
import Stencil
import Facility
import FacilityQueries
public enum StencilParser {
  public static func renderStencil(query: RenderStencil) throws -> RenderStencil.Reply {
    let context = query.context.reduce(into: [:]) { $0.merge($1){ $1 } }
    return try Template(templateString: query.template).render(context)
  }
}
