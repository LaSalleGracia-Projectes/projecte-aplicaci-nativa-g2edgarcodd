// Este script actualiza las importaciones de 'package:streamhub/' a 'package:projecte_aplicaci_nativa_g2edgarcodd/'
// Para ejecutarlo, debemos usar: dart update_imports.dart

import 'dart:io';

void main() async {
  // Directorio donde buscar archivos Dart
  final libDir = Directory('lib');
  final testDir = Directory('test');
  
  // Procesa los archivos
  await processDirectory(libDir);
  if (await testDir.exists()) {
    await processDirectory(testDir);
  }
  
  print('¡Importaciones actualizadas correctamente!');
}

Future<void> processDirectory(Directory dir) async {
  await for (final entity in dir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      await processFile(entity);
    }
  }
}

Future<void> processFile(File file) async {
  final content = await file.readAsString();
  
  // Reemplaza las importaciones
  final updatedContent = content.replaceAll(
    'package:streamhub/',
    'package:projecte_aplicaci_nativa_g2edgarcodd/'
  );
  
  // Si hubo cambios, guarda el archivo
  if (content != updatedContent) {
    await file.writeAsString(updatedContent);
    print('Actualizado: ${file.path}');
  }
} 