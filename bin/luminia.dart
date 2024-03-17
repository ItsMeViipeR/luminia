import "package:luminia/lang/parser.dart";
import 'dart:io';

void main() {
  File('examples/test.tl').readAsString().then((String code) {
    final parser = Parser();
    final result = parser.parseCode(code);

    if (result.containsKey('test')) {
      final function = result['test'];
      function!([]);
    }
  });
}
