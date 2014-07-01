part of mist;

class MistResourceMapper extends ResourceMapper {
  Map<RegExp, MistResource> _resource_map = new Map<RegExp, MistResource>();
  
  /**
   * Get [List] of all registered [MistResource]s
   */
  List<MistResource> get registered_resources => this._resource_map.values.toList();
  
  /**
   * Fill the [_resource_map] with resource and use its regexp as key.
   * Regexp is created by replacing all uri variables (marked with : such as /tests/:id_test where id_test is a variable) by ([^\/]*) 
   */
  void registerResource(MistResource resource) {
    RegExp placeholders_regex = new RegExp("(:[a-zA-Z0-9_]+)");
    
    //Automatic weighting of resources
    if (placeholders_regex.hasMatch(resource.uri)) {
      resource.weight = resource.weight - placeholders_regex.allMatches(resource.uri).length;
    }

    String uri_regex_string = resource.uri.replaceAllMapped(placeholders_regex, (match) {
      return "([^\/]*)";
    });

    RegExp uri_regex = new RegExp('^' + uri_regex_string + '\$');

    //Dart can not match RegExp objects using containsKey(RegExp)
    this._resource_map.forEach((regexp, resource) {
      if(regexp.toString() == uri_regex.toString()) {
        throw new MultipleResourcesWithSameUriPatternException('Multiple resources on uri pattern ${uri_regex.pattern}');
      }
    });

    this._resource_map[uri_regex] = resource;
  }
  
  /**
   * Returns correct [MistResource] by comparing [request.uri] to [_resource_map] entries. 
   */
  MistResource getResourceByRequest(HttpRequest request) {
    MistResource matched_resource = null;
    Uri uri = request.uri;
        
    this._resource_map.forEach((uri_regex, resource) {
      if (uri_regex.hasMatch(uri.path)) {
        if (matched_resource == null || matched_resource.weight < resource.weight) {
          matched_resource = resource;
        } else if (matched_resource.weight == resource.weight) {
          throw new MultipleResourcesMatchUriException('Multiple resources match uri ${uri.path}');
        }
      }
    });

    if (matched_resource == null) {
      throw new NoResourcesMatchUriException('No resource found for uri ${uri.path}');
    }

    return matched_resource;
  } 
}