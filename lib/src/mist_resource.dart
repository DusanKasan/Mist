part of mist;

/**
 * Base resource for Mist, inherit from here.
 */
abstract class MistResource extends Resource {
  String _uri;
  int _weight;
  Map<String, Symbol> _methods; 
  
  String get uri {
    if (_uri == null) {
      _uri = getMetadata(reflect(this).type, Annotations.uri).first.value;
    }
    return _uri;
  }
  
  int get weight {
    if (_weight == null) {
      try {
        _weight = getMetadata(reflect(this).type, Annotations.weight).first.value;
      } on MetadataNotFoundException catch (exception) {
        _weight = 0;
      }
    }
    return _weight;
  }
  
  set weight(int value) {
    _weight = value;
  }
  
  Map<String, Symbol> get methods {
    if (_methods == null) {
      _methods = new Map<String, Symbol>();
      reflect(this).type.instanceMembers.forEach((symbol, mirror) {
        if (mirror is MethodMirror && hasMetadata(mirror, Annotations.method)) {
          var http_method = getMetadata(mirror, Annotations.method);
          _methods[http_method.first.value] = symbol;
        }
      });
    }
    
    return _methods;
  }

  MistResource();

  /**
   * Processes HEAD HTTP method, which should return the same result as calling GET on the same [MistResource]
   * 
   * This is achieved by calling get, while forbidding response writing.
   */
  @Annotations.method("head")
  void head(HttpRequest request) {
    var proxy_request = new ProxyHttpRequest(request);
    var proxy_response = new ProxyHttpResponse(request.response);
    proxy_request.override_attribute("response", proxy_response);
    proxy_response.override_method("write", (object) {}); //forbid writing

    reflect(this).invoke(methods["get"], [proxy_request]); //will throw if not implemented, this is correct behavior
  }
  
  /**
   * Parses uri variables from [uri.path] using using [this.uri]. 
   */
  Map<String, String> getUriParametersMap(Uri uri) {
    RegExp placeholders_regex = new RegExp("(:[a-zA-Z0-9_]*)");
    List<String> placeholder_names = [];

    String uri_regex_string = this.uri.replaceAllMapped(placeholders_regex, (match) {
      var placeholder = match[1].substring(1);
      placeholder_names.add(placeholder);

      return "([^\/]*)";
    });
    
    RegExp uri_regex = new RegExp(uri_regex_string);
    Match uri_matches = uri_regex.firstMatch(uri.path);

    List<String> placeholder_values = uri_matches.groups(new List.generate(placeholder_names.length, (int index) {
      return index + 1;
    }));

    return new Map.fromIterables(placeholder_names, placeholder_values);
  }
  
  /**
   * Throw [ResourceMethodNotImplementedException] when invoking method that does not exist, so it can be handled by [RequestHandler].
   */
  void noSuchMethod(Invocation invocation) {
    throw new ResourceMethodNotImplementedException('No such method as ${invocation.memberName.toString()} on ${this.uri}');
  }
}

class ProxyHttpRequest extends Proxy implements HttpRequest {
  ProxyHttpRequest(HttpRequest request) : super (request);
}

class ProxyHttpResponse extends Proxy implements HttpResponse {
  ProxyHttpResponse(HttpResponse response) : super (response);
}