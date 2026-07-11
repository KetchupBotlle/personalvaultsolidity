// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PersonalVault {
    address public owner;
    uint256 public unlockTime;

    event Deposit(address indexed sender, uint256 amount);
    event Withdrawal(uint256 amount, uint256 timestamp);
    event LockExtended(uint256 newUnlockTime);

    error FundsLocked();
    error NotOwner();
    error InvalidUnlockTime();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor(uint256 _unlockTime) payable {
        require(_unlockTime > block.timestamp, "Unlock time must be in the future");
        owner = msg.sender;
        unlockTime = _unlockTime;
    }

    function deposit() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() external onlyOwner {
        if (block.timestamp < unlockTime) revert FundsLocked();

        uint256 amount = address(this).balance;
        require(amount > 0, "No balance to withdraw");

        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawal(amount, block.timestamp);
    }

    function extendLock(uint256 newTime) external onlyOwner {
        if (newTime <= unlockTime) revert InvalidUnlockTime();
        unlockTime = newTime;
        emit LockExtended(newTime);
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }
}
