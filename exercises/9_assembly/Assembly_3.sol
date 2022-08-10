// I AM NOT DONE

pragma solidity ^0.8.4;
contract SubOverflow {

    // Modify this function so on overflow it sets value to 0
    function subtract(uint x, uint y) public pure returns (uint) {        

        // Write assembly code that handles overflows        
        assembly {
            let result := 0
            if gt(x, y) {
                result := sub(x, y)
            }
            mstore(0x0, result)
            return(0x0, 32)
        }
    }    
}
