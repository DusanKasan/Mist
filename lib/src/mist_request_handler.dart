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
  void _executeResource(MistResource resource, HttpRequest request) {
    String http_method = request.method.toLowerCase();
    if (resource.methods.containsKey(http_method)) {
      InstanceMirror resource_mirror = reflect(resource);
      resource_mirror.invoke(resource.methods[http_method], [request]).reflectee;
    } else {
      throw new ResourceMethodNotImplementedException('No method ${http_method} on ${resource.uri}');
    }
  }
}
