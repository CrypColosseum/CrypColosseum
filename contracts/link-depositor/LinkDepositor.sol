pragma solidity ^0.4.24;

import "@aragon/apps-vault/contracts/Vault.sol";
import "@aragon/os/contracts/lib/token/ERC20.sol";
import "./IUniswapV2Router02.sol";
import "./UniswapV2Library.sol"; // Copied from Polygon deployment for correct deployment hex hash

// This contract must have permission move funds in the Vault contract
contract LinkDepositor {

    uint256 public constant DEADLINE_DELAY_SECONDS = 1000;
    uint256 public constant MAX_VALUE = uint256(-1);

    Vault public vault;
    IUniswapV2Router02 public uniswapRouter;
    address public uniswapFactory;
    ERC20 public wethToken;
    ERC20 public chainlinkToken;
    uint256 public paymentAmount;
    uint256 public paymentFrequencySeconds;
    address public paymentAccount;
    uint256 public previousDepositTime;

    event LinkDeposited(uint256 wethPaid);

    constructor(
        Vault _vault,
        IUniswapV2Router02 _uniswapRouter,
        address _uniswapFactory,
        ERC20 _wethToken,
        ERC20 _chainlinkToken,
        uint256 _paymentAmount,
        uint256 _paymentFrequencySeconds,
        address _paymentAccount
    ) {
        vault = _vault;
        uniswapRouter = _uniswapRouter;
        uniswapFactory = _uniswapFactory;
        wethToken = _wethToken;
        chainlinkToken = _chainlinkToken;
        paymentAmount = _paymentAmount;
        paymentFrequencySeconds = _paymentFrequencySeconds;
        paymentAccount = _paymentAccount;

        wethToken.approve(address(uniswapRouter), MAX_VALUE);
    }

    function tradeAndDepositLink() public {
        uint256 nextDepositFromTime = previousDepositTime + paymentFrequencySeconds;
        require(now >= nextDepositFromTime, "ERR:DepositTooSoon");
        previousDepositTime = nextDepositFromTime;

        address[] memory path = new address[](2);
        path[0] = address(wethToken);
        path[1] = address(chainlinkToken);

        uint256 deadline = block.timestamp + DEADLINE_DELAY_SECONDS;

        uint256[] memory amountsIn = UniswapV2Library.getAmountsIn(uniswapFactory, paymentAmount, path);
        vault.transfer(address(wethToken), address(this), amountsIn[0]);

        uint256[] memory amounts = uniswapRouter.swapTokensForExactTokens(
            paymentAmount, // Exact amount out
            MAX_VALUE, // Max input weth
            path,
            paymentAccount,
            deadline
        );

        emit LinkDeposited(amounts[0]);
    }
}





