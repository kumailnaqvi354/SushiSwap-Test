// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/ISushiswap.sol";
import './interface/IOrderBook.sol';
import "./libraries/Orders.sol";
import "./libraries/EIP721.sol";
contract SwapContract is IOrderBook {
    using Orders for Orders.Order;

    bytes32 public constant ORDER_TYPEHASH = 0x7c228c78bd055996a44b5046fb56fa7c28c66bce92d9dc584f742b2cd76a140f;

    address private constant SUSHISWAP_V2_ROUTER = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    address private constant SUSHISWAP_ORDER_LIMIT = 0x170650434C994897C642e5DC14260bfc2770fd1a;

    address private constant USDT = 0xC2C527C0CACF457746Bd31B2a698Fe89de2b6d49;
    address private constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;

    ISushiswap private router = ISushiswap(SUSHISWAP_V2_ROUTER);
    IOrderBook private order = IOrderBook(SUSHISWAP_ORDER_LIMIT);

    IERC20 private usdt = IERC20(USDT);
    IERC20 private wbtc = IERC20(WBTC);

    receive() external payable {}

   function swapSingleHopExactAmountOut(
        uint amountOutDesired,
        uint amountInMax
    ) external returns (uint amountOut) {
      
        address[] memory path;
        path = new address[](2);
        path[0] = USDT;
        path[1] = WBTC;

        uint[] memory amounts = router.swapExactTokensForTokens(
            amountOutDesired,
            amountInMax,
            path,
            msg.sender,
            block.timestamp
        );

        if (amounts[0] < amountInMax) {
            usdt.transfer(msg.sender, amountInMax - amounts[0]);
        }

        return amounts[1];
    }

     // Creates an order
    function createOrder(Orders.Order memory _order) public {
        require(_order.maker != address(0), "invalid-maker");
        require(_order.fromToken != address(0), "invalid-from-token");
        require(_order.toToken != address(0), "invalid-to-token");
        require(_order.fromToken != _order.toToken, "duplicate-tokens");
        require(_order.amountIn > 0, "invalid-amount-in");
        require(_order.amountOutMin > 0, "invalid-amount-out-min");
        require(_order.recipient != address(0), "invalid-recipient");
        require(_order.deadline > 0, "invalid-deadline");
        bytes32 hash =  keccak256(
                abi.encode(
                    ORDER_TYPEHASH,
                    _order.maker,
                    _order.fromToken,
                    _order.toToken,
                    _order.amountIn,
                    _order.amountOutMin,
                    _order.recipient,
                    _order.deadline
                )
            );
        order.createOrder(_order);
        emit OrderCreated(hash);
    }


}