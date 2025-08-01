// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title investreAutoBuy
 * @dev Ultra-lightweight auto-buy contract optimized for <15k gas per transaction
 * 
 * Design Philosophy:
 * - Hard-coded trusted routers for maximum gas efficiency
 * - Users approve routers directly to pull USDC
 * - Backend handles validation, tracking, and swap execution
 * - Standard USDC approval for simple UX
 * - Minimal gas footprint for microtransactions
 */
contract investre is Ownable, Pausable, ReentrancyGuard {

  
    IERC20 public immutable usdc;

    // Hard-coded trusted DEX routers (Base mainnet)
    // address public constant OPENOCEAN_ROUTER = 0x6352a56caadC4F1E25CD6c75970Fa768A3304e64;
    address public constant KYBERSWAP_ROUTER = 0x6131B5fae19EA4f9D964eAc0408E4408b66337b5;

    // Router IDs for gas-efficient function calls
    // uint8 public constant OPENOCEAN_ID = 0;
    uint8 public constant KYBERSWAP_ID = 0;

    // Events - minimal and efficient
    event AutoBuyApproved(address indexed user, uint256 usdcAmount, address indexed router);
    

    constructor(address _usdc, address owner) Ownable(owner) {
        usdc = IERC20(_usdc);
    }

  /**
     * @dev Approve auto-buy for a single user (KyberSwap only)
     * @param user User's wallet address
     * @param usdcAmount Amount of USDC to approve
     */
    function singleAutoBuy(
        address user,
        uint256 usdcAmount
    ) external onlyOwner whenNotPaused nonReentrant {
        require(usdc.allowance(user, KYBERSWAP_ROUTER) >= usdcAmount, "Insufficient USDC allowance for KyberSwap router");
        emit AutoBuyApproved(user, usdcAmount, KYBERSWAP_ROUTER);
    }
    /**
     * @dev Ultra-light auto-buy approval function (hard-coded routers)
     * @param user User's wallet address
     * @param usdcAmount Amount of USDC to approve
  
     */
    function approveAutoBuy(
        address user,
        uint256 usdcAmount
      
    ) external onlyOwner whenNotPaused nonReentrant {

        require(usdc.allowance(user, KYBERSWAP_ROUTER) >= usdcAmount, "Insufficient USDC allowance for router");
        emit AutoBuyApproved(user, usdcAmount, KYBERSWAP_ROUTER);
    }

    /**
     * @dev Batch auto-buy approval for multiple users (KyberSwap only)
     *      Can also be used for a single user by passing arrays of length 1.
     * @param users Array of user addresses
     * @param usdcAmounts Array of USDC amounts
     */
    function batchAutoBuy(
        address[] calldata users,
        uint256[] calldata usdcAmounts
    ) external onlyOwner whenNotPaused nonReentrant {
        require(users.length == usdcAmounts.length && users.length <= 100, "Array length mismatch or too large");
        for (uint256 i = 0; i < users.length; i++) {
            require(usdc.allowance(users[i], KYBERSWAP_ROUTER) >= usdcAmounts[i], "Insufficient USDC allowance for KyberSwap router");
            emit AutoBuyApproved(users[i], usdcAmounts[i], KYBERSWAP_ROUTER);
        }
    }

    /**
     * @dev Emergency pause
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Unpause
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Get router address by ID
     * @param routerId Router ID (0=OpenOcean, 1=KyberSwap)
     * @return Router contract address
     */
    function getRouterAddress(uint8 routerId) external pure returns (address) {
    
         if (routerId == KYBERSWAP_ID) {
            return KYBERSWAP_ROUTER;
        } else {
            revert("Invalid router ID");
        }
    }

    /**
     * @dev Get OpenOcean router address
     * @return OpenOcean router address
     */


    /**
     * @dev Get KyberSwap router address
     * @return KyberSwap router address
     */
    function getKyberSwapRouter() external pure returns (address) {
        return KYBERSWAP_ROUTER;
    }
}