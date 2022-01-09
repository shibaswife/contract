// SPDX-License-Identifier: Unlicensed

/**

   #Fixes

   3% auto add to the liquidity pool
   2% to token growth wallet
   10% to cause wallet

   // Preliminary audit changes:
   SCP-01 - Will be addressed through contract renouncement
   SCP-02 - Addressed
   SCP-03 - Will be addressed through contract renouncement
   SCP-04 - Addressed
   SCP-05 - Addressed (removed)
   SCP-06 - Addressed
   SCP-07 - Addressed
   SCP-08 - Addressed (transfer leftover BNB to cause wallet)
   SCP-09 - Not addressed (informational impact)
   SCP-10 - Will be addressed through contract renouncement
   SCP-11 - Not addressed (informational)

   Additional changes:
    1. taxFee related removed as not needed
    2. _tFeeTotal removed as not used
    3. removeAllFee() modified to reflect taxFee removal and to check for 3 fees
    
   Changes after deployment:
    1. uniswapPair to be excluded from reward after deployment
 */

   pragma solidity ^0.8.3;

   /**
    * @dev Interface of the ERC20 standard as defined in the EIP.
    */
   interface IERC20 {
       /**
        * @dev Returns the amount of tokens in existence.
        */
       function totalSupply() external view returns (uint256);
   
       /**
        * @dev Returns the amount of tokens owned by `account`.
        */
       function balanceOf(address account) external view returns (uint256);
   
       /**
        * @dev Moves `amount` tokens from the caller's account to `recipient`.
        *
        * Returns a boolean value indicating whether the operation succeeded.
        *
        * Emits a {Transfer} event.
        */
       function transfer(address recipient, uint256 amount) external returns (bool);
   
       /**
        * @dev Returns the remaining number of tokens that `spender` will be
        * allowed to spend on behalf of `owner` through {transferFrom}. This is
        * zero by default.
        *
        * This value changes when {approve} or {transferFrom} are called.
        */
       function allowance(address owner, address spender) external view returns (uint256);
   
       /**
        * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
        *
        * Returns a boolean value indicating whether the operation succeeded.
        *
        * IMPORTANT: Beware that changing an allowance with this method brings the risk
        * that someone may use both the old and the new allowance by unfortunate
        * transaction ordering. One possible solution to mitigate this race
        * condition is to first reduce the spender's allowance to 0 and set the
        * desired value afterwards:
        * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        *
        * Emits an {Approval} event.
        */
       function approve(address spender, uint256 amount) external returns (bool);
   
       /**
        * @dev Moves `amount` tokens from `sender` to `recipient` using the
        * allowance mechanism. `amount` is then deducted from the caller's
        * allowance.
        *
        * Returns a boolean value indicating whether the operation succeeded.
        *
        * Emits a {Transfer} event.
        */
       function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
   
       /**
        * @dev Emitted when `value` tokens are moved from one account (`from`) to
        * another (`to`).
        *
        * Note that `value` may be zero.
        */
       event Transfer(address indexed from, address indexed to, uint256 value);
   
       /**
        * @dev Emitted when the allowance of a `spender` for an `owner` is set by
        * a call to {approve}. `value` is the new allowance.
        */
       event Approval(address indexed owner, address indexed spender, uint256 value);
   }
   
   // CAUTION
   // This version of SafeMath should only be used with Solidity 0.8 or later,
   // because it relies on the compiler's built in overflow checks.
   
   /**
    * @dev Wrappers over Solidity's arithmetic operations.
    *
    * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
    * now has built in overflow checking.
    */
   library SafeMath {
       /**
        * @dev Returns the addition of two unsigned integers, with an overflow flag.
        *
        * _Available since v3.4._
        */
       function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
           unchecked {
               uint256 c = a + b;
               if (c < a) return (false, 0);
               return (true, c);
           }
       }
   
       /**
        * @dev Returns the substraction of two unsigned integers, with an overflow flag.
        *
        * _Available since v3.4._
        */
       function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
           unchecked {
               if (b > a) return (false, 0);
               return (true, a - b);
           }
       }
   
       /**
        * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
        *
        * _Available since v3.4._
        */
       function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
           unchecked {
               // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
               // benefit is lost if 'b' is also tested.
               // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
               if (a == 0) return (true, 0);
               uint256 c = a * b;
               if (c / a != b) return (false, 0);
               return (true, c);
           }
       }
   
       /**
        * @dev Returns the division of two unsigned integers, with a division by zero flag.
        *
        * _Available since v3.4._
        */
       function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
           unchecked {
               if (b == 0) return (false, 0);
               return (true, a / b);
           }
       }
   
       /**
        * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
        *
        * _Available since v3.4._
        */
       function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
           unchecked {
               if (b == 0) return (false, 0);
               return (true, a % b);
           }
       }
   
       /**
        * @dev Returns the addition of two unsigned integers, reverting on
        * overflow.
        *
        * Counterpart to Solidity's `+` operator.
        *
        * Requirements:
        *
        * - Addition cannot overflow.
        */
       function add(uint256 a, uint256 b) internal pure returns (uint256) {
           return a + b;
       }
   
       /**
        * @dev Returns the subtraction of two unsigned integers, reverting on
        * overflow (when the result is negative).
        *
        * Counterpart to Solidity's `-` operator.
        *
        * Requirements:
        *
        * - Subtraction cannot overflow.
        */
       function sub(uint256 a, uint256 b) internal pure returns (uint256) {
           return a - b;
       }
   
       /**
        * @dev Returns the multiplication of two unsigned integers, reverting on
        * overflow.
        *
        * Counterpart to Solidity's `*` operator.
        *
        * Requirements:
        *
        * - Multiplication cannot overflow.
        */
       function mul(uint256 a, uint256 b) internal pure returns (uint256) {
           return a * b;
       }
   
       /**
        * @dev Returns the integer division of two unsigned integers, reverting on
        * division by zero. The result is rounded towards zero.
        *
        * Counterpart to Solidity's `/` operator.
        *
        * Requirements:
        *
        * - The divisor cannot be zero.
        */
       function div(uint256 a, uint256 b) internal pure returns (uint256) {
           return a / b;
       }
   
       /**
        * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
        * reverting when dividing by zero.
        *
        * Counterpart to Solidity's `%` operator. This function uses a `revert`
        * opcode (which leaves remaining gas untouched) while Solidity uses an
        * invalid opcode to revert (consuming all remaining gas).
        *
        * Requirements:
        *
        * - The divisor cannot be zero.
        */
       function mod(uint256 a, uint256 b) internal pure returns (uint256) {
           return a % b;
       }
   
       /**
        * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
        * overflow (when the result is negative).
        *
        * CAUTION: This function is deprecated because it requires allocating memory for the error
        * message unnecessarily. For custom revert reasons use {trySub}.
        *
        * Counterpart to Solidity's `-` operator.
        *
        * Requirements:
        *
        * - Subtraction cannot overflow.
        */
       function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
           unchecked {
               require(b <= a, errorMessage);
               return a - b;
           }
       }
   
       /**
        * @dev Returns the integer division of two unsigned integers, reverting with custom message on
        * division by zero. The result is rounded towards zero.
        *
        * Counterpart to Solidity's `%` operator. This function uses a `revert`
        * opcode (which leaves remaining gas untouched) while Solidity uses an
        * invalid opcode to revert (consuming all remaining gas).
        *
        * Counterpart to Solidity's `/` operator. Note: this function uses a
        * `revert` opcode (which leaves remaining gas untouched) while Solidity
        * uses an invalid opcode to revert (consuming all remaining gas).
        *
        * Requirements:
        *
        * - The divisor cannot be zero.
        */
       function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
           unchecked {
               require(b > 0, errorMessage);
               return a / b;
           }
       }
   
       /**
        * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
        * reverting with custom message when dividing by zero.
        *
        * CAUTION: This function is deprecated because it requires allocating memory for the error
        * message unnecessarily. For custom revert reasons use {tryMod}.
        *
        * Counterpart to Solidity's `%` operator. This function uses a `revert`
        * opcode (which leaves remaining gas untouched) while Solidity uses an
        * invalid opcode to revert (consuming all remaining gas).
        *
        * Requirements:
        *
        * - The divisor cannot be zero.
        */
       function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
           unchecked {
               require(b > 0, errorMessage);
               return a % b;
           }
       }
   }
   
   /*
    * @dev Provides information about the current execution context, including the
    * sender of the transaction and its data. While these are generally available
    * via msg.sender and msg.data, they should not be accessed in such a direct
    * manner, since when dealing with meta-transactions the account sending and
    * paying for execution may not be the actual sender (as far as an application
    * is concerned).
    *
    * This contract is only required for intermediate, library-like contracts.
    */
   abstract contract Context {
       function _msgSender() internal view virtual returns (address) {
           return msg.sender;
       }
   
       function _msgData() internal view virtual returns (bytes calldata) {
           this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
           return msg.data;
       }
   }
   
   /**
    * @dev Collection of functions related to the address type
    */
   library Address {
       /**
        * @dev Returns true if `account` is a contract.
        *
        * [IMPORTANT]
        * ====
        * It is unsafe to assume that an address for which this function returns
        * false is an externally-owned account (EOA) and not a contract.
        *
        * Among others, `isContract` will return false for the following
        * types of addresses:
        *
        *  - an externally-owned account
        *  - a contract in construction
        *  - an address where a contract will be created
        *  - an address where a contract lived, but was destroyed
        * ====
        */
       function isContract(address account) internal view returns (bool) {
           // This method relies on extcodesize, which returns 0 for contracts in
           // construction, since the code is only stored at the end of the
           // constructor execution.
   
           uint256 size;
           // solhint-disable-next-line no-inline-assembly
           assembly { size := extcodesize(account) }
           return size > 0;
       }
   
       /**
        * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
        * `recipient`, forwarding all available gas and reverting on errors.
        *
        * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
        * of certain opcodes, possibly making contracts go over the 2300 gas limit
        * imposed by `transfer`, making them unable to receive funds via
        * `transfer`. {sendValue} removes this limitation.
        *
        * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
        *
        * IMPORTANT: because control is transferred to `recipient`, care must be
        * taken to not create reentrancy vulnerabilities. Consider using
        * {ReentrancyGuard} or the
        * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
        */
       function sendValue(address payable recipient, uint256 amount) internal {
           require(address(this).balance >= amount, "Address: insufficient balance");
   
           // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
           (bool success, ) = recipient.call{ value: amount }("");
           require(success, "Address: unable to send value, recipient may have reverted");
       }
   
       /**
        * @dev Performs a Solidity function call using a low level `call`. A
        * plain`call` is an unsafe replacement for a function call: use this
        * function instead.
        *
        * If `target` reverts with a revert reason, it is bubbled up by this
        * function (like regular Solidity function calls).
        *
        * Returns the raw returned data. To convert to the expected return value,
        * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
        *
        * Requirements:
        *
        * - `target` must be a contract.
        * - calling `target` with `data` must not revert.
        *
        * _Available since v3.1._
        */
       function functionCall(address target, bytes memory data) internal returns (bytes memory) {
         return functionCall(target, data, "Address: low-level call failed");
       }
   
       /**
        * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
        * `errorMessage` as a fallback revert reason when `target` reverts.
        *
        * _Available since v3.1._
        */
       function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
           return functionCallWithValue(target, data, 0, errorMessage);
       }
   
       /**
        * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
        * but also transferring `value` wei to `target`.
        *
        * Requirements:
        *
        * - the calling contract must have an ETH balance of at least `value`.
        * - the called Solidity function must be `payable`.
        *
        * _Available since v3.1._
        */
       function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
           return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
       }
   
       /**
        * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
        * with `errorMessage` as a fallback revert reason when `target` reverts.
        *
        * _Available since v3.1._
        */
       function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
           require(address(this).balance >= value, "Address: insufficient balance for call");
           require(isContract(target), "Address: call to non-contract");
   
           // solhint-disable-next-line avoid-low-level-calls
           (bool success, bytes memory returndata) = target.call{ value: value }(data);
           return _verifyCallResult(success, returndata, errorMessage);
       }
   
       /**
        * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
        * but performing a static call.
        *
        * _Available since v3.3._
        */
       function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
           return functionStaticCall(target, data, "Address: low-level static call failed");
       }
   
       /**
        * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
        * but performing a static call.
        *
        * _Available since v3.3._
        */
       function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
           require(isContract(target), "Address: static call to non-contract");
   
           // solhint-disable-next-line avoid-low-level-calls
           (bool success, bytes memory returndata) = target.staticcall(data);
           return _verifyCallResult(success, returndata, errorMessage);
       }
   
       /**
        * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
        * but performing a delegate call.
        *
        * _Available since v3.4._
        */
       function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
           return functionDelegateCall(target, data, "Address: low-level delegate call failed");
       }
   
       /**
        * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
        * but performing a delegate call.
        *
        * _Available since v3.4._
        */
       function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
           require(isContract(target), "Address: delegate call to non-contract");
   
           // solhint-disable-next-line avoid-low-level-calls
           (bool success, bytes memory returndata) = target.delegatecall(data);
           return _verifyCallResult(success, returndata, errorMessage);
       }
   
       function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
           if (success) {
               return returndata;
           } else {
               // Look for revert reason and bubble it up if present
               if (returndata.length > 0) {
                   // The easiest way to bubble the revert reason is using memory via assembly
   
                   // solhint-disable-next-line no-inline-assembly
                   assembly {
                       let returndata_size := mload(returndata)
                       revert(add(32, returndata), returndata_size)
                   }
               } else {
                   revert(errorMessage);
               }
           }
       }
   }
   
   /**
    * @dev Contract module which provides a basic access control mechanism, where
    * there is an account (an owner) that can be granted exclusive access to
    * specific functions.
    *
    * By default, the owner account will be the one that deploys the contract. This
    * can later be changed with {transferOwnership}.
    *
    * This module is used through inheritance. It will make available the modifier
    * `onlyOwner`, which can be applied to your functions to restrict their use to
    * the owner.
    */
   abstract contract Ownable is Context {
       address private _owner;
   
       event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
   
       /**
        * @dev Initializes the contract setting the deployer as the initial owner.
        */
       constructor () {
           _owner = 0x19A0651C42982dB4B66aC93DF4DeC95E9Dce6935;
           emit OwnershipTransferred(address(0), _owner);
       }
   
       /**
        * @dev Returns the address of the current owner.
        */
       function owner() public view virtual returns (address) {
           return _owner;
       }
   
       /**
        * @dev Throws if called by any account other than the owner.
        */
       modifier onlyOwner() {
           require(owner() == _msgSender(), "Ownable: caller is not the owner");
           _;
       }
   
       /**
        * @dev Leaves the contract without owner. It will not be possible to call
        * `onlyOwner` functions anymore. Can only be called by the current owner.
        *
        * NOTE: Renouncing ownership will leave the contract without an owner,
        * thereby removing any functionality that is only available to the owner.
        */
       function renounceOwnership() public virtual onlyOwner {
           emit OwnershipTransferred(_owner, address(0));
           _owner = address(0);
       }
   
       /**
        * @dev Transfers ownership of the contract to a new account (`newOwner`).
        * Can only be called by the current owner.
        */
       function transferOwnership(address newOwner) public virtual onlyOwner {
           require(newOwner != address(0), "Ownable: new owner is the zero address");
           emit OwnershipTransferred(_owner, newOwner);
           _owner = newOwner;
       }
   }
   
   interface IUniswapV2Factory {
       event PairCreated(address indexed token0, address indexed token1, address pair, uint);
   
       function feeTo() external view returns (address);
       function feeToSetter() external view returns (address);
   
       function getPair(address tokenA, address tokenB) external view returns (address pair);
       function allPairs(uint) external view returns (address pair);
       function allPairsLength() external view returns (uint);
   
       function createPair(address tokenA, address tokenB) external returns (address pair);
   
       function setFeeTo(address) external;
       function setFeeToSetter(address) external;
   }
   
   interface IUniswapV2Pair {
       event Approval(address indexed owner, address indexed spender, uint value);
       event Transfer(address indexed from, address indexed to, uint value);
   
       function name() external pure returns (string memory);
       function symbol() external pure returns (string memory);
       function decimals() external pure returns (uint8);
       function totalSupply() external view returns (uint);
       function balanceOf(address owner) external view returns (uint);
       function allowance(address owner, address spender) external view returns (uint);
   
       function approve(address spender, uint value) external returns (bool);
       function transfer(address to, uint value) external returns (bool);
       function transferFrom(address from, address to, uint value) external returns (bool);
   
       function DOMAIN_SEPARATOR() external view returns (bytes32);
       function PERMIT_TYPEHASH() external pure returns (bytes32);
       function nonces(address owner) external view returns (uint);
   
       function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
   
       event Mint(address indexed sender, uint amount0, uint amount1);
       event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
       event Swap(
           address indexed sender,
           uint amount0In,
           uint amount1In,
           uint amount0Out,
           uint amount1Out,
           address indexed to
       );
       event Sync(uint112 reserve0, uint112 reserve1);
   
       function MINIMUM_LIQUIDITY() external pure returns (uint);
       function factory() external view returns (address);
       function token0() external view returns (address);
       function token1() external view returns (address);
       function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
       function price0CumulativeLast() external view returns (uint);
       function price1CumulativeLast() external view returns (uint);
       function kLast() external view returns (uint);
   
       function mint(address to) external returns (uint liquidity);
       function burn(address to) external returns (uint amount0, uint amount1);
       function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
       function skim(address to) external;
       function sync() external;
   
       function initialize(address, address) external;
   }
   
   interface IUniswapV2Router01 {
       function factory() external pure returns (address);
       function WETH() external pure returns (address);
   
       function addLiquidity(
           address tokenA,
           address tokenB,
           uint amountADesired,
           uint amountBDesired,
           uint amountAMin,
           uint amountBMin,
           address to,
           uint deadline
       ) external returns (uint amountA, uint amountB, uint liquidity);
       function addLiquidityETH(
           address token,
           uint amountTokenDesired,
           uint amountTokenMin,
           uint amountETHMin,
           address to,
           uint deadline
       ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
       function removeLiquidity(
           address tokenA,
           address tokenB,
           uint liquidity,
           uint amountAMin,
           uint amountBMin,
           address to,
           uint deadline
       ) external returns (uint amountA, uint amountB);
       function removeLiquidityETH(
           address token,
           uint liquidity,
           uint amountTokenMin,
           uint amountETHMin,
           address to,
           uint deadline
       ) external returns (uint amountToken, uint amountETH);
       function removeLiquidityWithPermit(
           address tokenA,
           address tokenB,
           uint liquidity,
           uint amountAMin,
           uint amountBMin,
           address to,
           uint deadline,
           bool approveMax, uint8 v, bytes32 r, bytes32 s
       ) external returns (uint amountA, uint amountB);
       function removeLiquidityETHWithPermit(
           address token,
           uint liquidity,
           uint amountTokenMin,
           uint amountETHMin,
           address to,
           uint deadline,
           bool approveMax, uint8 v, bytes32 r, bytes32 s
       ) external returns (uint amountToken, uint amountETH);
       function swapExactTokensForTokens(
           uint amountIn,
           uint amountOutMin,
           address[] calldata path,
           address to,
           uint deadline
       ) external returns (uint[] memory amounts);
       function swapTokensForExactTokens(
           uint amountOut,
           uint amountInMax,
           address[] calldata path,
           address to,
           uint deadline
       ) external returns (uint[] memory amounts);
       function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
           external
           payable
           returns (uint[] memory amounts);
       function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
           external
           returns (uint[] memory amounts);
       function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
           external
           returns (uint[] memory amounts);
       function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
           external
           payable
           returns (uint[] memory amounts);
   
       function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
       function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
       function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
       function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
       function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
   }
   
   interface IUniswapV2Router02 is IUniswapV2Router01 {
       function removeLiquidityETHSupportingFeeOnTransferTokens(
           address token,
           uint liquidity,
           uint amountTokenMin,
           uint amountETHMin,
           address to,
           uint deadline
       ) external returns (uint amountETH);
       function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
           address token,
           uint liquidity,
           uint amountTokenMin,
           uint amountETHMin,
           address to,
           uint deadline,
           bool approveMax, uint8 v, bytes32 r, bytes32 s
       ) external returns (uint amountETH);
   
       function swapExactTokensForTokensSupportingFeeOnTransferTokens(
           uint amountIn,
           uint amountOutMin,
           address[] calldata path,
           address to,
           uint deadline
       ) external;
       function swapExactETHForTokensSupportingFeeOnTransferTokens(
           uint amountOutMin,
           address[] calldata path,
           address to,
           uint deadline
       ) external payable;
       function swapExactTokensForETHSupportingFeeOnTransferTokens(
           uint amountIn,
           uint amountOutMin,
           address[] calldata path,
           address to,
           uint deadline
       ) external;
   }
   
   contract Fixes is Context, IERC20, Ownable {
       using SafeMath for uint256;
       using Address for address;
   
       mapping (address => uint256) private _rOwned;
       mapping (address => uint256) private _tOwned;
       mapping (address => mapping (address => uint256)) private _allowances;
   
       mapping (address => bool) private _isExcludedFromFee;
       mapping (address => bool) private _isExcludedFromMaxTaxLimit;
   
       mapping (address => bool) private _isExcluded;
       address[] private _excluded;
   
       address private _causeWalletAddress = 0xfF63a768C79e1BA1Eb9B61165846bbCf5A927b38;
       address private _growthWalletAddress = 0x480c3183b32442E25782f944716b49c7C59aDc0c;
       uint256 public leftOverBalanceAfterSwap;
      
       uint256 private constant MAX = ~uint256(0);
       uint256 private constant _tTotal = 394796000000 * 10**9;
       uint256 private _rTotal = (MAX - (MAX % _tTotal));
   
       string private _name = "Fixes";
       string private _symbol = "Fixes";
       uint8 private constant _decimals = 18;
   
       uint256 public _growthFee = 2;
       uint256 private _previousGrowthFee = _growthFee;
   
       uint256 public _liquidityFee = 3;
       uint256 private _previousLiquidityFee = _liquidityFee;
   
       uint256 public _causeFee = 10;
       uint256 private _previousCauseFee = _causeFee;
   
       IUniswapV2Router02 public immutable uniswapV2Router;
       address public immutable uniswapV2Pair;
       
       bool inSwapAndLiquify;
       bool public swapAndLiquifyEnabled = true;
       
       uint256 public _maxTxAmount = 1973980000 * 10**9;
       uint256 private constant numTokensSellToAddToLiquidity = 197398000 * 10**9;
       
       event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
       event SwapAndLiquifyEnabledUpdated(bool enabled);
       event SwapAndLiquify(
           uint256 tokensSwapped,
           uint256 ethReceived,
           uint256 tokensIntoLiquidity
       );
       
       modifier lockTheSwap {
           inSwapAndLiquify = true;
           _;
           inSwapAndLiquify = false;
       }
       
       constructor () {
           _rOwned[owner()] = _rTotal;
           
           IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
            // Create a uniswap pair for this new token
           uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
               .createPair(address(this), _uniswapV2Router.WETH());
   
           // set the rest of the contract variables
           uniswapV2Router = _uniswapV2Router;
           
           //exclude owner and this contract from fee
           _isExcludedFromFee[owner()] = true;
           _isExcludedFromFee[address(this)] = true;
           
           emit Transfer(address(0), owner(), _tTotal);
       }
   
       function name() public view returns (string memory) {
           return _name;
       }
   
       function symbol() public view returns (string memory) {
           return _symbol;
       }
   
       function decimals() public view returns (uint8) {
           return _decimals;
       }
   
       function totalSupply() public view override returns (uint256) {
           return _tTotal;
       }
   
       function balanceOf(address account) public view override returns (uint256) {
           if (_isExcluded[account]) return _tOwned[account];
           return tokenFromReflection(_rOwned[account]);
       }

    function withdrawLockedBNB(address payable recipient) external{
        require(recipient != address(0), "Cannot withdraw the leftover BNB balance to the zero address");
        require(recipient == _causeWalletAddress, "Cannot withdraw the leftover BNB balance to other than buy back wallet");
        require(leftOverBalanceAfterSwap > 0, "The BNB balance must be greater than 0");
        
        // prevent re-entrancy attacks
        uint256 amount = leftOverBalanceAfterSwap;
        leftOverBalanceAfterSwap = 0;
        recipient.transfer(amount);
    }
   
       function transfer(address recipient, uint256 amount) public override returns (bool) {
           _transfer(_msgSender(), recipient, amount);
           return true;
       }
   
       function allowance(address owner, address spender) public view override returns (uint256) {
           return _allowances[owner][spender];
       }
   
       function approve(address spender, uint256 amount) public override returns (bool) {
           _approve(_msgSender(), spender, amount);
           return true;
       }
   
       function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
           _transfer(sender, recipient, amount);
           _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
           return true;
       }
   
       function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
           _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
           return true;
       }
   
       function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
           _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
           return true;
       }
   
       function isExcludedFromReward(address account) public view returns (bool) {
           return _isExcluded[account];
       }
   
       function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
           require(tAmount <= _tTotal, "Amount must be less than supply");
           if (!deductTransferFee) {
               (uint256 rAmount,,,,,) = _getValues(tAmount);
               return rAmount;
           } else {
               (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
               return rTransferAmount;
           }
       }
   
       function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
           require(rAmount <= _rTotal, "Amount must be less than total reflections");
           uint256 currentRate =  _getRate();
           return rAmount.div(currentRate);
       }
   
       function excludeFromReward(address account) external onlyOwner() {
           // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
           require(!_isExcluded[account], "Account is already excluded");
           if(_rOwned[account] > 0) {
               _tOwned[account] = tokenFromReflection(_rOwned[account]);
           }
           _isExcluded[account] = true;
           _excluded.push(account);
       }
   
       function includeInReward(address account) external onlyOwner() {
           require(_isExcluded[account], "Account is already included");
           for (uint256 i = 0; i < _excluded.length; i++) {
               if (_excluded[i] == account) {
                   _excluded[i] = _excluded[_excluded.length - 1];
                   _tOwned[account] = 0;
                   _isExcluded[account] = false;
                   _excluded.pop();
                   break;
               }
           }
       }
           function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
           (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, uint256 tLiquidity, uint256 tCause, uint256 tGrowth) = _getValues(tAmount);
           _tOwned[sender] = _tOwned[sender].sub(tAmount);
           _rOwned[sender] = _rOwned[sender].sub(rAmount);
           _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
           _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
           _takeLiquidity(tLiquidity);
           _takeCause(tCause);
           _takeGrowth(tGrowth);
           emit Transfer(sender, recipient, tTransferAmount);
       }
       
       function excludeFromFee(address account) external onlyOwner {
           _isExcludedFromFee[account] = true;
       }
       
       function includeInFee(address account) external onlyOwner {
           _isExcludedFromFee[account] = false;
       }
   
       function setCauseFeePercent(uint256 causeFee) external onlyOwner() {
           _causeFee = causeFee;
       }

       function setGrowthFeePercent(uint256 growthFee) external onlyOwner() {
        _growthFee = growthFee;
    }
       
       function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {
           _liquidityFee = liquidityFee;
       }
      
       function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
           _maxTxAmount = _tTotal.mul(maxTxPercent).div(
               10**2
           );
       }
   
       function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
           swapAndLiquifyEnabled = _enabled;
           emit SwapAndLiquifyEnabledUpdated(_enabled);
       }
       
        //to receive BNB from uniswapV2Router when swapping
       receive() external payable {}

       function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
           (uint256 tTransferAmount, uint256 tLiquidity, uint256 tCause, uint256 tGrowth) = _getTValues(tAmount);
           (uint256 rAmount, uint256 rTransferAmount) = _getRValues(tAmount, tLiquidity, tCause, tGrowth, _getRate());
           return (rAmount, rTransferAmount, tTransferAmount, tLiquidity, tCause, tGrowth);
       }
   
       function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) {
           uint256 tLiquidity = calculateLiquidityFee(tAmount);
           uint256 tCause = calculateCauseFee(tAmount);
           uint256 tGrowth = calculateGrowthFee(tAmount);
           uint256 tTransferAmount = tAmount.sub(tLiquidity).sub(tCause).sub(tGrowth);
           return (tTransferAmount, tLiquidity, tCause, tGrowth);
       }
   
       function _getRValues(uint256 tAmount, uint256 tLiquidity, uint256 tCause, uint256 tGrowth, uint256 currentRate) private pure returns (uint256, uint256) {
           uint256 rAmount = tAmount.mul(currentRate);
           uint256 rLiquidity = tLiquidity.mul(currentRate);
           uint256 rCause = tCause.mul(currentRate);
           uint256 rGrowth = tGrowth.mul(currentRate);
           uint256 rTransferAmount = rAmount.sub(rLiquidity).sub(rCause).sub(rGrowth);
           return (rAmount, rTransferAmount);
       }
   
       function _getRate() private view returns(uint256) {
           (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
           return rSupply.div(tSupply);
       }
   
       function _getCurrentSupply() private view returns(uint256, uint256) {
           uint256 rSupply = _rTotal;
           uint256 tSupply = _tTotal;      
           for (uint256 i = 0; i < _excluded.length; i++) {
               if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
               rSupply = rSupply.sub(_rOwned[_excluded[i]]);
               tSupply = tSupply.sub(_tOwned[_excluded[i]]);
           }
           if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
           return (rSupply, tSupply);
       }
       
       function _takeLiquidity(uint256 tLiquidity) private {
           uint256 currentRate =  _getRate();
           uint256 rLiquidity = tLiquidity.mul(currentRate);
           _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
           if(_isExcluded[address(this)])
               _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
       }
       
       function _takeCause(uint256 tCause) private {
           uint256 currentRate =  _getRate();
           uint256 rCause = tCause.mul(currentRate);
           _rOwned[_causeWalletAddress] = _rOwned[_causeWalletAddress].add(rCause);
           if(_isExcluded[_causeWalletAddress])
               _tOwned[_causeWalletAddress] = _tOwned[_causeWalletAddress].add(tCause);
       }

       function _takeGrowth(uint256 tGrowth) private {
        uint256 currentRate =  _getRate();
        uint256 rGrowth = tGrowth.mul(currentRate);
        _rOwned[_growthWalletAddress] = _rOwned[_growthWalletAddress].add(rGrowth);
        if(_isExcluded[_growthWalletAddress])
            _tOwned[_growthWalletAddress] = _tOwned[_growthWalletAddress].add(tGrowth);
        }
   
       function calculateCauseFee(uint256 _amount) private view returns (uint256) {
           return _amount.mul(_causeFee).div(
               10**2
           );
       }

       function calculateGrowthFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_growthFee).div(
            10**2
        );
    }
   
       function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
           return _amount.mul(_liquidityFee).div(
               10**2
           );
       }
       
       function removeAllFee() private {
           if(_causeFee == 0 && _growthFee == 0 && _liquidityFee == 0) return;
           
           _previousCauseFee = _causeFee;
           _previousGrowthFee = _growthFee;
           _previousLiquidityFee = _liquidityFee;
           
           _causeFee = 0;
           _growthFee = 0;
           _liquidityFee = 0;
       }
       
       function restoreAllFee() private {
           _causeFee = _previousCauseFee;
           _growthFee = _previousGrowthFee;
           _liquidityFee = _previousLiquidityFee;
       }
       
       function isExcludedFromFee(address account) public view returns(bool) {
           return _isExcludedFromFee[account];
       }
   
       function _approve(address owner, address spender, uint256 amount) private {
           require(owner != address(0), "ERC20: approve from the zero address");
           require(spender != address(0), "ERC20: approve to the zero address");
   
           _allowances[owner][spender] = amount;
           emit Approval(owner, spender, amount);
       }
   
       function _transfer(
           address from,
           address to,
           uint256 amount
       ) private {
           require(from != address(0), "ERC20: transfer from the zero address");
           require(to != address(0), "ERC20: transfer to the zero address");
           require(amount > 0, "Transfer amount must be greater than zero");

         if(to != _causeWalletAddress){
             if(from != owner() && to != owner()){
             require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
         }
         }
        
   
           // is the token balance of this contract address over the min number of
           // tokens that we need to initiate a swap + liquidity lock?
           // also, don't get caught in a circular liquidity event.
           // also, don't swap & liquify if sender is uniswap pair.
           uint256 contractTokenBalance = balanceOf(address(this));
           
           if(contractTokenBalance >= _maxTxAmount)
           {
               contractTokenBalance = _maxTxAmount;
           }
           
           bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
           if (
               overMinTokenBalance &&
               !inSwapAndLiquify &&
               from != uniswapV2Pair &&
               swapAndLiquifyEnabled
           ) {
               contractTokenBalance = numTokensSellToAddToLiquidity;
               //add liquidity
               swapAndLiquify(contractTokenBalance);
           }
           
           //indicates if fee should be deducted from transfer
           bool takeFee = true;
           
           //if any account belongs to _isExcludedFromFee account then remove the fee
           if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
               takeFee = false;
           }
           
           //transfer amount, it will take tax, burn, liquidity fee
           _tokenTransfer(from,to,amount,takeFee);
       }
   
       function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
           // split the contract balance into halves
           uint256 half = contractTokenBalance.div(2);
           uint256 otherHalf = contractTokenBalance.sub(half);
   
           // capture the contract's current ETH balance.
           // this is so that we can capture exactly the amount of ETH that the
           // swap creates, and not make the liquidity event include any ETH that
           // has been manually sent to the contract
           uint256 initialBalance = address(this).balance;
   
           // swap tokens for ETH
           swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered
   
           // how much ETH did we just swap into?
           uint256 newBalance = address(this).balance.sub(initialBalance);
   
           // add liquidity to uniswap
           addLiquidity(otherHalf, newBalance);

           leftOverBalanceAfterSwap = address(this).balance;
           
           emit SwapAndLiquify(half, newBalance, otherHalf);
       }
   
       function swapTokensForEth(uint256 tokenAmount) private {
           // generate the uniswap pair path of token -> weth
           address[] memory path = new address[](2);
           path[0] = address(this);
           path[1] = uniswapV2Router.WETH();
   
           _approve(address(this), address(uniswapV2Router), tokenAmount);
   
           // make the swap
           uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
               tokenAmount,
               0, // accept any amount of ETH
               path,
               address(this),
               block.timestamp
           );
       }
   
       function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
           // approve token transfer to cover all possible scenarios
           _approve(address(this), address(uniswapV2Router), tokenAmount);
   
           // add the liquidity
           uniswapV2Router.addLiquidityETH{value: ethAmount}(
               address(this),
               tokenAmount,
               0, // slippage is unavoidable
               0, // slippage is unavoidable
               owner(),
               block.timestamp
           );
       }
   
       //this method is responsible for taking all fee, if takeFee is true
       function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
           if(!takeFee)
               removeAllFee();
           
           if (_isExcluded[sender] && !_isExcluded[recipient]) {
               _transferFromExcluded(sender, recipient, amount);
           } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
               _transferToExcluded(sender, recipient, amount);
           } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
               _transferStandard(sender, recipient, amount);
           } else if (_isExcluded[sender] && _isExcluded[recipient]) {
               _transferBothExcluded(sender, recipient, amount);
           } else {
               _transferStandard(sender, recipient, amount);
           }
           
           if(!takeFee)
               restoreAllFee();
       }
   
       function _transferStandard(address sender, address recipient, uint256 tAmount) private {
           (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, uint256 tLiquidity, uint256 tCause, uint256 tGrowth) = _getValues(tAmount);
           _rOwned[sender] = _rOwned[sender].sub(rAmount);
           _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
           _takeLiquidity(tLiquidity);
           _takeCause(tCause);
           _takeGrowth(tGrowth);
           emit Transfer(sender, recipient, tTransferAmount);
       }
   
       function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
           (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, uint256 tLiquidity, uint256 tCause, uint256 tGrowth) = _getValues(tAmount);
           _rOwned[sender] = _rOwned[sender].sub(rAmount);
           _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
           _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
           _takeLiquidity(tLiquidity);
           _takeCause(tCause);
           _takeGrowth(tGrowth);
           emit Transfer(sender, recipient, tTransferAmount);
       }
   
       function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
           (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, uint256 tLiquidity, uint256 tCause, uint256 tGrowth) = _getValues(tAmount);
           _tOwned[sender] = _tOwned[sender].sub(tAmount);
           _rOwned[sender] = _rOwned[sender].sub(rAmount);
           _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
           _takeLiquidity(tLiquidity);
           _takeCause(tCause);
           _takeGrowth(tGrowth);
           emit Transfer(sender, recipient, tTransferAmount);
       }
   
   }
