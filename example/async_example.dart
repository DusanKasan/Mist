import 'dart:io';
import 'dart:async';
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
    var a = new Future(() => this.getUriParametersMap(request.uri));
    return a.then((parameters) {request.response.write(parameters['id']);});
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