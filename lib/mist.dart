library mist;

import 'dart:io';
import 'dart:mirrors';
import 'src/mist_abstraction.dart';
import 'src/annotations.dart' as Annotations;

export 'src/mist_abstraction.dart' hide Server, Resource;
export 'src/annotations.dart';

part 'src/mist_resource_mapper.dart';
part 'src/mist_resource.dart';
part 'src/mist_request_handler.dart';
part 'src/mist_exceptions.dart';
part 'src/mist_exception_handlers.dart';
part 'src/utils.dart';

/**
 * Mist
 * 
 * Simple and modular web server micro framework.
 */
class Mist extends Server {
  /**
   * Creates Mist on [address] and [port]. It will not be active until it is [deploy]ed.
   * 
   * If [use_default_behavior] is set to false, it will not register any of the default behavior of Mist.
   * This means that at least [ResourceMapper] and [RequestHandler] will have to be set manually before [deploy]ment.
   */
  Mist(var address, int port, {use_default_behavior: true}) : super(address, port) {
    if (use_default_behavior == true) {
      this._setDefaultBehavior();
    }
  }
  
  /**
   * Sets default behavior for Mist, registers [MistResourceMapper], [MistRequestHandler] and some [ExceptionHandler]s.
   */
  void _setDefaultBehavior() {
    this.resource_mapper = new MistResourceMapper();
    this.registerRequestHandler(new MistRequestHandler(this));
    this.registerExceptionHandler(NoResourcesMatchUriException, new NoResourcesMatchUriExceptionHandler());
    this.registerExceptionHandler(MultipleResourcesMatchUriException, new MultipleResourcesMatchUriExceptionHandler());
    this.registerExceptionHandler(ResourceMethodNotImplementedException, new ResourceMethodNotImplementedExceptionHandler());
  }
}


