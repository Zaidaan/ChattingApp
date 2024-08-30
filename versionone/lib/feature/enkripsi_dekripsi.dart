// encryption_decryption.dart
import 'turing_machine.dart';

class Enkripsi_Dekripsi {
  late String keys;
  String enkripsi(String message) {
    var turingMachine = TuringMachine(message.toLowerCase() + '_');
    turingMachine.runEncrypt();
    var resultText = turingMachine.getTape().replaceAll('_', '');
    keys = turingMachine.keys;
    return resultText;
  }

  String dekripsi(String message, var keys) {
    var turingMachine = TuringMachine(message.toLowerCase() + '_');
    turingMachine.runDecrypt(keys);
    var resultText = turingMachine.getTape().replaceAll('_', '');
    return resultText;
  }
}
