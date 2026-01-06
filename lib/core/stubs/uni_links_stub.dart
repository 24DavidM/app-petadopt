import 'dart:async';

// Stub para web - uni_links no soporta web correctamente
// Este archivo se importa automáticamente en web gracias a la importación condicional

/// Stream de URIs - siempre vacío en web
Stream<Uri?> get uriLinkStream => Stream.value(null);

/// Obtener URI inicial - siempre null en web
Future<Uri?> getInitialUri() async => null;
