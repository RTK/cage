# Widgets

## Example
> my_widget.dart
```
final WidgetContainerFactory myWidget =
    WidgetContainerFactory(
        createPresenter: (final Injector injector) => MyPresenter(injector.getDependency(MyService),
        createView: () => MyView(),
        widgetKey: MyWidget
    );
```

> my_widget_meta.dart
```
const Key MyWidget = Key('MyWidget');

abstract class MyWidgetInterface {
    Color color;
}

@immutable
class MyWidgetOptions {
    final Color initialColor;
    
    @literal
    const MyWidgetOptions(this.initialColor);
}
```

> my_widget_presenter.dart
```
class MyPresenter extends Presenter<MyWidgetOptions> implements MyPresenterInterface {
    Color color;
    
    set _color(final Color color) {
        updateView(() {
            this.color = color;
        });
    }
    
    @override
    void onInit() {
        _color = options.initialColor;
    }
}
```

> my_widget_view.dart
```
class MyView extends View<MyPresenterInterface> {
    @override
    Widget createView(final BuildContext buildContext) {
        return Container(color: presenter.color);
    }
}
```
