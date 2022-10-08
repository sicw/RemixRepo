// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/*
    永远不要相信错误数据。 默认情况下，错误数据会通过外部调用链向上冒泡，这意味着一个合约可能会收到一个它直接调用的任何合约中没有定义的错误。
    此外，任何合约都可以通过返回与错误签名相匹配的数据来伪造任何错误，即使该错误没有在任何地方定义。
*/
contract AbiError{

    error InsufficientBalance(uint256 available, uint256 required);

    /*
        Error provided by the contract:
        InsufficientBalance
        Parameters:
        {
            "available": {
                "value": "0"
            },
            "required": {
                "value": "1"
            }
        }
    */
    // 上面注解中的样例 应该是解码过的
    function transfer(uint amount) public pure {
        revert InsufficientBalance(0, amount);
    }
}