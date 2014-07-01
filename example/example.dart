import 'dart:io';
import 'package:mists/mists.dart';

main() {  
  Mist mist = new Mist('127.0.0.1', 8081);
  mist.registerRequestHandler(new LogUriRequestHandler());
  mist.registerResource(new TestResource());
  mist.deploy();
}

@uri("/:id")
class TestResource extends MistResource
{
  /**
   * Gets id variable from URI and returns it to client.
   */
  @method("get")
  getRequestId(HttpRequest request) {
    var parameters = this.getUriParametersMap(request.uri);
    request.response.write(parameters['id']);
  }
}

/**
 * Print every uri to console.
 */
class LogUriRequestHandler extends RequestHandler {
  void handle(HttpRequest request) {
    print (request.uri.path);
  }
}