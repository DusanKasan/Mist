library abstraction;

import 'dart:io';
import 'dart:mirrors';
import 'dart:async';

/**
 * Main class of server, on it Resources and Request/Exception Handlers are registered.
 */
abstract class Server {
  ResourceMapper resource_mapper = null;
  List<RequestHandler> _request_handlers = new List<RequestHandler>();
  Map<Type,ExceptionHandler> _exception_handlers = new Map<Type,ExceptionHandler>();
  var _address;
  int _port;
  
  Server (this._address, this._port){}

  List<RequestHandler> get request_handlers => this._request_handlers;
  Map<Type,ExceptionHandler> get exception_handlers => this._exception_handlers;
  get address => this._address;
  int get port => this._port;
  
  /**
   * Register [resource] to [this._resource_mapper]
   */
  void registerResource(Resource resource) {
    this.resource_mapper.registerResource(resource);
  }

  /**
   * Register [handler] to exception of type [exception_type].
   * 
   * Note that only one one exception [handler] for each [exception_type] can be registered.
   * Upon registering [handler] for already registered [exception_type], the old handler will be overwritten.
   */
  void registerExceptionHandler(Type exception_type, ExceptionHandler handler) {
    this._exception_handlers[exception_type] = handler;
  }
  
  /**
   * Register [handler] to the end of request handler queue.
   * If [push_first] is true, then register it to front of the queue.
   */
  void registerRequestHandler(RequestHandler handler, {push_first:false}) {
    if (push_first) {
      this._request_handlers.insert(0, handler);
    } else {
      this._request_handlers.add(handler);
    }
  }
  
  /**
   * Put the server online.
   */
  void deploy() {
    HttpServer.bind(this._address, this._port).then((http_server) {
      http_server.listen((HttpRequest request) {       
        this.processRequest(request);
      });
    });
  }
  
  /**
   * Processing logic, this is public only for testing purposes.
   * 
   * Todo: Figure a way how to make this private and testable.
   */
  processRequest(HttpRequest request) {    
    var handlers = [];
    try {
      this._request_handlers.forEach((handler) {
        var handled = handler.handle(request);
        
        if (handled is Future) {
          handlers.add(handled);
        } else {
          handlers.add(new Future(() => handled));
        }
      });
    } catch (exception) {
      processException(request, exception);
    }
    
    Future.wait(handlers)
      ..catchError((exception) {
          this.processException(request, exception);
          request.response.close();
        })
      ..then((object) {
          request.response.close();
        });
  }
  
  processException(request, exception) {
    var exception_mirror = reflectClass(exception.runtimeType);
    var found_handler = false;
    
    this._exception_handlers.forEach((exception_type, handler) {
      //this should be possible with is, with mirrors it will be slow
      if (exception_mirror.isSubtypeOf(reflectType(exception_type))) {          
        found_handler = true;
        handler.handle(request, exception);
      }
    });
          
    //if no handler for this type is found, propagate exception
    if (found_handler == false) {
      throw exception;
    }
  }
}

/**
 * Resource management class in server.
 */
abstract class ResourceMapper {
  void registerResource(Resource resource);
  Resource getResourceByRequest(HttpRequest request);
}

/**
 * Resource representation - purely abstract entity
 */
abstract class Resource {}

/**
 * [RequestHandler] objects are top level request processors.
 * They intercept and modify [HttpRequest] objects.
 * They are registered in server using the method [Server.registerRequestHandler].
 */
abstract class RequestHandler {
  handle(HttpRequest request);
}

/**
 * [ExceptionHandler] objects are top level exception processors.
 * They are registered in server using the method [Server.registerExceptionHandler].
 */
abstract class ExceptionHandler {
  handle(HttpRequest request, Exception exception);
}

/**
 * Parent exception of every exception thrown by server
 */
abstract class BaseServerException implements Exception {
  String cause;
  BaseServerException(String cause) {
    this.cause = cause;
  }
}

/**
 * This exception is thrown if trying to rewrite assigned resource mapper.
 */
class ResourceMapperAlreadySetException extends BaseServerException {
  ResourceMapperAlreadySetException(String cause) : super(cause);
}