{{flutter_js}}
{{flutter_build_config}}

// Keep the CanvasKit runtime on the same origin as the application. This
// avoids startup failures when the browser cannot reach gstatic.com.
_flutter.loader.load({
  config: {
    canvasKitBaseUrl: 'canvaskit/',
  },
});
