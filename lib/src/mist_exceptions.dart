part of mist;

/**
 * This exception is thrown if multiple [MistResource] are matched by request uri.
 */
class MultipleResourcesMatchUriException extends BaseServerException {
  MultipleResourcesMatchUriException(String cause) : super(cause);
}

/**
 * This exception is thrown if no [MistResource] is matched by request uri.
 */
class NoResourcesMatchUriException extends BaseServerException {
  NoResourcesMatchUriException(String cause) : super(cause);
}

/**
 * This exception is thrown if multiple [MistResource] with the same uri pattern would be inserted.
 */
class MultipleResourcesWithSameUriPatternException extends BaseServerException {
  MultipleResourcesWithSameUriPatternException(String cause) : super(cause);
}

/**
 * This exception is thrown if matched [MistResource] does not implement given method.
 */
class ResourceMethodNotImplementedException extends BaseServerException {
  ResourceMethodNotImplementedException(String cause) : super(cause);
}

/**
 * This exception is thrown if no metadata of requested type is found
 */
class MetadataNotFoundException extends BaseServerException {
  MetadataNotFoundException(String cause) : super(cause);
}