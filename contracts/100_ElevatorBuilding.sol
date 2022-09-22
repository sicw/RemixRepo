// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
interface IElevator {
    function floor() external view returns(uint);
    function goTo(uint _floor) external;
}

contract ElevatorBuilding {

    mapping(uint => uint) public counter;

    function goTo(address _elevatorAddr, uint _floor) external {
        IElevator(_elevatorAddr).goTo(_floor);
    }

    function isLastFloor(uint _floor) external returns (bool) {
        require(_floor > 0,"floor <= 0");
        uint cnt = counter[_floor];
        if(cnt == 0){
            counter[_floor] = cnt + 1;
            return false;
        }
        return true;
    }
}

contract ElevatorBuildingView {

    mapping(uint => uint) public counter;

    function goTo(address _elevatorAddr, uint _floor) external {
        IElevator(_elevatorAddr).goTo(_floor);
    }

    function isLastFloor(uint _floor) external view returns (bool) {
        return _floor == IElevator(msg.sender).floor();
    }
}