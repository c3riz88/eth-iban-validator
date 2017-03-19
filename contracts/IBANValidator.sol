pragma solidity ^0.4.0;

/**
 * IBAN ISO 13616 standard structure that's contains :
 * - Country code using ISO 3166-1 alpha-2 - two letters;
 * - Check digits enable a sanity check of the bank account - two digits;
 * - Basic Bank Account Number (BBAN) up to 30 alphanumeric characters that are country-specific - variables.
 */
contract IBANValidator {
  /**
   * Validating IBAN with check digits
   * See ISO 7064 algorithm specs for more explanations
   *
   * Need a sanitized input args, (no white char).
   * Bad : FR 14 20041 01005 0500013M026 06
   * Good : FR1420041010050500013M02606
   *
   * @param raw IBAN must be checked
   * @return True if IBAN is validated, false otherwise
   */
  function check(bytes raw) constant returns (bool) {
      bytes memory iban;
      bytes memory converted;
      uint i = 0;
      uint j = 0;
      uint offset = 0;
      uint count = 0;

      for(i = 0; i < raw.length; i++) {
        if(isAlpha(raw[i])) {
          count++;
        }
      }

      iban = new bytes(raw.length+count);

      for(i = 0; i < raw.length; i++) {
        if(isAlpha(raw[i])) {
          converted = parseBytes(uint(raw[i])-65+10);

          for(j = 0; j < converted.length; j++) {
            iban[i+j+offset] = converted[j];
          }
          offset++;
        }
        else {
          iban[i+offset] = raw[i];
        }
      }

      iban = lrotate(iban, 6);

      return parseInt(iban) % 97 == 1;
  }


  /**
   * Check if byte is an alpha in ASCII test
   * Only supports for upercases
   *
   * @param char Value that's need a check to alpha
   * @return valid True if an uppercased alpha, false otherwise
   */
  function isAlpha(byte char) internal returns (bool valid) {
    valid = false;
    if(char >= 65 && char <= 90) {
      valid = true;
    }
  }


  /**
   * Convert an integer to a her lot of bytes représentation
   * For example : uint(10) will be converted to bytes(10)
   *
   * @param integer Integer that's need to be converted to string
   * @return mbytes String representation of integer
   */
  function parseBytes(uint integer) internal returns (bytes) {
    bytes memory mbytes;
    uint i = 0;
    uint length = 0;
    uint dummy = integer;

    while(dummy > 0) {
      length++;
      dummy /= 10;
    }

    mbytes = new bytes(length);

    for(i = 0; i < length; i++) {
      mbytes[mbytes.length-1-i] = byte((integer % 10) + 48);
      integer /= 10;
    }

    return mbytes;
  }

  /**
   * Convert a lot of bytes to her integer representation
   * For example : bytes('143') will be converted to uint(143)
   *
   * @param array Lot of bytes that's represents string to be converted
   * @return mint Integer value extracted from byte array
   */
  function parseInt(bytes array) internal returns (uint mint) {
     mint = 0;

     for (uint i = 0; i < array.length; i++) {
      if ((array[i] >= 48) && (array[i] <= 57)) {
        mint *= 10;
        mint += uint(array[i]) - 48;
      }
    }

    return mint;
  }

  /**
   * Apply a left rotation to a byte array
   * For example : 'foo' with two left rotation turn into 'ofo'
   *
   * @param array Array that's need left rotation
   * @param count Number of rotation
   */
  function lrotate(bytes array, uint count) internal constant returns (bytes rotated) {
    byte tmp = 0;
    count %= array.length;
    rotated = array;

    for(uint i = 0; i < count; i++) {
      tmp = array[0];

      for(uint j = 1; j < array.length; j++) {
        rotated[j-1] = rotated[j];
      }
      rotated[rotated.length-1] = tmp;
    }

    return rotated;
  }
}
