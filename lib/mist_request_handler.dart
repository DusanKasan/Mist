part of mist;

/**
 * Core request handling in Mist.
 * 
 * Gets correct [Resource] for [HttpRequest] from [ResourceMapper] and executes correct method.
 */
class MistRequestHandler implements RequestHandler {
  Server _server;

  MistRequestHandler(Server this._server);

  void handle(HttpRequest request) {
    var resource = this._server.resource_mapper.getResourceByRequest(request);
    this._executeResource(resource, request);
  }

  /**
   * Executes method on [resource]. This methods name is determined by [request.method.toLowerCase()]
   */
  void _executeResource(Resource resource, HttpRequest request) {
    String method = request.method.toLowerCase();
    InstanceMirror resource_mirror = reflect(resource);
    resource_mirror.invoke(new Symbol(method), [request]).reflectee;
  }
}
