class Num {
  int num = 10;
}

int notEqual() {
  var n = Num();
  int number220;
  number220 = n.num ?? 0;
  print(number220);
  return 0;
}

void main() {
  notEqual();

  // Null Aware Operator
  int? number16;
  print(number16 ??= 100);
  print(number16);

  // Ternary Operator
  int x11 = 100;
  var result122 = x11 % 2 == 0 ? 'Even' : 'Odd';
  print(result122);

  // Type test
  var x123 = 100;
  if (x123 is int) {
    print('Integer');
  }

  // Conditional Statement
  int number124 = 100;
  if (number124 % 2 == 0) {
    print('Even');
  } else if (number124 % 2 != 0) {
    print('Odd');
  } else {
    print("Confused");
  }

  // Switch Statement
  int number134 = 0;
  switch (number134) { 
    case 0:
      print('Even');
      break;
    case 1: // lowercase 'case'
      print('Odd');
      break;
    default:
      print('Confused');
  }

  // For-in Loop
  var number146 = [1, 2, 3];
  for (var n in number146) { 
    print(n);
  }

  // While loop
  int number148 = 5;
  while (number148 > 0) {
    print(number148);
    number148 -= 1;
  }

  // Break and Continue
  for (var i = 0; i < 10; ++i) {
    if (i > 5) break;
    print(i);
  }

  for (var i = 0; i < 10; ++i) {
    if (i % 2 == 0) continue;
    print("odd: $i"); // Fixed logic/typo
  }
}
