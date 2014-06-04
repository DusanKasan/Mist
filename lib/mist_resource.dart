part of mist;

/**
 * Base resource for Mist, inherit from here.
 */
abstract class MistResource extends Resource {
  String uri;
  int weight = 0;

  MistResource(String this.uri, {int this.weight: 0});

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