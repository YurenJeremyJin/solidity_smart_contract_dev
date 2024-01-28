// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
// @title Solidity 1st Homework
// @author Yuren Jin

contract FirstHomework {
    function binaryToDecimal(string memory binaryString) public pure returns (uint) {
        bytes memory binaryBytes = bytes(binaryString); // Convert string to bytes for iteration
        uint decimal = 0;

        for(uint i = 0; i < binaryBytes.length; i++) {
            // Get current byte
            bytes1 char = binaryBytes[i];

            // Ensure it's either '0' or '1'
            require(char == '0' || char == '1', "Invalid binary string");

            // Convert char to uint and calculate its decimal value
            if (char == '1') {
                decimal += 2**(binaryBytes.length - i - 1);
            }
        }

        return decimal;
    }

    function bitShiftedMask(uint8 number) public pure returns (uint256[] memory) {
        uint256[] memory result = new uint256[](8);
        // Loop through each bit position of the uint8 input
        for (uint8 i = 0; i < 8; i++) {
            uint8 mask = uint8(1) << i; // Create a mask for the current bit
            // Apply mask and shift right to get the bit as 0 or 1
            uint8 bit = (number & mask) >> i;
            // Only add to the resultArray if the bit is set, otherwise leave as 0
            if (bit == 1) {
                result[i] = 2 ** i;
            } else {
                result[i] = 0;
            }
        }

        return result;
    }

}