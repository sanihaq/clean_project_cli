import 'dart:io';

void main(List<String> arguments) {
  final currentPath = arguments.isNotEmpty ? arguments[0] : Directory.current.path;

  final directoryPaths = findGitDirectories(currentPath);

  if (directoryPaths.isEmpty) {
    print('No Git repositories found in the specified directory.');
  } else {
    for (final directoryPath in directoryPaths) {
      final gitignoreContent = File('$directoryPath/.gitignore').readAsStringSync();
      final ignoredPaths = parseGitignore(gitignoreContent);
      for (var path in ignoredPaths) {
        deleteFromPath('$directoryPath/$path');
      }
      print('"$directoryPath" cleaned.');
    }
  }
}

List<String> findGitDirectories(String directoryPath) {
  final gitDirectories = <String>[];

  final directory = Directory(directoryPath);
  if (!directory.existsSync()) {
    print('The specified directory does not exist.');
    return gitDirectories;
  }

  final entries = directory.listSync(recursive: true).whereType<Directory>();
  for (final entry in [directory, ...entries]) {
    final gitignore = File('${entry.path}/.gitignore');
    if (gitignore.existsSync()) {
      gitDirectories.add(entry.path);
    }
  }

  return gitDirectories;
}

List<String> parseGitignore(String content) {
  return content
      .split('\n')
      .where((line) => line.isNotEmpty && !line.startsWith('#'))
      .toList();
}

void deleteFromPath(String path) {
  final fileSystemEntity = FileSystemEntity.typeSync(path);

  if (fileSystemEntity == FileSystemEntityType.directory) {
    final directory = Directory(path);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  } else if (fileSystemEntity == FileSystemEntityType.file) {
    final file = File(path);
    if (file.existsSync()) {
      file.deleteSync();
    }
  } else {
    // print('$path does not exist or is of unknown type.');
  }
}
