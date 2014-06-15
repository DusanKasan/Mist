import 'dart:io';
import 'package:Mist/Mist.dart';

main() {
  Mist mist = new Mist('127.0.0.1', 8080);
  mist.registerRequestHandler(new LogUriRequestHandler());
  mist.registerResource(new TestResource());
  mist.deploy();
}

class TestResource extends MistResource 
{  
  /**
   * Bind to uri /:id.
   */
  TestResource() : super('/:id');
  
  /**
   * Gets id variable from URI and returns it to client.
   */
  get(HttpRequest request) {
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