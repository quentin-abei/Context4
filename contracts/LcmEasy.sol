// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract LCM {

    function greatestCommonDiv(uint a , uint b) internal pure returns (uint) {
        while(b != 0) {
            a %=b;
            (a, b) = (b, a);
        }
        return a;
    }

    //this function calculates the LCM
    function lcm(uint a, uint b) public pure returns (uint) {
        if(a == 0 || b == 0) {
            revert();
        }
        return (a/ greatestCommonDiv(a,b)) * b;
    }

}