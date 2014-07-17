#Mist - Web server micro framework for Dart

[![Build Status](https://drone.io/github.com/DusanKasan/Mist/status.png)](https://drone.io/github.com/DusanKasan/Mist/latest)

Mist is a micro framework for creating server-side applications in Dart oriented on REST services. It is modular and extensible. Its core provides only the basic functionality with the tools to implement specific functionality with ease.

Mist is a specific implementation of abstract concepts located in /lib/src/mist_abstraction.dart. If you can not achieve desired behavior with Mist, you can create your specific implementation for this abstraction.

##Example usage
This is just an example, we will explain it later.

In this example usage we have:
- Mist server at 127.0.0.1 on port 8080
- Request handler which will log every request to this server into console
- Resource on URI /:id which accepts GET HTTP method

```dart
import 'dart:io';
import 'package:Mist/Mist.dart';

main() {
  Mist mist = new Mist('127.0.0.1', 8080);
  mist.registerRequestHandler(new LogUriRequestHandler());
  mist.registerResource(new TestResource());
  mist.deploy();
}

@uri("/:id")
class TestResource extends MistResource 
{    
  /**
   * Gets id variable from URI and returns it to client.
   */
  @method("get")
  getIdParam(HttpRequest request) {
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
```

##Mist
Mist class is the web server itself.

In constructor it takes 2 positional arguments and 1 named optional argument:
- `var address`, where it will be listening
- `int port`, on which it will be listening
- `bool use_default_behavior`, which is true by default 

The positional arguments are the same arguments that are used when instantiating `dart:io.HttpServer`.

You can disable most of the default behavior of Mist described here (the `MistRequestHandler` and default exception handlers) by passing `use_default_behavior:false` into constructor of Mist, which will prevent the registering of `MistRequestHandler` and default exception handlers in Mist.

When Mist is instantiated, you can:
- register request handlers
- register exception handlers
- register resources
- deploy Mist (start listening for incoming requests)

These are explained below.

##Request handlers
Mist enables you to register request handlers, which are top-level request processors. These are children of `RequestHandler` abstract class which requires you to implement method `void handle(HttpRequest request)`. You can make arbitrary changes to the request object inside the handle method. For example, request handlers can implement request logging, filtration, etc.

The registering is done through Mist method `void registerRequestHandler(ReuqestHandler handler)`. Even the core logic of Mist (resource path matching, etc.) is implemented as a `MistRequestHandler` which is registered into Mist upon instantiation.

##Exception handlers
Exception handlers are top level exception handlers. You can register them into Mist using its method `void registerExceptionHandler(Type exception_type, ExceptionHandler exception_handler)`. When the exception of the registered type is thrown, its exception handler will execute its `void handle(HttpRequest request, exception)` method.

Note that only one exception handler can be registered for one exception type, but exception handlers will be invoked even for subtypes of the registered exceptions too. This is handy if you have one "base" exception from which you inherit and need some actions performed for each of them, but some other action for all of them.

There are 3 exception handlers registered into Mist by default:
- `NoResourcesMatchUriExceptionHandler`, which returns HTTP code 404 (NOT FOUND) to the client when no resource is found for the current request (and `NoResourcesMatchUriException` is thrown)
- `MultipleResourcesMatchUriExceptionHandler`, which returns HTTP code 409 (CONFLICT) to the client when multiple resources are found for the current request (and `MultipleResourcesMatchUriException` is thrown)
- `ResourceMethodNotImplementedExceptionHandler`, which returns HTTP code 405 (METHOD NOT ALLOWED) to the client when the matched resource is not implementing called HTTP method (and `ResourceMethodNotImplementedException` is thrown)

##Mist resources
Each resource is represented as a child of `MistResource` abstract class. They are identified by their `String uri` and `int weight` properties which are represented by annotating the class using `@uri(String uri)` and `@weight(int weight)` respectively. `uri` specifies to which URI is this resource bound. 

URIs can be:
- static `/test/uri` 
- dynamic `/test/:var` where variables are marked by colon (:) and followed by variable name

If we have these two examples registered into Mist, all requests with URIs `/test/{{random_string}}` will be processed by the dynamic one, except for the `/test/uri` which will be pointed to the static one if they both have the same priority, thanks to the automatic weighing of the resources - during registration, the priority of the dynamic URI will get decreased by an amount equal to the number of variables in it.

So, if we register:
- resource with `/test/uri/` and weight 0
- resource with `/test/:var/` and weight 0

the weight of the second resource will get decreased by 1 to -1. So when the request with uri `/test/uri` comes, the static resource will have higher weight and will be prioritized. This could be a problem when registering 2 resources with overlaping dynamic URIs, for example `/test/:uri` and `/:test/uri`. In this case you have to manually assign weight to the resources to ensure correct prioritization.

The resources should have one public method for each HTTP method (i.e. get, put, post ...) you want them to process. These methods should take 1 argument being `HttpRequest` and must be annotated with `@method(String method_name)`.These will be called by `MistRequestHandler`, which is the core request processor in Mist, respectively by matching the currently incoming HTTP methods to matched resource public methods. No that mist also supports asynchronous code execution. All you have to do, is return a Future at the end of asynchronous method. Mist will recognize the future and will change its behavior accordingly (catching future exceptions, etc...)

`MistResource` also has a method `Map<String,String> getUriParametersMap(HttpRequest request)` to fetch variables from currently processed request, by comparing it to its `uri` property.
