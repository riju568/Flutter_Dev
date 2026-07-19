// https://docs.flutter.dev/install/custom --> SDK with code editor and IDE
// https://youtu.be/Ej_Pcr4uC2Q --> complete tutorial

import 'dart:io';

void main() {

  print("Hello World");
  var firstName = 'Mahmud';
  String lastName = 'A';

  print(firstName + ' ' + lastName);
  print(firstName + ' ' + lastName); 

  stdout.writeln("What is your name?");

  int amount1 = 100;
  int amount2 = 200;
  print('amount1: $amount1 | Amount2: $amount2');

  double dAmount1 = 100.11; 
  var dAmount2 = 200.22;
  print('dAmount1: $dAmount1, dAmount2: $dAmount2');
  String name1 = 'Mahmid';
  var name22 = 'Ahsan'; // Fixed: Typo 'mane22' -> 'name22'
  print('Names: $name1, $name22');
  dynamic weakVariable = 100;
  print('weakVariable: $weakVariable\n');
  weakVariable = 'Dart programming';
  weakVariable = null;
  print('weakVariable: $weakVariable');

  var s1 = ' Single quotes work well';
  var s2 = " Double quotes work well";
  var s3 = "Hi it's working";
  print(s1);
  print(s2);
  print(s3);
  var s23 = r'In a raw string, not even \n gets special treatment';
  print(s23);

  var v1 = '''This is a multi-line string''';
  var v2 = '''This is also a multi-line string''';
  print(v1);
  print(v2);

  // String -> int
  var one = int.parse('1');
  assert(one == 1);

  // String -> double
  var onePointOne = double.parse('1.1');
  assert(onePointOne == 1.1);

  // int -> String
  String oneAsString = 1.toString();
  print('oneAsString: $oneAsString');

  // double -> String
  String piAsString = 3.14159.toStringAsFixed(2);
  assert(piAsString == '3.14');

  // const keyword
  const aConstNum = 0; // int constant
  const aConstBool = true; // bool constant
  const aConstString = 'a contract';
  print(aConstNum);
  print(aConstBool);
  print(aConstString);
  // Use .runtimeType instead of .runtime
  print(aConstNum.runtimeType);
  print(aConstBool.runtimeType);
  print(aConstString.runtimeType);
  int num12 = 0;
  print(num12);

  int num13 = 10 + 22;
  print(num13);

  // Relational operators
  if (num13 == 100) {
    print("num13 is 100");
  }

  num13 *= 2; // num13 = num13 * 2;
  print(num13);

  // Unary Operator
  ++num13;
  num13++;
  print(num13);
  num13++;
  num13 += 1;
  num13 -= 1;
  print(num13);
    //logical && logical || // and or
  if(num14>200 && num<203){
    print('200 to 203');
    //!= Not Equal
    if(num15 != 100){
      PRINT('Num is not equal to 100');
    }
  }
  

}
// != not Equal
if num16!= 100{
  print('num is not equal to 100');
}
