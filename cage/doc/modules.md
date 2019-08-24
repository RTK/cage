# Modules
The modules package handles bundling of logic to modules.
Splitting the source code to modules provides stricter separation of concern program architecture.
Additionally modules provide all necessary program parts (widgets, services) and thus can be used across applications.

## Featuring
- Registering a root module
- Adding child modules

## Examples
> app_module.dart
```
import 'child/child_module.dart'

final Module myModule = Module(Key('App'), imports: [childModule]);
```

> child/child_module.dart
```
final Module childModule = Module(Key('Child'));
```
