// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @title SecurityBreaker
 * @author Amantlane core engineering
 * @notice Enterprise crisis-control infrastructure enforcing time-locked state circuit breakers.
 */
contract SecurityBreaker {

    error SystemIsPaused();
    error SystemNotPaused();
    error UnauthorizedGovernor();
    error TimeLockActive();

    event SystemFreezeAction(address indexed governor, bool status);
    event UpgradeQueued(address indexed targetUpgrade, uint256 executionTimestamp);

    address public securityGovernor;
    bool public isSystemPaused;
    
    address public pendingUpgradeAddress;
    uint256 public upgradeExecutionTime;
    uint256 public constant TIMELOCK_DELAY = 2 days;

    modifier onlyGovernor() {
        if (msg.sender != securityGovernor) revert UnauthorizedGovernor();
        _;
    }

    modifier whenNotPaused() {
        if (isSystemPaused) revert SystemIsPaused();
        _;
    }

    constructor() {
        securityGovernor = msg.sender;
    }

    /**
     * @notice Instantly freezes all primary protocol interaction pathways during network crises.
     */
    function triggerEmergencyPause() external onlyGovernor {
        if (isSystemPaused) revert SystemIsPaused();
        isSystemPaused = true;
        emit SystemFreezeAction(msg.sender, true);
    }

    /**
     * @notice Unfreezes the protocol pathways once threats are completely mitigated.
     */
    function liftEmergencyPause() external onlyGovernor {
        if (!isSystemPaused) revert SystemNotPaused();
        isSystemPaused = false;
        emit SystemFreezeAction(msg.sender, false);
    }

    /**
     * @notice Queues a mission-critical structural protocol address upgrade.
     */
    function queueUpgrade(address _newUpgrade) external onlyGovernor {
        pendingUpgradeAddress = _newUpgrade;
        upgradeExecutionTime = block.timestamp + TIMELOCK_DELAY;
        emit UpgradeQueued(_newUpgrade, upgradeExecutionTime);
    }

    /**
     * @notice Executes a queued upgrade only after the strict 48-hour security delay expires.
     */
    function executeUpgrade() external onlyGovernor {
        if (block.timestamp < upgradeExecutionTime) revert TimeLockActive();
        if (pendingUpgradeAddress == address(0)) revert UnauthorizedGovernor();
        
        securityGovernor = pendingUpgradeAddress;
        pendingUpgradeAddress = address(0);
        upgradeExecutionTime = 0;
    }
}
