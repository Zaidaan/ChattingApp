import 'dart:typed_data';

class SHA3 {
  static const int _blockSize = 136;
  static const List<int> _roundConstants = [
    0x0000000000000001,
    0x0000000000008082,
    0x800000000000808a,
    0x8000000080008000,
    0x000000000000808b,
    0x0000000080000001,
    0x8000000080008081,
    0x8000000000008009,
    0x000000000000008a,
    0x0000000000000088,
    0x0000000080008009,
    0x000000008000000a,
    0x000000008000808b,
    0x800000000000008b,
    0x8000000000008089,
    0x8000000000008003,
    0x8000000000008002,
    0x8000000000000080,
    0x000000000000800a,
    0x800000008000000a,
    0x8000000080008081,
    0x8000000000008080,
    0x0000000080000001,
    0x8000000080008008
  ];
  static const List<int> _rotationOffsets = [
    0,
    36,
    3,
    41,
    18,
    1,
    44,
    10,
    45,
    2,
    62,
    6,
    43,
    15,
    61,
    28,
    55,
    25,
    21,
    56,
    27,
    20,
    39,
    8,
    14
  ];

  static List<int> _keccakF(List<int> state) {
    final List<int> output = List<int>.filled(state.length, 0);
    final List<int> lanes = List<int>.filled(25, 0);

    for (var round = 0; round < 24; round++) {
      _theta(state, lanes);
      _rho(state, lanes);
      _pi(state, lanes);
      _chi(state, lanes);
      _iota(state, round);
    }

    return state;
  }

  static void _theta(List<int> state, List<int> lanes) {
    for (var i = 0; i < 5; i++) {
      lanes[i] = state[i] ^
          state[i + 5] ^
          state[i + 10] ^
          state[i + 15] ^
          state[i + 20];
    }

    for (var i = 0; i < 5; i++) {
      final T = lanes[(i + 4) % 5] ^ _rotateLeft(lanes[(i + 1) % 5], 1);
      for (var j = 0; j < 25; j += 5) {
        state[j + i] ^= T;
      }
    }
  }

  static void _rho(List<int> state, List<int> lanes) {
    for (var i = 0; i < 25; i++) {
      lanes[i] = _rotateLeft(state[i], _rotationOffsets[i]);
    }
  }

  static void _pi(List<int> state, List<int> lanes) {
    for (var i = 0; i < 25; i++) {
      state[i] = lanes[_piMapping[i]];
    }
  }

  static void _chi(List<int> state, List<int> lanes) {
    for (var i = 0; i < 25; i += 5) {
      for (var j = 0; j < 5; j++) {
        lanes[i + j] =
            state[i + j] ^ ((state[i + j + 1] ^ 1) & state[i + j + 2]);
      }
    }
  }

  static void _iota(List<int> state, int round) {
    state[0] ^= _roundConstants[round];
  }

  static List<int> _pad(Uint8List message) {
    final blockSize = _blockSize ~/ 8;
    final messageLength = message.length;
    final remainder = messageLength % blockSize;
    final padLength = remainder == 0 ? blockSize : blockSize - remainder;
    final padded = Uint8List(messageLength + padLength);
    padded.setRange(0, messageLength, message);

    // padding
    padded[messageLength] = 0x06; // append 0110 0000
    padded[padded.length - 1] |= 0x80; // append 1000 0000
    return padded;
  }

  static List<int> _digest(String message) {
    final paddedMessage = _pad(Uint8List.fromList(message.codeUnits));
    final state = List<int>.filled(200, 0);

    for (var offset = 0; offset < paddedMessage.length; offset += 136) {
      final blockEnd = offset + 136 <= paddedMessage.length
          ? offset + 136
          : paddedMessage.length;
      final block = paddedMessage.sublist(offset, blockEnd);

      for (var i = 0; i < block.length; i++) {
        state[i] ^= block[i]; // Use 'i' directly, not 'i ~/ 8'
      }

      _keccakF(state);
    }

    return state.sublist(0, 32);
  }

  static String hash(String message) {
    final digest = _digest(message);
    final hash =
        digest.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
    return hash;
  }

  static int _rotateLeft(int x, int n) {
    return ((x << n) | (x >> (64 - n))) & 0xFFFFFFFFFFFFFFFF;
  }

  static const List<int> _piMapping = [
    0,
    6,
    12,
    18,
    24,
    3,
    9,
    10,
    16,
    22,
    1,
    7,
    13,
    19,
    20,
    4,
    5,
    11,
    17,
    23,
    2,
    8,
    14,
    15,
    21
  ];
}
