// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Logic1 {

    Counters.Counter public counter;

    function current() external view returns (uint256) {
        return Counters.current(counter);
    }

    // external test中会检查类型
    function increment() external {
        Counters.increment(counter);
    }
}

contract Logic2 {

    Counters.Counter public counter;

    function current() external view returns (uint256) {
        return Counters.current(counter);
    }

    function increment() external {
        Counters.increment(counter);
    }

    // add decrement and reset function
    function decrement() external {
        Counters.decrement(counter);
    }

    function reset() external {
        Counters.reset(counter);
    }
}

contract Logic3 is UUPSUpgradeable {

    Counters.Counter public counter;

    function current() external view returns (uint256) {
        return Counters.current(counter);
    }

    function increment() external {
        Counters.increment(counter);
    }

    function decrement() external {
        Counters.decrement(counter);
    }

    function _authorizeUpgrade(address newImplementation) internal override virtual{

    }
}

contract Logic4 is UUPSUpgradeable {

    Counters.Counter public counter;

    function current() external view returns (uint256) {
        return Counters.current(counter);
    }

    function increment() external {
        Counters.increment(counter);
    }

    // add decrement and reset function
    function decrement() external {
        Counters.decrement(counter);
    }

    function reset() external {
        Counters.reset(counter);
    }

    function _authorizeUpgrade(address newImplementation) internal override virtual{

    }
}
