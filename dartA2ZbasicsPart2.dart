import 'dart:io';

// 1. Person Class (Fixed case-sensitivity and moved showOutput inside the class)
class Person {
  String name;
  int age;
  Person(this.name, [this.age = 18]);

  void showOutput() {
    print(name);
    print(age);
  }
}

// 2. Class X (Fixed constructor name, static syntax, and duplicate variables)
class X {
  final String name;
  static const int age = 10; // Fixed static syntax error

  X(this.name);
}

void displayClass() {
  var myX = X('Jack');
  print(myX.name);
  print(X.age);
  var y = X('jail');
  y = X('jaill');
  print(y.name);
}

void displayClass2() {
  final name = 'Mahamud';
  var age = 30;
  print(name);
  print(age);
}

// 3. Vehicle & Car Classes (Cleaned up the duplicate code and created the Car class used in main)
class Vehicle {
  String model;
  int year;

  Vehicle(this.model, this.year);

  void showOutput() {
    print(model);
    print(year);
  }
}

class Car extends Vehicle {
  int price;

  Car(String model, int year, this.price) : super(model, year);

  @override
  void showOutput() {
    super.showOutput();
    print(price);
  }
}

// 4. Rectangle Class (Fixed missing commas, duplicate parameters, and added missing right getter/setter)
class Rectangle {
  num left, top, width, height;
  Rectangle(this.left, this.top, this.width, this.height);
  num get right => left + width;
  set right(num value) => left = value - width;

  set bottom(num value) => top = value - height;
}

// 5. Main Function (Fixed syntax execution, typos, and structured exception handling)
void main() {
  // Person Test
  Person person1 = Person('Maud', 35);
  person1.showOutput();

  // Car Test
  var car1 = Car('Accord', 2024, 15000);
  car1.showOutput();
  print(car1.price);

  // Rectangle Test
  var rect = Rectangle(3, 4, 20, 15);
  print(rect.left);
  rect.right = 12;
  print(rect.left);

  // Exception Handling Functions (Nested inside main)
  int mustGreaterThanZero(int val) {
    if (val <= 0) {
      throw Exception('Value must be greater than zero');
    }
    return val;
  }

  void leftoverfixTheValue(var val) {
    var valueVerification;
    try {
      valueVerification = mustGreaterThanZero(val);
    } catch (e) {
      print(e);
    } finally {
      if (valueVerification == null) {
        print('value is not acceptable');
      } else {
        print('value verified $valueVerification');
      }
    }
  }

  // Running the exception tests
  print('\n--- Exception Testing ---');
  leftoverfixTheValue(5);
  leftoverfixTheValue(-3);
}
