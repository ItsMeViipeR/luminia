import 'dart:convert';

class Parser {
  Map<String, Function(List<dynamic>)> parseCode(String code) {
    final RegExp functionRegExp = RegExp(
        r'fn\s+(\w+)\s*\(\s*([^)]*)\s*\)\s*:\s*(void|int|String)\s*{\s*([^}]*)\s*}');

    final RegExp variableRegExp =
        RegExp(r'(?:let\s+)?(\w+)\s*:\s*(\w+)\s*=\s*([^;]+)(;|\n)');

    final RegExp printRegExp =
        RegExp(r'print\(([^;"]+|"([^"]|\\")*"|[^;"]+\([^)]*\))(;|\n)?\)');

    final functionMatches = functionRegExp.allMatches(code);
    final variableMatches = variableRegExp.allMatches(code);

    final functions = <String, Function(List<dynamic>)>{};
    final variables = <String, dynamic>{};

    for (final match in variableMatches) {
      final variableName = match.group(1);
      final variableType = match.group(2);
      final variableValue = match.group(3);

      variables[variableName!] =
          _parseVariableValue(variableValue!, variableType!);
    }

    for (final match in functionMatches) {
      final functionName = match.group(1);
      final parameterList = match.group(2);
      final returnType = match.group(3);
      final functionBody = match.group(4);

      functions[functionName!] = (List<dynamic> args) {
        final paramMap = <String, dynamic>{};
        if (parameterList != null && args.length > 0) {
          final parameters = parameterList.split(',');
          for (int i = 0; i < parameters.length; i++) {
            paramMap[parameters[i].trim()] = args[i];
          }
        }

        final lines = functionBody?.split('\n');
        for (final line in lines!) {
          if (line.trim().isEmpty) continue;

          final printMatch = printRegExp.firstMatch(line);
          if (printMatch != null) {
            final printStatement = printMatch.group(1);

            if (printStatement != null) {
              if (printStatement.startsWith('"') &&
                  printStatement.endsWith('"')) {
                print(printStatement.substring(1, printStatement.length - 1));
              } else {
                final variableName = printStatement.trim();
                final variableValue = variables[variableName];

                if (variableValue != null) {
                  print(variableValue);
                } else {
                  print('Variable $variableName is not defined.');
                }
              }
            }
          }
        }
      };
    }

    return functions;
  }

  dynamic _parseVariableValue(String value, String type) {
    switch (type) {
      case 'String':
        return value.replaceAll('"', '');
      case 'int':
        return int.parse(value);
      case 'double':
        return double.parse(value);
      case 'bool':
        return value.toLowerCase() == 'true';
      case 'List':
        return json.decode(value);
      default:
        throw ArgumentError('Type $type not supported');
    }
  }
}

void main() {
  final parser = Parser();
  final code = '''
    fn printMessage(message: String) {
      print(message);
    }
    
    fn test(): void {
      let message: String = "hello";
    
      printMessage(message);
    }
  ''';

  final functions = parser.parseCode(code);

  functions['test']!([]);
}
