library mist;

import 'dart:io';
import 'package:Mist/Mist.dart';
import 'package:unittest/unittest.dart';
import 'package:mock/mock.dart';

void main () {
  test('MistResource instantiation', () {
    expect(new TestResource('/test') is MistResource, isTrue);
    });
  
  test('MistResource parsing URI arguments', () {
    var resource = new TestResource('/:var1/abc/:var2');
    var uri = new MockUri.generate('/first/abc/second');
    
    Map<String, String> param_map = resource.getUriParametersMap(uri);
    expect(param_map, containsPair('var1', 'first'));
    expect(param_map, containsPair('var2', 'second'));
    });
  
  test('MistResource throws a ResourceMethodNotImplementedException', () {
    var resource = new TestResource('/test'); 
    expect(() => resource.put(), throwsA(new isInstanceOf<ResourceMethodNotImplementedException>()));      
    });
  
  test('MistResourceMapper registering resource', () {
    MistResourceMapper mapper = new MistResourceMapper();
    expect(mapper.registered_resources.length, equals(0));
    var resource = new MockResource.generate('/test', ['get']);
    mapper.registerResource(resource);
    expect(mapper.registered_resources.length, equals(1));    
    });
  
  test('MistResourceMapper throws MultipleResourcesWithSameUriPatternException', () {
    MistResourceMapper mapper = new MistResourceMapper();
    expect(mapper.registered_resources.length, equals(0));
    var resource1 = new MockResource.generate('/test', ['get']);
    mapper.registerResource(resource1);
    expect(() => mapper.registerResource(resource1), throwsA(new isInstanceOf<MultipleResourcesWithSameUriPatternException>()));    
    var resource2 = new MockResource.generate('/:test', ['get']);
    var resource3 = new MockResource.generate('/:xxx', ['get']);
    mapper.registerResource(resource2);
    expect(() => mapper.registerResource(resource3), throwsA(new isInstanceOf<MultipleResourcesWithSameUriPatternException>()));      
  });
  
  test('MistResourceMapper fetching resources by request - matching URIs', () {
    MistResourceMapper mapper = new MistResourceMapper();
    var resource = new MockResource.generate('/test', ['get']);
    var request = new MockRequest.generate('/test', 'get');
    mapper.registerResource(resource);    
    expect(mapper.getResourceByRequest(request), equals(resource));    
    });
  
  test('MistResourceMapper fetching resources by request - automatic weighting', () {
    MistResourceMapper mapper = new MistResourceMapper();
    var resource1 = new MockResource.generate('/test', ['get']);
    var resource2 = new MockResource.generate('/:test', ['get']);
    
    var resource3 = new MockResource.generate('/prefix/test', ['get']);
    var resource4 = new MockResource.generate('/prefix/:xxx', ['get'], 10);
    
    var request1 = new MockRequest.generate('/test', 'get');
    var request2 = new MockRequest.generate('/prefix/test', 'get');
    
    mapper.registerResource(resource1);    
    mapper.registerResource(resource2);    
    expect(mapper.getResourceByRequest(request1), equals(resource1));
    mapper.registerResource(resource3);    
    mapper.registerResource(resource4);    
    expect(mapper.getResourceByRequest(request2), equals(resource4));    
    });
  
  test('MistResourceMapper throws MultipleResourcesMatchUriException', () {
    MistResourceMapper mapper = new MistResourceMapper();
    var resource1 = new MockResource.generate('/test', ['get']);
    var resource2 = new MockResource.generate('/:test', ['get'], 1);

    var request = new MockRequest.generate('/test', 'get');
    
    mapper.registerResource(resource1);    
    mapper.registerResource(resource2);    
    expect(() => mapper.getResourceByRequest(request), throwsA(new isInstanceOf<MultipleResourcesMatchUriException>())); 
    });
  
  test('MistResourceMapper throws NoResourceMatchUriException', () {
    MistResourceMapper mapper = new MistResourceMapper();
    var resource = new MockResource.generate('/test', ['get']);

    var request = new MockRequest.generate('/test1', 'get');
    
    mapper.registerResource(resource);    
    expect(() => mapper.getResourceByRequest(request), throwsA(new isInstanceOf<NoResourcesMatchUriException>())); 
    });
  
  test('MistRequestHandler executes correct resource method based on request method', () {
    var mist = new MockMist();
    var mapper = new MockMistResourceMapper();
    var resource = new MockResource.generate('/test', ['post']);
    var request = new MockRequest.generate('/test', 'post');
    var handler = new MistRequestHandler(mist);
    
    mist.when(callsTo('get resource_mapper')).alwaysReturn(mapper);
    mapper.when(callsTo('getResourceByRequest')).alwaysReturn(resource);
    
    handler.handle(request);
    resource.getLogs(callsTo('post')).verify(happenedOnce);
    });
  
  test('Mist instantiation', () {
    expect(new Mist('127.0.0.1', 1478) is Mist, isTrue);
    expect(new Mist('127.0.0.1', 1478, use_default_behavior: false) is Mist, isTrue);
    });
  
  //Todo: Tests for exceptionHandlers (each one)
  
  test('Mist registering request handlers', () {
    var mist = new Mist('127.0.0.1', 1478, use_default_behavior: false);
    var request_handler1 = new MockRequestHandler();
    var request_handler2 = new MockRequestHandler();
    var request_handler3 = new MockRequestHandler();
    request_handler1.when(callsTo('get id')).alwaysReturn(1);
    request_handler2.when(callsTo('get id')).alwaysReturn(2);
    request_handler3.when(callsTo('get id')).alwaysReturn(3);

    mist.registerRequestHandler(request_handler1);
    expect(mist.request_handlers.length, equals(1));
    expect(mist.request_handlers.first == request_handler1, isTrue);
    mist.registerRequestHandler(request_handler2);
    expect(mist.request_handlers.last == request_handler2, isTrue);
    mist.registerRequestHandler(request_handler3, push_first: true);
    expect(mist.request_handlers.first == request_handler3, isTrue);
   });
  
  test('Mist registering exception handlers', () {
    var mist = new Mist('127.0.0.1', 1478, use_default_behavior: false);
    int current_handler_count = mist.exception_handlers.length;
    mist.registerExceptionHandler(MockException, new MockExceptionHandler());
    expect(mist.exception_handlers.length, equals(1));
   });
  
  test('Mist executes request handlers', () {
    var mist = new Mist('127.0.0.1', 1478, use_default_behavior: false);
    var request_handler = new MockRequestHandler.generate();
    var request = new MockRequest.generate('/test', 'get');
          
    mist.registerRequestHandler(request_handler);
    mist.processRequest(request);
    
    request_handler.getLogs(callsTo('handle')).verify(happenedOnce);
    });
  
  test('Mist executes exception handlers', () {
    var mist = new Mist('127.0.0.1', 1478);
    var request = new MockRequest.generate('/test', 'post');
    var resource = new MockResource.generate('/test', ['get']);
    var exception_handler = new MockExceptionHandler();
    
    resource.when(callsTo('post')).alwaysThrow(new MockException());
    
    mist.registerResource(resource);
    mist.registerExceptionHandler(MockException, exception_handler);
    mist.processRequest(request);
    
    exception_handler.getLogs(callsTo('handle')).verify(happenedOnce);
    });
  
  test('Mist propagates unhandled exceptions', () {
    var mist = new Mist('127.0.0.1', 1478);
    var request = new MockRequest.generate('/test', 'post');
    var resource = new MockResource.generate('/test', ['get']);
    
    resource.when(callsTo('post')).alwaysThrow(new MockException());
    
    mist.registerResource(resource);
    expect(() => mist.processRequest(request), throwsA(new isInstanceOf<MockException>())); 
    });
}

