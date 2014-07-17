#Mist changelog

#### Mist v0.01 - 04.06.2014
Initial public release, no big bugs, needs some tweaking and code review. Proabably should make it more robust (i.e. MVC?) ... 

#### Mist v0.02 - 01.07.2014
Resource and methods identification moved into @uri, @weight and @method annotations. Added class for proxy access to objects and metadata access function.

#### Mist v0.03 - 10.07.2014
Resource methods can now be executed asynchronously, but have to return the last future of the execution chain to correctly close the response. Documentation soon to follow.