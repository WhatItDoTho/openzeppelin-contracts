// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import 'contracts/token/ERC20/ERC20.sol';
import './IronControllerInterface.sol';
import './RTokenInterface.sol';
contract LibStrat is Ownable, Initializable {

    IERC20 weth;
    RTokenInterface rWeth;
    IERC20 usdc;
    RTokenInterface rUsdc;
    IronControllerInterface controller;
    uint256 investAmount;
    uint256 divestAmount;
    uint256 borrowAmount;
    
    using SafeMath for uint256;


    /* ========== EVENTS ========== */


    /* ========== Modifiers =============== */


    // run at contract init
    constructor(address _weth, address _rWeth, address _usdc, address _rUsdc, address _controller) public {
        weth = IERC20(_weth);
        rWeth = RTokenInterface(_rWeth);
        usdc = IERC20(_usdc);
        rUsdc = RTokenInterface(_rUsdc);
        controller = IronControllerInterface(_controller);
  
    }


    /* ========== MUTATIVE FUNCTIONS ========== */

    

    /* ========== OWNER FUNCTIONS ========== */

    function invest(uint256 _investAmount) external{
        investAmount = _investAmount;
        weth.approve(address(rWeth), investAmount);
        rWeth.mint(investAmount);
        
    }
    
    function divest(uint256 _divestAmount) external{
        uint balance = rWeth.balanceOf(this);
        rWeth.redeem(balance);
    }
    
    // need to set borrow amount equal to half the usd value of eth, so need to get usdc value of eth!!!!
    function borrow(uint _borrowAmount) external{
        borrowAmount = _borrowAmount;
        investAmount = _investAmount;
        weth.approve(address(rWeth), investAmount);
        rWeth.mint(investAmount);
        
        address[] markets = new address[];
        markets[0] = rWeth;
        controller.enterMarkets([rWeth]);
        
        rUsdc.borrow(_borrowAmount);
    }
    
    // need a better way to approve amount. current just double 
    // the investAmount to make sure it's enough but this is likely
    // way too much and can be based on an apy or something
    function repay() external{
        usdc.approve(address(rUsdc), investAmount*2);
        rUsdc.repayBorrow(borrowAmount);
        
        // Optional to get back collateral
        uint balance = rWeth.balanceOf(this);
        rWeth.redeem(balance);
    }
    
    /* ===========  extras   =========  */

}