class MockMist extends Mock implements Mist {
  MockMist() {}
}
class MockMistResourceMapper extends Mock implements MistResourceMapper {
  MockMistResourceMapper() {}
}
class MockResource extends Mock implements MistResource {
  int weight;
  
  MockResource() {}
  
  MockResource.generate(String uri, List<String> methods, [this.weight = 0]) {    
    this.when(callsTo('get uri')).alwaysReturn(uri);
    this.when(callsTo('get weight')).alwaysReturn(this.weight);
    this.when(callsTo('set weight')).alwaysCall((weight) {this.weight = weight;});
    methods.forEach((method) {
      this.when(callsTo(method)).alwaysCall((request) {});
    });
  }
}
class MockRequestHandler extends Mock implements RequestHandler {
  MockRequestHandler() {}
  
  MockRequestHandler.generate() {
    this.when(callsTo('handle')).thenCall((request) {});
  }
}
class MockExceptionHandler extends Mock implements ExceptionHandler {}
class MockException extends Mock implements BaseServerException {}
class MockRequest extends Mock implements HttpRequest {
  MockRequest () {}
    
  MockRequest.generate(String uri, String method) {
    this.when(callsTo('get uri')).alwaysReturn(new MockUri.generate(uri));
    this.when(callsTo('get response')).alwaysReturn(new MockResponse());
    this.when(callsTo('get method')).alwaysReturn(method);
  }
}
class MockResponse extends Mock implements HttpResponse {}
class MockUri extends Mock implements Uri {
  MockUri() {}
  
  MockUri.generate(String uri) {
    this.when(callsTo('get path')).alwaysReturn(uri);
  }
}

/**
 * Actual implementation to test
 */
class TestResource extends MistResource {
  TestResource(String uri, {int weight:0}) : super(uri, weight:weight);
    
  get(HttpRequest request) {    
    request.response.write('implementation');
  }
}

void clearLogs(List<Mock> objects) {
  objects.forEach((object) {
    object.clearLogs();
  });
}
