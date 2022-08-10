// I AM NOT DONE

pragma solidity ^0.8.4;
contract Scope {

    uint public count = 10;
    
    function increment(uint numb) public {        

        // Modify state of the count from within 
        // the assembly segment
        assembly {          
            let v := count.slot
            v := add(count.slot, numb)
            sstore(0x0, v)
        }
    }    
}
