part of mist;

/**
 * If no [MistResource] is matched, returns [HttpStatus.NOT_FOUND] with appropriate message. 
 */
class NoResourcesMatchUriExceptionHandler extends ExceptionHandler {
  void handle(HttpRequest request, NoResourcesMatchUriException exception) {
    request.response.statusCode = HttpStatus.NOT_FOUND;
    request.response.write('No resource with this URI: ' + request.uri.path);
  }
}

/**
 * If no multiple [MistResource] are matched, returns [HttpStatus.CONFLICT] with appropriate message. 
 */
class MultipleResourcesMatchUriExceptionHandler extends ExceptionHandler {
  void handle(HttpRequest request, MultipleResourcesMatchUriException exception) {
    request.response.statusCode = HttpStatus.CONFLICT;
    request.response.write('Multiple resources with the same weight match this URI: ' + request.uri.path);
  }
}

/**
 * If calling non-existing method on [MistResource], returns [HttpStatus.METHOD_NOT_ALLOWED] with appropriate message. 
 */
class ResourceMethodNotImplementedExceptionHandler extends ExceptionHandler {
  void handle(HttpRequest request, ResourceMethodNotImplementedException exception) {
    request.response.statusCode = HttpStatus.METHOD_NOT_ALLOWED;
    request.response.write('Resource on URI: ' + request.uri.path + ' does not support method: ' + request.method);
  }
}