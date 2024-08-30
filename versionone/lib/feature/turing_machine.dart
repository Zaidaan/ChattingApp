import 'dart:math';

class TuringMachine {
  late List<String> tape;
  late int head;
  late String keys;

  TuringMachine(String input) {
    tape = List.from(input.split(''));
    head = 0;
  }

  void moveLeft() {
    if (head > 0) {
      head--;
    }
  }

  void moveRight() {
    head++;
    if (head == tape.length) {
      tape.add('_');
    }
  }

  void write(String symbol) {
    tape[head] = symbol;
  }

  String read() {
    return tape[head];
  }

  void writeKeys(int key) {
    keys = keys + key.toString();
  }

  void runEncrypt() {
    var rnd = Random();
    int shift;
    var state = 0;
    while (state != 1) {
      shift = rnd.nextInt(26);
      writeKeys(shift);
      var symbol = read();
      if (state == 0) {
        if (symbol == '_') {
          state = 1;
        } else {
          if (symbol.codeUnitAt(0) >= 97 && symbol.codeUnitAt(0) <= 122) {
            var newChar = String.fromCharCode(
                ((symbol.codeUnitAt(0) - 97 + shift) % 26) + 97);
            write(newChar);
          }
          moveRight();
        }
      } else if (state == 1) {
        break;
      }
    }
  }

  void runDecrypt(int shift) {
    var state = 0;
    while (state != -1) {
      var symbol = read();
      if (state == 0) {
        if (symbol == '_') {
          state = -1;
        } else {
          if (symbol.codeUnitAt(0) >= 97 && symbol.codeUnitAt(0) <= 122) {
            var newChar = String.fromCharCode(
                ((symbol.codeUnitAt(0) - 97 - shift) % 26) + 97);
            write(newChar);
          }
          moveRight();
        }
      } else if (state == -1) {
        break;
      }
    }
  }

  String getTape() {
    return tape.join().replaceAll('_', '');
  }
}
