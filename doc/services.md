# Services

## Example
> my_service.dart
```
class MyService {}

final ServiceProvider provider = ServiceProvider.fromFactory(MyService, (final Injector injector) => MyService());
```

> my_second_service.dart
```
import 'my_service.dart';

class MySecondService {
 final MyService dependency;
 
 MySecondService(this.dependency);
}

final var createCb = (final Injector injector) => MySecondService(injector.getDependency(MyService));

final ServiceProvider provider = ServiceProvider.fromFactory(MySecondService, createCb,
  dependencies: [MyService]
);
```
