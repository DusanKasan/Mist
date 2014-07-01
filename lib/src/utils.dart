part of mist;

/**
 * Proxy access to objects, overrides some methods/attributes, all other are forwarded
 */
class Proxy {
  InstanceMirror target_reflection;
  Map<String, Function> method_overrides;
  Map<String, Object> attributes_overrides;

  Proxy(target, [this.method_overrides, this.attributes_overrides]) {
    target_reflection = reflect(target);    
    
    if (method_overrides == null) {
      method_overrides = {};
    }
    
    if (attributes_overrides == null) {
      attributes_overrides = {};
    }
  }
  
  void override_method(String function_name, Function function) {
    this.method_overrides[function_name] = function;
  }
  
  void override_attribute(String attribute_name, default_value) {
    this.method_overrides[attribute_name] = default_value;
  }

  noSuchMethod(Invocation invocation) {
    String invocation_name = MirrorSystem.getName(invocation.memberName);
    if (invocation_name.endsWith("=")) {
      invocation_name = invocation_name.replaceFirst("=", "");
    }
    Symbol invocation_symbol = MirrorSystem.getSymbol(invocation_name);
    
    if (invocation.isMethod) {
      if (method_overrides.containsKey(invocation.memberName)) {
        return Function.apply(method_overrides[invocation.memberName]
          , invocation.positionalArguments
          , invocation.namedArguments);
      } else {      
        return target_reflection.invoke(invocation.memberName
            , invocation.positionalArguments
            , invocation.namedArguments
            ).reflectee;
      }
    } else if (invocation.isGetter) {     
      if (attributes_overrides.containsKey(invocation_name)) {
        return attributes_overrides[invocation_name];
      } else {      
        return this.target_reflection.getField(invocation.memberName).reflectee;
      }
    } else if (invocation.isSetter) {     
      if (attributes_overrides.containsKey(invocation_name)) {
        attributes_overrides[invocation_name] = invocation.positionalArguments.first;
      } else {
        this.target_reflection.setField(invocation_symbol, invocation.positionalArguments.first);
      }
    }
  }
}

/**
 * Returns [List] of all metadata of [metadata_type] from [mirror].
 */
List getMetadata(Mirror mirror, Type metadata_type) {
  List metadata_objects = [];

  mirror.metadata.forEach((metadata) {  //all mirrors have metadata getter
    if (metadata.type.reflectedType == metadata_type) {
      metadata_objects.add(metadata.reflectee);
    }
  });
  
  return metadata_objects;
}

/**
 * Checks for metadata of [metadata_type] on [mirror]
 */
bool hasMetadata(Mirror mirror, Type metadata_type) {
 return getMetadata(mirror, metadata_type).isEmpty;
}