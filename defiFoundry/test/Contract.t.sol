// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Vm.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/DeFi1.sol";
import "../src/Token.sol";

contract User {
    receive() external payable {}
}

contract ContractTest is Test {
    DeFi1 defi;
    Token token;
    User internal alice;
    User internal bob;
    User internal chloe;
    uint256 initialAmount = 1000;
    uint256 blockReward = 5;

    function setUp() public {
        defi = new DeFi1(initialAmount, blockReward);
        token = defi.token();
        alice = new User();
        bob = new User();
        chloe = new User();
    }

    function testInitialBalance() public {
        assert(token.totalSupply() == initialAmount);
    }

    function testAddInvestor() public {
        defi.addInvestor(address(alice));
        assert(defi.investors(0) == address(alice));
    }

    function testClaim() public {
        defi.addInvestor(address(alice));
        defi.addInvestor(address(bob));
        vm.prank(address(alice));
        vm.roll(1);
        defi.claimTokens();
    }


    function testCorrectPayoutAmount() public {
        vm.startPrank(address(alice));
        defi.addInvestor(address(alice));
        vm.roll(100);
        defi.claimTokens();
        uint256 aliceTokens = token.balanceOf(address(alice));
        assert(aliceTokens == 0);
    }

    function testAddingManyInvestors(uint16 investors) public {
        for (uint160 i = 1; i <= investors; i++) {
            defi.addInvestor(address(i));
        }
        assert(defi.getInvestorsCount() == investors);
    }

    function testAddingManyInvestorsAndClaiming(uint8 max) public {
        for (uint160 i = 1; i <= max; i++) {
            address adr = address(i);
            defi.addInvestor(adr);
            vm.roll(i * 2);
            vm.prank(adr);
            defi.claimTokens();
            assert(token.balanceOf(adr) == 0);
        }
        assert(defi.getInvestorsCount() == max);
    }

}
