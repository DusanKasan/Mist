library annotations;
/**
 * Represents on which uri this [Resource] is located
 */
class uri {
  final String value;
  
  const uri(this.value);
}

/**
 * Represents weight of this [Resource]
 */
class weight {
  final int value;

  const weight(this.value);
}

/**
 * Represents which HTTP method, this function serves.
 */
class method {
  final String value;

  const method(this.value);
}